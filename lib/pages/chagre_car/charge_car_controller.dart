import 'dart:async';
import 'dart:convert';
import 'dart:io';

// import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_credit_card/extension.dart';
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
  late StreamSubscription<BluetoothConnectionState> stateConnectedSubscription;

  bool isVip = false;
  RxList<PriceModel> listPrice = RxList.empty();

  Rx<PriceModel> currentPrice = PriceModel().obs;

  // Name Device
  String nameDevice = "";
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

  // Thiết bị phần cứng
  Rx<ChargeCarPageEnum> pageEnum = Rx(ChargeCarPageEnum.CONNECTING);

  bool get canPop => [
        ChargeCarPageEnum.CHOOSE_TIME,
        ChargeCarPageEnum.CONNECTING,
      ].contains(pageEnum.value);
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
      nameDevice = Get.arguments;
      // chờ bật bluetooth rồi connect

      connectDevice().then((value) async {
        if (!isAvailable && Get.currentRoute == "/charge_car") {
          EasyLoading.showError(TKeys.fail_again2.translate());
          back();
        }
      });
    } else {
      bookingData = Get.arguments as BookingModel?;
      nameDevice = bookingData?.hardwareName ?? "";
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
      bookingData = null;
      isauthorizeDevice = false;
      await FlutterBluePlus.stopScan();
      var listDevice = FlutterBluePlus.connectedDevices;
      for (var device in listDevice) {
        await device.disconnect();
      }
      stateBluetoothSubscription.cancel();
      stateConnectedSubscription.cancel();
    } finally {
      pageEnum.value = ChargeCarPageEnum.CONNECTING;
      Get.back();
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
    int count = 1;

    scanBlueoothSubScription = FlutterBluePlus.onScanResults.listen(
      (results) async {
        if (results.isEmpty) return;

        ScanResult result = results.last;
        if (result.device.platformName == nameDevice) {
          await result.device.connect(autoConnect: true, mtu: null);
          if (Platform.isAndroid) {
            result.device.requestMtu(512);
          }
          authorizeDevice(result.device);
          _stateConnectedDevice.value = BluetoothConnectionState.connected;

          stateConnectedSubscription = result.device.connectionState
              .listen((BluetoothConnectionState state) async {
            _stateConnectedDevice.value = state;

            if (state == BluetoothConnectionState.disconnected) {
              isAuthorize.value = false;
              isauthorizeDevice = false;
              return;
            }

            if (!isAuthorize.value && !isauthorizeDevice) {
              isauthorizeDevice = true;
              findBluetoothCharacteristic();
              var listDevice = FlutterBluePlus.connectedDevices;
              if (listDevice.isEmpty) return;
              var device = FlutterBluePlus.connectedDevices.first;
              if (Platform.isAndroid) {
                device.requestMtu(512);
              }
              authorizeDevice(device);
            }
          });
          if (Platform.isAndroid) result.device.requestMtu(512);
        }
      },
    );
    FlutterBluePlus.cancelWhenScanComplete(scanBlueoothSubScription);

    await FlutterBluePlus.startScan(
        withNames: [nameDevice], timeout: Duration(seconds: timeoutSecond));

    // Đợi đến kết thúc > back > show thông báo
    while (count < 11) {
      count++;
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  bool isFindBluetoothCharacteristic = true;
  Future<BluetoothCharacteristic?> findBluetoothCharacteristic(
      {BluetoothDevice? device}) async {
    if (device == null) {
      var listDevice = FlutterBluePlus.connectedDevices;
      if (listDevice.isEmpty) return null;

      device = FlutterBluePlus.connectedDevices.first;
      if (Platform.isAndroid) {
        await device.requestMtu(512);
      }
    }
    if (!isFindBluetoothCharacteristic) return null;
    try {
      var discoverServices = await device.discoverServices();
      for (var service in discoverServices) {
        var characteristics = service.characteristics.where(
            (element) => element.properties.read && element.properties.write);
        for (var item in characteristics) {
          return item;
        }
      }
    } finally {
      isFindBluetoothCharacteristic = true;
    }

    return null;
  }

  // xác thực device
  bool isauthorizeDevice = false;
  authorizeDevice(BluetoothDevice device) async {
    try {
      var cx = await findBluetoothCharacteristic(device: device);
      BluetoothCharacteristic c = cx!;

      var authenValue = md5
          .convert(utf8.encode(nameDevice.substring(5, 8)))
          .toString()
          .substring(10, 22);
      List<int> bytes = utf8.encode(authenValue);

      await c.write(bytes);

      await Future.delayed(const Duration(seconds: 1));
      var listByteString = await c.read();
      var rawValue = utf8.decode(listByteString);

      if (rawValue.isNotNullAndNotEmpty) {
        // nếu gửi mã authen trùng nhận về > back
        if (rawValue.toLowerCase() == authenValue.toLowerCase() &&
            bookingData == null) {
          EasyLoading.showInfo(TKeys.machine_in_use.translate(),
              duration: const Duration(seconds: 5));
          back();
          return;
        }
        isAuthorize.value = true;
        if (rawValue.contains("{") && rawValue.contains("}")) {
          bleResponseModel = BleResponseModel.fromJson(jsonDecode(rawValue));
        } else {
          bleResponseModel = BleResponseModel();
        }

        if (bookingData != null && bleResponseModel.bookingID != null) {
          if (bleResponseModel.bookingID == bookingData?.bookID) {
            await onBookingComplete();
            return;
          }
        }
        // Chỉ chưa booking mới cần
        if (bookingData == null) {
          var checkQRCode =
              await HttpHelper.updateHardware(bleResponseModel.toJson());
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
        await getListPrice();
        if (bookingData == null) {
          pageEnum.value = ChargeCarPageEnum.CHOOSE_TIME;
        }

        // Gửi bookingID để xác nhận
        if (bookingData?.bookID != null) {
          bytes = utf8.encode("${bookingData!.bookID}");
          await c.write(bytes);
          await Future.delayed(const Duration(milliseconds: 500));
          print("1 === Đã gửi bookingID ${bookingData?.bookID}");
        }
      }
    } finally {}
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
      if (Platform.isAndroid) {
        devicesConnected.first.requestMtu(512);
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

        var listByteString = await c.read();
        await Future.delayed(const Duration(seconds: 1));
        var rawValue = utf8.decode(listByteString);
        if ("true" == rawValue.toLowerCase()) {
          var isUpdateComplete = await onUpdateAffterHardware(1); // thành công
          if (isUpdateComplete != null && isUpdateComplete.data != null) {
            List<int> bytesPAID = utf8.encode("PAID");
            await c.write(bytesPAID);
            onInitWhenBookingExist();
            pageEnum.value = ChargeCarPageEnum.CHARGING;
            isResult = true;
            break;
          }
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
      // không có thiết bị kết nối
      if (!isAvailable) {
        EasyLoading.showInfo(TKeys.fail_again2.translate());
        return;
      }
      var characteristic = (await findBluetoothCharacteristic())!;
      var bytes2 = utf8.encode("OFF");
      characteristic.write(bytes2);

      await Future.delayed(const Duration(milliseconds: 500));
      var onCompleteBooking =
          await HttpHelper.updateBookingComplete(bookingData?.bookID ?? 0);
      if (onCompleteBooking != null && onCompleteBooking.data != null) {
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
    paymentID ??= paymentData!.paymentID!;
    try {
      var data = await HttpHelper.updatePaymentAfterWaitHardware(
          paymentID, statusID,
          isExtTime: isExtTime);
      if (data != null && data.data != null) {
        bookingData = data.data!.booking;
        return data;
      }
    } catch (e) {}
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
}
