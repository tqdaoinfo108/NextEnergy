import 'package:get/get.dart';
import 'package:v2/pages/booking/booking_controller.dart';
import 'package:v2/pages/booking/booking_page.dart';
import 'package:v2/pages/chagre_car/charge_car_controller.dart';
import 'package:v2/pages/chagre_car/charge_car_page.dart';
import 'package:v2/pages/home/home_controller.dart';
import 'package:v2/pages/home/home_page.dart';
import 'package:v2/pages/login/login_controller.dart';
import 'package:v2/pages/login/login_page.dart';
import 'package:v2/pages/login_update/login_update_controller.dart';
import 'package:v2/pages/login_update/login_update_page.dart';
import 'package:v2/pages/member_code/member_code_controller.dart';
import 'package:v2/pages/no_internet/no_internet_page.dart';
import 'package:v2/pages/notification/notification_controller.dart';
import 'package:v2/pages/notification/notification_page.dart';
import 'package:v2/pages/otp/otp_controller.dart';
import 'package:v2/pages/otp/otp_page.dart';
import 'package:v2/pages/payment/payment_3ds_confirm_page.dart';
import 'package:v2/pages/payment/payment_form.dart';
import 'package:v2/pages/payment/payment_list.dart';
import 'package:v2/pages/pin_auth/pin_auth_page.dart';
import 'package:v2/pages/profile/profile_page.dart';
import 'package:v2/pages/profile_change_pass_page/profile_change_pass_controller.dart';
import 'package:v2/pages/profile_detail/profile_detail_controller.dart';
import 'package:v2/pages/profile_detail/profile_detail_page.dart';
import 'package:v2/pages/qr_code/scan_qr_code_page.dart';
import 'package:v2/pages/session_device/session_device_controller.dart';
import 'package:v2/pages/session_device/session_device_page.dart';
import 'package:v2/pages/terms_of_service/terms_of_service_controller.dart';
import 'package:v2/pages/terms_of_service/terms_of_service_page.dart';
import 'package:v2/utils/const.dart';

import '../pages/intro/intro_page.dart';
import '../pages/member_code/member_code_page.dart';
import '../pages/payment/payment_3ds_controller.dart';
import '../pages/payment/payment_3ds_page.dart';
import '../pages/payment/payment_form_controller.dart';
import '../pages/profile_change_pass_page/profile_change_pass_page.dart';
import '../services/base_hive.dart';

// String get getInitialRoute => "/payment";
String get getInitialRoute =>
    HiveHelper.get(Constants.USER_ID, defaultvalue: 0) != 0
        ? "/home"
        : HiveHelper.get(Constants.TERMS_OF_SERVICE) != null
            ? HiveHelper.get(Constants.INTRO) != null
                ? "/login"
                : "/intro"
            : "/termsofservice";

Bindings get getInitialBinding =>
    HiveHelper.get(Constants.USER_ID, defaultvalue: 0) != 0
        ? HomeBind()
        : HiveHelper.get(Constants.TERMS_OF_SERVICE) != null
            ? LoginBind()
            : TermsOfServiceBind();

get pageList => [
      GetPage(name: '/home', page: () => HomePage(), binding: HomeBind()),
      GetPage(
          name: '/termsofservice',
          page: () => const TermsOfServicePage(),
          binding: TermsOfServiceBind()),
      GetPage(name: '/profile', page: () => const ProfilePage()),
      GetPage(
          name: '/login', page: () => const LoginPage(), binding: LoginBind()),
      GetPage(
          name: '/notification',
          page: () => const NotificationPage(),
          binding: NotificationBind()),
      GetPage(
          name: '/qrcode',
          page: () => const ScanQRCodePage(),
          binding: ScanQRCodeBind()),
      GetPage(name: '/otp', page: () => const OTPPage(), binding: OtpBind()),
      GetPage(
          name: '/login_profile',
          page: () => const LoginUpdatePage(),
          binding: LoginUpdateBind()),
      GetPage(
          name: '/charge_car',
          page: () => const ChargeCarPage(),
          binding: ChargeCarBind()),
      GetPage(
          name: '/profile_detail',
          page: () => const ProfileDetailPage(),
          binding: ProfileDetailBind()),
      GetPage(
          name: '/profile_change_pass',
          page: () => const ProfileChangePassPage(),
          binding: ProfileChangePassBind()),
      GetPage(
          name: '/payment_confirm', page: () => const Payment3DSConfirmPage()),
      GetPage(
          name: '/list_booking',
          page: () => const BookingPage(),
          binding: BookingBind()),
      GetPage(
          name: '/member_code',
          page: () => const MemberCodePage(),
          binding: MemberCodeBind()),
      GetPage(name: '/no_internet', page: () => const NoInternetPage()),
      GetPage(name: '/payment_list', page: () => const PaymentListPage()),
      GetPage(
          name: '/payment_form',
          page: () => PaymentFormPage(),
          binding: PaymentFormBind()),
      GetPage(name: '/pin_code_form', page: () => const PinAuthPage()),
      GetPage(
          name: '/session_device',
          page: () => const SessionDevicePage(),
          binding: SessionDeviceBind()),
      GetPage(name: '/intro', page: () => const IntroPage()),
    ];
