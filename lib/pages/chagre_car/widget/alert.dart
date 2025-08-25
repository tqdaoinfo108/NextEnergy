import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:v2/pages/chagre_car/charge_car_controller.dart';

import '../../../services/localization_service.dart';

letCancelBooking(BuildContext cxt, ChargeCarController controller) {
  return showDialog<void>(
    context: cxt,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actionsOverflowAlignment: OverflowBarAlignment.center,
        title: Text(
          TKeys.cofirm_charge.translate(),
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Column(
                children: [
                  Text(
                    TKeys.time_is_still.translate(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontSize: 12),
                  ),
                  Text(
                    controller.getTimeStill,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    controller.isVip
                        ? TKeys.are_you_sure_want_to_end_member.translate()
                        : TKeys.are_you_sure_want_to_end.translate(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(TKeys.no.translate(),
                style: Theme.of(context).textTheme.bodyMedium),
            onPressed: () {
              Get.back();
            },
          ),
          TextButton(
            onPressed: () async {
              if (!controller.isAvailable) {
                EasyLoading.showError(TKeys.fail_again2.translate());
                return;
              }
              Get.back();
              await controller.onBookingComplete();
            },
            child: Text(TKeys.yes.translate(),
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      );
    },
  );
}
