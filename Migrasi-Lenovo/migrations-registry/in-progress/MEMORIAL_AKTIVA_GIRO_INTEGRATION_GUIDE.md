# Memorial - Aktiva & Giro Integration Guide

**Date**: 2026-01-17
**Status**: 📋 **DOCUMENTED - IMPLEMENTATION PENDING**
**Complexity**: HIGH
**Estimated Effort**: 6-8 hours (implementation + testing)

---

## Overview

This document describes the integration between Memorial (Journal Entry) module and two related subsystems:
1. **Aktiva (Fixed Assets)** - BL3
2. **Giro (Checks/Bank Drafts)** - BL4

Both integrations follow a similar pattern where data is collected in temporary storage during Memorial entry, then saved to permanent tables when the Memorial transaction is committed.

---

## 🏗️ Architecture Pattern

### Delphi Pattern (Reference)
```
User fills Memorial form
  ↓
User clicks Aktiva/Giro button
  ↓
Aktiva/Giro dialog opens
  ↓
User enters Aktiva/Giro details
  ↓
Data saved to in-memory dataset (dxAktiva/dxGiro)
  ↓
User closes dialog
  ↓
User saves Memorial
  ↓
Memorial saved + Aktiva/Giro records created in database
```

### Laravel Pattern (Proposed)
```
User fills Memorial form
  ↓
User enters Aktiva/Giro details (inline or modal)
  ↓
Data stored in session OR sent with Memorial request
  ↓
MemorialService::store() called
  ↓
Memorial transaction created
  ↓
IF Perkiraan is Aktiva account → handleAktivaIntegration()
IF THPC includes H/P → handleGiroIntegration()
  ↓
Aktiva/Giro records created
  ↓
Transaction committed
```

---

## 📋 BL3: Aktiva Integration

### Business Logic (from FrmMemorialAktiva.pas)

**When**: Aktiva record should be created when:
- Memorial detail line has Perkiraan that is a fixed asset account
- User explicitly adds Aktiva details via Aktiva button/form

**Data Flow**:
1. User selects Perkiraan (e.g., `1301.001` - Fixed Assets)
2. System detects this is an Aktiva account (via dbposthutpiut where Kode='AKV')
3. User enters Aktiva details:
   - KodeAktiva (auto-generated: Perkiraan + NoBelakang + NoBelakang2)
   - Keterangan (description)
   - Quantity (number of units)
   - Persen (depreciation percentage)
   - TglPengakuan (recognition date)
   - Tipe/Metode (L=Linear, M=Menurun, P=Production)
   - Akumulasi (accumulated depreciation account)
   - Biaya (expense account 1)
   - Biaya2, Biaya3 (expense accounts 2, 3)
   - PersenBiaya1, PersenBiaya2, PersenBiaya3 (allocation percentages)
   - TipeAktiva (0=Tetap/Fixed, 1=Dibiayakan/Expensed)
   - Kodebag (department code)
   - Devisi (division code)
   - isHeader (0=regular, 1+=sub-header level)
4. Data saved to **TempDBAKTIVA** table for user session
5. When Memorial saved, data read from TempDBAKTIVA and inserted into **dbAKTIVA** table

### Database Tables

**TempDBAKTIVA** (temporary storage):
- Devisi
- Perkiraan (full code with NoBelakang)
- Keterangan
- Quantity
- Persen
- Tanggal
- Tipe (L/M/P)
- Akumulasi
- Biaya, Biaya2, Biaya3
- PersenBiaya1, PersenBiaya2, PersenBiaya3
- NoMuka (parent aktiva code)
- NoBelakang, NoBelakang2 (sequence numbers)
- TipeAktiva
- Kodebag
- Kelompok (header level)
- NoAktivaHd (parent header code)

**dbAKTIVA** (permanent storage):
- Same fields as TempDBAKTIVA
- Additional: Status, XSusut, PerlakuanAktiva

