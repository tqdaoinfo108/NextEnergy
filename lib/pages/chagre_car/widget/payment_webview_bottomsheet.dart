import 'dart:async';
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
  Timer? _checkTimer;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _startPaymentCheck();
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }

  void _startPaymentCheck() {
    _checkTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkPaymentSuccess();
    });
  }

  Future<void> _checkPaymentSuccess() async {
    try {
      final result = await controller.runJavaScriptReturningResult(
          'document.body.innerText || document.body.textContent || ""');

      String pageContent = result.toString().toLowerCase();
      debugPrint('Checking page content for payment success...');

      if (pageContent.contains('thanh toán thành công') ||
          pageContent.contains('payment success') ||
          pageContent.contains('thanh toan thanh cong')) {
        debugPrint('Payment success detected in page content');
        _checkTimer?.cancel();
        widget.onPaymentComplete();
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      debugPrint('Error checking payment status: $e');
    }
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
            debugPrint('WebView finished loading: $url');

            setState(() {
              isLoading = false;
            });
            _updateCanGoBack();
            // Kiểm tra ngay khi trang load xong
            _checkPaymentSuccess();
          },
          onWebResourceError: (WebResourceError error) {
            // Handle error
            debugPrint('WebView error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('WebView finished loading: ${request.url}');

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
      final shouldExit = await _showExitConfirmation();
      if (shouldExit) {
        _checkTimer?.cancel();
      }
      return shouldExit;
    }
  }

  Future<bool> _showExitConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(TKeys.notice.translate()),
              content: Text(TKeys.are_you_sure_want_to_end.translate()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(TKeys.continue_payment.translate()),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    widget.onPaymentCancelled?.call();
                  },
                  child: Text(TKeys.cancel.translate()),
                ),
              ],
            );
          },
        ) ??
        false;
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
                    TKeys.payment.translate(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    onPressed: () async {
                      if (await _showExitConfirmation()) {
                        _checkTimer?.cancel();
                        if (mounted) {
                          Navigator.of(context).pop(false);
                        }
                      }
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Loading indicator
            if (isLoading) const LinearProgressIndicator(),

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
                        _checkTimer?.cancel();
                        if (mounted) {
                          Navigator.of(context).pop(false);
                        }
                      }
                    },
                    child: Text(TKeys.cancel.translate()),
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
