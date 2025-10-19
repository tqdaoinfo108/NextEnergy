# Input Money API Response Structure Update

## 🔄 API Response Change

### Old Response Structure
```json
{
  "data": [
    {
      "PaymentID": 1,
      "UserID": 5,
      "Amount": 20000,
      "Status": 1,
      ...
    }
  ]
}
```

### New Response Structure
```json
{
  "data": {
    "totalMoney": 2000,
    "data": [
      {
        "UUserID": "908245345",
        "PhoneUser": "0908245345",
        "FullName": "Tên tài khoản",
        "TypeUserID": 3,
        "TypeName": "User Normal",
        "InputID": 1,
        "InputCode": "7db7b256-3b73-4a96-8e02-1dbf1522d69a",
        "DateInput": 1759251600,
        "Amount": 2000.0,
        "StatusID": 1
      }
    ]
  }
}
```

## 🔧 Changes Made

### 1. **Updated Model** (`lib/model/input_money_model.dart`)

**Added New Fields:**
```dart
int? inputID;           // InputID from API
String? inputCode;      // InputCode (transaction UUID)
String? uUserID;        // UUserID (user identifier)
String? phoneUser;      // PhoneUser
String? fullName;       // FullName
int? typeUserID;        // TypeUserID
String? typeName;       // TypeName (e.g., "User Normal")
int? dateInput;         // DateInput (Unix timestamp)
int? statusID;          // StatusID (replaces Status)
```

**Key Changes:**
- Parses `DateInput` Unix timestamp to DateTime
- Maps `StatusID` to status
- Maps `InputCode` to orderID
- Supports both old and new field names for backward compatibility
- Updated `statusText` getter to handle StatusID values: -1, 0, 1, 2, 3

### 2. **Updated API Handler** (`lib/services/https.dart`)

**Changed Return Type:**
```dart
// Old
Future<ResponseBase<List<dynamic>>?> getInputMoneyHistory(...)

// New
Future<ResponseBase<Map<String, dynamic>>?> getInputMoneyHistory(...)
```

**Response Parsing:**
```dart
var responseData = response.data['data'];
if (responseData is Map<String, dynamic>) {
  return ResponseBase<Map<String, dynamic>>(
    data: {
      'totalMoney': responseData['totalMoney'],
      'data': responseData['data'] as List<dynamic>?,
    },
    ...
  );
}
```

### 3. **Updated Controller** (`lib/pages/input_money/input_money_controller.dart`)

**Added Field:**
```dart
RxDouble totalMoney = 0.0.obs;  // Total wallet balance
```

**Updated loadHistory():**
```dart
// Extract totalMoney
totalMoney.value = (response.data!['totalMoney'] ?? 0.0).toDouble();

// Extract transaction list
var dataList = response.data!['data'] as List<dynamic>?;
if (dataList != null) {
  historyList.value = dataList
      .map((json) => InputMoneyModel.fromJson(json))
      .toList();
  ...
}

// Update Hive for profile page
HiveHelper.put(Constants.TOTAL_MONEY, totalMoney.value.toInt());
```

### 4. **Updated UI** (`lib/pages/input_money/input_money_page.dart`)

**Added Total Money Card:**
```dart
Widget _buildTotalMoneyCard(BuildContext context) {
  // Displays wallet balance in gradient card
  // Shows totalMoney with formatted currency
}
```

**Added Floating Action Button:**
```dart
floatingActionButton: FloatingActionButton.extended(
  onPressed: () => _showInputAmountBottomSheet(context),
  icon: Icon(Icons.add),
  label: Text("Nạp tiền"),
),
```

**Removed:**
- Old `_buildHeaderCard` (replaced by `_buildTotalMoneyCard`)

## 📱 UI Layout