**dbAKTIVADET** (depreciation details):
- Created automatically by stored procedure
- Tracks monthly depreciation

### Delphi References

**File**: `D:\migrasi\pwt\Trasaksi\Memorial\FrmMemorialAktiva.pas`

**Key Methods**:
- `BitBtn1Click` (Save button) - lines 172-229
  - Saves to `FrMemorial.dxAktiva` dataset
  - Auto-generates KodeAktiva
  - Validates no duplicates
- `DevisiExit` - lines 260-274
  - Auto-generates NoBelakang (sequence number)
  - Format: `Perkiraan.NoBelakang`
- `TampilisiHeader` - lines 104-140
  - Loads existing Aktiva for editing

**Integration Point in FrmMemorial.pas**:
- Line 1457: `SimpanDataAktiva` procedure
- Called after main Memorial save succeeds
- Loops through `dxAktiva` dataset
- Calls stored procedure `SP_AktivaTetap` for each record

### Laravel Implementation Plan

#### Models Already Exist ✅
- `App\Models\DbAKTIVA`
- `App\Models\DbAKTIVADET`
- `App\Models\TempDBAKTIVA`
- `App\Models\TempDBAKTIVADET`

#### Service Already Exists ✅
- `App\Services\AktivaService`
  - `createAktiva()` method exists
  - Uses stored procedure `SP_AktivaTetap`
  - Requires 25 parameters

#### What Needs to be Implemented ❌

**1. Account Detection** (30 minutes)
```php
// In MemorialService.php
protected function isAktivaAccount(string $perkiraan): bool
{
    // Query dbposthutpiut where Kode='AKV' and Perkiraan = $perkiraan
    return DB::table('dbposthutpiut')
        ->where('Perkiraan', $perkiraan)
        ->where('Kode', 'AKV')
        ->exists();
}
```

**2. Aktiva Data Handling** (1 hour)
```php
// In MemorialService::store()
protected function handleAktivaIntegration(string $noBukti, array $details, string $userId): void
{
    // 1. Check if any detail line has Aktiva account
    foreach ($details as $detail) {
        if ($this->isAktivaAccount($detail['perkiraan']) ||
            $this->isAktivaAccount($detail['lawan'])) {

            // 2. Load Aktiva data from TempDBAKTIVA for this user
            $tempAktiva = TempDBAKTIVA::where('IDUser', $userId)
                ->where('NoBukti', $noBukti)
                ->get();

            // 3. For each temp record, create actual Aktiva
            foreach ($tempAktiva as $temp) {
                $this->aktivaService->createAktiva([
                    'Devisi' => $temp->Devisi,
                    'Perkiraan' => $temp->Perkiraan,
                    'Keterangan' => $temp->Keterangan,
                    'Quantity' => $temp->Quantity,
                    'Persen' => $temp->Persen,
                    'Tanggal' => $temp->Tanggal,
                    'Tipe' => $temp->Tipe,
                    'Akumulasi' => $temp->Akumulasi,
                    'Biaya' => $temp->Biaya,
                    'Biaya2' => $temp->Biaya2,
                    'PersenBiaya1' => $temp->PersenBiaya1,
                    'PersenBiaya2' => $temp->PersenBiaya2,
                    // ... all other fields
                ]);
            }

            // 4. Clear temp data
            TempDBAKTIVA::where('IDUser', $userId)
                ->where('NoBukti', $noBukti)
                ->delete();
        }
    }
}
```

**3. Controller/Request Updates** (30 minutes)
- Add `aktiva_data` field to StoreMemorialRequest
- Validation for Aktiva fields if provided
- Pass to service

**4. UI Integration** (2 hours - frontend)
- Aktiva entry modal/form
- Save to TempDBAKTIVA before Memorial save
- Display Aktiva list in Memorial form
- Edit/delete temp Aktiva records

**Total Backend Effort**: ~2 hours
**Total Frontend Effort**: ~2 hours

