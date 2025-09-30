import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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
  final RxBool isScan = false.obs;

  late final MobileScannerController scannerController;

  bool _isHandlingResult = false;
  bool _isDialogShowing = false;

  bool get isDialogShowing => _isDialogShowing;

  @override
  void onInit() {
    super.onInit();
    scannerController = MobileScannerController(
      autoStart: false,
      facing: CameraFacing.back,
      returnImage: false,
      formats: const [BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void onReady() {
    super.onReady();
    _showDialog();
  }

  Future<void> onBarcodeDetected(BarcodeCapture capture) async {
    if (_isHandlingResult) return;

    final rawValue = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .firstWhere(
          (value) => value != null && value.trim().isNotEmpty,
          orElse: () => null,
        );

    if (rawValue == null) return;
    if (rawValue.trim().isEmpty) return;

    final normalizedCode = rawValue.trim();
    _isHandlingResult = true;

    if (normalizedCode.toLowerCase().contains('evs-')) {
      EasyLoading.show();
      try {
        await scannerController.stop();
      } catch (e) {
        print('Error stopping scanner after valid QR: $e');
      } finally {
        EasyLoading.dismiss();
      }

      isScan.value = false;
      _isHandlingResult = false;
      Get.offNamed('/charge_car', arguments: normalizedCode);
      return;
    }

    EasyLoading.showError(
      TKeys.qr_code_invalid.translate(),
      duration: const Duration(seconds: 2),
    );

    await Future.delayed(const Duration(seconds: 2));
    _isHandlingResult = false;
  }

  Future<void> handlePageDisappear() async {
    try {
      await scannerController.stop();
    } catch (e) {
      print('Error stopping scanner on disappear: $e');
    }
    isScan.value = false;
    _isHandlingResult = false;
  }

  Future<void> showScanDialog() async {
    if (_isDialogShowing) return;

    final context = Get.context;
    if (context == null) {
      _isDialogShowing = false;
      return;
    }

    _isDialogShowing = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              TKeys.notice.translate(),
              textAlign: TextAlign.center,
              style: Theme.of(dialogContext)
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
                    style: Theme.of(dialogContext).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  TKeys.no_scan.translate(),
                  style: Theme.of(dialogContext).textTheme.bodyMedium,
                ),
                onPressed: () {
                  _isDialogShowing = false;
                  Get.back();
                  Get.back();
                },
              ),
              ElevatedButton(
                child: Text(TKeys.yes.translate()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(dialogContext).primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  _isDialogShowing = false;
                  _isHandlingResult = false;
                  Get.back();
                  isScan.value = true;
                  try {
                    await scannerController.start();
                  } catch (e) {
                    print('Error starting scanner: $e');
                  }
                },
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      _isDialogShowing = false;
    });
  }

  Future<void> _showDialog() async {
    if (!_isDialogShowing) {
      await showScanDialog();
    }
  }

  @override
  void onClose() {
    scannerController.dispose();
    super.onClose();
  }
}

class ScanQRCodePage extends GetView<ScanQRCodeController> {
  const ScanQRCodePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageLifecycle(
      stateChanged: (bool appeared) {
        final ctrl = Get.isRegistered<ScanQRCodeController>()
            ? Get.find<ScanQRCodeController>()
            : null;
        if (ctrl == null) return;

        if (appeared) {
          if (!ctrl.isScan.value && !ctrl.isDialogShowing) {
            ctrl.showScanDialog();
          }
        } else {
          ctrl.handlePageDisappear();
        }
      },
      child: Obx(
        () => Scaffold(
          appBar: AppBarCustom(
            title: Text(
              TKeys.scan_qr.translate(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          body: SafeArea(
            child: controller.isScan.value
                ? _buildScannerView(context)
                : _buildIdleState(context),
          ),
        ),
      ),
    );
  }

  Widget _buildScannerView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(color: Colors.black),
              child: MobileScanner(
                controller: controller.scannerController,
                onDetect: controller.onBarcodeDetected,
                fit: BoxFit.cover,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdleState(BuildContext context) {
    return Center(
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
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: controller.showScanDialog,
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
    );
  }
}
