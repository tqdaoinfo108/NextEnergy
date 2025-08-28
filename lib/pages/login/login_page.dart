import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:v2/pages/login/login_controller.dart';
import 'package:v2/services/localization_service.dart';

import '../../model/response_base.dart';
import '../../model/user_model.dart';
import '../customs/appbar.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>(debugLabel: '_childWidgetKey3');
    final phoneController = TextEditingController();
    final RxBool obscurePassword =
        true.obs; // State để theo dõi ẩn/hiện password

    return Obx(() => Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: !controller.isLogin.value
              ? AppBarCustom(
                  backgroundColor: Colors.grey.shade50,
                  elevation: 0,
                  leading: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        controller.changeModeLogin(LoginType.forgetPassword);
                      },
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                    ),
                  ))
              : null,
          body: SafeArea(
            child: controller.isLoading.value
                ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Đang xử lý...",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),

                          // App Logo/Branding Section
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).primaryColor,
                                  Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.flash_on,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 32),

                          if (!controller.isLogin.value)
                            Column(
                              children: [
                                Text(
                                    controller.typeRequestOTP ==
                                            LoginType.forgetPassword
                                        ? TKeys.forget_password_string
                                            .translate()
                                        : TKeys.create_account_string
                                            .translate(),
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                      letterSpacing: -0.5,
                                    )),
                                const SizedBox(height: 8),
                                Text(
                                  controller.typeRequestOTP ==
                                          LoginType.forgetPassword
                                      ? "Nhập số điện thoại để khôi phục mật khẩu"
                                      : "Tạo tài khoản mới để bắt đầu sử dụng",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 40),
                              ],
                            ),

                          if (controller.isLogin.value)
                            Column(
                              children: [
                                Text(
                                  TKeys.login.translate(),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    letterSpacing: -1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Chào mừng bạn quay trở lại!",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 40),
                              ],
                            ),

                          // Enhanced Phone Input Field with +84 prefix
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                prefixIcon: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  margin: const EdgeInsets.only(right: 12),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Vietnamese flag design
                                      Container(
                                        width: 24,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFDA020E),
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.star,
                                                color: Color(0xFFFFFF00),
                                                size: 8,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "+84",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                labelText: TKeys.phone.translate(),
                                hintText: "xxx xxx xxx",
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 20),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return TKeys.dont_blank.translate();
                                }
                                if (value.length < 9 || value.length > 10) {
                                  return "Số điện thoại không hợp lệ";
                                }
                                return null;
                              },
                              onChanged: (value) {
                                // Update phone value for controller use
                                controller.onChangePhoneValue(value);
                              },
                            ),
                          ),

                          const SizedBox(height: 24),

                          if (controller.isLogin.value)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                obscureText: obscurePassword.value,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  labelText: TKeys.password.translate(),
                                  hintText: TKeys.password.translate(),
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 16,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      obscurePassword.value =
                                          !obscurePassword.value;
                                    },
                                    icon: Icon(
                                      obscurePassword.value
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 2,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 20),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                validator: (s) {
                                  if (s == null || s.isEmpty) {
                                    return TKeys.dont_blank.translate();
                                  }
                                  if (s.length < 6 || s.length > 32) {
                                    return TKeys.more_than_6.translate();
                                  }
                                  return null;
                                },
                                onChanged: (s) =>
                                    controller.onChangePasswordValue(s),
                              ),
                            ),

                          const SizedBox(height: 20),

                          // Forgot Password / Info Section
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () => controller.changeModeLogin(
                                        LoginType.forgetPassword),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      child: Text(
                                          controller.isLogin.value
                                              ? TKeys.forget_password
                                                  .translate()
                                              : controller
                                                  .textForgetPasswordString
                                                  .value,
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          )),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Primary Action Button
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).primaryColor,
                                  Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () async {
                                  if (!formKey.currentState!.validate()) {
                                    return;
                                  }

                                  // Validate phone number
                                  if (!isPhoneValid(phoneController.text)) {
                                    EasyLoading.showError(
                                        TKeys.field_format_invalid.translate(),
                                        duration: const Duration(seconds: 3));
                                    return;
                                  }

                                  ResponseBase<UserModel>? isLogin =
                                      await controller.letLogin();

                                  if (controller.isLogin.value) {
                                    if (isLogin != null &&
                                        isLogin.data != null) {
                                      Get.offAndToNamed("/home");
                                      Get.updateLocale(Locale(
                                          isLogin.data?.languageCode ?? "vi",
                                          ''));
                                    } else {
                                      controller.getStringErrorValue(
                                          isLogin?.message ?? "", context);
                                    }
                                  } else {
                                    if (isLogin != null &&
                                        isLogin.data != null) {
                                      Get.toNamed("/otp",
                                          arguments:
                                              controller.userModelResponse);
                                    } else if (isLogin != null &&
                                        isLogin.message == "PHONE_EXIST") {
                                      letPopupRegister(context);
                                      return;
                                    } else {
                                      controller.getStringErrorValue(
                                          isLogin?.message ?? "", context);
                                    }
                                  }
                                  controller.rerest();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        controller.isLogin.value
                                            ? TKeys.confirm.translate()
                                            : controller
                                                .textConfirmString.value,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Secondary Action (Register)
                          if (controller.isLogin.value)
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    controller
                                        .changeModeLogin(LoginType.register);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.person_add_rounded,
                                          color: Theme.of(context).primaryColor,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          TKeys.register.translate(),
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
          ),
        ));
  }

  // Simple phone validation for Vietnamese numbers
  bool isPhoneValid(String phoneNumber) {
    // Remove any spaces or special characters
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Check if it's a valid Vietnamese phone number (9-10 digits)
    if (cleanPhone.length >= 9 && cleanPhone.length <= 10) {
      return true;
    }
    return false;
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
