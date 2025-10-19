import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../model/input_money_model.dart';
import '../../services/base_hive.dart';
import '../../services/getxController.dart';
import '../../services/https.dart';
import '../../services/localization_service.dart';
import '../../utils/const.dart';

class InputMoneyBind extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InputMoneyController>(() => InputMoneyController());
  }
}

class InputMoneyController extends GetxControllerCustom {
  RxList<InputMoneyModel> historyList = <InputMoneyModel>[].obs;
  RxBool isLoadingHistory = false.obs;
  RxBool isCreatingPayment = false.obs;
  
  // Lưu paymentID hiện tại để update status
  int? currentPaymentID;
  
  // Total money from API
  RxDouble totalMoney = 0.0.obs;
  
  // Filter fields
  Rx<DateTime?> fromDate = Rx<DateTime?>(null);
  Rx<DateTime?> toDate = Rx<DateTime?>(null);
  RxnInt selectedStatusID = RxnInt(null); // null = all, 1 = success, 0 = pending, -1 = failed
  
  int get userID => HiveHelper.get(Constants.USER_ID);

  @override
  void onInit() {
    super.onInit();
    // Set default date range: last 30 days
    toDate.value = DateTime.now();
    fromDate.value = DateTime.now().subtract(Duration(days: 30));
    loadHistory();
  }

  @override
  void onClose() {
    // Refresh profile page's total money when leaving this page
    // Force update by getting latest from API
    _refreshProfileBalance();
    super.onClose();
  }

  // Refresh profile balance
  Future<void> _refreshProfileBalance() async {
    try {
      var response = await HttpHelper.getProfile(userID);
      if (response != null && response.data != null) {
        final latestTotalMoney = response.data!.totalMoney ?? 0;
        HiveHelper.put(Constants.TOTAL_MONEY, latestTotalMoney);
        print("✅ Profile balance updated: $latestTotalMoney VND");
      }
    } catch (e) {
      print("❌ Error refreshing profile balance: $e");
    }
  }

  // Load lịch sử nạp tiền with filters
  Future<void> loadHistory() async {
    try {
      isLoadingHistory.value = true;
      
      // Format dates to dd/MM/yyyy
      String? fromDateStr;
      String? toDateStr;
      
      if (fromDate.value != null) {
        fromDateStr = "${fromDate.value!.day.toString().padLeft(2, '0')}/${fromDate.value!.month.toString().padLeft(2, '0')}/${fromDate.value!.year}";
      }
      
      if (toDate.value != null) {
        toDateStr = "${toDate.value!.day.toString().padLeft(2, '0')}/${toDate.value!.month.toString().padLeft(2, '0')}/${toDate.value!.year}";
      }
      
      var response = await HttpHelper.getInputMoneyHistory(
        userID,
        fromDate: fromDateStr,
        toDate: toDateStr,
        statusID: selectedStatusID.value,
      );
      
      if (response != null && response.data != null) {
        // Extract totalMoney
        totalMoney.value = (response.data!['totalMoney'] ?? 0.0).toDouble();
        
        // Extract transaction list
        var dataList = response.data!['data'] as List<dynamic>?;
        if (dataList != null) {
          historyList.value = dataList
              .map((json) => InputMoneyModel.fromJson(json))
              .toList();
          
          // Sắp xếp theo ngày tạo mới nhất
          historyList.sort((a, b) {
            if (a.createdDate == null) return 1;
            if (b.createdDate == null) return -1;
            return b.createdDate!.compareTo(a.createdDate!);
          });
        }
        
        // Update total money in Hive for profile page
        HiveHelper.put(Constants.TOTAL_MONEY, totalMoney.value.toInt());
      }
    } catch (e) {
      print("Error loading history: $e");
      EasyLoading.showError("Không thể tải lịch sử nạp tiền");
    } finally {
      isLoadingHistory.value = false;
    }
  }

  // Reset filters
  void resetFilters() {
    toDate.value = DateTime.now();
    fromDate.value = DateTime.now().subtract(Duration(days: 30));
    selectedStatusID.value = null;
    loadHistory();
  }

  // Update date range
  void updateDateRange(DateTime? from, DateTime? to) {
    fromDate.value = from;
    toDate.value = to;
    loadHistory();
  }

  // Update status filter
  void updateStatusFilter(int? statusID) {
    selectedStatusID.value = statusID;
    loadHistory();
  }

