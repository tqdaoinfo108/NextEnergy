import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:v2/pages/customs/textfield_custom.dart';
import 'package:v2/pages/login/login_controller.dart';
import 'package:v2/services/localization_service.dart';

import '../../model/response_base.dart';
import '../../model/user_model.dart';
import '../customs/appbar.dart';
import '../customs/button.dart';
import 'widget/phone_form_field_custom.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>(debugLabel: '_childWidgetKey3');
    return Obx(() => Scaffold(
          appBar: !controller.isLogin.value
              ? AppBarCustom(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  leading: IconButton(
                    onPressed: () {
                      controller.changeModeLogin(LoginType.forgetPassword);
                    },
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ))
              : null,
          body: SafeArea(
            child: controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!controller.isLogin.value)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    controller.typeRequestOTP ==
                                            LoginType.forgetPassword
                                        ? TKeys.forget_password_string
                                            .translate()
                                        : TKeys.create_account_string
                                            .translate(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge!
                                        .copyWith(
                                            fontSize: 18,
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold)),
                                const SizedBox(height: 40)
                              ],
                            ),
                          PhoneFormFieldCustom(
                            key: const Key('phone-field'),
                            controller: controller.phoneController,
                            decoration: InputDecoration(
                              fillColor: Colors.transparent,
                              hintText: "xxx xxx xxxx",
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    style: BorderStyle.solid,
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.3)),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    style: BorderStyle.solid,
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.6)),
                              ),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    style: BorderStyle.solid,
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.3)),
                              ),
                            ),
                            validator: PhoneValidator.compose([
                              // PhoneValidator.valid(context,
                              //     errorText:
                              //         TKeys.field_format_invalid.translate()),
                              // PhoneValidator.valid(context),
                              (phoneNumber) {
                                if (isPhoneValid(phoneNumber)) {
                                  return null;
                                }
                                return TKeys.field_format_invalid.translate();
                              }
                            ]),
                            isCountrySelectionEnabled: true,
                            countrySelectorNavigator:
                                const CountrySelectorNavigator
                                    .draggableBottomSheet(
                                    countries: [IsoCode.VN]),
                            showFlagInInput: false,
                            autofillHints: const [
                              AutofillHints.telephoneNumber
                            ],
                            showDialCode: true,
                            enabled: true,
                            onSaved: (p) => controller.onChangePhoneValue(p),
                            onChanged: (p) => controller.onChangePhoneValue(p),
                            autovalidateMode: AutovalidateMode.disabled,
                            autocorrect: false,
                          ),
                          if (controller.isLogin.value)
                            const SizedBox(height: 6),
                          if (controller.isLogin.value)
                            TextFieldCustom(
                              TKeys.password.translate(),
                              obscureText: true,
                              validator: (s) {
                                if (s == null || s.isEmpty) {
                                  return TKeys.dont_blank.translate();
                                }
                                if (s.length < 6 || s.length > 32) {
                                  return TKeys.more_than_6.translate();
                                }
                              },
                              onChange: (s) =>
                                  controller.onChangePasswordValue(s ?? ""),
                            ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () => controller
                                    .changeModeLogin(LoginType.forgetPassword),
                                child: Text(
                                    controller.isLogin.value
                                        ? TKeys.forget_password.translate()
                                        : controller
                                            .textForgetPasswordString.value,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          ButtonPrimary(
                            controller.isLogin.value
                                ? TKeys.confirm.translate()
                                : controller.textConfirmString.value,
                            onPress: () async {
                              if (!formKey.currentState!.validate() ||
                                  !isPhoneValid(
                                      controller.phoneController.value)) {
                                // EasyLoading.showError(TKeys.fail.translate(),
                                //     duration: const Duration(seconds: 5));
                                return;
                              }
                              ResponseBase<UserModel>? isLogin =
                                  await controller.letLogin();

                              if (controller.isLogin.value) {
                                if (isLogin != null && isLogin.data != null) {
                                  // ignore: use_build_context_synchronously

                                  Get.offAndToNamed("/home");
                                  Get.updateLocale(Locale(
                                      isLogin.data?.languageCode ?? "vi", ''));
                                } else {
                                  // ignore: use_build_context_synchronously
                                  controller.getStringErrorValue(
                                      isLogin?.message ?? "", context);
                                }
                              } else {
                                if (isLogin != null && isLogin.data != null) {
                                  Get.toNamed("/otp",
                                      arguments: controller.userModelResponse);
                                } else if (isLogin != null &&
                                    // ignore: unrelated_type_equality_checks
                                    isLogin.message == "PHONE_EXIST") {
                                  // ignore: use_build_context_synchronously
                                  letPopupRegister(context);
                                  return;
                                } else {
                                  // ignore: use_build_context_synchronously
                                  controller.getStringErrorValue(
                                      isLogin?.message ?? "", context);
                                }
                              }
                              controller.rerest();
                            },
                          ),
                          const SizedBox(height: 12),
                          if (controller.isLogin.value)
                            SizedBox(
                              width: double.maxFinite,
                              child: ButtonPrimaryOutline(
                                TKeys.register.translate(),
                                () {
                                  controller
                                      .changeModeLogin(LoginType.register);
                                },
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
          ),
        ));
  }

  isPhoneValid(PhoneNumber? phoneNumber) {
    if (phoneNumber?.nsn.length == 9 ||
        phoneNumber?.nsn.length == 10 ||
        (phoneNumber?.countryCode == '81' && phoneNumber?.nsn.length == 11)) {
      return true;
    } else {
      return false;
    }
  }

  letPopupRegister(BuildContext cxt) {
    return showDialog<void>(
      context: cxt,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actionsOverflowAlignment: OverflowBarAlignment.center,
          alignment: Alignment.center,
          title: Text(
            TKeys.notification.translate(),
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
                  TKeys.login_exist_recreate.translate(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                child: Text(TKeys.create_new_user.translate(),
                    style: Theme.of(context).textTheme.bodyMedium),
                onPressed: () async {
                  Get.back();

                  UserModel? isLogin = await controller.letRegister(true);
                  if (isLogin != null && isLogin.userID != null) {
                    isLogin.loginType = LoginType.register;
                    Get.toNamed("/otp", arguments: isLogin);
                  } else {
                    EasyLoading.showError(TKeys.fail_again.translate(),
                        duration: const Duration(seconds: 5));
                  }
                  controller.rerest();
                }),
            TextButton(
                child: Text(TKeys.change_password.translate(),
                    style: Theme.of(context).textTheme.bodyMedium),
                onPressed: () async {
                  Get.back();

                  UserModel? isLogin = await controller.sendOTPForgotPassword();
                  if (isLogin?.userID != null) {
                    isLogin!.loginType = LoginType.forgetPassword;
                    Get.toNamed("/otp", arguments: isLogin);
                  } else {
                    EasyLoading.showError(TKeys.fail_again.translate(),
                        duration: const Duration(seconds: 5));
                  }
                  controller.rerest();
                }),
            TextButton(
              child: Text(TKeys.cancel.translate(),
                  style: Theme.of(context).textTheme.bodyMedium),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }
}
