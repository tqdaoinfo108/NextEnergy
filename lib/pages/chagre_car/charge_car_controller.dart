import 'dart:async';
import 'dart:convert';
import 'dart:io';

// import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:crypto/crypto.dart';
import '../../model/ble_response_model.dart';
import '../../model/booking_model.dart';
import '../../model/payment_model.dart';
import '../../model/price_model.dart';
import '../../model/response_base.dart';
import '../../services/base_hive.dart';
import '../../services/getxController.dart';
import '../../services/https.dart';
import '../../services/localization_service.dart';
import '../../services/network_connect.dart';
import '../../utils/const.dart';
import '../customs/count_down.dart';

class ChargeCarBind extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChargeCarController>(() => ChargeCarController());
  }
}

class ChargeCarController extends GetxControllerCustom
    with WidgetsBindingObserver {
  late StreamSubscription<List<ScanResult>> scanBlueoothSubScription;
  late StreamSubscription<BluetoothAdapterState> stateBluetoothSubscription;
  StreamSubscription<BluetoothConnectionState>? stateConnectedSubscription;

  bool isVip = false;
  RxList<PriceModel> listPrice = RxList.empty();

  Rx<PriceModel> currentPrice = PriceModel().obs;

  // Name Device
  String nameDevice = "";
  String originalQRCode = ""; // Lưu mã QR gốc để xác định characteristic
  final int expiredTimeValue =
      HiveHelper.get(Constants.EXPIRED_ON_HARDWARE, defaultvalue: 90);
  // is On Ble
  final Rx<BluetoothAdapterState> _stateBluetooth =
      Rx<BluetoothAdapterState>(BluetoothAdapterState.off);
  bool get isOnBluetooth => _stateBluetooth.value == BluetoothAdapterState.on;

  // is Connected
  final Rx<BluetoothConnectionState> _stateConnectedDevice =
      Rx(BluetoothConnectionState.disconnected);
  bool get isConnectedDevice =>
      _stateConnectedDevice.value == BluetoothConnectionState.connected;

  // đã xác thực thành công
  RxBool isAuthorize = RxBool(false);
  bool get isAvailable =>
      isOnBluetooth && isConnectedDevice && isAuthorize.value;

  // Retry connection status
  RxInt currentRetryAttempt = RxInt(0);
  RxInt maxRetryAttempts = RxInt(3);
  RxString retryStatus = RxString(''); // "Đang kết nối... (Lần 2/3)"

  // Authorization state
  bool _isAuthorizingInProgress = false; // Prevent concurrent authorization

  // Smart connection management
  bool _shouldMaintainConnection = false;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  BluetoothDevice? _currentDevice;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;

  // Thiết bị phần cứng
  Rx<ChargeCarPageEnum> pageEnum = Rx(ChargeCarPageEnum.CONNECTING);

  bool get canPop {
    // ❌ Không cho back khi đang authorize hoặc đang charging
    if (_isAuthorizingInProgress) {
      print("⚠️ Cannot go back - authorization in progress");
      return false;
    }

    return [
      ChargeCarPageEnum.CHOOSE_TIME,
      ChargeCarPageEnum.CONNECTING,
    ].contains(pageEnum.value);
  }

  @override
  void onInit() {
    super.onInit();
    isLoading.value = false;
    bookingData = null;
    // kiểm tra bật tắt bluetooth

    stateBluetoothSubscription = FlutterBluePlus.adapterState
        .listen((BluetoothAdapterState state) async {
      _stateBluetooth.value = state;

      // Nếu thiết bị android sẽ tự động bật
      if (state == BluetoothAdapterState.off) {
        if (Platform.isAndroid) {
          await FlutterBluePlus.turnOn();
        }
      }
    });

    if (Get.arguments is String) {
      originalQRCode = Get.arguments; // Lưu mã QR gốc
      nameDevice = originalQRCode
          .replaceAll('_1', '')
          .replaceAll('_2', ''); // Remove suffix cho Bluetooth scan
      // chờ bật bluetooth rồi connect

      connectDevice().then((value) async {
        // ⏳ Đợi thêm thời gian cho authorization hoàn thành (retry có thể mất ~19s)
        await Future.delayed(const Duration(seconds: 20));

        // ✅ Kiểm tra kỹ hơn - chỉ back nếu thực sự thất bại
        // Nếu đã chuyển sang CHOOSE_TIME page thì authorization đã thành công
        if (isClosed) {
          print("⚠️ Controller already disposed, skipping auto-back check");
          return;
        }

        if (pageEnum.value == ChargeCarPageEnum.CHOOSE_TIME) {
          print("✅ Already on CHOOSE_TIME page - authorization successful");
          return;
        }

        if (!isAvailable && Get.currentRoute == "/charge_car") {
          print(
              "⚠️ Auto-back triggered: Connection/Authorization failed after extended timeout");
          print("   - isOnBluetooth: $isOnBluetooth");
          print("   - isConnectedDevice: $isConnectedDevice");
          print("   - isAuthorize: ${isAuthorize.value}");
          print("   - pageEnum: ${pageEnum.value}");
          EasyLoading.showError(TKeys.fail_again2.translate());
          back();
        } else if (isAvailable) {
          print("✅ Connection and authorization successful");
        }
      });
    } else {
      bookingData = Get.arguments as BookingModel?;
      originalQRCode = bookingData?.hardwareName ?? "";
      nameDevice = originalQRCode.replaceAll('_1', '').replaceAll('_2', '');
      pageEnum.value = ChargeCarPageEnum.CHARGING;
      onInitWhenBookingExist();
      connectDevice(isBackWhenDontConnect: false);
      getListPrice();
    }
  }

//   /// load when booking exits
  onInitWhenBookingExist() async {
    if (processbarTimer != null) {
      processbarTimer!.cancel();
    }
    bool isContinueCompleteBooking = true;
    processbarTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (bookingData != null) {
        var value = (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000) -
            bookingData!.dateStart!;
        percentProcessbar.value = value;
        getTimeStillText.value = _printDuration(
            Duration(seconds: percentProcessbar.value),
            isShowSecond: false);

        getTimeTotalsText.value = bookingData != null
            ? _printDuration(
                Duration(
                    seconds: (bookingData!.dateEnd! - bookingData!.dateStart!)
                        .toInt()),
                isShowSecond: false)
            : "";

        if (bookingData!.getDurationTimeEnd - percentProcessbar.value < 20) {
          var listDevice = FlutterBluePlus.connectedDevices;
          for (var device in listDevice) {
            await device.disconnect();
          }
        }

        if (percentProcessbar.value >= bookingData!.getDurationTimeEnd &&
            pageEnum.value == ChargeCarPageEnum.CHARGING &&
            isContinueCompleteBooking) {
          isContinueCompleteBooking = false;

          // Tắt smart reconnect vì charging đã hoàn thành
          _disableConnectionMaintenance();

          EasyLoading.showSuccess(
              TKeys.complete_charging_end_processing_auto.translate(),
              duration: const Duration(seconds: 5));
          await HttpHelper.updateBookingComplete(bookingData?.bookID ?? 0);
          processbarTimer?.cancel();
          back();
        }
      }
    });
  }

  void setPaymentData(ResponseBase<PaymentModel> data) {
    paymentData = data.data;
    bookingData = data.data!.booking;
  }

  back() async {
    try {
      print("🔙 Starting cleanup before going back");

      // Dừng smart reconnect khi thoát
      _shouldMaintainConnection = false;
      _stopReconnectTimer();

      bookingData = null;
      isauthorizeDevice = false;
      
      // ✅ Cancel scan subscription TRƯỚC khi stop scan
      try {
        scanBlueoothSubScription.cancel();
        print("✅ Scan subscription cancelled");
      } catch (e) {
        print("⚠️ Error cancelling scan subscription: $e");
      }
      
      // ✅ Stop scan
      try {
        await FlutterBluePlus.stopScan();
        print("✅ Scan stopped");
      } catch (e) {
        print("⚠️ Error stopping scan: $e");
      }

      // Disconnect và clear GATT cache cho tất cả devices
      var listDevice = FlutterBluePlus.connectedDevices;
      for (var device in listDevice) {
        print("🔙 Disconnecting device: ${device.platformName}");

        try {
          // Clear GATT cache trước khi disconnect (Android only)
          if (Platform.isAndroid) {
            await device.clearGattCache();
            print("🧹 GATT cache cleared for ${device.platformName}");
          }

          await device.disconnect();
          print("✅ Device disconnected: ${device.platformName}");
        } catch (e) {
          print("❌ Error disconnecting device: $e");
        }
      }

      // Cancel subscriptions
      try {
        stateBluetoothSubscription.cancel();
        print("✅ Bluetooth state subscription cancelled");
      } catch (e) {
        print("⚠️ Error cancelling Bluetooth state subscription: $e");
      }
      
      try {
        stateConnectedSubscription?.cancel();
        print("✅ Connected state subscription cancelled");
      } catch (e) {
        print("⚠️ Error cancelling connected state subscription: $e");
      }
      
      try {
        _connectionStateSubscription?.cancel();
        print("✅ Connection state subscription cancelled");
      } catch (e) {
        print("⚠️ Error cancelling connection state subscription: $e");
      }

      print("✅ Cleanup completed");
    } finally {
      pageEnum.value = ChargeCarPageEnum.CONNECTING;
      Get.back();
    }
  }

  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;
  }

  // Enable connection maintenance during charging
  void _enableConnectionMaintenance() {
    _shouldMaintainConnection = true;
    _reconnectAttempts = 0;
    print("🔗 Connection maintenance enabled for charging session");
  }

  // Disable connection maintenance
  void _disableConnectionMaintenance() {
    _shouldMaintainConnection = false;
    _stopReconnectTimer();
    print("🔗 Connection maintenance disabled");
  }

  // Continuous reconnect for CHARGING session - NO GIVE UP
  void _startContinuousReconnect() async {
    if (!_shouldMaintainConnection) {
      print("⏭️ Continuous reconnect stopped - maintenance disabled");
      return;
    }

    if (pageEnum.value != ChargeCarPageEnum.CHARGING) {
      print("⏭️ Not in CHARGING state anymore, stopping continuous reconnect");
      return;
    }

    _reconnectAttempts++;
    print(
        "🔄 Continuous reconnect attempt #$_reconnectAttempts (UNLIMITED during charging)");

    // Progressive delay: 2s, 4s, 6s, max 10s
    int delaySeconds = (_reconnectAttempts * 2).clamp(2, 10);
    await Future.delayed(Duration(seconds: delaySeconds));

    // Check again after delay
    if (!_shouldMaintainConnection ||
        pageEnum.value != ChargeCarPageEnum.CHARGING) {
      print("⏭️ Reconnect cancelled after delay");
      return;
    }

    try {
      if (_currentDevice != null) {
        print(
            "📱 Attempting direct connect to saved device (charging session)");

        // Try to connect
        await _currentDevice!.connect(
            autoConnect: false, // Use false for more reliable reconnect
            timeout: const Duration(seconds: 8),
            mtu: null);

        print("✅ Reconnected successfully!");

        // Wait a bit for connection to stabilize
        await Future.delayed(const Duration(milliseconds: 500));

        // Verify connection
        var connectionState = await _currentDevice!.connectionState.first;
        if (connectionState == BluetoothConnectionState.connected) {
          print("✅ Connection verified, resetting reconnect counter");
          _reconnectAttempts = 0;

          // ✅ Re-authorize after successful reconnect
          if (!isAuthorize.value && !isClosed) {
            print("🔐 Re-authorizing device after reconnect...");
            isauthorizeDevice = false; // Reset flag to allow re-auth
            await authorizeDevice(_currentDevice!);
          }
        } else {
          throw Exception("Connection not stable");
        }
      } else {
        print("❌ No saved device, cannot reconnect");
      }
    } catch (e) {
      print("❌ Reconnect attempt #$_reconnectAttempts failed: $e");

      // ✅ ALWAYS retry if still charging - NO GIVE UP
      if (_shouldMaintainConnection &&
          pageEnum.value == ChargeCarPageEnum.CHARGING) {
        print("♻️ Will retry reconnect continuously...");
        _reconnectTimer = Timer(
          Duration(seconds: delaySeconds),
          () => _startContinuousReconnect(),
        );
      }
    }
  }

  // Attempt to reconnect to device (with max attempts limit)
  void _attemptReconnect() async {
    if (!_shouldMaintainConnection) {
      print("⏭️ Reconnect skipped - maintenance disabled");
      return;
    }

    if (_reconnectAttempts >= _maxReconnectAttempts) {
      print("⚠️ Max reconnect attempts reached ($_maxReconnectAttempts)");
      EasyLoading.showError(
        TKeys.fail_again2.translate(),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    _reconnectAttempts++;
    print("🔄 Reconnect attempt $_reconnectAttempts/$_maxReconnectAttempts");

    // Đợi một chút trước khi thử reconnect
    await Future.delayed(Duration(seconds: 2 * _reconnectAttempts));

    if (!_shouldMaintainConnection) return;

    try {
      // Nếu có current device, thử connect trực tiếp
      if (_currentDevice != null) {
        print("📱 Attempting direct connect to saved device");
        await _currentDevice!.connect(
            autoConnect: true, timeout: const Duration(seconds: 10), mtu: null);
        print("✅ Reconnected successfully");
        _reconnectAttempts = 0;

        // Re-authorize sau khi reconnect
        if (!isAuthorize.value) {
          await authorizeDevice(_currentDevice!);
        }
      } else {
        // Fallback: scan lại device
        print("🔍 Scanning for device: $nameDevice");
        await connectDevice(timeoutSecond: 15, isBackWhenDontConnect: false);
      }
    } catch (e) {
      print("❌ Reconnect attempt failed: $e");

      // Thử lại sau một khoảng thời gian
      if (_reconnectAttempts < _maxReconnectAttempts) {
        _reconnectTimer = Timer(
          Duration(seconds: 3 * _reconnectAttempts),
          () => _attemptReconnect(),
        );
      }
    }
  }

  // kết nối device
  Future<void> connectDevice(
      {isCheckQR = false,
      isBackWhenDontConnect = true,
      int timeoutSecond = 10}) async {
    while (!isOnBluetooth) {
      await FlutterBluePlus.adapterState
          .where((val) => val == BluetoothAdapterState.on)
          .first;
    }
    
    // ✅ Check if controller is disposed
    if (isClosed) {
      print("❌ Controller disposed, cannot start connection");
      return;
    }
    
    // ✅ BƯỚC 1: Disconnect tất cả thiết bị hiện tại trước khi bắt đầu
    print("🧹 Step 1: Cleaning up existing connections...");
    var connectedDevices = FlutterBluePlus.connectedDevices;
    for (var device in connectedDevices) {
      try {
        print("🔌 Disconnecting existing device: ${device.platformName}");
        await device.disconnect();
        await Future.delayed(const Duration(milliseconds: 300));
      } catch (e) {
        print("⚠️ Error disconnecting device: $e");
      }
    }
    print("✅ Step 1 completed: All existing connections cleared");
    
    // ✅ BƯỚC 2: Cancel old subscription nếu có
    try {
      scanBlueoothSubScription.cancel();
      print("✅ Old scan subscription cancelled");
    } catch (e) {
      print("⚠️ No old scan subscription to cancel or error: $e");
    }
    
    // ✅ BƯỚC 2.1: Đảm bảo scan đã dừng
    try {
      await FlutterBluePlus.stopScan();
      await Future.delayed(const Duration(milliseconds: 300));
      print("✅ Scan stopped");
    } catch (e) {
      print("⚠️ Error stopping scan: $e");
    }

    int scanCount = 0;
    const int maxScans = 6; // Tối đa 6 lần scan/connect
    bool deviceFound = false;

    // ✅ Create NEW subscription
    scanBlueoothSubScription = FlutterBluePlus.onScanResults.listen(
      (results) async {
        if (results.isEmpty) return;
        if (deviceFound) return; // Tránh xử lý duplicate

        ScanResult result = results.last;
        if (result.device.platformName == nameDevice) {
          deviceFound = true;
          print("📱 Found device: $nameDevice, RSSI: ${result.rssi}, Attempt: ${scanCount + 1}/$maxScans");

          // ✅ Stop scan immediately to prevent duplicate connections
          await FlutterBluePlus.stopScan();
          print("🛑 Scan stopped after finding device");

          // Lưu device để có thể reconnect sau này
          _currentDevice = result.device;

          // ✅ BƯỚC 3: Thử connect với timeout ngắn (3s)
          bool connectionSuccess = false;
          
          for (int attempt = 1; attempt <= 5; attempt++) {
            if (isClosed) {
              print("❌ Controller disposed, stopping connection attempts");
              return;
            }

            try {
              print("🔌 Connection attempt $attempt/5 (Scan round ${scanCount + 1})");
              
              // Update UI status
              currentRetryAttempt.value = attempt;
              maxRetryAttempts.value = 5;
              retryStatus.value = 'Đang kết nối... (Lần $attempt/5)';
              
              // ⚡ Timeout ngắn: 3 giây
              await result.device.connect(
                autoConnect: false,
                timeout: const Duration(seconds: 3),
                mtu: null,
              );

              // Verify connection
              await Future.delayed(const Duration(milliseconds: 300));
              var connectionState = await result.device.connectionState.first;
              
              if (connectionState == BluetoothConnectionState.connected) {
                print("✅ Connection successful on attempt $attempt!");
                connectionSuccess = true;
                
                // Request MTU if Android
                if (Platform.isAndroid) {
                  try {
                    await result.device.requestMtu(512);
                    print("📶 MTU size updated to 512");
                  } catch (e) {
                    print("⚠️ MTU request failed: $e");
                  }
                }
                
                break; // Success - exit retry loop
              } else {
                print("❌ Connection state not connected: $connectionState");
                throw Exception("Connection state not connected");
              }
            } catch (e) {
              print("❌ Connection attempt $attempt failed: $e");
              
              if (attempt < 5) {
                // Disconnect và đợi trước khi thử lại
                try {
                  await result.device.disconnect();
                  await Future.delayed(Duration(seconds: 1 * attempt)); // Progressive delay: 1s, 2s, 3s, 4s
                } catch (disconnectError) {
                  print("⚠️ Error disconnecting before retry: $disconnectError");
                }
              }
            }
          }

          if (!connectionSuccess) {
            print("❌ Failed all 5 connection attempts for scan round ${scanCount + 1}");
            
            // ✅ BƯỚC 4: Nếu chưa hết 6 lần, tiếp tục scan
            scanCount++;
            if (scanCount < maxScans) {
              print("🔄 Retrying scan... (Round ${scanCount + 1}/$maxScans)");
              deviceFound = false; // Reset flag để có thể scan lại
              
              // Delay trước khi scan lại
              await Future.delayed(const Duration(seconds: 2));
              
              if (!isClosed) {
                try {
                  await FlutterBluePlus.startScan(
                    withNames: [nameDevice],
                    timeout: Duration(seconds: 5),
                  );
                  print("✅ New scan started for round ${scanCount + 1}");
                } catch (e) {
                  print("❌ Error starting new scan: $e");
                }
              }
              return;
            } else {
              // ✅ BƯỚC 5: Đã hết 6 lần, báo lỗi và back
              print("❌ Failed after $maxScans scan/connect rounds");
              retryStatus.value = '';
              currentRetryAttempt.value = 0;
              
              // ✅ Cancel subscription để tránh trigger lại
              try {
                scanBlueoothSubScription.cancel();
                print("✅ Scan subscription cancelled after all retries failed");
              } catch (e) {
                print("⚠️ Error cancelling subscription: $e");
              }
              
              if (!isClosed && Get.currentRoute == "/charge_car") {
                EasyLoading.showError(TKeys.fail_again2.translate());
                back();
              }
              return;
            }
          }

          // ✅ Connection thành công - tiếp tục setup
          print("✅ Connection established successfully");
          retryStatus.value = '';
          currentRetryAttempt.value = 0;

          // ❌ REMOVED: Không gọi authorizeDevice ở đây để tránh duplicate
          // authorizeDevice sẽ được gọi trong connection state listener
          _stateConnectedDevice.value = BluetoothConnectionState.connected;

          // Setup connection state monitoring với reconnect logic
          _connectionStateSubscription?.cancel();
          _connectionStateSubscription = result.device.connectionState
              .listen((BluetoothConnectionState state) async {
            _stateConnectedDevice.value = state;

            if (state == BluetoothConnectionState.disconnected) {
              isAuthorize.value = false;
              isauthorizeDevice = false;

              // Clear GATT cache khi disconnect (Android only)
              if (Platform.isAndroid && Get.currentRoute != "/charge_car")   {
                try {
                  await result.device.clearGattCache();
                } catch (e) {}
              }

              // ✅ Tự động reconnect LIÊN TỤC nếu đang charging
              if (_shouldMaintainConnection &&
                  pageEnum.value == ChargeCarPageEnum.CHARGING) {
                _startContinuousReconnect();
              } else if (_shouldMaintainConnection) {
                _attemptReconnect();
              }
              return;
            }

            // ✅ Authorize when connected (includes reconnect scenarios)
            if (!isAuthorize.value && !isauthorizeDevice) {
              isauthorizeDevice = true;

              // ✅ Verify device still connected before operations
              var currentConnectionState =
                  await result.device.connectionState.first;
              if (currentConnectionState !=
                  BluetoothConnectionState.connected) {
                isauthorizeDevice = false; // Reset flag
                return;
              }

              // ✅ Check controller not disposed
              if (isClosed) {
                return;
              }

              findBluetoothCharacteristic();
              var listDevice = FlutterBluePlus.connectedDevices;
              if (listDevice.isEmpty) {
                isauthorizeDevice = false; // Reset flag
                return;
              }
              var device = FlutterBluePlus.connectedDevices.first;

              // ✅ Request MTU with connection check
              if (Platform.isAndroid && !isClosed) {
                try {
                  await device.requestMtu(512);
                } catch (e) {
                  // Continue with authorization even if MTU fails
                }
              }

              await authorizeDevice(device);
            } else if (isAuthorize.value) {
            } else {}
          });

          // ✅ Check current connection state để trigger authorize nếu đã connected
          var currentState = await result.device.connectionState.first;
          if (currentState == BluetoothConnectionState.connected &&
              !isAuthorize.value &&
              !isauthorizeDevice) {
            // ✅ Check controller not disposed
            if (isClosed) {
              return;
            }

            isauthorizeDevice = true;

            // ✅ Request MTU with error handling
            if (Platform.isAndroid && !isClosed) {
              try {
                await result.device.requestMtu(512);
              } catch (e) {
                // Continue with authorization
              }
            }

            authorizeDevice(result.device);
          }
        }
      },
    );
    FlutterBluePlus.cancelWhenScanComplete(scanBlueoothSubScription);

    // ✅ BƯỚC 2.5: Bắt đầu scan lần đầu tiên
    print("🔍 Starting initial scan for device: $nameDevice");
    await FlutterBluePlus.startScan(
        withNames: [nameDevice], timeout: Duration(seconds: 5));

    // ✅ BƯỚC 6: Đợi quá trình scan/connect hoàn tất
    // Maximum time: 6 rounds * (5s scan + 5 attempts * 3s + delays) ≈ 2-3 minutes
    int waitCount = 0;
    while (waitCount < 180 && !isClosed) { // 180 seconds max
      await Future.delayed(const Duration(seconds: 1));
      waitCount++;
      
      // Nếu đã authorize thành công thì thoát sớm
      if (isAuthorize.value) {
        print("✅ Authorization completed, exiting wait loop");
        break;
      }
      
      // Nếu đã chuyển sang CHOOSE_TIME thì thoát
      if (pageEnum.value == ChargeCarPageEnum.CHOOSE_TIME) {
        print("✅ Page changed to CHOOSE_TIME, exiting wait loop");
        break;
      }
    }
  }

  // Helper method để read với error handling
  Future<String?> readWithErrorHandling(BluetoothCharacteristic characteristic,
      {int retryCount = 2}) async {
    for (int i = 0; i < retryCount; i++) {
      try {
        var data = await characteristic.read();
        var result = utf8.decode(data);
        print("📡 Read attempt ${i + 1} successful: '$result'");
        return result;
      } catch (e) {
        print("❌ Read attempt ${i + 1} failed: $e");
        if (i < retryCount - 1) {
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    }
    return null;
  }

  bool isFindBluetoothCharacteristic = true;

  // Định nghĩa UUID cho các cổng khác nhau
  static const String CHARACTERISTIC_1_UUID =
      "e6eae575-4d89-4750-bf3e-c82d6a1cd299";
  static const String CHARACTERISTIC_2_UUID =
      "f6eae575-4d89-4750-bf3e-c82d6a1cd29a";

  Future<BluetoothCharacteristic?> findBluetoothCharacteristic(
      {BluetoothDevice? device}) async {
    // ✅ Check controller state first
    if (isClosed) {
      print("❌ Controller disposed, cannot find characteristic");
      return null;
    }

    if (device == null) {
      var listDevice = FlutterBluePlus.connectedDevices;
      if (listDevice.isEmpty) return null;

      device = FlutterBluePlus.connectedDevices.first;
    }

    if (!isFindBluetoothCharacteristic) return null;

    // ✅ Verify device is still connected before MTU request
    try {
      var connectionState = await device.connectionState.first;
      if (connectionState != BluetoothConnectionState.connected) {
        print("❌ Device not connected, cannot find characteristic");
        return null;
      }

      // Request MTU only if device is connected and controller exists
      if (Platform.isAndroid && !isClosed) {
        try {
          await device.requestMtu(512);
          print("📶 MTU requested in findBluetoothCharacteristic");
        } catch (e) {
          print("⚠️ MTU request failed in findBluetoothCharacteristic: $e");
          // Continue even if MTU fails
        }
      }
    } catch (e) {
      print("❌ Error checking connection state: $e");
      return null;
    }

    // ✅ Check again before discovering services
    if (isClosed) {
      print("❌ Controller disposed before discovering services");
      return null;
    }

    try {
      var discoverServices = await device.discoverServices();
      print("🔍 Found ${discoverServices.length} services");
      print("🔍 Device name: $nameDevice");
      print("🔍 Original QR code: $originalQRCode");

      // Xác định UUID target dựa trên mã QR gốc
      String? targetCharacteristicUuid;
      if (originalQRCode.endsWith('_2')) {
        targetCharacteristicUuid = CHARACTERISTIC_2_UUID;

        // Chỉ tìm UUID_2, không fallback
        for (var service in discoverServices) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase() ==
                targetCharacteristicUuid.toLowerCase()) {
              if (characteristic.properties.read &&
                  characteristic.properties.write) {
                print("✅ Found characteristic: ${characteristic.uuid}");
                return characteristic;
              } else {
                print(
                    "⚠️ Characteristic found but missing read/write properties");
              }
            }
          }
        }
        print("❌ Characteristic UUID_2 not found");
        return null;
      } else {
        targetCharacteristicUuid = CHARACTERISTIC_1_UUID;
        // Chỉ tìm UUID_1, không fallback
        for (var service in discoverServices) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase() ==
                targetCharacteristicUuid.toLowerCase()) {
              if (characteristic.properties.read &&
                  characteristic.properties.write) {
                print("✅ Found characteristic: ${characteristic.uuid}");
                return characteristic;
              } else {
                print(
                    "⚠️ Characteristic found but missing read/write properties");
              }
            }
          }
        }
        print("❌ Characteristic UUID_1 not found");
        return null;
      }
    } catch (e) {
      print("❌ Error discovering services: $e");
      return null;
    } finally {
      isFindBluetoothCharacteristic = true;
    }
  }

  // xác thực device
  bool isauthorizeDevice = false;

  authorizeDevice(BluetoothDevice device) async {
    // ✅ Prevent duplicate authorization calls
    if (_isAuthorizingInProgress) {
      print("⚠️ Authorization already in progress, skipping duplicate call");
      return;
    }

    _isAuthorizingInProgress = true;

    try {
      // ✅ Check if controller still exists
      if (isClosed) {
        print("❌ Controller disposed, skipping authorization");
        return;
      }

      // ✅ Check if device is still connected
      var connectionState = await device.connectionState.first;
      if (connectionState != BluetoothConnectionState.connected) {
        print("❌ Device not connected, skipping authorization");
        return;
      }

      var cx = await findBluetoothCharacteristic(device: device);
      if (cx == null || isClosed) {
        print("❌ Characteristic not found or controller disposed");
        return;
      }
      BluetoothCharacteristic c = cx;

      var authenValue = md5
          .convert(utf8.encode(nameDevice.substring(5, 8)))
          .toString()
          .substring(10, 22);
      List<int> bytes = utf8.encode(authenValue);

      print("🔐 Sending auth value: $authenValue");
      print("🔐 Device name: $nameDevice");
      print("🔐 Device substring: ${nameDevice.substring(5, 8)}");

      // ✅ Check before MTU request
      if (isClosed) return;

      // Thử set MTU size
      try {
        await device.requestMtu(512);
        print("📶 MTU size updated to 512");
      } catch (e) {
        print("⚠️ MTU request failed: $e");
      }

      // ✅ Check before write
      if (isClosed) {
        print("❌ Controller disposed before write");
        return;
      }

      // ✅ Verify device still connected before write
      connectionState = await device.connectionState.first;
      if (connectionState != BluetoothConnectionState.connected) {
        print("❌ Device disconnected before write");
        return;
      }

      try {
        await c.write(bytes);
        print("✅ Auth value written successfully");
      } catch (e) {
        print("❌ Failed to write auth value: $e");
        return;
      }

      // ⚡ Giảm delay từ 2s xuống 1s để user không phải đợi lâu
      await Future.delayed(const Duration(seconds: 1));

      // ✅ Check before read
      if (isClosed) {
        print("❌ Controller disposed before read");
        return;
      }

      // ✅ Verify device still connected before read
      connectionState = await device.connectionState.first;
      if (connectionState != BluetoothConnectionState.connected) {
        print("❌ Device disconnected before read");
        return;
      }

      String? rawValue = await readWithErrorHandling(c);
      if (rawValue == null) {
        print("❌ Failed to read response from ESP32");
        if (!isClosed) {
          EasyLoading.showError("Không thể đọc phản hồi từ thiết bị");
        }
        return;
      }

      print("📡 Received from ESP32: '$rawValue'");
      print("📡 Expected auth value: '$authenValue'");

      // ✅ Check before processing response
      if (isClosed) {
        print("❌ Controller disposed before processing response");
        return;
      }

      if (rawValue.isNotEmpty) {
        // nếu gửi mã authen trùng nhận về > back
        if (rawValue.toLowerCase() == authenValue.toLowerCase() &&
            bookingData == null) {
          if (!isClosed) {
            EasyLoading.showInfo(TKeys.machine_in_use.translate(),
                duration: const Duration(seconds: 5));
            back();
          }
          return;
        }

        // ✅ Set authorize TRƯỚC để auto-back check không trigger
        isAuthorize.value = true;
        print("✅ isAuthorize set to TRUE");

        if (rawValue.contains("{") && rawValue.contains("}")) {
          bleResponseModel = BleResponseModel.fromJson(jsonDecode(rawValue));
          print(
              "📦 Parsed BLE response model: bookingID=${bleResponseModel.bookingID}, myId=${bleResponseModel.myId}");

          // ✅ Check if this is an old booking response
          if (bleResponseModel.bookingID != null && bookingData == null) {
            print(
                "⚠️ ESP32 returned existing booking ID: ${bleResponseModel.bookingID}");
            print("⚠️ This might be an old session. Checking with server...");
          }
        } else {
          bleResponseModel = BleResponseModel();
          print("📦 Created empty BLE response model");
        }

        if (bookingData != null && bleResponseModel.bookingID != null) {
          print(
              "🔄 Existing booking detected: ${bookingData?.bookID} vs ${bleResponseModel.bookingID}");
          if (bleResponseModel.bookingID == bookingData?.bookID) {
            if (!isClosed) {
              await onBookingComplete();
            }
            return;
          }
        }
        // Chỉ chưa booking mới cần
        if (bookingData == null && !isClosed) {
          print("🌐 Calling updateHardware API...");
          var checkQRCode =
              await HttpHelper.updateHardware(bleResponseModel.toJson());

          print("🌐 updateHardware response: $checkQRCode");

          if (isClosed) return;

          switch (checkQRCode) {
            case "DEACTIVE":
              EasyLoading.showInfo(
                  TKeys.this_charger_is_out_of_order.translate(),
                  duration: const Duration(seconds: 5));
              back();
              return;
            case "ERROR":
            case "LIMIT":
              EasyLoading.showInfo(TKeys.machine_under_maintenance.translate(),
                  duration: const Duration(seconds: 5));
              back();
              return;
          }
        }

        if (isClosed) return;

        await getListPrice();

        if (isClosed) return;

        if (bookingData == null) {
          print("🎯 Changing page to CHOOSE_TIME");
          pageEnum.value = ChargeCarPageEnum.CHOOSE_TIME;
          print("✅ Page changed to: ${pageEnum.value}");
        } else {
          print("📋 Booking exists, not changing page");
        }

        // Gửi bookingID để xác nhận
        if (bookingData?.bookID != null && !isClosed) {
          // ✅ Verify device still connected
          connectionState = await device.connectionState.first;
          if (connectionState != BluetoothConnectionState.connected) {
            print("❌ Device disconnected, cannot send bookingID");
            return;
          }

          bytes = utf8.encode("${bookingData!.bookID}");
          try {
            await c.write(bytes);
            await Future.delayed(const Duration(milliseconds: 500));
            print("1 === Đã gửi bookingID ${bookingData?.bookID}");
          } catch (e) {
            print("❌ Failed to write bookingID: $e");
          }
        }
      }
    } catch (e) {
      print("❌ Authorization failed: $e");
    } finally {
      _isAuthorizingInProgress = false;
    }
  }

  // lấy danh sách giá
  getListPrice() async {
    var listPriceTemp = await HttpHelper.getPrice(
        bleResponseModel.myId ?? bookingData!.hardwareID!,
        HiveHelper.get(Constants.USER_ID));
    listPrice.value = (listPriceTemp.data ?? []);
    isVip = listPriceTemp.isVIP ?? false;
    if (listPrice.isNotEmpty) {
      currentPrice.value = listPrice[0];
    }
    return;
  }

  Future<bool> openHardware() async {
    bool isResult = false;
    pageEnum.value = ChargeCarPageEnum.WAIT_PLUGING;
    try {
      var devicesConnected = FlutterBluePlus.connectedDevices;

      // không có thiết bị kết nối
      if (devicesConnected.isEmpty) {
        EasyLoading.showInfo(TKeys.fail_again2.translate());
        return false;
      }

      BluetoothCharacteristic c =
          (await findBluetoothCharacteristic(device: devicesConnected.first))!;

      String onCommand =
          "ON:${getTimeOpenHardware()}:${DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000}:${bookingData!.bookID}";
      List<int> bytes = utf8.encode(onCommand);

      await c.write(bytes);

      for (int i = 1; i <= expiredTimeValue; i++) {
        if (i == expiredTimeValue) {
          EasyLoading.showError(TKeys.on_back_300s_message.translate(),
              duration: const Duration(seconds: 5));
          back();
          break;
        }

        String? rawValue = await readWithErrorHandling(c, retryCount: 1);
        if (rawValue == null) {
        } else {
          if ("true" == rawValue.toLowerCase()) {
            var isUpdateComplete =
                await onUpdateAffterHardware(1); // thành công

            if (isUpdateComplete != null && isUpdateComplete.data != null) {
              List<int> bytesPAID = utf8.encode("PAID");

              await c.write(bytesPAID);

              // Enable smart reconnect cho charging session
              _enableConnectionMaintenance();

              onInitWhenBookingExist();
              pageEnum.value = ChargeCarPageEnum.CHARGING;
              isResult = true;
              break;
            } else {
              // Tiếp tục loop để thử lại, thay vì dừng ngay
              if (i >= 3) {
                // Sau 3 lần thử, bỏ qua API và chuyển trực tiếp
                print(
                    "🔥 After 3 attempts, proceeding to CHARGING without API update");
                List<int> bytesPAID = utf8.encode("PAID");
                await c.write(bytesPAID);
                onInitWhenBookingExist();
                pageEnum.value = ChargeCarPageEnum.CHARGING;
                print("🔥 Force changed pageEnum to CHARGING");
                isResult = true;
                break;
              }
            }
          }
        }

        // Chờ 1 giây trước khi đọc lần tiếp theo
        if (i < expiredTimeValue) {
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    } catch (e) {
      // nếu có vấn đề gì khi start > trả tiền > back home
      return false;
    }

    return isResult;
  }

  // sạc hoàn thành
  Future<void> onBookingComplete() async {
    try {
      print("🏁 Starting booking completion process");

      // Tắt smart reconnect vì booking đã complete
      _disableConnectionMaintenance();

      // không có thiết bị kết nối
      if (!isAvailable) {
        EasyLoading.showInfo(TKeys.fail_again2.translate());
        return;
      }

      var characteristic = (await findBluetoothCharacteristic())!;
      var bytes2 = utf8.encode("OFF");

      await characteristic.write(bytes2);
      print("📤 Sent OFF command to device");

      await Future.delayed(const Duration(milliseconds: 500));

      var onCompleteBooking =
          await HttpHelper.updateBookingComplete(bookingData?.bookID ?? 0);
      if (onCompleteBooking != null && onCompleteBooking.data != null) {
        print("✅ Booking completed successfully");

        // Clear GATT cache trước khi disconnect (Android only)
        if (Platform.isAndroid && _currentDevice != null) {
          try {
            await _currentDevice!.clearGattCache();
            print("🧹 GATT cache cleared after completion");
          } catch (e) {
            print("⚠️ Failed to clear GATT cache: $e");
          }
        }

        EasyLoading.showSuccess(
            TKeys.complete_charging_end_processing.translate(),
            duration: const Duration(seconds: 5));
        back();
      }
    } finally {}
  }

  // ----------------------------------------
  // init Booking
  late PaymentModel paymentModel;
  late BookingModel? bookingData;
  late PaymentModel? paymentData;

  late BleResponseModel bleResponseModel;
  RxInt percentProcessbar = 1.obs;
  Timer? processbarTimer;

  //
  RxString getTimeStillText = "".obs;
  RxString getTimeTotalsText = "".obs;
  CountdownController countdownController =
      CountdownController(autoStart: true);

  onChangePrice(PriceModel model) async {
    currentPrice.value = model;
    listPrice.refresh();
  }

  // Gọi API lấy thông tin thanh toán
  Future<PaymentModel?> onBookingPayment() async {
    try {
      var autoPayment = await HttpHelper.autoPayment(bleResponseModel.myId!,
          currentPrice.value.priceID!, bookingData?.bookID);
      if (autoPayment != null && autoPayment.data != null) {
        paymentData = autoPayment.data;
        bookingData = autoPayment.data!.booking;
        return autoPayment.data;
      }
    } finally {}
    return null;
  }

  // Cập nhật trạng thái payment khi thao tác với phẩn cứng
  Future<ResponseBase<PaymentModel>?> onUpdateAffterHardware(int statusID,
      {bool isExtTime = false, int? paymentID}) async {
    print("🔥 onUpdateAffterHardware called with statusID: $statusID");

    if (paymentData == null) {
      print("❌ PaymentData is null - cannot update payment status");
      return null;
    }

    paymentID ??= paymentData!.paymentID!;
    print("🔥 Using paymentID: $paymentID");

    try {
      var data = await HttpHelper.updatePaymentAfterWaitHardware(
          paymentID, statusID,
          isExtTime: isExtTime);

      print("🔥 API response: ${data != null ? 'SUCCESS' : 'NULL'}");
      print("🔥 API data: ${data?.data != null ? 'HAS_DATA' : 'NO_DATA'}");

      if (data != null && data.data != null) {
        bookingData = data.data!.booking;
        print("🔥 Updated bookingData successfully");
        return data;
      } else {
        print("❌ API returned null or empty data");
      }
    } catch (e) {
      print("❌ Exception in onUpdateAffterHardware: $e");
    }
    return null;
  }

  /// mấy hàm convert sang string
  String getTimeOpenHardware({double? time}) {
    time ??= currentPrice.value.priceTime!;

    int intTime = (time * 60).toInt();

    String result = "";
    if (intTime <= 999 && intTime > 99) {
      result = intTime.toString();
    } else if (intTime > 9 && intTime <= 99) {
      result = "0$intTime";
    } else if (intTime > 0) {
      result = "00$intTime";
    }
    return result;
  }

  // Tính thơi gian
  String _printDuration(Duration duration,
      {bool isShowSecond = true, bool isNotCount = false}) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (isShowSecond) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes";
    }
  }

  // Thời gian còn lại nhấn nút cancel
  String get getTimeStill {
    if (bookingData == null ||
        bookingData!.dateEnd == null ||
        bookingData!.dateStart == null) return "--:--";
    var time = (bookingData!.dateEnd! - bookingData!.dateStart!) -
        ((DateTime.now().millisecondsSinceEpoch ~/ 1000) -
            bookingData!.dateStart!);
    var duration = Duration(seconds: time + 60);
    return _printDuration(duration, isShowSecond: false, isNotCount: true);
  }

  onUpdatePayment(int statusID, {int? paymentID}) async {
    paymentID ??= paymentData!.paymentID!;
    try {
      var data = await HttpHelper.updatePayment(paymentID, statusID);
      if (data != null && data.data != null) {
        return true;
      }
    } finally {}
    return false;
  }

  /// Mua thêm thời gian
  Future<PaymentModel?> getPaymentKeyExtTimeBooking(int priceID) async {
    try {
      var getPayment = await HttpHelper.extHoursBooking(
          bookingData!.hardwareID!, priceID, bookingData!.bookID!);
      paymentData = getPayment?.data;
      return getPayment?.data;
    } catch (e) {}
    return null;
  }

  // gọi qua phần cứng tăng thêm thời gian
  Future<bool> extTimeHardware(double? time) async {
    bool isResult = false;
    bool isLoadMethod = true;

    if (!isAvailable) {
      // ignore: use_build_context_synchronously
      await showDialog(
        context: Get.context!,
        builder: (context) => PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text(TKeys.notice.translate(),
                style: Theme.of(context).textTheme.bodyLarge),
            content: Text(TKeys.grant_ble.translate(),
                style: Theme.of(context).textTheme.bodyMedium),
            actions: <Widget>[
              TextButton(
                child: Text(TKeys.cancel.translate(),
                    style: Theme.of(context).textTheme.bodyMedium),
                onPressed: () async {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(TKeys.yes.translate(),
                    style: Theme.of(context).textTheme.bodyMedium),
                onPressed: () async {
                  if (!isLoadMethod) return;
                  isLoadMethod = false;

                  try {
                    var isInternetConnect = await NetworkInfo().isConnected;

                    if (isAvailable && isInternetConnect) {
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                    } else {
                      EasyLoading.showError(TKeys.unable_to_connect.translate(),
                          duration: const Duration(seconds: 5));
                    }
                  } finally {
                    isLoadMethod = true;
                  }
                },
              ),
            ],
          ),
        ),
      ).then((value) async {
        try {
          BluetoothCharacteristic? characteristic =
              await findBluetoothCharacteristic();

          String onCommand = "EXT:${getTimeOpenHardware(time: time)}";
          List<int> bytes = utf8.encode(onCommand);
          await characteristic?.write(bytes);

          var listByteString = await characteristic?.read();
          var rawValue = utf8.decode(listByteString ?? []);

          if ("true" == rawValue.toLowerCase() ||
              "ext_ok" == rawValue.toLowerCase()) {
            isResult = true;
          }
        } catch (e) {
          isResult = false;
        }
      });
    } else {
      try {
        var characteristic = (await findBluetoothCharacteristic())!;

        var bytes2 = utf8.encode("${bookingData!.bookID}");
        await characteristic.write(bytes2);
        await Future.delayed(const Duration(seconds: 1));

        String onCommand = "EXT:${getTimeOpenHardware(time: time)}";
        List<int> bytes = utf8.encode(onCommand);
        await characteristic.write(bytes);

        var listByteString = await characteristic.read();
        var rawValue = utf8.decode(listByteString);
        if ("true" == rawValue.toLowerCase() ||
            "ext_ok" == rawValue.toLowerCase()) {
          isResult = true;
        }
      } catch (e) {
        isResult = false;
      }
    }
    pageEnum.value = ChargeCarPageEnum.CHARGING;
    return isResult;
  }

  /// load when booking exits
  onInitExtBooking() async {
    if (processbarTimer != null) {
      processbarTimer!.cancel();
    }

    bool isContinueCompleteBooking = true;
    processbarTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (bookingData != null) {
        var value = (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000) -
            bookingData!.dateStart!;
        percentProcessbar.value = value;

        getTimeStillText.value = _printDuration(
            Duration(seconds: percentProcessbar.value),
            isShowSecond: false);
        getTimeTotalsText.value = bookingData != null
            ? _printDuration(
                Duration(
                    seconds: (bookingData!.dateEnd! - bookingData!.dateStart!)
                        .toInt()),
                isShowSecond: false)
            : "";

        if (bookingData!.getDurationTimeEnd - percentProcessbar.value < 20) {
          var listDevice = FlutterBluePlus.connectedDevices;
          for (var device in listDevice) {
            await device.disconnect();
          }
        }

        if (percentProcessbar.value >= bookingData!.getDurationTimeEnd &&
            pageEnum.value == ChargeCarPageEnum.CHARGING &&
            isContinueCompleteBooking) {
          isContinueCompleteBooking = false;
          EasyLoading.showSuccess(
              TKeys.complete_charging_end_processing_auto.translate(),
              duration: const Duration(seconds: 5));
          await HttpHelper.updateBookingComplete(bookingData?.bookID ?? 0);
          processbarTimer?.cancel();

          back();
        }
      }
    });
  }

  // Xử lý khi quay lại trang để auto-reconnect
  void handlePageReappear() {
    print('ChargeCarController: Page reappeared, checking Bluetooth status');
    if (!isConnectedDevice) {
      print(
          'ChargeCarController: Bluetooth not connected, attempting auto-reconnect');
      enableBluetoothAndReconnect();
    }
  }

  // Bật Bluetooth và reconnect
  Future<void> enableBluetoothAndReconnect() async {
    try {
      print(
          'ChargeCarController: Starting Bluetooth enable and reconnect process');

      // Kiểm tra và bật Bluetooth
      bool isEnabled = await FlutterBluePlus.isOn;
      if (!isEnabled) {
        print('ChargeCarController: Bluetooth is off, requesting to turn on');
        await FlutterBluePlus.turnOn();
        await Future.delayed(Duration(seconds: 2)); // Đợi Bluetooth khởi động
      }

      // Thử reconnect bằng cách scan lại thiết bị
      print(
          'ChargeCarController: Attempting to reconnect to device: $nameDevice');
      await connectDevice();
    } catch (e) {
      print(
          'ChargeCarController: Error during Bluetooth enable and reconnect: $e');
    }
  }

  @override
  void onClose() async {
    print("🔚 Controller closing - performing cleanup");

    // Tắt smart reconnect khi controller bị dispose
    _disableConnectionMaintenance();

    // Cancel all subscriptions
    _connectionStateSubscription?.cancel();
    stateConnectedSubscription?.cancel();

    // Clear GATT cache và disconnect nếu còn connected
    if (_currentDevice != null) {
      try {
        if (Platform.isAndroid) {
          await _currentDevice!.clearGattCache();
          print("🧹 GATT cache cleared in onClose");
        }
        await _currentDevice!.disconnect();
        print("✅ Device disconnected in onClose");
      } catch (e) {
        print("⚠️ Error during cleanup in onClose: $e");
      }
    }

    super.onClose();
  }
}
