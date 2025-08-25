import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v2/model/user_model.dart';
import 'package:v2/pages/customs/appbar.dart';
import 'package:v2/services/base_hive.dart';
import 'package:v2/services/localization_service.dart';
import 'package:v2/utils/const.dart';

import '../../services/https.dart';
import '../customs/profile_menu_item.dart';
import '../login/login_controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String languageValue = "English";
  @override
  void initState() {
    super.initState();

    languageValue =
        HiveHelper.get(Constants.LANGUAGE_CODE, defaultvalue: "en") == "en"
            ? "English"
            : "日本語";
    toggleLanguage(HiveHelper.get(Constants.LANGUAGE_CODE, defaultvalue: "en"));
  }

  void toggleLanguage(String lang) {
    languageValue = lang == "en" ? "English" : "日本語";
    setState(() {
      languageValue = languageValue;
      HiveHelper.put(Constants.LANGUAGE_CODE, lang);
    });
    HttpHelper.updateLanguageCode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom(
        title: Text(
          TKeys.profile.translate(),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            ProfileMenuItem(Icons.people, TKeys.info_account.translate(),
                onPress: () => Get.toNamed("/profile_detail")),
            ProfileMenuItem(
                Icons.card_membership_outlined, TKeys.member_code.translate(),
                onPress: () => Get.toNamed("/member_code")),
            ProfileMenuItem(Icons.payment, TKeys.payment_method.translate(),
                onPress: () async {
              String? result = await Get.toNamed("/pin_code_form",
                  arguments: "/payment_list") as String?;
              if (result != null && result.isNotEmpty) {
                Get.toNamed("/payment_list");
              }
            }),
            ProfileMenuItem(Icons.devices, TKeys.session_device.translate(),
                onPress: () async {
              await Get.toNamed("/session_device");
            }),
            ProfileMenuItem(
              Icons.password_outlined,
              TKeys.change_password.translate(),
              onPress: () {
                Get.toNamed("/profile_change_pass",
                    arguments: UserModel()..loginType = LoginType.none);
              },
            ),
            ProfileMenuItem(
                Icons.delete_forever, TKeys.delete_account.translate(),
                onPress: () {
              letDeleteAccount(context);
            }),
            ProfileMenuItem(
              Icons.language,
              TKeys.language.translate(),
              isDropdownlist: true,
              widgetDropdownlist: buildSelectLanguage(context),
              onPress: null,
            ),
            ProfileMenuItem(
              Icons.dark_mode,
              TKeys.dark_mode.translate(),
              isOnSwitch: true,
              isValueSwitch: Get.isDarkMode,
              onSwitch: (v) {
                Get.changeThemeMode(v ? ThemeMode.dark : ThemeMode.light);
                HiveHelper.put(Constants.IS_DARK_MODE, v);
              },
            ),
            ProfileMenuItem(
              Icons.info,
              TKeys.version.translate(),
              isText: true,
              textValue: "v1.0.1",
            ),
          ],
        ),
      ),
    );
  }

  DropdownButton<String> buildSelectLanguage(BuildContext context) {
    return DropdownButton<String>(
      value: languageValue,
      iconSize: 18,
      icon: const Padding(
        padding: EdgeInsets.only(left: 8.0),
        child: RotatedBox(
            quarterTurns: -45, child: Icon(Icons.arrow_back_ios_new)),
      ),
      onChanged: (String? value) async {
        var lang = value == "English" ? "en" : "vi";
        await Get.updateLocale(Locale(lang, ""));
        toggleLanguage(lang);
      },
      underline: const SizedBox(),
      items: ["English", "Việt Nam"].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).iconTheme.color!.withOpacity(0.6))),
        );
      }).toList(),
    );
  }

  letDeleteAccount(BuildContext cxt) {
    return showDialog<void>(
      context: cxt,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actionsOverflowAlignment: OverflowBarAlignment.center,
          title: Text(
            TKeys.notification.translate(),
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
                  TKeys.delete_account_message.translate(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(TKeys.no.translate(),
                  style: Theme.of(context).textTheme.bodyMedium),
              onPressed: () {
                Get.back();
              },
            ),
            TextButton(
              child: Text(TKeys.yes.translate(),
                  style: Theme.of(context).textTheme.bodyMedium),
              onPressed: () async {
                Get.back();
                var user = await HttpHelper.deleteAccount();
                if (user != null && user.data != null) {
                  await FirebaseMessaging.instance.unsubscribeFromTopic(
                      "user${HiveHelper.get(Constants.USER_ID)}");
                  HiveHelper.remove(Constants.USER_ID);
                  HiveHelper.remove(Constants.LAST_LOGIN);

                  HiveHelper.remove(Constants.PAYMENT_CARD);
                  HiveHelper.remove(Constants.LOCAL_PIN_CODE);
                  Get.offAllNamed("/login");
                }
              },
            )
          ],
        );
      },
    );
  }
}
