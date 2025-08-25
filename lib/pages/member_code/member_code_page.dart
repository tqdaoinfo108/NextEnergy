import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v2/model/member_code_model.dart';
import 'package:v2/pages/customs/appbar.dart';
import 'package:v2/pages/customs/circular_progress_indicator.dart';

import '../../services/localization_service.dart';
import '../../utils/date_time_utils.dart';
import '../customs/load_more_widget.dart';
import 'member_code_controller.dart';

class MemberCodePage extends GetView<MemberCodeController> {
  const MemberCodePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() =>  Scaffold(
      appBar: AppBarCustom(
        title: Text(
          TKeys.member_code.translate(),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SafeArea(
          child: controller.listMemeberCode.value.totals == 0
              ? Center(
                  child: Text(TKeys.data_not_found.translate()),
                )
              : controller.isLoading.value
                  ? const Center(
                      child: CircularProgressIndicatorCustom(),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: RefreshIndicator(
                        onRefresh: () => controller.getListHistoryBase(),
                        child: EasyLoadMore(
                          finishedStatusText: "",
                          isFinished: controller.listMemeberCode.value.data!.length >=
                              controller.listMemeberCode.value.totals!,
                          onLoadMore: () =>
                              controller.getListHistoryBookingBaseNext(),
                          runOnEmptyResult: false,
                          child: ListView.separated(
                            separatorBuilder: ((context, index) =>
                                const SizedBox(
                                  height: 20.0,
                                )),
                            itemBuilder: (BuildContext context, int index) {
                              return buildItem(context,
                                  controller.listMemeberCode.value.data![index]);
                            },
                            itemCount: controller.listMemeberCode.value.data!.length,
                          ),
                        ),
                      ),
                    )),
    ));
  }

  Widget buildItem(context, MemberCodeModel data) {
    // var dateStart = DateTime.fromMillisecondsSinceEpoch(data.timeStart! * 1000);
    // var dateEnd = DateTime.fromMillisecondsSinceEpoch(data.timeEnd! * 1000);

    return Card(
        child: ListTile(
      // trailing: IconButton(
      //   icon: Icon(Icons.keyboard_arrow_right),
      //   onPressed: () {},
      // ),
      // leading: Stack(
      //   alignment: Alignment.center,
      //   children: [
      //     CircularProgressIndicator(
      //       color: Theme.of(context).primaryColor,
      //       value: data.numberRemain! / data.numberUser!,
      //     ),
      //     Text(
      //       "${data.numberUser! - data.numberUsed!}",
      //       textAlign: TextAlign.center,
      //       style: Theme.of(context)
      //           .textTheme
      //           .bodyMedium!
      //           .copyWith(fontWeight: FontWeight.bold),
      //     ),
      //   ],
      // ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.nameParking ?? "",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).iconTheme.color)),
          Text(
              "${TKeys.expiry_date.translate()}: ${DateTimeUtils.getDateTimeString(data.timeEnd, subStringLastIndex: 10)}",
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).iconTheme.color!.withOpacity(0.6))),
        ],
      ),
    ));
  }
}
