# Migration Specification: INV (Invoice Pembelian)

**Created**: Tue, Jan 13, 2026 10:32:05 PM
**Status**: In Progress
**Complexity**: COMPLEX

## 1. Problem Statement
Migrate Invoice Pembelian (Purchase Invoice) transaction module from Delphi to Laravel. This is a master-detail form that links Purchase Orders (dbBeli) to Invoice (dbInvoice/dbInvoiceDet) with authorization support. The form manages invoice entry with PPN calculation, currency conversion, and multi-level authorization.

## 2. Delphi Source Files
- FrmInv.pas: `d:\migrasi\pwt\Trasaksi\Beli\FrmInv.pas`
- FrmInv.dfm: `d:\migrasi\pwt\Trasaksi\Beli\FrmInv.dfm`
- FrmMainInv.pas: `d:\migrasi\pwt\Trasaksi\Beli\FrmMainInv.pas`
- FrmMainInv.dfm: `d:\migrasi\pwt\Trasaksi\Beli\FrmMainInv.dfm`

## 3. Requirements

### Functional Requirements
- [ ] FR1: Create Invoice from multiple Purchase Orders (NoBeli references)
- [ ] FR2: Support multi-level authorization workflow (IsOtorisasi1, OtoUser1, TglOto1)
- [ ] FR3: Calculate DPP, PPN, and NET automatically based on Purchase Orders
- [ ] FR4: Support currency (Valas) and exchange rate (Kurs) management
- [ ] FR5: Handle payment terms (TUNAI/KREDIT) with due date calculation (Hari)
- [ ] FR6: Link to Purchase Order (NoPO) with auto-fill data
- [ ] FR7: Store supplier invoice number (NoFaktur) and date (TglFaktur)
- [ ] FR8: Support PPN types: NONE, Exclude, Include with percentage (ppnp)
- [ ] FR9: Master-detail view showing all invoice details per purchase

### Mode Operations (Choice:Char)
- [ ] Choice='I' (Insert) - store() via Sp_Invoice
- [ ] Choice='U' (Update) - update() via Sp_Invoice
- [ ] Choice='D' (Delete) - destroy() via Sp_Invoice

### Permissions
- [ ] IsTambah - create invoice permission
- [ ] IsKoreksi - update invoice permission
- [ ] IsHapus - delete invoice permission
- [ ] IsCetak - print invoice permission
- [ ] Authorization permission for Otorisasi/BatalOtorisasi

### Validations to Migrate
- [ ] VAL1: Period check - CekPeriode(IDUser, Tanggal) before any operation
- [ ] VAL2: Lock period - IsLockPeriode(PeriodBln, PeriodThn) must be true
- [ ] VAL3: Authorization check - Cannot edit/delete if IsOtorisasi1=true
- [ ] VAL4: Nomor Urut format - must be 5 digits
- [ ] VAL5: NoBeli validation - Must exist in dbBeli and not yet invoiced
- [ ] VAL6: Duplicate number check - Daftar_Nomor() prevents concurrent editing
- [ ] VAL7: Supplier validation - Must exist in dbCustSupp with type 'HT'
- [ ] VAL8: NoPO validation - Must exist and belong to same supplier

## 4. Acceptance Criteria
- [ ] All mode operations working (I/U/D via Sp_Invoice)
- [ ] All permissions enforced (create/update/delete/print)
- [ ] All validations migrated (period check, lock, authorization)
- [ ] Audit logging complete (LoggingData for I/U/D)
- [ ] Authorization workflow functional (Otorisasi/BatalOtorisasi)
- [ ] Master-detail view displays correctly
- [ ] Currency and PPN calculations accurate
- [ ] Tests passing (unit + feature)

## 5. Technical Design

### Database Tables
| Table | Model | Purpose |
|-------|-------|---------|
| dbInvoice | DbInvoice | Invoice header (NoBukti, Tanggal, KodeSupp, etc.) |
| dbInvoiceDet | DbInvoiceDET | Invoice details (NoBeli references) |
| dbBeli | DbBeli | Purchase Order reference |
| dbBeliDet | DbBeliDet | Purchase detail for calculations |
| dbCustSupp | DbCustSupp | Supplier master data |
| dbPO | DbPO | Purchase Order reference |