```
┌─────────────────────────────────┐
│  [AppBar: Nạp tiền]            │
├─────────────────────────────────┤
│  ┌───────────────────────────┐  │
│  │ Số dư ví         💰       │  │
│  │ 2,000 ₫                   │  │
│  └───────────────────────────┘  │
├─────────────────────────────────┤
│  Bộ lọc              [Đặt lại]  │
│  ┌──────────┐  ┌──────────┐    │
│  │Từ ngày   │  │Đến ngày  │    │
│  └──────────┘  └──────────┘    │
├─────────────────────────────────┤
│  [Transaction List]             │
│  ┌─────────────────────────┐   │
│  │ ✓ 2,000 ₫    Thành công │   │
│  │ 01/01/2025 10:00        │   │
│  │ Mã: 7db7b256-3b73...    │   │
│  └─────────────────────────┘   │
│  ...                            │
└─────────────────────────────────┘
                    [+ Nạp tiền] ← FAB
```

## 🎯 Features

✅ **Wallet Balance Display**: Shows `totalMoney` from API in gradient card
✅ **Transaction History**: Lists all input money transactions
✅ **Date Filtering**: Filter by date range (dd/MM/yyyy format)
✅ **Status Display**: Shows transaction status with color coding
✅ **Floating Action Button**: Easy access to add money
✅ **Auto-sync Balance**: Updates Hive storage for profile page
✅ **Backward Compatible**: Supports both old and new field names

## 📊 Data Flow

```
1. User opens Input Money page
   ↓
2. Controller loads history with date filters
   ↓
3. API returns: { data: { totalMoney: X, data: [...] } }
   ↓
4. Controller extracts:
   - totalMoney → totalMoney.value
   - data array → historyList
   ↓
5. UI displays:
   - Total Money Card (totalMoney)
   - Transaction List (historyList)
   ↓
6. totalMoney saved to Hive (Constants.TOTAL_MONEY)
   ↓
7. Profile page reads from Hive and shows balance
```

## 🔍 Field Mapping

| New API Field | Model Field | Old API Field | Notes |
|--------------|-------------|---------------|-------|
| InputID | inputID | PaymentID | Transaction ID |
| InputCode | inputCode | OrderID | UUID string |
| StatusID | statusID | Status | -1=fail, 0=pending, 1=success |
| DateInput | dateInput → createdDate | CreatedDate | Unix timestamp |
| Amount | amount | Amount | Double value |
| UUserID | uUserID | - | User identifier |
| PhoneUser | phoneUser | - | User phone |
| FullName | fullName | - | User name |
| TypeUserID | typeUserID | - | User type |
| TypeName | typeName | - | User type name |

## 🐛 Error Handling

- ✅ Handles null/missing fields gracefully
- ✅ Validates Unix timestamp parsing
- ✅ Falls back to Hive data on API error
- ✅ Shows error toast on failure
- ✅ Empty state when no transactions

## 🧪 Testing Checklist

- [ ] Total money displays correctly
- [ ] Transaction list shows with new fields
- [ ] Date filter works with dd/MM/yyyy format
- [ ] DateInput timestamp converts to readable date
- [ ] Status colors match StatusID values
- [ ] FAB opens input amount bottom sheet
- [ ] Balance syncs to profile page
- [ ] Backward compatible with old API (if needed)
- [ ] Pull-to-refresh updates totalMoney
- [ ] InputCode displays as transaction ID

## 💡 Notes

- **DateInput Format**: Unix timestamp (seconds), converted to milliseconds for DateTime
- **StatusID Values**: -1 (fail), 0 (pending), 1 (success), 2 (failed), 3 (cancelled)
- **totalMoney**: Stored in Hive as integer for profile page
- **Backward Compatibility**: Model supports both old and new field names
- **InputCode**: UUID format, displayed as truncated transaction ID

## 🔮 Future Enhancements

- [ ] Show user info in transaction details (fullName, phoneUser)
- [ ] Filter by transaction type (TypeUserID/TypeName)
- [ ] Export transaction history
- [ ] Transaction receipt/invoice
- [ ] Real-time balance updates
