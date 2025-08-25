// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:v2/model/payment_model.dart';
// import 'package:v2/provider/payment_provider.dart';
// import 'package:v2/services/localization_service.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import '../../services/base_hive.dart';
// import '../../utils/const.dart';
// import '../customs/appbar.dart';

// class PaymentPage extends ConsumerWidget {
//   const PaymentPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     var watchProvider = ref.watch(paymentProvider);
//     var readProvider = ref.read(paymentProvider.notifier);

//     ThemeData themeData = Theme.of(context);
//     readProvider.setBuilContext(context);
//     readProvider.setPaymentModel(
//         ModalRoute.of(context)!.settings.arguments as PaymentModel);

//     var webViewController = WebViewController();
//     webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);

//     webViewController.setNavigationDelegate(NavigationDelegate(
//       onPageStarted: (url) {
//         if (url == Constants.PAYMENT_SUCCESS_URL) {
//           Navigator.of(context).pop(true);
//         } else if (url == Constants.PAYMENT_FAILURE_URL) {
//           Navigator.of(context).pop(false);
//         }
//       },
//       onPageFinished: (url) {},
//     ));

//     String buildPaymentPage(
//         String popScriptUrl, String? popClientKey, String? paymentKey) {
//       final language =
//           HiveHelper.get(Constants.LANGUAGE_CODE, defaultvalue: "ja");

//       return "<!DOCTYPE html> <html> <head> <meta charset=\"UTF-8\" /> <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\" /> <script type=\"text/javascript\" src=\"$popScriptUrl\" data-client-key=\"$popClientKey\"></script> <script type=\"text/javascript\"> function letsPayment() { pop.pay(\"$paymentKey\", { language: \"$language\" }); } </script> </head> <body onload=\"letsPayment();\" /> </html> ";
//     }

//     webViewController.loadRequest(Uri.dataFromString(
//       buildPaymentPage(
//         Constants.PAYMENT_POP_SCRIPT_URL,
//         watchProvider.paymentModel.clientKey,
//         watchProvider.paymentModel.paymentKey,
//       ),
//       mimeType: 'text/html',
//     ));

//     return WillPopScope(
//       onWillPop: () async {
//         Navigator.of(context).pop(null);
//         return true;
//       },
//       child: Scaffold(
//         resizeToAvoidBottomInset: false,
//         backgroundColor: themeData.scaffoldBackgroundColor,
//         appBar: AppBarCustom(
//           title: Text(
//             TKeys.payment.translate(),
//             style: Theme.of(context).textTheme.headlineSmall,
//           ),
//         ),
//         body: Column(
//           children: [
//             Expanded(
//               child: Container(
//                 padding: const EdgeInsets.only(bottom: 12),
//                 height: double.infinity, // <-----
//                 decoration: BoxDecoration(
//                   borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(12),
//                       topRight: Radius.circular(12)),
//                   color: themeData.scaffoldBackgroundColor,
//                 ),
//                 child: Stack(
//                   children: [
//                     WebViewWidget(
//                       controller: webViewController,
//                     ),
//                     // watchProvider.webviewLoading
//                     //     ? const CircularProgressIndicatorCustom()
//                     //     : Container()
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
