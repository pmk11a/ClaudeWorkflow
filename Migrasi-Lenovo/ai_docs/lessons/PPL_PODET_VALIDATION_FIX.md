# PPL PO Detail Validation Fix

## Issue
Validasi yang ada di Delphi untuk cek apakah PR detail sudah terdaftar di PO tidak menampilkan informasi detail PO di Laravel.

**Delphi Error Message** (FrmPPL.pas, KoreksiBtnClick & HapusBtnClick):
```
'NoBukti='+NoBukti.Text+' dan Kodebrg='+QuBeliKodeBrg.AsString+' Sudah Ada Transaksi di PO Nobukti'+ QuotedStr(DM.QuCari.fieldbyname('nobukti').asstring)
```
Result: `NoBukti=PR/0001/12/2025 dan Kodebrg=1142.3.1.014 Sudah Ada Transaksi di PO Nobukti PO/0042/12/2025`

**Laravel Error Message** (Before Fix):
```
'Baris ini sudah terdaftar dalam PO dan tidak dapat diubah.'
'Baris ini sudah terdaftar dalam PO dan tidak dapat dihapus.'
```
Result: Generic message tanpa informasi PO mana yang menggunakan item tersebut

## Solution

### 1. Enhanced `checkPOUsage()` Method
File: `app/Services/PPLService.php`, lines 399-439

**Perubahan:**
- Before: Returns boolean `true/false`
- After: Returns array with PO details
  ```php
  [
      'exists' => true,
      'noBuktiPO' => 'PO/0042/12/2025',
      'kodeBrg' => '1142.3.1.014',
      'urutPPL' => 1,
  ]
  ```

**Implementasi:**
```php
public function checkPOUsage(string $noBukti, ?int $urut = null)
{
    try {
        $query = DB::table('DbPODET')
            ->where('noPPL', $noBukti)
            ->select('NOBUKTI', 'KODEBRG', 'UrutPPL');

        if (! is_null($urut)) {
            $query->where('UrutPPL', $urut);
        }

        $result = $query->first();

        if ($result) {
            return [
                'exists' => true,
                'noBuktiPO' => $result->NOBUKTI,
                'kodeBrg' => $result->KODEBRG,
                'urutPPL' => $result->UrutPPL,
            ];
        }

        return ['exists' => false];
    } catch (Exception $e) {
        // Handle error gracefully
        return ['exists' => false];
    }
}
```

### 2. Updated `updateDetailLine()` Error Message
File: `app/Services/PPLService.php`, lines 279-313

**New Error Message:**
```php
'PR: '.$noBukti.' dan Item: '.$poCheck['kodeBrg'].
' sudah ada transaksi di PO: '.$poCheck['noBuktiPO'].
'. Tidak dapat mengubah baris ini.'
```

**Result:**
```
PR: PR/0001/12/2025 dan Item: 1142.3.1.014 sudah ada transaksi di PO: PO/0042/12/2025. Tidak dapat mengubah baris ini.
```

### 3. Updated `deleteDetailLine()` Error Message
File: `app/Services/PPLService.php`, lines 344-376

**New Error Message:**
```php
'PR: '.$noBukti.' dan Item: '.$poCheck['kodeBrg'].
' sudah ada transaksi di PO: '.$poCheck['noBuktiPO'].
'. Tidak dapat menghapus baris ini.'
```

**Result:**
```
PR: PR/0001/12/2025 dan Item: 1142.3.1.014 sudah ada transaksi di PO: PO/0042/12/2025. Tidak dapat menghapus baris ini.
```

### 4. Updated `cancelDocument()` Method
File: `app/Services/PPLService.php`, lines 522-558

**Change:**
```php
// Before
$usedInPO = $this->checkPOUsage($noBukti);
if ($usedInPO) {

// After
$poCheck = $this->checkPOUsage($noBukti);
if ($poCheck['exists']) {
```

## Database Schema Reference