// get getListRouters => {
//       "/termsofservice": (context) => const TermsOfServicePage(),
//       "/home": (context) => HomePage(),
//       "/profile": (context) => const ProfilePage(),
//       "/login": (context) => const LoginPage(),
//       "/notification": (context) => const NotificationPage(),
//       "/qrcode": (context) => const ScanQRCodePage(),
//       "/otp": (context) => const OTPPage(),
//       "/login_profile": (context) => const LoginUpdatePage(),
//       "/charge_car": (context) => const ChargeCarPage(),
//       "/profile_detail": (context) => const ProfileDetailPage(),
//       "/profile_change_pass": (context) => const ProfileChangePassPage(),
//       // "/payment": (context) => const Payment3DSPage(),
//       "/payment_confirm": (context) => const Payment3DSConfirmPage(),
//       "/list_booking": (context) => const BookingPage(),
//       "/member_code": (context) => const MemberCodePage(),
//       "/no_internet": (context) => const NoInternetPage(),
//       "/payment_list": (context) => const PaymentListPage(),
//       "/payment_form": (context) => const PaymentFormPage(),
//       "/pin_code_form": (context) => const PinAuthPage()
//     };
// GoRouter configuration
// final router = GoRouter(
//   initialLocation: HiveHelper.get(Constants.USER_ID) != null
//       ? "/"
//       : HiveHelper.get(Constants.TERMS_OF_SERVICE) != null
//           ? "/login"
//           : "/termsofservice",
//   routes: [
//     GoRoute(
//         path: '/termsofservice',
//         builder: (context, state) => const TermsOfServicePage()),
//     GoRoute(
//       path: '/',
//       pageBuilder: (context, state) {
//         return CustomTransitionPage(
//           key: state.pageKey,
//           child: const HomePage(),
//           transitionsBuilder: (context, animation, secondaryAnimation, child) {
//             return FadeTransition(
//               opacity:
//                   CurveTween(curve: Curves.easeInOutCirc).animate(animation),
//               child: child,
//             );
//           },
//         );
//       },
//     ),
//     GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
//     GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
//     GoRoute(
//         path: '/notification',
//         builder: (context, state) => const NotificationPage()),
//     GoRoute(
//         path: '/qrcode', builder: (context, state) => const ScanQRCodePage()),
//     GoRoute(
//         name: '/otp',
//         path: '/otp',
//         builder: (context, state) => OTPPage(state)),
//     GoRoute(
//         path: '/login_profile',
//         builder: (context, state) => LoginUpdatePage(state)),
//     GoRoute(
//         path: '/charge_car', builder: (context, state) => ChargeCarPage(state)),
//     GoRoute(
//         path: '/profile_detail',
//         builder: (context, state) => const ProfileDetailPage()),
//     GoRoute(
//       path: '/profile_change_pass',
//       builder: (context, state) => ProfileChangePassPage(state),
//     ),
//     GoRoute(
//       path: '/payment',
//       builder: (context, state) => PaymentPage(state),
//     ),
//     GoRoute(
//       path: '/list_booking',
//       builder: (context, state) => const BookingPage(),
//     ),
//     GoRoute(
//       path: '/member_code',
//       builder: (context, state) => const MemberCodePage(),
//     )
//   ],
// );
