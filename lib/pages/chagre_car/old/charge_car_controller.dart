// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// // import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:flutter_credit_card/extension.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:get/get.dart';
// import 'package:crypto/crypto.dart';
// import '../../model/ble_response_model.dart';
// import '../../model/booking_model.dart';
// import '../../model/payment_model.dart';
// import '../../model/price_model.dart';
// import '../../model/response_base.dart';
// import '../../services/base_hive.dart';
// import '../../services/getxController.dart';
// import '../../services/https.dart';
// import '../../services/localization_service.dart';
// import '../../services/network_connect.dart';
// import '../../utils/const.dart';
// import '../customs/count_down.dart';

// class ChargeCarBind extends Bindings {
//   @override
//   void dependencies() {
//     Get.lazyPut<ChargeCarController>(() => ChargeCarController());
//   }
// }

// class ChargeCarController extends GetxControllerCustom
//     with WidgetsBindingObserver {
//   @override
//   void onInit() {
//     super.onInit();

//     if (Get.arguments is String) {
//       nameDevices = Get.arguments;

//       checkBLEAvailiable().then((value) async {
//         await onConnectBlue();
//         timeBookingNow = DateTime.now().millisecondsSinceEpoch ~/ 1000;
//       });
//     } else {
//       bookingData = Get.arguments as BookingModel?;
//       nameDevices = bookingData?.hardwareName ?? "";
//       bleState.value = BleStateEnum.isBeingStarted;
//       onInitWhenBookingExist();
//       onCheckSatausHardWareWhenOFF();
//       getListPrice();
//     }
//   }

//   int timeBookingNow = DateTime.now().millisecondsSinceEpoch ~/ 1000;
//   String nameDevices = "";
//   late List<BluetoothService> services;
//   late StreamSubscription<List<ScanResult>> scanSubScription;
//   BluetoothDevice? targetDevice;
//   // bool _IsDeviceConnectedAndEnable = false;
//   // late BluetoothCharacteristic targetCharacteristic;
//   var isBleConnected = false.obs;
//   var currentPrice = PriceModel().obs;
//   var bleState = BleStateEnum.connecting.obs;
//   RxList<PriceModel> listPrice = RxList.empty();
//   bool isVip = false;
//   int countToReload = 0;

//   PaymentModel? paymentModel;
//   // init Booking
//   BookingModel? bookingData;
//   PaymentModel? paymentData;
//   BleResponseModel? bleResponseModel;
//   RxInt percentProcessbar = 1.obs;
//   Timer? processbarTimer;

//   // debug
//   String rawString = "";
//   String exception = "";

//   //
//   RxString getTimeStillText = "".obs;
//   RxString getTimeTotalsText = "".obs;

//   CountdownController countdownController =
//       CountdownController(autoStart: true);

//   Future<bool> checkBLEAvailiable() async {
//     var a = await FlutterBluePlus.isSupported;
//     var b = await FlutterBluePlus.isOn;
//     while (!a || !b) {
//       await Future.delayed(const Duration(seconds: 2));
//       bleState.value = BleStateEnum.bleNotConnected;
//       a = await FlutterBluePlus.isSupported;
//       b = await FlutterBluePlus.isOn;
//       if (a && b) {
//         bleState.value = BleStateEnum.connecting;
//         break;
//       }
//     }
//     return true;
//   }

//   onChangePrice(PriceModel model) async {
//     if (!(await isConnectedHardware())) {
//       EasyLoading.showError(TKeys.grant_ble.translate());
//       return;
//     }
//     currentPrice.value = model;
//     listPrice.refresh();
//   }

//   DateTime time = DateTime.now();
//   Future onConnectBlue(
//       {Duration duration = const Duration(milliseconds: 10000)}) async {
//     bleState.value = BleStateEnum.connecting;
//     if (await FlutterBluePlus.isScanning.first) {
//       await FlutterBluePlus.stopScan();
//     }
//     scanSubScription = FlutterBluePlus.onScanResults.listen((results) async {
//       if (results.isNotEmpty) {
//         ScanResult result = results.last;
//         if (result.device.platformName.isEmpty) {
//           return;
//         }

