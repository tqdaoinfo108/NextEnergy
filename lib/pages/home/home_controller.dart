import 'dart:async';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:convert_vietnamese/convert_vietnamese.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:v2/main.dart';

import '../../model/park_model.dart';
import '../../model/response_base.dart';
import '../../model/user_model.dart';
import '../../services/base_hive.dart';
import '../../services/https.dart';
import '../../utils/const.dart';

class HomeBind extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}

class HomeController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    initData();
  }

  var userModel = UserModel().obs;
  Position? position;
  final Completer<GoogleMapController> mapController = Completer();

  String googleMapDarkTheme =
      "[{\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#242f3e\"}]},{\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#746855\"}]},{\"elementType\":\"labels.text.stroke\",\"stylers\":[{\"color\":\"#242f3e\"}]},{\"featureType\":\"administrative.locality\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#d59563\"}]},{\"featureType\":\"poi\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#d59563\"}]},{\"featureType\":\"poi.business\",\"stylers\":[{\"visibility\":\"off\"}]},{\"featureType\":\"poi.park\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#263c3f\"}]},{\"featureType\":\"poi.park\",\"elementType\":\"labels.text\",\"stylers\":[{\"visibility\":\"off\"}]},{\"featureType\":\"poi.park\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#6b9a76\"}]},{\"featureType\":\"road\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#38414e\"}]},{\"featureType\":\"road\",\"elementType\":\"geometry.stroke\",\"stylers\":[{\"color\":\"#212a37\"}]},{\"featureType\":\"road\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#9ca5b3\"}]},{\"featureType\":\"road.highway\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#746855\"}]},{\"featureType\":\"road.highway\",\"elementType\":\"geometry.stroke\",\"stylers\":[{\"color\":\"#1f2835\"}]},{\"featureType\":\"road.highway\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#f3d19c\"}]},{\"featureType\":\"transit\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#2f3948\"}]},{\"featureType\":\"transit.station\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#d59563\"}]},{\"featureType\":\"water\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#17263c\"}]},{\"featureType\":\"water\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#515c6d\"}]},{\"featureType\":\"water\",\"elementType\":\"labels.text.stroke\",\"stylers\":[{\"color\":\"#17263c\"}]}]";

  String googleMapLightTheme =
      "[{\"featureType\":\"poi.business\",\"stylers\":[{\"visibility\":\"off\"}]},{\"featureType\":\"poi.park\",\"elementType\":\"labels.text\",\"stylers\":[{\"visibility\":\"off\"}]}]";

  CameraPosition cameraPosition =
      const CameraPosition(target: LatLng(38.4784794, 137.9816488), zoom: 4.5);

  bool isOpenDrawer = false;
  var listParkSlot = ResponseBase(totals: 0, data: []).obs;

  ResponseBase<List<ParkingModel>> listParkSlotTemp =
      ResponseBase(totals: 0, data: []);

  ResponseBase<List<ParkingModel>> get getListParkSlotTemp => listParkSlotTemp;
  
  // Selected station for displaying in bottom card
  var selectedStation = Rx<ParkingModel?>(null);

  RxSet<Marker> listMaker = RxSet();

  initData() async {
    try {
      await getConfig();
      position = await getUserCurrentLocation();
      // ignore: unnecessary_new
      cameraPosition = new CameraPosition(
        target: LatLng(position!.latitude, position!.longitude),
        zoom: 14,
      );

      await getProfile();
      await getListParkSlot();
      await checkBookingAvailiable();
      if (position?.latitude != null || position?.longitude != null) {
        moveCamera(LatLng(position!.latitude, position!.longitude));
      } else {
        var item = listParkSlot.value.data!.first as ParkingModel?;
        if (item != null) {
          moveCamera(LatLng(item.latParking ?? 0, item.lngParking ?? 0));
        }
      }
    } catch (e) {}
  }

  moveCameraCurrent() async {
    position = await getUserCurrentLocation();
    moveCamera(LatLng(
        position?.latitude ?? 38.4784794, position?.longitude ?? 137.9816488));
  }

  updateUserModel(UserModel _userModel) {
    userModel.value = _userModel;
    update();
  }

  // Methods for selectedStation
  void selectStation(ParkingModel station) {
    selectedStation.value = station;
  }

  void clearSelectedStation() {
    selectedStation.value = null;
  }

  getListParkSlot() async {
    await _getListParkSlot(
        "", 1, 100000, position?.latitude ?? 0, position?.longitude ?? 0);
  }

  Future getConfig() async {
    try {
      var configs = await HttpHelper.getConfig();
      if (configs != null && configs.data != null) {
        var config =
            configs.data!.firstWhere((x) => x.configKey == "IsDebugApp");
        HiveHelper.put(Constants.IS_DEBUG_APP, config.configValue == "true");
        config = configs.data!
            .firstWhere((x) => x.configKey == "ExpiredWaitPayment");
        HiveHelper.put(
            Constants.EXPIRED_WAIT_PAYMENT, int.tryParse(config.configValue!));
        config = configs.data!
            .firstWhere((x) => x.configKey == "ExpiredConnectHardware");
        HiveHelper.put(
            Constants.EXPIRED_ON_HARDWARE, int.tryParse(config.configValue!));
      }
    } catch (e) {}
  }

  Future<bool> checkBookingAvailiable() async {
    try {
      var booking = await HttpHelper.checkBookingAvailiable();
      if (booking != null && booking.data != null) {
        // ignore: use_build_context_synchronously
        Get.toNamed("/charge_car", arguments: booking.data);
        return true;
      }
      if (Platform.isIOS) {
        var value = await AwesomeNotifications().getInitialNotificationAction();
        if (value != null) {
          Get.toNamed(value.payload!["page"] ?? "/home");
        }
      }
    } catch (e) {}
    return false;
  }

  Future letLogout() async {
    HiveHelper.remove(Constants.USER_ID);
    HiveHelper.remove(Constants.LAST_LOGIN);
    HiveHelper.remove(Constants.PAYMENT_CARD);
    HiveHelper.remove(Constants.LOCAL_PIN_CODE);
  }

  Future getProfile() async {
    try {
      var user = await HttpHelper.getProfile(HiveHelper.get(Constants.USER_ID));
      if (user != null && user.data != null) {
        userModel.value = user.data!;
        update();
      }
    } catch (e) {}
  }

  Future<bool> letDeleteAccount() async {
    try {
      var user = await HttpHelper.deleteAccount();
      if (user != null && user.data != null) {
        return true;
      }
    } catch (e) {}
    return false;
  }

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
    });
    return await Geolocator.getCurrentPosition();
  }

  Future<void> moveCamera(LatLng latLong) async {
    final GoogleMapController controller = await mapController.future;
    controller.moveCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: latLong, zoom: 17)));
  }

  void onChangeListParkSlot(String s) async {
    await _getListParkSlot(
        "", 1, 100000, position?.latitude ?? 0, position?.longitude ?? 0);

    listParkSlot.value.data!.clear();
    for (var element in getListParkSlotTemp.data!) {
      if (element.nameParking!.toLowerCase().contains(s.toLowerCase()) ||
          element.addressParking!.toLowerCase().contains(s.toLowerCase())) {
        listParkSlot.value.data!.add(element);
      }
    }
    listParkSlot.value.totals = listParkSlot.value.data!.length;
    update();
  }

  Future<bool> _getListParkSlot(
      String keyword, int page, int limit, double lat, double lng) async {
    try {
      var resonse =
          await HttpHelper.getListParkSlot(keyword, page, limit, lat, lng);
      listParkSlot.value =
          ResponseBase(data: resonse.data, totals: resonse.totals);
      listParkSlotTemp =
          ResponseBase(data: resonse.data!.toList(), totals: resonse.totals);
      listMaker.clear();
      double width = Get.width * (Platform.isAndroid ? 0.1 : 0.03);
      for (ParkingModel item in listParkSlot.value.data ?? []) {
        final icon = Platform.isAndroid
            ? await BitmapDescriptor.fromAssetImage(
                ImageConfiguration(size: Size(width, width)),
                'assets/images/charging.png')
            : await BitmapDescriptor.fromAssetImage(
                ImageConfiguration(size: Size(width, width)),
                'assets/images/charging_ios.png');
        listMaker.add(Marker(
          markerId: MarkerId("${item.parkingID}"),
          position: item.getLatLng,
          icon: icon,
          infoWindow: InfoWindow(
              title: '${item.nameParking}',
              snippet: '${item.addressParking}',
              onTap: () {
                selectStation(item);
              }),
          // ignore: use_build_context_synchronously
        ));
      }
      update();
      return true;
    } catch (e) {}
    return false;
  }

  Future setMapStyle(bool v) async {
    final controller = await mapController.future;
    if (v) {
      controller.setMapStyle(googleMapDarkTheme);
    } else {
      controller.setMapStyle(googleMapLightTheme);
    }
  }
}
