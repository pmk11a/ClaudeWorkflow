# KasBank Migration Plan

**Generated**: 2026-01-15
**Status**: PLANNING
**Complexity**: 🔴 COMPLEX
**Estimated Time**: 10-14 hours

## 📊 Module Assessment

### Complexity Rating: 🔴 COMPLEX

**Rationale:**
- **9 related forms** with complex interdependencies
- **Multiple transaction types**: BKK, BKM, BBM, BBK (Kas Masuk/Keluar, Bank Masuk/Keluar)
- **Multi-currency support** with exchange rate calculations
- **Complex business logic**:
  - Hutang Piutang (Accounts Receivable/Payable) management
  - Giro management (issuance and clearing)
  - Deposito management
  - Aktiva (Fixed Assets) transactions
  - Multi-level transaction approvals
- **Heavy MyProcedure dependencies** (8+ functions)
- **Stock/financial impact** on multiple tables

### Tables Involved

| Table | Purpose | Status |
|-------|---------|--------|
| `dbtrans` | Transaction header | ❌ Need to create model |
| `dbtransaksi` | Transaction detail | ❌ Need to create model |
| `dbaktiva` | Fixed assets master | ✅ DbAKTIVA.php exists |
| `dbaktivadet` | Fixed assets transactions | ✅ DbAKTIVADET.php exists |
| `dbhutpiut` | AR/AP transactions | ✅ DbHUTPIUT.php exists |
| `dbgiro` | Giro/Check management | ✅ DbGIRO.php exists |
| `dbdeposito` | Deposit management | ✅ DbDEPOSITO.php exists |
| `dbtemphutpiut` | Temporary AR/AP table | ❌ Need to verify |
| `dbperkiraan` | Chart of accounts | ✅ Existing |
| `dbcustsupp` | Customers/Suppliers | ✅ Existing |
| `dbvalas` | Currencies | ✅ Existing |
| `dbbagian` | Departments | ✅ Existing |

### Forms to Migrate

| Form | Lines | Purpose | Complexity |
|------|-------|---------|------------|
| FrmKasBank.pas | ~2000+ | Main Kas/Bank transaction form | 🔴 COMPLEX |
| FrmHutPiut.pas | ~748 | Hutang Piutang (AR/AP) management | 🟡 MEDIUM |
| FrmKasBankGiro.pas | ~614 | Giro management | 🟡 MEDIUM |
| FrmKasBankDeposito.pas | ~434 | Deposito management | 🟡 MEDIUM |
| FrmKasBankAktiva.pas | ~441 | Aktiva transactions | 🟡 MEDIUM |
| FrmKasBankHutPiut.pas | - | HutPiut detail form | 🟢 SIMPLE |
| FrmTransAktiva.pas | - | Aktiva transactions | 🟡 MEDIUM |
| FrmMainKasBank.pas | - | Main menu | 🟢 SIMPLE |

## 🔍 Key Findings from Discovery

### Business Logic Identified

#### 1. Main Transaction Types (THPC Codes)
```
P+ = Piutang Debit (AR Debit)
P- = Piutang Kredit (AR Credit)
H+ = Hutang Debit (AP Debit)
H- = Hutang Kredit (AP Credit)
T+ = Transfer Debit
T- = Transfer Credit
R+ = Retur Debit
R- = Retur Credit
```

#### 2. Transaction Modes (Mode)
```
BKK = Bukti Kas Keluar (Cash Disbursement)
BKM = Bukti Kas Masuk (Cash Receipt)
BBK = Bukti Bank Keluar (Bank Disbursement)
BBM = Bukti Bank Masuk (Bank Receipt)
```

#### 3. Key Procedures in FrmKasBank

