# Migration Specification: MEMORIAL

**Created**: Sat, Jan 17, 2026  3:44:57 AM
**Updated**: Sat, Jan 17, 2026  4:00:00 AM
**Status**: Ready for Implementation
**Complexity**: COMPLEX
**Module Code**: 03017 (Memorial/Journal Entry)

## 1. Problem Statement

Migrate the Memorial (Journal Entry) module from Delphi to Laravel. This is a COMPLEX module that handles general journal entries with support for:
- Master-Detail transactions (dbTransaksi + dbTrans)
- Related modules: Fixed Assets (Aktiva), Checks (Giro), Accounts Payable/Receivable (HutPiut)
- Multi-currency support with exchange rates
- Transaction modes (THPC): Hutang, Piutang, Cash, Transfer
- Temporary HutPiut management for invoice matching

**Delphi Forms**:
1. **FrmMainMemorial** - List/Grid view with filter and export
2. **FrmMemorial** - Main transaction form (CRUD operations)
3. **FrmMemorialAktiva** - Fixed assets handling
4. **FrmMemorialGiro** - Check/Giro management
5. **FrmMemorialHutPiut** - Accounts Payable/Receivable matching

## 2. Delphi Source Files

### Main Form (List View)
- .pas file: `d:\migrasi\pwt\Trasaksi\Memorial\FrmMainMemorial.pas`
- .dfm file: `d:\migrasi\pwt\Trasaksi\Memorial\FrmMainMemorial.dfm`

### Transaction Form
- .pas file: `d:\migrasi\pwt\Trasaksi\Memorial\FrmMemorial.pas`
- .dfm file: `d:\migrasi\pwt\Trasaksi\Memorial\FrmMemorial.dfm`

### Related Forms
- Aktiva: `FrmMemorialAktiva.pas/.dfm`
- Giro: `FrmMemorialGiro.pas/.dfm`
- HutPiut: `FrmMemorialHutPiut.pas/.dfm`

## 3. Requirements

### Functional Requirements

#### FR1: Master-Detail Transaction Management
- [ ] Create journal entry with master (dbTransaksi) + multiple detail lines (dbTrans)
- [ ] Each detail line has: Perkiraan (Debit account), Lawan (Credit account), Amount, Currency, Exchange rate
- [ ] Validate debit = credit balance
- [ ] Support multi-currency (IDR, USD, EUR, GBP, JPY)

#### FR2: Related Entity Management
- [ ] **Aktiva (Fixed Assets)**: Link transactions to assets for depreciation tracking
- [ ] **Giro (Checks)**: Manage check issuance and clearing
- [ ] **HutPiut (AP/AR)**: Match payments to invoices, track open balances

#### FR3: Transaction Modes (THPC)
- [ ] T = Transfer
- [ ] H = Hutang (Payable)
- [ ] P = Piutang (Receivable)
- [ ] C = Cash
- [ ] Each mode triggers different validation and related entity handling

#### FR4: Temporary HutPiut Management
- [ ] Store temporary invoice list in dbTempHutPiut per user session
- [ ] Allow user to select which invoices to pay
- [ ] Validate total payment matches selected invoices
- [ ] Clear temp data after successful save

#### FR5: Period Locking
- [ ] Check if accounting period is locked before any CUD operation
- [ ] Validate transaction date is within allowed period

#### FR6: Authorization/Otorisasi
- [ ] Support multi-level authorization (max 5 levels)
- [ ] Track authorization status per level
- [ ] Store authorized user and timestamp

### Mode Operations (Choice:Char)
Delphi `SimpanData(Choice: String)` procedure:
- [ ] Choice='I' (Insert) → TambahBtnClick → store()
- [ ] Choice='U' (Update) → KoreksiBtnClick → update()
- [ ] Choice='D' (Delete) → HapusBtnClick → destroy()

### Permissions (From FrmMainMemorial)
Source: `FrmMainMemorial.pas` lines 241-242, 377, 402, 464, 1714-1716
- [ ] **IsTambah** - create permission (checked in TambahBtnClick)
- [ ] **IsKoreksi** - update permission (checked in KoreksiBtnClick)
- [ ] **IsHapus** - delete permission (checked in HapusBtnClick)
- [ ] **IsCetak** - print permission
- [ ] **IsExcel** - export to Excel permission
- [ ] **MemorialOL** - Authorization Level from dbMenu.OL

### Validations to Migrate

