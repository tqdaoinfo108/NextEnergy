import 'package:flutter/material.dart';

class CircularProgressIndicatorCustom extends StatelessWidget {
  const CircularProgressIndicatorCustom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        alignment: Alignment.center,
        child: const CircularProgressIndicator());
  }
}
