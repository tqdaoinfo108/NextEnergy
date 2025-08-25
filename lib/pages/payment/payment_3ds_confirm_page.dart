import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v2/model/payment_model.dart';
import 'package:v2/services/https.dart';

import 'package:webview_flutter/webview_flutter.dart';

import '../../services/localization_service.dart';
import '../customs/appbar.dart';

class Payment3DSConfirmPage extends StatefulWidget {
  const Payment3DSConfirmPage({super.key});

  @override
  State<Payment3DSConfirmPage> createState() => _Payment3DSConfirmPageState();
}

class _Payment3DSConfirmPageState extends State<Payment3DSConfirmPage> {
  late PaymentModel paymentResponse;

  @override
  void initState() {
    super.initState();

    paymentResponse = Get.arguments as PaymentModel;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    var webViewController = WebViewController();
    webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);

    webViewController.setNavigationDelegate(NavigationDelegate(
      onPageStarted: (url) async {
        if (url == paymentResponse.reqRedirectionUri) {
          var isSuccess = await HttpHelper.mpiResult(
              paymentResponse.orderID!);
          if (isSuccess) {
           
            Get.back(result: true);
          } else {
            Get.back(result: null);
          }
        }
      },
      // onPageFinished: (url) async {
      //   if (url == paymentResponse.reqRedirectionUri) {
      //     var isSuccess = await HttpHelper.mpiResult(
      //         paymentResponse.orderID!);
      //     if (isSuccess) {
            
      //       Get.back(result: true);
      //     } else {
      //       Get.back(result: null);
      //     }
      //   }
      // },
    ));

    webViewController
        .loadHtmlString(paymentResponse.resResponseContents!);

    return WillPopScope(
      onWillPop: () async {
        Get.back(result: null);
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: themeData.scaffoldBackgroundColor,
        appBar: AppBarCustom(
          title: Text(
            TKeys.payment.translate(),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
                height: double.infinity, // <-----
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12)),
                  color: themeData.scaffoldBackgroundColor,
                ),
                child: Stack(
                  children: [
                    WebViewWidget(
                      controller: webViewController,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}