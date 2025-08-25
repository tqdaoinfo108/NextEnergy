class Constants {
  static String USER_ID = "USER_ID";
  static String LAST_LOGIN = "LAST_LOGIN";
  static String FULL_NAME = "FULL_NAME";
  static String PHONE = "PHONE";
  static String AVARTA = "AVARTA";
  static String PAYMENT_CARD = "PAYMENT_CARD";
  static String LOCAL_PIN_CODE = "LOCAL_PIN_CODE";
  static String COUNT_PIN_CODE = "COUNT_PIN_CODE";
  static String FIREBASE_TOKEN = "FIREBASE_TOKEN";

  static String TERMS_OF_SERVICE = "TERMS_OF_SERVICE";
  static String INTRO = "INTRO";
  static String IS_DARK_MODE = "IS_DARK_MODE";
  static String COUNT_OTP = "COUNT_OTP";
  static String LANGUAGE_CODE = "LANGUAGE_CODE";
  static String EXPIRED_ON_HARDWARE = "EXPIRED_ON_HARDWARE";
  static String EXPIRED_WAIT_PAYMENT = "EXPIRED_WAIT_PAYMENT";
  static String IS_DEBUG_APP = "IS_DEBUG_APP";

  static String PAYMENT_API_URL = 'https://pay.veritrans.co.jp/';
  static String PAYMENT_POP_SCRIPT_URL =
      'https://pay.veritrans.co.jp/pop/v1/javascripts/pop.js';
  static String PAYMENT_API_AUTHORIZE =
      'NjEzNmYzMjMtYWE0My00ODQwLWJkMTktYWRjOTFmMzBlMjA3Og==';
  static String PAYMENT_POP_CLIENT_KEY = 'e84c118c-2faa-4eef-a69c-5bc2121f0ada';
  static bool PAYMENT_DEBUG = true;
  static String PAYMENT_SUCCESS_URL = 'https://evstand.payment.com/success';
  static String PAYMENT_FAILURE_URL = 'https://enstand.payment.com/fail';
}

class PageState {
  static String SUCCESS = "SUCCESS";
  static String FAIL = "FAIL";
  static String LOADING = "LOADING";
}

class BleStateEnum {
  static String connecting = "connecting";
  static String chooseYourPlan = "chooseYourPlan";
  static String fail = "fail";
  static String bleNotConnected = "bleNotConnected";
  static String waitingConnectPlugging = "waitingConnectPlugging";
  static String isBeingStarted = "isBeingStarted";
  static String loading = "loading";
}

enum ChargeCarPageEnum { CONNECTING, CHOOSE_TIME, CHARGING, WAIT_PLUGING}
