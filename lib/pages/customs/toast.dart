import 'package:flutter/material.dart';

enum ToastTypeEnum { success, error }

class IosStyleToast extends StatelessWidget {
  final String text;
  final ToastTypeEnum toastType;

  const IosStyleToast(
      {super.key, required this.text, this.toastType = ToastTypeEnum.success});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTextStyle(
        style: Theme.of(context)
            .textTheme
            .bodyMedium!
            .copyWith(color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                color: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      toastType == ToastTypeEnum.success
                          ? Icons.check
                          : Icons.close_outlined,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(text)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
