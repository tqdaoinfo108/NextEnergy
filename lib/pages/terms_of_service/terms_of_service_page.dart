import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:v2/pages/customs/circular_progress_indicator.dart';
import 'package:v2/pages/customs/dialog_custom.dart';
import 'package:v2/pages/terms_of_service/terms_of_service_controller.dart';
import 'package:v2/services/base_hive.dart';
import 'package:v2/services/localization_service.dart';
import 'package:v2/utils/const.dart';

import '../customs/button.dart';
import '../customs/checkbox_custom.dart';

class TermsOfServicePage extends StatefulWidget {
  const TermsOfServicePage({Key? key}) : super(key: key);

  @override
  State<TermsOfServicePage> createState() => _TermsOfServicePageState();
}

class _TermsOfServicePageState extends State<TermsOfServicePage> {
  final TermsOfServiceController controller =
      Get.find<TermsOfServiceController>();

  late final WebViewController _wv;
  bool _initialized = false;

  // JS: chặn camera/mic và phát hiện cuộn tới cuối trang
  static const String _denyMediaAndScrollJS = """
(function() {
  try {
    const md = navigator.mediaDevices;
    if (md) {
      md.getUserMedia = function() {
        return Promise.reject(new DOMException('NotAllowedError', 'NotAllowedError'));
      };
      md.enumerateDevices = function() { return Promise.resolve([]); };
    }
  } catch (e) {}

  function notifyIfEnd() {
    try {
      if ((window.innerHeight + window.scrollY + 200) >= document.body.offsetHeight) {
        if (window.ScrollBridge && window.ScrollBridge.postMessage) {
          window.ScrollBridge.postMessage('end');
        }
      }
    } catch (e) {}
  }

  window.addEventListener('scroll', notifyIfEnd, {passive:true});
  document.addEventListener('DOMContentLoaded', notifyIfEnd);
  window.addEventListener('load', notifyIfEnd);
})();
""";

  @override
  void initState() {
    super.initState();

    _wv = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'ScrollBridge',
        onMessageReceived: (JavaScriptMessage msg) {
          if (msg.message == 'end') {
            controller.isScrolled.value = true;
            controller.update();
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            controller.isLoadStart.value = true;
          },
          onPageFinished: (url) async {
            // Hết loading
            controller.isLoadStart.value = false;
            // Tiêm JS: chặn camera + theo dõi cuộn
            await _wv.runJavaScript(_denyMediaAndScrollJS);
            // Kiểm tra một lần ngay sau khi load
            await _wv.runJavaScript("""
              (function(){
                if ((window.innerHeight + window.scrollY + 200) >= document.body.offsetHeight) {
                  if (window.ScrollBridge && window.ScrollBridge.postMessage) {
                    window.ScrollBridge.postMessage('end');
                  }
                }
              })();
            """);
          },
          // onWebResourceError: (WebResourceError err) {
          //   controller.isLoadError.value = true;
          //   showDialogCustomForPrivacy(
          //     context,
          //     () { exit(0); },
          //     yesText: TKeys.cofirm_charge.translate(),
          //     isPop: false,
          //     question: TKeys.communication_with_the_server_unstable.translate(),
          //     title: TKeys.note.translate(),
          //   );
          // },
          onNavigationRequest: (NavigationRequest req) {
            // Cho phép điều hướng bình thường; tùy bạn muốn chặn thêm thì xử lý ở đây
            return NavigationDecision.navigate;
          },
        ),
      );

    // Chỉ load 1 lần
    if (!_initialized) {
      _initialized = true;
      _wv.loadRequest(Uri.parse("https://adminchargingvietnam.gvbsoft.vn/TermOfUse.aspx"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => SafeArea(
          child: controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Image.asset("assets/images/document.png", width: 86),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: Get.width - 160,
                            child: Text(
                              controller.data.title ?? "",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              softWrap: true,
                              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                    color: Theme.of(context).iconTheme.color,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Stack(
                          children: [
                            WebViewWidget(controller: _wv),
                            if (controller.isLoadStart.value)
                              const CircularProgressIndicatorCustom(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => IntrinsicHeight(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  RoundCheckBox(
                                    checkedColor: Theme.of(context).primaryColor,
                                    size: 30,
                                    isChecked: controller.isCheckTermOfUse.value,
                                    onTap: (selected) {
                                      if (!controller.isScrolled.value) return;
                                      controller.isCheckTermOfUse.value = selected ?? false;
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    controller.data.agree ?? "",
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ButtonPrimary(
                                controller.data.confirm ?? "",
                                onPress: controller.isCheckTermOfUse.value
                                    ? () {
                                        HiveHelper.put(Constants.TERMS_OF_SERVICE, true);
                                        Get.offAndToNamed("/intro");
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
