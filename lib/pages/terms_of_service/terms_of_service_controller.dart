import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../model/terms_of_service.dart';
import '../../services/getxController.dart';
import '../../services/https.dart';

class TermsOfServiceBind extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TermsOfServiceController>(() => TermsOfServiceController());
  }
}

class TermsOfServiceController extends GetxControllerCustom {
  TermsOfUseModel data = TermsOfUseModel()
    ..agree = "Tôi đồng ý với tất cả các điều khoản trên"
    ..confirm = "Đồng ý"
    ..title = "Điều khoản sử dụng & Quyền riêng Tư";
  DateTime time = DateTime.now();
  var isCheckTermOfUse = false.obs;
  RxBool isLoadError = RxBool(false);
  RxBool isScrolled = RxBool(false);
  RxBool isLoadStart = RxBool(true);
  RxBool isTest = RxBool(false);
  var webController = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse("https://adminchargingvietnam.gvbsoft.vn/TermOfUse.aspx"));

  void onChange(bool value) {
    isCheckTermOfUse.value = value;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    getConfig();
  }

  Future getConfig() async {
    try {
      var configs = await HttpHelper.getConfig();
      if (configs != null && configs.data != null) {
        var config = configs.data!.firstWhere((x) => x.configKey == "TermsOfUse");
        data = TermsOfUseBaseModel.fromJson(jsonDecode(config.configValue!))
            .data!
            .firstWhere((element) => element.language == "vi");
        await Get.updateLocale(Locale(isTest.value ? "en" : "vi", ""));
      }
    } catch (e) {
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
