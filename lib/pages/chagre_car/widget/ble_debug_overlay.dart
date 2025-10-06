import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleDebugOverlay extends StatelessWidget {
  final RxBool isDebugMode;
  final Rx<BleStatus> bleStatus;
  final Rx<DeviceConnectionState> connectionState;
  final RxList<DiscoveredDevice> nearbyDevices;
  final String targetDeviceName;
  final String? connectedDeviceId;
  final RxBool isAuthorized;
  final Rx<String> lastAction;
  final RxList<String> bleOperationLogs;

  const BleDebugOverlay({
    Key? key,
    required this.isDebugMode,
    required this.bleStatus,
    required this.connectionState,
    required this.nearbyDevices,
    required this.targetDeviceName,
    this.connectedDeviceId,
    required this.isAuthorized,
    required this.lastAction,
    required this.bleOperationLogs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!isDebugMode.value) return const SizedBox.shrink();

      return Positioned(
        top: 100,
        left: 10,
        right: 10,
        child: Material(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 500),
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '🔧 BLE Debug Panel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => isDebugMode.value = false,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const Divider(color: Colors.white24),
                const SizedBox(height: 8),

                // BLE Status
                _buildStatusRow(
                  '📡 BLE Status',
                  _getBleStatusText(bleStatus.value),
                  _getBleStatusColor(bleStatus.value),
                ),

                // Connection State
                _buildStatusRow(
                  '🔗 Connection',
                  _getConnectionStateText(connectionState.value),
                  _getConnectionStateColor(connectionState.value),
                ),

                // Authorization
                _buildStatusRow(
                  '🔐 Authorized',
                  isAuthorized.value ? 'YES' : 'NO',
                  isAuthorized.value ? Colors.green : Colors.red,
                ),

                // Target Device
                _buildInfoRow('🎯 Target', targetDeviceName),

                // Connected Device
                if (connectedDeviceId != null)
                  _buildInfoRow('📱 Connected ID', connectedDeviceId!),

                // Last Action
                _buildInfoRow('⚡ Last Action', lastAction.value),

                const SizedBox(height: 12),
                const Divider(color: Colors.white24),
                const SizedBox(height: 8),

                // Nearby Devices
                Text(
                  '📍 Nearby Devices (${nearbyDevices.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Device List
                Container(
                  constraints: const BoxConstraints(maxHeight: 150),
                  child: nearbyDevices.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'No devices found',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: nearbyDevices.length,
                          itemBuilder: (context, index) {
                            final device = nearbyDevices[index];
                            final isTarget = device.name == targetDeviceName;
                            final isConnected = device.id == connectedDeviceId;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isTarget
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isTarget
                                      ? Colors.green
                                      : Colors.white24,
                                  width: isTarget ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        isConnected
                                            ? Icons.bluetooth_connected
                                            : Icons.bluetooth,
                                        color: isTarget
                                            ? Colors.green
                                            : Colors.white70,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          device.name.isEmpty
                                              ? 'Unknown'
                                              : device.name,
                                          style: TextStyle(
                                            color: isTarget
                                                ? Colors.green
                                                : Colors.white,
                                            fontWeight: isTarget
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      if (isTarget)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'TARGET',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      if (isConnected)
                                        Container(
                                          margin: const EdgeInsets.only(left: 4),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'CONNECTED',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'ID: ${device.id}',
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    'RSSI: ${device.rssi} dBm',
                                    style: TextStyle(
                                      color: _getRssiColor(device.rssi),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                
                // BLE Operation Logs
                const SizedBox(height: 12),
                const Divider(color: Colors.white24),
                const SizedBox(height: 8),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '📝 BLE Operations',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '(${bleOperationLogs.length})',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                Container(
                  constraints: const BoxConstraints(maxHeight: 150),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: bleOperationLogs.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            'No operations yet',
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          reverse: true, // Latest at top
                          itemCount: bleOperationLogs.length,
                          itemBuilder: (context, index) {
                            final log = bleOperationLogs[bleOperationLogs.length - 1 - index];
                            
                            // Parse log type from prefix
                            Color logColor = Colors.white70;
                            IconData logIcon = Icons.circle;
                            
                            if (log.contains('✍️ WRITE')) {
                              logColor = Colors.blue;
                              logIcon = Icons.edit;
                            } else if (log.contains('📖 READ')) {
                              logColor = Colors.green;
                              logIcon = Icons.visibility;
                            } else if (log.contains('❌')) {
                              logColor = Colors.red;
                              logIcon = Icons.error;
                            } else if (log.contains('⚠️')) {
                              logColor = Colors.orange;
                              logIcon = Icons.warning;
                            }
                            
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.white10,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    logIcon,
                                    size: 12,
                                    color: logColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      log,
                                      style: TextStyle(
                                        color: logColor,
                                        fontSize: 11,
                                        fontFamily: 'monospace',
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      );
    });
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color, width: 1),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getBleStatusText(BleStatus status) {
    switch (status) {
      case BleStatus.ready:
        return 'READY';
      case BleStatus.poweredOff:
        return 'POWERED OFF';
      case BleStatus.unauthorized:
        return 'UNAUTHORIZED';
      case BleStatus.unsupported:
        return 'UNSUPPORTED';
      case BleStatus.locationServicesDisabled:
        return 'LOCATION DISABLED';
      default:
        return 'UNKNOWN';
    }
  }

  Color _getBleStatusColor(BleStatus status) {
    switch (status) {
      case BleStatus.ready:
        return Colors.green;
      case BleStatus.poweredOff:
        return Colors.red;
      case BleStatus.unauthorized:
        return Colors.orange;
      case BleStatus.unsupported:
        return Colors.red;
      case BleStatus.locationServicesDisabled:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getConnectionStateText(DeviceConnectionState state) {
    switch (state) {
      case DeviceConnectionState.connected:
        return 'CONNECTED';
      case DeviceConnectionState.connecting:
        return 'CONNECTING...';
      case DeviceConnectionState.disconnected:
        return 'DISCONNECTED';
      case DeviceConnectionState.disconnecting:
        return 'DISCONNECTING...';
    }
  }

  Color _getConnectionStateColor(DeviceConnectionState state) {
    switch (state) {
      case DeviceConnectionState.connected:
        return Colors.green;
      case DeviceConnectionState.connecting:
        return Colors.blue;
      case DeviceConnectionState.disconnected:
        return Colors.red;
      case DeviceConnectionState.disconnecting:
        return Colors.orange;
    }
  }

  Color _getRssiColor(int rssi) {
    if (rssi >= -60) return Colors.green;
    if (rssi >= -80) return Colors.orange;
    return Colors.red;
  }
}