//         if (result.device.platformName == nameDevices && targetDevice == null) {
//           targetDevice = result.device;
//           try {
//             await result.device.connect(mtu: null);
//             if (Platform.isAndroid) {
//               result.device.requestMtu(223, predelay: 0);
//             }
//             if (countToReload == 0) {
//               await discoverServices();
//             }
//             await onCheckDeviceConnect();
//             await FlutterBluePlus.stopScan();
//           } catch (e) {}
//         }
//       }
//     }, onDone: (() {}));
//     time = time.add(const Duration(seconds: 10));
//     await FlutterBluePlus.startScan(timeout: duration);
//     await Future.delayed(duration);
//     if (targetDevice == null &&
//         !(await FlutterBluePlus.isScanning.first) &&
//         DateTime.now().difference(time) > const Duration(seconds: 9)) {
//       if (targetDevice == null) {
//         EasyLoading.showError(TKeys.fail_again2.translate());
//         onBack(isBack: true);
//       }
//     }
//   }

//   discoverServices() async {
//     List<BluetoothService> services = await targetDevice!.discoverServices();
//     isLoading.value = true;
//     for (var service in services) {
//       service.characteristics
//           .where(
//               (element) => element.properties.read && element.properties.write)
//           .forEach((characteristic) async {
//         var authenValue = md5
//             .convert(utf8.encode(nameDevices.substring(5, 8)))
//             .toString()
//             .substring(10, 22);
//         List<int> bytes = utf8.encode(authenValue);
//         try {
//           await characteristic.write(bytes);
//           countToReload++;
//           await Future.delayed(const Duration(seconds: 1));

//           var listByteString = await characteristic.read();

//           var rawValue = utf8.decode(listByteString);
//           if (rawValue.isNotNullAndNotEmpty) {
//             if (rawValue.toLowerCase() == authenValue.toLowerCase()) {
//               EasyLoading.showInfo(TKeys.machine_in_use.translate(),
//                   duration: const Duration(seconds: 5));
//               onBack(isBack: true);
//               return;
//             }
//             rawString = rawValue; // debug

//             bleResponseModel = BleResponseModel.fromJson(jsonDecode(rawValue));

//             var checkQRCode =
//                 await HttpHelper.updateHardware(bleResponseModel!.toJson());
//             if (!checkQRCode) {
//               EasyLoading.showInfo(
//                   // ignore: use_build_context_synchronously
//                   TKeys.machine_under_maintenance.translate(),
//                   duration: const Duration(seconds: 5));

//               onBack(isBack: true);
//               return;
//             }
//             await getListPrice();
//             isLoading.value = false;
//             isBleConnected.value = true;

//             bleState.value = BleStateEnum.chooseYourPlan;
//           }
//         } catch (e) {
//           // EasyLoading.showError(TKeys.fail_again2.translate(),
//           //     duration: const Duration(seconds: 5));
//           onBack(isBack: true);
//         }
//       });
//     }
//   }

//   // lấy danh sách giá
//   getListPrice() async {
//     var listPriceTemp = await HttpHelper.getPrice(
//         bleResponseModel?.myId ?? bookingData!.hardwareID!,
//         HiveHelper.get(Constants.USER_ID));
//     listPrice.value = listPriceTemp.data ?? [];
//     isVip = listPriceTemp.isVIP ?? false;
//     if (listPriceTemp.data?.isNotEmpty ?? false) {
//       currentPrice.value = listPriceTemp.data![0];
//     }
//   }

//   onUpdatePayment(int statusID, {int? paymentID = null}) async {
//     paymentID ??= paymentData!.paymentID!;
//     try {
//       var data = await HttpHelper.updatePayment(paymentID, statusID);
//       if (data != null && data.data != null) {
//         return true;
//       }
//     } finally {}
//     return false;
//   }

