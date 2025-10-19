class InputMoneyModel {
  int? inputID;
  String? inputCode;
  String? uUserID;
  String? phoneUser;
  String? fullName;
  int? typeUserID;
  String? typeName;
  int? dateInput;
  double? amount;
  int? statusID;
  
  // Legacy fields for backward compatibility
  int? paymentID;
  int? userID;
  int? status;
  String? orderID;
  String? paymentKey;
  String? clientKey;
  String? reqRedirectionUri;
  String? resResponseContents;
  DateTime? createdDate;
  DateTime? updatedDate;

  InputMoneyModel({
    this.inputID,
    this.inputCode,
    this.uUserID,
    this.phoneUser,
    this.fullName,
    this.typeUserID,
    this.typeName,
    this.dateInput,
    this.amount,
    this.statusID,
    this.paymentID,
    this.userID,
    this.status,
    this.orderID,
    this.paymentKey,
    this.clientKey,
    this.reqRedirectionUri,
    this.resResponseContents,
    this.createdDate,
    this.updatedDate,
  });

  factory InputMoneyModel.fromJson(Map<String, dynamic> json) {
    // Parse DateInput timestamp to DateTime
    DateTime? parsedDate;
    if (json['DateInput'] != null) {
      try {
        final timestamp = json['DateInput'] is int 
            ? json['DateInput'] 
            : int.tryParse(json['DateInput'].toString());
        if (timestamp != null) {
          parsedDate = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
        }
      } catch (e) {
        print("Error parsing DateInput: $e");
      }
    }
    
    return InputMoneyModel(
      // New API fields
      inputID: json['InputID'] as int?,
      inputCode: json['InputCode'] as String?,
      uUserID: json['UUserID'] as String?,
      phoneUser: json['PhoneUser'] as String?,
      fullName: json['FullName'] as String?,
      typeUserID: json['TypeUserID'] as int?,
      typeName: json['TypeName'] as String?,
      dateInput: json['DateInput'] as int?,
      amount: (json['Amount'])?.toDouble(),
      statusID: json['StatusID'] as int?,
      
      // Legacy fields
      paymentID: json['PaymentID'] as int?,
      userID: json['UserID'] as int?,
      status: json['Status'] as int? ?? json['StatusID'] as int?,
      orderID: json['OrderID'] as String? ?? json['InputCode'] as String?,
      paymentKey: json['PaymentKey'] as String?,
      clientKey: json['ClientKey'] as String?,
      reqRedirectionUri: json['ReqRedirectionUri'] as String?,
      resResponseContents: json['ResResponseContents'] as String?,
      createdDate: parsedDate ?? (json['CreatedDate'] != null
          ? DateTime.parse(json['CreatedDate'])
          : null),
      updatedDate: json['UpdatedDate'] != null
          ? DateTime.parse(json['UpdatedDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'InputID': inputID,
      'InputCode': inputCode,
      'UUserID': uUserID,
      'PhoneUser': phoneUser,
      'FullName': fullName,
      'TypeUserID': typeUserID,
      'TypeName': typeName,
      'DateInput': dateInput,
      'Amount': amount,
      'StatusID': statusID,
      'PaymentID': paymentID,
      'UserID': userID,
      'Status': status,
      'OrderID': orderID,
      'PaymentKey': paymentKey,
      'ClientKey': clientKey,
      'ReqRedirectionUri': reqRedirectionUri,
      'ResResponseContents': resResponseContents,
      'CreatedDate': createdDate?.toIso8601String(),
      'UpdatedDate': updatedDate?.toIso8601String(),
    };
  }

  // Trạng thái nạp tiền
  String get statusText {
    final currentStatus = statusID ?? status;
    switch (currentStatus) {
      case 0:
        return 'Đang chờ';
      case 1:
        return 'Thành công';
      case 2:
      case -1:
        return 'Thất bại';
      case 3:
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }

  bool get isSuccess => (statusID ?? status) == 1;
  bool get isPending => (statusID ?? status) == 0;
  bool get isFailed => (statusID ?? status) == -1 || (statusID ?? status) == 2;
  bool get isCancelled => (statusID ?? status) == 3;
}