---

## 📋 BL4: Giro Integration

### Business Logic (from FrmMemorialGiro.pas)

**When**: Giro record should be created when:
- THPC mode includes 'H' (Hutang/Payable) or 'P' (Piutang/Receivable)
- User explicitly adds check/giro details

**Data Flow**:
1. User sets THPC mode (e.g., 'HP' = both Hutang and Piutang)
2. User clicks Giro button
3. Giro dialog opens
4. User enters Giro details:
   - Bank (bank code)
   - NoGiro (check number)
   - TglGiro (check date)
   - KodeVls (currency)
   - Kurs (exchange rate)
   - Nilai/Jumlah (amount)
   - Keterangan (description)
5. Data saved to in-memory `dxGiro` dataset
6. When Memorial saved, Giro records created in **dbGiro** table

### Giro Types

**THPC Modes**:
- `'T'` = Transfer (no giro)
- `'H'` = Hutang (Payable - creates HT type giro)
- `'P'` = Piutang (Receivable - creates PT type giro)
- `'C'` = Cash (no giro)

**Combined**: `'HP'`, `'TH'`, `'TP'`, etc.

### Database Tables

**dbGiro** (permanent storage):
- Bank
- NoGiro
- TglGiro
- KodeVls
- Kurs
- Tipe ('HT' = Hutang, 'PT' = Piutang)
- Debet (for Piutang/receivable)
- Kredit (for Hutang/payable)
- DebetD, KreditD (foreign currency amounts)
- Jumlah, JumlahRp (total amounts)
- BuktiBuka (Memorial NoBukti)
- UrutBuka (Memorial line Urut)
- TglCair (clearing date - nullable)
- BuktiCair (clearing transaction number)
- UrutBuktiCair (clearing transaction line)
- Keterangan

### Delphi References

**File**: `D:\migrasi\pwt\Trasaksi\Memorial\FrmMemorialGiro.pas`

**Key Methods**:
- `btnOKClick` (Save button) - lines 276-374
  - Validates NoGiro + Bank uniqueness
  - Saves to `FrMemorial.dxGiro` dataset
  - Sets Debet/Kredit based on THPC mode
- `btnHapusGiroClick` (Delete button) - lines 218-274
  - Checks if already cleared (`TglCair IS NOT NULL`)
  - Updates dbGiro to clear linkage if needed
- `TampildataGiro` - lines 119-136
  - Calculates total Giro amount
  - Stores in `FrMemorial.JumlahNilaiGiro`

**Integration Point in FrmMemorial.pas**:
- Line 1459: `SimpanDataGiro` procedure (not shown in snippet but referenced)
- Called after main Memorial save succeeds
- Loops through `dxGiro` dataset
- Inserts into dbGiro table

### Laravel Implementation Plan

#### Models Already Exist ✅
- `App\Models\Giro` (simplified)
- Need to check if it maps to dbGiro correctly

#### Service Already Exist ✅
- `App\Services\GiroService`
  - `register()` method exists
  - Simplified version using Eloquent

#### What Needs to be Implemented ❌

**1. THPC Mode Detection** (15 minutes)
```php
// In MemorialService.php
protected function needsGiroIntegration(string $thpc): bool
{
    return str_contains($thpc, 'H') || str_contains($thpc, 'P');
}
```

