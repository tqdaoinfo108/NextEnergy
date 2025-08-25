import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:v2/model/notification_model.dart';
import 'package:v2/pages/customs/appbar.dart';
import 'package:v2/pages/customs/circular_progress_indicator.dart';
import 'package:v2/pages/customs/dialog_custom.dart';
import 'package:v2/services/localization_service.dart';

import '../../model/session_device_model.dart';
import '../../utils/date_time_utils.dart';
import '../customs/load_more_widget.dart';
import 'session_device_controller.dart';

class SessionDevicePage extends GetView<SessionDeviceController> {
  const SessionDevicePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          appBar: AppBarCustom(
            title: Text(
              TKeys.session_device.translate(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          body: SafeArea(
              child: controller.listSessionDevice.value.totals == 0
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
                            onRefresh: () =>
                                controller.getlistSessionDeviceBase(),
                            child: EasyLoadMore(
                              finishedStatusText: "",
                              isFinished: controller
                                      .listSessionDevice.value.data!.length >=
                                  (controller.listSessionDevice.value.totals ??
                                      0),
                              onLoadMore: () async => await controller
                                  .getlistSessionDeviceBaseNext(),
                              runOnEmptyResult: false,
                              child: ListView.separated(
                                separatorBuilder: ((context, index) =>
                                    const SizedBox(
                                      height: 20.0,
                                    )),
                                itemBuilder: (BuildContext context, int index) {
                                  return buildNotificationItem(
                                      context,
                                      controller.listSessionDevice.value
                                          .data![index]);
                                },
                                itemCount: controller
                                    .listSessionDevice.value.data!.length,
                              ),
                            ),
                          ),
                        )),
        ));
  }

  Widget buildNotificationItem(context, SessionDeviceModel data) {
    return Card(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(data.deviceName ?? "",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).iconTheme.color)),
          Row(
            children: [
              Text(DateTimeUtils.getDateTimeString(data.lastLogin),
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color:
                          Theme.of(context).iconTheme.color!.withOpacity(0.6))),
              const Spacer(),
              if ((data.statusID ?? 0) == 1)
                Row(
                  children: [
                    const Icon(Icons.trip_origin,
                        color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Text(TKeys.active.translate(),
                        style: Theme.of(context).textTheme.bodyMedium)
                  ],
                )
            ],
          ),
        ],
      ),
    ));
  }
}
