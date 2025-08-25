import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:v2/model/park_model.dart';
import 'package:v2/pages/customs/button.dart';
import 'package:map_launcher/map_launcher.dart' as MapLauncher;

import '../../services/localization_service.dart';

showPopupLocationDetail(BuildContext ctx, ParkingModel data) {
  Get.dialog(
    Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
          side:
              BorderSide(width: 1, color: Theme.of(ctx).dialogBackgroundColor),
          borderRadius: const BorderRadius.all(Radius.circular(12.0))),
      child: IntrinsicHeight(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
              color: Theme.of(ctx).dialogBackgroundColor,
              borderRadius: const BorderRadius.all(Radius.circular(12.0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${data.nameParking}",
                    maxLines: 1,
                    style: Theme.of(ctx)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close)),
                ],
              ),
              Text("${data.distance} ${data.unit}",
                  style: Theme.of(ctx).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Text(
                "${data.addressParking}",
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
              Text(
                "${TKeys.machine_availiable.translate()}: ${data.powerSocketAvailable}",
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                      child: ButtonPrimary(TKeys.cancel.translate(),
                          color: Colors.green, onPress: () => Get.back())),
                  const SizedBox(width: 8),
                  Expanded(
                      child: ButtonPrimary(TKeys.open_map.translate(),
                          color: Colors.purple, onPress: () async {
                    Get.back();
                    final availableMaps =
                        await MapLauncher.MapLauncher.installedMaps;
                    if (availableMaps.isEmpty) {
                      EasyLoading.showError(
                          TKeys.maps_app_not_found.translate(),
                          duration: const Duration(seconds: 5));
                      return;
                    }
                    await availableMaps.first.showMarker(
                      coords: MapLauncher.Coords(
                          data.getLatLng.latitude, data.getLatLng.longitude),
                      title: data.nameParking ?? "",
                    );
                  }))
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                      child:
                          ButtonPrimary(TKeys.scan_qr.translate(), onPress: () {
                    Get.back();
                    Get.toNamed("/qrcode");
                  }))
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
