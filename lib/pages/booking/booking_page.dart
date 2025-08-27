import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v2/model/booking_model.dart';
import 'package:v2/pages/booking/booking_controller.dart';
import 'package:v2/pages/customs/appbar.dart';
import 'package:v2/services/localization_service.dart';

import '../../utils/date_time_utils.dart';
import '../customs/load_more_widget.dart';

class BookingPage extends GetView<BookingController> {
  const BookingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() => Scaffold(
          backgroundColor: theme.colorScheme.background,
          
          body: SafeArea(
            child: _buildBody(context, theme),
          ),
        ));
  }

  Widget _buildBody(BuildContext context, ThemeData theme) {
    if (controller.isLoading.value &&
        controller.listBooking.value.data?.isEmpty == true) {
      return _buildLoadingState(theme);
    }

    if (controller.listBooking.value.totals == 0) {
      return _buildEmptyState(theme);
    }

    return _buildHistoryList(context, theme);
  }

  // Loading state with skeleton
  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Loading charging history...",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // Empty state with illustration
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.ev_station_outlined,
                size: 60,
                color: theme.primaryColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              TKeys.data_not_found.translate(),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Start charging to see your history here",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.add),
              label: const Text("Start Charging"),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // History list with pull-to-refresh and load more
  Widget _buildHistoryList(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: RefreshIndicator(
        onRefresh: () => controller.getListHistoryBase(),
        color: theme.primaryColor,
        child: EasyLoadMore(
          finishedStatusText: "",
          isFinished: controller.listBooking.value.data!.length >=
              (controller.listBooking.value.totals ?? 0),
          onLoadMore: () => controller.getListHistoryBookingBaseNext(),
          runOnEmptyResult: false,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16),
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (BuildContext context, int index) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 300 + (index * 50)),
                curve: Curves.easeOutBack,
                child: _buildHistoryCard(
                  context,
                  theme,
                  controller.listBooking.value.data![index],
                ),
              );
            },
            itemCount: controller.listBooking.value.data!.length,
          ),
        ),
      ),
    );
  }
}

// Modern history card với Material Design 3
Widget _buildHistoryCard(
    BuildContext context, ThemeData theme, BookingModel data) {
  final dateStart = DateTime.fromMillisecondsSinceEpoch(data.dateStart! * 1000);
  final dateEnd = DateTime.fromMillisecondsSinceEpoch(data.dateEnd! * 1000);

  return Container(
    decoration: BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        // Header với time range
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.primaryColor.withOpacity(0.1),
                theme.primaryColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: _buildTimeRange(context, theme, dateStart, dateEnd),
        ),

        // Content
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location info
              _buildLocationInfo(context, theme, data),

              const SizedBox(height: 16),

              // Stats grid
              _buildStatsGrid(context, theme, data),
            ],
          ),
        ),
      ],
    ),
  );
}

// Time range header
Widget _buildTimeRange(
    BuildContext context, ThemeData theme, DateTime start, DateTime end) {
  String formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  return Row(
    children: [
      // Start time
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          formatTime(start),
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Duration line
      Expanded(
        child: Container(
          height: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.primaryColor,
                theme.primaryColor.withOpacity(0.3),
              ],
            ),
          ),
        ),
      ),

      // End time
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade600,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          formatTime(end),
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}

// Location information
Widget _buildLocationInfo(
    BuildContext context, ThemeData theme, BookingModel data) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.ev_station,
              color: theme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.parkingName ?? "Unknown Station",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.addressParking ?? "No address",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          DateTimeUtils.getDateTimeString(data.dateBook),
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.blue,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}

// Stats grid
Widget _buildStatsGrid(
    BuildContext context, ThemeData theme, BookingModel data) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.grey.shade200,
        width: 1,
      ),
    ),
    child: Row(
      children: [
        _buildStatItem(theme, data.ambe?.toString() ?? "-", "A", "Current",
            Icons.electrical_services),
        _buildStatDivider(),
        _buildStatItem(
            theme, data.volt?.toString() ?? "-", "V", "Voltage", Icons.bolt),
        _buildStatDivider(),
        _buildStatItem(theme, data.powerConsumption?.toStringAsFixed(1) ?? "-",
            "kWh", "Energy", Icons.battery_charging_full),
        _buildStatDivider(),
        _buildStatItem(theme, "${data.priceAmount?.toInt() ?? 0}",
            data.unit ?? "¥", "Cost", Icons.payments),
      ],
    ),
  );
}

// Individual stat item
Widget _buildStatItem(
    ThemeData theme, String value, String unit, String label, IconData icon) {
  return Expanded(
    child: Column(
      children: [
        Icon(
          icon,
          color: theme.primaryColor,
          size: 20,
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              TextSpan(
                text: " $unit",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontSize: 10,
          ),
        ),
      ],
    ),
  );
}

// Stat divider
Widget _buildStatDivider() {
  return Container(
    width: 1,
    height: 40,
    color: Colors.grey.shade300,
    margin: const EdgeInsets.symmetric(horizontal: 8),
  );
}

// Legacy method để tương thích (có thể xóa sau)
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
                          .copyWith(color: Theme.of(context).iconTheme.color)),
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
                          .copyWith(color: Theme.of(context).iconTheme.color)),
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
                          .copyWith(color: Theme.of(context).iconTheme.color)),
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
                          .copyWith(color: Theme.of(context).iconTheme.color)),
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
