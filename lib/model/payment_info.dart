import 'dart:convert';

import 'package:v2/utils/const.dart';

import '../services/base_hive.dart';

class PaymentInfoModel {
  late String numberCard;
  late String cvv;
  late String cardHolder;
  late String expiredDate;

  PaymentInfoModel(
      this.numberCard, this.cvv, this.cardHolder, this.expiredDate);

  PaymentInfoModel.fromJson(Map<String, dynamic> json) {
    numberCard = json['numberCard'];
    cvv = json['cvv'];
    cardHolder = json['cardHolder'];
    expiredDate = json['expiredDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['numberCard'] = this.numberCard;
    data['cvv'] = this.cvv;
    data['cardHolder'] = this.cardHolder;
    data['expiredDate'] = this.expiredDate;
    return data;
  }

  static List<PaymentInfoModel> getListCard() {
    var list = HiveHelper.get(Constants.PAYMENT_CARD, defaultvalue: []);
    List<PaymentInfoModel> result = [];
    for (String item in list) {
      result.add(PaymentInfoModel.fromJson(jsonDecode(item)));
    }
    return result;
  }

  static String removeNumberCard(String numberCard) {
    numberCard = numberCard.replaceAll(" ", "");
    return "${numberCard.substring(0, 4)} **** **** ${numberCard.substring(numberCard.length - 4, numberCard.length)}";
  }

  static void addCard(PaymentInfoModel card) {
    List<String> list =
        HiveHelper.get(Constants.PAYMENT_CARD, defaultvalue: <String>[]);
    if (list.toString().contains(card.numberCard)) {
      return;
    }
    list.add(jsonEncode(card.toJson()));
    HiveHelper.put(Constants.PAYMENT_CARD, list);
  }

  static void removeCard(String cardNumber) {
    List<String> list =
        HiveHelper.get(Constants.PAYMENT_CARD, defaultvalue: []);
    for (String item in list) {
      var json = jsonDecode(item);
      if (json["numberCard"] == cardNumber) {
        list.remove(item);
        break;
      }
    }
    HiveHelper.put(Constants.PAYMENT_CARD, list);
  }

  static void updateCard(PaymentInfoModel cardNumber, String cardNumberOld) {
    List<String> list =
        HiveHelper.get(Constants.PAYMENT_CARD, defaultvalue: []);
    for (String item in list) {
      var json = jsonDecode(item);
      if (json["numberCard"] == cardNumberOld) {
        list.remove(item);
        addCard(cardNumber);
        break;
      }
    }
    HiveHelper.put(Constants.PAYMENT_CARD, list);
  }

  static void removeAllListCard() {
    HiveHelper.remove(Constants.LOCAL_PIN_CODE);
    HiveHelper.remove(Constants.PAYMENT_CARD);
  }

  static Map<CardTypeCustom, Set<List<String>>> cardNumPatterns =
      <CardTypeCustom, Set<List<String>>>{
    CardTypeCustom.visa: <List<String>>{
      <String>['4'],
    },
    CardTypeCustom.americanExpress: <List<String>>{
      <String>['34'],
      <String>['37'],
    },
    CardTypeCustom.unionpay: <List<String>>{
      <String>['62'],
    },
    CardTypeCustom.discover: <List<String>>{
      <String>['6011'],
      <String>['622126', '622925'], // China UnionPay co-branded
      <String>['644', '649'],
      <String>['65']
    },
    CardTypeCustom.mastercard: <List<String>>{
      <String>['51', '55'],
      <String>['2221', '2229'],
      <String>['223', '229'],
      <String>['23', '26'],
      <String>['270', '271'],
      <String>['2720'],
    },
    CardTypeCustom.elo: <List<String>>{
      <String>['401178'],
      <String>['401179'],
      <String>['438935'],
      <String>['457631'],
      <String>['457632'],
      <String>['431274'],
      <String>['451416'],
      <String>['457393'],
      <String>['504175'],
      <String>['506699', '506778'],
      <String>['509000', '509999'],
      <String>['627780'],
      <String>['636297'],
      <String>['636368'],
      <String>['650031', '650033'],
      <String>['650035', '650051'],
      <String>['650405', '650439'],
      <String>['650485', '650538'],
      <String>['650541', '650598'],
      <String>['650700', '650718'],
      <String>['650720', '650727'],
      <String>['650901', '650978'],
      <String>['651652', '651679'],
      <String>['655000', '655019'],
      <String>['655021', '655058']
    },
    CardTypeCustom.hipercard: <List<String>>{
      <String>['606282'],
    },
  };

  static CardTypeCustom detectCCType(String cardNumber) {
    //Default card type is other
    CardTypeCustom cardType = CardTypeCustom.otherBrand;

    if (cardNumber.isEmpty) {
      return cardType;
    }

    PaymentInfoModel.cardNumPatterns.forEach(
      (CardTypeCustom type, Set<List<String>> patterns) {
        for (List<String> patternRange in patterns) {
          // Remove any spaces
          String ccPatternStr =
              cardNumber.replaceAll(RegExp(r'\s+\b|\b\s'), '');
          final int rangeLen = patternRange[0].length;
          // Trim the Credit Card number string to match the pattern prefix length
          if (rangeLen < cardNumber.length) {
            ccPatternStr = ccPatternStr.substring(0, rangeLen);
          }

          if (patternRange.length > 1) {
            // Convert the prefix range into numbers then make sure the
            // Credit Card num is in the pattern range.
            // Because Strings don't have '>=' type operators
            final int ccPrefixAsInt = int.parse(ccPatternStr);
            final int startPatternPrefixAsInt = int.parse(patternRange[0]);
            final int endPatternPrefixAsInt = int.parse(patternRange[1]);
            if (ccPrefixAsInt >= startPatternPrefixAsInt &&
                ccPrefixAsInt <= endPatternPrefixAsInt) {
              // Found a match
              cardType = type;
              break;
            }
          } else {
            // Just compare the single pattern prefix with the Credit Card prefix
            if (ccPatternStr == patternRange[0]) {
              // Found a match
              cardType = type;
              break;
            }
          }
        }
      },
    );

    return cardType;
  }

  static String getImageCard(CardTypeCustom type) {
    switch (type) {
      case CardTypeCustom.otherBrand:
        return "assets/images/chip.png";
      case CardTypeCustom.mastercard:
        return "assets/images/mastercard.png";
      case CardTypeCustom.visa:
        return "assets/images/visa.png";
      case CardTypeCustom.americanExpress:
        return "assets/images/amex.png";
      case CardTypeCustom.unionpay:
        return "assets/images/unionpay.png";
      case CardTypeCustom.discover:
        return "assets/images/discover.png";
      case CardTypeCustom.elo:
        return "assets/images/elo.png";
      case CardTypeCustom.hipercard:
        return "assets/images/hipercard.png";
    }
  }
}

enum CardTypeCustom {
  otherBrand,
  mastercard,
  visa,
  americanExpress,
  unionpay,
  discover,
  elo,
  hipercard,
}
