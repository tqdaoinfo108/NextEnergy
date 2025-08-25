import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:v2/model/config.dart';
import 'package:v2/model/member_code_model.dart';
import 'package:v2/model/notification_model.dart';
import '../model/booking_model.dart';
import '../model/park_model.dart';
import '../model/payment_model.dart';
import '../model/price_model.dart';
import '../model/session_device_model.dart';
import '../model/user_model.dart';
import '../services/base_dio.dart';
import '../services/base_hive.dart';
import '../utils/const.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../model/response_base.dart';

class HttpHelper {
  static Future<ResponseBase<UserModel>?> login(
      String phone, String password, String phoneArea) async {
    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      await FirebaseMessaging.instance.deleteToken();
      var token = await FirebaseMessaging.instance.getToken();
      HiveHelper.put(Constants.FIREBASE_TOKEN, token);

      var deviceName = (await deviceInfoPlugin.deviceInfo).data;
      var deviceNameString = Platform.isAndroid
          ? deviceName["manufacturer"] + " " + deviceName["product"]
          : deviceName["name"];

      var response = await DioRequest.post("/api/user/login", data: {
        "PhoneArea": phoneArea,
        "UUserID": phone,
        "PassWord": password,
        "TokenKey": token,
        "DeviceName": deviceNameString
      });
      if (response != null) {
        return UserModel.getUserResponse(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<ResponseBase<UserModel>?> register(
      String phoneArea, String phone, bool isRenew) async {
    try {
      var response = await DioRequest.post("/api/user/register",
          data: {"PhoneArea": phoneArea, "Phone": phone, "IsRenew": isRenew});
      if (response != null) {
        return UserModel.getUserResponse(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<ResponseBase<UserModel>?> sentOTPAgain(
      String phone, String phoneArea) async {
    try {
      var response = await DioRequest.post("/api/user/sentotptouseragain",
          data: {"PhoneArea": phoneArea, "Phone": phone});
      if (response != null) {
        return UserModel.getUserResponse(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<ResponseBase<UserModel>?> sentOTPAgainForgotPassword(
      String phone, String phoneArea) async {
    try {
      var response = await DioRequest.post("/api/user/sentotpforgotpassword",
          data: {"PhoneArea": phoneArea, "Phone": phone});
      if (response != null) {
        return UserModel.getUserResponse(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<ResponseBase<UserModel>?> getProfile(int userID) async {
    try {
      var response = await DioRequest.getHttp("/api/user/profile",
          query: {"userID": userID});
      if (response != null) {
        return UserModel.getUserResponse(response.data);
      }
      return null;
    } catch (e) {
      if (e is DioError) {
        return ResponseBase(message: e.error);
      }
      return null;
    }
  }

  static Future<ResponseBase<UserModel>?> updateAvatar(
      String imageSource) async {
    try {
      var response = await DioRequest.post("/api/user/uploadavatar", data: {
        "UserID": HiveHelper.get(Constants.USER_ID),
        "UserName": HiveHelper.get(Constants.USER_ID).toString(),
        "ImagesPaths": imageSource
      });
      if (response != null) {
        return UserModel.getUserResponse(response.data);
      }
      return null;
    } catch (e) {
      if (e is DioError) {
        return ResponseBase(message: e.error);
      }
      return null;
    }
  }

  static Future<ResponseBase<bool>?> deleteAccount() async {
    try {
      var response = await DioRequest.post("/api/user/delete",
          data: {"UserID": HiveHelper.get(Constants.USER_ID)});
      if (response != null) {
        return ResponseBase<bool>.fromJson(response.data);
      }
      return null;
    } catch (e) {
      if (e is DioError) {
        return ResponseBase(message: e.error);
      }
      return null;
    }
  }

  static Future<ResponseBase<UserModel>?> forgetPassword(
      String phone, String phoneArea, String password) async {
    try {
      var response = await DioRequest.post("/api/user/forgotpassword", data: {
        "PhoneArea": phoneArea,
        "UUserID": phone,
        "PassWordNew": password,
        "PassWordNewAgain": password
      });
      if (response != null) {
        return UserModel.getUserResponse(response.data);
      }
      return null;
    } catch (e) {
      if (e is DioError) {
        return ResponseBase(message: e.error);
      }
      return null;
    }
  }

  static Future<ResponseBase<List<ConfigModel>>?> getConfig() async {
    try {
      var response = await DioRequest.getHttp("/api/config/getlist");
      if (response != null) {
        return ConfigModel.getListConfigResponse(response.data);
      }
      return null;
    } catch (e) {
      if (e is DioError) {
        return ResponseBase(message: e.error);
      }
      return null;
    }
  }

  static Future<ResponseBase<UserModel>?> updateAccount(
      String password, String email, String fullName, String languageCode,
      {int? userID}) async {
    try {
      var token = await FirebaseMessaging.instance.getToken();
      HiveHelper.put(Constants.FIREBASE_TOKEN, token);

      final deviceInfoPlugin = DeviceInfoPlugin();
      var deviceName = (await deviceInfoPlugin.deviceInfo).data;
      var deviceNameString = Platform.isAndroid
          ? deviceName["manufacturer"] + " " + deviceName["product"]
          : deviceName["name"];
      userID ??= HiveHelper.get(Constants.USER_ID);
      var response = await DioRequest.post("/api/user/update", data: {
        "UserID": userID,
        "Password": password,
        "Email": email,
        "FullName": fullName,
        "LanguageCode": languageCode,
        "LastLogin": DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000,
        "Status": 1,
        "TokenKey": token,
        "DeviceName": deviceNameString
      });
      if (response != null) {
        return UserModel.getUserResponse(response.data);
      }
      return null;
    } catch (e) {
      if (e is DioError) {
        return ResponseBase(message: e.error);
      }
      return null;
    }
  }

  static Future<ResponseBase<UserModel>?> changePassword(
      String passwordOld, String passwordNew) async {
    try {
      var response = await DioRequest.post("/api/user/changepass", data: {
        "UserID": HiveHelper.get(Constants.USER_ID),
        "PassWordOld": passwordOld,
        "PassWordNew": passwordNew
      });
      if (response != null) {
        return UserModel.getUserResponse(response.data);
      }
      return null;
    } catch (e) {
      if (e is DioError) {
        return ResponseBase(message: e.error);
      }
      return null;
    }
  }

  static Future<ResponseBase<List<ParkingModel>>> getListParkSlot(
      String keyword, int page, int limit, double lat, double lng) async {
    try {
      var response = await DioRequest.getHttp("/api/parkinglot/get", query: {
        "userID": HiveHelper.get(Constants.USER_ID),
        "keySearch": keyword,
        "page": page,
        "limit": limit,
        "Latitude": lat,
        "Longitude": lng
      });
      if (response != null) {
        return ParkingModel.getListParkingResponse(response.data);
      }
      return ResponseBase(data: []);
    } catch (e) {
      if (e is DioError) {
        return ResponseBase(message: e.error);
      }
      return ResponseBase(data: []);
    }
  }

  static Future<ResponseBase<List<PriceModel>>> getPrice(
      String hardwareID, int userID) async {
    try {
      var response = await DioRequest.getHttp("/api/price/get",
          query: {"hardwareID": hardwareID, "userID": userID});
      if (response != null) {
        return PriceModel.getListPriceResponse(response.data);
      }
      return ResponseBase(data: []);
    } catch (e) {
      if (e is DioError) {
        return ResponseBase(message: e.error);
      }
      return ResponseBase(data: []);
    }
  }

  static Future<ResponseBase<List<NotificationModel>>> getNotification(int page,
      {int limit = 20}) async {
    try {
      var response =
          await DioRequest.getHttp("/api/notification/getlist", query: {
        "userID": HiveHelper.get(Constants.USER_ID),
        "page": page,
        "limit": limit,
        "languageCode":
            HiveHelper.get(Constants.LANGUAGE_CODE, defaultvalue: "en")
      });
      if (response != null) {
        return NotificationModel.getListNotificationResponse(response.data);
      }
      return ResponseBase(data: []);
    } catch (e) {
      if (e is DioError) {
        return ResponseBase(message: e.error, totals: 0);
      }
      return ResponseBase(data: []);
    }
  }

  static Future<String> updateHardware(Map<String, dynamic> bodyData) async {
    try {
      var response = await DioRequest.post(
          "/api/parkinglot/updatestatushardware",
          data: bodyData);

      if (response != null) {
        return ResponseBase<String>.fromJson(response.data).data ?? "ERORR";
      }
      return "ERORR";
    } catch (e) {
      return "ERORR";
    }
  }

  static Future<ResponseBase<PaymentModel>?> autoPayment(
      String hardwareID, int priceID, int? bookingID,
      {String cardNumber = "",
      String cardExpire = "",
      String securityCode = "",
      String holderName = ""}) async {
    var response;
    try {
      var mapData = {
        "HardwareID": hardwareID,
        "UserID": HiveHelper.get(Constants.USER_ID),
        "TimeZoneName":
            HiveHelper.get(Constants.LANGUAGE_CODE, defaultvalue: "en"),
        "PriceID": priceID,
        "cardNumber": cardNumber,
        "cardExpire": cardExpire,
        "securityCode": securityCode,
        "holderName": holderName
      };
      if (bookingID != null) {
        mapData.addAll({"BookID": bookingID});
      }
      var response =
          await DioRequest.post("/api/payment/autopayment", data: mapData);
      if (response?.data["message"] ==
          "Can not Charging because limit in Area.") {
        return ResponseBase<PaymentModel>(
            message: "Can not Charging because limit in Area.");
      }
      if (response != null) {
        return PaymentModel.getPaymentData(response.data);
      }
      return null;
    } catch (e) {
      if (e is DioError) {
        return ResponseBase(message: e.error);
      }
      return null;
    }
  }

  static Future<ResponseBase<BookingModel>?> checkBookingAvailiable() async {
    try {
      var response = await DioRequest.post("/api/booking/checkuserbooking",
          data: {"UserID": HiveHelper.get(Constants.USER_ID)});
      if (response != null) {
        return BookingModel.getBookingDetail(response.data);
      }
      return null;
    } catch (e) {
      if (e is DioError) {
        return ResponseBase(message: e.error);
      }
      return null;
    }
  }

  static Future<ResponseBase<List<BookingModel>>> getHistoryBooking(int page,
      {int limit = 20}) async {
    try {
      var response =
          await DioRequest.getHttp("/api/booking/gethistorybooking", query: {
        "userID": HiveHelper.get(Constants.USER_ID),
        "status": 1,
        "page": page,
        "limit": limit
      });
      if (response != null) {
        return BookingModel.getListHistoryBookingResponse(response.data);
      }
      return ResponseBase(data: []);
    } catch (e) {
      if (e is DioError) {
        return ResponseBase(message: e.error);
      }
      return ResponseBase(data: []);
    }
  }

  static Future<ResponseBase<PaymentModel>?> updatePayment(
      int paymentID, int status) async {
    try {
      var response = await DioRequest.post("/api/payment/update",
          data: {"PaymentID": paymentID.toInt(), "Status": status.toInt()});
      if (response != null) {
        return PaymentModel.getPaymentData(response.data);
      }
      return null;
    } catch (e) {
      if (e is DioError) {
        return ResponseBase(message: e.error);
      }
      return null;
    }
  }

  static Future<ResponseBase<PaymentModel>?> updatePaymentAfterWaitHardware(
      int paymentID, int status,
      {bool isExtTime = false}) async {
    try {
      var response = await DioRequest.post(
          "/api/payment/updatebookingafterwaithardware",
          data: {
            "PaymentID": paymentID.toInt(),
            "Status": status.toInt(),
            "IsExtTime": isExtTime
          });
      if (response != null) {
        return PaymentModel.getPaymentData(response.data);
      }
      return null;
    } catch (e) {
      if (e is DioError) {
        return ResponseBase(message: e.error);
      }
      return null;
    }
  }

  static Future<ResponseBase<List<MemberCodeModel>>> getMemberCode(
      int paymentID,
      {int page = 1,
      int limit = 20}) async {
    try {
      var response = await DioRequest.getHttp("/api/codemember/get", query: {
        "userID": HiveHelper.get(Constants.USER_ID),
        "page": page,
        "limit": limit
      });
      if (response != null) {
        return MemberCodeModel.getListMemeberCodeResponse(response.data);
      }
      return ResponseBase(totals: 0, data: []);
    } catch (e) {
      if (e is DioError) {
        return ResponseBase(totals: 0, data: [], message: e.error);
      }
      return ResponseBase(totals: 0, data: []);
    }
  }

  static Future<ResponseBase<BookingModel>?> updateBookingComplete(
      int bookingID) async {
    try {
      var response = await DioRequest.post(
          "/api/booking/updatesbookingcomplete",
          data: {"BookID": bookingID, "Status": 1});
      if (response != null) {
        return BookingModel.getBookingDetail(response.data);
      }
      return null;
    } catch (e) {
      if (e is DioError) {
        return ResponseBase(message: e.error);
      }
      return null;
    }
  }

  static Future<ResponseBase<PaymentModel>?> extHoursBooking(
      String hardwareID, int priceID, int bookID,
      {String cardNumber = "",
      String cardExpire = "",
      String securityCode = "",
      String holderName = ""}) async {
    try {
      var response =
          await DioRequest.post("/api/payment/externalpayment", data: {
        "HardwareID": hardwareID,
        "UserID": HiveHelper.get(Constants.USER_ID),
        "BooID": bookID,
        "PriceID": priceID,
        "cardNumber": cardNumber,
        "cardExpire": cardExpire,
        "securityCode": securityCode,
        "holderName": holderName
      });
      if (response != null) {
        return PaymentModel.getPaymentData(response.data);
      }
      return null;
    } catch (e) {
      if (e is DioError) {
        return ResponseBase(message: e.error);
      }
      return null;
    }
  }

  static Future<ResponseBase<bool>> clearNotification() async {
    try {
      var response = await DioRequest.post("/api/notification/clearall",
          query: {"userID": HiveHelper.get(Constants.USER_ID)});
      if (response != null) {
        return ResponseBase(data: response.data);
      }
      return ResponseBase(data: false);
    } catch (e) {
      return ResponseBase(data: false);
    }
  }

  static Future<int> getTimeServer() async {
    try {
      var response = await DioRequest.getHttp("/api/getTimeServer");
      if (response != null) {
        return int.parse(response.toString());
      }
      return DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    } catch (e) {
      return DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    }
  }

  static Future<bool> mpiResult(String orderID) async {
    try {
      var response = await DioRequest.getHttp("/api/payment/mpiResult",
          query: {"orderID": orderID});
      if (response != null) {
        return ResponseBase<bool>.fromJson(response.data).data ?? false;
      }
      return false;
    } catch (e) {}
    return false;
  }

  static Future<bool> changeLanguage(int userID, String languageCode) async {
    try {
      var response = await DioRequest.post("/api/user/changelanggues",
          data: {"UserID": userID, "LanguageCode": languageCode});
      if (response != null) {
        return response.statusCode == 200;
      }
      return false;
    } catch (e) {}
    return false;
  }

  static Future<ResponseBase<List<SessionDeviceModel>>> getListSessionDevice(
      int page,
      {int limit = 20}) async {
    try {
      var response = await DioRequest.getHttp("/api/devicetoken/getlist",
          query: {
            "userID": HiveHelper.get(Constants.USER_ID),
            "page": page,
            "limit": limit
          });
      if (response != null) {
        return SessionDeviceModel.getListSessionDevice(response.data);
      }
      return ResponseBase(data: []);
    } catch (e) {
      if (e is DioError) {
        return ResponseBase(message: e.error, totals: 0);
      }
      return ResponseBase(data: []);
    }
  }

  static Future<void> updateLanguageCode() async {
    try {
      await DioRequest.getHttp("/api/updatelanguage", query: {
        "userID": HiveHelper.get(Constants.USER_ID),
        "languageCode": HiveHelper.get(Constants.LANGUAGE_CODE),
      });
      // ignore: empty_catches
    } catch (e) {}
  }
}
