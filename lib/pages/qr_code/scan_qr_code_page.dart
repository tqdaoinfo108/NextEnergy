import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ultra_qr_scanner/ultra_qr_scanner.dart';
import 'package:ultra_qr_scanner/ultra_qr_scanner_widget.dart';
import 'package:v2/pages/customs/appbar.dart';
import 'package:v2/services/localization_service.dart';

class ScanQRCodeBind extends Bindings {
  @override
  void dependencies() {
    Get.put(ScanQRCodeController());
  }
}

class ScanQRCodeController extends GetxController {
  bool isNextToPage = true;
  RxBool isScan = false.obs;
  RxBool isFlashOn = false.obs;

  Future<void> _requestPermissions() async {
    await [Permission.camera].request();
  }

  @override
  void onInit() {
    super.onInit();
    isNextToPage = true;
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _requestPermissions();
    // (khuyến nghị) chuẩn bị scanner trước cho lần mở đầu nhanh hơn
    await UltraQrScanner.prepareScanner(); // optional nhưng tốt
    _showDialog();
  }

  Future<void> onQrDetected(String? code) async {
    if (code == null || code.isEmpty || !isNextToPage) return;

    if (code.toLowerCase().contains('evs-')) {
      isNextToPage = false;
      EasyLoading.show();
      await Future.delayed(const Duration(milliseconds: 500));
      EasyLoading.dismiss();

      // Dừng camera (autoStop cũng dừng, nhưng mình chủ động cho chắc)
      await UltraQrScanner.stopScanner();

      Get.offAndToNamed("/charge_car", arguments: code);
      return;
    }

    EasyLoading.showError(
      TKeys.qr_code_invalid.translate(),
      duration: const Duration(seconds: 5),
    );
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> toggleFlash() async {
    // Tự giữ trạng thái đèn, vì package chỉ cung cấp toggleFlash(bool)
    isFlashOn.value = !isFlashOn.value;
    await UltraQrScanner.toggleFlash(isFlashOn.value); // đúng API
  }

  @override
  void dispose() {
    UltraQrScanner.stopScanner();
    super.dispose();
  }

  Future<void> _showDialog() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return showDialog<void>(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actionsOverflowAlignment: OverflowBarAlignment.center,
            title: Text(
              TKeys.notice.translate(),
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
                    TKeys.do_you_have_charge_flag_your_car.translate(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(TKeys.no_scan.translate(),
                    style: Theme.of(context).textTheme.bodyMedium),
                onPressed: () {
                  Get.back();
                  Get.back();
                },
              ),
              TextButton(
                child: Text(TKeys.yes.translate(),
                    style: Theme.of(context).textTheme.bodyMedium),
                onPressed: () {
                  Get.back();
                  isScan.value = true; // Hiện widget & tự start
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class ScanQRCodePage extends GetView<ScanQRCodeController> {
  const ScanQRCodePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: AppBarCustom(
            title: Text(
              TKeys.scan_qr.translate(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
            ),
            elevation: 5,
            onPressed: controller.toggleFlash,
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.flash_on, color: Colors.white),
          ),
          body: Stack(
            children: [
              if (controller.isScan.value)
                // Dùng widget chính xác theo docs
                UltraQrScannerWidget(
                  onQrDetected: controller.onQrDetected,
                  autoStart: true,             // vào là quét ngay
                  autoStop: true,              // dừng sau khi detect đầu tiên
                  showStartStopButton: false,  // ẩn nút manual
                  showFlashToggle: false,      // mình đã có FAB riêng
                ),
            ],
          ),
        ));
  }
}
