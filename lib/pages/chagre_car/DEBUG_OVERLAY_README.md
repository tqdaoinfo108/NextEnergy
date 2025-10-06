# 🔧 BLE Debug Overlay - Hướng Dẫn Sử Dụng

## Tổng Quan
Debug overlay giúp bạn theo dõi trạng thái Bluetooth Low Energy (BLE) và các thiết bị xung quanh trong thời gian thực, **bao gồm chi tiết tất cả thao tác WRITE/READ**.

## Cách Bật/Tắt Debug Mode

### Cách 1: Bật từ UI (Khuyến nghị cho testing)
1. Mở màn hình `ChargeCar` (scan QR code)
2. Nhấn vào icon **Bug** ở góc trên bên phải (AppBar)
3. Debug overlay sẽ hiển thị ngay lập tức
4. Nhấn lại icon **Bug** hoặc nút **X** trên overlay để tắt

### Cách 2: Bật mặc định từ code
Trong file `charge_car_controller.dart`, dòng 62:

```dart
// Debug mode
RxBool isDebugMode = RxBool(true); // Đổi false thành true để bật mặc định
```

**⚠️ LƯU Ý:** Nhớ đổi lại `false` trước khi release app để production.

---

## Thông Tin Hiển Thị

### 1. BLE Status (Trạng thái Bluetooth)
- **READY** 🟢: Bluetooth đã sẵn sàng
- **POWERED OFF** 🔴: Bluetooth đã tắt
- **UNAUTHORIZED** 🟠: Chưa cấp quyền Bluetooth
- **LOCATION DISABLED** 🟠: Location services bị tắt (cần cho Android)
- **UNSUPPORTED** 🔴: Thiết bị không hỗ trợ BLE

### 2. Connection State (Trạng thái kết nối)
- **CONNECTED** 🟢: Đã kết nối thành công
- **CONNECTING...** 🔵: Đang kết nối
- **DISCONNECTED** 🔴: Đã ngắt kết nối
- **DISCONNECTING...** 🟠: Đang ngắt kết nối

### 3. Authorized (Đã xác thực)
- **YES** 🟢: Đã gửi và nhận auth token thành công
- **NO** 🔴: Chưa xác thực hoặc xác thực thất bại

### 4. Target Device
- Hiển thị tên thiết bị mục tiêu (từ QR code)
- Ví dụ: `NE240001`

### 5. Connected ID
- Hiển thị MAC address của thiết bị đang kết nối
- Chỉ hiện khi đã kết nối

### 6. Last Action
- Hiển thị hành động cuối cùng trong luồng BLE
- Ví dụ: `✅ Authorized successfully`, `🔍 Scanning for: NE240001`

### 7. **📝 BLE Operations (MỚI!)**
- **Hiển thị lịch sử tất cả thao tác WRITE/READ**
- Tối đa 50 entries (tự động xóa entry cũ nhất)
- Sắp xếp mới nhất ở trên
- Mỗi log có timestamp format `[HH:MM:SS]`

#### Các loại operations:
- **✍️ WRITE** (màu xanh dương): Ghi dữ liệu lên ESP32
  - Auth value
  - BookingID
  - ON command
  - OFF command
  - EXT command
  - PAID confirmation
  
- **📖 READ** (màu xanh lá): Đọc dữ liệu từ ESP32
  - Auth response
  - Hardware status polling
  - Extension response
  
- **✅ Success** (màu xanh): Thao tác thành công
- **❌ Error** (màu đỏ): Thao tác lỗi
- **⚠️ Warning** (màu cam): Cảnh báo

---

## Nearby Devices (Thiết bị xung quanh)

### Thông tin hiển thị cho mỗi thiết bị:
- **Tên thiết bị**: Bluetooth advertised name
- **Device ID**: MAC address
- **RSSI**: Signal strength (đơn vị dBm)
  - Xanh lá (>= -60 dBm): Tín hiệu mạnh
  - Cam (-60 đến -80 dBm): Tín hiệu trung bình
  - Đỏ (< -80 dBm): Tín hiệu yếu

### Labels đặc biệt:
- **TARGET** 🟢: Đây là thiết bị mục tiêu (từ QR code)
- **CONNECTED** 🔵: Thiết bị đang được kết nối

---

## Use Cases (Khi nào dùng Debug Overlay)

### 1. Kiểm tra tại sao không quét được thiết bị
- Bật debug overlay
- Kiểm tra **BLE Status**: phải là **READY**
- Kiểm tra **Nearby Devices**: xem có thiết bị nào xuất hiện không
- Nếu có thiết bị khác nhưng không có target:
  - Kiểm tra tên thiết bị từ QR code có đúng không
  - Kiểm tra thiết bị BLE có đang bật không
  - Kiểm tra khoảng cách (RSSI phải > -80 dBm)

### 2. Kiểm tra tại sao kết nối thất bại
- Xem **Last Action**: nó sẽ hiển thị bước lỗi
- Kiểm tra **Connection State**: có застряло ở `CONNECTING...` không
- Xem RSSI của target device: nếu quá yếu (<-80) sẽ khó kết nối

