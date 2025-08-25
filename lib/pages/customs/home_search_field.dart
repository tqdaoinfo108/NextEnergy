import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomeSearchField extends StatelessWidget {
  const HomeSearchField(this.title, this.onPress, {Key? key}) : super(key: key);
  final Function onPress;
  final String title;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onPress.call(),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(0.95),
            borderRadius: const BorderRadius.all(Radius.circular(40.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 9,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ]),
        child: Row(children: [
          Icon(Icons.search_outlined,
              color: Theme.of(context).iconTheme.color!.withOpacity(0.7)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).iconTheme.color!.withOpacity(0.7)),
              overflow: TextOverflow.ellipsis,
            ),
          )
        ]),
      ),
    );
  }
}

class HomeQRScanWidget extends StatelessWidget {
  const HomeQRScanWidget(this.title, this.onPress, {Key? key})
      : super(key: key);
  final Function onPress;
  final String title;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onPress.call(),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.all(Radius.circular(40.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(.2),
                spreadRadius: 2,
                blurRadius: 9,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ]),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Colors.white),
          ),
          const SizedBox(width: 24),
          const Icon(Icons.charging_station_sharp, color: Colors.white)
        ]),
      ),
    );
  }
}
