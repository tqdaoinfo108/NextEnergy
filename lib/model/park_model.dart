import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'response_base.dart';

class ParkingModel {
  double? distance;
  String? unit;
  int? parkingID;
  String? codeParking;
  String? nameParking;
  String? phoneParking;
  String? addressParking;
  double? latParking;
  double? lngParking;
  int? powerSocketAvailable;
  int? totalPowerSocket;
  bool? isVIP;
  ParkingModel(
      {this.distance,
      this.unit,
      this.parkingID,
      this.codeParking,
      this.nameParking,
      this.phoneParking,
      this.addressParking,
      this.powerSocketAvailable,
      this.lngParking,
      this.latParking,
      this.totalPowerSocket,
      this.isVIP});

  LatLng get getLatLng => LatLng(latParking ?? 0, lngParking ?? 0);

  factory ParkingModel.fromJson(Map<String, dynamic> json) => ParkingModel(
      distance: json['Distance'],
      unit: json['Unit'],
      parkingID: json['ParkingID'],
      codeParking: json['CodeParking'],
      nameParking: json['NameParking'],
      phoneParking: json['PhoneParking'],
      addressParking: json['AddressParking'],
      powerSocketAvailable: json['PowerSocketAvailable'],
      latParking: json["LatParking"],
      lngParking: json["IngParking"],
      isVIP: json["IsVIP"],
      totalPowerSocket: json["TotalPowerSocket"]);

  static ResponseBase<List<ParkingModel>> getListParkingResponse(
      Map<String, dynamic> json) {
    if (json["message"] == null) {
      var list = <ParkingModel>[];
      if (json['data'] != null) {
        json['data'].forEach((v) {
          list.add(ParkingModel.fromJson(v));
        });
      }
      return ResponseBase<List<ParkingModel>>(
        totals: json['totals'],
        data: list,
      );
    } else {
      return ResponseBase(message: json["message"]);
    }
  }
}