#### VAL1: Required Fields
Source: `FrmMemorial.pas` BitBtn1Click (line 2243)
```delphi
if (Jumlah.Value<>0) and (Kurs.Value<>0) then
```
- [ ] Amount (Jumlah) must not be zero
- [ ] Exchange rate (Kurs) must not be zero
- [ ] Date (Tanggal) is required
- [ ] Perkiraan (debit account) is required
- [ ] Lawan (credit account) is required

#### VAL2: HutPiut Balance Validation
Source: `FrmMemorial.pas` lines 2248-2256
```delphi
if RoundTo(xJumlahHutPiut,-2)<>RoundTo(Jumlah.Value,-2) then
  MessageDlg('Jumlah Kartu Hutang / Piutang tidak sama...')
```
- [ ] When mode is HT (Hutang) or PT (Piutang), validate sum of selected invoices equals transaction amount
- [ ] Use rounding to 2 decimal places

#### VAL3: Period Lock Check
Source: `FrmMemorial.pas` line 2239-2241
```delphi
if CekPeriode(IdUser,TANGGAL.Date)=true then
  if IsLockPeriode(StrToInt(PeriodBln),StrToInt(PeriodThn)) then
```
- [ ] Check if user has access to transaction date period
- [ ] Check if accounting period is locked

#### VAL4: Perkiraan vs Lawan (No same account)
- [ ] Perkiraan and Lawan must not be the same account
- [ ] Both must be valid accounts from dbPerkiraan with tipe=1

#### VAL5: Giro Clearing Check (on Delete)
Source: `FrmMemorial.pas` lines 2060-2071
```delphi
if DataBersyarat('...where buktibuka=:0 and TglCair is not null'...)
```
- [ ] Before deleting transaction with Giro, check if check is already cleared
- [ ] If cleared, prevent deletion with error message showing bank, check number, and clearing details

#### VAL6: Debit-Credit Balance (Master level)
- [ ] Sum of all detail debits must equal sum of all detail credits
- [ ] Validate before saving master transaction

#### VAL7: Multi-Currency Consistency
- [ ] All detail lines in same transaction can have different currencies
- [ ] Each line must have proper exchange rate (Kurs)
- [ ] IDR should have Kurs=1 and Kurs field disabled

### Business Logic to Preserve

#### BL1: Stored Procedure Integration
Source: `FrmMemorial.pas` SimpanData procedure (lines 1409-1459)
```delphi
with Sp_Transaksi do
begin
  Parameters[1].Value := Choice;  // I/U/D
  ...
  ExecProc;
end
```
- [ ] Call stored procedure `Sp_Transaksi` for INSERT/UPDATE/DELETE operations
- [ ] Pass 34 parameters including Choice, NoBukti, Tanggal, amounts, etc.

#### BL2: Automatic NoUrut Assignment
Source: `FrmMemorial.pas` TambahBtnClick (lines 1806-1817)
```delphi
select top 1 Urut from dbTransaksi where NoBukti=:0 order by Urut desc
mUrut := FieldByName('Urut').AsInteger+1
```
- [ ] When adding new detail line, auto-increment Urut (sequence number) per NoBukti

#### BL3: Aktiva Integration
Source: `FrmMemorial.pas` procedures: AmbilDataAktiva, SimpanDataAktiva, TampilDataAktiva
- [ ] When Perkiraan or Lawan is fixed asset account, prompt for asset details
- [ ] Save asset transaction to dbAktiva/dbAktivadet
- [ ] Track depreciation parameters (Susut, Persen, TipeAktiva, etc.)

#### BL4: Giro Integration
Source: `FrmMemorial.pas` procedures: TampilDataGiro, SimpanDataGiro
- [ ] When THPC mode includes 'H' or 'P' with check, open Giro form
- [ ] Save check details to dbGiro (Bank, NoGiro, TglGiro, etc.)
- [ ] Track check status: BuktiBuka, BuktiCair, TglCair

#### BL5: HutPiut Temporary Matching
Source: `FrmMemorial.pas` procedures: IsiTempHutPiut, HapusTempHutPiut (lines 428-517)
```delphi
insert into dbTempHutPiut (...) select ... from vwHutPiut
where KodeCustSupp=:0 and Perkiraan=:1
having sum(Kredit-Debet)>0  // for Hutang
```
- [ ] Load open invoices to temp table filtered by KodeCustSupp and Perkiraan
- [ ] Filter by balance direction (Debit>Credit or Credit>Debit) based on mode
- [ ] IDUser as session identifier
- [ ] TipeDK to distinguish Debit vs Kredit side

