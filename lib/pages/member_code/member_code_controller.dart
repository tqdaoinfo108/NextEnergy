import 'package:get/get.dart';

import '../../model/member_code_model.dart';
import '../../model/response_base.dart';
import '../../services/getxController.dart';
import '../../services/https.dart';
import '../../utils/const.dart';

class MemberCodeBind extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MemberCodeController>(() => MemberCodeController());
  }
}

class MemberCodeController extends GetxControllerCustom {
  var listMemeberCode =
      ResponseBase(totals: 0, data: []).obs;
      
    @override
  void onInit() {
    super.onInit();
    getListHistoryBase();
  }

  Future<void> getListHistoryBase() async {
    listMemeberCode.value.page = 1;
    isLoading.value = true;

    try {
      var listMemberCodeTemp =
          await HttpHelper.getMemberCode(listMemeberCode.value.page!);
      if (listMemeberCode.value.data != null) {
        listMemeberCode.value.data = listMemberCodeTemp.data;
        listMemeberCode.value.page = listMemeberCode.value.page! + 1;
        listMemeberCode.value.totals = listMemberCodeTemp.totals;
        listMemeberCode.refresh();
      }
    } catch (e) {
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<bool> getListHistoryBookingBaseNext() async {
    try {
      var listMemberCodeTemp =
          await HttpHelper.getMemberCode(listMemeberCode.value.page!);
      if (listMemeberCode.value.data != null) {
        listMemeberCode.value.data!.addAll(listMemberCodeTemp.data ?? []);
        listMemeberCode.value.page = listMemeberCode.value.page! + 1;
        listMemeberCode.refresh();
      }
    } catch (e) {}
    return true;
  }
}