| Procedure | Purpose | Laravel Mapping |
|-----------|---------|-----------------|
| `SimpanData(Choice)` | Save transaction header/detail | `KasBankService::saveTransaction()` |
| `UpdateTransaksi` | Update existing transaction | `KasBankService::updateTransaction()` |
| `TampilData` | Load transaction data | `KasBankService::getTransaction()` |
| `SimpanDataGiro` | Save giro transactions | `GiroService::saveGiro()` |
| `TampilDataGiro` | Load giro data | `GiroService::getGiroByTransaction()` |
| `SimpanDataDeposito` | Save deposito transactions | `DepositoService::saveDeposito()` |
| `SimpanDataHutPiut` | Save AR/AP transactions | `HutPiutService::saveHutPiut()` |
| `SimpanDataAktiva` | Save fixed asset transactions | `AktivaService::saveAktivaTransaction()` |
| `CekLawanDiPosting` | Validate counterpart account | `KasBankService::validateCounterpart()` |
| `CariJumlahPembayaranHutPiut` | Calculate AR/AP payments | `HutPiutService::calculatePayments()` |
| `IsiTempHutPiut` | Populate temporary AR/AP table | `HutPiutService::populateTempHutPiut()` |

#### 4. Key Procedures in FrmHutPiut

| Procedure | Purpose | Laravel Mapping |
|-----------|---------|-----------------|
| `SimpanData(Choice)` | Save AR/AP detail | `HutPiutService::saveDetail()` |
| `CekPelunasanMax` | Check overpayment | `HutPiutService::checkOverpayment()` |
| `JumlahYgDibayar` | Calculate payment amount | `HutPiutService::calculatePaidAmount()` |
| `SaldoHutPiut` | Calculate running balance | `HutPiutService::calculateBalance()` |
| `TampilDataHutPiut` | Load AR/AP data | `HutPiutService::getHutPiutData()` |

#### 5. Currency & Exchange Rate Logic

```delphi
// From FrmKasBank
if Valas.Text='IDR' then
  JumlahRp := Jumlah
else
  JumlahRp := Jumlah * Kurs;

// Multi-currency support for Giro
if KodeVls.Text='IDR' then begin
  DebetD := 0;
  KreditD := 0;
end else begin
  // Store foreign currency amount
end;
```

### Event Handlers Identified

| Event | Handler | Laravel Equivalent |
|-------|---------|-------------------|
| FormShow | Load data | `__construct()` or `mount()` |
| TambahBtnClick | Add new | `create()` method |
| KoreksiBtnClick | Edit existing | `edit()` method |
| HapusBtnClick | Delete | `destroy()` method |
| BitBtn1Click | Save | `store()` or `update()` |
| ModeChange | Transaction type change | Computed property |
| THPCChange | Transaction category change | Computed property |

### MyProcedure Dependencies

| Function | Purpose | Laravel Equivalent |
|----------|---------|-------------------|
| `MyFindField` | Search field value | `Model::where()->first()` |
| `DataBersyarat` | Query with conditions | `Model::where()->get()` |
| `TampilIsiData` | Browse form | BrowseService |
| `CekPeriode` | Period validation | PeriodService::isLocked() |
| `Check_Nomor` | Number generation | NumberService::generate() |
| `IsLockPeriode` | Lock period check | LockPeriodService::isLocked() |
| `UrutAktiva` | Generate asset number | AktivaService::generateNumber() |
| `KursValas` | Get exchange rate | ExchangeRateService::getRate() |

### Database Operations

**Complex Queries:**
- Multi-table JOINs with vwHutPiut view
- Aggregate calculations (SUM, COUNT)
- Subqueries for balance calculations
- Temporary table operations (dbTempHutPiut)
- Transaction updates across multiple tables

**Transactions:**
- All operations must be wrapped in database transactions
- Atomicity required for header-detail operations
- Locking needed for concurrent access

## 🛠️ Migration Approach

### Strategy: Modular Migration

Given the complexity, we'll use a **phased approach**:

1. **Phase 1**: Core Transaction Module (KasBank main)
2. **Phase 2**: Giro Management
3. **Phase 3**: Deposito Management
4. **Phase 4**: Hutang Piutang (AR/AP)
5. **Phase 5**: Aktiva Transactions

### Tools & Technologies

| Component | Technology |
|-----------|------------|
| Backend | Laravel 12 + PHP 8.2 |
| Frontend | Blade Templates + Alpine.js |
| State Management | Livewire 3 (for complex forms) |
| Validation | Form Request + Rules |
| Database | SQL Server via PDO |
| Testing | PHPUnit + SQLite (in-memory) |

### Architecture Pattern

```
Routes → Controller → Request Validation → Service → Model
                ↓
            Policies (Authorization)
```

