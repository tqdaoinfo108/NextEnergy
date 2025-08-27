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
    final theme = Theme.of(context);
    
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
          stateChanged: (bool appeared) {
            // Auto-reconnect khi trang xuất hiện lại
            if (appeared && !controller.isAvailable) {
              controller.handlePageReappear();
            }
          },
          child: Scaffold(
            appBar: _buildAppBar(theme),
            body: _buildBody(theme),
          ),
        ));
  }

  // Tách AppBar thành method riêng để tối ưu rebuild
  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBarCustom(
      leading: Obx(() {
        final shouldHideLeading = controller.pageEnum.value == ChargeCarPageEnum.WAIT_PLUGING ||
            controller.pageEnum.value == ChargeCarPageEnum.CHARGING;
        return shouldHideLeading ? const SizedBox.shrink() : const BackButton();
      }),
      actions: [_buildBluetoothStatus(theme)],
    );
  }

  // Tối ưu Bluetooth status widget
  Widget _buildBluetoothStatus(ThemeData theme) {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: controller.isAvailable 
            ? Colors.green.withOpacity(0.1) 
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: controller.isAvailable ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bluetooth, 
            size: 16,
            color: controller.isOnBluetooth ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.router,
            size: 16, 
            color: controller.isAvailable ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 6),
          Text(
            controller.isAvailable
                ? TKeys.connecting.translate()
                : TKeys.disconnect.translate(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: controller.isAvailable ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ));
  }

  // Tối ưu body với cached widgets
  Widget _buildBody(ThemeData theme) {
    return Obx(() => Stack(
      children: [
        // Main content với AnimatedSwitcher để smooth transition
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildMainContent(theme),
        ),
        
        // Bluetooth grant overlay
        if (!controller.isOnBluetooth &&
            controller.pageEnum.value != ChargeCarPageEnum.CHARGING)
          _buildBluetoothGrantOverlay(theme),
      ],
    ));
  }

  // Main content với key để AnimatedSwitcher hoạt động
  Widget _buildMainContent(ThemeData theme) {
    switch (controller.pageEnum.value) {
      case ChargeCarPageEnum.CONNECTING:
        return _buildConnecting(theme);
      case ChargeCarPageEnum.CHOOSE_TIME:
        return buildChooseSlotCharge(Get.context!, controller);
      case ChargeCarPageEnum.WAIT_PLUGING:
        return buildWaitingConnectPlugging(Get.context!, controller);
      case ChargeCarPageEnum.CHARGING:
        return buildIsBegingStarted(Get.context!, controller);
      default:
        return _buildConnecting(theme);
    }
  }

  // Tối ưu connecting widget
  Widget _buildConnecting(ThemeData theme) {
    return Center(
      key: const ValueKey('connecting'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Thay gif bằng loading animation tối ưu hơn
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            TKeys.connecting.translate(),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            TKeys.grant_ble.translate(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          // Thêm retry button
          Obx(() => !controller.isAvailable 
              ? ElevatedButton.icon(
                  onPressed: () => controller.connectDevice(),
                  icon: const Icon(Icons.refresh),
                  label: Text(TKeys.retry.translate()),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24, 
                      vertical: 12,
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  // Tối ưu Bluetooth grant overlay
  Widget _buildBluetoothGrantOverlay(ThemeData theme) {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.bluetooth_disabled,
                    size: 48,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  TKeys.notice.translate(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  TKeys.grant_ble.translate(),
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    await controller.enableBluetoothAndReconnect();
                  },
                  icon: const Icon(Icons.bluetooth),
                  label: Text(TKeys.grant_ble.translate()),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24, 
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
