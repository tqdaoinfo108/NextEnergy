import 'dart:io';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:convert_vietnamese/convert_vietnamese.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/extension.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:v2/model/response_base.dart';
import 'package:v2/pages/customs/circular_progress_indicator.dart';
import 'package:v2/pages/payment/payment_3ds_controller.dart';

import '../../model/payment_info.dart';
import '../../model/payment_model.dart';
import '../../services/localization_service.dart';
import '../customs/appbar.dart';
import '../customs/button.dart';
import '../customs/dialog_custom.dart';
import '../customs/page_life_cycle.dart';
import 'credit_card_form_custom.dart';

class Payment3DSPage extends GetView<Payment3dsController> {
  const Payment3DSPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(Payment3dsController());
    final themeData = Theme.of(context);

    final boder2 = UnderlineInputBorder(
      borderSide: BorderSide(
        style: BorderStyle.solid,
        color: Theme.of(context).primaryColor.withOpacity(0.3),
      ),
    );

    final border3 =
        boder2.copyWith(borderSide: BorderSide(color: Theme.of(context).primaryColor));

    onValidate() async {
      var listDevice = FlutterBluePlus.connectedDevices;
      if (listDevice.isEmpty) {
        Get.back(result: null);
        return;
      }

      if (controller.paymentModel.timeNow != 0 &&
          (controller.paymentModel.timeNow + 300) <
              (DateTime.now().millisecondsSinceEpoch ~/ 1000)) {
        Get.back(result: null);
        return;
      }

      if (controller.isLoading.value) return;

      if (controller.formKey.currentState!.validate()) {
        PaymentModel? result = controller.paymentModel.isExtTime
            ? await controller.getPaymentKeyExtTimeBooking()
            : await controller.onBookingPayment();

        if (result != null &&
            result.resResponseContents.isNotNullAndNotEmpty &&
            result.reqRedirectionUri.isNotNullAndNotEmpty) {
          var resultPage = await Get.toNamed('/payment_confirm', arguments: result);
          if (resultPage != null && resultPage as bool) {
            if (controller.isSaveCreditCard.value) {
              PaymentInfoModel.addCard(
                PaymentInfoModel(
                  controller.cardNumberController.text,
                  controller.cvvCodeController.text,
                  controller.cardHolderNameController.text,
                  controller.expiryDateController.text,
                ),
              );
            }
            Get.back(result: ResponseBase(data: result));
          } else {
            Get.back(result: null);
          }
        }
      }
    }

