import 'dart:io' show InternetAddress, InternetAddressType, Platform;

import 'package:internet_connection_checker/internet_connection_checker.dart';

final List<AddressCheckOptions> DEFAULT_ADDRESSES =
    List<AddressCheckOptions>.unmodifiable(
  <AddressCheckOptions>[
    AddressCheckOptions(
      address: InternetAddress(
        '8.8.4.4', // Google
        type: InternetAddressType.IPv4,
      ),
    ),
    AddressCheckOptions(
      address: InternetAddress(
        '2001:4860:4860::8888', // Google
        type: InternetAddressType.IPv6,
      ),
    ),
    AddressCheckOptions(
      address: InternetAddress(
        '208.67.222.222', // OpenDNS
        type: InternetAddressType.IPv4,
      ), // OpenDNS
    ),
    AddressCheckOptions(
      address: InternetAddress(
        '2620:0:ccc::2', // OpenDNS
        type: InternetAddressType.IPv6,
      ), // OpenDNS
    ),
  ],
);

final InternetConnectionChecker customInstance =
    InternetConnectionChecker.createInstance(
        checkTimeout: const Duration(seconds: 1),
        checkInterval: const Duration(seconds: 1),
        addresses: DEFAULT_ADDRESSES);

abstract class INetworkInfo {
  Future<bool> get isConnected;
}

// Checks if the current device can connect to the internet (iOS and Android only).
class NetworkInfo implements INetworkInfo {
  NetworkInfo();

  /// Returns TRUE if the current device has an internet connection. Returns FALSE if the device doesn't.
  ///
  /// Returns TRUE by default for platforms that aren't iOS or Android.
  @override
  Future<bool> get isConnected async => Platform.isAndroid || Platform.isIOS
      ? await customInstance.hasConnection
      : true;
}
