import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:v2/pages/chagre_car/charge_car_controller.dart';
import 'package:v2/pages/customs/button.dart';
import 'package:v2/utils/const.dart';

import '../../../model/payment_model.dart';
import '../../../model/response_base.dart';
import '../../../services/localization_service.dart';
import '../../customs/circular_progress_indicator.dart';
import '../../customs/count_down.dart';
import '../../customs/dialog_custom.dart';
import '../../customs/spinner_item_selector_widget.dart';
import 'payment_webview_bottomsheet.dart';

Widget buildChooseSlotCharge(
    BuildContext context, ChargeCarController controller) {
  return Obx(
    () => SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Countdown(
                        controller: controller.countdownController,
                        seconds: 300,
                        build: (BuildContext context, double time) => Text(
                            "${TKeys.time_remaining.translate()} ${time.toInt()}"),
                        interval: const Duration(seconds: 1),
                        onFinished: () async {
                          if (controller.pageEnum.value ==
                              ChargeCarPageEnum.CHOOSE_TIME) {
                            EasyLoading.showError(
                                TKeys.on_back_300s_message.translate(),
                                duration: const Duration(seconds: 5));
                            await controller.back();
                            if (Get.currentRoute == "/charge_car") {
                              await controller.back();
                            }
                          }
                        }),
                    const SizedBox(height: 12),
                    Text(
                      TKeys.choose_your_plant.translate(),
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 12),
                    controller.listPrice.isEmpty
                        ? const CircularProgressIndicatorCustom()
                        : Column(
                            children: [
                              SpinnerItemSelector(
                                items: controller.listPrice,
                                selectedItemToWidget: (item) =>
                                    ButtonPriceOutline(
                                  "${item.priceTime}",
                                  () {
                                    controller.onChangePrice(item);
                                  },
                                  item == controller.currentPrice.value,
                                  subString: controller.isVip
                                      ? null
                                      : "${item.unitPrice}${item.priceAmount}",
                                ),
                                nonSelectedItemToWidget: (item) => Opacity(
                                  opacity: 0.4,
                                  child: ButtonPriceOutline(
                                    "${item.priceTime}",
                                    () {
                                      // controller.onChangePrice(item);
                                    },
                                    item == controller.currentPrice.value,
                                    subString: controller.isVip
                                        ? null
                                        : "${item.unitPrice}${item.priceAmount}",
                                  ),
                                ),
                                itemHeight: 100,
                                height: Get.height / 3 * 2,
                                width: Get.width,
                                itemWidth: Get.width,
                                onSelectedItemChanged: ((item) {
                                  controller.onChangePrice(item);
                                }),
                                spinnerBgColor: Colors.white,
                              ),
                            ],
                          ),
                    const SizedBox(height: 78),
                  ]),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 56,
                  child: Row(
                    children: [
                      Expanded(
                          child: ButtonPrimaryOutline(TKeys.cancel.translate(),
                              () async {
                        controller.back();
                      })),
                      const SizedBox(width: 8),
                      Expanded(
                          child: ButtonPrimary(
                        controller.isVip
                            ? TKeys.start_member.translate()
                            : TKeys.start.translate(),
                        onPress: () async {
                          if (controller.currentPrice.value.priceID == null) {
                            EasyLoading.showError(
                                TKeys.no_select_time.translate(),
                                duration: const Duration(seconds: 5));
                            return;
                          }
                          showDialogAutoPaymentCustom(context, () async {
                            if (!controller.isAvailable) {
                              EasyLoading.showInfo(
                                  TKeys.fail_again2.translate());
                              return false;
                            }
                            // is vip payment
                            if (controller.isVip) {
                              await controller.onBookingPayment();
                              if (controller.paymentData != null &&
                                  controller.paymentData!.paymentKey!.isEmpty) {
                                // Thanh toán vip member
                                // ignore: use_build_context_synchronously
                                letOpenHardware(context, controller);
                              } else {
                                // ignore: use_build_context_synchronously
                                EasyLoading.showError(
                                    TKeys.fail_again2.translate(),
                                    duration: const Duration(seconds: 5));
                              }
                            } else {
                              // thanh toán = visa
                              var result = await controller.onBookingPayment();

                              if (result != null) {
                                // Kiểm tra nếu có reqRedirectionUri thì hiển thị bottomsheet
                                if (result.reqRedirectionUri != null && 
                                    result.reqRedirectionUri!.isNotEmpty) {
                                  // ignore: use_build_context_synchronously
                                  final paymentResult = await showPaymentBottomSheet(
                                    context: context,
                                    url: result.reqRedirectionUri!,
                                    onPaymentComplete: () {
                                      // Thanh toán thành công, tiếp tục với quy trình
                                      debugPrint('Payment completed successfully');
                                    },
                                    onPaymentCancelled: () {
                                      // Thanh toán bị hủy
                                      EasyLoading.showInfo('Thanh toán đã bị hủy');
                                    },
                                  );

                                  if (paymentResult == true) {
                                    // Thanh toán thành công, tiếp tục với hardware
                                    controller.setPaymentData(
                                        ResponseBase<PaymentModel>(data: result));
                                    // ignore: use_build_context_synchronously
                                    await letOpenHardware(context, controller);
                                  }
                                } else {
                                  // Không có reqRedirectionUri, xử lý bình thường
                                  controller.setPaymentData(
                                      ResponseBase<PaymentModel>(data: result));
                                  // ignore: use_build_context_synchronously
                                  await letOpenHardware(context, controller);
                                }
                              } else {
                                // back ra do hết giờ hoặc thất bại
                                //  if ((controller.timeBookingNow + 300) <
                                //       (DateTime.now().millisecondsSinceEpoch ~/
                                //           1000)) {
                                //     Get.back(result: false);
                                //   } else {
                                //     if (!controller.isAvailable) {
                                //       controller.back();
                                //       EasyLoading.showError(
                                //           // ignore: use_build_context_synchronously
                                //           TKeys.fail_again2.translate(),
                                //           duration: const Duration(seconds: 5));
                                //     }
                                //   }
                              }
                            }
                          },
                              text: controller.isVip
                                  ? TKeys.warning_auto_payment_member
                                      .translate()
                                  : TKeys.warning_auto_payment.translate());
                        },
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

letOpenHardware(BuildContext cxt, ChargeCarController controller) {
  bool isCalled = true;
  return showDialog<void>(
    context: cxt,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        actionsAlignment: MainAxisAlignment.center,
        actionsOverflowAlignment: OverflowBarAlignment.center,
        title: Text(
          TKeys.notice.translate(),
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                controller.isVip
                    ? TKeys.pls_attaach_charger_to_vehicle_member.translate()
                    : TKeys.pls_attaach_charger_to_vehicle.translate(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(TKeys.yes.translate(),
                style: Theme.of(context).textTheme.bodyMedium),
            onPressed: () async {
              try {
                if (isCalled) {
                  isCalled = false;
                  if (!controller.isAvailable) {
                    EasyLoading.showError(TKeys.grant_ble.translate());
                    return;
                  } else {
                    Navigator.pop(context);
                    await controller.openHardware().then((value) {
                      // if (!value) {
                      //   controller.onUpdateAffterHardware(-1);
                      //   EasyLoading.showError(
                      //       TKeys.booking_failed_to_not_begin_connect
                      //           .translate(),
                      //       duration: const Duration(seconds: 5));
                      //   controller.back();
                      // }
                    });
                  }
                }
              } finally {
                isCalled = true;
              }
            },
          ),
        ],
      );
    },
  );
}
