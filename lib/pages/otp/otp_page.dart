import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:v2/pages/otp/otp_controller.dart';
import 'package:v2/services/base_hive.dart';
import 'package:v2/services/localization_service.dart';

import '../../utils/const.dart';
import '../customs/appbar.dart';
import '../customs/count_down.dart';
import '../login/login_controller.dart';

class OTPPage extends GetView<OtpController> {
  const OTPPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
          fontSize: 20,
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(
            color: const Color.fromARGB(255, 88, 95, 102).withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 1),
      ),
    );
    return Obx(() => Scaffold(
          appBar: AppBarCustom(
            title: Text(
              "",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          body: SafeArea(
            child: controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                :  Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(TKeys.verification.translate(),
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge!
                                .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor)),
                        const SizedBox(height: 16),
                        Text(TKeys.enter_the_code_sent_to_my_phone.translate(),
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    color: Theme.of(context)
                                        .iconTheme
                                        .color!
                                        .withOpacity(0.6))),
                        const SizedBox(height: 8),
                        Text(
                            "+${controller.userModel.phoneArea} ${controller.userModel.uUserID}",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 32),
                        Pinput(
                            defaultPinTheme: defaultPinTheme,
                            focusedPinTheme: focusedPinTheme,
                            submittedPinTheme: submittedPinTheme,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            validator: (s) {
                              return controller.validateOTP(s ?? "")
                                  ? null
                                  : TKeys.invalid_pin_code.translate();
                            },
                            pinputAutovalidateMode:
                                PinputAutovalidateMode.onSubmit,
                            showCursor: true,
                            onCompleted: (pin) {
                              if (controller.validateOTP(pin)) {
                                HiveHelper.remove(Constants.COUNT_OTP);
                                Get.offAndToNamed(
                                    controller.userModel.loginType ==
                                            LoginType.register
                                        ? "/login_profile"
                                        : "/profile_change_pass",
                                    arguments: controller.userModel);
                              }
                            }),
                        const SizedBox(height: 32),
                        Text(TKeys.didnt_recieve_code.translate(),
                            style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 8),
                        if (!controller.isResend.value)
                          Countdown(
                              controller: controller.countdownController,
                              seconds: 120,
                              build: (BuildContext context, double time) =>
                                  Text(time.toInt().toString()),
                              interval: const Duration(seconds: 1),
                              onFinished: () {
                                controller.onChageIsResend(true);
                              }),
                        GestureDetector(
                          onTap: () async {
                            if (controller.isResend.value) {
                              var isSent = await controller.onCallReSend();
                              if (isSent) {
                                EasyLoading.showSuccess(
                                    TKeys.success.translate(),
                                    duration: const Duration(seconds: 5));
                              } else {
                                EasyLoading.showError(TKeys.fail.translate(),
                                    duration: const Duration(seconds: 5));
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(TKeys.resend.translate(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: controller.isResend.value
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context)
                                                .iconTheme
                                                .color!
                                                .withOpacity(0.3))),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ));
  }
}
