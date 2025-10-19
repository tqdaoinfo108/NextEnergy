# Input Money API Update - Filter Support

## 📋 Overview
Updated the Input Money feature to work with the new API endpoint that supports filtering by date range and status.

## 🔄 API Changes

### Old API
```
GET /api/input-money/get-by-userid?userID={id}
```

### New API
```
GET /api/input-money/get-money-by-user?userID={id}&fromDate={date}&toDate={date}&statusID={status}
```

### Query Parameters
- `userID` (required): User ID
- `fromDate` (optional): Start date in format `dd/MM/yyyy` (e.g., `01/01/2025`)
- `toDate` (optional): End date in format `dd/MM/yyyy` (e.g., `31/01/2025`)
- `statusID` (optional): Filter by status
  - `null` or `100`: All statuses
  - `1`: Success (Thành công)
  - `0`: Pending (Chờ xử lý)
  - `-1`: Failed (Thất bại)

### Example Request
```bash
curl -X 'GET' \
  'https://apichargingvietnam.gvbsoft.vn/api/input-money/get-money-by-user?userID=1&fromDate=01%2F01%2F2025&toDate=01%2F01%2F2025&statusID=100' \
  -H 'accept: application/json'
```

## 🎨 UI Changes

### 1. **Filter Controls Panel**
Added a new filter section below the header card with:

- **Date Range Picker**: 
  - "Từ ngày" (From Date) button
  - "Đến ngày" (To Date) button
  - Opens native DatePicker dialog
  - Default range: Last 30 days

- **Status Filter Chips**:
  - "Tất cả" (All) - Shows all transactions
  - "Thành công" (Success) - statusID = 1
  - "Chờ xử lý" (Pending) - statusID = 0
  - "Thất bại" (Failed) - statusID = -1

- **Reset Button**: Quickly reset all filters to default

### 2. **Visual Design**
- Clean, modern filter panel with light gray background
- Color-coded status chips (Green/Orange/Red/Blue)
- Date buttons with calendar icon
- Compact layout that doesn't overwhelm the screen

## 💻 Code Changes

### `lib/services/https.dart`
```dart
static Future<ResponseBase<List<dynamic>>?> getInputMoneyHistory(
    int userID, {
    String? fromDate,
    String? toDate,
    int? statusID,
  }) async {
  try {
    Map<String, dynamic> queryParams = {"userID": userID};
    
    if (fromDate != null) queryParams["fromDate"] = fromDate;
    if (toDate != null) queryParams["toDate"] = toDate;
    if (statusID != null) queryParams["statusID"] = statusID;
    
    var response = await DioRequest.getHttp(
        "/api/input-money/get-money-by-user",
        query: queryParams);
    // ...
  }
}
```

### `lib/pages/input_money/input_money_controller.dart`
**Added fields:**
```dart
Rx<DateTime?> fromDate = Rx<DateTime?>(null);
Rx<DateTime?> toDate = Rx<DateTime?>(null);
RxnInt selectedStatusID = RxnInt(null);
```

**Added methods:**
```dart
void resetFilters()
void updateDateRange(DateTime? from, DateTime? to)
void updateStatusFilter(int? statusID)
```

**Updated loadHistory():**
- Formats DateTime to `dd/MM/yyyy` string
- Passes optional parameters to API

### `lib/pages/input_money/input_money_page.dart`
**Added widgets:**
```dart
Widget _buildFilterControls(BuildContext context)
Widget _buildDateButton(...)
Widget _buildStatusChip(String label, int? statusID)
```

## 🚀 Features

✅ **Date Range Filtering**: Filter transactions by custom date range
✅ **Status Filtering**: Quick filter by transaction status
✅ **Default Range**: Shows last 30 days by default
✅ **Reset Filters**: One-click reset to default state
✅ **Reactive UI**: Real-time updates using GetX observables
✅ **Visual Feedback**: Selected filters are highlighted
✅ **Mobile-Friendly**: Compact design for small screens

## 🎯 User Flow

1. **Initial Load**:
   - Shows transactions from last 30 days
   - All statuses included

2. **Filter by Date**:
   - Tap "Từ ngày" or "Đến ngày"
   - Select date from picker
   - List auto-updates

3. **Filter by Status**:
   - Tap a status chip
   - List shows only matching transactions
   - Chip is highlighted

4. **Reset Filters**:
   - Tap "Đặt lại" button
   - Returns to default 30-day range
   - Shows all statuses

## 📱 Screenshots Layout

```
┌─────────────────────────────────┐
│  [Header Card - Nạp tiền]      │
├─────────────────────────────────┤
│  Bộ lọc              [Đặt lại]  │
│  ┌──────────┐  ┌──────────┐    │
│  │Từ ngày   │  │Đến ngày  │    │
│  │01/01/2025│  │31/01/2025│    │
│  └──────────┘  └──────────┘    │
│                                 │
│  [Tất cả] [Thành công]         │
│  [Chờ xử lý] [Thất bại]        │
├─────────────────────────────────┤
│  [Transaction List]             │
│  ...                            │
└─────────────────────────────────┘
```

## 🔍 Testing Checklist

- [ ] Date picker opens and closes properly
- [ ] From date cannot be after To date (optional validation)
- [ ] Status chips toggle correctly
- [ ] API receives correct date format `dd/MM/yyyy`
- [ ] API receives correct statusID values
- [ ] Reset button clears all filters
- [ ] List updates when filters change
- [ ] Pull-to-refresh works with active filters
- [ ] Empty state shows when no results
- [ ] Loading indicator appears during API call

## 🐛 Known Issues
None currently

## 🔮 Future Enhancements
- [ ] Date range presets (Today, This Week, This Month)
- [ ] Amount range filter
- [ ] Export filtered data
- [ ] Save filter presets
- [ ] Validation: fromDate <= toDate
- [ ] Total amount summary for filtered results

## 📝 Notes
- Date format must be `dd/MM/yyyy` for API compatibility
- StatusID `100` is treated as "show all" by backend
- Null statusID means no filter applied (same as 100)
- Default range prevents loading too much data on initial load
