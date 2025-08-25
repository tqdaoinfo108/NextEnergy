import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:v2/model/notification_model.dart';
import 'package:v2/pages/customs/appbar.dart';
import 'package:v2/pages/customs/circular_progress_indicator.dart';
import 'package:v2/pages/customs/dialog_custom.dart';
import 'package:v2/pages/notification/notification_controller.dart';
import 'package:v2/services/localization_service.dart';

import '../../utils/date_time_utils.dart';
import '../customs/load_more_widget.dart';

class NotificationPage extends GetView<NotificationController> {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: AppBarCustom(
            title: Text(
              TKeys.notification.translate(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            actions: [
              IconButton(
                  onPressed: () async {
                    showDialogCustom(context, () async {
                      var isDelete = await controller.onClearNotification();

                      if (isDelete) {
                        EasyLoading.showSuccess(
                            // ignore: use_build_context_synchronously
                            TKeys.success.translate(),
                            duration: const Duration(seconds: 5));
                      } else {
                        EasyLoading.showError(
                            // ignore: use_build_context_synchronously
                            TKeys.fail_again.translate(),
                            duration: const Duration(seconds: 5));
                      }
                    }, question: TKeys.delete_noti.translate());
                  },
                  icon: const Icon(Icons.delete))
            ],
          ),
          body: SafeArea(
              child: controller.listNotify.value.totals == 0
                  ? Center(
                      child: Text(TKeys.data_not_found.translate()),
                    )
                  : controller.isLoading.value
                      ? const Center(
                          child: CircularProgressIndicatorCustom(),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: RefreshIndicator(
                            onRefresh: () => controller.getListNotifyBase(),
                            child: EasyLoadMore(
                              finishedStatusText: "",
                              isFinished:
                                  controller.listNotify.value.data!.length >=
                                      (controller.listNotify.value.totals ?? 0),
                              onLoadMore: () async =>
                                  await controller.getListNotifyBaseNext(),
                              runOnEmptyResult: false,
                              child: ListView.separated(
                                separatorBuilder: ((context, index) =>
                                    const SizedBox(
                                      height: 20.0,
                                    )),
                                itemBuilder: (BuildContext context, int index) {
                                  return buildNotificationItem(context,
                                      controller.listNotify.value.data![index]);
                                },
                                itemCount:
                                    controller.listNotify.value.data!.length,
                              ),
                            ),
                          ),
                        )),
        ));
  }

  Widget buildNotificationItem(context, NotificationModel data) {
    String getString(id) {
      if (id == 1) {
        return TKeys.charging.translate();
      } else if (id == 2) {
        return TKeys.stop_charging.translate();
      } else if (id == 3) {
        return TKeys.cancel.translate();
      } else if (id == 5) {
        return TKeys.payment.translate();
      } else {
        return "";
      }
    }

    String getTitleString(id) {
      if (id == 1) {
        return TKeys.create_booking_success.translate();
      } else if (id == 2) {
        return TKeys.charging_order_completed.translate();
      } else if (id == 5) {
        return TKeys.create_payment_success.translate();
      } else if (id == 3) {
        return TKeys.charging_cancel.translate();
      } else {
        return "";
      }
    }

    return Card(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(data.title ?? "",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).iconTheme.color)),
          Text(DateTimeUtils.getDateTimeString(data.createdDate),
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).iconTheme.color!.withOpacity(0.6))),
          const SizedBox(height: 6),
          Text(data.message ?? "",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Theme.of(context).iconTheme.color))
        ],
      ),
    ));
  }
}
