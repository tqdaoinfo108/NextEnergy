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

Widget buildChooseSlotCharge(BuildContext context, ChargeCarController controller) {
  return Obx(() => Scaffold(
    backgroundColor: const Color(0xFFF6FDF8), // App background color
    body: SafeArea(
      child: Column(
        children: [
          // Header với gradient
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF059669), // Primary green
                  const Color(0xFF10B981), // Secondary green
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF059669).withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                children: [
                  // Header row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: const Icon(Icons.ev_station, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              TKeys.choose_your_plant.translate(),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller.isVip ? TKeys.premium_member.translate() : TKeys.account.translate(),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Timer card - chỉ hiển thị thời gian chọn
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer, color: Colors.white, size: 20),
                          const SizedBox(width: 12),
                          Countdown(
                            controller: controller.countdownController,
                            seconds: 300,
                            build: (BuildContext context, double time) => Text(
                              "${time.toInt()}s",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            interval: const Duration(seconds: 1),
                            onFinished: () async {
                              if (controller.pageEnum.value == ChargeCarPageEnum.CHOOSE_TIME) {
                                EasyLoading.showError(TKeys.on_back_300s_message.translate(), duration: const Duration(seconds: 5));
                                await controller.back();
                                if (Get.currentRoute == "/charge_car") {
                                  await controller.back();
                                }
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          Text(
                            TKeys.time_remaining.translate(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
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
          const SizedBox(height: 16),
          // Content area
          Expanded(
            child: Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtitle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      controller.isVip
                          ? TKeys.choose_your_plant.translate()
                          : TKeys.choose_your_plant.translate(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Price list
                  Expanded(
                    child: controller.listPrice.isEmpty
                        ? const Center(child: CircularProgressIndicatorCustom())
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: controller.listPrice.length,
                            itemBuilder: (context, index) {
                              final item = controller.listPrice[index];
                              final isSelected = item == controller.currentPrice.value;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () => controller.onChangePrice(item),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFF059669) : Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isSelected 
                                              ? const Color(0xFF059669)
                                              : const Color(0xFFE0E0E0),
                                          width: isSelected ? 2 : 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isSelected 
                                                ? const Color(0xFF059669).withOpacity(0.2)
                                                : Colors.black.withOpacity(0.05),
                                            blurRadius: isSelected ? 8 : 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          // Icon container (smaller)
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: isSelected 
                                                  ? Colors.white.withOpacity(0.2)
                                                  : const Color(0xFF059669).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.electric_bolt,
                                              color: isSelected ? Colors.white : const Color(0xFF059669),
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          // Content
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${item.priceTime} ${TKeys.hours.translate()}",
                                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: isSelected ? Colors.white : const Color(0xFF222B45),
                                                  ),
                                                ),
                                                if (!controller.isVip && item.priceAmount != null) ...[
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    "${formatCurrency(item.priceAmount)} ${item.unitPrice}",
                                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                      color: isSelected 
                                                          ? Colors.white.withOpacity(0.9)
                                                          : const Color(0xFF6B7280),
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                                if (controller.isVip) ...[
                                                  const SizedBox(height: 2),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.star, size: 14, color: Colors.amber.shade700),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        TKeys.premium_member.translate(),
                                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                          color: Colors.amber.shade700,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          // Selection indicator (smaller)
                                          AnimatedContainer(
                                            duration: const Duration(milliseconds: 300),
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: isSelected ? Colors.white : Colors.transparent,
                                              borderRadius: BorderRadius.circular(8),
                                              border: !isSelected 
                                                  ? Border.all(color: const Color(0xFFE0E0E0))
                                                  : null,
                                            ),
                                            child: Icon(
                                              isSelected ? Icons.check : Icons.radio_button_unchecked,
                                              color: isSelected ? const Color(0xFF059669) : const Color(0xFF6B7280),
                                              size: 18,
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
                  ),
                ],
              ),
            ),
          ),
          // Bottom section with action buttons
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Selected plan summary (compact)
                    if (controller.currentPrice.value.priceID != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF059669).withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            // Small icon
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF059669),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.electric_bolt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${TKeys.buy.translate()}: ${controller.currentPrice.value.priceTime} ${TKeys.hours.translate()}",
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: const Color(0xFF059669),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (!controller.isVip && controller.currentPrice.value.priceAmount != null)
                                    Text(
                                      "${formatCurrency(controller.currentPrice.value.priceAmount)} ${controller.currentPrice.value.unitPrice}",
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: const Color(0xFF6B7280),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // VIP badge if applicable
                            if (controller.isVip)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "VIP",
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.amber.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    // Action buttons row
                    Row(
                      children: [
                        // Cancel button
                        Expanded(
                          flex: 1,
                          child: ButtonPrimaryOutline(
                            TKeys.cancel.translate(),
                            () async {
                              controller.back();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Payment/Start button
                        Expanded(
                          flex: 2,
                          child: ButtonPrimary(
                            controller.isVip ? TKeys.start_member.translate() : TKeys.start.translate(),
                            onPress: () async {
                              if (controller.currentPrice.value.priceID == null) {
                                EasyLoading.showError(TKeys.no_select_time.translate(), duration: const Duration(seconds: 5));
                                return;
                              }
                              showDialogAutoPaymentCustom(context, () async {
                                if (!controller.isAvailable) {
                                  EasyLoading.showInfo(TKeys.fail_again2.translate());
                                  return false;
                                }
                                // is vip payment
                                if (controller.isVip) {
                                  await controller.onBookingPayment();
                                  if (controller.paymentData != null && controller.paymentData!.paymentKey!.isEmpty) {
                                    letOpenHardware(context, controller);
                                  } else {
                                    EasyLoading.showError(TKeys.fail_again2.translate(), duration: const Duration(seconds: 5));
                                  }
                                } else {
                                  var result = await controller.onBookingPayment();
                                  if (result != null) {
                                    if (result.reqRedirectionUri != null && result.reqRedirectionUri!.isNotEmpty) {
                                      final paymentResult = await showPaymentBottomSheet(
                                        context: context,
                                        url: result.reqRedirectionUri!,
                                        onPaymentComplete: () {
                                          debugPrint('Payment completed successfully');
                                        },
                                        onPaymentCancelled: () {
                                          EasyLoading.showInfo(TKeys.cancel.translate());
                                        },
                                      );
                                      if (paymentResult == true) {
                                        controller.setPaymentData(ResponseBase<PaymentModel>(data: result));
                                        await letOpenHardware(context, controller);
                                      }
                                    } else {
                                      controller.setPaymentData(ResponseBase<PaymentModel>(data: result));
                                      await letOpenHardware(context, controller);
                                    }
                                  }
                                }
                              },
                                text: controller.isVip ? TKeys.warning_auto_payment_member.translate() : TKeys.warning_auto_payment.translate(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ));
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
String formatCurrency(num? value) {
  if (value == null) return "0";
  final str = value.toStringAsFixed(0);
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    buffer.write(str[str.length - i - 1]);
    if ((i + 1) % 3 == 0 && i != str.length - 1) buffer.write('.');
  }
  return buffer.toString().split('').reversed.join('');
}
