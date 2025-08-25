import 'dart:convert';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:v2/pages/customs/dialog_custom.dart';
import 'package:v2/pages/home/home_controller.dart';
import 'package:v2/services/localization_service.dart';
import '../customs/button.dart';
import '../customs/home_search_field.dart';
import 'home_bottom_sheet.dart';

class HomePage extends GetView<HomeController> {
  HomePage({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> sliderDrawerKey = GlobalKey(); // Create a key

  @override
  Widget build(BuildContext context) {
    String googleMapDarkTheme =
        "[{\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#242f3e\"}]},{\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#746855\"}]},{\"elementType\":\"labels.text.stroke\",\"stylers\":[{\"color\":\"#242f3e\"}]},{\"featureType\":\"administrative.locality\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#d59563\"}]},{\"featureType\":\"poi\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#d59563\"}]},{\"featureType\":\"poi.business\",\"stylers\":[{\"visibility\":\"off\"}]},{\"featureType\":\"poi.park\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#263c3f\"}]},{\"featureType\":\"poi.park\",\"elementType\":\"labels.text\",\"stylers\":[{\"visibility\":\"off\"}]},{\"featureType\":\"poi.park\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#6b9a76\"}]},{\"featureType\":\"road\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#38414e\"}]},{\"featureType\":\"road\",\"elementType\":\"geometry.stroke\",\"stylers\":[{\"color\":\"#212a37\"}]},{\"featureType\":\"road\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#9ca5b3\"}]},{\"featureType\":\"road.highway\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#746855\"}]},{\"featureType\":\"road.highway\",\"elementType\":\"geometry.stroke\",\"stylers\":[{\"color\":\"#1f2835\"}]},{\"featureType\":\"road.highway\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#f3d19c\"}]},{\"featureType\":\"transit\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#2f3948\"}]},{\"featureType\":\"transit.station\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#d59563\"}]},{\"featureType\":\"water\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#17263c\"}]},{\"featureType\":\"water\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#515c6d\"}]},{\"featureType\":\"water\",\"elementType\":\"labels.text.stroke\",\"stylers\":[{\"color\":\"#17263c\"}]}]";

    String googleMapLightTheme =
        "[{\"featureType\":\"poi.business\",\"stylers\":[{\"visibility\":\"off\"}]},{\"featureType\":\"poi.park\",\"elementType\":\"labels.text\",\"stylers\":[{\"visibility\":\"off\"}]}]";

    void showSheet() {
      controller.getListParkSlot();
      showFlexibleBottomSheet<void>(
        minHeight: 0,
        initHeight: 0.5,
        maxHeight: 0.9,
        anchors: [0, 0.5, 0.9],
        useRootNavigator: true,
        context: context,
        isSafeArea: false,
        bottomSheetColor: Theme.of(context).scaffoldBackgroundColor,
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0))),
        builder: (context2, scrollController, offset) {
          return HomeBootomSheet(scrollController, offset, controller);
        },
      );
    }

    Widget buildBody(
            BuildContext context, GlobalKey<ScaffoldState> sliderDrawerKey) =>
        Stack(
          children: [
            GoogleMap(
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              mapType: MapType.normal,
              markers: controller.listMaker.value,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              },
              initialCameraPosition: controller.cameraPosition,
              myLocationEnabled: true,
              compassEnabled: true,
              myLocationButtonEnabled: false,
              onMapCreated: (GoogleMapController mapController) {
                mapController.setMapStyle(
                    Get.isDarkMode ? googleMapDarkTheme : googleMapLightTheme);
                if (!controller.mapController.isCompleted) {
                  controller.mapController.complete(mapController);
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.only(
                  right: 24, left: 24, bottom: 12, top: kToolbarHeight + 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButtonCustom(
                        Icon(
                          Icons.menu,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        () async {
                          if (sliderDrawerKey.currentState!.isDrawerOpen) {
                            sliderDrawerKey.currentState!.closeDrawer();
                            controller.isOpenDrawer = false;
                          } else {
                            controller.isOpenDrawer = true;
                            sliderDrawerKey.currentState!.openDrawer();
                          }
                          controller.getProfile();
                          controller.update();
                        },
                        colors: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                          child: HomeSearchField(
                              TKeys.find_an_ev_charger.translate(),
                              () => {showSheet()})),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(bottom: 0),
                        child: HomeQRScanWidget(TKeys.scan_qr.translate(),
                            () async {
                          var status = await Permission.camera.request();
                          if (status.isDenied || status.isPermanentlyDenied) {
                            EasyLoading.showError(TKeys.fail.translate());
                            return;
                          }
                          await FlutterBluePlus.stopScan();
                          Get.toNamed("/qrcode");
                        }),
                      )),
                      const SizedBox(width: 8),
                      IconButtonCustom(
                          const Icon(
                            CupertinoIcons.location_solid,
                            color: Colors.white,
                          ), () async {
                        await controller.moveCameraCurrent();
                      }, colors: Theme.of(context).primaryColor)
                    ],
                  ),
                ],
              ),
            )
          ],
        );

    return Scaffold(
      key: sliderDrawerKey,
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.75,
        child: _SliderView(
          onItemClick: (title) async {
            sliderDrawerKey.currentState!.closeDrawer();
            controller.isOpenDrawer = false;
            switch (title) {
              case MenuEnum.profile:
                await Get.toNamed("/profile");
                final GoogleMapController controller2 =
                    await controller.mapController.future;
                controller2.setMapStyle(
                    Get.isDarkMode ? googleMapDarkTheme : googleMapLightTheme);
                controller.update();
                break;
              case MenuEnum.history:
                Get.toNamed("/list_booking");
                break;
              case MenuEnum.notification:
                Get.toNamed("/notification");
                break;
              case MenuEnum.logOut:
                showDialogCustom(context, () async {
                  EasyLoading.show();
                  await controller.letLogout();
                  Get.offAllNamed("/login");
                  EasyLoading.dismiss();
                }, question: TKeys.sign_out.translate());
                break;
              case MenuEnum.vipMember:
                Get.toNamed("/member_code");
                break;

              case MenuEnum.search:
                break;
              case MenuEnum.payment:
                break;
            }
          },
        ),
      ),
      body: Obx(() => buildBody(context, sliderDrawerKey)),
    );
  }
}

