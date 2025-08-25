import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:v2/pages/chagre_car/widget/build_choose_plan.dart';
import 'package:v2/pages/customs/appbar.dart';
import 'package:v2/services/localization_service.dart';
import 'package:v2/utils/const.dart';
import '../customs/page_life_cycle.dart';
import 'charge_car_controller.dart';
import 'widget/buid_charging.dart';
import 'widget/build_wait_pluging.dart';

class ChargeCarPage extends GetView<ChargeCarController> {
  const ChargeCarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    Widget grantBluetoothWidget() {
      return Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(color: theme.iconTheme.color?.withOpacity(0.2)),
          IntrinsicHeight(
            child: Container(
              margin: const EdgeInsets.only(top: 40),
              width: Get.width / 7 * 6,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: const Color(0xffcc8e35),
                  border: Border.all(color: Colors.grey),
                  borderRadius: const BorderRadius.all(Radius.circular(12.0))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.info),
                      const SizedBox(width: 10),
                      Text(TKeys.notice.translate(),
                          style: theme.textTheme.bodyLarge),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(TKeys.grant_ble.translate(),
                      style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
          ),
        ],
      );
    }

    Widget stateBluetoothWidget() {
      return IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.bluetooth, size: 18),
                Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: controller.isOnBluetooth
                            ? Colors.green
                            : Colors.red)),
                const SizedBox(width: 4),
                const Icon(Icons.computer, size: 18),
                const SizedBox(width: 4),
                Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: controller.isAvailable
                            ? Colors.green
                            : Colors.red)),
                const SizedBox(width: 4),
                Text(
                    controller.isAvailable
                        ? TKeys.connecting.translate()
                        : TKeys.disconnect.translate(),
                    style: theme.textTheme.bodySmall),
                const SizedBox(width: 10)
              ],
            ),
          ],
        ),
      );
    }

    Column buildConnecting() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset("assets/images/ble_connecting.gif"),
          const SizedBox(height: 12),
          Text(TKeys.connecting.translate())
        ],
      );
    }

    return WillPopScope(
        onWillPop: () async {
          if (controller.canPop) {
            controller.back();
            return true;
          } else {
            EasyLoading.showInfo(TKeys.charging_can_not_go_back.translate());
            return false;
          }
        },
        child: PageLifecycle(
          stateChanged: (bool appeared) {},
          child: Obx(
            () => Scaffold(
              appBar: AppBarCustom(
                leading: (controller.pageEnum.value ==
                            ChargeCarPageEnum.WAIT_PLUGING ||
                        controller.pageEnum.value == ChargeCarPageEnum.CHARGING)
                    ? const SizedBox()
                    : null,
                actions: [Obx(() => stateBluetoothWidget())],
              ),
              body: Obx(
                () => Stack(
                  alignment: Alignment.topRight,
                  children: [
                    if (controller.pageEnum.value ==
                        ChargeCarPageEnum.CONNECTING)
                      buildConnecting()
                    else if (controller.pageEnum.value ==
                        ChargeCarPageEnum.CHOOSE_TIME)
                      buildChooseSlotCharge(context, controller)
                    else if (controller.pageEnum.value ==
                        ChargeCarPageEnum.WAIT_PLUGING)
                      buildWaitingConnectPlugging(context, controller)
                    else if (controller.pageEnum.value ==
                        ChargeCarPageEnum.CHARGING)
                      buildIsBegingStarted(context, controller),
                    // show popup

                    if (!controller.isOnBluetooth &&
                        controller.pageEnum.value != ChargeCarPageEnum.CHARGING)
                      grantBluetoothWidget()
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