#### BL6: Currency Exchange Rate Lookup
Source: `FrmMemorial.pas` KursValas function (lines 1356-1369)
```delphi
select isnull(max(kurs),1) as kurs from dbValasdet
where kodevls=:0 and awal<=:1 and akhir>=:2
```
- [ ] Fetch exchange rate from dbValasdet based on currency code and date range
- [ ] Default to 1 if not found

#### BL7: Authorization Calculation
- [ ] Calculate max_authorization_level based on transaction amount thresholds
- [ ] Set need_otorisasi flag if authorization required

## 4. Acceptance Criteria

- [ ] All mode operations working (Insert, Update, Delete)
- [ ] All permissions enforced (IsTambah, IsKoreksi, IsHapus, IsCetak)
- [ ] All 7 validations migrated and working
- [ ] Stored procedure integration working
- [ ] Aktiva integration functional
- [ ] Giro integration functional
- [ ] HutPiut temporary matching working
- [ ] Multi-currency support working
- [ ] Period locking enforced
- [ ] Authorization tracking implemented
- [ ] Audit logging complete (LoggingData equivalent)
- [ ] Tests passing (CRUD + permissions + validations)
- [ ] No SQL injection vulnerabilities
- [ ] Transactions used for data consistency

## 5. Technical Design

### Database Tables

| Table | Model | Purpose |
|-------|-------|---------|
| **dbTransaksi** | MemorialDetail | Master transaction (header) - NoBukti, Tanggal, Devisi, Note, totals, authorization fields |
| **dbTrans** | Memorial | Detail transactions - NoBukti+Urut (PK), Perkiraan, Lawan, Keterangan, Debet, Kredit, Valas, Kurs |
| **dbAktiva** | Aktiva | Fixed asset master |
| **dbAktivadet** | AktivaDetail | Fixed asset depreciation detail |
| **dbGiro** | Giro | Check/Giro transactions |
| **dbHutPiut** | HutangPiutang | Accounts Payable/Receivable ledger |
| **dbTempHutPiut** | TempHutPiutang | Temporary invoice selection per user session |
| **dbPerkiraan** | Perkiraan | Chart of accounts |
| **dbValas** | Valas | Currency master |
| **dbValasdet** | ValasDetail | Exchange rates by date |
| **dbDevisi** | Divisi | Division/Department |
| **dbMenu** | Menu | Menu configuration with OL (authorization level) |

### API Endpoints

| Method | Route | Controller Method | Description |
|--------|-------|-------------------|-------------|
| GET | /memorial | index() | List transactions (FrmMainMemorial) |
| GET | /memorial/create | create() | Show create form |
| POST | /memorial | store() | Create new transaction (Choice='I') |
| GET | /memorial/{noBukti}/edit | edit() | Show edit form |
| PUT | /memorial/{noBukti} | update() | Update transaction (Choice='U') |
| DELETE | /memorial/{noBukti} | destroy() | Delete transaction (Choice='D') |
| GET | /memorial/{noBukti} | show() | View transaction details |
| GET | /memorial/export | export() | Export to Excel |
| POST | /memorial/{noBukti}/authorize | authorize() | Multi-level authorization |

### Dependencies

#### Existing Code to Check
- [x] **app/Models/Memorial.php** - EXISTS (dbTrans detail model)
- [x] **app/Models/MemorialDetail.php** - EXISTS (dbTransaksi master model)
- [x] **app/Models/Aktiva.php** - EXISTS with memorial() relationship
- [x] **app/Models/Giro.php** - EXISTS with memorial() relationship
- [x] **app/Models/HutangPiutang.php** - EXISTS with memorial() relationship
- [x] **app/Models/TempHutPiutang.php** - EXISTS
- [x] **app/Services/MemorialService.php** - EXISTS (654 lines)
- [x] **app/Controllers/MemorialController.php** - EXISTS (371 lines)

#### Related Services/Procedures
- [ ] Check **MyProcedure.pas** for shared functions:
  - `DataBersyarat()` → Laravel Query Builder
  - `TampilIsiData()` → Lookup/Browse functionality
  - `CekPeriode()` → Period validation service
  - `IsLockPeriode()` → Period lock service
  - `LoggingData()` → Audit log service
- [ ] Check **OtorisasiService.php** for authorization logic
- [ ] Check **HutangPiutangMemorialService.php** for AP/AR integration

## 6. Implementation Plan

