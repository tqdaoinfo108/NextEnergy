# BLE Reconnect Issue Fix

## Problem Description
**Issue**: After 60s scan timeout → returns to map screen → scans again → waits 60s+ without connecting

## Root Cause
The BLE status stream subscription (`_bleStatusSubscription`) was being:
1. ✅ Created in `onInit()` on first page entry
2. ❌ **Cancelled in `back()` method when user returns to map**
3. ❌ **NOT recreated on second `onInit()` call when user scans again**

This caused `_waitForBluetoothReady()` to check a stale/inactive `_bleStatus` value that was never updated, resulting in:
- The while loop waiting indefinitely (up to 5s timeout)
- BLE status never updating to `ready` because the stream listener was dead
- Second connection attempt failing with timeout

## Code Flow Before Fix
```
First scan:
onInit() → setup _bleStatusSubscription ✅ → wait for BLE ready ✅ → connect ✅

User backs out (60s timeout):
back() → cancel _bleStatusSubscription ❌ → return to map

Second scan:
onInit() → skip _bleStatusSubscription setup ❌ → wait for BLE ready (HANGS on stale data) ⏱️
```

## Solution Implemented
**Restructured `onInit()` to ensure BLE status stream is ALWAYS active before checking status:**

### Key Changes:
1. **Moved BLE status stream setup INSIDE the initialization delay**
   - Now happens after 500ms delay along with other setup
   - Ensures fresh stream on every page entry

2. **Added explicit cancellation before creating new stream**
   ```dart
   _bleStatusSubscription?.cancel(); // Cancel old stream first
   _bleStatusSubscription = _ble.statusStream.listen(...); // Create fresh stream
   ```

3. **Added 200ms delay after stream setup**
   - Gives stream time to emit first value
   - Prevents race condition where we check status before stream updates

4. **Enhanced logging in `_waitForBluetoothReady()`**
   - Added BLE log entry for status check
   - Logs every second during wait (5 checks = 1 second)
   - Better error message "Vui lòng thử lại" for unknown status

## New Code Flow
```
First scan:
onInit() → delay 500ms → cancel old stream → setup NEW _bleStatusSubscription ✅ 
       → delay 200ms → wait for BLE ready ✅ → connect ✅

User backs out:
back() → cancel _bleStatusSubscription → return to map

Second scan:
onInit() → delay 500ms → cancel old stream → setup NEW _bleStatusSubscription ✅ 
       → delay 200ms → wait for BLE ready ✅ → connect ✅
```

## Technical Details

### Modified Method: `onInit()`
**Location**: Lines ~120-180

**Before**:
- Set up BLE status stream BEFORE 500ms delay
- Stream set up only once on first page load
- Not recreated on subsequent page entries

**After**:
- Set up BLE status stream INSIDE 500ms delay
- Explicitly cancel old subscription first
- Add 200ms delay after stream setup
- Fresh stream on every page entry (including re-entry)

### Modified Method: `_waitForBluetoothReady()`
**Location**: Lines ~248-310

**Improvements**:
- Log initial BLE status when starting wait
- Count checks and log progress every 5 checks (~1 second)
- Add BLE operation log for debugging
- Better error message for unknown status

## Expected Behavior After Fix
✅ First scan: Works as before (connect in <10s)
✅ Timeout → Back → Second scan: **Now connects immediately** (no 60s+ wait)
✅ Multiple back/rescan cycles: Each scan gets fresh BLE stream
✅ Debug overlay: Shows "INFO: Checking BLE status: ready" on each scan

## Testing Checklist
- [ ] First scan connects successfully
- [ ] After 60s timeout, back button returns to map
- [ ] Second scan starts immediately (no delay)
- [ ] Second scan connects successfully (<10s)
- [ ] Third+ scans continue to work
- [ ] Debug overlay shows BLE status updates
- [ ] Logs show "Setting up BLE status stream" on each scan
- [ ] No 60s+ hanging on reconnect

## Debug Log Output (Expected)
```
First scan:
📡 Setting up BLE status stream...
📡 BLE Status: BleStatus.ready
⏳ Waiting for BLE ready... Current status: BleStatus.ready
✅ BLE ready
🔍 Scanning for device: NE240001

[60s timeout...]
User backs to map

Second scan:
📡 Setting up BLE status stream...
📡 BLE Status: BleStatus.ready
⏳ Waiting for BLE ready... Current status: BleStatus.ready
✅ BLE ready (should be IMMEDIATE, not 60s wait)
🔍 Scanning for device: NE240001
```

## Related Files
- `lib/pages/chagre_car/charge_car_controller.dart` - Main controller with fix
- `lib/pages/chagre_car/DEBUG_OVERLAY_README.md` - Debug overlay documentation
- `lib/pages/chagre_car/BLE_RECONNECT_FIX.md` - This file

## Version History
- **v1.0** (2024-10-06): Initial fix for BLE stream lifecycle issue
  - Restructured onInit() to recreate stream on every entry
  - Added 200ms delay after stream setup
  - Enhanced logging in _waitForBluetoothReady()