## ✅ Quality Gates Checklist

### Phase 0: Discovery ✓
- [x] All procedures identified
- [x] All functions identified
- [x] All events identified
- [x] MyProcedure dependencies mapped
- [x] Database operations documented
- [x] Similar migrations referenced (SPK, Beli)

### Phase 1: Models & Migrations
- [ ] Create DbTrans model (if not exists)
- [ ] Create DbTransaksi model (if not exists)
- [ ] Verify DbHUTPIUT model has all fields
- [ ] Verify DbGIRO model has all fields
- [ ] Verify DbDEPOSITO model has all fields
- [ ] Verify DbAKTIVA/DbAKTIVADET models
- [ ] Create DbTempHutPiut model (if needed)

### Phase 2: Services
- [ ] KasBankService created
- [ ] GiroService created
- [ ] DepositoService created
- [ ] HutPiutService created
- [ ] AktivaService created (or verify existing)
- [ ] All procedures mapped to service methods
- [ ] Transaction support implemented
- [ ] Validation logic implemented

### Phase 3: Controllers & Requests
- [ ] KasBankController created
- [ ] GiroController created
- [ ] DepositoController created
- [ ] HutPiutController created
- [ ] AktivaController created (or verify existing)
- [ ] StoreRequest classes for all modes
- [ ] UpdateRequest classes for all modes
- [ ] DeleteRequest classes for all modes

### Phase 4: Views
- [ ] Index view with transaction list
- [ ] Create view with all forms
- [ ] Edit view with all forms
- [ ] Giro modal/form
- [ ] Deposito modal/form
- [ ] HutPiut modal/form
- [ ] Aktiva modal/form
- [ ] Validation feedback working

### Phase 5: Routes & Policies
- [ ] Routes registered in web.php
- [ ] Policies created
- [ ] Authorization checks in place
- [ ] Menu integration

### Phase 6: Testing
- [ ] Service tests passing
- [ ] Feature tests passing
- [ ] All transaction types tested (BKK, BKM, BBK, BBM)
- [ ] Multi-currency calculations verified
- [ ] HutPiut balance calculations verified
- [ ] Giro clearing logic verified
- [ ] Deposito lifecycle verified

### Phase 7: Documentation
- [ ] Migration summary written
- [ ] Delphi source references present
- [ ] Known limitations documented
- [ ] Integration points documented

## 📝 Implementation Tasks

### Task Group 1: Foundation (2-3 hours)
1. Create missing models (DbTrans, DbTransaksi, DbTempHutPiut)
2. Verify existing models have correct fields
3. Create base KasBankService with transaction support
4. Create base KasBankController
5. Create basic routes

### Task Group 2: Main KasBank Form (3-4 hours)
1. Implement SimpanData logic
2. Implement UpdateTransaksi logic
3. Implement TampilData loading
4. Implement CekLawanDiPosting validation
5. Create main transaction form view
6. Add Mode and THPC selection logic
7. Implement currency conversion logic
8. Add validation rules

### Task Group 3: HutPiut Module (2-3 hours)
1. Create HutPiutService
2. Implement IsiTempHutPiut logic
3. Implement SimpanDataHutPiut logic
4. Implement CekPelunasanMax validation
5. Implement SaldoHutPiut calculation
6. Create HutPiut modal/form
7. Add AR/AP balance display

### Task Group 4: Giro Module (2 hours)
1. Create GiroService
2. Implement SimpanDataGiro logic
3. Implement TampilDataGiro loading
4. Handle Giro clearing logic
5. Create Giro modal/form
6. Add pending Giro display

### Task Group 5: Deposito Module (1-2 hours)
1. Create DepositoService
2. Implement SimpanDataDeposito logic
3. Implement TampilDeposito loading
4. Handle deposito opening/closing
5. Create Deposito modal/form

### Task Group 6: Aktiva Integration (1-2 hours)
1. Verify AktivaService exists
2. Implement SimpanDataAktiva logic
3. Implement TampilDataAktiva loading
4. Create Aktiva modal/form
5. Integrate with main transaction form

