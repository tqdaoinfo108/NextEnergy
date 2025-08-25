import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:v2/services/getxController.dart';

import '../../model/response_base.dart';
import '../../model/user_model.dart';
import '../../services/base_hive.dart';
import '../../services/https.dart';
import '../../services/localization_service.dart';
import '../../utils/const.dart';
import 'widget/phone_controller_custom.dart';

class LoginBind extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}

enum LoginType {
  register,
  none,
  forgetPassword;
}

class LoginController extends GetxControllerCustom {
  @override
  void onInit() {
    super.onInit();
    isLoading.value = false;
  }

  var isLogin = true.obs;
  var textForgetPasswordString = "Forget Password?".obs;
  var textConfirmString = "Confirm".obs;
  String phoneValue = "";
  String areaCoutryCode = "";
  String passwordValue = "";
  PhoneControllerCustom phoneController = PhoneControllerCustom(
      initialValue: const PhoneNumber(isoCode: IsoCode.VI, nsn: ""));

  LoginType typeRequestOTP = LoginType.none;
  late UserModel userModelResponse;

  void onChangePhoneValue(PhoneNumber? s) {
    phoneValue = s!.nsn;
    if (phoneValue.startsWith('0') && phoneValue.length > 3) {
      phoneValue = phoneValue.substring(1, phoneValue.length);
    }
    areaCoutryCode = s.countryCode;
    phoneController = PhoneControllerCustom(initialValue: s);
  }

  void onChangePasswordValue(String s) {
    passwordValue = s;
  }

  void changeModeLogin(LoginType type) {
    isLogin.value = !isLogin.value;
    if (isLoading.value) {
      textForgetPasswordString.value = TKeys.reset_password.translate();
      textConfirmString.value = TKeys.login.translate();
    } else {
      textForgetPasswordString.value = "";
      textConfirmString.value = TKeys.request_otp.translate();
    }
    typeRequestOTP = type;
    update();
  }

  void rerest() {
    isLogin.value = true;
    isLoading.value = false;
    update();
  }

  Future<ResponseBase<UserModel>?> letLogin() async {
    isLoading.value = true;
    update();

    try {
      if (isLogin.value) {
        ResponseBase<UserModel>? user =
            await HttpHelper.login(phoneValue, passwordValue, areaCoutryCode);
        if (user != null && user.data != null) {
          HiveHelper.put(Constants.USER_ID, user.data!.userID!);
          try {
            await FirebaseMessaging.instance
                .subscribeToTopic("user${user.data!.userID!}");
          } catch (e) {}

          HiveHelper.put(Constants.LAST_LOGIN, user.data!.lastLogin!);
          HiveHelper.put(
              Constants.LANGUAGE_CODE, user.data!.languageCode ?? "ja");
          Get.updateLocale(Locale(user.data!.languageCode ?? "vi", ""));
          HttpHelper.updateLanguageCode();
          return user;
        } else if (user?.message != null) {
          return user;
        }
        return null;
      } else {
        // Đăng ký
        if (typeRequestOTP == LoginType.register) {
          try {
            ResponseBase<UserModel>? user =
                await HttpHelper.register(areaCoutryCode, phoneValue, false);
            if (user != null && user.data != null) {
              userModelResponse = user.data!;
              userModelResponse.loginType = LoginType.register;
              int getCountOTPLocal =
                  HiveHelper.get(Constants.COUNT_OTP, defaultvalue: 0);
              HiveHelper.put(Constants.COUNT_OTP, getCountOTPLocal + 1);
              return user;
            } else if (user != null && user.message != null) {
              return user;
            }
          } catch (e) {}
          // Quên mật khẩu
        } else if (typeRequestOTP == LoginType.forgetPassword) {
          try {
            ResponseBase<UserModel>? user =
                await HttpHelper.sentOTPAgainForgotPassword(
                    phoneValue, areaCoutryCode);

            if (user != null && user.data != null) {
              userModelResponse = user.data!;
              userModelResponse.loginType = LoginType.forgetPassword;
              int getCountOTPLocal =
                  HiveHelper.get(Constants.COUNT_OTP, defaultvalue: 0);
              HiveHelper.put(Constants.COUNT_OTP, getCountOTPLocal + 1);
              return user;
            } else if (user?.message != null) {
              return user;
            }
          } catch (e) {}
        }

        return null;
      }
    } catch (e) {
      return null;
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<UserModel?> sendOTPForgotPassword() async {
    try {
      ResponseBase<UserModel>? user =
          await HttpHelper.sentOTPAgainForgotPassword(
              phoneValue, areaCoutryCode);

      if (user != null && user.data != null) {
        user.data!.loginType = LoginType.forgetPassword;
        return user.data;
      }
    } catch (e) {}
    return null;
  }

  Future<UserModel?> letRegister(bool isRenew) async {
    isLoading.value = true;
    update();
    try {
      var register =
          await HttpHelper.register(areaCoutryCode, phoneValue, isRenew);
      if (register != null && register.data != null) {
        return register.data;
      }
    } catch (e) {}
    isLoading.value = false;
    update();
    return null;
  }

  void getStringErrorValue(String? item, BuildContext context) {
    switch (item) {
      case "USER_NOT_EXIST":
        EasyLoading.showError(TKeys.account_not_exists.translate(),
            duration: const Duration(seconds: 5));
        break;
      case "DEAVTIVE":
        EasyLoading.showError(TKeys.account_nonactive.translate(),
            duration: const Duration(seconds: 5));
        break;
      case "PASS_INVALID.":
        EasyLoading.showError(TKeys.password_incorrect.translate(),
            duration: const Duration(seconds: 5));
        break;
      default:
        EasyLoading.showError(TKeys.fail_again.translate(),
            duration: const Duration(seconds: 5));
        break;
    }
  }
}
