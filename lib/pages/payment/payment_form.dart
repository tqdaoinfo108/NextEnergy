import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:get/get.dart';
import 'package:v2/pages/customs/circular_progress_indicator.dart';
import 'package:v2/pages/customs/dialog_custom.dart';
import 'package:v2/pages/payment/payment_form_controller.dart';

import '../../services/localization_service.dart';
import '../customs/appbar.dart';
import '../customs/button.dart';
import 'credit_card_form_custom.dart';

class PaymentFormPage extends GetView<PaymentFormController> {
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    var boder2 = UnderlineInputBorder(
      borderSide: BorderSide(
          style: BorderStyle.solid,
          color: Theme.of(context).primaryColor.withOpacity(0.3)),
    );

    var border3 = boder2
      ..copyWith(borderSide: BorderSide(color: Theme.of(context).primaryColor));

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
            TKeys.card_infomation.translate(),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Obx(
                () => Expanded(
                  child: controller.isLoading.value
                      ? const CircularProgressIndicatorCustom()
                      : SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              CreditCardFormCustom(
                                formKey: controller.formKey,
                                obscureCvv: true,
                                obscureNumber: false,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                cardNumber: controller.cardNumber.value,
                                cvvCode: controller.cvvCode.value,
                                isHolderNameVisible: true,
                                isCardNumberVisible: true,
                                isExpiryDateVisible: true,
                                isReadOnly: false,
                                cardHolderName: controller.cardHolderName.value,
                                expiryDate: controller.expiryDate.value,
                                themeColor: Colors.blue,
                                textColor: themeData.iconTheme.color!,
                                cvvValidationMessage:
                                    TKeys.pls_input_a_valid_cvv.translate(),
                                dateValidationMessage:
                                    TKeys.pls_input_a_valid_date.translate(),
                                numberValidationMessage:
                                    TKeys.pls_input_a_valid_number.translate(),
                                cardNumberDecoration: InputDecoration(
                                  labelText: TKeys.card_number.translate(),
                                  hintText: 'XXXX XXXX XXXX XXXX',
                                  hintStyle: TextStyle(
                                      color: themeData.iconTheme.color!),
                                  labelStyle: TextStyle(
                                      color: themeData.iconTheme.color!),
                                  focusedBorder: border3,
                                  enabledBorder: boder2,
                                ),
                                expiryDateDecoration: InputDecoration(
                                  hintStyle: TextStyle(
                                      color: themeData.iconTheme.color!),
                                  labelStyle: TextStyle(
                                      color: themeData.iconTheme.color!),
                                  focusedBorder: border3,
                                  enabledBorder: boder2,
                                  labelText: TKeys.expired_date.translate(),
                                  hintText: 'MM/YY',
                                ),
                                cvvCodeDecoration: InputDecoration(
                                  hintStyle: TextStyle(
                                      color: themeData.iconTheme.color!),
                                  labelStyle: TextStyle(
                                      color: themeData.iconTheme.color!),
                                  focusedBorder: border3,
                                  enabledBorder: boder2,
                                  labelText: 'CVV',
                                  hintText: 'XXX',
                                ),
                                cardHolderDecoration: InputDecoration(
                                  hintStyle: TextStyle(
                                      color: themeData.iconTheme.color!),
                                  labelStyle: TextStyle(
                                      color: themeData.iconTheme.color!),
                                  focusedBorder: border3,
                                  enabledBorder: boder2,
                                  labelText: TKeys.card_holder.translate(),
                                ),
                                onCreditCardModelChange:
                                    controller.onCreditCardModelChange,
                                cardNumberController:
                                    controller.cardNumberController,
                                cvvCodeController: controller.cvvCodeController,
                                expiryDateController:
                                    controller.expiryDateController,
                                cardHolderNameController:
                                    controller.cardHolderNameController,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: ButtonPrimary(
                                  TKeys.save.translate(),
                                  onPress: () {
                                    showDialogCustom(context, () {
                                      controller.onValidate();
                                    }, question: TKeys.do_you_save.translate());
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
