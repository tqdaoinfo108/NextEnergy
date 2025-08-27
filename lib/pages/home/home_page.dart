import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart' as MapLauncher;
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

          // Enhanced search bar with modern design
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 40,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                elevation: 0,
                borderRadius: BorderRadius.circular(24),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.white.withOpacity(0.98),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.08),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      // Enhanced search icon with background
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.search_rounded,
                          color: Theme.of(context).primaryColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          onTap: () => showSheet(),
                          readOnly: true,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            hintText: TKeys.find_an_ev_charger.translate(),
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.2,
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
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
            final selectedStation = controller.selectedStation.value;
            
            // Only show if we have a station selected
            if (selectedStation == null) {
              return Container();
            }

            return AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: Material(
                  elevation: 12,
                  borderRadius: BorderRadius.circular(28),
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
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.08),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 24,
                          offset: const Offset(0, -8),
                        ),
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withOpacity(0.08),
                          blurRadius: 32,
                          offset: const Offset(0, -12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 20, 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            selectedStation.nameParking ?? "Station Name",
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                              letterSpacing: -0.5,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: (selectedStation.powerSocketAvailable ?? 0) > 0 
                                                ? const Color(0xFF10B981).withOpacity(0.1)
                                                : Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 6,
                                                height: 6,
                                                decoration: BoxDecoration(
                                                  color: (selectedStation.powerSocketAvailable ?? 0) > 0 
                                                      ? const Color(0xFF10B981)
                                                      : Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                (selectedStation.powerSocketAvailable ?? 0) > 0 ? TKeys.available.translate() : TKeys.close.translate(),
                                                style: TextStyle(
                                                  color: (selectedStation.powerSocketAvailable ?? 0) > 0 
                                                      ? const Color(0xFF10B981)
                                                      : Colors.red,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_rounded,
                                          size: 16,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${selectedStation.distance?.toStringAsFixed(1) ?? "0"} km away",
                                          style: TextStyle(
                                            color: Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Icon(
                                          Icons.access_time_rounded,
                                          size: 16,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
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
                              // Close button with improved design
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () => controller.clearSelectedStation(),
                                    child: const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Icon(
                                        Icons.close_rounded,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              
                            ],
                          ),
                        ),

                        // Station stats with improved responsive design
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width * 0.04,
                            vertical: 8,
                          ),
                          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final isSmallScreen = constraints.maxWidth < 300;
                              final fontSize = isSmallScreen ? 20.0 : 28.0;
                              final iconSize = isSmallScreen ? 20.0 : 24.0;
                              final separatorHeight = isSmallScreen ? 40.0 : 60.0;
                              
                              return Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                                          decoration: BoxDecoration(
                                            color: (selectedStation.powerSocketAvailable ?? 0) > 0 
                                                ? const Color(0xFF10B981).withOpacity(0.1)
                                                : Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Icon(
                                            Icons.ev_station_rounded,
                                            color: (selectedStation.powerSocketAvailable ?? 0) > 0 
                                                ? const Color(0xFF10B981)
                                                : Colors.red,
                                            size: iconSize,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            "${selectedStation.powerSocketAvailable ?? 0}",
                                            style: TextStyle(
                                              fontSize: fontSize,
                                              fontWeight: FontWeight.bold,
                                              color: (selectedStation.powerSocketAvailable ?? 0) > 0 
                                                  ? const Color(0xFF10B981)
                                                  : Colors.red,
                                              letterSpacing: -1,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          TKeys.machine_availiable.translate(),
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: isSmallScreen ? 11 : 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: separatorHeight,
                                    color: Colors.grey.shade300,
                                    margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 16),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Icon(
                                            Icons.bolt_rounded,
                                            color: Theme.of(context).primaryColor,
                                            size: iconSize,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            "${selectedStation.powerSocketAvailable ?? 0}",
                                            style: TextStyle(
                                              fontSize: fontSize,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).primaryColor,
                                              letterSpacing: -1,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          TKeys.total_slot.translate(),
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: isSmallScreen ? 11 : 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        
                        // Action buttons (QR Code and Open Map) with responsive design
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width * 0.04,
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final isSmallScreen = constraints.maxWidth < 320;
                              final buttonHeight = isSmallScreen ? 48.0 : 56.0;
                              final buttonSpacing = isSmallScreen ? 12.0 : 16.0;
                              final iconSize = isSmallScreen ? 18.0 : 20.0;
                              final fontSize = isSmallScreen ? 14.0 : 16.0;
                              final borderRadius = isSmallScreen ? 24.0 : 28.0;
                              final horizontalPadding = isSmallScreen ? 12.0 : 20.0;
                              
                              return Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: buttonHeight,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF10B981),
                                            Color(0xFF059669),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(borderRadius),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF10B981).withOpacity(0.3),
                                            blurRadius: isSmallScreen ? 12 : 20,
                                            offset: Offset(0, isSmallScreen ? 4 : 8),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(borderRadius),
                                          onTap: () => Get.toNamed('/qrcode'),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                if (!isSmallScreen || constraints.maxWidth > 280) ...[
                                                  Container(
                                                    padding: const EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withOpacity(0.2),
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Icon(
                                                      Icons.qr_code_scanner_rounded,
                                                      color: Colors.white,
                                                      size: iconSize,
                                                    ),
                                                  ),
                                                  SizedBox(width: isSmallScreen ? 8 : 12),
                                                ] else ...[
                                                  Icon(
                                                    Icons.qr_code_scanner_rounded,
                                                    color: Colors.white,
                                                    size: iconSize,
                                                  ),
                                                  const SizedBox(width: 6),
                                                ],
                                                Flexible(
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      TKeys.scan_qr.translate(),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: fontSize,
                                                        fontWeight: FontWeight.w600,
                                                        letterSpacing: 0.3,
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
                                  ),
                                  SizedBox(width: buttonSpacing),
                                  Expanded(
                                    child: Container(
                                      height: buttonHeight,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(borderRadius),
                                        border: Border.all(
                                          color: const Color(0xFF10B981),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: isSmallScreen ? 12 : 20,
                                            offset: Offset(0, isSmallScreen ? 4 : 8),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(borderRadius),
                                          onTap: () async {
                                            try {
                                              EasyLoading.show(status: 'Đang bật bản đồ ...');
                                              final availableMaps = await MapLauncher.MapLauncher.installedMaps;
                                              if (availableMaps.isEmpty) {
                                                EasyLoading.showError(
                                                  TKeys.maps_app_not_found.translate(),
                                                  duration: const Duration(seconds: 5)
                                                );
                                                return;
                                              }
                                              await availableMaps.first.showMarker(
                                                coords: MapLauncher.Coords(
                                                  selectedStation.getLatLng.latitude,
                                                  selectedStation.getLatLng.longitude
                                                ),
                                                title: selectedStation.nameParking ?? "",
                                              );
                                              EasyLoading.dismiss();
                                            } catch (e) {
                                              EasyLoading.showError(
                                                TKeys.maps_app_not_found.translate(),
                                                duration: const Duration(seconds: 5)
                                              );
                                            }
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                if (!isSmallScreen || constraints.maxWidth > 280) ...[
                                                  Container(
                                                    padding: const EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF10B981).withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Icon(
                                                      Icons.navigation_rounded,
                                                      color: const Color(0xFF10B981),
                                                      size: iconSize,
                                                    ),
                                                  ),
                                                  SizedBox(width: isSmallScreen ? 8 : 12),
                                                ] else ...[
                                                  Icon(
                                                    Icons.navigation_rounded,
                                                    color: const Color(0xFF10B981),
                                                    size: iconSize,
                                                  ),
                                                  const SizedBox(width: 6),
                                                ],
                                                Flexible(
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      TKeys.open_map.translate(),
                                                      style: TextStyle(
                                                        color: const Color(0xFF10B981),
                                                        fontSize: fontSize,
                                                        fontWeight: FontWeight.w600,
                                                        letterSpacing: 0.3,
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
                                  ),
                                ],
                              );
                            },
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
            final selectedStation = controller.selectedStation.value;
            final hasSelectedStation = selectedStation != null;

            return AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              bottom: hasSelectedStation
                  ? 400 // Increased to accommodate enhanced station card
                  : 20, // Adjusted based on station card visibility
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
    );
  }
}
