import 'package:flutter/material.dart';
import 'package:v2/services/localization_service.dart';

class IconButtonCustom extends StatelessWidget {
  const IconButtonCustom(this.widget, this.onPress, {Key? key, this.colors})
      : super(key: key);
  final Function onPress;
  final Widget widget;
  final Color? colors;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.white,
      onTap: () => onPress.call(),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
            color: colors ?? Theme.of(context).cardColor.withOpacity(0.9),
            borderRadius: const BorderRadius.all(Radius.circular(40.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(.2),
                spreadRadius: 2,
                blurRadius: 9,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ]),
        child: widget,
      ),
    );
  }
}

class ButtonPrimary extends StatelessWidget {
  const ButtonPrimary(this.title, {this.onPress, this.color, Key? key})
      : super(key: key);
  final String title;
  final Function? onPress;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
          overlayColor: MaterialStateProperty.all<Color>(
              Theme.of(context).cardColor.withOpacity(0.4)),
          backgroundColor: MaterialStateProperty.all<Color>(color == null
              ? Theme.of(context)
                  .colorScheme
                  .primary
                  .withOpacity(onPress == null ? 0.4 : 1)
              : color!),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.0),
          ))),
      onPressed: onPress == null
          ? null
          : () {
              onPress!.call();
            },
      child: Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      )),
    );
  }
}

class ButtonPrimaryOutline extends StatelessWidget {
  const ButtonPrimaryOutline(
    this.title,
    this.onPress, {
    Key? key,
    this.subString,
  }) : super(key: key);
  final String title;
  final String? subString;

  final Function onPress;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
          shadowColor: MaterialStateProperty.all<Color>(Colors.black),
          overlayColor:
              MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
          backgroundColor: MaterialStateProperty.all<Color>(
              Theme.of(context).iconTheme.color!),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.0),
          ))),
      onPressed: () => onPress.call(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Theme.of(context).scaffoldBackgroundColor),
            ),
          ),
          if (subString != null)
            Text(
              subString!,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).iconTheme.color!.withOpacity(0.5)),
            ),
        ],
      ),
    );
  }
}

class ButtonPriceOutline extends StatelessWidget {
  const ButtonPriceOutline(
    this.title,
    this.onPress,
    this.isChoose, {
    Key? key,
    this.subString,
  }) : super(key: key);
  final String title;
  final String? subString;
  final bool isChoose;
  final Function onPress;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: ElevatedButton(
        style: ButtonStyle(
            shadowColor: MaterialStateProperty.all<Color>(Colors.black),
            overlayColor: MaterialStateProperty.all<Color>(
                Theme.of(context).primaryColor),
            backgroundColor: MaterialStateProperty.all<Color>(isChoose
                ? Theme.of(context).primaryColor.withOpacity(0.2)
                : Theme.of(context).cardColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ))),
        onPressed: () => onPress.call(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall!
                      ..copyWith(fontSize: 13),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    TKeys.hours.translate(),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (subString != null)
                Text(
                  "${TKeys.amount_of_money.translate()} ${subString!}",
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Theme.of(context).iconTheme.color),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
