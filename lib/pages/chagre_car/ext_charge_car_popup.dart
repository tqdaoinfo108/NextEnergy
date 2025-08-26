import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:v2/model/price_model.dart';
import 'package:v2/model/response_base.dart';
import 'package:v2/pages/chagre_car/charge_car_controller.dart';
import 'package:v2/pages/customs/button.dart';

import '../../model/payment_model.dart';
import '../../services/localization_service.dart';
import '../payment/payment_3ds_page.dart';

class ExtTimeChargeCarBottomSheet extends StatelessWidget {
  final ScrollController scrollController;
  final double bottomSheetOffset;
  final BuildContext cxt;
  final ChargeCarController controller;

  const ExtTimeChargeCarBottomSheet({
    required this.scrollController,
    required this.bottomSheetOffset,
    required this.cxt,
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Padding buildItemLocation(PriceModel item, BuildContext context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Divider(
                  color: Theme.of(context).iconTheme.color!.withOpacity(0.4),
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "${item.priceTime} ${TKeys.hours.translate()}",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 4,
                  child: ButtonPrimary(
                      controller.isVip
                          ? "${item.unitPrice} 0"
                          : "${item.unitPrice} ${item.priceAmount?.toInt()}",
                      onPress: () async {
                    if (!controller.isAvailable) return;

                    Get.back();

                    // kiểm tra có VIP không ?
                    if (controller.isVip) {
                      var paymentKey = await controller
                          .getPaymentKeyExtTimeBooking(item.priceID!);
                      if (paymentKey != null) {
                        // Thanh toán vip member
                        await controller
                            .extTimeHardware(item.priceTime!)
                            .then((isOK) async {
                          if (isOK) {
                            // cập nhật and update time
                            var responseNewTime =
                                await controller.onUpdateAffterHardware(1,
                                    isExtTime: true,
                                    paymentID:
                                        paymentKey.paymentID); // thành công
                            if (responseNewTime != null &&
                                responseNewTime.data != null) {
                              controller.setPaymentData(responseNewTime);
                            }
                          } else {
                            // reject booking
                            await controller.onUpdateAffterHardware(-1,
                                isExtTime: true,
                                paymentID: paymentKey.paymentID); // thất bại
                            // ignore: prefer_const_constructors
                            EasyLoading.showError(TKeys.fail.translate(),
                                duration: const Duration(seconds: 5));
                          }
                        });
                        controller.onInitExtBooking();
                      }
                    } else {
                      //--------------------------------------------------- thanh toán visa
                      // var result = await Get.dialog(
                      //   const Payment3DSPage(),
                      //   arguments: PaymentDtoModel(
                      //       controller.bleResponseModel?.myId ??
                      //           controller.bookingData!.hardwareID!,
                      //       item.priceID!,
                      //       controller.bookingData?.bookID,
                      //       true,
                      //       timeNow: 0),
                      //   barrierDismissible: false,
                      // );

                      // if (result != null &&
                      //     (result as ResponseBase<PaymentModel>?) != null) {
                      //   /// Thanh toán thành công

                      //   // Bật thiết bị lên
                      //   await controller.onUpdatePayment(1,
                      //       paymentID: result!.data!.paymentID!); // thành công

                      //   await controller
                      //       .extTimeHardware(item.priceTime)
                      //       .then((isOK) async {
                      //     if (isOK) {
                      //       // cập nhật and update time
                      //       var responseNewTime =
                      //           await controller.onUpdateAffterHardware(1,
                      //               isExtTime: true,
                      //               paymentID:
                      //                   result.data!.paymentID); // thành công
                      //       if (responseNewTime != null &&
                      //           responseNewTime.data != null) {
                      //         controller.setPaymentData(responseNewTime);
                      //       }
                      //     } else {
                      //       // reject booking
                      //       await controller.onUpdateAffterHardware(-1,
                      //           isExtTime: true,
                      //           paymentID: result.data!.paymentID); // thất bại
                      //     }
                      //   });
                      // }
                      controller.onInitExtBooking();
                    }
                  }),
                ),
              ],
            ),
            SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Divider(
                  color: Theme.of(context).iconTheme.color!.withOpacity(0.4),
                )),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.zero,
      controller: scrollController,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 12),
            child: Text(
              TKeys.choose_your_plant.translate(),
              style: Theme.of(context).textTheme.titleLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              for (PriceModel item in controller.listPrice)
                buildItemLocation(item, context)
            ]),
          )
        ]),
      ],
    );
  }
}
