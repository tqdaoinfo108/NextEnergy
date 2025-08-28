import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ultra_qr_scanner/ultra_qr_scanner.dart';
import 'package:ultra_qr_scanner/ultra_qr_scanner_widget.dart';
import 'package:v2/pages/customs/appbar.dart';
import 'package:v2/pages/customs/page_life_cycle.dart';
import 'package:v2/services/localization_service.dart';

class ScanQRCodeBind extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScanQRCodeController>(() => ScanQRCodeController());
  }
}

class ScanQRCodeController extends GetxController {
  bool isNextToPage = true;
  RxBool isScan = false.obs;
  RxBool isFlashOn = false.obs;
  bool _isDialogShowing = false; // Flag để tránh hiện popup nhiều lần

  Future<void> _requestPermissions() async {
    await [Permission.camera].request();
  }

  @override
  void onInit() {
    super.onInit();
    isNextToPage = true;
    _bootstrap();
  }

  @override
  void onReady() {
    super.onReady();
    // Reset trạng thái khi quay lại trang
    isNextToPage = true;
    isScan.value = false;
    isFlashOn.value = false;
    _isDialogShowing = false;
    
    // Force stop scanner để đảm bảo clean state
    UltraQrScanner.stopScanner().catchError((e) {
      print("Error stopping scanner in onReady: $e");
    });
  }

  @override
  void onClose() {
    // Đảm bảo scanner được dừng khi controller bị dispose
    UltraQrScanner.stopScanner();
    super.onClose();
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

      Get.offNamed("/charge_car", arguments: code);
      return;
    }

    // QR không hợp lệ - dừng scanner tạm thời để hiển thị lỗi
    isNextToPage = false;
    await UltraQrScanner.stopScanner();
    
    EasyLoading.showError(
      TKeys.qr_code_invalid.translate(),
      duration: const Duration(seconds: 2),
    );
    
    // Chờ một chút để user đọc message, sau đó restart scanner
    await Future.delayed(const Duration(seconds: 2));
    
    // Restart scanner để tiếp tục quét
    try {
      await UltraQrScanner.prepareScanner();
      isNextToPage = true; // Cho phép quét lại
    } catch (e) {
      print("Error restarting scanner after invalid QR: $e");
      // Nếu không restart được, reset về trạng thái ban đầu
      isScan.value = false;
      isNextToPage = true;
    }
  }

  Future<void> toggleFlash() async {
    // Tự giữ trạng thái đèn, vì package chỉ cung cấp toggleFlash(bool)
    isFlashOn.value = !isFlashOn.value;
    await UltraQrScanner.toggleFlash(isFlashOn.value); // đúng API
  }

  // Method để restart scanner khi quay lại trang
  Future<void> restartScanner() async {
    try {
      await UltraQrScanner.stopScanner();
      await Future.delayed(const Duration(milliseconds: 500)); // Tăng delay để đảm bảo camera release
      await UltraQrScanner.prepareScanner();
      
      // Reset trạng thái
      isNextToPage = true;
      isFlashOn.value = false;
      isScan.value = false;
      _isDialogShowing = false;
      
      // Hiện dialog một cách an toàn
      _showDialogSafely();
      
    } catch (e) {
      print("Error restarting scanner: $e");
      // Force reset nếu có lỗi
      isNextToPage = true;
      isFlashOn.value = false;
      isScan.value = false;
      _isDialogShowing = false;
    }
  }

  // Method để force restart khi camera bị stuck
  Future<void> forceRestartScanner() async {
    try {
      isNextToPage = false;
      isScan.value = false;
      
      // Force stop multiple times nếu cần
      await UltraQrScanner.stopScanner();
      await Future.delayed(const Duration(milliseconds: 300));
      await UltraQrScanner.stopScanner();
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Restart camera permission nếu cần
      await _requestPermissions();
      
      // Prepare lại scanner
      await UltraQrScanner.prepareScanner();
      
      // Reset trạng thái và hiện dialog
      isNextToPage = true;
      isFlashOn.value = false;
      _isDialogShowing = false;
      
      // Hiện dialog để user có thể scan lại
      if (Get.context != null) {
        showScanDialog();
      }
      
    } catch (e) {
      print("Error force restarting scanner: $e");
      // Reset về trạng thái ban đầu
      isNextToPage = true;
      isFlashOn.value = false;
      isScan.value = false;
      _isDialogShowing = false;
    }
  }

  // Method để hiện dialog một cách an toàn, tránh duplicate
  Future<void> _showDialogSafely() async {
    if (_isDialogShowing || isScan.value) return;
    
    await Future.delayed(const Duration(milliseconds: 300));
    if (Get.context != null && !_isDialogShowing && !isScan.value) {
      showScanDialog();
    }
  }

  @override
  void dispose() {
    UltraQrScanner.stopScanner();
    super.dispose();
  }

  Future<void> showScanDialog() async {
    if (_isDialogShowing) return; // Tránh hiện dialog nhiều lần
    
    _isDialogShowing = true;
    await Future.delayed(const Duration(milliseconds: 50));
    
    return showDialog<void>(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
                  _isDialogShowing = false;
                  Get.back();
                  Get.back();
                },
              ),
              ElevatedButton(
                child: Text(TKeys.yes.translate()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  _isDialogShowing = false;
                  Get.back();
                  
                  // Reset trạng thái và restart scanner
                  isNextToPage = true;
                  isFlashOn.value = false;
                  
                  // Dừng scanner cũ (nếu có) trước khi start mới
                  await UltraQrScanner.stopScanner();
                  await Future.delayed(const Duration(milliseconds: 100));
                  
                  // Prepare lại scanner và hiện widget
                  await UltraQrScanner.prepareScanner();
                  isScan.value = true;
                },
              ),
            ],
          ),
        );
      },
    ).then((_) {
      _isDialogShowing = false; // Đảm bảo flag được reset khi dialog đóng
    });
  }

  Future<void> _showDialog() async {
    // Chỉ hiện dialog nếu chưa có dialog nào đang hiện
    if (!_isDialogShowing) {
      return showScanDialog();
    }
  }
}

