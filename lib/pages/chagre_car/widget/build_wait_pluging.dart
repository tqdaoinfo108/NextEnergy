import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:v2/pages/chagre_car/charge_car_controller.dart';

import '../../../services/localization_service.dart';
import '../../../utils/const.dart';
import '../../customs/count_down.dart';

Padding buildWaitingConnectPlugging(
    BuildContext context, ChargeCarController controller) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
    child: Stack(
      children: [
        Countdown(
            controller: controller.countdownController,
            seconds: controller.expiredTimeValue,
            build: (BuildContext context, double time) =>
                Text("${TKeys.time_remaining.translate()} ${time.toInt()}"),
            interval: const Duration(seconds: 1),
            onFinished: () async {
              if (controller.pageEnum.value == ChargeCarPageEnum.WAIT_PLUGING) {
                await controller.onUpdateAffterHardware(-1);
                EasyLoading.showError(
                    TKeys.booking_failed_to_not_begin_connect.translate(),
                    duration: const Duration(seconds: 5));
                controller.back();
              }
            }),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset("assets/images/plugin_car.gif"),
            ),
            const SizedBox(height: 20),
            Text(
              controller.isVip
                  ? TKeys.pls_attaach_charger_to_vehicle_member.translate()
                  : TKeys.pls_attaach_charger_to_vehicle.translate(),
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ],
        ),
      ],
    ),
  );
}
