// ignore_for_file: constant_identifier_names

// import 'dart:convert';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

// import 'navigation_service.dart';

// class LocalizationService {
//   late final Locale locale;
//   static late Locale currentLocale;

//   LocalizationService(this.locale) {
//     currentLocale = locale;
//   }

//   static LocalizationService of(BuildContext context) {
//     return Localizations.of(context, LocalizationService);
//   }

//   late Map<String, String> _localizedString;

//   Future<void> load() async {
//     final jsonString = await rootBundle
//         .loadString('assets/translations/${locale.languageCode}.json');

//     Map<String, dynamic> jsonMap = jsonDecode(jsonString);

//     _localizedString =
//         jsonMap.map((key, value) => MapEntry(key, value.toString()));
//   }

//   String? translate(String key) {
//     return _localizedString[key];
//   }

//   static const supportedLocales = [Locale('en', 'US'), Locale('ja', 'JP')];

//   static Locale? localeResolutionCallBack(
//       Locale? locale, Iterable<Locale>? supportedLocales) {
//     if (supportedLocales != null && locale != null) {
//       return supportedLocales.firstWhere(
//           (element) => element.languageCode == locale.languageCode,
//           orElse: () => supportedLocales.first);
//     }

//     return null;
//   }

//   static const LocalizationsDelegate<LocalizationService> _delegate =
//       _LocalizationServiceDelegate();

//   static const localizationsDelegate = [
//     GlobalMaterialLocalizations.delegate,
//     GlobalCupertinoLocalizations.delegate,
//     GlobalWidgetsLocalizations.delegate,
//     _delegate
//   ];
// }

// class _LocalizationServiceDelegate
//     extends LocalizationsDelegate<LocalizationService> {
//   const _LocalizationServiceDelegate();

//   @override
//   bool isSupported(Locale locale) {
//     return ['en', 'ja'].contains(locale.languageCode);
//   }

//   @override
//   Future<LocalizationService> load(Locale locale) async {
//     LocalizationService service = LocalizationService(locale);
//     await service.load();
//     return service;
//   }

//   @override
//   bool shouldReload(covariant LocalizationsDelegate<LocalizationService> old) {
//     return false;
//   }
// }

enum TKeys {
  home,
  history,
  notification,
  setting,
  dark_mode,
  light,
  dark,
  email,
  password,
  confirm_password,
  dont_blank,
  more_than_6,
  password_incorrect,
  email_invalid,
  register,
  login,
  phone,
  power_socket_available,
  maps_app_not_found,
  scan_qr,
  search,
  filter_name_or_address,
  data_not_found,
  number_kwh,
  total_amount,
  charging,
  stop_charging,
  account,
  verify_account,
  verified,
  not_verified,
  info_account,
  delete_account,
  sign_out,
  settings,
  system,
  language,
  version,
  app_version,
  full_name,
  success,
  fail,
  open_settings,
  grant_location_and_camera,
  delete_account_message,
  yes,
  no,
  register_success_message,
  fail_again,
  login_success,
  account_nonactive,
  user_pass_invalid,
  full,
  splash_screen_message,
  qr_code_invalid,
  register_on_failed,
  time,
  h,
  start,
  cancel,
  skip,
  server_busy,
  retry,
  field_format_invalid,
  // Profile page keys
  premium_member,
  active_status,
  manage_personal_information,
  view_membership_details,
  manage_payment_methods,
  manage_connected_devices,
  update_your_password,
  choose_preferred_language,
  switch_theme_mode,
  danger_zone,
  sign_out_from_account,
  permanently_delete_account,
  action_cannot_undone,
  logout_confirmation,
  delete_account_confirmation,
  unable_to_connect,
  create_booking_success,
  charging_order_completed,
  reset_password,
  from,
  to,
  save,
  you_have_not_complete_the_payment,
  continue_payment,
  machine_availiable,
  open_map,
  find_an_ev_charger,
  found,
  charge_station,
  available,
  detail,
  change_password,
  password_current,
  password_new,
  member_code,
  profile,
  expiry_date,
  account_exists,
  unregistered_account,
  confirm,
  forget_password,
  already_have_an_account,
  request_otp,
  verification,
  enter_the_code_sent_to_my_phone,
  didnt_recieve_code,
  resend,
  invalid_pin_code,
  charging_can_not_go_back,
  connecting,
  disconnect,
  touch_to_reconnect,
  charge,
  buy_more,
  pls_attaach_charger_to_vehicle,
  grant_ble,
  choose_your_plant,
  no_select_time,
  booking_failed_to_not_begin_connect,
  hours,
  password_not_match,
  update_profile,
  payment,
  request_permission,
  buy,
  time_is_still,
  are_you_sure_want_to_end,
  are_you_sure_want_to_end_member,
  time_remaining,
  machine_in_use,
  machine_under_maintenance,
  account_not_exists,
  create_new_user,
  login_exist_recreate,
  create_payment_success,
  do_you_have_charge_flag_your_car,
  no_scan,
  do_you_save,
  note,
  warning_auto_payment,
  amount_of_money,
  do_note_remove_flag,
  charging_cancel,
  delete_noti,
  card_holder,
  expired_date,
  card_number,
  pls_input_a_valid_cvv,
  pls_input_a_valid_date,
  pls_input_a_valid_number,
  internet_no_connect,
  device_loggin_by_another,
  notice,
  card_infomation,
  cofirm_charge,
  no_internet_try_again,
  complete_charging_end_processing,
  payment_method,
  input_pincode,
  list_payment_note,
  authenticate_to_view_card_information,
  wrong_entry_delete,
  select_credit_card_information,
  create_a_new_pin_code,
  pincode_will_used_to_store,
  save_credit_card,
  edit,
  delete,
  card_infomation_has_been_deleted_due,
  you_want_proces,
  no_info_credit_card,
  pls_enter_the_4_digit_code,
  fail_again2,
  complete_charging_end_processing_auto,
  can_not_create_due_to_the_overspep,
  communication_with_the_server_unstable,
  i_agree_to_the_specified_commercial_transactions_law,
  i_disagree,
  close,
  no_internet_warning,
  warning_auto_payment_member,
  free,
  pls_attaach_charger_to_vehicle_member,
  start_member,
  buy_more_member,
  create_account_string,
  forget_password_string,
  session_device,
  active,
  on_back_300s_message,
  this_charger_is_out_of_order,
  total_slot
}

//TKeys.hello
extension TKeysExtention on TKeys {
  String get _string => toString().split('.')[1];

  String translate() {
    return _string.tr;
  }
}
