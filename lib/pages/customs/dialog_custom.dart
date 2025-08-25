import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v2/pages/customs/button.dart';
import '../../services/localization_service.dart';

showDialogCustomForPrivacy(BuildContext cxt, Function func,
    {String question = "",
    String title = "",
    String yesText = "",
    bool isPop = true}) async {
  if (title.isEmpty) {
    title = TKeys.notification.translate();
  }
  return showDialog<void>(
    context: cxt,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: (() async => isPop),
        child: AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          actionsOverflowAlignment: OverflowBarAlignment.center,
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  question == "" ? TKeys.do_you_save.translate() : question,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ButtonPrimary(
              yesText,
              onPress: () {
                Get.back();
                func.call();
              },
            ),
          ],
        ),
      );
    },
  );
}

showDialogCustom(BuildContext cxt, Function func,
    {String question = "",
    String title = "",
    String noText = "",
    String yesText = ""}) async {
  if (title.isEmpty) {
    title = TKeys.notification.translate();
  }
  return showDialog<void>(
    context: cxt,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actionsOverflowAlignment: OverflowBarAlignment.center,
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                question == "" ? TKeys.do_you_save.translate() : question,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(TKeys.no_scan.translate(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
            onPressed: () async {
              Get.back();
            },
          ),
          TextButton(
            child: Text(TKeys.yes.translate(),
                style: Theme.of(context).textTheme.bodyMedium),
            onPressed: () async {
              Get.back();
              func.call();
            },
          ),
        ],
      );
    },
  );
}

showDialogAutoPaymentCustom(BuildContext cxt, Function func,
    {String? text}) async {
  text = text ?? TKeys.warning_auto_payment.translate();
  return showDialog<void>(
    context: cxt,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actionsOverflowAlignment: OverflowBarAlignment.center,
        title: Text(
          TKeys.note.translate(),
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                text ?? "",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(TKeys.cancel.translate(),
                style: Theme.of(context).textTheme.bodyMedium),
            onPressed: () async {
              Get.back();
            },
          ),
          TextButton(
            child: Text(TKeys.yes.translate(),
                style: Theme.of(context).textTheme.bodyMedium),
            onPressed: () async {
              Get.back();
              func.call();
            },
          ),
        ],
      );
    },
  );
}