### API Endpoints
| Method | Route | Controller Method |
|--------|-------|------------------|
| GET | /invoice | index() |
| GET | /invoice/create | create() |
| POST | /invoice | store() |
| GET | /invoice/{id} | show() |
| GET | /invoice/{id}/edit | edit() |
| PUT | /invoice/{id} | update() |
| DELETE | /invoice/{id} | destroy() |
| POST | /invoice/{id}/authorize | authorize() |
| POST | /invoice/{id}/cancel-authorize | cancelAuthorize() |

### Stored Procedure
**Sp_Invoice** - Main stored procedure handling I/U/D operations
- Parameters: Choice, NoBukti, Tanggal, Keterangan, Urut, NoBeli, KodeSupp, NoPO, NoFaktur, TglFaktur, KodeVls, Kurs, PPN, TipeBayar, Hari, nourut

### Dependencies
- [ ] Check MyProcedure.pas for shared code: CekPeriode, IsLockPeriode, LoggingData, Daftar_Nomor, Otorisasi, BatalOtorisasi
- [ ] Check dbBeli module (Purchase Order)
- [ ] Check dbPO module (PO reference)
- [ ] Check authorization service for multi-level authorization

## 6. Implementation Plan

### Phase 1: Core (Models already exist ✓)
1. ✓ DbInvoice.php already exists
2. ✓ DbInvoiceDET.php already exists
3. Create InvoiceService.php
4. Create InvoiceController.php
5. Create Requests: StoreInvoiceRequest, UpdateInvoiceRequest
6. Create InvoicePolicy for authorization

### Phase 2: Business Logic
1. Implement Sp_Invoice stored procedure call wrapper
2. Implement authorization workflow (authorize/cancelAuthorize)
3. Implement period validation
4. Implement lock period check
5. Implement number reservation (Daftar_Nomor)
6. Implement audit logging
7. Implement validation rules (all 8 validations)

### Phase 3: Views
1. Create index.blade.php (master-detail grid)
2. Create create.blade.php (invoice entry form)
3. Create edit.blade.php (invoice edit form)
4. Create show.blade.php (invoice detail view)

### Phase 4: Testing
1. Unit tests for InvoiceService
2. Feature tests for InvoiceController
3. Test authorization workflow
4. Test all validation rules
5. Browser tests for UI

## 7. Notes for Agent

### Critical Business Logic from Delphi
1. **Sp_Invoice Stored Procedure** (FrmInv.pas:429-497):
   - Handle 3 modes: Insert (I), Update (U), Delete (D)
   - Call stored procedure: Sp_Invoice
   - Parameters mapping documented in Sp_Beli.Parameters
   - After operation: TampilData() to refresh, LoggingData() for audit

2. **Authorization Logic** (FrmMainInv.pas:451-513):
   - Otorisasi(): Authorize invoice with user tracking
   - BatalOtorisasi(): Cancel authorization
   - Check IsOtorisasi1 before allowing edit/delete
   - Track OtoUser1 and TglOto1

3. **Period & Lock Validation** (FrmInv.pas:644-665, 728-755):
   - ALWAYS check CekPeriode() before any operation
   - ALWAYS check IsLockPeriode() before modify operations
   - Show specific error messages for each failure

4. **Number Management** (FrmInv.pas:341-356):
   - Check_Nomor() generates new number
   - Daftar_Nomor() reserves number to prevent conflicts
   - Hapus_Daftar_Nomor() releases number on cancel/close
   - NoUrut must be 5 digits

5. **NoBeli Validation** (FrmInv.pas:1044-1060):
   - Check if NoBeli exists in dbBeli
   - Check if not already invoiced: `Not in(select NoBeli from dbInvoiceDet)`
   - Auto-load supplier from Purchase Order

6. **UpdatedbBeli Logic** (FrmInv.pas:520-545):
   - When ModalKoreksi=True, allows editing header fields
   - Updates: KodeSupp, Keterangan, NoPO, Kurs, Hari, KodeVls, Tipebayar, PPN

### DO
- Follow existing patterns in app/
- Check ai_docs/patterns/ for similar cases (PPL, BARANG)
- Run validation tools after implementation
- Use transactions for multi-step operations
- Call stored procedure via DB::statement() or raw query
- Preserve all validation rules - NO shortcuts

### DON'T
- Create new database tables
- Skip authorization checks
- Use string concatenation in SQL
- Comment out validations
- Skip period/lock checks (CRITICAL for data integrity)
- Allow operations on authorized invoices (IsOtorisasi1=true)
