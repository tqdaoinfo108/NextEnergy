import 'booking_model.dart';
import 'response_base.dart';

class PaymentDtoModel {
  String? hardwareID;
  int? priceID;
  int? bookingID;
  bool isExtTime = false;
  int timeNow = 0;
  PaymentDtoModel(this.hardwareID, this.priceID, this.bookingID, this.isExtTime,
      {this.timeNow = 0});
}

class PaymentModel {
  int? paymentID;
  String? paymentKey;
  String? clientKey;
  int? status;
  String? orderID;
  double? grossAmount;
  BookingModel? booking;
  String? reqRedirectionUri;
  String? resResponseContents;

  String get getPaymentKey => paymentKey ?? "";
  String get getClientKey => clientKey ?? "";

  PaymentModel(
      {this.paymentKey,
      this.clientKey,
      this.status,
      this.orderID,
      this.grossAmount,
      this.booking,
      this.paymentID});

  PaymentModel.fromJson(Map<String, dynamic> json) {
    paymentKey = json['PaymentKey'];
    clientKey = json['ClientKey'];
    status = json['Status'];
    orderID = json['OrderID'];
    grossAmount = json['GrossAmount'];
    paymentID = json['PaymentID'];
    booking = json['Booking'] != null
        ? new BookingModel.fromJson(json['Booking'])
        : null;
    reqRedirectionUri = json["ReqRedirectionUri"];
    resResponseContents = json["ResResponseContents"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['PaymentKey'] = this.paymentKey;
    data['ClientKey'] = this.clientKey;
    data['Status'] = this.status;
    data['OrderID'] = this.orderID;
    data['GrossAmount'] = this.grossAmount;
    if (this.booking != null) {
      data['Booking'] = this.booking!.toJson();
    }
    return data;
  }

  static ResponseBase<PaymentModel> getPaymentData(Map<String, dynamic> json) {
    if (json["message"] == null) {
      return ResponseBase<PaymentModel>(
          data: PaymentModel.fromJson(json["data"]));
    } else {
      return ResponseBase(message: json["message"]);
    }
  }
}
