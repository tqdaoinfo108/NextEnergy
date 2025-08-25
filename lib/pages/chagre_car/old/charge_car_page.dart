// import 'package:bottom_sheet/bottom_sheet.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:get/get.dart';
// import 'package:v2/pages/customs/appbar.dart';
// import 'package:v2/pages/customs/button.dart';
// import 'package:v2/pages/customs/circular_progress_indicator.dart';
// import 'package:v2/services/localization_service.dart';
// import 'package:v2/utils/const.dart';
// import 'package:lottie/lottie.dart';

// import '../../model/payment_model.dart';
// import '../../model/response_base.dart';
// import '../customs/count_down.dart';
// import '../customs/dialog_custom.dart';
// import '../customs/flutter_animation_progress_bar.dart';
// import '../customs/page_life_cycle.dart';
// import '../customs/spinner_item_selector_widget.dart';
// import '../payment/payment_3ds_page.dart';
// import 'charge_car_controller.dart';
// import 'ext_charge_car_popup.dart';

// class ChargeCarPage extends GetView<ChargeCarController> {
//   const ChargeCarPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     Widget buildButtonClose(BuildContext context) {
//       return Opacity(
//         opacity: controller.isBleConnected.value ? 1 : 0.4,
//         child: Container(
//           decoration: BoxDecoration(
//             color: Theme.of(context).iconTheme.color,
//             borderRadius: BorderRadius.circular(12.0),
//           ),
//           width: MediaQuery.of(context).size.width / 2.4,
//           child: ListTile(
//             contentPadding:
//                 const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             onTap: () async {
//               if (controller.bleState.value == BleStateEnum.isBeingStarted &&
//                   controller.isBleConnected.value) {
//                 letCancelBooking(context);
//               }
//             },
//             horizontalTitleGap: 0,
//             leading: Icon(
//               Icons.close,
//               color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.4),
//             ),
//             title:
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text(
//                 TKeys.stop_charging.translate(),
//                 style: Theme.of(context)
//                     .textTheme
//                     .bodyMedium!
//                     .copyWith(color: Theme.of(context).scaffoldBackgroundColor),
//               ),
//             ]),
//           ),
//         ),
//       );
//     }

//     Widget buildButton(BuildContext context) {
//       return Opacity(
//         opacity: controller.isBleConnected.value ? 1 : 0.4,
//         child: Container(
//           decoration: BoxDecoration(
//             color: Theme.of(context).primaryColor,
//             borderRadius: BorderRadius.circular(12.0),
//           ),
//           width: MediaQuery.of(context).size.width / 2.4,
//           child: ListTile(
//             onTap: () async {
//               if (!controller.isBleConnected.value) {
//                 return;
//               }
//               if (controller.listPrice.isEmpty) {
//                 controller.bleState.value = BleStateEnum.loading;
//                 controller.update();
//                 await controller.getListPrice();
//                 controller.bleState.value = BleStateEnum.isBeingStarted;
//                 controller.update();
//               }
//               // ignore: use_build_context_synchronously
//               showFlexibleBottomSheet<void>(
//                 minHeight: 0,
//                 initHeight: 0.6,
//                 maxHeight: 0.6,
//                 anchors: [0, 0.6],
//                 context: context,
//                 isSafeArea: true,
//                 bottomSheetColor: Theme.of(context).scaffoldBackgroundColor,
//                 decoration: const BoxDecoration(
//                     borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(12.0),
//                         topRight: Radius.circular(12.0))),
//                 builder: (context1, controller1, offset) {
//                   return ExtTimeChargeCarBottomSheet(
//                     scrollController: controller1,
//                     bottomSheetOffset: offset,
//                     cxt: context1,
//                     controller: controller,
//                   );
//                 },
//               );
//             },
//             contentPadding:
//                 const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             horizontalTitleGap: 0,
//             leading: const Icon(Icons.add_circle),
//             title:
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text(
//                   controller.isVip
//                       ? TKeys.buy_more_member.translate()
//                       : TKeys.buy_more.translate(),
//                   style: Theme.of(context).textTheme.bodyMedium,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis),
//             ]),
//           ),
//         ),
//       );
//     }

//     Widget buildIsBegingStarted(BuildContext context) {
//       return Obx(() => Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//             child: Column(
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     SizedBox(
//                         width: 60,
//                         height: 60,
//                         child: Lottie.asset('assets/images/charging.json')),
//                     const SizedBox(height: 10),
//                     Text(TKeys.charging.translate(),
//                         style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                             color: Theme.of(context).primaryColor,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 24))
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 Image.asset(
//                   "assets/images/charge.gif",
//                   width: Get.width / 2,
//                 ),
//                 const SizedBox(height: 12),
//                 Text(TKeys.do_note_remove_flag.translate(),
//                     textAlign: TextAlign.center,
//                     style: Theme.of(context).textTheme.bodyLarge),
//                 const SizedBox(height: 12),
//                 Text(
//                     "${controller.getTimeStillText.value} / ${controller.getTimeTotalsText.value}",
//                     style: Theme.of(context)
//                         .textTheme
//                         .bodyLarge!
//                         .copyWith(fontSize: 15)),
//                 FAProgressBar(
//                   backgroundColor:
//                       Theme.of(context).primaryColor.withOpacity(0.2),
//                   currentValue: controller.percentProcessbar.value,
//                   maxValue: controller.bookingData?.getDurationTimeEnd ?? 100,
//                   displayText: '',
//                   displayTextStyle: const TextStyle(fontSize: 0),
//                   progressGradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: const Alignment(0.8, 1),
//                     colors: <Color>[
//                       Theme.of(context).primaryColor,
//                       Theme.of(context).primaryColor.withOpacity(0.7),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     buildButtonClose(context),
//                     const SizedBox(width: 12),
//                     buildButton(context),
//                   ],
//                 ),
//               ],
//             ),
//           ));
//     }

//     SafeArea buildChooseSlotCharge(BuildContext context) {
//       return SafeArea(
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Stack(
//             children: [
//               SingleChildScrollView(
//                 child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 12),
//                       Countdown(
//                           controller: controller.countdownController,
//                           seconds: 300,
//                           build: (BuildContext context, double time) => Text(
//                               "${TKeys.time_remaining.translate()} ${time.toInt()}"),
//                           interval: const Duration(seconds: 1),
//                           onFinished: () async {
//                             if (controller.bleState.value ==
//                                 BleStateEnum.chooseYourPlan) {
//                               EasyLoading.showError(
//                                   TKeys.on_back_300s_message.translate(),
//                                   duration: const Duration(seconds: 5));
//                               await controller.onBack(isBack: true);
//                               if (Get.currentRoute == "/charge_car") {
//                                 await controller.onBack(isBack: true);
//                               }
//                             }
//                           }),
//                       const SizedBox(height: 12),
//                       Text(
//                         TKeys.choose_your_plant.translate(),
//                         style: Theme.of(context).textTheme.headlineLarge,
//                       ),
//                       const SizedBox(height: 12),
//                       controller.isLoading.value
//                           ? const CircularProgressIndicatorCustom()
//                           : Column(
//                               children: [
//                                 SpinnerItemSelector(
//                                   items: controller.listPrice,
//                                   selectedItemToWidget: (item) =>
//                                       ButtonPriceOutline(
//                                     "${item.priceTime}",
//                                     () {
//                                       controller.onChangePrice(item);
//                                     },
//                                     item == controller.currentPrice.value,
//                                     subString: controller.isVip
//                                         ? null
//                                         : "${item.unitPrice}${item.priceAmount}",
//                                   ),
//                                   nonSelectedItemToWidget: (item) => Opacity(
//                                     opacity: 0.4,
//                                     child: ButtonPriceOutline(
//                                       "${item.priceTime}",
//                                       () {
//                                         // controller.onChangePrice(item);
//                                       },
//                                       item == controller.currentPrice.value,
//                                       subString: controller.isVip
//                                           ? null
//                                           : "${item.unitPrice}${item.priceAmount}",
//                                     ),
//                                   ),
//                                   itemHeight: 100,
//                                   height: Get.height / 3 * 2,
//                                   width: Get.width,
//                                   itemWidth: Get.width,
//                                   onSelectedItemChanged: ((item) {
//                                     controller.onChangePrice(item);
//                                   }),
//                                   spinnerBgColor: Colors.white,
//                                 ),
//                                 // Center(
//                                 //   child: Wrap(
//                                 //     direction: Axis.horizontal,
//                                 //     spacing: 8,
//                                 //     runSpacing: 8,
//                                 //     children: <Widget>[
//                                 //       for (var item in controller.listPrice)
//                                 //         ButtonPriceOutline(
//                                 //           "${item.priceTime}",
//                                 //           () {
//                                 //             controller.onChangePrice(item);
//                                 //           },
//                                 //           item == controller.currentPrice.value,
//                                 //           subString: controller.isVip
//                                 //               ? null
//                                 //               : "${item.unitPrice}${item.priceAmount}",
//                                 //         ),
//                                 //     ],
//                                 //   ),
//                                 // ),
//                               ],
//                             ),
//                       const SizedBox(height: 78),
//                     ]),
//               ),
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   SizedBox(
//                     height: 56,
//                     child: Row(
//                       children: [
//                         Expanded(
//                             child: ButtonPrimaryOutline(
//                                 TKeys.cancel.translate(), () async {
//                           controller.onBack(isBack: true);
//                         })),
//                         const SizedBox(width: 8),
//                         Expanded(
//                             child: ButtonPrimary(
//                           controller.isVip
//                               ? TKeys.start_member.translate()
//                               : TKeys.start.translate(),
//                           onPress: () async {
//                             if (controller.currentPrice.value.priceID == null) {
//                               EasyLoading.showError(
//                                   TKeys.no_select_time.translate(),
//                                   duration: const Duration(seconds: 5));
//                               return;
//                             }
//                             showDialogAutoPaymentCustom(context, () async {
//                               if (!(await controller.isConnectedHardware())) {
//                                 EasyLoading.showInfo(
//                                     TKeys.fail_again2.translate());
//                                 return false;
//                               }
//                               // is vip payment
//                               if (controller.isVip) {
//                                 await controller.onBookingPayment();
//                                 if (controller.paymentData != null &&
//                                     controller
//                                         .paymentData!.paymentKey!.isEmpty) {
//                                   // Thanh toán vip member
//                                   // ignore: use_build_context_synchronously
//                                   letOpenHardware(context);
//                                 } else {
//                                   // ignore: use_build_context_synchronously
//                                   EasyLoading.showError(
//                                       TKeys.fail_again2.translate(),
//                                       duration: const Duration(seconds: 5));
//                                 }
//                               } else {
//                                 // thanh toán = visa
//                                 var result = await Get.dialog(
//                                   const Payment3DSPage(),
//                                   arguments: PaymentDtoModel(
//                                       controller.bookingData?.hardwareID ??
//                                           controller.bleResponseModel?.myId,
//                                       controller.currentPrice.value.priceID!,
//                                       controller.bookingData?.bookID,
//                                       false,
//                                       timeNow: controller.timeBookingNow),
//                                   barrierDismissible: false,
//                                 );

//                                 if (result != null &&
//                                     (result as ResponseBase<PaymentModel>?) !=
//                                         null) {
//                                   controller.setPaymentData(
//                                       result as ResponseBase<PaymentModel>);
//                                   await letOpenHardware(context);
//                                 } else {
//                                   if ((controller.timeBookingNow + 300) <
//                                       (DateTime.now().millisecondsSinceEpoch ~/
//                                           1000)) {
//                                     Get.back(result: false);
//                                   } else {
//                                     var a = await FlutterBluePlus.isAvailable;
//                                     var b = await FlutterBluePlus.isOn;
//                                     if (!a || !b) {
//                                       controller.onBack(isBack: true);
//                                       EasyLoading.showError(
//                                           // ignore: use_build_context_synchronously
//                                           TKeys.fail_again2.translate(),
//                                           duration: const Duration(seconds: 5));
//                                     }
//                                   }
//                                 }
//                               }
//                             },
//                                 text: controller.isVip
//                                     ? TKeys.warning_auto_payment_member
//                                         .translate()
//                                     : TKeys.warning_auto_payment.translate());
//                           },
//                         )),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return WillPopScope(
//         onWillPop: () async {
//           if (controller.bleState.value == BleStateEnum.isBeingStarted ||
//               controller.bleState.value ==
//                   BleStateEnum.waitingConnectPlugging) {
//             EasyLoading.showError(TKeys.charging_can_not_go_back.translate(),
//                 duration: const Duration(seconds: 5));
//             return false;
//           }
//           await controller.onBack(isBack: true);
//           await Future.delayed(const Duration(milliseconds: 500));
//           return true;
//         },
//         child: Obx(
//           () => PageLifecycle(
//             stateChanged: (bool appeared) {
//               if (appeared) {
//                 if (controller.bleState.value == BleStateEnum.isBeingStarted) {
//                   controller.onInitWhenBookingExist();
//                 } else if (controller.bleState.value ==
//                     BleStateEnum.chooseYourPlan) {
//                   if ((controller.timeBookingNow + 300) <
//                       (DateTime.now().millisecondsSinceEpoch ~/ 1000)) {
//                     controller.onBack(isBack: true);
//                     if (Get.currentRoute == "/charge_car") {
//                       controller.onBack(isBack: true);
//                     }
//                   }
//                 }
//               }
//             },
//             child: Scaffold(
//               backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//               appBar: AppBarCustom(
//                 leading: (controller.bleState.value ==
//                             BleStateEnum.waitingConnectPlugging ||
//                         controller.bleState.value ==
//                             BleStateEnum.isBeingStarted)
//                     ? const SizedBox()
//                     : null,
//                 actions: [
//                   if (controller.bleState.value == BleStateEnum.isBeingStarted)
//                     Row(
//                       children: [
//                         InkWell(
//                           customBorder: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           onTap: () async {
//                             var isOnBle = await FlutterBluePlus.isOn;
//                             if (!isOnBle) {
//                               EasyLoading.showInfo(TKeys.grant_ble.translate(),
//                                   duration: const Duration(seconds: 5));
//                               return;
//                             }
//                             if (!controller.isBleConnected.value) {
//                               controller.onCheckSatausHardWareWhenOFF();
//                             }
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.all(8.0),
//                             decoration: controller.isBleConnected.value
//                                 ? null
//                                 : BoxDecoration(
//                                     color: Theme.of(context)
//                                         .cardColor
//                                         .withOpacity(.3),
//                                     borderRadius: const BorderRadius.all(
//                                         Radius.circular(12.0))),
//                             child: Row(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   const Icon(Icons.bluetooth_connected),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     controller.isBleConnected.value
//                                         ? TKeys.connecting.translate()
//                                         : "${TKeys.disconnect.translate()} (${TKeys.touch_to_reconnect.translate()})",
//                                     textAlign: TextAlign.start,
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .bodyMedium!
//                                         .copyWith(
//                                             fontWeight: FontWeight.bold,
//                                             color:
//                                                 controller.isBleConnected.value
//                                                     ? null
//                                                     : Colors.red),
//                                   )
//                                 ]),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                       ],
//                     )
//                 ],
//                 title: Text(
//                   controller.bleState.value == BleStateEnum.isBeingStarted
//                       ? ""
//                       : TKeys.charge.translate(),
//                   style: Theme.of(context).textTheme.headlineSmall,
//                 ),
//               ),
//               body: controller.bleState.value == BleStateEnum.loading
//                   ? const Center(
//                       child: CircularProgressIndicatorCustom(),
//                     )
//                   : controller.bleState.value ==
//                           BleStateEnum.waitingConnectPlugging
//                       ? buildWaitingConnectPlugging(context)
//                       : controller.bleState.value == BleStateEnum.isBeingStarted
//                           ? buildIsBegingStarted(context)
//                           : controller.bleState.value ==
//                                   BleStateEnum.bleNotConnected
//                               ? buildGrantBluetoothPermisstion(context)
//                               : controller.bleState.value ==
//                                       BleStateEnum.connecting
//                                   ? buildConnecting()
//                                   : controller.bleState.value ==
//                                           BleStateEnum.chooseYourPlan
//                                       ? buildChooseSlotCharge(context)
//                                       : buildErrorWidget(),
//             ),
//           ),
//         ));
//   }

//   Padding buildWaitingConnectPlugging(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
//       child: Stack(
//         children: [
//           Text(controller.prettyDuration(controller.countDownPlugin.value)),
//           Column(
//             children: [
//               Image.asset("assets/images/ble_connecting.gif"),
//               Text(
//                 controller.isVip
//                     ? TKeys.pls_attaach_charger_to_vehicle_member.translate()
//                     : TKeys.pls_attaach_charger_to_vehicle.translate(),
//                 style: Theme.of(context).textTheme.headlineLarge,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Column buildConnecting() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Image.asset("assets/images/ble_connecting.gif"),
//         const SizedBox(height: 12),
//         Text(TKeys.connecting.translate())
//       ],
//     );
//   }

//   Padding buildGrantBluetoothPermisstion(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
//       child: Column(
//         children: [
//           Image.asset("assets/images/ble_connecting.gif"),
//           Text(
//             TKeys.grant_ble.translate(),
//             style: Theme.of(context).textTheme.headlineLarge,
//           ),
//           const Spacer(),
//           // ButtonPrimary(
//           //   TKeys.request_permission.translate(),
//           //   onPress: () => controller.onRequestBlePermission(),
//           // ),
//         ],
//       ),
//     );
//   }

//   Column buildErrorWidget() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Center(
//           child: ElevatedButton(
//             onPressed: () {},
//             style: ElevatedButton.styleFrom(
//               shape: const CircleBorder(),
//               padding: const EdgeInsets.all(20),
//               backgroundColor: Colors.blue, // <-- Button color
//               foregroundColor: Colors.red, // <-- Splash color
//             ),
//             child: const Icon(Icons.close, size: 48, color: Colors.redAccent),
//           ),
//         ),
//         const SizedBox(height: 24),
//         Text(controller.rawString),
//         Text(controller.exception),
//       ],
//     );
//   }

//   letCancelBooking(BuildContext cxt) {
//     return showDialog<void>(
//       context: cxt,
//       barrierDismissible: false, // user must tap button!
//       builder: (BuildContext context) {
//         return AlertDialog(
//           actionsAlignment: MainAxisAlignment.spaceBetween,
//           actionsOverflowAlignment: OverflowBarAlignment.center,
//           title: Text(
//             TKeys.cofirm_charge.translate(),
//             textAlign: TextAlign.center,
//             style: Theme.of(context)
//                 .textTheme
//                 .titleLarge!
//                 .copyWith(fontWeight: FontWeight.bold),
//           ),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 Column(
//                   children: [
//                     Text(
//                       TKeys.time_is_still.translate(),
//                       textAlign: TextAlign.center,
//                       style: Theme.of(context)
//                           .textTheme
//                           .bodyMedium!
//                           .copyWith(fontSize: 12),
//                     ),
//                     Text(
//                       controller.getTimeStill,
//                       textAlign: TextAlign.center,
//                       style: Theme.of(context)
//                           .textTheme
//                           .bodyMedium!
//                           .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                     Text(
//                       controller.isVip
//                           ? TKeys.are_you_sure_want_to_end_member.translate()
//                           : TKeys.are_you_sure_want_to_end.translate(),
//                       textAlign: TextAlign.center,
//                       style: Theme.of(context)
//                           .textTheme
//                           .bodyMedium!
//                           .copyWith(fontSize: 12),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text(TKeys.no.translate(),
//                   style: Theme.of(context).textTheme.bodyMedium),
//               onPressed: () {
//                 Get.back();
//               },
//             ),
//             TextButton(
//               onPressed: controller.isShowButtonCancel.value
//                   ? () async {
//                       Get.back();
//                       var isComplete = await controller.onBookingComplete();
//                       if (isComplete != null) {
//                         EasyLoading.showSuccess(
//                             TKeys.complete_charging_end_processing.translate(),
//                             duration: const Duration(seconds: 5));
//                         // ref.read(homeProvider.notifier).isInit = true;
//                         // ref.read(homeProvider.notifier).initData();
//                       }
//                     }
//                   : null,
//               child: Text(TKeys.yes.translate(),
//                   style: Theme.of(context).textTheme.bodyMedium),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   letOpenHardware(BuildContext cxt) {
//     bool isCalled = true;
//     return showDialog<void>(
//       context: cxt,
//       barrierDismissible: false, // user must tap button!
//       builder: (BuildContext context) {
//         return AlertDialog(
//           actionsAlignment: MainAxisAlignment.center,
//           actionsOverflowAlignment: OverflowBarAlignment.center,
//           title: Text(
//             TKeys.notice.translate(),
//             textAlign: TextAlign.center,
//             style: Theme.of(context)
//                 .textTheme
//                 .titleLarge!
//                 .copyWith(fontWeight: FontWeight.bold),
//           ),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 Text(
//                   controller.isVip
//                       ? TKeys.pls_attaach_charger_to_vehicle_member.translate()
//                       : TKeys.pls_attaach_charger_to_vehicle.translate(),
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.bodyMedium,
//                 ),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text(TKeys.yes.translate(),
//                   style: Theme.of(context).textTheme.bodyMedium),
//               onPressed: () async {
//                 try {
//                   if (isCalled) {
//                     isCalled = false;
//                     if (!(await controller.isConnectedHardware())) {
//                       EasyLoading.showError(TKeys.grant_ble.translate());
//                       return;
//                     } else {
//                       Navigator.pop(context);
//                       await controller.openHardware();
//                     }
//                   }
//                 } finally {
//                   isCalled = true;
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
