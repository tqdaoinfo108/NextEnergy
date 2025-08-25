import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:v2/services/localization_service.dart';

import '../../services/https.dart';

class NoInternetPage extends StatelessWidget {
  const NoInternetPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future<bool> checkBookingAvailiable() async {
      try {
        var booking = await HttpHelper.checkBookingAvailiable();
        if (booking != null && booking.data != null) {
          // ignore: use_build_context_synchronously
          Get.back();
          Get.toNamed("/charge_car", arguments: booking.data);
          return true;
        }
      } catch (e) {}
      return false;
    }

    Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      if (result != ConnectivityResult.none) {
        var isDeviceConnected = await InternetConnectionChecker().hasConnection;
        var isRouteOrther =  Get.currentRoute != "/charge_car" && Get.currentRoute != "/home";
        if (isDeviceConnected && isRouteOrther) {
          var isBookingAvaliable = await checkBookingAvailiable();
          if (!isBookingAvaliable) {
            Get.back();
          }
        }
      }
    });

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 112),
            child: Image.asset("assets/images/no_internet.png"),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Text(
              TKeys.no_internet_warning.translate(),
              textAlign: TextAlign.center,
            ),
          )
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 48),
          //   child: ButtonPrimary(TKeys.no_internet_try_again.translate(),
          //       onPress: () async {
          //     var isInternetConnect = await NetworkInfo().isConnected;
          //     if (isInternetConnect) {
          //       Get.back();
          //     }
          //   }),
          // )
        ]),
      ),
    );
  }
}