class ScanQRCodePage extends GetView<ScanQRCodeController> {
  const ScanQRCodePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageLifecycle(
      stateChanged: (bool appeared) {
        // Khi trang xuất hiện lại (back từ trang khác)
        if (appeared && !controller._isDialogShowing && !controller.isScan.value) {
          controller.restartScanner();
        }
      },
      child: Obx(() => Scaffold(
            appBar: AppBarCustom(
              title: Text(
                TKeys.scan_qr.translate(),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: controller.isScan.value 
                ? FloatingActionButton(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    ),
                    elevation: 5,
                    onPressed: controller.toggleFlash,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Icon(
                      controller.isFlashOn.value ? Icons.flash_off : Icons.flash_on, 
                      color: Colors.white
                    ),
                  )
                : FloatingActionButton(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    ),
                    elevation: 5,
                    onPressed: () {
                      // Restart scanner khi user nhấn nút
                      controller.showScanDialog();
                    },
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(Icons.qr_code_scanner, color: Colors.white),
                  ),
            body: Stack(
              children: [
                if (controller.isScan.value)
                  // Dùng widget chính xác theo docs
                  UltraQrScannerWidget(
                    onQrDetected: controller.onQrDetected,
                    autoStart: true,             // vào là quét ngay
                    autoStop: false,             // không tự động dừng để có thể quét liên tục
                    showStartStopButton: false,  // ẩn nút manual
                    showFlashToggle: false,      // mình đã có FAB riêng
                  ),
                
                // Nút restart camera khi bị stuck (góc trên phải)
                if (controller.isScan.value)
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: IconButton(
                        onPressed: () {
                          controller.forceRestartScanner();
                        },
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 24,
                        ),
                        tooltip: "Restart camera",
                      ),
                    ),
                  ),
                
                // Hiện thị message khi chưa scan
                if (!controller.isScan.value)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          size: 100,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          TKeys.scan_qr.translate(),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.grey.shade600
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            controller.showScanDialog();
                          },
                          icon: const Icon(Icons.qr_code_scanner),
                          label: Text(TKeys.scan_qr.translate()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          )),
    );
  }
}
