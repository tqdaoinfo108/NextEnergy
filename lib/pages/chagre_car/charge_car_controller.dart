import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get/get.dart';
import 'package:crypto/crypto.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../model/ble_response_model.dart';
import '../../model/booking_model.dart';
import '../../model/payment_model.dart';
import '../../model/price_model.dart';
import '../../model/response_base.dart';
import '../../services/base_hive.dart';
import '../../services/getxController.dart';
import '../../services/https.dart';
import '../../services/localization_service.dart';
import '../../utils/const.dart';
import '../customs/count_down.dart';

class ChargeCarBind extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChargeCarController>(() => ChargeCarController());
  }
}

enum ChargeCarPageEnum {
  CONNECTING,
  CHOOSE_TIME,
  WAIT_PLUGING,
  CHARGING,
}

class ChargeCarController extends GetxControllerCustom with WidgetsBindingObserver {
  // Flutter Reactive BLE instance
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  
  // Subscriptions
  StreamSubscription<BleStatus>? _bleStatusSubscription;
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;
  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  
  // Device info
  String nameDevice = "";
  String originalQRCode = "";
  String? _deviceId;
  QualifiedCharacteristic? _targetCharacteristic;
  
  // State management
  final Rx<BleStatus> _bleStatus = Rx<BleStatus>(BleStatus.unknown);
  bool get isBluetoothOn => _bleStatus.value == BleStatus.ready;
  bool get isOnBluetooth => _bleStatus.value == BleStatus.ready; // Alias for compatibility
  Rx<BleStatus> get bleStatus => _bleStatus; // Expose for debug
  
  final Rx<DeviceConnectionState> _connectionState = 
      Rx<DeviceConnectionState>(DeviceConnectionState.disconnected);
  bool get isConnected => _connectionState.value == DeviceConnectionState.connected;
  Rx<DeviceConnectionState> get connectionState => _connectionState; // Expose for debug
  
  RxBool isAuthorized = RxBool(false);
  bool get isAvailable => isBluetoothOn && isConnected && isAuthorized.value;
  
  // Debug mode
  RxBool isDebugMode = RxBool(false); // Set to true to enable debug overlay
  RxList<DiscoveredDevice> nearbyDevices = RxList<DiscoveredDevice>([]);
  Rx<String> lastDebugAction = Rx<String>('Initializing...');
  String? get deviceId => _deviceId; // Expose for debug
  RxList<String> bleOperationLogs = RxList<String>([]); // BLE operation history
  static const int maxBleLogEntries = 50; // Limit log size
  
  // Page state
  Rx<ChargeCarPageEnum> pageEnum = Rx(ChargeCarPageEnum.CONNECTING);
  bool get canPop => [
        ChargeCarPageEnum.CHOOSE_TIME,
        ChargeCarPageEnum.CONNECTING,
      ].contains(pageEnum.value);
  
  // Pricing
  bool isVip = false;
  RxList<PriceModel> listPrice = RxList.empty();
  Rx<PriceModel> currentPrice = PriceModel().obs;
  
  // Booking data
  BookingModel? bookingData;
  PaymentModel? paymentData;
  BleResponseModel bleResponseModel = BleResponseModel();
  
  // Timer and progress
  RxInt percentProcessbar = 1.obs;
  Timer? processbarTimer;
  RxString getTimeStillText = "".obs;
  RxString getTimeTotalsText = "".obs;
  CountdownController countdownController = CountdownController(autoStart: true);
  
  // Connection management
  bool _shouldMaintainConnection = false;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 3;
  static const int _reconnectDelay = 3; // seconds
  
  // UUIDs for multi-port stations
  static const String CHARACTERISTIC_1_UUID = "e6eae575-4d89-4750-bf3e-c82d6a1cd299";
  // static const String CHARACTERISTIC_1_UUID = "0000beef-0000-1000-8000-00805f9b34fb";
  static const String CHARACTERISTIC_2_UUID = "f6eae575-4d89-4750-bf3e-c82d6a1cd29a";
  
  final int expiredTimeValue = HiveHelper.get(Constants.EXPIRED_ON_HARDWARE, defaultvalue: 90);
  bool isauthorizeDevice = false;