**2. Giro Data Handling** (1.5 hours)
```php
// In MemorialService::store()
protected function handleGiroIntegration(
    string $noBukti,
    string $thpc,
    array $giroData
): void {
    if (! $this->needsGiroIntegration($thpc)) {
        return;
    }

    // Determine giro type based on THPC
    $tipe = str_contains($thpc, 'H') ? 'HT' : 'PT';

    foreach ($giroData as $index => $giro) {
        // Create Giro record
        DB::table('dbGiro')->insert([
            'Bank' => $giro['bank'],
            'NoGiro' => $giro['no_giro'],
            'TglGiro' => $giro['tgl_giro'],
            'KodeVls' => $giro['valas'],
            'Kurs' => $giro['kurs'],
            'Tipe' => $tipe,
            'Debet' => ($tipe === 'PT') ? $giro['jumlah'] : 0,
            'Kredit' => ($tipe === 'HT') ? $giro['jumlah'] : 0,
            'DebetD' => ($tipe === 'PT' && $giro['valas'] !== 'IDR')
                ? $giro['jumlah'] : 0,
            'KreditD' => ($tipe === 'HT' && $giro['valas'] !== 'IDR')
                ? $giro['jumlah'] : 0,
            'Jumlah' => $giro['jumlah'],
            'JumlahRp' => $giro['jumlah'] * $giro['kurs'],
            'BuktiBuka' => $noBukti,
            'UrutBuka' => $index + 1,
            'TglCair' => null,
            'BuktiCair' => '',
            'UrutBuktiCair' => 0,
            'Keterangan' => $giro['keterangan'] ?? '',
        ]);
    }
}
```

**3. Giro Validation** (30 minutes)
```php
// Validate giro uniqueness
protected function validateGiroUniqueness(string $bank, string $noGiro, string $tglGiro, string $tipe): void
{
    $exists = DB::table('dbGiro')
        ->where('Bank', $bank)
        ->where('NoGiro', $noGiro)
        ->where('TglGiro', $tglGiro)
        ->where('Tipe', $tipe)
        ->exists();

    if ($exists) {
        throw new Exception(
            "No. Giro {$noGiro} dengan Bank {$bank} sudah ada"
        );
    }
}
```

**4. Update Delete Method** (30 minutes)
```php
// In MemorialService::delete()
// Add Giro unlinking logic
protected function clearGiroLinkage(string $noBukti): void
{
    // Update dbGiro to clear linkage (if not yet cleared)
    DB::table('dbGiro')
        ->where('BuktiBuka', $noBukti)
        ->whereNull('TglCair') // Only if not yet cleared
        ->update([
            'BuktiCair' => '',
            'UrutBuktiCair' => 0,
            // Don't clear TglCair if already set
        ]);
}
```

**5. UI Integration** (2 hours - frontend)
- Giro entry modal/form
- Display Giro list in Memorial form
- Edit/delete Giro records
- Show total Giro amount

**Total Backend Effort**: ~2.5 hours
**Total Frontend Effort**: ~2 hours

---

## 🚨 Critical Considerations

### 1. Transaction Integrity
Both Aktiva and Giro MUST be created within the same database transaction as Memorial:
```php
DB::transaction(function () use ($data) {
    // 1. Create Memorial
    $memorial = $this->createMemorialRecords($data);

    // 2. Create Aktiva (if applicable)
    $this->handleAktivaIntegration($data['no_bukti'], $data['details'], auth()->id());

    // 3. Create Giro (if applicable)
    if (isset($data['giro_data'])) {
        $this->handleGiroIntegration($data['no_bukti'], $data['thpc'], $data['giro_data']);
    }

    // If any step fails, entire transaction rolls back
});
```

### 2. Account Mapping
Need business user input to determine:
- **Aktiva accounts**: Which Perkiraan codes are fixed assets?
  - Currently detected via dbposthutpiut where Kode='AKV'
  - Need to verify this is correct and complete
- **Bank accounts**: Which Perkiraan codes are bank accounts for Giro?
  - May need similar mapping table

### 3. UI/UX Design
- How should users enter Aktiva/Giro data?
  - Inline in Memorial form?
  - Separate modals?
  - Step-by-step wizard?
- How to handle temp data storage?
  - Session storage?
  - Temporary database tables?
  - Include in Memorial request payload?

### 4. Stored Procedures
AktivaService uses `SP_AktivaTetap` stored procedure with 25 parameters. Need to verify:
- Stored procedure exists in target database
- Parameter mapping is correct
- Business logic is preserved