### DBPODET Table Structure
```
Column Name    | Type       | Description
--------------|------------|----------------------------------
NOBUKTI        | VARCHAR(20)| PO Number (Primary Key)
URUT           | INT        | Line sequence (Primary Key)
KODEBRG        | VARCHAR(20)| Item code
NoPPL          | VARCHAR(20)| PR Number (Foreign Key)
UrutPPL        | INT        | PR Line number
IsClose        | BIT        | Close status
Isbatal        | BIT        | Cancel status
...            | ...        | Other columns
```

### How It Works
1. When user tries to **edit** a PR detail → Check if `DBPODET.noPPL = PR Number AND UrutPPL = Line Number`
2. When user tries to **delete** a PR detail → Check if `DBPODET.noPPL = PR Number AND UrutPPL = Line Number`
3. When user tries to **cancel** entire PR → Check if any `DBPODET.noPPL = PR Number` exists

If found, system shows:
- PR number that's locked
- Item code that's in the PO
- PO number that references it

## Delphi Source Reference

**File:** `pwt/FrmPPL.pas`

**KoreksiBtnClick (Correction):** Lines 20-23
```delphi
Select KodeBrg,nobukti from dbPODet a
where KodeBrg=:0 and NoPPL=:1 and UrutPPL= :2
```

**HapusBtnClick (Delete):** Lines 81
```delphi
Select KodeBrg,nobukti from dbPODet a
where KodeBrg=:0 and NoPPL=:1 and UrutPPL= :2
```

## Testing Scenarios

### Scenario 1: Edit PR Detail Already in PO
```
PR: PR/0001/12/2025
Detail: Item 1142.3.1.014 (urut=1)
PO: PO/0042/12/2025 references this PR detail

User Action: Click "Edit" on the detail
Expected Result: Error message shows:
  "PR: PR/0001/12/2025 dan Item: 1142.3.1.014 sudah ada transaksi di PO: PO/0042/12/2025. Tidak dapat mengubah baris ini."
```

### Scenario 2: Delete PR Detail Already in PO
```
Same setup as Scenario 1

User Action: Click "Delete" on the detail
Expected Result: Error message shows:
  "PR: PR/0001/12/2025 dan Item: 1142.3.1.014 sudah ada transaksi di PO: PO/0042/12/2025. Tidak dapat menghapus baris ini."
```

### Scenario 3: Cancel PR Already in PO
```
PR: PR/0001/12/2025 with multiple detail lines
At least one detail is in a PO

User Action: Try to cancel PR
Expected Result: Error message shows:
  "Nomor PR PR/0001/12/2025 Sudah Terdaftar Dalam PO dan tidak dapat dibatalkan."
```

## Files Modified

| File | Changes | Lines |
|------|---------|-------|
| `app/Services/PPLService.php` | Enhanced checkPOUsage(), updated updateDetailLine(), deleteDetailLine(), cancelDocument() | 399-439, 279-313, 344-376, 522-558 |

## Validation Flow

```
User Action (Edit/Delete/Cancel PR Detail)
    ↓
Controller calls Service method
    ↓
Service calls checkPOUsage($noBukti, $urut)
    ↓
Query DBPODET table for matching record
    ↓
┌─ Found: Return ['exists' => true, 'noBuktiPO' => ..., 'kodeBrg' => ...]
│  → Throw Exception with detailed message
│  → User sees: "PR: XXX dan Item: YYY sudah ada transaksi di PO: ZZZ"
│
└─ Not Found: Return ['exists' => false]
   → Proceed with update/delete operation
   → Operation succeeds
```

## Code Quality

- ✅ Syntax verified with `php -l`
- ✅ Code formatted with Laravel Pint
- ✅ Application boots successfully
- ✅ Error messages match Delphi format
- ✅ Comments reference Delphi source lines
- ✅ Exception handling prevents crashes

## Backward Compatibility

- Service still checks PO usage (existing behavior)
- Error message improved (user-facing enhancement)
- Return value is now array instead of boolean
- All call sites updated to use `['exists']` key

## Related Issues

- **Issue**: DbPODET validation was implemented but didn't show PO number in error
- **Root Cause**: checkPOUsage() only returned boolean, lost PO details
- **Fix**: Return full array with PO details for informative error messages
- **Impact**: Users now see exactly which PO is preventing modification/deletion