//   Future<ResponseBase<PaymentModel>?> onUpdateAffterHardware(int statusID,
//       {bool isExtTime = false, int? paymentID = null}) async {
//     paymentID ??= paymentData!.paymentID!;
//     try {
//       var data = await HttpHelper.updatePaymentAfterWaitHardware(
//           paymentID, statusID,
//           isExtTime: isExtTime);
//       if (data != null && data.data != null) {
//         bookingData = data.data!.booking;
//         return data;
//       }
//     } catch (e) {}
//     return null;
//   }

//   Future<bool> isConnectedHardware({bool isConnect = true}) async {
//     var conenctState = FlutterBluePlus.connectedDevices;
//     var isOnBle = await FlutterBluePlus.isSupported;

//     if (!isOnBle || conenctState.isEmpty) {
//       isBleConnected.value = false;
//       if (true) await onCheckSatausHardWareWhenOFF();
//       return false;
//     } else {
//       isBleConnected.value = true;
//     }
//     return isBleConnected.value;
//   }

//   RxInt countDownPlugin = 0.obs;
//   String prettyDuration(int seconds2) {
//     var rxpired =
//         HiveHelper.get(Constants.EXPIRED_ON_HARDWARE, defaultvalue: 90);
//     var duration = Duration(seconds: rxpired - seconds2);
//     var seconds = (duration.inMilliseconds % (60 * 1000)) / 1000;
//     return '${duration.inMinutes}:${seconds.toStringAsFixed(0)}s';
//   }

//   Future<bool> openHardware() async {
//     bool isResult = false;
//     bleState.value = BleStateEnum.waitingConnectPlugging;

//     if (!(await isConnectedHardware())) {
//       EasyLoading.showInfo(TKeys.fail_again2.translate());
//       return false;
//     }

//     List<BluetoothService> services = await targetDevice!.discoverServices();
//     await Future.wait(services.map((service) async {
//       await Future.wait(service.characteristics
//           .where((element) =>
//               element.properties.read &&
//               element.properties.write &&
//               element.properties.notify)
//           .map((characteristic) async {
//         try {
//           String onCommand =
//               "ON:${getTimeOpenHardware()}:${DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000}:${bookingData!.bookID}";
//           List<int> bytes = utf8.encode(onCommand);
//           await characteristic.write(bytes);

//           int expiredValue =
//               HiveHelper.get(Constants.EXPIRED_ON_HARDWARE, defaultvalue: 90);

//           for (int i = 1; i <= expiredValue; i++) {
//             if (i == expiredValue) {
//               EasyLoading.showError(TKeys.on_back_300s_message.translate(),
//                   duration: const Duration(seconds: 5));
//               onBack(isBack: true);
//               return;
//             }
//             countDownPlugin.value = i;
//             // testing
//             // List<int> bytesPAID = utf8.encode("PAID");
//             // await characteristic.write(bytesPAID);
//             // bleState.value = BleStateEnum.isBeingStarted;
//             // onInitWhenBookingExist();
//             // isResult = true;

//             var listByteString = await characteristic.read();
//             await Future.delayed(const Duration(seconds: 1));
//             var rawValue = utf8.decode(listByteString);
//             if ("true" == rawValue.toLowerCase()) {
//               var isUpdateComplete =
//                   await onUpdateAffterHardware(1); // thành công
//               if (isUpdateComplete != null && isUpdateComplete.data != null) {
//                 List<int> bytesPAID = utf8.encode("PAID");
//                 await characteristic.write(bytesPAID);
//                 bleState.value = BleStateEnum.isBeingStarted;
//                 onInitWhenBookingExist();
//                 isResult = true;
//                 break;
//               }
//             }
//           }
//         } catch (e) {
//           // exception = e.toString();
//           // if (!isResult) {
//           //   onUpdateAffterHardware(-1);
//           //   EasyLoading.showError(
//           //       TKeys.booking_failed_to_not_begin_connect.translate(),
//           //       duration: const Duration(seconds: 5));
//           //   onBack(isBack: true);
//           // }
//         }
//       }));
//     }));
//     if (!isResult) {
//       onUpdateAffterHardware(-1);
//       EasyLoading.showError(
//           TKeys.booking_failed_to_not_begin_connect.translate(),
//           duration: const Duration(seconds: 5));
//       onBack(isBack: true);
//     }
//     return isResult;
//   }

