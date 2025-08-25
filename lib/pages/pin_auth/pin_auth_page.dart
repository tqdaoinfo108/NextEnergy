import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pinput/pinput.dart';
import 'package:v2/model/payment_info.dart';
import 'package:v2/pages/customs/appbar.dart';
import 'package:v2/services/base_hive.dart';
import 'package:v2/utils/const.dart';

import '../../services/localization_service.dart';

class PinAuthPage extends StatefulWidget {
  const PinAuthPage({super.key});

  @override
  State<PinAuthPage> createState() => _PinAuthPageState();
}

class _PinAuthPageState extends State<PinAuthPage> {
  String title = "";
  String description = "";
  String pincode = "";

  String routeNextPage = "";

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      String arguments = ModalRoute.of(context)!.settings.arguments as String;
      if (arguments.isNotEmpty) {
        routeNextPage = arguments;
      } else {
        Get.back();
      }
    });

    pincode = HiveHelper.get(Constants.LOCAL_PIN_CODE, defaultvalue: "");
    if (pincode != "") {
      setState(() {
        title = TKeys.input_pincode.translate();
        description = TKeys.pls_enter_the_4_digit_code.translate();
      });
      isAuthLocal().then((value) {
        if (value) {
          HiveHelper.put(Constants.COUNT_PIN_CODE, 0);
          Get.back(result: routeNextPage);
        }
      });
    } else {
      setState(() {
        title = TKeys.create_a_new_pin_code.translate();
        description = TKeys.pincode_will_used_to_store.translate();
      });
    }
  }

  Future<bool> isAuthLocal() async {
    final LocalAuthentication auth = LocalAuthentication();
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    final List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();

    if (canAuthenticate && availableBiometrics.isNotEmpty) {
      if (availableBiometrics.contains(BiometricType.strong) ||
          availableBiometrics.contains(BiometricType.face)) {
        // Specific types of biometrics are available.
        // Use checks like this with caution!
        var result = await auth.authenticate(
            localizedReason:
                TKeys.authenticate_to_view_card_information.translate());
        return result;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
          fontSize: 20,
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(
            color: const Color.fromARGB(255, 88, 95, 102).withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    return Scaffold(
      appBar: AppBarCustom(),
      body: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    )),
            const SizedBox(height: 16),
            Text(description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color:
                        Theme.of(context).iconTheme.color!.withOpacity(0.6))),
            const SizedBox(height: 32),
            Pinput(
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                crossAxisAlignment: CrossAxisAlignment.center,
                validator: (s) {
                  if (s != pincode) {
                    var countInputPin = HiveHelper.get(Constants.COUNT_PIN_CODE,
                        defaultvalue: 0);
                    if (countInputPin == 2) {
                      PaymentInfoModel.removeAllListCard();
                      EasyLoading.showInfo(
                          TKeys.card_infomation_has_been_deleted_due
                              .translate(),
                          duration: const Duration(seconds: 5));
                      Get.back();
                      return "";
                    }
                    if (pincode != "") {
                      countInputPin = countInputPin + 1;
                    }
                    HiveHelper.put(Constants.COUNT_PIN_CODE, countInputPin);

                    return TKeys.wrong_entry_delete
                        .translate()
                        .replaceAll("{0}", "$countInputPin");
                  }
                  return "";
                },
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                showCursor: true,
                onCompleted: (pin) {
                  if (pincode == "") {
                    HiveHelper.put(Constants.LOCAL_PIN_CODE, pin);
                    Get.back(result: routeNextPage);
                    HiveHelper.put(Constants.COUNT_PIN_CODE, 0);
                  } else if (pincode == pin) {
                    Get.back(result: routeNextPage);
                    HiveHelper.put(Constants.COUNT_PIN_CODE, 0);
                  }
                }),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
