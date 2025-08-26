import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:v2/services/localization_service.dart';

class PaymentWebViewBottomSheet extends StatefulWidget {
  final String url;
  final VoidCallback onPaymentComplete;
  final VoidCallback? onPaymentCancelled;

  const PaymentWebViewBottomSheet({
    Key? key,
    required this.url,
    required this.onPaymentComplete,
    this.onPaymentCancelled,
  }) : super(key: key);

  @override
  State<PaymentWebViewBottomSheet> createState() =>
      _PaymentWebViewBottomSheetState();
}

class _PaymentWebViewBottomSheetState extends State<PaymentWebViewBottomSheet> {
  late WebViewController controller;
  bool isLoading = true;
  bool canGoBack = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
            _updateCanGoBack();
          },
          onWebResourceError: (WebResourceError error) {
            // Handle error
            debugPrint('WebView error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            // Check if payment is completed based on URL patterns
            if (_isPaymentCompleteUrl(request.url)) {
              widget.onPaymentComplete();
              Navigator.of(context).pop(true);
              return NavigationDecision.prevent;
            }
            
            if (_isPaymentCancelledUrl(request.url)) {
              widget.onPaymentCancelled?.call();
              Navigator.of(context).pop(false);
              return NavigationDecision.prevent;
            }
            
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  bool _isPaymentCompleteUrl(String url) {
    // Add your payment completion URL patterns here
    // Example: return url.contains('payment-success') || url.contains('completed');
    return url.contains('success') || 
           url.contains('completed') || 
           url.contains('payment-complete');
  }

  bool _isPaymentCancelledUrl(String url) {
    // Add your payment cancellation URL patterns here
    return url.contains('cancel') || 
           url.contains('cancelled') || 
           url.contains('payment-cancel');
  }

  Future<void> _updateCanGoBack() async {
    final canGoBack = await controller.canGoBack();
    setState(() {
      this.canGoBack = canGoBack;
    });
  }

  Future<bool> _onWillPop() async {
    if (canGoBack) {
      controller.goBack();
      return false;
    } else {
      // Show confirmation dialog
      return await _showExitConfirmation();
    }
  }

  Future<bool> _showExitConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(TKeys.notice.translate()),
          content: Text('Bạn có chắc chắn muốn hủy thanh toán không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Tiếp tục'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                widget.onPaymentCancelled?.call();
              },
              child: Text('Hủy thanh toán'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Thanh toán',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    onPressed: () async {
                      if (await _showExitConfirmation()) {
                        Navigator.of(context).pop(false);
                      }
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            // Loading indicator
            if (isLoading)
              const LinearProgressIndicator(),
            
            // WebView
            Expanded(
              child: WebViewWidget(controller: controller),
            ),
            
            // Bottom navigation
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: canGoBack
                        ? () {
                            controller.goBack();
                          }
                        : null,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  IconButton(
                    onPressed: () {
                      controller.reload();
                    },
                    icon: const Icon(Icons.refresh),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      if (await _showExitConfirmation()) {
                        Navigator.of(context).pop(false);
                      }
                    },
                    child: const Text('Hủy'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Utility function to show the payment bottom sheet
Future<bool?> showPaymentBottomSheet({
  required BuildContext context,
  required String url,
  required VoidCallback onPaymentComplete,
  VoidCallback? onPaymentCancelled,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    builder: (context) => PaymentWebViewBottomSheet(
      url: url,
      onPaymentComplete: onPaymentComplete,
      onPaymentCancelled: onPaymentCancelled,
    ),
  );
}