//   void setPaymentData(ResponseBase<PaymentModel> data) {
//     paymentData = data.data;
//     bookingData = data.data!.booking;
//   }

//   Future<PaymentModel?> onBookingPayment() async {
//     bleState.value = BleStateEnum.loading;

//     try {
//       var autoPayment = await HttpHelper.autoPayment(bleResponseModel!.myId!,
//           currentPrice.value.priceID!, bookingData?.bookID);
//       if (autoPayment != null && autoPayment.data != null) {
//         paymentData = autoPayment.data;
//         bookingData = autoPayment.data!.booking;
//         return autoPayment.data;
//       }
//     } finally {
//       bleState.value = BleStateEnum.chooseYourPlan;
//     }
//     return null;
//   }

//   // ---------------------------------------------------------------------------------------------------------

//   RxBool isShowButtonCancel = true.obs;
//   // sạc hoàn thành
//   Future<BookingModel?> onBookingComplete({bool isSendOff = true}) async {
//     if (!isBleConnected.value) {
//       return null;
//     }

//     isShowButtonCancel.value = false;
//     BookingModel? booking;
//     try {
//       bleState.value = BleStateEnum.loading;
//       if (!(await isConnectedHardware())) {
//         await targetDevice!.connect(mtu: null);
//         if (Platform.isAndroid) {
//           targetDevice!.requestMtu(223, predelay: 0);
//         }
//       }
//       List<BluetoothService> services = await targetDevice!.discoverServices();
//       await Future.wait(services.map((service) async {
//         await Future.wait(service.characteristics
//             .where((element) =>
//                 element.properties.read && element.properties.write)
//             .map((characteristic) async {
//           try {
//             var authenValue = md5
//                 .convert(utf8.encode((nameDevices).substring(5, 8)))
//                 .toString()
//                 .substring(10, 22);

//             List<int> bytes = utf8.encode(authenValue);
//             await characteristic.write(bytes);
//             bytes = utf8.encode("${bookingData!.bookID}");
//             await characteristic.write(bytes);
//             await Future.delayed(const Duration(milliseconds: 500));
//             if (isSendOff) {
//               try {
//                 var bytes2 = utf8.encode("OFF");
//                 characteristic.write(bytes2);
//               } catch (e) {}
//             }

//             await Future.delayed(const Duration(milliseconds: 500));
//             var onCompleteBooking = await HttpHelper.updateBookingComplete(
//                 bookingData?.bookID ?? 0);
//             if (onCompleteBooking != null && onCompleteBooking.data != null) {
//               processbarTimer?.cancel();
//               // ignore: use_build_context_synchronously
//               booking = onCompleteBooking.data;
//               onBack(isBack: true);
//             }
//           } catch (e) {
//             exception = e.toString();
//           }
//         }));
//       }));
//     } finally {
//       bleState.value = BleStateEnum.isBeingStarted;
//       isShowButtonCancel.value = true;
//     }
//     return booking;
//   }

//   Future onBack({bool isBack = true}) async {
//     try {
//       await FlutterBluePlus.stopScan();
//       targetDevice?.disconnect();
//       countToReload = 0;
//       bookingData = null;
//       nameDevices = "";
//       scanSubScription.cancel();
//       processbarTimer?.cancel();
//       targetDevice = null;
//       countdownController.onPause;
//       // ignore: empty_catches
//     } catch (e) {}

//     if (isBack) {
//       Get.back();
//     }
//   }

