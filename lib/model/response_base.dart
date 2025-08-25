class ResponseBase<T> {
  T? data;
  int? totals;
  int? status;
  String? message;
  int? page;
  bool? isVIP;
  bool isReload = true;
  ResponseBase(
      {this.data,
      this.message,
      this.status,
      this.isVIP,
      this.totals = 0,
      this.page = 1});

  ResponseBase.fromJson(Map<String, dynamic> json,
      [T Function(dynamic json)? dataFromJson]) {
    if (dataFromJson == null) {
      data = json['data'];
    } else {
      var _tmp = json['data'];
      data = _tmp == null ? null : dataFromJson(_tmp);
    }
    status = json.containsKey('status') ? json['status'] : -100;
    totals = json.containsKey('total')
        ? json['total']
        : json.containsKey('totals')
            ? json['totals']
            : -100;
    isVIP = json.containsKey("isVIP") ? json['isVIP'] : false;
  }
}
