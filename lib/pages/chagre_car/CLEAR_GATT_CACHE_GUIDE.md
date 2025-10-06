# Clear GATT Cache - Quick Reference

## TL;DR
Sử dụng `await _ble.clearGattCache(deviceId)` để clear Android GATT cache trước khi thoát màn hình.

## API Usage

```dart
// Clear GATT cache (Android only, iOS no-op)
if (_deviceId != null) {
  try {
    await _ble.clearGattCache(_deviceId!);
    print("✅ GATT cache cleared");
  } catch (e) {
    print("⚠️ Clear failed: $e");
    // Continue anyway
  }
}
```

## Where We Use It

### 1. `_disconnect()` Method
```dart
Future<void> _disconnect() async {
  // Clear cache FIRST (need deviceId)
  if (_deviceId != null) {
    await _ble.clearGattCache(_deviceId!);
  }
  
  // Then clear state
  _deviceId = null;
  _targetCharacteristic = null;
  // ... rest of cleanup
}
```

### 2. `onClose()` Method
```dart
void onClose() {
  // Safety net clear
  if (_deviceId != null) {
    _ble.clearGattCache(_deviceId!);
  }
  // ... rest of cleanup
}
```

## Why It Works

- **Android**: Calls native `BluetoothGatt.refresh()` via reflection
- **iOS**: No-op (iOS manages cache automatically)
- **Effect**: Forces fresh service/characteristic discovery on next connect

## Critical Sequence

```
✅ CORRECT:
1. clearGattCache(_deviceId)  ← deviceId still available
2. _deviceId = null            ← then clear it

❌ WRONG:
1. _deviceId = null            ← lost the ID!
2. clearGattCache(_deviceId)   ← can't clear null
```

## Testing

```bash
# Build and test
flutter build apk --release

# Expected logs on disconnect:
🧹 Clearing GATT cache for device: XX:XX:XX:XX:XX:XX
✅ GATT cache cleared successfully
✅ Full disconnect completed - GATT cache cleared
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Clear failed" on some devices | Normal - some OEMs don't support it, app continues working |
| iOS doesn't log "cleared" | Expected - iOS doesn't need clearing |
| Still getting stale connections | Check you're on `flutter_reactive_ble` v5.4.0+ |

## Package Requirement

```yaml
# pubspec.yaml
dependencies:
  flutter_reactive_ble: ^5.4.0  # ← Must be 5.4.0 or higher
```

## Full Documentation

See `GATT_CLEANUP_FIX.md` for complete technical details.