//   /// load when booking exits
//   onInitWhenBookingExist() async {
//     if (processbarTimer != null) {
//       processbarTimer!.cancel();
//     }

//     processbarTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
//       if (bookingData != null) {
//         var value = (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000) -
//             bookingData!.dateStart!;
//         percentProcessbar.value = value;
//         getTimeStillText.value = _printDuration(
//             Duration(seconds: percentProcessbar.value),
//             isShowSecond: false);

//         getTimeTotalsText.value = bookingData != null
//             ? _printDuration(
//                 Duration(
//                     seconds: (bookingData!.dateEnd! - bookingData!.dateStart!)
//                         .toInt()),
//                 isShowSecond: false)
//             : "";

//         if (percentProcessbar.value >= bookingData!.getDurationTimeEnd &&
//             bleState.value == BleStateEnum.isBeingStarted) {
//           await HttpHelper.updateBookingComplete(bookingData?.bookID ?? 0);
//           EasyLoading.showSuccess(
//               TKeys.complete_charging_end_processing_auto.translate(),
//               duration: const Duration(seconds: 5));
//           processbarTimer?.cancel();
//           onBack(isBack: true);
//         }
//       }
//     });
//   }

//   /// load when booking exits
//   onInitExtBooking() async {
//     if (processbarTimer != null) {
//       processbarTimer!.cancel();
//     }

//     processbarTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
//       if (bookingData != null) {
//         var value = (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000) -
//             bookingData!.dateStart!;
//         percentProcessbar.value = value;

//         getTimeStillText.value = _printDuration(
//             Duration(seconds: percentProcessbar.value),
//             isShowSecond: false);
//         getTimeTotalsText.value = bookingData != null
//             ? _printDuration(
//                 Duration(
//                     seconds: (bookingData!.dateEnd! - bookingData!.dateStart!)
//                         .toInt()),
//                 isShowSecond: false)
//             : "";

//         if (percentProcessbar.value >= bookingData!.getDurationTimeEnd &&
//             bleState.value == BleStateEnum.isBeingStarted) {
//           await HttpHelper.updateBookingComplete(bookingData?.bookID ?? 0);
//           processbarTimer?.cancel();
//           EasyLoading.showSuccess(
//               TKeys.complete_charging_end_processing_auto.translate(),
//               duration: const Duration(seconds: 5));
//           onBack(isBack: true);
//         }
//       }
//     });
//   }

//   /// mấy hàm convert sang string
//   String getTimeOpenHardware({double? time}) {
//     // ignore: prefer_conditional_assignment
//     if (time == null) {
//       time = currentPrice.value.priceTime!;
//     }

//     int intTime = (time * 60).toInt();

//     String result = "";
//     if (intTime <= 999 && intTime > 99) {
//       result = intTime.toString();
//     } else if (intTime > 9 && intTime <= 99) {
//       result = "0$intTime";
//     } else if (intTime > 0) {
//       result = "00$intTime";
//     }
//     return result;
//   }

//   String _printDuration(Duration duration,
//       {bool isShowSecond = true, bool isNotCount = false}) {
//     String twoDigits(int n) => n.toString().padLeft(2, "0");
//     String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
//     String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
//     if (isShowSecond) {
//       return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
//     } else {
//       return "${twoDigits(duration.inHours)}:$twoDigitMinutes";
//     }
//   }

//   String get getTimeStill {
//     var time = (bookingData!.dateEnd! - bookingData!.dateStart!) -
//         ((DateTime.now().millisecondsSinceEpoch ~/ 1000) -
//             bookingData!.dateStart!);
//     var duration = Duration(seconds: time + 60);
//     return _printDuration(duration, isShowSecond: false, isNotCount: true);
//   }

//   /// --- hết

//   // Kiểm tra kết nối bluetooth
//   onCheckDeviceConnect() async {
//     FlutterBluePlus.adapterState.listen((event) async {
//       if (event == BluetoothAdapterState.turningOff) {
//         targetDevice?.disconnect();
//       } else if (BluetoothAdapterState.off == event) {
//         isBleConnected.value = false;
//       } else if (BluetoothAdapterState.on == event && countToReload > 0) {
//         await onCheckSatausHardWareWhenOFF();
//       }
//     });

