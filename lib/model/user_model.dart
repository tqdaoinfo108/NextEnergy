import 'dart:convert';
import '../pages/login/login_controller.dart';
import 'response_base.dart';

class UserModel {
  int? userID;
  String? imagesPaths;
  int? typeUserID;
  String? uUserID;
  String? fullName;
  String? email;
  int? status;
  int? confirmEmail;
  String? lastLogin;
  String? languageCode;
  int? timeOTP;
  int? countVIP;
  String? oTP;
  String? phoneArea;

  LoginType loginType = LoginType.none;
  UserModel(
      {userID,
      imagesPaths,
      typeUserID,
      uUserID,
      fullName,
      email,
      phone,
      status,
      confirmEmail,
      lastLogin,
      languageCode,
      this.countVIP});

  factory UserModel.fromRawJson(String str) =>
      UserModel.fromJson(json.decode(str) as Map<String, dynamic>);

  UserModel.fromJson(Map<String, dynamic> json) {
    userID = json['UserID'];
    imagesPaths = json['ImagesPaths'];
    typeUserID = json['TypeUserID'];
    uUserID = json['UUserID'];
    fullName = json['FullName'];
    email = json['Email'];
    status = json['Status'];
    confirmEmail = json['ConfirmEmail'];
    lastLogin = json['LastLogin'];
    languageCode = json['LanguageCode'];
    countVIP = json['CountVIP'];
    timeOTP = json['TimeOTP'];
    oTP = json['OTP'];
    phoneArea = json["PhoneArea"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['UserID'] = userID;
    data['ImagesPaths'] = imagesPaths;
    data['TypeUserID'] = typeUserID;
    data['PhoneArea'] = phoneArea;
    data['UUserID'] = uUserID;
    data['FullName'] = fullName;
    data['Email'] = email;
    data['Status'] = status;
    data['ConfirmEmail'] = confirmEmail;
    data['LastLogin'] = lastLogin;
    data['LanguageCode'] = languageCode;
    data['OTP'] = oTP;
    data['TimeOTP'] = timeOTP;
    data['CountVIP'] = countVIP;
    return data;
  }

  static ResponseBase<UserModel> getUserResponse(Map<String, dynamic> json) {
    if (json["message"] == null) {
      return ResponseBase<UserModel>(data: UserModel.fromJson(json["data"]));
    } else {
      return ResponseBase(message: json["message"]);
    }
  }

  static ResponseBase<bool> getUserUploadAvatarResponse(
      Map<String, dynamic> json) {
    if (json["message"] == null) {
      return ResponseBase<bool>(data: json["data"]);
    } else {
      return ResponseBase(message: json["message"]);
    }
  }
}