### Phase 0: Analysis (COMPLETED)
✅ Read all 5 Delphi forms
✅ Identify 7 key validations
✅ Map 5 business logic procedures
✅ Identify existing Laravel code

### Phase 1: Core Layer (Backend)

#### 1.1 Review & Update Models (30 min)
- [ ] Review existing Memorial.php and MemorialDetail.php
- [ ] Ensure all fillable fields are present
- [ ] Add relationships if missing (aktivas, giros, hutangPiutangs)
- [ ] Add scope methods for filtering

#### 1.2 Review & Update Service (2 hours)
Review existing MemorialService.php (654 lines):
- [ ] Validate store() method implements all 7 validations
- [ ] Add HutPiut temporary matching logic
- [ ] Add Aktiva integration logic
- [ ] Add Giro integration logic
- [ ] Ensure stored procedure is called correctly
- [ ] Add authorization calculation
- [ ] Wrap in DB::transaction()

#### 1.3 Review & Update Controller (1 hour)
Review existing MemorialController.php (371 lines):
- [ ] Ensure store/update/destroy use MemorialService
- [ ] Add authorization checks (Policy)
- [ ] Add period lock validation
- [ ] Return proper JSON responses
- [ ] Handle exceptions properly

#### 1.4 Create/Update Request Classes (30 min)
- [ ] **StoreMemorialRequest.php** - Validation for create
- [ ] **UpdateMemorialRequest.php** - Validation for update
- [ ] **DeleteMemorialRequest.php** - Validation for delete
- [ ] Implement authorize() method checking IsTambah/IsKoreksi/IsHapus

#### 1.5 Create/Update Policy (20 min)
- [ ] **MemorialPolicy.php**
  - create() → check IsTambah
  - update() → check IsKoreksi
  - delete() → check IsHapus
  - view() → check general access
  - export() → check IsExcel
  - print() → check IsCetak

#### 1.6 Add Routes (10 min)
- [ ] Register resource routes in `routes/web.php` or `routes/api.php`
- [ ] Add custom routes for export, authorize

### Phase 2: Views (Frontend)

#### 2.1 Index View (1 hour)
- [ ] **resources/views/memorial/index.blade.php**
  - Master-detail grid (cxGrid equivalent)
  - Filters: month, year, divisi, status, need_auth
  - Action buttons: Create, Edit, Delete, Excel Export
  - Show authorization status

#### 2.2 Form View (2 hours)
- [ ] **resources/views/memorial/form.blade.php** (create/edit)
  - Master section: NoBukti, Tanggal, Devisi, Note
  - Detail grid: Add/Edit/Delete lines
  - Each line: Perkiraan, Lawan, Keterangan, Debet, Kredit, Valas, Kurs
  - Calculate totals (debit/credit balance)
  - THPC mode selector
  - Save/Cancel buttons
  - Handle Aktiva popup
  - Handle Giro popup
  - Handle HutPiut popup

#### 2.3 HutPiut Matching View (1 hour)
- [ ] **resources/views/memorial/_hutpiut_modal.blade.php**
  - Show open invoices from TempHutPiutang
  - Checkboxes to select invoices
  - Display: NoFaktur, Tanggal, JatuhTempo, Saldo
  - Calculate total selected
  - Validate total matches transaction amount

#### 2.4 Aktiva View (30 min)
- [ ] **resources/views/memorial/_aktiva_modal.blade.php**
  - Asset selection
  - Depreciation parameters

#### 2.5 Giro View (30 min)
- [ ] **resources/views/memorial/_giro_modal.blade.php**
  - Check details: Bank, NoGiro, TglGiro, Amount

### Phase 3: Testing

#### 3.1 Unit Tests (2 hours)
- [ ] **tests/Unit/Services/MemorialServiceTest.php**
  - Test store() with valid data
  - Test VAL1: Required fields
  - Test VAL2: HutPiut balance
  - Test VAL6: Debit-credit balance
  - Test multi-currency calculation
  - Test NoUrut auto-increment

#### 3.2 Feature Tests (2 hours)
- [ ] **tests/Feature/MemorialControllerTest.php**
  - Test index() returns list
  - Test store() with IsTambah=true
  - Test store() with IsTambah=false (403 Forbidden)
  - Test update() with IsKoreksi=true
  - Test update() with IsKoreksi=false (403 Forbidden)
  - Test destroy() with IsHapus=true
  - Test destroy() with IsHapus=false (403 Forbidden)
  - Test VAL3: Period lock check
  - Test VAL5: Giro clearing check on delete

