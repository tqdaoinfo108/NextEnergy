import 'dart:async';
import 'dart:io';
import 'utils/app_theme.dart';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:v2/routers/router.dart';
import 'package:v2/services/https.dart';
import 'package:v2/transactions/my_transactions.dart';
import 'package:ultra_qr_scanner/ultra_qr_scanner.dart';
import 'firebase_options.dart';
import 'pages/customs/page_life_cycle.dart';
import 'services/base_hive.dart';

import 'package:firebase_messaging/firebase_messaging.dart';


import 'utils/const.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  await Hive.initFlutter();
  await Hive.openBox("NextEnergy");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

   // Request camera permission and prepare scanner
  final hasPermission = await UltraQrScanner.requestPermissions();
  if (hasPermission) {
    await UltraQrScanner.prepareScanner();
  }

  EasyLoading.instance
    ..maskColor = Colors.black.withOpacity(0.4)
    ..dismissOnTap = true;

  NotificationController.initializeLocalNotifications();

  runApp(const MyApp());
}

/// IOS setup
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  NotificationController.createNewNotificationIos(message);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    HiveHelper.put("AppStatus", true);
    FlutterNativeSplash.remove();
    FirebaseMessaging.instance.getToken().then((value) {
      assert(value != null);
      HiveHelper.put(Constants.FIREBASE_TOKEN, value);
    });
    FirebaseMessaging.instance
        .requestPermission(alert: true, badge: true, sound: true);

    FirebaseMessaging.onMessageOpenedApp.listen((event) async {
      var booking = await HttpHelper.checkBookingAvailiable();
      if (booking == null || booking.data == null) {
        Get.toNamed(event.data["page"]);
      }
    });
    if (Platform.isIOS) {
      FirebaseMessaging.onBackgroundMessage(
          (message) => _firebaseMessagingBackgroundHandler(message));
    }
    FirebaseMessaging.onMessage.listen((notify) {
      if (Platform.isIOS) {
        NotificationController.createNewNotificationIos(notify);
      } else {
        NotificationController.createNewNotification(notify);
      }
    });

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    FirebaseMessaging.instance.subscribeToTopic("all");
  }

  setupNotiIos() async {}

  @override
  Widget build(BuildContext context) {
    return PageLifecycle(
      stateChanged: (bool appeared) async {
        await HttpHelper.getTimeServer();
      },
      child: GetMaterialApp(
        locale: Locale(
            HiveHelper.get(Constants.LANGUAGE_CODE, defaultvalue: "en"), ''),
        builder: EasyLoading.init(),
        title: '',
        getPages: pageList,
        initialRoute: getInitialRoute,
        initialBinding: getInitialBinding,
        translations: MyTranslations(),
        localizationsDelegates: const [...PhoneFieldLocalization.delegates],
        supportedLocales: const [
          Locale('vi', ''),
          Locale('en', ''),
        ],
        theme: AppTheme.lightTheme,
        // Có thể bổ sung darkTheme nếu muốn, hoặc để mặc định
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

///  *********************************************
///     NOTIFICATION CONTROLLER
///  *********************************************
///
class NotificationController {
  static ReceivedAction? initialAction;

  ///  *********************************************
  ///     INITIALIZATIONS
  ///  *********************************************
  ///
  static Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
        'resource://drawable/logo', //'resource://drawable/res_app_icon',//
        [
          NotificationChannel(
              channelKey: 'basic',
              channelName: 'Basic',
              channelDescription: 'Basic',
              playSound: true,
              onlyAlertOnce: true,
              groupAlertBehavior: GroupAlertBehavior.All,
              importance: NotificationImportance.Max,
              defaultPrivacy: NotificationPrivacy.Public)
        ],
        debug: false);
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: ((receivedAction) =>
            onActionReceivedMethod(receivedAction)));
    // Get initial notification action is optional
    initialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    var booking = await HttpHelper.checkBookingAvailiable();
    if ((booking == null || booking.data == null) &&
        receivedAction.payload?["page"] != null) {
      Get.toNamed(receivedAction.payload!["page"]!);
    }
  }

  ///  *********************************************
  ///     NOTIFICATION CREATION METHODS
  ///  *********************************************
  ///
  static Future<void> createNewNotification(RemoteMessage notify) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) return;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: notify.hashCode, // -1 is replaced by a random number
          channelKey: 'basic',
          title: notify.notification?.title ?? "",
          body: notify.notification?.body ?? "",
          payload: {"page": notify.data["page"]},
          notificationLayout: NotificationLayout.Default),
    );
  }

  static Future<void> createNewNotificationIos(RemoteMessage notify) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) return;
    var noti = notify.data!;
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: notify.hashCode, // -1 is replaced by a random number
          channelKey: 'basic',
          title: noti["title"],
          body: noti["body"],
          payload: {"page": noti["page"]},
          notificationLayout: NotificationLayout.Default),
    );
  }
}
