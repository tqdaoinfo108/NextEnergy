import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:v2/pages/chagre_car/charge_car_controller.dart';

import '../../../services/localization_service.dart';
import '../../customs/flutter_animation_progress_bar.dart';
import '../ext_charge_car_popup.dart';

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

Widget buildButton(BuildContext context, ChargeCarController controller) {
  return Opacity(
    opacity: controller.isAvailable ? 1 : 0.4,
    child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      width: MediaQuery.of(context).size.width / 2.4,
      child: ListTile(
        onTap: () async {
          if (!controller.isAvailable) return;

          // ignore: use_build_context_synchronously
          showFlexibleBottomSheet<void>(
            minHeight: 0,
            initHeight: 0.6,
            maxHeight: 0.6,
            anchors: [0, 0.6],
            context: context,
            isSafeArea: true,
            bottomSheetColor: Theme.of(context).scaffoldBackgroundColor,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0))),
            builder: (context1, controller1, offset) {
              return ExtTimeChargeCarBottomSheet(
                scrollController: controller1,
                bottomSheetOffset: offset,
                cxt: context1,
                controller: controller,
              );
            },
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        horizontalTitleGap: 0,
        leading: const Icon(Icons.add_circle),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
              controller.isVip
                  ? TKeys.buy_more_member.translate()
                  : TKeys.buy_more.translate(),
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ]),
      ),
    ),
  );
}

Widget buildButtonClose(BuildContext context, ChargeCarController controller) {
  return Opacity(
    opacity: controller.isAvailable ? 1 : 0.4,
    child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).iconTheme.color,
        borderRadius: BorderRadius.circular(12.0),
      ),
      width: MediaQuery.of(context).size.width / 2.4,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        onTap: () async {
          if (!controller.isAvailable) return;
          letCancelBooking(context, controller);
        },
        horizontalTitleGap: 0,
        leading: Icon(
          Icons.close,
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.4),
        ),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            TKeys.stop_charging.translate(),
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Theme.of(context).scaffoldBackgroundColor),
          ),
        ]),
      ),
    ),
  );
}

Widget buildIsBegingStarted(
    BuildContext context, ChargeCarController controller) {
  return Obx(() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                    width: 60,
                    height: 60,
                    child: Lottie.asset('assets/images/charging.json')),
                const SizedBox(height: 10),
                Text(TKeys.charging.translate(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 24))
              ],
            ),
            const SizedBox(height: 12),
            Image.asset(
              "assets/images/charge.gif",
              width: Get.width / 2,
            ),
            const SizedBox(height: 12),
            Text(TKeys.do_note_remove_flag.translate(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 12),
            Text(
                "${controller.getTimeStillText.value} / ${controller.getTimeTotalsText.value}",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(fontSize: 15)),
            const SizedBox(height: 8),
            FAProgressBar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              currentValue: controller.percentProcessbar.value,
              maxValue: controller.bookingData?.getDurationTimeEnd ?? 100,
              displayText: '',
              displayTextStyle: const TextStyle(fontSize: 0),
              progressGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: const Alignment(0.8, 1),
                colors: <Color>[
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.7),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildButtonClose(context, controller),
                const SizedBox(width: 12),
                buildButton(context, controller),
              ],
            ),
          ],
        ),
      ));
}
