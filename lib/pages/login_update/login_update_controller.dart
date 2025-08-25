import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/user_model.dart';
import '../../services/base_hive.dart';
import '../../services/getxController.dart';
import '../../services/https.dart';
import '../../utils/const.dart';

class LoginUpdateBind extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginUpdateController>(() => LoginUpdateController());
  }
}

class LoginUpdateController extends GetxControllerCustom {
  UserModel userModel = UserModel();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController passwordCurrentController =
      TextEditingController();
  final TextEditingController passwordNewController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    isLoading.value = false;
  }

  Future<bool> onUpdateProfile() async {
    isLoading.value = true;

    try {
      var user = await HttpHelper.updateAccount(
          passwordNewController.text,
          emailController.text,
          fullNameController.text,
          HiveHelper.get(Constants.LANGUAGE_CODE, defaultvalue: "en"),
          userID: userModel.userID!);
      if (user != null && user.data != null) {
        HiveHelper.put(Constants.USER_ID, user.data!.userID!);
        try {
          await FirebaseMessaging.instance
              .subscribeToTopic("user${user.data!.userID!}");
        } catch (e) {}
        HiveHelper.put(Constants.LAST_LOGIN, user.data!.lastLogin!);
        HiveHelper.put(Constants.LANGUAGE_CODE, user.data!.languageCode);
        return true;
      }
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
    return false;
  }
}
