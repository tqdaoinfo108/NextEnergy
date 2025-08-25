import 'package:convert_vietnamese/convert_vietnamese.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../../model/payment_info.dart';

class PaymentFormBind extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentFormController>(() => PaymentFormController());
  }
}

class PaymentFormController extends GetxController {
  RxString cardNumber = RxString("");
  RxString expiryDate = RxString("");
  RxString cardHolderName = RxString("");
  RxString cvvCode = RxString("");
  RxString oldNumber = RxString("");

  MaskedTextController cardNumberController =
      MaskedTextController(mask: '0000 0000 0000 0000');
  TextEditingController expiryDateController =
      MaskedTextController(mask: '00/00');
  TextEditingController cardHolderNameController = TextEditingController();
  TextEditingController cvvCodeController = MaskedTextController(mask: '0000');

  RxBool isLoading = true.obs;
  RxBool isEditing = false.obs;
  final GlobalKey<FormState> formKey =
      GlobalKey<FormState>(debugLabel: "formKeyFormState");

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    @override
    PaymentInfoModel? arguments = Get.arguments as PaymentInfoModel?;
    if (arguments != null) {
      oldNumber.value = arguments.numberCard;
      cardNumber.value = arguments.numberCard;
      expiryDate.value = arguments.expiredDate;
      cardHolderName.value = arguments.cardHolder;
      cvvCode.value = arguments.cvv;
      isEditing.value = true;
      isLoading.value = false;
    } else {
      isEditing.value = false;
      isLoading.value = false;
    }
  }

  onValidate() async {
    if (formKey.currentState!.validate()) {
      if (isEditing.value) {
        PaymentInfoModel.updateCard(
            PaymentInfoModel(cardNumber.value, cvvCode.value,
                cardHolderName.value, expiryDate.value),
            oldNumber.value);
      } else {
        PaymentInfoModel.addCard(PaymentInfoModel(cardNumber.value,
            cvvCode.value, cardHolderName.value, expiryDate.value));
      }

      Get.back();
    }
  }

  onCreditCardModelChange(CreditCardModel? creditCardModel) {
    cardNumber.value = creditCardModel!.cardNumber;
    expiryDate.value = creditCardModel.expiryDate;
    cardHolderName.value =
        removeDiacritics(creditCardModel.cardHolderName).toUpperCase();
    cvvCode.value = creditCardModel.cvvCode;
  }
}
