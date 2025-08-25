import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../model/response_base.dart';
import '../../model/user_model.dart';
import '../../services/base_hive.dart';
import '../../services/getxController.dart';
import '../../services/https.dart';
import '../customs/count_down.dart';
import '../login/login_controller.dart';

class ProfileChangePassBind extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileChangePassController>(() => ProfileChangePassController());
  }
}

class ProfileChangePassController extends GetxControllerCustom {
  UserModel? userModel;
 final GlobalKey<FormState> formKey =
        GlobalKey<FormState>(debugLabel: '_childWidgetKey5');
  final TextEditingController passwordCurrentController =
      TextEditingController();
  final TextEditingController passwordNewController = TextEditingController();

    @override
  void onInit() {
    super.onInit();
    isLoading.value = false;
    UserModel? isUserExits =
        Get.arguments as UserModel?;
    if (isUserExits != null) {
      userModel = isUserExits;
    }
  }

  Future<bool> letChangePass() async {
    isLoading.value = true;
    update();
    LoginType type = userModel!.loginType;
    try {
      ResponseBase<UserModel>? user;
      if (userModel!.loginType == LoginType.forgetPassword) {
        user = await HttpHelper.forgetPassword(userModel!.uUserID!,
            userModel!.phoneArea!, passwordNewController.text);
      } else {
        user = await HttpHelper.changePassword(
            passwordCurrentController.text, passwordNewController.text);
      }

      if (user != null && user.data != null) {
        userModel = user.data;

        update();
        return true;
      }
    } catch (e) {
      if (e is DioError) {
        // errorText = e.message;
      }
    } finally {
      isLoading.value = false;
      userModel!.loginType = type;
    }
    update();
    return false;
  }
}