### Task Group 7: Testing & Validation (2-3 hours)
1. Write unit tests for calculations
2. Write feature tests for CRUD operations
3. Test multi-currency scenarios
4. Test all transaction modes (BKK, BKM, BBK, BBM)
5. Test HutPiut balance calculations
6. Test Giro lifecycle
7. Test Deposito lifecycle
8. Performance testing

## ⚠️ Identified Risks

### Risk 1: Multi-Currency Calculations
**Impact**: HIGH
**Mitigation**: Create dedicated CurrencyService for exchange rate handling; write extensive tests for calculations

### Risk 2: Complex HutPiut Logic
**Impact**: HIGH
**Mitigation**: Isolate HutPiut logic in dedicated service; verify calculations against Delphi output

### Risk 3: Transaction Atomicity
**Impact**: HIGH
**Mitigation**: Use database transactions for all multi-table operations; implement retry logic

### Risk 4: Performance with Large Data
**Impact**: MEDIUM
**Mitigation**: Implement pagination; use database indexes; optimize queries

### Risk 5: Giro Clearing State Management
**Impact**: MEDIUM
**Mitigation**: Implement state machine pattern; add validation for state transitions

## 📚 Reference Migrations

### SPK Module (Complex)
- **What to Learn**: Multi-form integration, approval workflows
- **See**: `SPK_MIGRATION_SUMMARY.md`

### Beli Module (Medium)
- **What to Learn**: Master-detail patterns, multi-table transactions
- **See**: `ai_docs/lessons/BELI_*`

### Aktiva Module (Existing)
- **What to Learn**: Fixed asset transaction patterns
- **See**: Existing AktivaService, AktivaController

## 🔗 Integration Points

1. **Perkiraan Module**: Chart of accounts integration
2. **CustSupp Module**: Customer/Supplier selection
3. **Valas Module**: Currency selection and exchange rates
4. **Bagian Module**: Department selection
5. **Devisi Module**: Division selection
6. **Aktiva Module**: Fixed asset transactions

## 📊 Estimated Time Breakdown

| Phase | Tasks | Time |
|-------|-------|------|
| Phase 1 | Models & Migrations | 2-3h |
| Phase 2 | Services Implementation | 4-5h |
| Phase 3 | Controllers & Requests | 2-3h |
| Phase 4 | Views & Frontend | 3-4h |
| Phase 5 | Routes & Policies | 1h |
| Phase 6 | Testing | 2-3h |
| Phase 7 | Documentation | 1h |
| **Total** | | **15-22 hours** |

## 🚦 Approval Gates

### Gate 1: Plan Approval ✓
- [ ] User approves this plan
- [ ] Priority is set (Core vs Full features)
- [ ] Scope is confirmed (which forms to migrate first)

### Gate 2: Design Approval (After Phase 1)
- [ ] Database schema verified
- [ ] Service architecture approved
- [ ] API design approved

### Gate 3: Implementation Approval (After Phase 4)
- [ ] All forms working
- [ ] Calculations verified
- [ ] Ready for testing

### Gate 4: Final Sign-Off (After Phase 7)
- [ ] All tests passing
- [ ] Documentation complete
- [ ] Ready for production

## 📝 Notes

### Key Complexity Points

1. **Composite Keys**: Several tables use composite primary keys
2. **Temporary Tables**: dbTempHutPiut requires special handling
3. **Views**: vwHutPiut is a database view - need to handle query structure
4. **Multiple Status Codes**: HT+, HT-, PT+, PT-, UHT+, UHT-, UPT+, UPT-
5. **Transaction Modes**: BKK, BKM, BBM, BBK - each has different rules
6. **THPC Codes**: Transaction category affects validation rules

### Special Considerations

1. **Lock Period**: Must check period locks before allowing transactions
2. **Authorization**: Multi-level authorization may be required
3. **Audit Trail**: All changes must be logged
4. **Number Generation**: Automatic document numbering
5. **Exchange Rates**: Must use rates from transaction date
6. **Giro Clearing**: Track giro from issuance to clearing
7. **Deposito Maturity**: Track deposit maturity dates

---

**Next Steps:**
1. Get user approval for this plan
2. Confirm scope (migrate all forms or start with core)
3. Create models (DbTrans, DbTransaksi)
4. Begin implementation with Phase 1

