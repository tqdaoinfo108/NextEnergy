import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v2/pages/customs/appbar.dart';
import 'package:v2/pages/customs/circular_progress_indicator.dart';
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
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBarCustom(
            title: Text(
              TKeys.session_device.translate(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
            ),
          ),
          body: SafeArea(
            child: controller.isLoading.value
                ? const Center(
                    child: CircularProgressIndicatorCustom(),
                  )
                : controller.listSessionDevice.value.totals == 0
                    ? _buildEmptyState(context)
                    : Column(
                        children: [
                          // Header with device count
                          Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.devices,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Thiết bị đã đăng nhập",
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                                        ),
                                      ),
                                      Text(
                                        "${controller.listSessionDevice.value.totals ?? 0} thiết bị",
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Device list
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: () => controller.getlistSessionDeviceBase(),
                              child: EasyLoadMore(
                                finishedStatusText: "",
                                isFinished: controller.listSessionDevice.value.data!.length >=
                                    (controller.listSessionDevice.value.totals ?? 0),
                                onLoadMore: () async => await controller.getlistSessionDeviceBaseNext(),
                                runOnEmptyResult: false,
                                child: ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  itemBuilder: (BuildContext context, int index) {
                                    return _buildDeviceCard(
                                        context,
                                        controller.listSessionDevice.value.data![index],
                                        index);
                                  },
                                  itemCount: controller.listSessionDevice.value.data!.length,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
          ),
        ));
  }

  // Build empty state widget
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.devices_other,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            TKeys.data_not_found.translate(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Chưa có thiết bị nào đăng nhập vào tài khoản của bạn",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  // Build modern device card
  Widget _buildDeviceCard(BuildContext context, SessionDeviceModel data, int index) {
    final isActive = (data.statusID ?? 0) == 1;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive 
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                  : Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Device header
              Row(
                children: [
                  // Device icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isActive 
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getDeviceIcon(data.deviceName ?? ""),
                      size: 20,
                      color: isActive 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Device name and status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.deviceName ?? "Unknown Device",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getDeviceType(data.deviceName ?? ""),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status indicator
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            TKeys.active.translate(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Device details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Lần cuối đăng nhập:",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        DateTimeUtils.getDateTimeString(data.lastLogin),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Get appropriate icon for device type
  IconData _getDeviceIcon(String deviceName) {
    final name = deviceName.toLowerCase();
    if (name.contains('iphone') || name.contains('ios')) {
      return Icons.phone_iphone;
    } else if (name.contains('android')) {
      return Icons.phone_android;
    } else if (name.contains('web') || name.contains('browser')) {
      return Icons.web;
    } else if (name.contains('tablet') || name.contains('ipad')) {
      return Icons.tablet;
    } else if (name.contains('desktop') || name.contains('windows') || name.contains('mac')) {
      return Icons.computer;
    }
    return Icons.device_unknown;
  }

  // Get device type description
  String _getDeviceType(String deviceName) {
    final name = deviceName.toLowerCase();
    if (name.contains('iphone')) {
      return "iPhone";
    } else if (name.contains('android')) {
      return "Android Device";
    } else if (name.contains('web') || name.contains('browser')) {
      return "Web Browser";
    } else if (name.contains('tablet') || name.contains('ipad')) {
      return "Tablet";
    } else if (name.contains('desktop') || name.contains('windows')) {
      return "Desktop";
    } else if (name.contains('mac')) {
      return "Mac";
    }
    return "Mobile Device";
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