    buildCard(int index) {
      var cardType =
          PaymentInfoModel.detectCCType(controller.listCard[index].numberCard);

      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: InkWell(
          onTap: () {
            controller.setCreditCard(controller.listCard[index]);
            Get.back();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      PaymentInfoModel.getImageCard(
                        PaymentInfoModel.detectCCType(
                          controller.listCard[index].numberCard,
                        ),
                      ),
                      color: cardType == CardTypeCustom.visa ? Colors.blue.shade900 : null,
                      width: 42,
                      height: 42,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          PaymentInfoModel.removeNumberCard(
                              controller.listCard[index].numberCard),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          controller.listCard[index].cardHolder!,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    void onChoosePaymentCard() async {
      String? result =
          await Get.toNamed("/pin_code_form", arguments: "showPopup") as String?;
      if (result != null && result.isNotEmpty) {
        // ignore: use_build_context_synchronously
        showFlexibleBottomSheet<void>(
          minHeight: 0,
          initHeight: 0.7,
          maxHeight: 0.9,
          anchors: [0, 0.7, 0.9],
          useRootNavigator: true,
          context: context,
          isSafeArea: false,
          bottomSheetColor: Theme.of(context).scaffoldBackgroundColor,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.0),
              topRight: Radius.circular(12.0),
            ),
          ),
          builder: (context2, controller2, offset) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Text(
                    TKeys.select_credit_card_information.translate(),
                    style: Theme.of(context2).textTheme.bodyLarge,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.listCard.length,
                    itemBuilder: (context2, i) => buildCard(i),
                  ),
                ),
              ],
            );
          },
        );
      }
    }

    void onCreditCardModelChange(CreditCardModel? creditCardModel) {
      controller.cardNumberController.text = controller.cardNumberController.text;
      controller.expiryDateController.text = controller.expiryDateController.text;
      controller.cardHolderNameController.text =
          removeDiacritics(controller.cardHolderNameController.text).toUpperCase();
      controller.cvvCodeController.text = controller.cvvCodeController.text;
    }

    final creditWidget = CreditCardFormCustom(
      formKey: controller.formKey,
      obscureCvv: true,
      obscureNumber: false,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      cardNumber: controller.cardNumberController.text,
      cvvCode: controller.cvvCodeController.text,
      isHolderNameVisible: true,
      isCardNumberVisible: true,
      isExpiryDateVisible: true,
      cardHolderName: controller.cardHolderNameController.text,
      expiryDate: controller.expiryDateController.text,
      themeColor: Colors.blue,
      textColor: themeData.iconTheme.color!,
      cvvValidationMessage: TKeys.pls_input_a_valid_cvv.translate(),
      dateValidationMessage: TKeys.pls_input_a_valid_date.translate(),
      numberValidationMessage: TKeys.pls_input_a_valid_number.translate(),
      cardNumberDecoration: InputDecoration(
        labelText: TKeys.card_number.translate(),
        hintText: 'XXXX XXXX XXXX XXXX',
        hintStyle: TextStyle(color: themeData.iconTheme.color!),
        labelStyle: TextStyle(color: themeData.iconTheme.color!),
        focusedBorder: border3,
        enabledBorder: boder2,
      ),
      expiryDateDecoration: InputDecoration(
        hintStyle: TextStyle(color: themeData.iconTheme.color!),
        labelStyle: TextStyle(color: themeData.iconTheme.color!),
        focusedBorder: border3,
        enabledBorder: boder2,
        labelText: TKeys.expired_date.translate(),
        hintText: 'MM/YY',
      ),
      cvvCodeDecoration: InputDecoration(
        hintStyle: TextStyle(color: themeData.iconTheme.color!),
        labelStyle: TextStyle(color: themeData.iconTheme.color!),
        focusedBorder: border3,
        enabledBorder: boder2,
        labelText: 'CVV',
        hintText: 'XXX',
      ),
      cardHolderDecoration: InputDecoration(
        hintStyle: TextStyle(color: themeData.iconTheme.color!),
        labelStyle: TextStyle(color: themeData.iconTheme.color!),
        focusedBorder: border3,
        enabledBorder: boder2,
        labelText: TKeys.card_holder.translate(),
      ),
      onCreditCardModelChange: onCreditCardModelChange,
      cardNumberController: controller.cardNumberController,
      expiryDateController: controller.expiryDateController,
      cvvCodeController: controller.cvvCodeController,
      cardHolderNameController: controller.cardHolderNameController,
    );

    return Center(
      child: WillPopScope(
        onWillPop: () async {
          Get.back(result: null);
          return true;
        },
        child: PageLifecycle(
          stateChanged: (bool appeared) {
            if (controller.paymentModel.timeNow != 0 &&
                (controller.paymentModel.timeNow + 300) <
                    (DateTime.now().millisecondsSinceEpoch ~/ 1000)) {
              Get.back(result: null);
              return;
            }
          },
          child: Obx(
            () => buildBody(
              themeData,
              context,
              controller,
              creditWidget,
              onCreditCardModelChange,
              onValidate,
              onChoosePaymentCard,
            ),
          ),
        ),
      ),
    );
  }

  Scaffold buildBody(
    ThemeData themeData,
    BuildContext context,
    Payment3dsController controller,
    CreditCardFormCustom creditWidget,
    void onCreditCardModelChange(CreditCardModel? creditCardModel),
    Future<Null> onValidate(),
    void onChoosePaymentCard(),
  ) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: themeData.scaffoldBackgroundColor,
      appBar: AppBarCustom(
        title: Text(
          TKeys.card_infomation.translate(),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SafeArea(
        child: controller.isLoading.value
            ? const CircularProgressIndicatorCustom()
            : Column(
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          creditWidget,
                          const SizedBox(height: 10),
                          CheckboxListTile(
                            value: controller.isSaveCreditCard.value,
                            activeColor: Theme.of(context).primaryColor,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text(
                              TKeys.save_credit_card.translate(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            fillColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                              if (states.contains(MaterialState.selected)) {
                                return Theme.of(context).primaryColor;
                              }
                              return Theme.of(context).scaffoldBackgroundColor;
                            }),
                            side: MaterialStateBorderSide.resolveWith(
                              (states) => const BorderSide(width: 2.0, color: Colors.grey),
                            ),
                            onChanged: (v) async {
                              if (!controller.isSaveCreditCard.value) {
                                String? result = await Get.toNamed("/pin_code_form",
                                    arguments: "/payment_list") as String?;
                                if (result != null) {
                                  controller.isSaveCreditCard.value = true;
                                  onCreditCardModelChange(
                                    CreditCardModel(
                                      controller.cardNumberController.text,
                                      controller.expiryDateController.text,
                                      controller.cardHolderNameController.text,
                                      controller.cvvCodeController.text,
                                      false,
                                    ),
                                  );
                                } else {
                                  controller.isSaveCreditCard.value = false;
                                }
                              } else {
                                controller.isSaveCreditCard.value = false;
                              }
                            },
                          ),
                          ListTile(
                            title: GestureDetector(
                              onTap: () {
                                Get.dialog(
                                  WillPopScope(
                                    onWillPop: () async => false,
                                    child: Obx(
                                      () => SafeArea(
                                        child: Container(
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Stack(
                                                  children: [
                                                    _LawWebView(
                                                      onLoadingChanged: (loading) {
                                                        controller.isLoadingWebView.value =
                                                            loading;
                                                      },
                                                      onError: () {
                                                        showDialogCustomForPrivacy(
                                                          context,
                                                          () {
                                                            exit(0);
                                                          },
                                                          yesText: TKeys.cofirm_charge.translate(),
                                                          isPop: false,
                                                          question: TKeys
                                                              .communication_with_the_server_unstable
                                                              .translate(),
                                                          title: TKeys.note.translate(),
                                                        );
                                                      },
                                                    ),
                                                    if (controller.isLoadingWebView.value)
                                                      const CircularProgressIndicatorCustom(),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              ButtonPrimary(
                                                TKeys.close.translate(),
                                                onPress: () {
                                                  Get.back();
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                TKeys.i_agree_to_the_specified_commercial_transactions_law
                                    .translate(),
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontSize:
                                      Theme.of(context).textTheme.bodyMedium!.fontSize,
                                  fontFamily:
                                      Theme.of(context).textTheme.bodyMedium!.fontFamily,
                                  color: Theme.of(context).primaryColor,
                                  decorationColor: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            leading: Radio<String>(
                              value: TKeys
                                  .i_agree_to_the_specified_commercial_transactions_law
                                  .toString(),
                              groupValue: controller.radioStringValue.value,
                              onChanged: (String? value) {
                                controller.radioStringValue.value =
                                    value ?? TKeys.i_disagree.toString();
                              },
                            ),
                          ),
                          ListTile(
                            title: Text(
                              TKeys.i_disagree.translate(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            leading: Radio<String>(
                              value: TKeys.i_disagree.toString(),
                              groupValue: controller.radioStringValue.value,
                              onChanged: (String? value) {
                                controller.radioStringValue.value =
                                    value ?? TKeys.i_disagree.toString();
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (!controller.isLoading.value)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: ButtonPrimary(
                                TKeys.payment.translate(),
                                onPress: (controller.isButtonActive.value &&
                                        controller.radioStringValue.value !=
                                            TKeys.i_disagree.toString())
                                    ? () {
                                        onValidate();
                                      }
                                    : null,
                              ),
                            ),
                          const SizedBox(height: 12),
                          if (controller.isListCardNotEmpty.value &&
                              !controller.isLoading.value)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: ButtonPrimary(
                                TKeys.select_credit_card_information.translate(),
                                onPress: () async {
                                  onChoosePaymentCard();
                                },
                                color: Colors.grey,
                              ),
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

/// WebView hiển thị điều khoản trong dialog (webview_flutter)
class _LawWebView extends StatefulWidget {
  final void Function(bool loading)? onLoadingChanged;
  final VoidCallback? onError;

  const _LawWebView({this.onLoadingChanged, this.onError});

  @override
  State<_LawWebView> createState() => _LawWebViewState();
}

class _LawWebViewState extends State<_LawWebView> {
  late final WebViewController _controller;
  bool _loadedOnce = false;

  // (Tuỳ chọn) Chặn getUserMedia để không dính log camera từ trang
  static const _denyMediaJS = """
    (function(){
      try {
        const md = navigator.mediaDevices;
        if (md) {
          md.getUserMedia = function(){ return Promise.reject(new DOMException('NotAllowedError','NotAllowedError')); };
          md.enumerateDevices = function(){ return Promise.resolve([]); };
        }
      } catch(e){}
    })();
  """;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            widget.onLoadingChanged?.call(true);
          },
          onPageFinished: (_) async {
            // Tiêm JS chặn media (nếu trang có thử gọi camera/mic)
            await _controller.runJavaScript(_denyMediaJS);
            widget.onLoadingChanged?.call(false);
          },
          onWebResourceError: (_) {
            widget.onError?.call();
          },
        ),
      );

    if (!_loadedOnce) {
      _loadedOnce = true;
      _controller.loadRequest(Uri.parse("https://NextEnergy.net/law"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
