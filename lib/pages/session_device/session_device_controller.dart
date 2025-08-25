import 'package:get/get.dart';

import '../../model/notification_model.dart';
import '../../model/response_base.dart';
import '../../services/getxController.dart';
import '../../services/https.dart';

class SessionDeviceBind extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SessionDeviceController>(() => SessionDeviceController());
  }
}

class SessionDeviceController extends GetxControllerCustom {
  var listSessionDevice = ResponseBase(totals: 0, data: []).obs;

  @override
  void onInit() {
    super.onInit();
    getlistSessionDeviceBase();
  }

  Future<bool> onClearNotification() async {
    try {
      isLoading.value = true;
      var isDelete = await HttpHelper.clearNotification();

      if (isDelete.data!) {
        await getlistSessionDeviceBase();
        return true;
      }
    } catch (e) {}
    isLoading.value = false;
    update();
    return false;
  }

  Future<void> getlistSessionDeviceBase() async {
    listSessionDevice.value.page = 1;
    isLoading.value = true;

    try {
      var listSessionDeviceTemp =
          await HttpHelper.getListSessionDevice(listSessionDevice.value.page!);
      if (listSessionDevice.value.data != null) {
        listSessionDevice.value.data = listSessionDeviceTemp.data;
        listSessionDevice.value.page = listSessionDevice.value.page! + 1;
        listSessionDevice.value.totals = listSessionDeviceTemp.totals;
        listSessionDevice.refresh();
      }
    } catch (e) {
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<bool> getlistSessionDeviceBaseNext() async {
    try {
      var listSessionDeviceTemp =
          await HttpHelper.getListSessionDevice(listSessionDevice.value.page!);
      if (listSessionDevice.value.data != null) {
        listSessionDevice.value.data!.addAll(listSessionDeviceTemp.data ?? []);
        listSessionDevice.value.page = listSessionDevice.value.page! + 1;
        listSessionDevice.refresh();
      }
    } catch (e) {
    } finally {
      update();
    }
    return true;
  }
}
