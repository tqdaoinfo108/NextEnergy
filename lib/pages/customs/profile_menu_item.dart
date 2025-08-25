import 'package:flutter/material.dart';

class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem(this.icon, this.title,
      {Key? key,
      this.onPress,
      this.isValueSwitch = false,
      this.onSwitch,
      this.isOnSwitch = false,
      this.isText = false,
      this.textValue,
      this.isDropdownlist = false,
      this.widgetDropdownlist})
      : super(key: key);
  final String title;
  final IconData icon;
  final Function? onPress;
  final bool isOnSwitch;
  final bool isValueSwitch;
  final Function(bool)? onSwitch;
  final bool isText;
  final String? textValue;
  final bool isDropdownlist;
  final Widget? widgetDropdownlist;

  Widget buildSwitch(bool isvalue, Function(bool)? onSwitch) {
    final MaterialStateProperty<Icon?> thumbIcon =
        MaterialStateProperty.resolveWith<Icon?>(
      (Set<MaterialState> states) {
        // Thumb icon when the switch is selected.
        if (states.contains(MaterialState.selected)) {
          return const Icon(Icons.check);
        }
        return const Icon(Icons.close);
      },
    );

    return Switch(
      thumbIcon: thumbIcon,
      splashRadius: 28,
      value: isValueSwitch,
      onChanged: (value) => onSwitch?.call(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).textTheme.bodyLarge!.color,
      ),
      title: Text(title),
      trailing: isDropdownlist
          ? widgetDropdownlist
          : isText
              ? Text(
                  textValue ?? "",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color:
                          Theme.of(context).iconTheme.color!.withOpacity(0.6)),
                )
              : isOnSwitch
                  ? buildSwitch(isOnSwitch, onSwitch)
                  : const RotatedBox(
                      quarterTurns: 90, child: Icon(Icons.arrow_back_ios_new)),
      onTap: onPress != null ? () => {onPress?.call()} : null,
    );
  }
}
