import 'package:v2/services/base_hive.dart';
import 'package:v2/utils/const.dart';

class BleResponseModel {
  String? myId;
  int? bookingID;
  double? volt;
  double? ampe;
  double? kwh;
  int? endTime;
  Map? dvList;

  BleResponseModel(
      {this.myId,
      this.bookingID,
      this.volt,
      this.ampe,
      this.kwh,
      this.endTime,
      this.dvList});

  BleResponseModel.fromJson(Map<String, dynamic> json) {
    myId = json['myId'];
    bookingID = int.tryParse(json["bookId"].toString()) ?? 0;
    volt = double.tryParse(json['volt'].toString()) ?? 0;
    ampe = double.tryParse(json['ampe'].toString()) ?? 0;
    kwh = double.tryParse(json['kwh'].toString()) ?? 0;
    endTime = int.tryParse(json['endTime'].toString());
    dvList = json['dvList'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['myId'] = myId;
    data['userID'] = HiveHelper.get(Constants.USER_ID);
    data['bookingID'] = bookingID;
    data['volt'] = volt;
    data['ampe'] = ampe;
    data['kwh'] = kwh;
    data['endTime'] = endTime;
    data['dvList'] = dvList;
    data['isNewversion'] = true;
    return data;
  }
}
