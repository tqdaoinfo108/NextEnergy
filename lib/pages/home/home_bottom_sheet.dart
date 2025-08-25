import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/park_model.dart';
import '../../services/localization_service.dart';
import 'home_controller.dart';
import 'home_detail.dart';

class HomeBootomSheet extends StatelessWidget {
  ScrollController scrollController;
  double bottomSheetOffset;
  HomeController controller;
  HomeBootomSheet(
      this.scrollController, this.bottomSheetOffset, this.controller,
      {super.key});

  GestureDetector buildItemLocation(ParkingModel item, BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.moveCamera(item.getLatLng);
        Get.back();
        showPopupLocationDetail(context, item);
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              if (item.isVIP ?? false)
                Container(
                  decoration:
                      BoxDecoration(color: Color.fromARGB(255, 148, 116, 0)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                  child: Text(
                    TKeys.free.translate(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white),
                  ),
                ),
              Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${item.nameParking}",
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Text(
                          "${item.distance} ${item.unit}",
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${item.addressParking}",
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Card(
                          color: Theme.of(context).primaryColor,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              "${item.powerSocketAvailable} ${TKeys.available.translate()}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: Theme.of(context).cardColor),
                            ),
                          ),
                        ),
                      ],
                    )
                  ]),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: HomeController(),
        builder: (controller) {
          return Obx(() => ListView(
                padding: EdgeInsets.zero,
                controller: scrollController,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12.0),
                            topRight: Radius.circular(12.0))),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            child: TextField(
                                decoration: InputDecoration(
                                  hintText:
                                      TKeys.find_an_ev_charger.translate(),
                                  prefixIcon: const Icon(Icons.search_outlined),
                                  border: const OutlineInputBorder(),
                                  labelText:
                                      TKeys.find_an_ev_charger.translate(),
                                  isDense: true, // Added this
                                  contentPadding: const EdgeInsets.all(8),
                                ),
                                onChanged: (s) {
                                  controller.onChangeListParkSlot(s);
                                }),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 24),
                            child: Text(
                              "${TKeys.found.translate()} ${controller.listParkSlot.value.totals} ${TKeys.charge_station.translate()}",
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: [
                              for (ParkingModel item
                                  in controller.listParkSlot.value.data ?? [])
                                buildItemLocation(item, context)
                            ]),
                          )
                        ]),
                  ),
                ],
              ));
        }); // Hello world
  }
}
