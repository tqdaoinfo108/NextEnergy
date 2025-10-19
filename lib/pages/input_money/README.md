# Input Money Feature - Tính năng Nạp tiền

## 📋 Tổng quan
Module nạp tiền vào ví qua VietQR với các tính năng:
- ✅ Xem lịch sử nạp tiền
- ✅ Tạo QR thanh toán VietQR
- ✅ Auto-detect thanh toán thành công
- ✅ Cập nhật trạng thái thanh toán

## 🗂️ Cấu trúc File

### Models
- `lib/model/input_money_model.dart` - Data model cho input money

### Controllers
- `lib/pages/input_money/input_money_controller.dart` - Business logic

### Views
- `lib/pages/input_money/input_money_page.dart` - UI màn hình chính

### Services
- `lib/services/https.dart` - API integration:
  - `getInputMoneyHistory()` - GET lịch sử
  - `createQRInputMoney()` - POST tạo QR
  - `updateInputMoneyStatus()` - POST cập nhật status
  - `checkInputMoneyStatus()` - GET check status

## 🔄 Flow hoạt động

### 1. Xem lịch sử
```
User → Profile → Nạp tiền
→ GET /api/input-money/get-by-userid?userID={id}
→ Hiển thị danh sách
```

### 2. Tạo nạp tiền mới
```
User → Nhấn "Nạp tiền ngay"
→ Nhập số tiền (min 10,000 VNĐ)
→ POST /api/input-money/create-qr-input-money
→ Nhận response với PaymentID & ReqRedirectionUri
```

### 3. Thanh toán
```
Mở WebView với ReqRedirectionUri (VietQR)
→ User quét mã QR bằng banking app
→ Auto-detect success từ URL/content
```

### 4. Cập nhật trạng thái

#### Thành công:
```
PaymentWebView detect success
→ POST /api/input-money/update-status
   Body: { "InputID": {paymentID}, "StatusID": 1 }
→ Reload lịch sử
→ Hiển thị thông báo "Nạp tiền thành công!"
```

#### Thất bại/Hủy:
```
User đóng WebView hoặc hủy
→ POST /api/input-money/update-status
   Body: { "InputID": {paymentID}, "StatusID": -1 }
→ Reload lịch sử
```

## 📊 Status Codes

| StatusID | Ý nghĩa | Màu hiển thị |
|----------|---------|--------------|
| 0 | Đang chờ | Orange |
| 1 | Thành công | Green |
| -1 (hoặc 2) | Thất bại | Red |
| 3 | Đã hủy | Grey |

## 🎨 UI Components

### Header Card
- Gradient background với primary color
- Icon wallet
- Button "Nạp tiền ngay"

### History List
- Card layout với status badge
- Hiển thị: Số tiền, Ngày giờ, Trạng thái, Mã giao dịch
- Pull-to-refresh
- Empty state khi chưa có giao dịch

### Input Bottom Sheet
- TextField nhập số tiền
- Validation: min 10,000 VNĐ
- Quick amount chips: 20k, 50k, 100k, 200k, 500k, 1M
- Button "Tiếp tục"

### Payment WebView
- Full-screen bottom sheet
- Header với title "Thanh toán" và nút đóng
- Loading indicator
- Back/Refresh buttons
- Auto-detect success patterns:
  - URL contains: "success", "completed", "payment-complete"
  - Content contains: "thanh toán thành công", "payment success"

## 🔧 API Endpoints

### 1. Get History
```bash
GET /api/input-money/get-by-userid?userID=5
Authorization: Basic {token}
```

### 2. Create QR Payment
```bash
POST /api/input-money/create-qr-input-money?userID=5
Authorization: Basic {token}
Content-Type: application/json

{
  "UserID": 5,
  "Amount": 20000
}
```

**Response:**
```json
{
  "data": {
    "PaymentID": 290,
    "GrossAmount": 20000.0,
    "ReqRedirectionUri": "https://pro.vietqr.vn/qr-generated?token=xxx"
  }
}
```

### 3. Update Status
```bash
POST /api/input-money/update-status?userID=5
Authorization: Basic {token}
Content-Type: application/json

{
  "InputID": 290,
  "StatusID": 1  # 1 = success, -1 = failed
}
```

## 🧪 Testing

### Test Flow thành công:
1. Mở app → Profile → Nạp tiền
2. Nhấn "Nạp tiền ngay"
3. Nhập 20000
4. Scan QR bằng banking app
5. Kiểm tra: Status = 1, hiển thị "Thành công"

### Test Flow thất bại:
1. Tạo payment
2. Đóng WebView trước khi thanh toán
3. Kiểm tra: Status = -1

### Test Edge Cases:
- Nhập số tiền < 10,000 → Show validation error
- Network error khi tạo QR → Show error message
- WebView load fail → Show error, cho phép retry

## 📝 Notes

- PaymentID được lưu trong `currentPaymentID` của controller
- Reset `currentPaymentID = null` sau khi update status
- Pull-to-refresh để reload lịch sử mới
- Format tiền tệ VNĐ: "20,000 ₫"
- Format ngày: "DD/MM/YYYY HH:mm"

## 🚀 Future Improvements

- [ ] Thêm filter theo ngày/status
- [ ] Export lịch sử ra PDF/Excel
- [ ] Push notification khi thanh toán thành công
- [ ] Retry mechanism cho failed payments
- [ ] Deep link từ banking app về app
- [ ] Hiển thị số dư ví hiện tại
