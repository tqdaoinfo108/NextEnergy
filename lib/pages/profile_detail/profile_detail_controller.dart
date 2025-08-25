import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:v2/utils/const.dart';

import '../../model/user_model.dart';
import '../../services/base_hive.dart';
import '../../services/getxController.dart';
import '../../services/https.dart';

class ProfileDetailBind extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileDetailController>(() => ProfileDetailController());
  }
}

class ProfileDetailController extends GetxControllerCustom {
  @override
  void onInit() {
    super.onInit();
    getProfile();
  }

  var userModel = UserModel().obs;
  GlobalKey<FormState> infoAccountKey =
      GlobalKey<FormState>(debugLabel: '_childWidgetKey7');
  final ImagePicker pickerImage = ImagePicker();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  Future getProfile() async {
    try {
      var user = await HttpHelper.getProfile(HiveHelper.get(Constants.USER_ID));
      if (user != null && user.data != null) {
        userModel.value = user.data!;
        emailController.text = userModel.value.email!;
        fullNameController.text = userModel.value.fullName!;
        phoneController.text =
            "${userModel.value.phoneArea!} ${userModel.value.uUserID!}";
        update();
      }
    } catch (e) {}finally{
      isLoading.value = false;
    }
  }

  Future<bool> updateInfoAccount() async {
    isLoading.value = true;
    update();

    try {
      var user = await HttpHelper.updateAccount(
          "",
          emailController.text,
          fullNameController.text,
          HiveHelper.get(Constants.LANGUAGE_CODE, defaultvalue: "en"));
      if (user != null && user.data != null) {
        userModel.value = user.data!;
        emailController.text = userModel.value.email!;
        fullNameController.text = userModel.value.fullName!;
        phoneController.text =
            "${userModel.value.phoneArea!} ${userModel.value.uUserID!}";

        update();
        return true;
      }
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
    update();
    return false;
  }

  Future<UserModel?> updateAvatar(String imageSource) async {
    isLoading.value = true;
    update();

    try {
      var user = await HttpHelper.updateAvatar(imageSource);
      if (user != null && user.data != null) {
        userModel.value = user.data!;
        return userModel.value;
      }
    } catch (e) {
    } finally {
      isLoading.value = false;
      update();
    }
    return null;
  }
}
