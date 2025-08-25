class PaymentKeyResponse {
  PaymentKeyResponse({
    this.paymentKey,
    this.status,
    this.clientKey,
    this.oderId,
    this.grossAmount,
  });

  String? paymentKey;
  String? status;
  String? clientKey;
  String? oderId;
  int? grossAmount;

  PaymentKeyResponse copyWith({
    String? paymentKey,
    String? status,
    String? clientKey,
    String? oderId,
    int? grossAmount,
  }) =>
      PaymentKeyResponse(
        paymentKey: paymentKey ?? this.paymentKey,
        status: status ?? this.status,
        clientKey: clientKey ?? this.clientKey,
        oderId: oderId ?? this.oderId,
        grossAmount: grossAmount ?? this.grossAmount,
      );

  factory PaymentKeyResponse.fromJson(Map<String, dynamic> json) =>
      PaymentKeyResponse(
        paymentKey: json["PaymentKey"],
        status: json["Status"],
        clientKey: json["ClientKey"],
        oderId: json["OderID"],
        grossAmount: json["GrossAmount"],
      );

  Map<String, dynamic> toJson() => {
        "PaymentKey": paymentKey,
        "Status": status,
        "ClientKey": clientKey,
        "OderID": oderId,
        "GrossAmount": grossAmount,
      };
}