//     targetDevice!.connectionState.listen((event) async {
//       if (event == BluetoothConnectionState.connected && countToReload > 0) {
//         await onCheckSatausHardWareWhenOFF();
//       } else if (event == BluetoothConnectionState.disconnected &&
//           nameDevices.isNotEmpty) {
//         isBleConnected.value = false;
//       }
//     });
//   }

//   // Ext time
//   Future<PaymentModel?> getPaymentKeyExtTimeBooking(int priceID) async {
//     try {
//       var getPayment = await HttpHelper.extHoursBooking(
//           bookingData!.hardwareID!, priceID, bookingData!.bookID!);
//       paymentData = getPayment?.data;
//       return getPayment?.data;
//     } catch (e) {}
//     return null;
//   }

//   // gọi qua phần cứng tăng thêm thời gian
//   Future<bool> extTimeHardware(double? time) async {
//     bool isResult = false;
//     bool isLoadMethod = true;
//     bleState.value = BleStateEnum.loading;

//     // ignore: unrelated_type_equality_checks
//     var status = await targetDevice!.connectionState.first;

//     if (!await isConnectedHardware(isConnect: false)) {
//       // ignore: use_build_context_synchronously
//       await showDialog(
//         context: Get.context!,
//         builder: (context) => WillPopScope(
//           onWillPop: () async => false,
//           child: AlertDialog(
//             title: Text(TKeys.notice.translate(),
//                 style: Theme.of(context).textTheme.bodyLarge),
//             content: Text(TKeys.grant_ble.translate(),
//                 style: Theme.of(context).textTheme.bodyMedium),
//             actions: <Widget>[
//               TextButton(
//                 child: Text(TKeys.cancel.translate(),
//                     style: Theme.of(context).textTheme.bodyMedium),
//                 onPressed: () async {
//                   Navigator.of(context).pop();
//                 },
//               ),
//               TextButton(
//                 child: Text(TKeys.yes.translate(),
//                     style: Theme.of(context).textTheme.bodyMedium),
//                 onPressed: () async {
//                   if (!isLoadMethod) return;
//                   isLoadMethod = false;
//                   try {
//                     var isBleON = await FlutterBluePlus.adapterState.first ==
//                         BluetoothAdapterState.on;
//                     status = await targetDevice!.connectionState.first;

//                     if (status != BluetoothConnectionState.connected) {
//                       await reConnect();
//                     }

//                     var isInternetConnect = await NetworkInfo().isConnected;

//                     if (status == BluetoothConnectionState.connected &&
//                         isInternetConnect) {
//                       // ignore: use_build_context_synchronously
//                       Navigator.of(context).pop();
//                     } else {
//                       EasyLoading.showError(TKeys.unable_to_connect.translate(),
//                           duration: const Duration(seconds: 5));
//                     }
//                   } finally {
//                     isLoadMethod = true;
//                   }
//                 },
//               ),
//             ],
//           ),
//         ),
//       ).then((value) async {
//         await Future.delayed(const Duration(seconds: 2));
//         status = await targetDevice!.connectionState.first;

//         if (!(await isConnectedHardware())) {
//           return false;
//         }

//         List<BluetoothService> services =
//             await targetDevice!.discoverServices();
//         await Future.wait(services.map((service) async {
//           await Future.wait(service.characteristics
//               .where((element) =>
//                   element.properties.read &&
//                   element.properties.write &&
//                   element.properties.notify)
//               .map((characteristic) async {
//             try {
//               var authenValue = md5
//                   .convert(utf8.encode(nameDevices.substring(5, 8)))
//                   .toString()
//                   .substring(10, 22);
//               List<int> bytesAuthenValue = utf8.encode(authenValue);