  @override
  void onInit() {
    super.onInit();
    isLoading.value = false;
    bookingData = null;
    
    // Register lifecycle observer
    WidgetsBinding.instance.addObserver(this);
    
    _updateDebugAction('Starting initialization');
    
    // Wait a bit for BLE to initialize, then setup everything
    Future.delayed(const Duration(milliseconds: 500), () async {
      // IMPORTANT: Set up BLE status stream FIRST before checking status
      // This ensures stream is active on every page entry (including re-entry after back navigation)
      print("📡 Setting up BLE status stream...");
      _bleStatusSubscription?.cancel(); // Cancel any existing subscription first
      _bleStatusSubscription = _ble.statusStream.listen(
        (status) {
          _bleStatus.value = status;
          print("📡 BLE Status: $status");
          _updateDebugAction('BLE Status: $status');
          
          // Handle BLE turned off during charging
          if (status != BleStatus.ready && pageEnum.value == ChargeCarPageEnum.CHARGING) {
            print("⚠️ Bluetooth turned off during charging");
            _updateDebugAction('⚠️ BLE turned off during charging');
          }
        },
        onError: (error) {
          print("❌ BLE Status stream error: $error");
          _updateDebugAction('❌ BLE Status error: $error');
        },
      );
      
      // Give the status stream a moment to emit first value
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Request permissions then initialize
      final hasPermissions = await _requestPermissions();
      if (!hasPermissions) {
        print("❌ Permissions denied, closing page");
        EasyLoading.showError("Không có quyền truy cập Bluetooth");
        Future.delayed(const Duration(seconds: 2), () => back());
        return;
      }
      
      // Wait for BLE to be ready (max 5 seconds)
      await _waitForBluetoothReady();
      
      // Handle arguments
      if (Get.arguments is String) {
        originalQRCode = Get.arguments;
        nameDevice = originalQRCode.replaceAll('_1', '').replaceAll('_2', '');
        
        _initializeNewSession();
      } else {
        bookingData = Get.arguments as BookingModel?;
        originalQRCode = bookingData?.hardwareName ?? "";
        nameDevice = originalQRCode.replaceAll('_1', '').replaceAll('_2', '');
        pageEnum.value = ChargeCarPageEnum.CHARGING;
        
        _initializeExistingSession();
      }
    });
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        print("📱 App resumed");
        // Try to reconnect if needed
        if (!isConnected && _deviceId != null && _shouldMaintainConnection) {
          print("🔄 Auto-reconnect on app resume");
          _connectToDeviceById(_deviceId!);
        }
        break;
      case AppLifecycleState.paused:
        print("📱 App paused");
        break;
      default:
        break;
    }
  }
  
  // Request necessary permissions
  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();
      
      // Check if all permissions granted
      bool allGranted = statuses.values.every((status) => status.isGranted);
      
      if (!allGranted) {
        print("⚠️ Not all permissions granted");
        _updateDebugAction('⚠️ Permissions denied');
        final deniedPermanently = statuses.values.any((status) => status.isPermanentlyDenied);
        
        if (deniedPermanently) {
          EasyLoading.showError(
            "Vui lòng cấp quyền Bluetooth và Location trong Settings",
            duration: const Duration(seconds: 3),
          );
        } else {
          EasyLoading.showError(
            "Cần cấp quyền Bluetooth và Location để sử dụng",
            duration: const Duration(seconds: 3),
          );
        }
        return false;
      } else {
        print("✅ All permissions granted");
        _updateDebugAction('✅ Permissions granted');
        return true;
      }
    } else if (Platform.isIOS) {
      // iOS handles permissions automatically
      print("📱 iOS - Permissions handled by system");
      _updateDebugAction('📱 iOS - Permissions OK');
      return true;
    }
    return true;
  }
  
  // Wait for Bluetooth to be ready
  Future<void> _waitForBluetoothReady({int maxWaitSeconds = 5}) async {
    print("⏳ Waiting for Bluetooth to be ready... Current status: ${_bleStatus.value}");
    _updateDebugAction('⏳ Waiting for BLE ready...');
    _addBleLog("INFO", "Checking BLE status: ${_bleStatus.value}");
    
    final startTime = DateTime.now();
    int checkCount = 0;
    
    while (!isBluetoothOn) {
      checkCount++;
      final elapsed = DateTime.now().difference(startTime).inSeconds;
      
      // Log every second to track progress
      if (checkCount % 5 == 0) {
        print("⏳ Still waiting... ${elapsed}s elapsed, status: ${_bleStatus.value}");
      }
      
      if (elapsed >= maxWaitSeconds) {
        print("⚠️ Bluetooth not ready after ${maxWaitSeconds}s, current status: ${_bleStatus.value}");
        _updateDebugAction('⚠️ BLE timeout: ${_bleStatus.value}');
        _addBleLog("ERROR", "BLE timeout after ${maxWaitSeconds}s: ${_bleStatus.value}");
        
        // Show helpful error message based on status
        switch (_bleStatus.value) {
          case BleStatus.poweredOff:
            EasyLoading.showError(
              "Vui lòng bật Bluetooth",
              duration: const Duration(seconds: 3),
            );
            break;
          case BleStatus.unauthorized:
            EasyLoading.showError(
              "Vui lòng cấp quyền Bluetooth trong Settings",
              duration: const Duration(seconds: 3),
            );
            break;
          case BleStatus.locationServicesDisabled:
            EasyLoading.showError(
              "Vui lòng bật Location Services (Android yêu cầu)",
              duration: const Duration(seconds: 3),
            );
            break;
          case BleStatus.unsupported:
            EasyLoading.showError(
              "Thiết bị không hỗ trợ Bluetooth Low Energy",
              duration: const Duration(seconds: 3),
            );
            break;
          default:
            EasyLoading.showError(
              "Bluetooth chưa sẵn sàng. Vui lòng thử lại",
              duration: const Duration(seconds: 3),
            );
        }
        
        Future.delayed(const Duration(seconds: 2), () => back());
        return;
      }
      
      await Future.delayed(const Duration(milliseconds: 200));
    }
    
    print("✅ Bluetooth is ready!");
    _updateDebugAction('✅ BLE ready');
  }
  
  // Initialize new charging session
  Future<void> _initializeNewSession() async {
    await _connectToDevice();
    // Connection is async - callbacks will handle success/failure
    // Don't check isAvailable here as connection hasn't completed yet
  }
  
  // Initialize existing charging session
  Future<void> _initializeExistingSession() async {
    _startChargingTimer();
    _connectToDevice(isBackWhenDontConnect: false);
    getListPrice();
  }
  
  // Connect to BLE device
  Future<void> _connectToDevice({
    bool isBackWhenDontConnect = true,
    int timeoutSeconds = 10,
  }) async {
    // Check BLE status first
    if (!isBluetoothOn) {
      print("❌ Bluetooth is not ready, status: ${_bleStatus.value}");
      _updateDebugAction('❌ BLE not ready: ${_bleStatus.value}');
      
      if (isBackWhenDontConnect) {
        // Show specific error message
        switch (_bleStatus.value) {
          case BleStatus.poweredOff:
            EasyLoading.showError("Vui lòng bật Bluetooth");
            break;
          case BleStatus.unauthorized:
            EasyLoading.showError("Vui lòng cấp quyền Bluetooth");
            break;
          case BleStatus.locationServicesDisabled:
            EasyLoading.showError("Vui lòng bật Location Services");
            break;
          case BleStatus.unsupported:
            EasyLoading.showError("Thiết bị không hỗ trợ BLE");
            break;
          default:
            EasyLoading.showError("Bluetooth chưa sẵn sàng");
        }
        back();
      }
      return;
    }
    
    // Cancel any existing scan
    await _scanSubscription?.cancel();
    
    // Clear nearby devices list
    nearbyDevices.clear();
    
    print("🔍 Scanning for device: $nameDevice");
    _updateDebugAction('🔍 Scanning for: $nameDevice');
    
    // Track if we found the device
    bool deviceFound = false;
    
    // Start scanning with timeout
    // Note: Scan all devices since ESP32 only advertises device name, not specific service UUIDs
    _scanSubscription = _ble
        .scanForDevices(
          withServices: [], // Empty = scan all devices (ESP32 advertises name only)
          scanMode: ScanMode.lowLatency, // Fast scanning
          requireLocationServicesEnabled: Platform.isAndroid,
        )
        .timeout(
          Duration(seconds: timeoutSeconds),
          onTimeout: (sink) {
            print("⏱️ Scan timeout");
            _updateDebugAction('⏱️ Scan timeout');
            sink.close();
          },
        )
        .listen(
          (device) {
            // Add to nearby devices list (avoid duplicates)
            if (!nearbyDevices.any((d) => d.id == device.id)) {
              nearbyDevices.add(device);
              print("📍 Found device: ${device.name} (${device.id}) RSSI: ${device.rssi}");
            }
            
            // Filter by exact device name match (case-sensitive)
            if (device.name == nameDevice && !deviceFound) {
              deviceFound = true;
              print("✅ Target device found! ID: ${device.id}, RSSI: ${device.rssi}");
              _updateDebugAction('✅ Target found: ${device.id}');
              _scanSubscription?.cancel();
              _deviceId = device.id;
              _connectToDeviceById(device.id);
            }
          },
          onError: (error) {
            print("❌ Scan error: $error");
            _updateDebugAction('❌ Scan error: $error');
            if (isBackWhenDontConnect) {
              EasyLoading.showError(TKeys.fail_again2.translate());
              back();
            }
          },
          onDone: () {
            print("🔍 Scan completed - Found ${nearbyDevices.length} devices");
            _updateDebugAction('🔍 Scan completed (${nearbyDevices.length} devices)');
            
            // If device not found after timeout
            if (_deviceId == null && isBackWhenDontConnect) {
              EasyLoading.showError("Không tìm thấy thiết bị: $nameDevice");
              
              // Debug: Show similar device names if any
              final similarDevices = nearbyDevices
                  .where((d) => d.name.isNotEmpty && d.name.toLowerCase().contains('ne'))
                  .toList();
              if (similarDevices.isNotEmpty) {
                print("💡 Similar devices found:");
                for (var dev in similarDevices) {
                  print("   - ${dev.name} (${dev.id})");
                }
              }
              
              back();
            }
          },
        );
  }
  
  // Connect to device by ID
  Future<void> _connectToDeviceById(String deviceId) async {
    print("🔗 Connecting to device: $deviceId");
    _updateDebugAction('🔗 Preparing connection: $deviceId');
    
    // IMPORTANT: Clear GATT cache BEFORE connecting to ensure fresh start
    print("🧹 Clearing GATT cache before connection...");
    try {
      await _ble.clearGattCache(deviceId);
      print("✅ GATT cache cleared before connection");
      _addBleLog('INFO', 'Pre-connection GATT clear: $deviceId');
    } catch (e) {
      print("⚠️ GATT cache clear error (may not be supported): $e");
      // Continue with connection even if clear fails
    }
    
    // Wait 500ms after clearing cache before connecting
    // This gives the BLE stack time to fully release cached data
    await Future.delayed(const Duration(milliseconds: 500));
    print("✅ Ready to connect after cache clear");
    _updateDebugAction('🔗 Connecting to: $deviceId');
    
    // Cancel existing connection if any
    await _connectionSubscription?.cancel();
    
    _connectionSubscription = _ble
        .connectToDevice(
          id: deviceId,
          connectionTimeout: const Duration(seconds: 10),
        )
        .listen(
          (connectionState) {
            final previousState = _connectionState.value;
            _connectionState.value = connectionState.connectionState;
            
            print("📡 Connection state: ${connectionState.connectionState}");
            
            // Only process if state actually changed
            if (previousState != connectionState.connectionState) {
              switch (connectionState.connectionState) {
                case DeviceConnectionState.connected:
                  _updateDebugAction('✅ Connected');
                  _reconnectAttempts = 0; // Reset on successful connection
                  _onDeviceConnected(deviceId);
                  break;
                case DeviceConnectionState.disconnected:
                  _updateDebugAction('❌ Disconnected');
                  _onDeviceDisconnected();
                  break;
                case DeviceConnectionState.connecting:
                  _updateDebugAction('🔄 Connecting...');
                  print("🔄 Connecting...");
                  break;
                case DeviceConnectionState.disconnecting:
                  _updateDebugAction('🔄 Disconnecting...');
                  print("🔄 Disconnecting...");
                  break;
              }
            }
          },
          onError: (error) {
            print("❌ Connection error: $error");
            _connectionState.value = DeviceConnectionState.disconnected;
            _onDeviceDisconnected();
          },
        );
  }
  
  // Handle device connected
  Future<void> _onDeviceConnected(String deviceId) async {
    print("✅ Device connected: $deviceId");
    _updateDebugAction('✅ Device connected');
    
    try {
      // Discover characteristics
      _updateDebugAction('🔍 Discovering characteristics...');
      await _discoverCharacteristics(deviceId);
      
      // Check if characteristic was found
      if (_targetCharacteristic == null) {
        print("❌ No characteristic found, cannot authorize");
        _updateDebugAction('❌ No characteristic found');
        EasyLoading.showError("Không tìm thấy characteristic phù hợp");
        back();
        return;
      }
      
      // Authorize device immediately after finding characteristic
      _updateDebugAction('🔐 Starting authorization...');
      await _authorizeDevice();
      
    } catch (e) {
      print("❌ Error in device connection flow: $e");
      _updateDebugAction('❌ Connection flow error: $e');
      EasyLoading.showError("Lỗi kết nối: ${e.toString()}");
      back();
    }
  }
  
  // Handle device disconnected
  void _onDeviceDisconnected() {
    print("❌ Device disconnected");
    _updateDebugAction('❌ Device disconnected');
    isAuthorized.value = false;
    isauthorizeDevice = false;
    
    // Smart reconnect if charging
    if (_shouldMaintainConnection && pageEnum.value == ChargeCarPageEnum.CHARGING) {
      _handleSmartReconnect();
    }
  }
  
  // Discover and select characteristic
  Future<void> _discoverCharacteristics(String deviceId) async {
    // Reset characteristic before discovery
    _targetCharacteristic = null;
    
    try {
      print("🔍 Discovering characteristics for device: $deviceId");
      
      // Determine target UUID based on QR code suffix
      Uuid targetUuid;
      String portLabel;
      if (originalQRCode.endsWith('_2')) {
        targetUuid = Uuid.parse(CHARACTERISTIC_2_UUID);
        portLabel = "Port 2";
        print("🎯 Looking for UUID_2 ($portLabel): $targetUuid");
      } else {
        // Default to UUID_1 for both '_1' suffix and no suffix
        targetUuid = Uuid.parse(CHARACTERISTIC_1_UUID);
        portLabel = "Port 1";
        print("🎯 Looking for UUID_1 ($portLabel): $targetUuid");
      }
      
      _updateDebugAction('🔍 Discovering $portLabel characteristic...');
      
      // Discover all services
      print("🔍 Starting service discovery...");
      final services = await _ble.discoverServices(deviceId);
      print("✅ Found ${services.length} services");
      
      // Search through all services and characteristics
      // Use optimized search: stop as soon as target is found
      for (var service in services) {
        print("🔍 Service: ${service.serviceId}");
        
        for (var characteristic in service.characteristics) {
          final charId = characteristic.characteristicId;
          print("  📍 Characteristic: $charId");
          
          // Check if this is our target characteristic
          if (charId == targetUuid) {
            _targetCharacteristic = QualifiedCharacteristic(
              serviceId: service.serviceId,
              characteristicId: charId,
              deviceId: deviceId,
            );
            print("✅ Found target characteristic ($portLabel)!");
            print("   Service: ${service.serviceId}");
            print("   Characteristic: $charId");
            _updateDebugAction('✅ Found $portLabel characteristic');
            return; // Found it, exit immediately
          }
        }
      }
      
      // If we reach here, characteristic not found
      print("❌ Target characteristic $targetUuid ($portLabel) not found in any service");
      _updateDebugAction('❌ $portLabel characteristic not found');
      
      // Debug: List all available characteristics
      print("💡 Available characteristics:");
      for (var service in services) {
        for (var char in service.characteristics) {
          print("   - ${char.characteristicId}");
        }
      }
      
    } catch (e) {
      print("❌ Error discovering characteristics: $e");
      _updateDebugAction('❌ Discovery error: $e');
      _targetCharacteristic = null;
      rethrow; // Re-throw to be handled by caller
    }
  }
  
  // Authorize device with ESP32
  Future<void> _authorizeDevice() async {
    if (_targetCharacteristic == null) {
      print("❌ No characteristic available for authorization");
      _updateDebugAction('❌ No characteristic');
      throw Exception("No characteristic found");
    }
    
    print("🔐 Starting authorization process...");
    _updateDebugAction('🔐 Authorizing...');
    
    try {
      // Generate auth value from device name
      if (nameDevice.length < 8) {
        throw Exception("Device name too short: $nameDevice");
      }
      
      final deviceCode = nameDevice.substring(5, 8);
      var authenValue = md5
          .convert(utf8.encode(deviceCode))
          .toString()
          .substring(10, 22);
      
      print("🔐 Generated auth value: $authenValue for device code: $deviceCode");
      print("🔐 Writing auth to characteristic: ${_targetCharacteristic!.characteristicId}");
      
      // Log write operation
      _addBleLog('✍️ WRITE', 'Auth: $authenValue');
      
      // Write auth value with response - THIS HAPPENS IMMEDIATELY AFTER CONNECTION
      await _ble.writeCharacteristicWithResponse(
        _targetCharacteristic!,
        value: utf8.encode(authenValue),
      );
      
      print("✅ Auth value written successfully, waiting for response...");
      _addBleLog('✅ WRITE', 'Auth sent successfully');
      
      // Wait for device to process
      await Future.delayed(const Duration(seconds: 2));
      
      // Read response from device
      print("📖 Reading response from device...");
      _addBleLog('📖 READ', 'Reading auth response...');
      
      final response = await _ble.readCharacteristic(_targetCharacteristic!);
      final rawValue = utf8.decode(response);
      
      print("📡 Received from ESP32: '$rawValue'");
      _addBleLog('📖 READ', 'Response: $rawValue');
      
      if (rawValue.isEmpty) {
        print("❌ Empty response from device");
        EasyLoading.showError("Thiết bị không phản hồi");
        throw Exception("Empty response from device");
      }
      
      // Check if machine is already in use
      if (rawValue.toLowerCase() == authenValue.toLowerCase() && bookingData == null) {
        print("⚠️ Machine already in use");
        EasyLoading.showInfo(
          TKeys.machine_in_use.translate(), 
          duration: const Duration(seconds: 5)
        );
        back();
        return;
      }
      
      // Mark as authorized - AUTHORIZATION SUCCESSFUL
      isAuthorized.value = true;
      print("✅ Authorization successful!");
      _updateDebugAction('✅ Authorized successfully');
      
      // Parse BLE response if it's JSON
      if (rawValue.contains("{") && rawValue.contains("}")) {
        try {
          bleResponseModel = BleResponseModel.fromJson(jsonDecode(rawValue));
          print("✅ Parsed BLE response: ${bleResponseModel.toJson()}");
        } catch (e) {
          print("⚠️ Failed to parse BLE response: $e");
          bleResponseModel = BleResponseModel();
        }
      } else {
        bleResponseModel = BleResponseModel();
      }
      
      // Check if booking already complete
      if (bookingData != null && bleResponseModel.bookingID != null) {
        if (bleResponseModel.bookingID == bookingData?.bookID) {
          print("✅ Booking already complete");
          await onBookingComplete();
          return;
        }
      }
      
      // Validate hardware status for new sessions
      if (bookingData == null) {
        print("🔍 Validating hardware status...");
        var checkQRCode = await HttpHelper.updateHardware(bleResponseModel.toJson());
        print("🔍 Hardware validation result: $checkQRCode");
        
        switch (checkQRCode) {
          case "DEACTIVE":
            print("❌ Hardware is DEACTIVE");
            EasyLoading.showInfo(
              TKeys.this_charger_is_out_of_order.translate(),
              duration: const Duration(seconds: 5)
            );
            back();
            return;
          case "ERROR":
          case "LIMIT":
            print("❌ Hardware status: $checkQRCode");
            EasyLoading.showInfo(
              TKeys.machine_under_maintenance.translate(),
              duration: const Duration(seconds: 5)
            );
            back();
            return;
        }
      }
      
      // Get price list
      print("💰 Getting price list...");
      await getListPrice();
      
      // Move to choose time screen for new sessions
      if (bookingData == null) {
        pageEnum.value = ChargeCarPageEnum.CHOOSE_TIME;
        print("✅ Ready to choose charging time");
      }
      
      // Send bookingID confirmation for existing sessions
      if (bookingData?.bookID != null) {
        print("📤 Sending bookingID confirmation...");
        _addBleLog('✍️ WRITE', 'BookingID: ${bookingData!.bookID}');
        
        await _ble.writeCharacteristicWithResponse(
          _targetCharacteristic!,
          value: utf8.encode("${bookingData!.bookID}"),
        );
        print("✅ Sent bookingID: ${bookingData?.bookID}");
        _addBleLog('✅ WRITE', 'BookingID sent successfully');
      }
      
      print("✅ Authorization flow completed successfully");
      
    } catch (e) {
      print("❌ Authorization error: $e");
      EasyLoading.showError("Không thể xác thực thiết bị: ${e.toString()}");
      isAuthorized.value = false;
      rethrow; // Re-throw to be handled by _onDeviceConnected
    }
  }
  
  // Get price list
  Future<void> getListPrice() async {
    var listPriceTemp = await HttpHelper.getPrice(
      bleResponseModel.myId ?? bookingData!.hardwareID!,
      HiveHelper.get(Constants.USER_ID),
    );
    listPrice.value = (listPriceTemp.data ?? []);
    isVip = listPriceTemp.isVIP ?? false;
    if (listPrice.isNotEmpty) {
      currentPrice.value = listPrice[0];
    }
  }
  
  // Change price selection
  void onChangePrice(PriceModel model) {
    currentPrice.value = model;
    listPrice.refresh();
  }
  
  // Create booking and payment
  Future<PaymentModel?> onBookingPayment() async {
    try {
      var autoPayment = await HttpHelper.autoPayment(
        bleResponseModel.myId!,
        currentPrice.value.priceID!,
        bookingData?.bookID,
      );
      if (autoPayment != null && autoPayment.data != null) {
        paymentData = autoPayment.data;
        bookingData = autoPayment.data!.booking;
        return autoPayment.data;
      }
    } catch (e) {
      print("❌ Payment error: $e");
    }
    return null;
  }
  
  // Set payment data
  void setPaymentData(ResponseBase<PaymentModel> data) {
    paymentData = data.data;
    bookingData = data.data!.booking;
  }
  
  // Open hardware and start charging
  Future<bool> openHardware() async {
    if (_targetCharacteristic == null) {
      EasyLoading.showInfo(TKeys.fail_again2.translate());
      return false;
    }
    
    bool isResult = false;
    pageEnum.value = ChargeCarPageEnum.WAIT_PLUGING;
    
    try {
      String onCommand =
          "ON:${getTimeOpenHardware()}:${DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000}:${bookingData!.bookID}";
      
      print("🔥 Opening hardware with command: $onCommand");
      _addBleLog('✍️ WRITE', 'ON command: $onCommand');
      
      await _ble.writeCharacteristicWithResponse(
        _targetCharacteristic!,
        value: utf8.encode(onCommand),
      );
      
      _addBleLog('✅ WRITE', 'ON command sent');
      
      for (int i = 1; i <= expiredTimeValue; i++) {
        if (i == expiredTimeValue) {
          EasyLoading.showError(TKeys.on_back_300s_message.translate(),
              duration: const Duration(seconds: 5));
          back();
          break;
        }
        
        try {
          _addBleLog('📖 READ', 'Polling hardware status...');
          
          final response = await _ble.readCharacteristic(_targetCharacteristic!);
          final rawValue = utf8.decode(response);
          
          print("🔥 BLE returned: $rawValue");
          _addBleLog('📖 READ', 'Status: $rawValue');
          
          if ("true" == rawValue.toLowerCase()) {
            var isUpdateComplete = await onUpdateAffterHardware(1);
            
            if (isUpdateComplete != null && isUpdateComplete.data != null) {
              _addBleLog('✍️ WRITE', 'PAID confirmation');
              
              await _ble.writeCharacteristicWithResponse(
                _targetCharacteristic!,
                value: utf8.encode("PAID"),
              );
              
              _addBleLog('✅ WRITE', 'PAID sent successfully');
              
              // Enable smart reconnect
              _enableConnectionMaintenance();
              
              _startChargingTimer();
              pageEnum.value = ChargeCarPageEnum.CHARGING;
              print("🔥 Successfully started charging");
              isResult = true;
              break;
            }
          }
        } catch (e) {
          print("❌ Read error: $e");
        }
        
        if (i < expiredTimeValue) {
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    } catch (e) {
      print("❌ Hardware error: $e");
      return false;
    }
    
    return isResult;
  }
  
  // Complete booking with full cleanup
  Future<void> onBookingComplete() async {
    print("🏁 Completing booking and cleaning up...");
    
    try {
      _disableConnectionMaintenance();
      
      if (!isAvailable || _targetCharacteristic == null) {
        EasyLoading.showInfo(TKeys.fail_again2.translate());
        // Still cleanup even if command fails
        await back();
        return;
      }
      
      _addBleLog('✍️ WRITE', 'OFF command');
      
      await _ble.writeCharacteristicWithResponse(
        _targetCharacteristic!,
        value: utf8.encode("OFF"),
      );
      
      _addBleLog('✅ WRITE', 'OFF sent successfully');
      
      // Wait for hardware to process OFF command
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Update server
      var onCompleteBooking = await HttpHelper.updateBookingComplete(bookingData?.bookID ?? 0);
      if (onCompleteBooking != null && onCompleteBooking.data != null) {
        EasyLoading.showSuccess(
          TKeys.complete_charging_end_processing.translate(),
          duration: const Duration(seconds: 5),
        );
        
        // Full cleanup before going back
        await back();
      } else {
        // Still cleanup even if server update fails
        await back();
      }
    } catch (e) {
      print("❌ Complete booking error: $e");
      // Always cleanup on error
      await back();
    }
  }
  
  // Update payment after hardware operation
  Future<ResponseBase<PaymentModel>?> onUpdateAffterHardware(
    int statusID, {
    bool isExtTime = false,
    int? paymentID,
  }) async {
    if (paymentData == null) {
      print("❌ PaymentData is null");
      return null;
    }
    
    paymentID ??= paymentData!.paymentID!;
    
    try {
      var data = await HttpHelper.updatePaymentAfterWaitHardware(
        paymentID,
        statusID,
        isExtTime: isExtTime,
      );
      
      if (data != null && data.data != null) {
        bookingData = data.data!.booking;
        return data;
      }
    } catch (e) {
      print("❌ Update payment error: $e");
    }
    return null;
  }
  
  // Start charging timer
  void _startChargingTimer() {
    processbarTimer?.cancel();
    
    bool isContinueCompleteBooking = true;
    processbarTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (bookingData != null) {
        var value = (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000) - bookingData!.dateStart!;
        percentProcessbar.value = value;
        
        getTimeStillText.value = _printDuration(
          Duration(seconds: percentProcessbar.value),
          isShowSecond: false,
        );
        
        getTimeTotalsText.value = bookingData != null
            ? _printDuration(
                Duration(seconds: (bookingData!.dateEnd! - bookingData!.dateStart!).toInt()),
                isShowSecond: false,
              )
            : "";
        
        // Auto disconnect near end
        if (bookingData!.getDurationTimeEnd - percentProcessbar.value < 20) {
          await _disconnect();
        }
        
        // Complete charging with full cleanup
        if (percentProcessbar.value >= bookingData!.getDurationTimeEnd &&
            pageEnum.value == ChargeCarPageEnum.CHARGING &&
            isContinueCompleteBooking) {
          isContinueCompleteBooking = false;
          _disableConnectionMaintenance();
          
          print("⏰ Auto-complete charging - time expired");
          
          EasyLoading.showSuccess(
            TKeys.complete_charging_end_processing_auto.translate(),
            duration: const Duration(seconds: 5),
          );
          
          // Update server
          await HttpHelper.updateBookingComplete(bookingData?.bookID ?? 0);
          
          // Cancel timer
          processbarTimer?.cancel();
          processbarTimer = null;
          
          // Full cleanup before going back
          await back();
        }
      }
    });
  }
  
  // Smart reconnect handling
  void _handleSmartReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      print("🔄 Max reconnect attempts reached");
      _shouldMaintainConnection = false;
      EasyLoading.showInfo("Mất kết nối với thiết bị");
      return;
    }
    
    _reconnectAttempts++;
    print("🔄 Smart reconnect attempt $_reconnectAttempts/$_maxReconnectAttempts");
    
    // Cancel previous timer if exists
    _stopReconnectTimer();
    
    // Exponential backoff: wait longer with each attempt
    final delaySeconds = _reconnectDelay * _reconnectAttempts;
    
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () async {
      if (_shouldMaintainConnection && !isConnected && _deviceId != null) {
        print("🔄 Attempting smart reconnect after ${delaySeconds}s...");
        try {
          await _connectToDeviceById(_deviceId!);
        } catch (e) {
          print("❌ Smart reconnect failed: $e");
          _handleSmartReconnect(); // Try again
        }
      }
    });
  }
  
  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;
  }
  
  void _enableConnectionMaintenance() {
    _shouldMaintainConnection = true;
    _reconnectAttempts = 0;
    print("🔗 Connection maintenance enabled");
  }
  
  void _disableConnectionMaintenance() {
    _shouldMaintainConnection = false;
    _stopReconnectTimer();
    print("🔗 Connection maintenance disabled");
  }
  
  // Disconnect device completely with GATT cache clear
  Future<void> _disconnect() async {
    print("🔌 Starting full disconnect and GATT cache clear...");
    
    try {
      // Clear GATT cache if device ID is available (Android only, iOS ignores)
      if (_deviceId != null) {
        print("🧹 Clearing GATT cache for device: $_deviceId");
        try {
          await _ble.clearGattCache(_deviceId!);
          print("✅ GATT cache cleared successfully");
          _addBleLog('INFO', 'GATT cache cleared for: $_deviceId');
        } catch (e) {
          print("⚠️ GATT cache clear error (may not be supported): $e");
          // Continue with cleanup even if clear fails
        }
      }
      
      // Cancel connection subscription
      await _connectionSubscription?.cancel();
      _connectionSubscription = null;
      
      // Reset connection state
      _connectionState.value = DeviceConnectionState.disconnected;
      
      // Clear device ID to force fresh discovery on next connect
      _deviceId = null;
      
      // Clear characteristic to force rediscovery
      _targetCharacteristic = null;
      
      // Reset authorization state
      isAuthorized.value = false;
      isauthorizeDevice = false;
      
      // Clear nearby devices list
      nearbyDevices.clear();
      
      // Add delay to allow BLE stack to fully release resources
      await Future.delayed(const Duration(milliseconds: 300));
      
      print("✅ Full disconnect completed - GATT cache cleared");
      _updateDebugAction('✅ Disconnected & GATT cleared');
      
    } catch (e) {
      print("⚠️ Error during disconnect: $e");
      _addBleLog('ERROR', 'Disconnect error: $e');
    }
  }
  
  // Back navigation with full cleanup
  Future<void> back() async {
    print("🔙 Back navigation - starting full cleanup...");
    
    try {
      // Disable reconnection attempts
      _disableConnectionMaintenance();
      
      // Clear booking data
      bookingData = null;
      paymentData = null;
      isauthorizeDevice = false;
      isAuthorized.value = false;
      
      // Cancel scan subscription
      await _scanSubscription?.cancel();
      _scanSubscription = null;
      
      // Full disconnect (clears GATT-like state)
      await _disconnect();
      
      // Cancel BLE status stream
      _bleStatusSubscription?.cancel();
      _bleStatusSubscription = null;
      
      // Cancel all timers
      processbarTimer?.cancel();
      processbarTimer = null;
      
      // Clear BLE response model
      bleResponseModel = BleResponseModel();
      
      // Clear price data
      listPrice.clear();
      
      // Additional delay to ensure complete BLE stack cleanup
      // Critical for avoiding GATT cache issues on next page entry
      await Future.delayed(const Duration(milliseconds: 300));
      
      print("✅ Back navigation cleanup completed");
      _addBleLog('INFO', 'Page exit - full cleanup completed');
      
    } catch (e) {
      print("⚠️ Error during back cleanup: $e");
    } finally {
      pageEnum.value = ChargeCarPageEnum.CONNECTING;
      Get.back();
    }
  }
  
  // Helper methods
  String getTimeOpenHardware({double? time}) {
    time ??= currentPrice.value.priceTime!;
    int intTime = (time * 60).toInt();
    
    if (intTime <= 999 && intTime > 99) {
      return intTime.toString();
    } else if (intTime > 9 && intTime <= 99) {
      return "0$intTime";
    } else if (intTime > 0) {
      return "00$intTime";
    }
    return "000";
  }
  
  String _printDuration(Duration duration, {bool isShowSecond = true}) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (isShowSecond) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes";
    }
  }
  
  String get getTimeStill {
    if (bookingData == null) return "--:--";
    var time = (bookingData!.dateEnd! - bookingData!.dateStart!) -
        ((DateTime.now().millisecondsSinceEpoch ~/ 1000) - bookingData!.dateStart!);
    var duration = Duration(seconds: time + 60);
    return _printDuration(duration, isShowSecond: false);
  }
  
  // Update debug action
  void _updateDebugAction(String action) {
    lastDebugAction.value = action;
    print("🔧 Debug: $action");
  }
  
  // Add BLE operation log
  void _addBleLog(String operation, String data) {
    final timestamp = DateTime.now().toString().substring(11, 19); // HH:MM:SS
    final logEntry = '[$timestamp] $operation: $data';
    
    bleOperationLogs.add(logEntry);
    
    // Limit log size
    if (bleOperationLogs.length > maxBleLogEntries) {
      bleOperationLogs.removeAt(0); // Remove oldest
    }
    
    print("📝 BLE Log: $logEntry");
  }
  
  // Toggle debug mode
  void toggleDebugMode() {
    isDebugMode.value = !isDebugMode.value;
    _updateDebugAction('Debug mode: ${isDebugMode.value ? "ON" : "OFF"}');
  }
  
  // Handle page reappear - auto reconnect when page comes back
  Future<void> handlePageReappear() async {
    if (!isConnected && _deviceId != null) {
      print("🔄 Page reappeared, attempting reconnect...");
      _connectToDeviceById(_deviceId!);
    }
  }
  
  // Manual connect device
  Future<void> connectDevice() async {
    if (nameDevice.isEmpty) {
      EasyLoading.showError("Device name is empty");
      return;
    }
    
    print("🔄 Manual connect requested");
    await _connectToDevice(isBackWhenDontConnect: false);
  }
  
  // Enable Bluetooth and reconnect
  Future<void> enableBluetoothAndReconnect() async {
    // Note: flutter_reactive_ble doesn't support programmatic BT enable
    // User must enable BT manually from system settings
    if (!isBluetoothOn) {
      EasyLoading.showInfo(
        "Vui lòng bật Bluetooth trong cài đặt",
        duration: const Duration(seconds: 3),
      );
      
      // Give user time to enable BT, then check again
      await Future.delayed(const Duration(seconds: 3));
    }
    
    if (isBluetoothOn) {
      await connectDevice();
    }
  }
  
  // Get payment key for extension
  Future<PaymentModel?> getPaymentKeyExtTimeBooking(int priceID) async {
    try {
      var response = await HttpHelper.extHoursBooking(
        bleResponseModel.myId ?? bookingData!.hardwareID!,
        priceID,
        bookingData?.bookID ?? 0,
      );
      
      if (response != null && response.data != null) {
        return response.data;
      }
    } catch (e) {
      print("❌ Get payment key error: $e");
    }
    return null;
  }
  
  // Extend charging time on hardware
  Future<bool> extTimeHardware(double extTime) async {
    if (_targetCharacteristic == null || bookingData == null) {
      EasyLoading.showError("Không thể extend thời gian");
      return false;
    }
    
    try {
      String extCommand = "EXT:${getTimeOpenHardware(time: extTime)}:${bookingData!.bookID}";
      
      print("⏱️ Extending time: $extCommand");
      _addBleLog('✍️ WRITE', 'EXT command: $extCommand');
      
      await _ble.writeCharacteristicWithResponse(
        _targetCharacteristic!,
        value: utf8.encode(extCommand),
      );
      
      _addBleLog('✅ WRITE', 'EXT command sent');
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      _addBleLog('📖 READ', 'Reading extension response...');
      
      final response = await _ble.readCharacteristic(_targetCharacteristic!);
      final rawValue = utf8.decode(response);
      
      print("📡 Extension response: $rawValue");
      _addBleLog('📖 READ', 'Extension result: $rawValue');
      
      if (rawValue.toLowerCase() == "true") {
        EasyLoading.showSuccess("Gia hạn thành công!");
        return true;
      } else {
        EasyLoading.showError("Gia hạn thất bại");
        return false;
      }
    } catch (e) {
      print("❌ Extend time error: $e");
      EasyLoading.showError("Lỗi gia hạn: $e");
      return false;
    }
  }
  
  // Initialize extension booking
  Future<void> onInitExtBooking() async {
    // Refresh booking data from server
    try {
      var response = await HttpHelper.checkBookingAvailiable();
      
      if (response != null && response.data != null) {
        // Cập nhật booking data mới
        var newBooking = response.data;
        
        // Chỉ update nếu bookingID trùng
        if (newBooking?.bookID == bookingData?.bookID) {
          bookingData = newBooking;
          
          // Update timer with new end time
          getTimeStillText.value = getTimeStill;
          
          if (bookingData != null) {
            getTimeTotalsText.value = _printDuration(
              Duration(seconds: (bookingData!.dateEnd! - bookingData!.dateStart!).toInt()),
              isShowSecond: false,
            );
          }
          
          print("✅ Extension booking initialized");
        }
      }
    } catch (e) {
      print("❌ Init extension error: $e");
    }
  }
  
  @override
  void onClose() {
    print("🧹 onClose() - Starting final cleanup with GATT cache clear...");
    
    // Clear GATT cache before disposing (if device ID available)
    if (_deviceId != null) {
      print("🧹 Clearing GATT cache in onClose for: $_deviceId");
      try {
        _ble.clearGattCache(_deviceId!);
        print("✅ GATT cache cleared in onClose");
      } catch (e) {
        print("⚠️ GATT cache clear error in onClose: $e");
      }
    }
    
    // Unregister lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    
    // Disable connection maintenance
    _disableConnectionMaintenance();
    
    // Cancel all timers
    processbarTimer?.cancel();
    processbarTimer = null;
    
    // Cancel all BLE subscriptions (critical for GATT cleanup)
    _scanSubscription?.cancel();
    _scanSubscription = null;
    
    _bleStatusSubscription?.cancel();
    _bleStatusSubscription = null;
    
    _connectionSubscription?.cancel();
    _connectionSubscription = null;
    
    // Clear all BLE-related state completely
    _deviceId = null;
    _targetCharacteristic = null;
    isAuthorized.value = false;
    isauthorizeDevice = false;
    _connectionState.value = DeviceConnectionState.disconnected;
    
    // Clear data models
    bookingData = null;
    paymentData = null;
    bleResponseModel = BleResponseModel();
    
    // Clear collections
    nearbyDevices.clear();
    listPrice.clear();
    bleOperationLogs.clear();
    
    // Reset debug state
    lastDebugAction.value = 'Controller disposed';
    
    print("✅ ChargeCarController fully cleaned up - GATT cache cleared");
    
    super.onClose();
  }
}
