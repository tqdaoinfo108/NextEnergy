import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:v2/model/price_model.dart';
import 'package:v2/pages/chagre_car/charge_car_controller.dart';

import '../../model/payment_model.dart';
import '../../services/localization_service.dart';
import 'widget/payment_webview_bottomsheet.dart';

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
    return Obx(() => Scaffold(
          backgroundColor: const Color(0xFFF6FDF8), // App background color
          body: SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              controller: scrollController,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back button
                            IconButton(
                              onPressed: () => Get.back(),
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            // Title
                            Text(
                              TKeys.choose_your_plant.translate(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            // Account type indicator
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    controller.isVip
                                        ? Icons.star
                                        : Icons.person,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    controller.isVip
                                        ? TKeys.premium_member.translate()
                                        : TKeys.account.translate(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtitle
                      Text(
                        TKeys.time_remaining.translate(),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF222B45),
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        TKeys.warning_auto_payment.translate(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF6B7280),
                            ),
                      ),
                      const SizedBox(height: 24),

                      // Price options
                      ...controller.listPrice
                          .map((item) => _buildPriceOption(item, context)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildPriceOption(PriceModel item, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            if (!controller.isAvailable) return;

            Get.back();

            // Logic mới: Kiểm tra isVip -> isUseInput
            if (controller.isVip) {
              // ✅ VIP: Sử dụng VIP payment
              var paymentKey =
                  await controller.getPaymentKeyExtTimeBooking(item.priceID!);
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
                            paymentID: paymentKey.paymentID); // thành công
                    if (responseNewTime != null &&
                        responseNewTime.data != null) {
                      controller.setPaymentData(responseNewTime);
                    }
                  } else {
                    // reject booking
                    await controller.onUpdateAffterHardware(-1,
                        isExtTime: true,
                        paymentID: paymentKey.paymentID); // thất bại
                    EasyLoading.showError(TKeys.fail.translate(),
                        duration: const Duration(seconds: 5));
                  }
                });
                controller.onInitExtBooking();
              }
            } else {
              // ❌ Không VIP: Kiểm tra isUseInput
              bool isUseInput = item.isUseInput ?? false;
              
              PaymentModel? result =
                  await controller.getPaymentKeyExtTimeBooking(item.priceID!);

              if (result != null) {
                if (isUseInput) {
                  // ✅ UseInput = true: Gọi auto payment -> Extend hardware (không cần QR)
                  print("💳 Using input payment method for extend time");
                  await controller
                      .extTimeHardware(item.priceTime!)
                      .then((isOK) async {
                    if (isOK) {
                      var responseNewTime =
                          await controller.onUpdateAffterHardware(1,
                              isExtTime: true,
                              paymentID: result.paymentID); // thành công
                      if (responseNewTime != null &&
                          responseNewTime.data != null) {
                        controller.setPaymentData(responseNewTime);
                      }
                    } else {
                      // reject booking
                      await controller.onUpdateAffterHardware(-1,
                          isExtTime: true,
                          paymentID: result.paymentID); // thất bại
                      EasyLoading.showError(TKeys.fail.translate(),
                          duration: const Duration(seconds: 5));
                    }
                  });
                } else {
                  // ❌ UseInput = false: Sử dụng QR Code payment
                  print("📱 Using QR Code payment method for extend time");
                  if (result.reqRedirectionUri != null &&
                      result.reqRedirectionUri!.isNotEmpty) {
                    final paymentResult = await showPaymentBottomSheet(
                      context: cxt, // ✅ Sử dụng cxt thay vì Get.context
                      url: result.reqRedirectionUri!,
                      onPaymentComplete: () {
                        debugPrint('Payment completed successfully');
                      },
                      onPaymentCancelled: () {
                        EasyLoading.showInfo(TKeys.cancel.translate());
                      },
                    );

                    if (paymentResult == true) {
                      await controller
                          .extTimeHardware(item.priceTime!)
                          .then((isOK) async {
                        if (isOK) {
                          var responseNewTime =
                              await controller.onUpdateAffterHardware(1,
                                  isExtTime: true,
                                  paymentID: result.paymentID); // thành công
                          if (responseNewTime != null &&
                              responseNewTime.data != null) {
                            controller.setPaymentData(responseNewTime);
                          }
                        } else {
                          // reject booking
                          await controller.onUpdateAffterHardware(-1,
                              isExtTime: true,
                              paymentID: result.paymentID); // thất bại
                          EasyLoading.showError(TKeys.fail.translate(),
                              duration: const Duration(seconds: 5));
                        }
                      });
                    } else {
                      // reject booking
                      await controller.onUpdateAffterHardware(-1,
                          isExtTime: true,
                          paymentID: result.paymentID); // thất bại
                      EasyLoading.showError(TKeys.fail.translate(),
                          duration: const Duration(seconds: 5));
                    }
                  } else {
                    // Fallback: Không có QR URL
                    EasyLoading.showError(TKeys.fail.translate(),
                        duration: const Duration(seconds: 5));
                  }
                }
              }
            }

            controller.onInitExtBooking();
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Time info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${item.priceTime} ${TKeys.hours.translate()}",
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF222B45),
                                ),
                      ),
                      if (!controller.isVip && item.priceAmount != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          "${formatCurrency(item.priceAmount)} ${item.unitPrice}",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF6B7280),
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                      // Badge hiển thị payment method
                      const SizedBox(height: 6),
                      if (controller.isVip)
                        Row(
                          children: [
                            Icon(Icons.star,
                                size: 14, color: Colors.amber.shade700),
                            const SizedBox(width: 4),
                            Text(
                              TKeys.premium_member.translate(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.amber.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        )
                      else if (item.isUseInput == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFF10B981).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.account_balance_wallet,
                                size: 12,
                                color: const Color(0xFF10B981),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Thanh toán tài khoản",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: const Color(0xFF10B981),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                              ),
                            ],
                          ),
                        )
                      else
                        Row(
                          children: [
                            Icon(
                              Icons.qr_code,
                              size: 12,
                              color: const Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Thanh toán QR Code",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: const Color(0xFF6B7280),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // Action button
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF059669),
                        const Color(0xFF10B981),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF059669).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        controller.isVip
                            ? TKeys.yes.translate()
                            : TKeys.buy.translate(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
}
