import 'response_base.dart';

class SessionDeviceModel {
  int? iD;
  String? deviceName;
  int? statusID;
  int? lastLogin;

  SessionDeviceModel({this.iD, this.deviceName, this.statusID, this.lastLogin});

  SessionDeviceModel.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    deviceName = json['DeviceName'];
    statusID = json['StatusID'];
    lastLogin = json['LastLogin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = this.iD;
    data['DeviceName'] = this.deviceName;
    data['StatusID'] = this.statusID;
    data['LastLogin'] = this.lastLogin;
    return data;
  }

  static ResponseBase<List<SessionDeviceModel>> getListSessionDevice(
      Map<String, dynamic> json) {
    if (json["message"] == null) {
      var list = <SessionDeviceModel>[];
      if (json['data'] != null) {
        json['data'].forEach((v) {
          list.add(SessionDeviceModel.fromJson(v));
        });
      }
      return ResponseBase<List<SessionDeviceModel>>(
        totals: json['totals'] ?? json['total'],
        data: list,
      );
    } else {
      return ResponseBase(message: json["message"]);
    }
  }
}