  // Tạo QR nạp tiền
  Future<String?> createQRPayment(double amount) async {
    try {
      isCreatingPayment.value = true;
      EasyLoading.show(status: "Đang xử lý...");
      
      var response = await HttpHelper.createQRInputMoney(userID, amount);
      
      EasyLoading.dismiss();
      
      if (response != null && response.data != null) {
        var paymentData = response.data!;
        String? redirectUri = paymentData['ReqRedirectionUri'] as String?;
        
        // Lưu paymentID để update status sau
        currentPaymentID = paymentData['PaymentID'] as int?;
        
        if (redirectUri != null && redirectUri.isNotEmpty) {
          return redirectUri;
        } else {
          EasyLoading.showError("Không nhận được link thanh toán");
          return null;
        }
      } else {
        EasyLoading.showError(response?.message ?? "Tạo thanh toán thất bại");
        return null;
      }
    } catch (e) {
      print("Error creating QR payment: $e");
      EasyLoading.dismiss();
      EasyLoading.showError("Có lỗi xảy ra khi tạo thanh toán");
      return null;
    } finally {
      isCreatingPayment.value = false;
    }
  }

  // Kiểm tra trạng thái thanh toán
  Future<bool> checkPaymentStatus(int paymentID) async {
    try {
      var response = await HttpHelper.checkInputMoneyStatus(paymentID);
      
      if (response != null && response.data != null) {
        var status = response.data!['Status'] as int?;
        return status == 1; // 1 = thành công
      }
      return false;
    } catch (e) {
      print("Error checking payment status: $e");
      return false;
    }
  }

  // Callback khi thanh toán thành công
  Future<void> onPaymentComplete() async {
    if (currentPaymentID == null) {
      print("❌ No paymentID to update");
      EasyLoading.showError("Không có thông tin thanh toán");
      return;
    }

    try {
      print("✅ Updating payment status to SUCCESS for PaymentID: $currentPaymentID");
      
      // Gọi API update status = 1 (thành công)
      var response = await HttpHelper.updateInputMoneyStatus(
        userID,
        currentPaymentID!,
        1, // StatusID = 1 (Thành công)
      );

      if (response != null) {
        EasyLoading.showSuccess(
          "Nạp tiền thành công!",
          duration: Duration(seconds: 3),
        );
        
        // Reset paymentID
        currentPaymentID = null;
        
        // Reload lịch sử
        await loadHistory();
        
        // Có thể refresh user profile để cập nhật số dư
        // await HttpHelper.getProfile(userID);
      } else {
        EasyLoading.showError("Cập nhật trạng thái thất bại");
      }
    } catch (e) {
      print("❌ Error updating payment status: $e");
      EasyLoading.showError("Có lỗi khi cập nhật trạng thái");
    }
  }

  // Callback khi thanh toán thất bại hoặc bị hủy
  Future<void> onPaymentFailed() async {
    if (currentPaymentID == null) {
      print("❌ No paymentID to update (already processed or not created)");
      return;
    }

    final paymentIDToUpdate = currentPaymentID;
    // Reset ngay để tránh duplicate calls
    currentPaymentID = null;

    try {
      print("❌ Updating payment status to CANCELLED for PaymentID: $paymentIDToUpdate");
      
      // Gọi API update status = -1 (hủy/thất bại)
      await HttpHelper.updateInputMoneyStatus(
        userID,
        paymentIDToUpdate!,
        -1, // StatusID = -1 (Hủy)
      );
      
      // Reload lịch sử
      await loadHistory();
    } catch (e) {
      print("❌ Error updating payment failed status: $e");
    }
  }

  // Hiển thị dialog nhập số tiền
  Future<void> showInputAmountDialog(BuildContext context) async {
    final TextEditingController amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Nhập số tiền nạp"),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Số tiền (VNĐ)",
                  hintText: "Ví dụ: 20000",
                  prefixText: "₫ ",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập số tiền";
                  }
                  final amount = double.tryParse(value.replaceAll(',', ''));
                  if (amount == null || amount <= 0) {
                    return "Số tiền không hợp lệ";
                  }
                  if (amount < 10000) {
                    return "Số tiền tối thiểu 10,000 VNĐ";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(
                "Số tiền nạp tối thiểu: 10,000 VNĐ",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(TKeys.cancel.translate()),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop();
                
                final amount = double.parse(
                  amountController.text.replaceAll(',', ''),
                );
                
                // Tạo QR payment và mở WebView
                await processPayment(context, amount);
              }
            },
            child: Text("Tiếp tục"),
          ),
        ],
      ),
    );
  }

  // Xử lý payment flow
  Future<void> processPayment(BuildContext context, double amount) async {
    // Tạo QR payment
    final redirectUri = await createQRPayment(amount);
    
    if (redirectUri != null) {
      // Import và sử dụng PaymentWebViewBottomSheet
      final result = await Get.bottomSheet(
        _buildPaymentWebView(redirectUri),
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
      );
      
      if (result == true) {
        await onPaymentComplete();
      }
    }
  }

  // Build PaymentWebView widget
  Widget _buildPaymentWebView(String url) {
    // Sẽ implement trong UI file
    return Container();
  }

  // Format số tiền
  String formatCurrency(double? amount) {
    if (amount == null) return "0 ₫";
    return "${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )} ₫";
  }

  // Format ngày tháng
  String formatDate(DateTime? date) {
    if (date == null) return "-";
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}
