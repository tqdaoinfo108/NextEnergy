import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';

import '../../model/user_model.dart';
import '../../services/base_hive.dart';
import '../../services/getxController.dart';
import '../../services/https.dart';
import '../customs/count_down.dart';

class OtpBind extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpController>(() => OtpController());
  }
}

class OtpController extends GetxControllerCustom {
  UserModel userModel = UserModel();
  RxBool isResend = false.obs;
  CountdownController countdownController =
      CountdownController(autoStart: true);

  @override
  void onInit() {
    super.onInit();
    userModel = Get.arguments as UserModel;
    isLoading.value =false;
  }

  bool validateOTP(String value) {
    DateTime timeCurrent = DateTime.now();
    DateTime timeExpired =
        DateTime.fromMillisecondsSinceEpoch(userModel.timeOTP! * 1000).add(
            Duration(
                minutes: HiveHelper.get("OTPTimeExpired", defaultvalue: 5)));

    return timeCurrent.compareTo(timeExpired) == -1 && value == userModel.oTP;
  }

  onChageIsResend(bool isResendTemp) {
    isResend.value = isResendTemp;
    update();
  }

  Future<bool> onCallReSend() async {
    // int getCountOTPLocal = HiveHelper.get(Constants.COUNT_OTP, defaultvalue: 0);

    // if (getCountOTPLocal >= 3) {
    //   return false;
    // }

    isLoading.value = true;
    update();

    try {
      var user = await HttpHelper.sentOTPAgain(
          userModel.uUserID!, userModel.phoneArea!);
      if (user != null && user.data != null) {
        countdownController.restart();
        isResend.value = false;
        userModel.oTP = user.data!.oTP;
        userModel.timeOTP = user.data!.timeOTP;

        // tăng count
        // HiveHelper.put(Constants.COUNT_OTP, getCountOTPLocal + 1);
        return true;
      }
    } catch (e) {
    } finally {
      isLoading.value = false;
      update();
    }
    return false;
  }
}
