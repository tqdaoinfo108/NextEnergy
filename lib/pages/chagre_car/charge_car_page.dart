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
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: _buildAppBar(theme),
            body: _buildBody(theme),
            // Thêm floating connection status
            floatingActionButton: _buildConnectionFAB(theme),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          ),
        ));
  }

  // Connection status FAB
  Widget _buildConnectionFAB(ThemeData theme) {
    return Obx(() {
      if (controller.pageEnum.value == ChargeCarPageEnum.CHARGING ||
          controller.pageEnum.value == ChargeCarPageEnum.WAIT_PLUGING) {
        return const SizedBox.shrink();
      }
      
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: controller.isAvailable
            ? FloatingActionButton.small(
                onPressed: null,
                backgroundColor: Colors.green,
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20,
                ),
              )
            : FloatingActionButton.small(
                onPressed: () => _handleRetryConnection(),
                backgroundColor: Colors.orange,
                child: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                  size: 20,
                ),
              ),
      );
    });
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

  // Tối ưu Bluetooth status widget với colors dễ thấy hơn
  Widget _buildBluetoothStatus(ThemeData theme) {
    return Obx(() {
      final isConnecting = controller.pageEnum.value == ChargeCarPageEnum.CONNECTING;
      final isAvailable = controller.isAvailable;
      final isBluetoothOn = controller.isOnBluetooth;
      
      Color statusColor;
      Color backgroundColor;
      String statusText;
      IconData statusIcon;
      
      if (!isBluetoothOn) {
        statusColor = Colors.white;
        backgroundColor = Colors.red.shade600;
        statusText = "Bluetooth Off";
        statusIcon = Icons.bluetooth_disabled;
      } else if (isConnecting) {
        statusColor = Colors.white;
        backgroundColor = Colors.orange.shade600;
        statusText = TKeys.connecting.translate();
        statusIcon = Icons.bluetooth_searching;
      } else if (isAvailable) {
        statusColor = Colors.white;
        backgroundColor = Colors.green.shade600;
        statusText = "Connected";
        statusIcon = Icons.bluetooth_connected;
      } else {
        statusColor = Colors.white;
        backgroundColor = Colors.red.shade600;
        statusText = TKeys.disconnect.translate();
        statusIcon = Icons.bluetooth_disabled;
      }
      
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated icon với loading effect
            isConnecting
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  )
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      statusIcon,
                      key: ValueKey(statusIcon),
                      size: 16,
                      color: statusColor,
                    ),
                  ),
            const SizedBox(width: 8),
            
            // Status text với high contrast
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              child: Text(statusText),
            ),
            
            // Signal strength indicator (if connected)
            if (isAvailable && !isConnecting) ...[
              const SizedBox(width: 8),
              _buildSignalStrength(statusColor),
            ],
          ],
        ),
      );
    });
  }

  // Signal strength indicator với contrast cao
  Widget _buildSignalStrength(Color color) {
    return Row(
      children: List.generate(3, (index) {
        return Container(
          width: 2,
          height: 6 + (index * 2).toDouble(),
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }

  // Tối ưu body với loading states
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
          
        // API Loading overlay (sử dụng isLoading từ GetxControllerCustom)
        if (controller.isLoading.value)
          _buildLoadingOverlay(theme),
      ],
    ));
  }

  // API Loading overlay
  Widget _buildLoadingOverlay(ThemeData theme) {
    return Positioned.fill(
      child: Container(
        color: Colors.black26,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(24),
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
                // Loading animation
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                Text(
                  "Processing...",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  "Please wait while we process your request",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Main content với enhanced transitions
  Widget _buildMainContent(ThemeData theme) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(controller.pageEnum.value),
        child: _getPageContent(theme),
      ),
    );
  }

  // Get page content based on current state
  Widget _getPageContent(ThemeData theme) {
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

  // Tối ưu connecting widget với progress và status
  Widget _buildConnecting(ThemeData theme) {
    return Obx(() => Center(
      key: const ValueKey('connecting'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Modern loading animation với pulse effect
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer pulse animation
                AnimatedContainer(
                  duration: const Duration(seconds: 2),
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.primaryColor.withOpacity(0.1),
                  ),
                ),
                // Middle pulse
                AnimatedContainer(
                  duration: const Duration(milliseconds: 1500),
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.primaryColor.withOpacity(0.2),
                  ),
                ),
                // Core progress indicator
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                  ),
                ),
                // Center icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    controller.isOnBluetooth 
                        ? Icons.bluetooth_searching 
                        : Icons.bluetooth_disabled,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Status title
            Text(
              _getConnectionStatusTitle(),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Status message
            Text(
              _getConnectionStatusMessage(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Connection progress steps
            _buildConnectionSteps(theme),
            
            const SizedBox(height: 32),
            
            // Action buttons
            _buildConnectionActions(theme),
          ],
        ),
      ),
    ));
  }

  // Connection status title
  String _getConnectionStatusTitle() {
    if (!controller.isOnBluetooth) {
      return "Bluetooth Required";
    } else if (controller.pageEnum.value == ChargeCarPageEnum.CONNECTING) {
      return TKeys.connecting.translate();
    } else {
      return "Connection Failed";
    }
  }

  // Connection status message  
  String _getConnectionStatusMessage() {
    if (!controller.isOnBluetooth) {
      return "Please enable Bluetooth to connect to the charging station";
    } else if (controller.pageEnum.value == ChargeCarPageEnum.CONNECTING) {
      return "Connecting to your charging station...";
    } else {
      return "Unable to connect to the charging station. Please try again.";
    }
  }

  // Connection progress steps
  Widget _buildConnectionSteps(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildStep(
            theme,
            1,
            "Enable Bluetooth",
            controller.isOnBluetooth,
            Icons.bluetooth,
          ),
          const SizedBox(height: 12),
          _buildStep(
            theme,
            2,
            "Scan for device",
            controller.isOnBluetooth && controller.pageEnum.value == ChargeCarPageEnum.CONNECTING,
            Icons.search,
          ),
          const SizedBox(height: 12),
          _buildStep(
            theme,
            3,
            "Establish connection",
            controller.isAvailable,
            Icons.link,
          ),
        ],
      ),
    );
  }

  // Individual connection step
  Widget _buildStep(ThemeData theme, int step, String title, bool isActive, IconData icon) {
    final isCompleted = isActive && step < 3;
    final color = isCompleted 
        ? Colors.green 
        : isActive 
            ? theme.primaryColor 
            : Colors.grey.shade400;
    
    return Row(
      children: [
        // Step indicator
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: isCompleted
              ? Icon(Icons.check, color: color, size: 18)
              : isActive && step == 2
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    )
                  : Icon(icon, color: color, size: 18),
        ),
        
        const SizedBox(width: 12),
        
        // Step title
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  // Connection action buttons
  Widget _buildConnectionActions(ThemeData theme) {
    return Obx(() => Column(
      children: [
        // Retry button (show when not connected and bluetooth is on)
        if (controller.isOnBluetooth && !controller.isAvailable)
          ElevatedButton.icon(
            onPressed: () => _handleRetryConnection(),
            icon: const Icon(Icons.refresh),
            label: Text(TKeys.retry.translate()),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          
        // Enable Bluetooth button (show when bluetooth is off)
        if (!controller.isOnBluetooth)
          ElevatedButton.icon(
            onPressed: () => _handleEnableBluetooth(),
            icon: const Icon(Icons.bluetooth),
            label: Text("Enable Bluetooth"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          
        const SizedBox(height: 12),
        
        // Cancel button
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            TKeys.cancel.translate(),
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      ],
    ));
  }

  // Handle retry connection with loading
  Future<void> _handleRetryConnection() async {
    EasyLoading.show(status: "Reconnecting...");
    try {
      await controller.connectDevice();
    } finally {
      EasyLoading.dismiss();
    }
  }

  // Handle enable bluetooth with loading
  Future<void> _handleEnableBluetooth() async {
    EasyLoading.show(status: "Enabling Bluetooth...");
    try {
      await controller.enableBluetoothAndReconnect();
    } finally {
      EasyLoading.dismiss();
    }
  }

  // Tối ưu Bluetooth grant overlay với loading states
  Widget _buildBluetoothGrantOverlay(ThemeData theme) {
    return Positioned.fill(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: Colors.black54,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Bluetooth icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.withOpacity(0.2),
                        Colors.orange.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.bluetooth_disabled,
                        size: 48,
                        color: Colors.orange,
                      ),
                      // Pulse animation
                      TweenAnimationBuilder(
                        duration: const Duration(seconds: 2),
                        tween: Tween<double>(begin: 0.5, end: 1.0),
                        builder: (context, double value, child) {
                          return Container(
                            width: 80 * value,
                            height: 80 * value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.orange.withOpacity(1 - value),
                                width: 2,
                              ),
                            ),
                          );
                        },
                        onEnd: () {
                          // Restart animation
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Title
                Text(
                  TKeys.notice.translate(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                // Description
                Text(
                  "Bluetooth is required to connect to the charging station. Please enable Bluetooth to continue.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),
                
                // Action buttons
                Column(
                  children: [
                    // Enable Bluetooth button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _handleEnableBluetoothOverlay(),
                        icon: const Icon(Icons.bluetooth),
                        label: Text("Enable Bluetooth"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Cancel button
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          TKeys.cancel.translate(),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Help text
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "You can also enable Bluetooth from your device settings",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.blue,
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
      ),
    );
  }

  // Handle enable bluetooth from overlay with loading
  Future<void> _handleEnableBluetoothOverlay() async {
    EasyLoading.show(status: "Enabling Bluetooth...");
    try {
      await controller.enableBluetoothAndReconnect();
    } finally {
      EasyLoading.dismiss();
    }
  }
}
