import 'package:v2/model/response_base.dart';

class PriceModel {
  int? priceID;
  double? priceTime;
  double? priceAmount;
  String? unitPrice;
  double get getHour => priceTime! / 60;
  PriceModel({this.priceID, this.priceTime, this.priceAmount, this.unitPrice});

  PriceModel.fromJson(Map<String, dynamic> json) {
    priceID = json['PriceID'];
    priceTime = json['PriceTime'];
    priceAmount = json['PriceAmount'];
    unitPrice = json['UnitPrice'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['PriceID'] = this.priceID;
    data['PriceTime'] = this.priceTime;
    data['PriceAmount'] = this.priceAmount;
    data['UnitPrice'] = this.unitPrice;
    return data;
  }

  static ResponseBase<List<PriceModel>> getListPriceResponse(
      Map<String, dynamic> json) {
    if (json["message"] == null) {
      var list = <PriceModel>[];
      if (json['data'] != null) {
        json['data'].forEach((v) {
          list.add(PriceModel.fromJson(v));
        });
      }
      return ResponseBase(data: list, isVIP: json["isVIP"] ?? false);
    } else {
      return ResponseBase(data: []);
    }
  }
}