//               await characteristic.write(bytesAuthenValue);
//               await Future.delayed(const Duration(seconds: 1));
//               var bytes2 = utf8.encode("${bookingData!.bookID}");
//               await characteristic.write(bytes2);

//               String onCommand = "EXT:${getTimeOpenHardware(time: time)}";
//               List<int> bytes = utf8.encode(onCommand);
//               await characteristic.write(bytes);

//               var listByteString = await characteristic.read();
//               var rawValue = utf8.decode(listByteString);

//               if ("true" == rawValue.toLowerCase() ||
//                   "ext_ok" == rawValue.toLowerCase()) {
//                 isResult = true;
//               }
//             } catch (e) {
//               exception = e.toString();
//             }
//           }));
//         }));
//       });
//     } else {
//       List<BluetoothService> services = await targetDevice!.discoverServices();
//       await Future.wait(services.map((service) async {
//         await Future.wait(service.characteristics
//             .where((element) =>
//                 element.properties.read &&
//                 element.properties.write &&
//                 element.properties.notify)
//             .map((characteristic) async {
//           try {
//             var bytes2 = utf8.encode("${bookingData!.bookID}");
//             await characteristic.write(bytes2);
//             await Future.delayed(const Duration(seconds: 1));

//             String onCommand = "EXT:${getTimeOpenHardware(time: time)}";
//             List<int> bytes = utf8.encode(onCommand);
//             await characteristic.write(bytes);

//             var listByteString = await characteristic.read();
//             var rawValue = utf8.decode(listByteString);
//             if ("true" == rawValue.toLowerCase() ||
//                 "ext_ok" == rawValue.toLowerCase()) {
//               isResult = true;
//             }
//           } catch (e) {
//             exception = e.toString();
//           }
//         }));
//       }));
//       bleState.value = BleStateEnum.isBeingStarted;
//     }
//     bleState.value = BleStateEnum.isBeingStarted;
//     return isResult;
//   }

//   Future<bool> findAndConnectDevice() async {
//     if (await FlutterBluePlus.isScanning.first) {
//       await FlutterBluePlus.stopScan();
//     }

//     for (var device in FlutterBluePlus.connectedDevices) {
//       await device.disconnect();
//     }
//     bool result2 = false;
//     scanSubScription = FlutterBluePlus.onScanResults.listen((results) async {
//       if (results.isNotEmpty) {
//         ScanResult result = results.last;
//         if (result.device.platformName.isEmpty) {
//           return;
//         }

//         if (result.device.platformName == nameDevices && targetDevice == null) {
//           targetDevice = result.device;
//           await FlutterBluePlus.stopScan();
//           await targetDevice!.connect(mtu: null);
//           if (Platform.isAndroid) {
//             result.device.requestMtu(223, predelay: 0);
//           }
//           isBleConnected.value = true;
//           result2 = true;
//           await onCheckDeviceConnect();
//           countToReload++;
//         }
//       }
//     }, onDone: () {
//       scanSubScription.cancel();
//       FlutterBluePlus.stopScan();
//       result2 = false;
//     });
//     await FlutterBluePlus.startScan();
//     return result2;
//   }

//   Future reConnect() async {
//     var state = FlutterBluePlus.connectedDevices;
//     var isBleON =
//         await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on;
//     try {
//       while (state.isEmpty && isBleON) {
//         isBleON = await FlutterBluePlus.adapterState.first ==
//             BluetoothAdapterState.on;
//         state = FlutterBluePlus.connectedDevices;
//         if (!targetDevice!.isConnected) {
//           nameDevices = targetDevice!.advName;
//           targetDevice = null;
//           scanSubScription =
//               FlutterBluePlus.onScanResults.listen((results) async {
//             if (results.isNotEmpty) {
//               ScanResult result = results.last;
//               if (result.device.platformName.isEmpty) {
//                 return;
//               }
//               targetDevice = result.device;
//               await targetDevice?.connect(
//                   mtu: null,
//                   timeout: const Duration(seconds: 3),
//                   autoConnect: true);
//               if (Platform.isAndroid) {
//                 result.device.requestMtu(223, predelay: 0);
//               }
//             }
//           }, onDone: (() {}));
//           FlutterBluePlus.cancelWhenScanComplete(scanSubScription);
//           await FlutterBluePlus.startScan(
//               withNames: [nameDevices], timeout: const Duration(seconds: 10));

