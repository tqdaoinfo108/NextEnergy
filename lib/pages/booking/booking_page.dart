import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v2/model/booking_model.dart';
import 'package:v2/pages/booking/booking_controller.dart';
import 'package:v2/pages/customs/appbar.dart';
import 'package:v2/pages/customs/circular_progress_indicator.dart';
import 'package:v2/services/localization_service.dart';

import '../../utils/date_time_utils.dart';
import '../customs/load_more_widget.dart';

class BookingPage extends GetView<BookingController> {
  const BookingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Obx (() => Scaffold(
            appBar: AppBarCustom(
              title: Text(
                TKeys.history.translate(),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            body: SafeArea(
                child: controller.listBooking.value.totals == 0
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
                                  controller.getListHistoryBase(),
                              child: EasyLoadMore(
                                finishedStatusText: "",
                                isFinished:
                                    controller.listBooking.value.data!.length >=
                                        (controller.listBooking.value.totals ?? 0),
                                onLoadMore: () => controller
                                    .getListHistoryBookingBaseNext(),
                                runOnEmptyResult: false,
                                child: ListView.separated(
                                  separatorBuilder: ((context, index) =>
                                      const SizedBox(
                                        height: 20.0,
                                      )),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return buildNotificationItem(context,
                                        controller.listBooking.value.data![index]);
                                  },
                                  itemCount:
                                      controller.listBooking.value.data!.length,
                                ),
                              ),
                            ),
                          )),
          ));
  }

  Widget buildNotificationItem(context, BookingModel data) {
    var dateStart = DateTime.fromMillisecondsSinceEpoch(data.dateStart! * 1000);
    var dateEnd = DateTime.fromMillisecondsSinceEpoch(data.dateEnd! * 1000);

    String getMinute(int time) {
      if (time < 10) {
        return "0$time";
      } else {
        return "$time";
      }
    }

    return Card(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("${dateStart.hour}:${getMinute(dateStart.minute)}",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Theme.of(context).iconTheme.color)),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  color: Theme.of(context).iconTheme.color!.withOpacity(0.4),
                  height: 2,
                ),
              ),
              const SizedBox(width: 12),
              Text("${dateEnd.hour}:${getMinute(dateEnd.minute)}",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Theme.of(context).iconTheme.color)),
            ],
          ),
          const SizedBox(height: 6),
          Text(data.parkingName ?? "",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).iconTheme.color)),
          Text(data.addressParking ?? "",
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).iconTheme.color!.withOpacity(0.6))),
          Text(DateTimeUtils.getDateTimeString(data.dateBook),
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).iconTheme.color!.withOpacity(0.6))),
          const SizedBox(height: 6),
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(data.ambe == 0 ? "-" : data.ambe.toString(),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                color: Theme.of(context).iconTheme.color)),
                    Text("A",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: Theme.of(context).iconTheme.color))
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: VerticalDivider(
                    color: Theme.of(context).iconTheme.color!.withOpacity(0.4),
                    thickness: 1,
                  ),
                ),
                Column(
                  children: [
                    Text(data.volt == 0 ? "-" : data.volt.toString(),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                color: Theme.of(context).iconTheme.color)),
                    Text("V",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: Theme.of(context).iconTheme.color))
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: VerticalDivider(
                    color: Theme.of(context).iconTheme.color!.withOpacity(0.4),
                    thickness: 1,
                  ),
                ),
                Column(
                  children: [
                    Text(
                        data.powerConsumption == 0
                            ? "-"
                            : data.powerConsumption!.toStringAsFixed(1),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                color: Theme.of(context).iconTheme.color)),
                    Text("K",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: Theme.of(context).iconTheme.color))
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: VerticalDivider(
                    color: Theme.of(context).iconTheme.color!.withOpacity(0.4),
                    thickness: 1,
                  ),
                ),
                Column(
                  children: [
                    Text("${data.priceAmount?.toInt()}",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                color: Theme.of(context).iconTheme.color)),
                    Text("${data.unit}",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: Theme.of(context).iconTheme.color))
                  ],
                )
              ],
            ),
          )
        ],
      ),
    ));
  }
}
