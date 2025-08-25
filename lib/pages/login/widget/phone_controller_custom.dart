import 'package:flutter/material.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:phone_form_field/src/validation/allowed_characters.dart';
import 'package:phone_numbers_parser/src/parsers/phone_number_exceptions.dart';

class PhoneControllerCustom extends ChangeNotifier {
  /// focus node of the national number
  // final FocusNode focusNode;
  final PhoneNumber initialValue;
  PhoneNumber _value;
  PhoneNumber get value => _value;

  set value(PhoneNumber phoneNumber) {
    _value = phoneNumber;
    final formattedNsn = _value.nsn;
    if (formattedNationalNumberController.text != formattedNsn) {
      changeNationalNumberCustom(formattedNsn);
    } else {
      notifyListeners();
    }
  }

  /// text editing controller of the nsn ( where user types the phone number )
  late final TextEditingController formattedNationalNumberController;
  PhoneControllerCustom({
    this.initialValue = const PhoneNumber(isoCode: IsoCode.VI, nsn: ''),
  })  : _value = initialValue,
        formattedNationalNumberController = TextEditingController(
          text: initialValue.nsn,
        );

  changeCountry(IsoCode isoCode) {
    _value = PhoneNumber.parse(
      _value.nsn,
      destinationCountry: isoCode,
    );
    _changeFormattedNationalNumber(_value.formatNsn());
    notifyListeners();
  }

  changeNationalNumberCustom(String? text) {
    text = text ?? '';
    final phoneNumber = PhoneNumber(isoCode: _value.isoCode, nsn: text);
    _value = phoneNumber;
    // var newFormattedText = text;

    // // if starts with + then we parse the whole number
    // final startsWithPlus =
    //     text.startsWith(RegExp('[${AllowedCharacters.plus}]'));

    // if (startsWithPlus) {
    //   final phoneNumber = _tryParseWithPlus(text);
    //   // if we could parse the phone number we can change the value inside
    //   // the national number field to remove the "+ country dial code"
    //   if (phoneNumber != null) {
    //     newFormattedText = _value.formatNsn();
    //   }
    // } else {
    //   final phoneNumber = PhoneNumber.parse(
    //     text,
    //     destinationCountry: _value.isoCode,
    //   );
    //   _value = phoneNumber;
    //   newFormattedText = phoneNumber.formatNsn();
    // }
    // _changeFormattedNationalNumber(newFormattedText);
    notifyListeners();
  }

  // changeNationalNumber(String? text) {
  //   text = text ?? '';
  //   var newFormattedText = text;

  //   // if starts with + then we parse the whole number
  //   final startsWithPlus =
  //       text.startsWith(RegExp('[${AllowedCharacters.plus}]'));

  //   if (startsWithPlus) {
  //     final phoneNumber = _tryParseWithPlus(text);
  //     // if we could parse the phone number we can change the value inside
  //     // the national number field to remove the "+ country dial code"
  //     if (phoneNumber != null) {
  //       _value = phoneNumber;
  //       newFormattedText = _value.formatNsn();
  //     }
  //   } else {
  //     final phoneNumber = PhoneNumber.parse(
  //       text,
  //       destinationCountry: _value.isoCode,
  //     );
  //     _value = phoneNumber;
  //     newFormattedText = phoneNumber.formatNsn();
  //   }
  //   _changeFormattedNationalNumber(newFormattedText);
  //   notifyListeners();
  // }

  void _changeFormattedNationalNumber(String newFormattedText) {
    if (newFormattedText != formattedNationalNumberController.text) {
      formattedNationalNumberController.value = TextEditingValue(
        text: newFormattedText,
        selection: _computeSelection(
            formattedNationalNumberController.text, newFormattedText),
      );
    }
  }

  /// When the cursor is at the end of the text we need to preserve that.
  /// Since there is formatting going on we need to explicitely do it.
  /// We don't want to do it in the middle because the user might have
  /// used arrow keys to move inside the text.
  TextSelection _computeSelection(String originalText, String newText) {
    final currentSelectionOffset =
        formattedNationalNumberController.selection.extentOffset;
    final isCursorAtEnd = currentSelectionOffset == originalText.length;
    var offset = currentSelectionOffset;

    if (isCursorAtEnd || currentSelectionOffset >= newText.length) {
      offset = newText.length;
    }
    return TextSelection.fromPosition(
      TextPosition(offset: offset),
    );
  }

  PhoneNumber? _tryParseWithPlus(String text) {
    try {
      return PhoneNumber.parse(text);
      // parsing "+", a country code won't be found
    } on PhoneNumberException {
      return null;
    }
  }

  selectNationalNumber() {
    formattedNationalNumberController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: formattedNationalNumberController.value.text.length,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    formattedNationalNumberController.dispose();
    super.dispose();
  }
}