#### 3.3 Integration Tests (1 hour)
- [ ] Test Aktiva integration
- [ ] Test Giro integration
- [ ] Test HutPiut temporary matching
- [ ] Test stored procedure call

### Phase 4: Authorization & Audit

#### 4.1 Authorization Implementation (1 hour)
- [ ] Implement OtorisasiService integration
- [ ] Add authorize() endpoint
- [ ] Track authorization levels (1-5)
- [ ] Store authorized_user and authorized_date per level

#### 4.2 Audit Logging (30 min)
- [ ] Log all CRUD operations
- [ ] Equivalent to Delphi's LoggingData()
- [ ] Store: user, timestamp, action, old_value, new_value

### Phase 5: Validation & Deployment

#### 5.1 Code Quality (30 min)
- [ ] Run `./vendor/bin/pint` (PSR-12 formatting)
- [ ] Check no SQL injection (use parameterized queries)
- [ ] Ensure DB::transaction() used
- [ ] Add PHPDoc comments with Delphi references

#### 5.2 Manual Testing (1 hour)
- [ ] Test full CRUD workflow
- [ ] Test permissions (login as user with different privileges)
- [ ] Test validations (try to save invalid data)
- [ ] Test HutPiut matching
- [ ] Test Aktiva integration
- [ ] Test Giro integration
- [ ] Test multi-currency
- [ ] Test period lock

#### 5.3 Migration Validation Tool (15 min)
```bash
php tools/validate_migration.php Memorial FrmMemorial
```

## 7. Estimated Time

| Phase | Estimated Time |
|-------|----------------|
| Phase 0: Analysis | 2 hours (DONE) |
| Phase 1: Core Layer | 4 hours |
| Phase 2: Views | 5 hours |
| Phase 3: Testing | 5 hours |
| Phase 4: Auth & Audit | 1.5 hours |
| Phase 5: Validation | 1.5 hours |
| **TOTAL** | **19 hours** |

**Complexity Factor**: COMPLEX (5 forms, 6 related tables, stored procedure, temp table management)
**Confidence**: Medium (existing code present, but needs significant enhancement)

## 8. Notes for Agent

### DO
- Review existing Memorial models/service/controller first
- Follow existing patterns in PPL, PO, PB migrations
- Check `ai_docs/patterns/` for similar master-detail cases
- Use DB::transaction() for all multi-table operations
- Call stored procedure `Sp_Transaksi` for actual CRUD (preserve Delphi logic)
- Handle TempHutPiutang per-user session correctly (use IDUser)
- Validate debit=credit balance at both detail and master level
- Check period lock before any CUD operation
- Add Delphi references in comments (e.g., `// Delphi: FrmMemorial.pas line 2243`)
- Use parameterized queries (Query Builder, not raw SQL)
- Run validation tool after implementation

### DON'T
- Create new database tables (all tables exist)
- Skip authorization checks (OL-based permissions required)
- Use string concatenation in SQL (SQL injection risk)
- Skip transaction wrapping (data consistency critical)
- Skip HutPiut balance validation (critical business rule)
- Allow same account for Perkiraan and Lawan
- Skip period lock check
- Comment out validations "for now"
- Delete existing working code without understanding it
- Forget to clear TempHutPiutang after successful save

### Critical Business Rules
1. **Debit = Credit Balance** - MUST validate at all levels
2. **HutPiut Matching** - Total selected invoices MUST equal transaction amount
3. **Period Lock** - MUST check before ANY write operation
4. **Giro Clearing** - MUST prevent deletion if check is cleared
5. **Multi-Currency** - Each line can have different currency, proper exchange rate required
6. **NoUrut** - MUST auto-increment per NoBukti
7. **Stored Procedure** - MUST call Sp_Transaksi for actual database writes
8. **Authorization** - Multi-level authorization based on amount thresholds

### Existing Services to Use
- **OtorisasiService** - for authorization logic
- **HutangPiutangMemorialService** - for AP/AR integration
- **Period validation service** - for lock checking
- **Audit log service** - for logging

### Reference Migrations
Look at these successful migrations for patterns:
- **PPL** - Master-detail with permissions
- **PO** - Stored procedure integration
- **PB** - Multi-table transactions

---

**STATUS**: ✅ Spec complete and ready for ADW Phase I (Analysis Agent)
**Next Step**: Run ADW pipeline or invoke `/delphi-laravel-migration` skill
