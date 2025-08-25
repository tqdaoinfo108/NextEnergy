import 'response_base.dart';

class MemberCodeModel {
  int? memberID;
  int? userID;
  String? memberCode;
  String? memberName;
  int? numberUser;
  int? timeStart;
  int? timeEnd;
  int? createdDate;
  int? updatedDate;
  String? userCreated;
  String? userUpdated;
  String? codeParking;
  String? nameParking;
  int? status;
  int? numberUsed;
  int? numberRemain;

  MemberCodeModel(
      {this.memberID,
      this.userID,
      this.memberCode,
      this.memberName,
      this.numberUser,
      this.timeStart,
      this.timeEnd,
      this.createdDate,
      this.updatedDate,
      this.userCreated,
      this.userUpdated,
      this.codeParking,
      this.nameParking,
      this.status,
      this.numberUsed,
      this.numberRemain});

  MemberCodeModel.fromJson(Map<String, dynamic> json) {
    memberID = json['MemberID'];
    userID = json['UserID'];
    memberCode = json['MemberCode'];
    memberName = json['MemberName'];
    numberUser = json['NumberUser'];
    timeStart = json['TimeStart'];
    timeEnd = json['TimeEnd'];
    createdDate = json['CreatedDate'];
    updatedDate = json['UpdatedDate'];
    userCreated = json['UserCreated'];
    userUpdated = json['UserUpdated'];
    codeParking = json['CodeParking'];
    nameParking = json['NameParking'];
    status = json['Status'];
    numberUsed = json['NumberUsed'];
    numberRemain = json['NumberRemain'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['MemberID'] = this.memberID;
    data['UserID'] = this.userID;
    data['MemberCode'] = this.memberCode;
    data['MemberName'] = this.memberName;
    data['NumberUser'] = this.numberUser;
    data['TimeStart'] = this.timeStart;
    data['TimeEnd'] = this.timeEnd;
    data['CreatedDate'] = this.createdDate;
    data['UpdatedDate'] = this.updatedDate;
    data['UserCreated'] = this.userCreated;
    data['UserUpdated'] = this.userUpdated;
    data['CodeParking'] = this.codeParking;
    data['NameParking'] = this.nameParking;
    data['Status'] = this.status;
    data['NumberUsed'] = this.numberUsed;
    data['NumberRemain'] = this.numberRemain;
    return data;
  }

  static ResponseBase<List<MemberCodeModel>> getListMemeberCodeResponse(
      Map<String, dynamic> json) {
    if (json["message"] == null) {
      var list = <MemberCodeModel>[];
      if (json['data'] != null) {
        json['data'].forEach((v) {
          list.add(MemberCodeModel.fromJson(v));
        });
      }
      return ResponseBase<List<MemberCodeModel>>(
        totals: json['totals'] ?? json['total'],
        data: list,
      );
    } else {
      return ResponseBase(message: json["message"]);
    }
  }
}