### 3. Kiểm tra authorization flow
- Theo dõi **Last Action**:
  1. `🔍 Scanning for: ...`
  2. `✅ Target found: ...`
  3. `🔗 Connecting to: ...`
  4. `✅ Connected`
  5. `🔍 Discovering characteristics...`
  6. `🔐 Authorizing...`
  7. `✅ Authorized successfully`
- Nếu застряло ở bước nào, đó là điểm lỗi

### 4. **Debug WRITE/READ operations (MỚI!)**
- Xem chi tiết **BLE Operations** log
- Kiểm tra giá trị WRITE có đúng không:
  ```
  [14:23:15] ✍️ WRITE: Auth: a1b2c3d4e5f6
  [14:23:15] ✅ WRITE: Auth sent successfully
  [14:23:17] 📖 READ: Reading auth response...
  [14:23:17] 📖 READ: Response: {"bookingID":null,...}
  ```
- Nếu READ response rỗng hoặc sai format → Vấn đề ở ESP32 firmware
- Nếu WRITE failed → Kiểm tra characteristic UUID có đúng không

### 5. Debug hardware opening
- Theo dõi ON command flow:
  ```
  [14:25:00] ✍️ WRITE: ON command: ON:060:1696603500:12345
  [14:25:00] ✅ WRITE: ON command sent
  [14:25:01] 📖 READ: Polling hardware status...
  [14:25:01] 📖 READ: Status: false
  [14:25:02] 📖 READ: Polling hardware status...
  [14:25:02] 📖 READ: Status: true
  [14:25:03] ✍️ WRITE: PAID confirmation
  [14:25:03] ✅ WRITE: PAID sent successfully
  ```
- Đếm số lần polling để biết hardware mất bao lâu mới ready

### 6. Debug reconnection issues
- Khi app resume từ background
- Xem **Last Action** có hiện `🔄 Auto-reconnect...` không
- Kiểm tra **Connection State** có chuyển về CONNECTED không

---

## Ví Dụ Debugging Scenarios

### Scenario 1: "Không tìm thấy thiết bị"
```
✅ BLE Status: READY
❌ Connection: DISCONNECTED
❌ Authorized: NO
🎯 Target: NE240001
⚡ Last Action: 🔍 Scan completed (5 devices)

📍 Nearby Devices:
- NE240002 (RSSI: -65 dBm) ← Thiết bị khác
- NE240003 (RSSI: -72 dBm)
- Unknown (RSSI: -85 dBm)
```
**Phân tích**: Quét được 5 thiết bị nhưng không có `NE240001`
**Giải pháp**: 
- Kiểm tra tên QR code
- Bật ESP32 hoặc kiểm tra firmware
- Di chuyển gần hơn

---

### Scenario 2: "Застряло ở Connecting"
```
✅ BLE Status: READY
🔵 Connection: CONNECTING...
❌ Authorized: NO
🎯 Target: NE240001
⚡ Last Action: 🔗 Connecting to: AA:BB:CC:DD:EE:FF

📍 Nearby Devices:
- NE240001 [TARGET] (RSSI: -82 dBm) ← Tín hiệu yếu!
```
**Phân tích**: Tìm thấy device nhưng RSSI quá thấp
**Giải pháp**: Di chuyển điện thoại gần trạm sạc hơn

---

### Scenario 3: "Authorization thất bại"
```
✅ BLE Status: READY
✅ Connection: CONNECTED
❌ Authorized: NO
🎯 Target: NE240001
📱 Connected ID: AA:BB:CC:DD:EE:FF
⚡ Last Action: ❌ Connection flow error: Empty response

� BLE Operations:
[14:30:00] ✍️ WRITE: Auth: a1b2c3d4e5f6
[14:30:00] ✅ WRITE: Auth sent successfully
[14:30:02] 📖 READ: Reading auth response...
[14:30:02] 📖 READ: Response: 

�📍 Nearby Devices:
- NE240001 [TARGET][CONNECTED] (RSSI: -55 dBm)
```
**Phân tích**: Kết nối thành công nhưng không nhận được auth response (response rỗng)
**Giải pháp**:
- Kiểm tra firmware ESP32 có reply auth không
- Kiểm tra characteristic UUID có đúng không
- Kiểm tra logic MD5 auth

---

### Scenario 4: "Hardware không mở được"
```
✅ BLE Status: READY
✅ Connection: CONNECTED
✅ Authorized: YES

📝 BLE Operations:
[14:35:00] ✍️ WRITE: ON command: ON:060:1696603500:12345
[14:35:00] ✅ WRITE: ON command sent
[14:35:01] 📖 READ: Polling hardware status...
[14:35:01] 📖 READ: Status: false
[14:35:02] 📖 READ: Polling hardware status...
[14:35:02] 📖 READ: Status: false
... (lặp lại 90 lần)
[14:36:30] 📖 READ: Status: false
```
**Phân tích**: ON command gửi thành công nhưng hardware không chuyển sang trạng thái `true`
**Giải pháp**:
- Kiểm tra relay hardware có hoạt động không
- Kiểm tra ESP32 có nhận được ON command không (check firmware logs)
- Kiểm tra bookingID trong ON command có đúng không
- Test bằng tay: dùng nRF Connect gửi ON command để xem hardware có phản hồi không

