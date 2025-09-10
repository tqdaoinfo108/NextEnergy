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
import 'payment_webview_bottomsheet.dart';

Widget buildChooseSlotCharge(
    BuildContext context, ChargeCarController controller) {
  return Obx(
    () => SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.95),
            ],
          ),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    
                    // Header với countdown
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Countdown(
                              controller: controller.countdownController,
                              seconds: 300,
                              build: (BuildContext context, double time) => Text(
                                "${TKeys.time_remaining.translate()} ${time.toInt()}s",
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Title
                    Text(
                      TKeys.choose_your_plant.translate(),
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    Text(
                      controller.isVip 
                          ? "Chọn thời gian sạc phù hợp với bạn"
                          : "Chọn gói sạc và thời gian phù hợp",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Price list
                    controller.listPrice.isEmpty
                        ? Container(
                            height: 200,
                            child: const Center(
                              child: CircularProgressIndicatorCustom(),
                            ),
                          )
                        : Column(
                            children: [
                              // Modern price list
                              _buildPriceList(context, controller),
                            ],
                          ),
                    const SizedBox(height: 120),
                  ]),
            ),
            
            // Bottom action buttons
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Selected price summary
                    if (controller.currentPrice.value.priceID != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.electric_bolt,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                controller.isVip
                                    ? "Thời gian: ${controller.currentPrice.value.priceTime} phút"
                                    : "Gói: ${controller.currentPrice.value.priceTime} phút - ${controller.currentPrice.value.unitPrice}${controller.currentPrice.value.priceAmount}",
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Action buttons
                    SizedBox(
                      height: 56,
                      child: Row(
                        children: [
                          Expanded(
                              child: ButtonPrimaryOutline(TKeys.cancel.translate(),
                                  () async {
                            controller.back();
                          })),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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

// Build modern price list widget
Widget _buildPriceList(BuildContext context, ChargeCarController controller) {
  return Container(
    height: Get.height * 0.45,
    child: ListView.builder(
      itemCount: controller.listPrice.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final item = controller.listPrice[index];
        final isSelected = item == controller.currentPrice.value;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => controller.onChangePrice(item),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    else
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    // Time icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.access_time,
                        color: isSelected 
                            ? Colors.white
                            : Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Time and price info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${item.priceTime} phút",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          
                          if (!controller.isVip && item.priceAmount != null)
                            const SizedBox(height: 4),
                          
                          if (!controller.isVip && item.priceAmount != null)
                            Row(
                              children: [
                                Icon(
                                  Icons.payments,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${item.unitPrice}${item.priceAmount}",
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: isSelected 
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          
                          if (controller.isVip)
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "VIP Member",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.amber.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    
                    // Selection indicator
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: !isSelected 
                            ? Border.all(
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                              )
                            : null,
                      ),
                      child: Icon(
                        isSelected ? Icons.check : Icons.radio_button_unchecked,
                        color: isSelected 
                            ? Colors.white
                            : Theme.of(context).colorScheme.outline,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
