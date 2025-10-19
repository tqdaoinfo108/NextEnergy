import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/input_money_model.dart';
import 'input_money_controller.dart';
import '../chagre_car/widget/payment_webview_bottomsheet.dart';

class InputMoneyPage extends GetView<InputMoneyController> {
  const InputMoneyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nạp tiền"),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showInputAmountBottomSheet(context),
        icon: Icon(Icons.add),
        label: Text("Nạp tiền"),
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadHistory,
        child: Obx(() {
          if (controller.isLoadingHistory.value && controller.historyList.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Filter controls
              _buildFilterControls(context),
              
              // Danh sách lịch sử
              Expanded(
                child: controller.historyList.isEmpty
                    ? _buildEmptyState()
                    : _buildHistoryList(),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTotalMoneyCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
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
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Số dư ví",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Obx(() => Text(
                    controller.formatCurrency(controller.totalMoney.value),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                ],
              ),
              Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 40,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterControls(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Bộ lọc",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () => controller.resetFilters(),
                icon: Icon(Icons.refresh, size: 18),
                label: Text("Đặt lại"),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          
          // Date Range Filter
          Row(
            children: [
              Expanded(
                child: Obx(() => _buildDateButton(
                  context,
                  "Từ ngày",
                  controller.fromDate.value,
                  (date) => controller.updateDateRange(date, controller.toDate.value),
                )),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Obx(() => _buildDateButton(
                  context,
                  "Đến ngày",
                  controller.toDate.value,
                  (date) => controller.updateDateRange(controller.fromDate.value, date),
                )),
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
          // Status Filter
          // Obx(() => Wrap(
          //   spacing: 8,
          //   children: [
          //     _buildStatusChip("Tất cả", null),
          //     _buildStatusChip("Thành công", 1),
          //     _buildStatusChip("Chờ xử lý", 0),
          //     _buildStatusChip("Thất bại", -1),
          //   ],
          // )),
        ],
      ),
    );
  }

  Widget _buildDateButton(
    BuildContext context,
    String label,
    DateTime? date,
    Function(DateTime?) onDateSelected,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(Duration(days: 365)),
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    date != null
                        ? "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}"
                        : "Chọn ngày",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16),
          Text(
            "Chưa có lịch sử nạp tiền",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Nhấn nút \"Nạp tiền ngay\" để bắt đầu",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: controller.historyList.length,
      itemBuilder: (context, index) {
        final item = controller.historyList[index];
        return _buildHistoryItem(item, context);
      },
    );
  }

  Widget _buildHistoryItem(InputMoneyModel item, BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    
    if (item.isSuccess) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (item.isPending) {
      statusColor = Colors.orange;
      statusIcon = Icons.access_time;
    } else if (item.isFailed) {
      statusColor = Colors.red;
      statusIcon = Icons.error;
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.cancel;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.formatCurrency(item.amount),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        controller.formatDate(item.createdDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (item.orderID != null && item.orderID!.isNotEmpty) ...[
              SizedBox(height: 12),
              Divider(height: 1),
              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    "Mã giao dịch: ",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.orderID!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showInputAmountBottomSheet(BuildContext context) {
    final TextEditingController amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    // Save the parent context before showing bottom sheet
    final parentContext = context;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Nhập số tiền nạp",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: "Số tiền (VNĐ)",
                    hintText: "Ví dụ: 20000",
                    prefixText: "₫ ",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
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
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Số tiền nạp tối thiểu: 10,000 VNĐ",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Quick amount buttons
                Text(
                  "Chọn nhanh:",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildQuickAmountChip(context, amountController, 20000),
                    _buildQuickAmountChip(context, amountController, 50000),
                    _buildQuickAmountChip(context, amountController, 100000),
                    _buildQuickAmountChip(context, amountController, 200000),
                    _buildQuickAmountChip(context, amountController, 500000),
                    _buildQuickAmountChip(context, amountController, 1000000),
                  ],
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final amount = double.parse(
                          amountController.text.replaceAll(',', ''),
                        );
                        
                        // Close bottom sheet
                        Navigator.of(context).pop();
                        
                        // Use parent context for payment
                        await _processPayment(parentContext, amount);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Tiếp tục",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAmountChip(
    BuildContext context,
    TextEditingController textController,
    int amount,
  ) {
    return ActionChip(
      label: Text(
        controller.formatCurrency(amount.toDouble()).replaceAll(' ₫', 'đ'),
        style: TextStyle(fontSize: 13),
      ),
      onPressed: () {
        textController.text = amount.toString();
      },
      backgroundColor: Colors.grey[100],
      side: BorderSide(color: Colors.grey[300]!),
    );
  }

  Future<void> _processPayment(BuildContext context, double amount) async {
    // Tạo QR payment
    final redirectUri = await controller.createQRPayment(amount);
    
    if (redirectUri != null) {
      bool paymentCompleted = false;
      
      // Mở PaymentWebView
      final result = await showPaymentBottomSheet(
        context: context,
        url: redirectUri,
        onPaymentComplete: () async {
          // Chỉ gọi khi thanh toán THÀNH CÔNG
          paymentCompleted = true;
          await controller.onPaymentComplete();
        },
        onPaymentCancelled: () async {
          // Gọi khi user nhấn nút Cancel
          if (!paymentCompleted) {
            await controller.onPaymentFailed();
          }
        },
      );
      
      // Kiểm tra kết quả khi bottom sheet đóng
      // result == true: Thanh toán thành công
      // result == false hoặc null: User hủy/đóng popup
      if (result != true && !paymentCompleted) {
        // Update status = -1 (Hủy) nếu user đóng popup
        await controller.onPaymentFailed();
      }
    }
  }
}