class _SliderView extends StatelessWidget {
  final Function(MenuEnum)? onItemClick;
  const _SliderView({Key? key, this.onItemClick}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: HomeController(),
        builder: (controller) {
          return Obx(() => Container(
                color: Theme.of(context).cardColor,
                padding: const EdgeInsets.only(top: 30),
                child: Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 30,
                    ),
                    ListTile(
                      leading: ClipOval(
                          child: ((controller.userModel.value.imagesPaths ??
                                      "") !=
                                  "")
                              ? Image.memory(
                                  width: 48.0,
                                  height: 48.0,
                                  base64Decode(
                                      controller.userModel.value.imagesPaths ??
                                          ""))
                              : Image.asset(
                                  "assets/images/user.png",
                                  fit: BoxFit.cover,
                                  width: 48.0,
                                  height: 48.0,
                                )),
                      title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(controller.userModel.value.fullName ?? "",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Theme.of(context).iconTheme.color)),
                            Row(
                              children: [
                                Image.asset(
                                  "assets/images/vip.png",
                                  width: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                    "${controller.userModel.value.countVIP ?? 0} VIP",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .iconTheme
                                                .color)),
                              ],
                            )
                          ]),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ...[
                      Menu(Icons.search_outlined, TKeys.search.translate(),
                          MenuEnum.search),
                      Menu(Icons.history, TKeys.history.translate(),
                          MenuEnum.history),
                      // Menu(Icons.card_membership, TKeys.member_code.translate(),
                      //     MenuEnum.vipMember),
                      Menu(Icons.notifications, TKeys.notification.translate(),
                          MenuEnum.notification),
                      Menu(Icons.settings_suggest, TKeys.profile.translate(),
                          MenuEnum.profile)
                    ]
                        .map((menu) => _SliderMenuItem(
                            title: menu,
                            iconData: menu.iconData,
                            onTap: onItemClick))
                        .toList(),
                    const Spacer(),
                    _SliderMenuItem(
                        title: Menu(Icons.logout_outlined,
                            TKeys.sign_out.translate(), MenuEnum.logOut),
                        iconData: Icons.logout_outlined,
                        onTap: onItemClick),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text("NextEnergy v1.0.1",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .color!
                                      .withOpacity(0.4))),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ));
        });
  }
}

enum MenuEnum {
  search,
  history,
  vipMember,
  profile,
  logOut,
  notification,
  payment
}

class Menu {
  final IconData iconData;
  final String title;
  final MenuEnum menuEnum;
  Menu(this.iconData, this.title, this.menuEnum);
}

class _SliderMenuItem extends StatelessWidget {
  final Menu title;
  final IconData iconData;
  final Function(MenuEnum)? onTap;

  const _SliderMenuItem(
      {Key? key,
      required this.title,
      required this.iconData,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(title.title,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).iconTheme.color)),
        leading: Icon(iconData, color: Theme.of(context).iconTheme.color),
        onTap: () => onTap?.call(title.menuEnum));
  }
}
