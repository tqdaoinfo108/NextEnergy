import 'package:get/get.dart';

import '../../model/notification_model.dart';
import '../../model/response_base.dart';
import '../../services/getxController.dart';
import '../../services/https.dart';

class NotificationBind extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationController>(() => NotificationController());
  }
}

class NotificationController extends GetxControllerCustom {
  var listNotify = ResponseBase(totals: 0, data: []).obs;

  @override
  void onInit() {
    super.onInit();
    getListNotifyBase();
  }

  Future<bool> onClearNotification() async {
    try {
      isLoading.value = true;
      var isDelete = await HttpHelper.clearNotification();

      if (isDelete.data!) {
        await getListNotifyBase();
        return true;
      }
    } catch (e) {}
    isLoading.value = false;
    update();
    return false;
  }

  Future<void> getListNotifyBase() async {
    listNotify.value.data?.clear();
    listNotify.value.page = 1;
    isLoading.value = true;

    try {
      var listNotifyTemp =
          await HttpHelper.getNotification(listNotify.value.page!);
      if (listNotify.value.data != null) {
        listNotify.value.data = listNotifyTemp.data;
        listNotify.value.page = listNotify.value.page! + 1;
        listNotify.value.totals = listNotifyTemp.totals;
        listNotify.refresh();
      }
    } catch (e) {
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<bool> getListNotifyBaseNext() async {
    try {
      var listNotifyTemp =
          await HttpHelper.getNotification(listNotify.value.page!);
      if (listNotify.value.data != null) {
        listNotify.value.data!.addAll(listNotifyTemp.data ?? []);
        listNotify.value.page = listNotify.value.page! + 1;
        listNotify.refresh();
      }
    } catch (e) {
    } finally {
      update();
    }
    return true;
  }
}
