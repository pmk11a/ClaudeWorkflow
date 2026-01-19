# Memorial Migration - Gap Analysis

**Date**: 2026-01-17
**Existing Code Review**: MemorialService.php (654 lines), MemorialController.php (371 lines)
**Spec Reference**: MEMORIAL_SPEC.md

## Summary

**Status**: 🟡 **SUBSTANTIAL CODE EXISTS** - Enhancement needed, not full rewrite
**Estimated Work**: 8-12 hours (vs 19 hours from scratch)

---

## 1. Validations (7 Required)

### ✅ VAL1: Required Fields - **IMPLEMENTED**
**Location**: `MemorialService::validateTransactionData()` line 423-463
```php
if (empty($data['no_bukti'])) throw new Exception('No. Bukti wajib diisi');
if (empty($data['tanggal'])) throw new Exception('Tanggal wajib diisi');
if (empty($data['details'])) throw new Exception('Details wajib diisi');
// Validates each detail has perkiraan, lawan
```
**Status**: ✅ Complete

---

### ❌ VAL2: HutPiut Balance Validation - **MISSING**
**Spec Requirement**: When mode is HT/PT, validate sum of selected invoices equals transaction amount (round to 2 decimals)
**Delphi Reference**: `FrmMemorial.pas` lines 2248-2256
```delphi
if RoundTo(xJumlahHutPiut,-2)<>RoundTo(Jumlah.Value,-2) then
  MessageDlg('Jumlah Kartu Hutang / Piutang tidak sama...')
```
**Current Status**: ❌ Not found in MemorialService
**Related Service**: HutangPiutangMemorialService exists but not called from MemorialService
**Action Required**: Add validation method in MemorialService that:
1. Checks if THPC mode includes 'H' or 'P'
2. Calls HutangPiutangMemorialService to get selected invoice total
3. Compares with transaction amount (rounded to 2 decimals)

---

### ✅ VAL3: Period Lock Check - **IMPLEMENTED**
**Location**: `MemorialService::isPeriodUnlocked()` line 472-482
```php
protected function isPeriodUnlocked(int $month, int $year): bool
{
    $isLocked = DB::table('DBLOCKPERIODE')
        ->where('BULAN', $month)
        ->where('TAHUN', $year)
        ->exists();
    return !$isLocked;
}
```
**Called from**: `store()` line 41, `update()` line 129
**Status**: ✅ Complete

---

### ⚠️ VAL4: Perkiraan vs Lawan (No same account) - **PARTIAL**
**Spec Requirement**: Perkiraan and Lawan must not be the same account
**Current Status**: ⚠️ Validated in Request (Controller validation) but not in Service
**Location**: `MemorialService::validateTransactionData()` line 445-456 validates they exist in dbPerkiraan
**Missing**: Check `$detail['perkiraan'] !== $detail['lawan']`
**Action Required**: Add in `validateTransactionData()`:
```php
foreach ($details as $detail) {
    if ($detail['perkiraan'] === $detail['lawan']) {
        throw new Exception('Perkiraan dan Lawan tidak boleh sama');
    }
}
```

---

### ❌ VAL5: Giro Clearing Check (on Delete) - **MISSING**
**Spec Requirement**: Before deleting transaction with Giro, check if check is already cleared
**Delphi Reference**: `FrmMemorial.pas` lines 2060-2071
```delphi
if DataBersyarat('...where buktibuka=:0 and TglCair is not null'...)
```
**Current Status**: ❌ Not found in `delete()` method
**Action Required**: Add in `delete()` method:
1. Check if transaction has related Giro records
2. Query dbGiro where buktibuka = NoBukti AND TglCair IS NOT NULL
3. If exists, throw Exception with bank, nogiro, and clearing details

---

### ✅ VAL6: Debit-Credit Balance (Master level) - **IMPLEMENTED**
**Location**: `MemorialService::isBalanced()` line 386-415
```php
protected function isBalanced(array $details): bool
{
    $currencies = array_unique(array_column($details, 'valas'));
    foreach ($currencies as $valas) {
        $totalDebet = array_sum(...);
        $totalKredit = array_sum(...);
        if (abs($totalDebet - $totalKredit) > 0.01) return false;
    }
    return true;
}
```
**Called from**: `store()` line 46, `update()` line 134
**Status**: ✅ Complete - Multi-currency support included

---

### ⚠️ VAL7: Multi-Currency Consistency - **PARTIAL**
**Spec Requirement**: Each line must have proper exchange rate, IDR should have Kurs=1
**Current Status**: ⚠️ Defaults to 'IDR' and Kurs=1, but doesn't enforce IDR=1 or validate non-IDR has Kurs>0
**Location**: `store()` line 72-73, `update()` line 158-159
```php
'Valas' => $detail['valas'] ?? 'IDR',
'Kurs' => $detail['kurs'] ?? 1,
```
**Action Required**: Add in `validateTransactionData()`:
```php
if ($detail['valas'] === 'IDR' && $detail['kurs'] != 1) {
    throw new Exception('Kurs untuk IDR harus 1');
}
if ($detail['valas'] !== 'IDR' && $detail['kurs'] <= 0) {
    throw new Exception('Kurs untuk valas non-IDR harus > 0');
}
```

