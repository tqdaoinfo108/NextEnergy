import 'dart:convert';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:v2/pages/customs/dialog_custom.dart';
import 'package:v2/pages/home/home_bottom_sheet.dart';
import 'package:v2/pages/home/home_controller.dart';
import 'package:v2/services/localization_service.dart';

class HomePage extends GetView<HomeController> {
  HomePage({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> sliderDrawerKey = GlobalKey(); // Create a key

  @override
  Widget build(BuildContext context) {
    String googleMapDarkTheme =
        "[{\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#1a1a1a\"}]},{\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#8a8a8a\"}]},{\"elementType\":\"labels.text.stroke\",\"stylers\":[{\"color\":\"#1a1a1a\"}]},{\"featureType\":\"administrative.locality\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#ffffff\"}]},{\"featureType\":\"poi\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#8a8a8a\"}]},{\"featureType\":\"poi.business\",\"stylers\":[{\"visibility\":\"off\"}]},{\"featureType\":\"poi.park\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#2d4a2e\"}]},{\"featureType\":\"poi.park\",\"elementType\":\"labels.text\",\"stylers\":[{\"visibility\":\"off\"}]},{\"featureType\":\"road\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#2d2d2d\"}]},{\"featureType\":\"road\",\"elementType\":\"geometry.stroke\",\"stylers\":[{\"color\":\"#1a1a1a\"}]},{\"featureType\":\"road\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#8a8a8a\"}]},{\"featureType\":\"road.highway\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#3d3d3d\"}]},{\"featureType\":\"road.highway\",\"elementType\":\"geometry.stroke\",\"stylers\":[{\"color\":\"#1a1a1a\"}]},{\"featureType\":\"road.highway\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#ffffff\"}]},{\"featureType\":\"transit\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#2d2d2d\"}]},{\"featureType\":\"transit.station\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#8a8a8a\"}]},{\"featureType\":\"water\",\"elementType\":\"geometry\",\"stylers\":[{\"color\":\"#1DB954\"}]},{\"featureType\":\"water\",\"elementType\":\"labels.text.fill\",\"stylers\":[{\"color\":\"#ffffff\"}]},{\"featureType\":\"water\",\"elementType\":\"labels.text.stroke\",\"stylers\":[{\"color\":\"#1DB954\"}]}]";

    String googleMapLightTheme =
        '''[ { "featureType": "all", "elementType": "labels.text.fill", "stylers": [ { "saturation": 36 }, { "color": "#333333" }, { "lightness": 40 } ] }, { "featureType": "all", "elementType": "labels.text.stroke", "stylers": [ { "visibility": "on" }, { "color": "#ffffff" }, { "lightness": 16 } ] }, { "featureType": "all", "elementType": "labels.icon", "stylers": [ { "visibility": "off" } ] }, { "featureType": "administrative", "elementType": "geometry.fill", "stylers": [ { "color": "#fefefe" }, { "lightness": 20 } ] }, { "featureType": "administrative", "elementType": "geometry.stroke", "stylers": [ { "color": "#fefefe" }, { "lightness": 17 }, { "weight": 1.2 } ] }, { "featureType": "landscape", "elementType": "geometry", "stylers": [ { "color": "#f5f5f5" }, { "lightness": 20 } ] }, { "featureType": "poi", "elementType": "geometry", "stylers": [ { "color": "#f5f5f5" }, { "lightness": 21 } ] }, { "featureType": "poi.business", "stylers": [ { "visibility": "off" } ] }, { "featureType": "poi.park", "elementType": "geometry", "stylers": [ { "color": "#dedede" }, { "lightness": 21 } ] }, { "featureType": "poi.park", "elementType": "labels.text", "stylers": [ { "visibility": "off" } ] }, { "featureType": "road.highway", "elementType": "geometry.fill", "stylers": [ { "color": "#ffffff" }, { "lightness": 17 } ] }, { "featureType": "road.highway", "elementType": "geometry.stroke", "stylers": [ { "color": "#ffffff" }, { "lightness": 29 }, { "weight": 0.2 } ] }, { "featureType": "road.arterial", "elementType": "geometry", "stylers": [ { "color": "#ffffff" }, { "lightness": 18 } ] }, { "featureType": "road.local", "elementType": "geometry", "stylers": [ { "color": "#ffffff" }, { "lightness": 16 } ] }, { "featureType": "transit", "elementType": "geometry", "stylers": [ { "color": "#f2f2f2" }, { "lightness": 19 } ] }, { "featureType": "water", "elementType": "geometry", "stylers": [ { "color": "#e9e9e9" }, { "lightness": 17 } ] } ]''';

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
        BuildContext context, GlobalKey<ScaffoldState> sliderDrawerKey) {
      return Stack(
        children: [
          // Full screen Google Map with Obx for markers
          Positioned.fill(
            child: Obx(() => GoogleMap(
                  mapToolbarEnabled: false,
                  zoomControlsEnabled: false,
                  rotateGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                  mapType: MapType.normal,
                  markers: Set<Marker>.from(controller.listMaker),
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                  initialCameraPosition: controller.cameraPosition,
                  myLocationEnabled: true,
                  compassEnabled: false,
                  myLocationButtonEnabled: false,
                  trafficEnabled: false,
                  buildingsEnabled: true,
                  indoorViewEnabled: false,
                  liteModeEnabled: false,
                  minMaxZoomPreference: const MinMaxZoomPreference(10.0, 20.0),
                  cameraTargetBounds: CameraTargetBounds.unbounded,
                  onMapCreated: (GoogleMapController mapController) {
                    // Apply custom map style for clean, modern look
                    mapController.setMapStyle(Get.isDarkMode
                        ? googleMapDarkTheme
                        : googleMapLightTheme);
                    if (!controller.mapController.isCompleted) {
                      controller.mapController.complete(mapController);
                    }
                  },
                  onCameraMove: (CameraPosition position) {
                    // Optional: Track camera movements for advanced features
                  },
                  onTap: (LatLng latLng) {
                    // Optional: Handle map taps
                  },
                )),
          ),

          // Search bar at top with gradient shadow
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                elevation: 0,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.white.withOpacity(0.95),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Icon(Icons.search,
                          color: Theme.of(context).primaryColor, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          onTap: () => showSheet(),
                          readOnly: true,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search charging stations...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                            isDense: true,
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Material(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
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
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.tune,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Station info card at bottom with separate Obx
          Obx(() {
            final selectedStation = controller.selectedStation.value ??
                controller.listParkSlot.value.data?.first;

            if (selectedStation == null) return const SizedBox.shrink();

            return Positioned(
              left: 0,
              right: 0,
              bottom: 0, // Increased to avoid bottom navigation
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.98),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.1),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 40,
                          offset: const Offset(0, -10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedStation.nameParking!,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          "${selectedStation.distance?.toStringAsFixed(1) ?? "0"} km",
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          "24/7 Open",
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Close button
                              Material(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () =>
                                      controller.clearSelectedStation(),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Navigation button
                              Material(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {},
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Icon(
                                      Icons.navigation,
                                      color: Theme.of(context).primaryColor,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),

                        // Station stats
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      "${selectedStation.powerSocketAvailable ?? 0}",
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      TKeys.machine_availiable.translate(),
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text(
                                      "\$1.25",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Charges / kWh",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

          // My location button with separate Obx
          Obx(() {
            final stations = controller.listParkSlot.value.data ?? [];
            final hasStation = stations.isNotEmpty;

            return Positioned(
              bottom: hasStation ? 200 : 200, // Adjusted for bottom navigation
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      await controller.moveCameraCurrent();
                    },
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.my_location_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      );
    }

    return Scaffold(
      key: sliderDrawerKey,
      body: buildBody(context, sliderDrawerKey),
      bottomNavigationBar: _ModernBottomNavigationBar(),
    );
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

class _ModernSliderMenuItem extends StatelessWidget {
  final Menu title;
  final IconData iconData;
  final Function(MenuEnum)? onTap;
  final bool isLogout;

  const _ModernSliderMenuItem({
    Key? key,
    required this.title,
    required this.iconData,
    required this.onTap,
    this.isLogout = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isLogout ? Colors.red.withOpacity(0.05) : Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onTap?.call(title.menuEnum),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isLogout
                        ? Colors.red.withOpacity(0.1)
                        : Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    iconData,
                    color: isLogout
                        ? Colors.red.shade600
                        : Theme.of(context).primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isLogout ? Colors.red.shade600 : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: isLogout ? Colors.red.shade400 : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModernBottomNavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomNavItem(
                icon: Icons.home_rounded,
                label: TKeys.home.translate(),
                isActive: true,
                onTap: () {},
              ),
              _BottomNavItem(
                icon: Icons.qr_code_rounded,
                label: TKeys.scan_qr.translate(),
                isActive: false,
                onTap: () {},
              ),
              _BottomNavItem(
                icon: Icons.history_rounded,
                label: TKeys.history.translate(),
                isActive: false,
                onTap: () => Get.toNamed("/list_booking"),
              ),
              _BottomNavItem(
                icon: Icons.person_rounded,
                label: TKeys.profile.translate(),
                isActive: false,
                onTap: () => Get.toNamed("/profile"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : Colors.grey.shade500,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
