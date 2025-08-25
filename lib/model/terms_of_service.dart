class TermsOfUseBaseModel {
  List<TermsOfUseModel>? data;

  TermsOfUseBaseModel({this.data});

  TermsOfUseBaseModel.fromJson(Map<String, dynamic> json) {
    this.data = json["data"] == null
        ? null
        : (json["data"] as List)
            .map((e) => TermsOfUseModel.fromJson(e))
            .toList();
  }
}

class TermsOfUseModel {
  String? language;
  String? title;
  String? content;
  String? agree;
  String? confirm;

  TermsOfUseModel(
      {this.language, this.title, this.content, this.agree, this.confirm});

  TermsOfUseModel.fromJson(Map<String, dynamic> json) {
    this.language = json["language"];
    this.title = json["title"];
    this.content = json["content"];
    this.agree = json["agree"];
    this.confirm = json["confirm"];
  }
}