---

## Tips & Tricks

### Tip 1: Sử dụng BLE Operations Log
- **Scroll log để xem full history** (50 entries gần nhất)
- Copy timestamp để báo cáo bug chính xác
- Kiểm tra timing giữa WRITE và READ (nên < 3s)
- Xem pattern: Mỗi WRITE phải có READ response tương ứng

### Tip 2: Debug với timestamp
- Mỗi log có timestamp `[HH:MM:SS]`
- So sánh timing để tìm bottleneck:
  ```
  [14:30:00] ✍️ WRITE: Auth
  [14:30:00] ✅ WRITE: Auth sent
  [14:30:02] 📖 READ: Response  ← 2 giây delay là bình thường
  ```
- Nếu delay > 5s → Vấn đề ESP32 processing chậm

### Tip 3: Sử dụng RSSI để tối ưu
- RSSI < -80: Quá xa, khó kết nối
- RSSI -60 đến -80: Khoảng cách lý tưởng
- RSSI > -60: Rất gần, tối ưu

### Tip 4: Theo dõi Last Action
- Mỗi action được log với timestamp
- Copy logs từ console để gửi bug report

### Tip 5: Test với nhiều thiết bị
- Debug overlay hiển thị tất cả thiết bị xung quanh
- Dễ dàng kiểm tra multi-station scenarios

### Tip 6: Screenshot debug info
- Khi gặp lỗi, chụp màn hình debug overlay
- Gửi cho team để phân tích, bao gồm cả BLE Operations log

### Tip 7: Phân tích BLE Operations pattern
- **Authorization flow chuẩn**:
  ```
  ✍️ WRITE: Auth
  ✅ WRITE: Auth sent
  📖 READ: Reading response
  📖 READ: Response: {...}
  ```
  
- **Hardware opening chuẩn**:
  ```
  ✍️ WRITE: ON command
  ✅ WRITE: ON command sent
  📖 READ: Polling... (loop 1-90 lần)
  📖 READ: Status: true
  ✍️ WRITE: PAID
  ✅ WRITE: PAID sent
  ```
  
- **Extension chuẩn**:
  ```
  ✍️ WRITE: EXT command
  ✅ WRITE: EXT sent
  📖 READ: Extension result: true
  ```

---

## Lưu Ý Production

**⚠️ QUAN TRỌNG:**
- **KHÔNG BẬT DEBUG MODE** trong bản release
- Debug overlay sẽ làm giảm performance
- Có thể leak thông tin thiết bị BLE

Trước khi build APK release:
```dart
RxBool isDebugMode = RxBool(false); // ← Phải là false!
```

---

## Technical Details

### Files liên quan:
- `charge_car_controller.dart`: Controller logic + debug tracking + **BLE logging**
- `charge_car_page.dart`: UI + debug toggle button
- `ble_debug_overlay.dart`: Debug overlay widget + **BLE operations display**

### Debug tracking points:
- Initialization
- Permission requests
- BLE status changes
- Scan start/stop/timeout
- Device discovery
- Connection state changes
- Characteristic discovery
- Authorization flow
- **All WRITE operations** (Auth, BookingID, ON, OFF, EXT, PAID)
- **All READ operations** (Auth response, status polling, extension result)
- Reconnection attempts

### BLE Operation Logging:
- **Format**: `[HH:MM:SS] OPERATION: data`
- **Max entries**: 50 (auto-rotate)
- **Display**: Reverse chronological (latest first)
- **Color-coded**: Blue (WRITE), Green (READ), Red (ERROR), Orange (WARNING)

---

## Changelog

### Version 2.0 (Current) - BLE Operations Logging
- ✅ **NEW: BLE Operations log section**
- ✅ **Track all WRITE operations**: Auth, BookingID, ON, OFF, EXT, PAID
- ✅ **Track all READ operations**: Auth response, hardware status, extension result
- ✅ Timestamp for each operation `[HH:MM:SS]`
- ✅ Color-coded logs (Blue=WRITE, Green=READ, Red=ERROR, Orange=WARNING)
- ✅ Auto-rotate logs (max 50 entries)
- ✅ Reverse chronological display (latest first)
- ✅ Scrollable log container with max height
- ✅ Icon indicators for each log type
- ✅ Monospace font for better readability

### Version 1.0
- ✅ Real-time BLE status
- ✅ Connection state tracking
- ✅ Nearby devices list with RSSI
- ✅ Last action logging
- ✅ Target device highlighting
- ✅ Toggle debug mode via UI
- ✅ Color-coded status indicators

### Future enhancements:
- [ ] Export logs to file
- [ ] Filter logs by operation type (WRITE/READ only)
- [ ] Search in logs
- [ ] Copy individual log entry
- [ ] Connection quality graph
- [ ] Auto-enable on error

---

## Support

Nếu có vấn đề với debug overlay, liên hệ team development với:
1. Screenshot của debug overlay
2. Console logs
3. Mô tả chi tiết bước tái tạo lỗi