//           await Future.delayed(const Duration(seconds: 1));
//           state = FlutterBluePlus.connectedDevices;
//         }
//       }
//     } catch (e) {}
//   }

//   // kiểm tra trạng thái hardware khi máy off, đc reconnect
//   bool isCall = true;
//   onCheckSatausHardWareWhenOFF() async {
//     var isBleON =
//         await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on;

//     if (isCall && isBleON) {
//       var state = FlutterBluePlus.connectedDevices;

//       if (timeBookingNow + 300 <
//               (DateTime.now().millisecondsSinceEpoch ~/ 1000) &&
//           bleState.value == BleStateEnum.chooseYourPlan) {
//         targetDevice = null;
//         for (var device in state) {
//           device.disconnect();
//         }
//         onBack(isBack: true);
//         return;
//       }
//       isCall = false;
//       if (targetDevice != null) {
//         try {
//           while (state.isEmpty && isBleON) {
//             if (!targetDevice!.isConnected) {
//               nameDevices = targetDevice!.advName;
//               targetDevice = null;
//               scanSubScription =
//                   FlutterBluePlus.onScanResults.listen((results) async {
//                 if (results.isNotEmpty) {
//                   ScanResult result = results.last;
//                   if (result.device.platformName.isEmpty) {
//                     return;
//                   }
//                   targetDevice = result.device;
//                   await targetDevice?.connect(
//                       mtu: null,
//                       timeout: const Duration(seconds: 3),
//                       autoConnect: true);
//                   if (Platform.isAndroid) {
//                     result.device.requestMtu(223, predelay: 0);
//                   }
//                 }
//               }, onDone: (() {}));
//               FlutterBluePlus.cancelWhenScanComplete(scanSubScription);
//               await FlutterBluePlus.startScan(
//                   withNames: [nameDevices],
//                   timeout: const Duration(seconds: 10));

//               await Future.delayed(const Duration(seconds: 1));
//               state = FlutterBluePlus.connectedDevices;
//             }
//           }
//         } catch (e) {}

//         if (state.isNotEmpty) {
//           isBleConnected.value = true;
//           try {
//             List<BluetoothService> services =
//                 await targetDevice!.discoverServices();
//             for (var service in services) {
//               service.characteristics
//                   .where((element) =>
//                       element.properties.read &&
//                       element.properties.write &&
//                       element.properties.notify)
//                   .forEach((characteristic) async {
//                 if (nameDevices.isNotNullAndNotEmpty) {
//                   try {
//                     var authenValue = md5
//                         .convert(utf8.encode((nameDevices).substring(5, 8)))
//                         .toString()
//                         .substring(10, 22);

//                     List<int> bytes = utf8.encode(authenValue);
//                     await characteristic.write(bytes);
//                     var listByteString = await characteristic.read();
//                     var rawValue = utf8.decode(listByteString);

//                     bleResponseModel =
//                         BleResponseModel.fromJson(jsonDecode(rawValue));
//                     if (bleResponseModel?.bookingID == bookingData?.bookID) {
//                       await onBookingComplete(isSendOff: false);
//                       EasyLoading.showSuccess(
//                           TKeys.complete_charging_end_processing_auto
//                               .translate(),
//                           duration: const Duration(seconds: 5));
//                     }
//                     // ignore: empty_catches
//                   } catch (e) {}
//                 }
//               });
//             }
//           } finally {
//             isCall = true;
//           }
//         }
//       } else {
//         try {
//           await findAndConnectDevice();
//         } finally {
//           isCall = true;
//         }
//       }
//     }
//   }
// }