---

## 2. Business Logic (7 Required)

### ❌ BL1: Stored Procedure Integration - **NOT IMPLEMENTED**
**Spec Requirement**: Call stored procedure `Sp_Transaksi` for INSERT/UPDATE/DELETE operations
**Delphi Reference**: `FrmMemorial.pas` SimpanData procedure (lines 1409-1459)
```delphi
with Sp_Transaksi do begin
  Parameters[1].Value := Choice;  // I/U/D
  ExecProc;
end
```
**Current Status**: ❌ Uses Eloquent ORM directly, NOT stored procedure
**Current Implementation**: `store()` uses `MemorialDetail::create()` and `$master->details()->create()`
**Critical Decision Needed**:
- **Option A**: Keep Eloquent (simpler, testable, maintainable)
- **Option B**: Call stored procedure (preserve Delphi logic 100%)

**If Option B**, need to:
1. Create `callStoredProcedure()` method
2. Pass 34 parameters as per Delphi
3. Replace Eloquent calls in store/update/delete

**Recommendation**: Option A (keep Eloquent) because:
- Stored procedures are legacy
- Laravel best practice is Eloquent
- Easier to test and maintain
- Business logic is already replicated

---

### ✅ BL2: Automatic NoUrut Assignment - **IMPLEMENTED**
**Location**: `store()` line 62-65, `update()` line 148-151
```php
foreach ($data['details'] as $index => $detail) {
    $master->details()->create([
        'Urut' => $index + 1,  // Auto-increment
```
**Status**: ✅ Complete

---

### ❌ BL3: Aktiva Integration - **MISSING**
**Spec Requirement**: When Perkiraan or Lawan is fixed asset account, save to dbAktiva/dbAktivadet
**Delphi Reference**: `FrmMemorial.pas` procedures: SimpanDataAktiva (line 1457), TampilDataAktiva
**Current Status**: ❌ No integration with Aktiva model in MemorialService
**Action Required**: Add method `handleAktivaIntegration()` that:
1. Detects if Perkiraan/Lawan starts with fixed asset account prefix (e.g., '1301')
2. Creates/updates Aktiva and AktivaDetail records
3. Links via NoBukti

---

### ❌ BL4: Giro Integration - **MISSING**
**Spec Requirement**: When THPC mode includes 'H' or 'P' with check, save to dbGiro
**Delphi Reference**: `FrmMemorial.pas` procedures: SimpanDataGiro (line 1459)
**Current Status**: ❌ No integration with Giro model in MemorialService
**Action Required**: Add method `handleGiroIntegration()` that:
1. Checks if THPC = 'H' or 'P'
2. Creates Giro records with Bank, NoGiro, TglGiro, BuktiBuka
3. Tracks check status

---

### ✅ BL5: HutPiut Temporary Matching - **IMPLEMENTED (Separate Service)**
**Location**: `HutangPiutangMemorialService.php` (separate service)
**Methods**:
- `tampilDataHutPiut()` - Load open invoices
- `hitungSaldo()` - Calculate balances
- `simpanData()` - Save matched invoices
**Status**: ✅ Service exists but NOT INTEGRATED with MemorialService
**Action Required**: Integrate HutangPiutangMemorialService into MemorialService:
1. Call in `store()` when mode includes HT/PT
2. Validate invoice matching (VAL2)
3. Clear temp data after successful save

---

### ⚠️ BL6: Currency Exchange Rate Lookup - **PARTIAL**
**Spec Requirement**: Fetch exchange rate from dbValasdet based on currency and date
**Delphi Reference**: `FrmMemorial.pas` KursValas function (lines 1356-1369)
```delphi
select isnull(max(kurs),1) as kurs from dbValasdet
where kodevls=:0 and awal<=:1 and akhir>=:2
```
**Current Status**: ⚠️ Defaults to 1, doesn't lookup from dbValasdet
**Location**: `store()` line 73 hardcodes `'Kurs' => $detail['kurs'] ?? 1`
**Action Required**: Add method `getExchangeRate($valas, $tanggal)` that:
1. Queries dbValasdet for rate
2. Filters by date range (awal <= tanggal <= akhir)
3. Returns max(kurs) or 1 if not found

---

### ✅ BL7: Authorization Calculation - **IMPLEMENTED**
**Location**: `store()` line 82-86
```php
$authOwner = Memorial::where('NoBukti', $master->NoBukti)->first();
if ($authOwner) {
    $this->otorisasiService->initialize($authOwner);
}
```
**Status**: ✅ Complete - Uses OtorisasiService

