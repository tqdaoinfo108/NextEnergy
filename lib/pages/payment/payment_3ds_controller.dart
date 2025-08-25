import 'package:flutter/widgets.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../model/payment_info.dart';
import '../../model/payment_model.dart';
import '../../model/response_base.dart';
import '../../services/base_hive.dart';
import '../../services/getxController.dart';
import '../../services/https.dart';
import '../../services/localization_service.dart';
import '../../utils/const.dart';

class Payment3dsBind extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<Payment3dsController>(() => Payment3dsController());
  }
}

class Payment3dsController extends GetxControllerCustom {
  late PaymentDtoModel paymentModel;

  @override
  void onInit() {
    super.onInit();
    paymentModel = Get.arguments as PaymentDtoModel;
    isLoading.value = false;
    isListCardNotEmpty.value =
        (HiveHelper.get(Constants.PAYMENT_CARD, defaultvalue: <String>[])
                as List<String>)
            .isNotEmpty;
  }

  var webviewLoading = true;
  late BuildContext context;
  late PaymentModel paymentResponse;
  RxBool isButtonActive = true.obs;
  ResponseBase<PaymentModel>? basicResponsePayment;
  RxBool isLoadingWebView = RxBool(true);
  setPaymentResponseModel(PaymentModel _paymentResponse) =>
      paymentResponse = _paymentResponse;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  RxBool isSaveCreditCard = false.obs;

  final MaskedTextController cardNumberController =
      MaskedTextController(mask: '0000 0000 0000 0000');
  final TextEditingController expiryDateController =
      MaskedTextController(mask: '00/00');
  final TextEditingController cardHolderNameController =
      TextEditingController();
  final TextEditingController cvvCodeController =
      MaskedTextController(mask: '0000');

  List<PaymentInfoModel> get listCard => PaymentInfoModel.getListCard();

  var isListCardNotEmpty = false.obs;
  RxString radioStringValue = RxString(TKeys.i_disagree.toString());

  setCreditCard(PaymentInfoModel card) {
    cardNumberController.text = card.numberCard;
    cardHolderNameController.text = card.cardHolder;
    cvvCodeController.text = card.cvv;
    expiryDateController.text = card.expiredDate;
  }

  Future<PaymentModel?> onBookingPayment() async {
    try {
      // isLoading.value = true;
      if (EasyLoading.isShow && !isButtonActive.value) {
        return null;
      }
      isButtonActive.value = false;
      EasyLoading.show(dismissOnTap: false);
      var autoPayment = await HttpHelper.autoPayment(paymentModel.hardwareID!,
          paymentModel.priceID!, paymentModel.bookingID ?? 0,
          cardNumber: cardNumberController.text,
          cardExpire: expiryDateController.text,
          holderName: cardHolderNameController.text,
          securityCode: cvvCodeController.text);

      if (autoPayment?.message == "Can not Charging because limit in Area.") {
        EasyLoading.showError(
            TKeys.can_not_create_due_to_the_overspep.translate());
        return null;
      }
      if (autoPayment != null && autoPayment.data != null) {
        setPaymentResponseModel(autoPayment.data!);
        basicResponsePayment = autoPayment;
        return autoPayment.data;
      } else {
        EasyLoading.showError(TKeys.field_format_invalid.translate(),
            duration: const Duration(seconds: 5));
      }
    } finally {
      // isLoading.value = false;
      EasyLoading.dismiss();
      isButtonActive.value = true;
    }
    return null;
  }

  Future<PaymentModel?> getPaymentKeyExtTimeBooking() async {
    if (EasyLoading.isShow) {
      return null;
    }
    isButtonActive.value = false;

    EasyLoading.show(dismissOnTap: false);
    try {
      var getPayment = await HttpHelper.extHoursBooking(
          paymentModel.hardwareID!,
          paymentModel.priceID!,
          paymentModel.bookingID ?? 0,
          cardNumber: cardNumberController.text,
          cardExpire: expiryDateController.text,
          holderName: cardHolderNameController.text,
          securityCode: cvvCodeController.text);
      setPaymentResponseModel(getPayment!.data!);
      basicResponsePayment = getPayment;
      return getPayment.data;
    } finally {
      EasyLoading.dismiss();
      isButtonActive.value = true;
    }
  }
}
