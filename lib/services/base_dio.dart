import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart' as Getx;
import 'package:v2/services/base_hive.dart';
import 'package:v2/utils/const.dart';

import 'network_connect.dart';

class DioRequest {
  static const baseURL = "https://apichargingvietnam.gvbsoft.vn";
  static Options get getOption => Options(
      sendTimeout: 15000,
      receiveTimeout: 15000,
      headers: {"Authorization": getCredential()});

  static String getCredential() {
    var userID = HiveHelper.get(Constants.USER_ID, defaultvalue: 0);
    if (userID != 0) {
      // ignore: prefer_interpolation_to_compose_strings
      return 'Basic ' + 
          base64.encode(utf8.encode(
              '${userID.toString()}:${HiveHelper.get(Constants.LAST_LOGIN)}'));
    }
    return "Basic VXNlckFQSU90b0NoYXJnaW5nOlBhc3NBUElPdG9DaGFyZ2luZw==";
  }

  static Future<Response?> getHttp(String path,
      {Map<String, dynamic>? query}) async {
    var isInternetConnect = await NetworkInfo().isConnected;
    if (!isInternetConnect && Getx.Get.currentRoute != "/termsofservice") {
      Getx.Get.toNamed("/no_internet");
      return null;
    }
    try {
      Response result = await Dio()
          .get(baseURL + path, options: getOption, queryParameters: query);
      return result;
    } on DioError catch (e) {
      print(e.response);
      if (e.response?.statusCode == 401 &&
          HiveHelper.get(Constants.USER_ID, defaultvalue: 0) != 0) {
        await FirebaseMessaging.instance.unsubscribeFromTopic(
            "user${HiveHelper.get(Constants.USER_ID, defaultvalue: 0)}");
        HiveHelper.remove(Constants.USER_ID);
        HiveHelper.remove(Constants.LAST_LOGIN);
        HiveHelper.remove(Constants.PAYMENT_CARD);
        HiveHelper.remove(Constants.LOCAL_PIN_CODE);
        Getx.Get.offAllNamed("/login");

        // flutterLocalNotificationsPlugin.show(
        //   DateTime.now().millisecondsSinceEpoch ~/ 1000,
        //   TKeys.notification.translate(),
        //   TKeys.device_loggin_by_another.translate(),
        //   NotificationDetails(
        //     android: AndroidNotificationDetails(
        //       channel.id,
        //       channel.name,
        //       channelDescription: channel.description,
        //       icon: '@mipmap/launcher_icon',
        //     ),
        //   ),
        // );
      }
      return null;
    }
  }

  static Future<Response?> post(String path,
      {Map<String, dynamic>? query, Map<String, dynamic>? data}) async {
    try {
      var isInternetConnect = await NetworkInfo().isConnected;
      if (!isInternetConnect && Getx.Get.currentRoute != "/termsofservice") {
        Getx.Get.toNamed("/no_internet");
        return null;
      }
      print("==============================================================");
      print("request: $baseURL$path");
      print("request: ${jsonEncode(data)}");
      var response = await Dio().post(baseURL + path,
          options: getOption, queryParameters: query, data: data);

      print("request: ${response.data}");

      return response;
    } on DioError catch (e) {
      print(e.response);
      if (e.response?.statusCode == 401 &&
          HiveHelper.get(Constants.USER_ID, defaultvalue: 0) != 0) {
        await FirebaseMessaging.instance.unsubscribeFromTopic(
            "user${HiveHelper.get(Constants.USER_ID, defaultvalue: 0)}");
        HiveHelper.remove(Constants.USER_ID);
        HiveHelper.remove(Constants.LAST_LOGIN);
        HiveHelper.remove(Constants.PAYMENT_CARD);
        HiveHelper.remove(Constants.LOCAL_PIN_CODE);
        Getx.Get.offAllNamed("/login");
      }

      if (path == "/api/payment/autopayment") {
        return Response(
            requestOptions: RequestOptions(path: path), data: e.response);
      }
      return null;
    }
  }
}
