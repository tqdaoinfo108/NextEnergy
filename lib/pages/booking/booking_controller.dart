import 'package:get/get.dart';

import '../../model/response_base.dart';
import '../../services/getxController.dart';
import '../../services/https.dart';

class BookingBind extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingController>(() => BookingController());
  }
}

class BookingController extends GetxControllerCustom {
  @override
  void onInit() {
    super.onInit();
    getListHistoryBase();
  }

  var listBooking =
      ResponseBase(totals: 0, data: []).obs;

  Future<void> getListHistoryBase() async {
    listBooking.value.page = 1;
    isLoading.value = true;
    update();
    try {
      var listNotifyTemp =
          await HttpHelper.getHistoryBooking(listBooking.value.page!);
      if (listBooking.value.data != null) {
        listBooking.value.data = listNotifyTemp.data;
        listBooking.value.page = listBooking.value.page! + 1;
        listBooking.value.totals = listNotifyTemp.totals;
        listBooking.refresh();
      }
    } catch (e) {
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<bool> getListHistoryBookingBaseNext() async {
    try {
      var listNotifyTemp =
          await HttpHelper.getHistoryBooking(listBooking.value.page!);
      if (listBooking.value.data != null) {
        listBooking.value.data!.addAll(listNotifyTemp.data ?? []);
        listBooking.value.page = listBooking.value.page! + 1;
        listBooking.refresh();
      }
    } catch (e) {}
    return true;
  }
}
