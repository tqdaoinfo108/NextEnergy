import 'package:v2/model/response_base.dart';

class BookingModel {
  int? bookID;
  int? parkingID;
  String? parkingName;
  int? charingPostID;
  String? code;
  int? dateBook;
  int? dateStart;
  int? dateCurrent;
  int? dateEnd;
  double? ambe;
  double? powerConsumption;
  double? priceAmount;
  double? amount;
  int? userID;
  int? statusID;
  String? timeZoneName;
  String? desriptionBooking;
  String? hardwareID;
  String? addressParking;
  String? unit;
  String? hardwareName;
  double? volt;
  BookingModel(
      {this.bookID,
      this.parkingID,
      this.parkingName,
      this.charingPostID,
      this.code,
      this.dateBook,
      this.dateStart,
      this.dateEnd,
      this.ambe,
      this.powerConsumption,
      this.priceAmount,
      this.amount,
      this.userID,
      this.statusID,
      this.timeZoneName,
      this.desriptionBooking,
      this.hardwareID,
      this.addressParking});

  int get getDurationTimeEnd => (dateEnd! - dateStart!).toInt();

  static ResponseBase<BookingModel> getBookingDetail(
      Map<String, dynamic> json) {
    if (json["message"] == null) {
      return ResponseBase<BookingModel>(
          data: BookingModel.fromJson(json["data"]));
    } else {
      return ResponseBase(message: json["message"]);
    }
  }

  BookingModel.fromJson(Map<String, dynamic> json) {
    bookID = json['BookID'];
    parkingID = json['ParkingID'];
    parkingName = json['ParkingName'] ?? json["NameParking"];
    charingPostID = json['CharingPostID'];
    code = json['Code'];
    dateBook = json['DateBook'];
    dateStart = json['DateStart'];
    dateEnd = json['DateEnd'];
    dateCurrent = json['DateCurrent'];
    ambe = json['Ambe'];
    powerConsumption = json['PowerConsumption'];
    priceAmount = json['PriceAmount'];
    amount = json['Amount'];
    userID = json['UserID'];
    statusID = json['StatusID'];
    timeZoneName = json['TimeZoneName'];
    desriptionBooking = json['DesriptionBooking'];
    hardwareID = json['HardwareID'];
    addressParking = json['AddressParking'];
    unit = json["Unit"];
    hardwareName = json["HardwareName"];
    volt = json["Volt"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['BookID'] = this.bookID;
    data['ParkingID'] = this.parkingID;
    data['ParkingName'] = this.parkingName;
    data['CharingPostID'] = this.charingPostID;
    data['Code'] = this.code;
    data['DateBook'] = this.dateBook;
    data['DateStart'] = this.dateStart;
    data['DateEnd'] = this.dateEnd;
    data['Ambe'] = this.ambe;
    data['PowerConsumption'] = this.powerConsumption;
    data['PriceAmount'] = this.priceAmount;
    data['Amount'] = this.amount;
    data['UserID'] = this.userID;
    data['StatusID'] = this.statusID;
    data['TimeZoneName'] = this.timeZoneName;
    data['DesriptionBooking'] = this.desriptionBooking;
    data['HardwareID'] = this.hardwareID;
    data['AddressParking'] = this.addressParking;

    return data;
  }

  static ResponseBase<List<BookingModel>> getListHistoryBookingResponse(
      Map<String, dynamic> json) {
    if (json["message"] == null) {
      var list = <BookingModel>[];
      if (json['data'] != null) {
        json['data'].forEach((v) {
          list.add(BookingModel.fromJson(v));
        });
      }
      return ResponseBase<List<BookingModel>>(
        totals: json['totals'] ?? json['total'],
        data: list,
      );
    } else {
      return ResponseBase(message: json["message"]);
    }
  }
}