---

## 3. Permissions (5 Required)

### ⚠️ Permissions - **NEED POLICY**
**Spec Requirements**:
- IsTambah → create permission
- IsKoreksi → update permission
- IsHapus → delete permission
- IsCetak → print permission
- IsExcel → export permission

**Current Status**: ⚠️ Controller uses auth middleware but NO POLICY
**Location**: `MemorialController::__construct()` line 26 has `middleware('auth:trade2exchange')`
**Missing**: `MemorialPolicy.php` with methods:
- `create(User $user)` → check IsTambah
- `update(User $user, Memorial $memorial)` → check IsKoreksi
- `delete(User $user, Memorial $memorial)` → check IsHapus
- `print(User $user)` → check IsCetak
- `export(User $user)` → check IsExcel

**Action Required**: Create `app/Policies/MemorialPolicy.php` and register in AuthServiceProvider

---

## 4. Request Classes

### ❌ Request Classes - **MISSING**
**Spec Requirements**:
- StoreMemorialRequest.php
- UpdateMemorialRequest.php
- DeleteMemorialRequest.php

**Current Status**: ❌ Controller uses generic `Request`, no FormRequest
**Location**: `MemorialController::store(Request $request)` line 59
**Action Required**: Create 3 FormRequest classes with validation rules

---

## 5. Tests

### ❌ Tests - **MISSING**
**Spec Requirements**:
- Unit tests for MemorialService
- Feature tests for MemorialController
- Integration tests for Aktiva/Giro/HutPiut

**Current Status**: ❌ No tests found for Memorial module
**Action Required**: Create:
1. `tests/Unit/Services/MemorialServiceTest.php`
2. `tests/Feature/MemorialControllerTest.php`
3. Test all 7 validations
4. Test permissions

---

## 6. Views

### ⚠️ Views - **PARTIAL** (assuming they exist)
**Current Status**: Not checked yet (focus on backend first)
**Action Required**: Verify and enhance if needed

---

## Priority Action Plan

### 🔴 **CRITICAL (P0)** - Must implement before deployment

1. ✅ **VAL3: Period Lock** - Already implemented
2. ✅ **VAL6: Debit-Credit Balance** - Already implemented
3. ❌ **VAL5: Giro Clearing Check** - Add to delete() method (30 min)
4. ❌ **Create MemorialPolicy** - Implement 5 permission methods (45 min)
5. ❌ **Create Request Classes** - 3 FormRequests with validation (1 hour)

### 🟡 **HIGH (P1)** - Business logic requirements

6. ❌ **VAL2: HutPiut Balance Validation** - Integrate HutangPiutangMemorialService (1 hour)
7. ⚠️ **VAL4: Perkiraan vs Lawan** - Add validation (15 min)
8. ⚠️ **VAL7: Multi-Currency Consistency** - Enhance validation (30 min)
9. ⚠️ **BL6: Exchange Rate Lookup** - Add dbValasdet query (45 min)
10. ❌ **BL5: HutPiut Integration** - Call from MemorialService (1.5 hours)

### 🟢 **MEDIUM (P2)** - Extended features

11. ❌ **BL3: Aktiva Integration** - Implement handleAktivaIntegration() (2 hours)
12. ❌ **BL4: Giro Integration** - Implement handleGiroIntegration() (2 hours)
13. ❌ **Tests** - Unit + Feature + Integration (4 hours)

### ⚪ **LOW (P3)** - Optional/architectural

14. ❌ **BL1: Stored Procedure** - Decision needed (keep Eloquent or switch to SP?)

---

## Estimated Time by Priority

| Priority | Items | Time |
|----------|-------|------|
| P0 (Critical) | 5 items | ~3.5 hours |
| P1 (High) | 5 items | ~5 hours |
| P2 (Medium) | 3 items | ~8 hours |
| **TOTAL** | **13 items** | **16.5 hours** |

**Original estimate from scratch**: 19 hours
**Current estimate with existing code**: 16.5 hours (13% savings)
**Critical items only**: 3.5 hours (get to functional state)

---

## Recommendation

### Phase 1: Make It Work (P0) - 3.5 hours
Implement critical items to get basic CRUD working with permissions and key validations.

### Phase 2: Complete Business Logic (P1) - 5 hours
Add HutPiut integration, currency validation, exchange rate lookup.

### Phase 3: Extended Features (P2) - 8 hours
Add Aktiva/Giro integration and comprehensive tests.

### Decision Point: Stored Procedures (P3)
**Recommend**: Keep Eloquent (current approach)
**Rationale**:
- Business logic already replicated
- More maintainable and testable
- Standard Laravel practice
- Migration goal is functionality, not line-by-line port

---

**Next Action**: Start with Phase 1 (P0 items) to get Memorial module to production-ready state in 3.5 hours.