---

## 📝 Recommended Implementation Approach

### Phase 3A: Backend Foundation (2-3 hours)
1. ✅ Verify TempDBAKTIVA, dbGiro tables exist and are correctly mapped
2. ✅ Create account detection methods (isAktivaAccount, needsGiroIntegration)
3. ✅ Implement handleAktivaIntegration() method
4. ✅ Implement handleGiroIntegration() method
5. ✅ Update store() and delete() to call integration methods
6. ✅ Add transaction safety checks
7. ✅ Write unit tests

### Phase 3B: Frontend Integration (2-3 hours)
1. ⏸️ Design Aktiva entry form/modal
2. ⏸️ Design Giro entry form/modal
3. ⏸️ Implement temp data storage (session or TempDB tables)
4. ⏸️ Add Aktiva/Giro display in Memorial form
5. ⏸️ Implement edit/delete for temp records
6. ⏸️ Add validation and error handling

### Phase 3C: Testing & Validation (2 hours)
1. ⏸️ Test Aktiva creation with various scenarios
2. ⏸️ Test Giro creation with different THPC modes
3. ⏸️ Test transaction rollback scenarios
4. ⏸️ Verify data integrity in dbAKTIVA, dbGiro
5. ⏸️ User acceptance testing with accounting team

**Total Estimated Effort**: 6-8 hours

---

## ⚠️ Known Risks

1. **Stored Procedure Dependency**: AktivaService relies on `SP_AktivaTetap` - if procedure has bugs or doesn't exist, integration will fail
2. **Account Mapping**: If dbposthutpiut mapping is incomplete, some Aktiva accounts may be missed
3. **THPC Mode Complexity**: Multiple mode combinations (TH, TP, HP, etc.) need thorough testing
4. **Data Migration**: Existing Aktiva/Giro data may need migration to new schema
5. **User Training**: Users need to understand new workflow compared to Delphi

---

## 🎯 Success Criteria

### Aktiva Integration ✅
- [ ] Memorial with Aktiva account creates dbAKTIVA record
- [ ] Aktiva auto-numbering works (NoBelakang generation)
- [ ] Depreciation setup correctly configured
- [ ] Multiple Aktiva per Memorial supported
- [ ] Aktiva edit/delete through Memorial works

### Giro Integration ✅
- [ ] Memorial with THPC='H' creates HT type Giro
- [ ] Memorial with THPC='P' creates PT type Giro
- [ ] Giro uniqueness validation works
- [ ] Giro clearing status prevents deletion
- [ ] Multiple Giro per Memorial supported
- [ ] Total Giro amount calculated correctly

### Data Integrity ✅
- [ ] All operations atomic (transaction-based)
- [ ] No orphan Aktiva/Giro records
- [ ] Memorial deletion clears Giro linkage
- [ ] No data corruption under concurrent access

---

## 📞 Next Steps

### Immediate
1. **Business User Review**: Get accounting team to review this document
2. **Account Mapping Verification**: Confirm dbposthutpiut Kode='AKV' is complete
3. **Stored Procedure Check**: Verify SP_AktivaTetap exists and works
4. **UI/UX Design**: Decide on Aktiva/Giro entry workflow

### Before Implementation
1. **Create Test Data**: Prepare sample Aktiva and Giro scenarios
2. **Backup Database**: Ensure rollback capability
3. **Write Tests First**: TDD approach for complex logic
4. **Code Review**: Get Laravel expert review before merging

### After Implementation
1. **User Training**: Train accounting team on new workflow
2. **Monitor Production**: Watch for errors in first week
3. **Gather Feedback**: Collect user experience feedback
4. **Optimize**: Tune performance based on real usage

---

**Document Created**: 2026-01-17
**Status**: Ready for Review
**Estimated Implementation**: 6-8 hours (backend + frontend)
**Recommended Priority**: Medium (after Phase 1 & 2 tested in production)
