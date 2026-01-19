# Delphi Migration Skill - Rules & Regulations

**Version**: 1.0
**Last Updated**: 2026-01-03
**Status**: Mandatory Compliance
**Severity**: Violations may cause production failures

---

## 📋 Table of Contents

1. [Critical Rules (P0)](#critical-rules-p0)
2. [Mandatory Rules (P1)](#mandatory-rules-p1)
3. [Recommended Rules (P2)](#recommended-rules-p2)
4. [Forbidden Practices](#forbidden-practices)
5. [Code Standards](#code-standards)
6. [Security Rules](#security-rules)
7. [Testing Rules](#testing-rules)
8. [Documentation Rules](#documentation-rules)
9. [Workflow Rules](#workflow-rules)
10. [Enforcement & Validation](#enforcement--validation)

---

## Critical Rules (P0)

**Severity**: 🔴 CRITICAL
**Consequence**: Production failure, data loss, security breach
**Compliance**: 100% REQUIRED

### Rule P0.1: Database Safety
**NEVER modify existing database schema**

**❌ FORBIDDEN**:
```bash
php artisan migrate:fresh        # Deletes ALL data
php artisan migrate:reset         # Deletes ALL data
php artisan migrate:refresh       # Deletes ALL data
php artisan db:wipe              # Deletes ALL data
```

**✅ ALLOWED**:
```bash
php artisan migrate              # Add new tables only
php artisan migrate:rollback     # Safe rollback
```

**Rationale**: Database tables already exist from Delphi. We only preserve logic, NOT recreate schema.

**Validation**:
```bash
# Check migration files before running
cat database/migrations/*.php | grep -i "drop\|truncate\|delete"
# If found → REJECT migration file
```

---

### Rule P0.2: SQL Injection Prevention
**NEVER use string concatenation in SQL queries**

**❌ FORBIDDEN**:
```php
// String concatenation
DB::select("SELECT * FROM Users WHERE Name = '" . $name . "'");
DB::raw("WHERE ID = " . $id);

// Direct interpolation
$query = "DELETE FROM Table WHERE Field = $value";
```

**✅ REQUIRED**:
```php
// Use parameter binding
DB::select("SELECT * FROM Users WHERE Name = ?", [$name]);
DB::table('Users')->where('Name', $name)->get();

// Use query builder
DB::raw("WHERE ID = ?", [$id]);
```

**Rationale**: Prevents SQL injection attacks (OWASP Top 10).

**Validation**:
```bash
# Scan for SQL injection vulnerabilities
grep -r "DB::select.*\." app/
grep -r "DB::raw.*\." app/
# If found → REJECT code
```

---

### Rule P0.3: Transaction Wrapping
**ALWAYS wrap multi-step operations in DB::transaction()**

**❌ FORBIDDEN**:
```php
// No transaction - partial failure possible
$header = DbXXX::create($data);
DbXXXDET::create($detail);  // If this fails → orphan header!
```

**✅ REQUIRED**:
```php
// Transaction ensures all-or-nothing
DB::transaction(function () use ($data, $detail) {
    $header = DbXXX::create($data);
    DbXXXDET::create($detail);
});
```

**Rationale**: Prevents orphaned/inconsistent data.

**Validation**:
```php
// Check service methods
if (method creates/updates/deletes multiple records) {
    assert(uses DB::transaction());
}
```

---

### Rule P0.4: Authorization Enforcement
**NEVER skip authorization checks**

**❌ FORBIDDEN**:
```php
// No authorization check
public function store(Request $request) {
    $this->service->create($request->all());
}

// Commented out authorization
// $this->authorize('create', DbXXX::class);
```

**✅ REQUIRED**:
```php
// Request-level authorization
public function authorize(): bool {
    return $this->user()->can('create', DbXXX::class);
}

// Controller-level authorization
public function store(StoreXXXRequest $request) {
    $this->authorize('create', DbXXX::class);
    // ... rest of logic
}
```

**Rationale**: Security - prevents unauthorized access.

**Validation**:
```bash
# Check all store/update/destroy methods have authorization
grep -A 5 "public function store\|update\|destroy" app/Http/Controllers/*.php
# Each MUST have authorize() or policy check
```

---

### Rule P0.5: OL Configuration Verification
**ALWAYS verify OL (Organization Level) before implementing authorization**

**❌ FORBIDDEN**:
```php
// Assuming all modules use 5 levels
for ($i = 1; $i <= 5; $i++) {
    // Authorization logic
}
```

**✅ REQUIRED**:
```sql
-- FIRST: Check actual OL value
SELECT L1, KODEMENU, NAMA, OL FROM DBMENU WHERE KODEMENU = 'XXXX';

-- THEN: Use actual OL in code
$maxLevel = $menu->OL;  // e.g., 2 for PPL, 3 for PO
for ($i = 1; $i <= $maxLevel; $i++) {
    // Authorization logic
}
```

**Rationale**: Prevents implementing wrong number of authorization levels.

**Validation**:
```php
// Before implementing authorization
assert($maxLevel === $menu->OL);
assert($maxLevel <= 5 && $maxLevel >= 1);
```

---

## Mandatory Rules (P1)

**Severity**: 🟡 HIGH
**Consequence**: Business logic errors, data inconsistency
**Compliance**: ≥95% REQUIRED

### Rule P1.1: Mode Coverage
**MUST implement ALL detected modes (I/U/D)**

**❌ INCOMPLETE**:
```php
// Only implemented INSERT mode
public function create() { ... }

// Missing UPDATE and DELETE
```

**✅ COMPLETE**:
```php
// All modes from Delphi
public function create() { ... }    // Choice='I'
public function update() { ... }    // Choice='U'
public function delete() { ... }    // Choice='D'
```

**Rationale**: Incomplete migration = broken functionality.

**Validation**:
```bash
# Check Delphi for modes
grep -i "Choice='I'\|Choice='U'\|Choice='D'" FrmXXX.pas

# Check Laravel has matching methods
grep "public function create\|update\|delete" app/Services/XXXService.php
```

---

### Rule P1.2: Permission Mapping
**MUST map ALL permission variables from Delphi**

**Detection in Delphi**:
```pascal
IsTambah, IsKoreksi, IsHapus, IsCetak, IsExcel: Boolean;
```

**✅ REQUIRED Mapping**:
```php
// Policy class MUST implement ALL permissions
public function create()  { }  // IsTambah
public function update()  { }  // IsKoreksi
public function delete()  { }  // IsHapus
public function print()   { }  // IsCetak
public function export()  { }  // IsExcel
```

**Rationale**: Missing permissions = security holes.

**Validation**:
```bash
# Count permissions in Delphi
grep -c "IsTambah\|IsKoreksi\|IsHapus\|IsCetak\|IsExcel" FrmXXX.pas

# Count permissions in Laravel Policy
grep -c "public function create\|update\|delete\|print\|export" app/Policies/XXXPolicy.php

# Numbers MUST match
```

---

### Rule P1.3: Validation Completeness
**MUST detect and implement ALL validation patterns**

**8 Required Patterns**:
1. ✅ Required validation (`if Text = ''`)
2. ✅ Unique validation (`QuCheck.Locate`)
3. ✅ Range validation (`if Value < 0`)
4. ✅ Format validation (`IsValidDate`)
5. ✅ Lookup validation (`if not QuTable.Locate`)
6. ✅ Conditional validation (`if Type=1 then if Field...`)
7. ✅ Enum validation (`if not (Status in [...])`)
8. ✅ Custom validation (`raise Exception.Create`)

**Rationale**: Missing validation = data corruption.

**Validation**:
```bash
# Scan Delphi for validation patterns
grep -i "raise Exception\|ShowMessage.*harus\|if.*then.*raise" FrmXXX.pas

# Each MUST have corresponding Laravel validation rule
```

---

### Rule P1.4: Audit Logging
**MUST log ALL data modification operations**

**❌ MISSING**:
```php
public function create($data) {
    DbXXX::create($data);
    // Missing log!
    return $result;
}
```

**✅ REQUIRED**:
```php
public function create($data) {
    $result = DbXXX::create($data);

    // MUST log
    $this->logActivity('I', $result->NOBUKTI, $data);

    return $result;
}
```

**Rationale**: Audit trail required for compliance.

**Validation**:
```bash
# Check all create/update/delete methods log activity
grep -A 10 "public function create\|update\|delete" app/Services/*.php | grep "logActivity\|Log::"
# All MUST have logging
```

---

### Rule P1.5: Detail Line Constraints
**MUST enforce minimum detail requirements**

**For Single-Item Forms** (PB pattern):
```php
// Validation
'details' => 'required|array|size:1'  // Exactly 1

// Service constraint
if (count($details) !== 1) {
    throw new \Exception('Harus tepat 1 detail');
}
```

**For Multi-Item Forms** (PPL/PO pattern):
```php
// Validation
'details' => 'required|array|min:1'  // At least 1

// Delete constraint
if ($detailCount <= 1) {
    throw new \Exception('Minimal 1 detail harus ada');
}
```

**Rationale**: Business rules from Delphi.

**Validation**:
```bash
# Check detail validation exists
grep "'details'" app/Http/Requests/*/*.php
# MUST have min/size constraint
```

---

### Rule P1.6: Delphi Reference Comments
**MUST include Delphi references in code comments**

**❌ MISSING**:
```php
public function create($data) {
    // No reference to Delphi
}
```

**✅ REQUIRED**:
```php
/**
 * Create new PPL document
 * Delphi: FrmPPL.pas, UpdateDataPPL(Choice:Char), line 425
 * Mode: Choice='I' (INSERT)
 */
public function create($data) {
    // Implementation
}
```

**Rationale**: Traceability for future maintenance.

**Validation**:
```bash
# Check service methods have Delphi references
grep -B 3 "public function create\|update\|delete" app/Services/*.php | grep "Delphi:"
# All MUST have Delphi reference
```

---

## Recommended Rules (P2)

**Severity**: 🟢 MEDIUM
**Consequence**: Code quality issues, maintenance difficulty
**Compliance**: ≥80% RECOMMENDED

### Rule P2.1: Type Hints
**SHOULD add type hints to all methods**

**✅ RECOMMENDED**:
```php
public function create(array $data): DbXXX
{
    // Implementation
}

public function authorize(): bool
{
    // Implementation
}
```

**Rationale**: Better IDE support, fewer runtime errors.

---

### Rule P2.2: Code Formatting
**SHOULD run Pint before committing**

```bash
# Format all code
./vendor/bin/pint

# Check formatting
./vendor/bin/pint --test
```

**Rationale**: Consistent code style (PSR-12).

---

### Rule P2.3: Error Messages in Indonesian
**SHOULD use Indonesian for user-facing messages**

**✅ RECOMMENDED**:
```php
'tgl_bukti.required' => 'Tanggal harus diisi',
'details.min' => 'Minimal harus ada 1 baris detail',

throw new \Exception('Dokumen sudah diotorisasi, tidak dapat diubah');
```

**Rationale**: User experience for Indonesian users.

---

### Rule P2.4: Retrospective Documentation
**SHOULD run /delphi-retrospective after each migration**

```bash
# After migration complete
/delphi-retrospective
```

**Rationale**: Continuous improvement, knowledge sharing.

---

### Rule P2.5: Pre-Migration Advice
**SHOULD run /delphi-advise before starting**

```bash
# Before migration
/delphi-advise
"I want to migrate FrmSupplier"
```

**Rationale**: Learn from past migrations, avoid known issues.

---

## Forbidden Practices

**Severity**: 🚫 PROHIBITED
**Consequence**: Immediate rejection in code review

### ❌ FP.1: Direct User Input in Queries
```php
// NEVER
DB::select("SELECT * FROM Users WHERE ID = " . $_GET['id']);
Route::get('/user/{id}', function ($id) {
    return DB::select("SELECT * FROM Users WHERE ID = $id");
});
```

**Why**: SQL Injection vulnerability.

---

### ❌ FP.2: Hardcoded Values
```php
// NEVER
$moduleCode = '05006';  // Magic number
$warehouseCode = 'GDGPWT';  // Hardcoded

// ALWAYS use constants or config
const PB_MENU_CODE = '05006';
$warehouseCode = config('warehouse.default');
```

**Why**: Unmaintainable, environment-specific.

---

### ❌ FP.3: Commented-Out Authorization
```php
// NEVER
public function store(Request $request) {
    // $this->authorize('create', DbXXX::class);  // Commented out!
    return $this->service->create($request->all());
}
```

**Why**: Security hole.

---

### ❌ FP.4: Skipping Validation
```php
// NEVER
public function rules(): array {
    return [];  // Empty rules!
}

// NEVER
DB::table('xxx')->insert($request->all());  // No validation!
```

**Why**: Data corruption risk.

---

### ❌ FP.5: Manual NoUrut Sequencing
```php
// NEVER manually assign NoUrut
DbXXXDET::create([
    'NOBUKTI' => $noBukti,
    'NoUrut' => 5,  // Hardcoded!
]);

// ALWAYS use loop index
foreach ($details as $index => $detail) {
    DbXXXDET::create([
        'NOBUKTI' => $noBukti,
        'NoUrut' => $index + 1,  // Sequential
    ]);
}
```

**Why**: Duplicate/gap in sequence.

---

### ❌ FP.6: Ignoring Delphi Business Logic
```php
// NEVER simplify complex Delphi logic
// Delphi: if (Qty > Stock) and (Type <> 'PO') then raise
// Laravel: 'qty' => 'numeric'  // Missing business rule!

// ALWAYS preserve exact logic
public function withValidator($validator) {
    $validator->after(function ($validator) {
        if ($this->qty > $this->getStock() && $this->type !== 'PO') {
            $validator->errors()->add('qty', 'Stok tidak mencukupi');
        }
    });
}
```

**Why**: Loss of business logic = production bugs.

---

### ❌ FP.7: Using Generic Exceptions
```php
// NEVER
throw new Exception('Error');  // Generic!

// ALWAYS be specific
throw new \InvalidArgumentException('Detail harus array dengan minimal 1 elemen');
throw new \RuntimeException('Dokumen sudah diotorisasi level 1, tidak dapat diubah');
```

**Why**: Better debugging, clearer error messages.

---

### ❌ FP.8: Editing Authorized Documents
```php
// NEVER allow editing authorized docs
public function update(Request $request, $id) {
    $model = DbXXX::find($id);
    // Missing authorization check!
    $model->update($request->all());
}

// ALWAYS check authorization status
public function update(Request $request, $id) {
    $model = DbXXX::find($id);

    if ($model->IsOtorisasi1 == 1) {
        throw new \Exception('Dokumen sudah diotorisasi');
    }

    $model->update($request->all());
}
```

**Why**: Data integrity, audit trail.

---

## Code Standards

### CS.1: File Naming
```
✅ Correct:
app/Http/Controllers/PenyerahanBhnController.php
app/Services/PPLService.php
app/Policies/AktivaPolicy.php

❌ Wrong:
app/Http/Controllers/penyerahan_bhn_controller.php
app/Services/ppl-service.php
app/Policies/aktivapolicy.php
```

**Rule**: PascalCase for class files.

---

### CS.2: Method Naming
```php
✅ Correct:
public function create()
public function getAvailableSPKItems()
public function authorizeDocument()

❌ Wrong:
public function CreatePPL()  // PascalCase
public function get_spk_items()  // snake_case
public function auth()  // Unclear abbreviation
```

**Rule**: camelCase for methods, descriptive names.

---

### CS.3: Variable Naming
```php
✅ Correct:
$noBukti
$detailData
$maxVisibleLevel

❌ Wrong:
$no_bukti  // snake_case
$d  // Single letter
$temp123  // Meaningless
```

**Rule**: camelCase, descriptive names.

---

### CS.4: Constant Naming
```php
✅ Correct:
const PB_MENU_CODE = '05006';
const MAX_AUTHORIZATION_LEVELS = 5;

❌ Wrong:
const pb_menu_code = '05006';
const menuCode = '05006';
```

**Rule**: UPPER_SNAKE_CASE for constants.

---

### CS.5: Array Syntax
```php
✅ Correct:
$data = [
    'field1' => 'value1',
    'field2' => 'value2',
];

❌ Wrong:
$data = array(
    'field1' => 'value1',
    'field2' => 'value2',
);
```

**Rule**: Use short array syntax [].

---

## Security Rules

### SEC.1: Password Handling
```php
✅ Correct:
// Use Laravel's Hash facade
use Illuminate\Support\Facades\Hash;

$hashedPassword = Hash::make($password);

if (Hash::check($password, $user->password)) {
    // Authenticated
}

❌ Wrong:
$password = md5($password);  // Weak hashing
$password = $request->input('password');  // Plain text
```

---

### SEC.2: Mass Assignment Protection
```php
✅ Correct:
// Use $fillable or $guarded
class DbPPL extends Model {
    protected $fillable = [
        'NOBUKTI',
        'TglBukti',
        'KodeSupplier',
    ];
}

❌ Wrong:
// No protection
DB::table('DBPPL')->insert($request->all());
```

---

### SEC.3: CSRF Protection
```blade
✅ Correct:
<form method="POST" action="/ppl">
    @csrf
    <!-- form fields -->
</form>

❌ Wrong:
<form method="POST" action="/ppl">
    <!-- Missing @csrf -->
</form>
```

---

### SEC.4: XSS Prevention
```blade
✅ Correct:
{{ $user->name }}  <!-- Escaped -->
{{ htmlspecialchars($data) }}

❌ Wrong:
{!! $user->name !!}  <!-- Unescaped! -->
<?= $data ?>  <!-- Unescaped! -->
```

---

### SEC.5: Authorization Layer
```php
✅ Correct:
// Multiple layers
1. Request::authorize()     // First layer
2. Controller authorize()   // Second layer
3. Policy check            // Third layer
4. Service validation      // Fourth layer

❌ Wrong:
// Single point of failure
if ($user->id === 1) {  // Only checking user ID
    // Allow everything
}
```

---

## Testing Rules

### TEST.1: Manual Testing Required
**MUST test ALL operations before deployment**

Checklist:
- [ ] Create document (INSERT mode)
- [ ] Read/view document
- [ ] Update document (UPDATE mode)
- [ ] Delete document (DELETE mode)
- [ ] Authorization workflow (if OL > 0)
- [ ] Permission checks (denied scenarios)
- [ ] Validation errors (all rules)
- [ ] Detail operations (add/edit/delete)
- [ ] Lookup functionality

---

### TEST.2: Database Verification
**MUST verify data in database after operations**

```sql
-- After CREATE
SELECT * FROM DbXXX WHERE NOBUKTI = '...';
SELECT * FROM DbXXXDET WHERE NOBUKTI = '...';

-- Check activity log
SELECT * FROM dbLogFile WHERE NoBukti = '...' ORDER BY TglLog DESC;

-- Check authorization
SELECT IsOtorisasi1, OtoUser1, TglOto1 FROM DbXXX WHERE NOBUKTI = '...';
```

---

### TEST.3: Permission Testing
**MUST test with different user permission levels**

Test Matrix:
- User WITH IsTambah → Can create ✅
- User WITHOUT IsTambah → Cannot create ❌
- User WITH IsKoreksi → Can edit ✅
- User WITHOUT IsKoreksi → Cannot edit ❌
- User WITH IsHapus → Can delete ✅
- User WITHOUT IsHapus → Cannot delete ❌

---

### TEST.4: Edge Case Testing
**SHOULD test boundary conditions**

Examples:
- Empty detail array
- Single detail (for multi-item forms)
- Maximum detail count
- Negative quantities
- Future dates
- Past dates (period lock)
- Duplicate entries
- Non-existent foreign keys

---

## Documentation Rules

### DOC.1: Migration Summary
**MUST create migration summary after completion**

Template location: `.claude/skills/delphi-migration/OBSERVATIONS.md`

```bash
# Use retrospective command
/delphi-retrospective
```

**Required Sections**:
- Basic info (form, date, time, status)
- Patterns detected
- Files generated
- Quality metrics
- What worked well
- Challenges encountered
- Lessons learned

---

### DOC.2: Code Comments
**MUST add comments for complex logic**

```php
✅ Correct:
// Calculate remaining quantity (QntRencana - QntAmbil)
// Delphi: cekBahanSPK function, line 145
$sisaAmbil = $qntRencana - $qntAmbil;

❌ Wrong:
// Calculate
$x = $a - $b;
```

**When to Comment**:
- Complex calculations
- Business rules from Delphi
- Non-obvious logic
- Workarounds

**When NOT to Comment**:
- Self-explanatory code
- Standard CRUD operations

---

### DOC.3: API Documentation
**SHOULD document API endpoints**

```php
/**
 * Get available SPK items for warehouse
 *
 * @param Request $request
 * @return \Illuminate\Http\JsonResponse
 *
 * @queryParam kodegdg string Warehouse code. Example: GDGPWT
 * @queryParam search string Search term. Example: BRG001
 *
 * @response {
 *   "data": [
 *     {
 *       "NOBUKTI": "00001/SPK/PWT/012026",
 *       "KODEBRG": "BRG001",
 *       "NAMABRG": "Barang 1",
 *       "SisaAmbil": 100
 *     }
 *   ]
 * }
 */
public function getAvailableSPKItems(Request $request)
```

---

## Workflow Rules

### WF.1: Approval Gates
**MUST get approval before proceeding to next phase**

**Gate 1**: Before Implementation (Phase 2)
- [ ] User reviewed Phase 0 analysis
- [ ] User approved migration plan
- [ ] User confirmed complexity estimate
- [ ] User agreed on timeline

**Gate 2**: Before Deployment (Phase 5)
- [ ] All tests passed
- [ ] User completed UAT
- [ ] User signed off on quality
- [ ] User approved production deployment

---

### WF.2: Phase Sequence
**MUST NOT skip phases**

Required Sequence:
1. Phase 0: Discovery & Analysis ✅
2. Phase 1: Implementation Planning ✅
3. **[APPROVAL GATE 1]** 🚨
4. Phase 2: Code Generation ✅
5. Phase 3: Testing & Validation ✅
6. Phase 4: Documentation ✅
7. **[APPROVAL GATE 2]** 🚨
8. Phase 5: Deployment ✅

❌ FORBIDDEN: Jump from Phase 0 to Phase 2 (skip planning)
❌ FORBIDDEN: Deploy without testing (skip Phase 3)

---

### WF.3: Version Control
**MUST use git for all changes**

```bash
# After each significant change
git add .
git commit -m "feat(ppl): Add detail validation and error handling

- Add minimum detail validation (min:1)
- Add service-level constraint check
- Improve error messages in Indonesian

Delphi: FrmPPL.pas, line 425-450"

# NEVER commit directly to main
git checkout -b feature/ppl-migration
git push -u origin feature/ppl-migration
```

---

### WF.4: Code Review
**SHOULD request code review before merging**

Review Checklist:
- [ ] All patterns implemented
- [ ] All validations present
- [ ] Authorization checks in place
- [ ] Audit logging added
- [ ] Tests completed
- [ ] Code formatted (Pint)
- [ ] No security vulnerabilities
- [ ] Delphi references included

---

## Enforcement & Validation

### Automated Checks

**Pre-Commit Hooks**:
```bash
# .git/hooks/pre-commit

# 1. Run Pint
./vendor/bin/pint --test || exit 1

# 2. Check for SQL injection
if grep -r "DB::select.*\." app/; then
    echo "ERROR: Potential SQL injection found"
    exit 1
fi

# 3. Check for hardcoded values
if grep -r "05006\|05001" app/ --exclude="*Policy.php"; then
    echo "ERROR: Hardcoded menu codes found"
    exit 1
fi

# 4. Run tests
php artisan test || exit 1
```

---

### Manual Review Checklist

**Before Approval Gate 1**:
- [ ] All Delphi patterns detected (use PATTERN-GUIDE.md)
- [ ] OL configuration verified (SQL query)
- [ ] Dependencies identified (shared units)
- [ ] Complexity assessed (SIMPLE/MEDIUM/COMPLEX)
- [ ] Migration plan reviewed by user

**Before Approval Gate 2**:
- [ ] All modes implemented (I/U/D)
- [ ] All permissions mapped
- [ ] All validations implemented
- [ ] Audit logging present
- [ ] Manual testing completed
- [ ] Database verification done
- [ ] Documentation created
- [ ] User acceptance obtained

---

### Quality Metrics

**Minimum Thresholds**:
| Metric | Threshold | How to Measure |
|--------|-----------|----------------|
| Mode Coverage | 100% | All I/U/D present |
| Permission Coverage | 100% | All IsTambah/IsKoreksi/IsHapus mapped |
| Validation Coverage | ≥95% | All 8 patterns checked |
| Audit Coverage | 100% | All operations logged |
| Code Format | 100% | Pint passes |
| Manual Testing | 100% | All checklist items ✅ |

**Score Calculation**:
```
Quality Score = (Mode + Permission + Validation + Audit + Format + Testing) / 6

Example:
100% + 100% + 95% + 100% + 100% + 100% = 595%
595% / 6 = 99.2/100 ✅ EXCELLENT
```

**Deployment Criteria**:
- ✅ Score ≥ 90/100 → Ready for production
- ⚠️ Score 70-89/100 → Needs improvement
- ❌ Score < 70/100 → REJECT, rework required

---

### Violation Handling

**P0 Violation** (Critical):
- 🚨 Immediate rejection
- 🔴 Cannot proceed to next phase
- ⚠️ Must fix before continuing
- 📝 Document in incident log

**P1 Violation** (Mandatory):
- ⚠️ Major concern raised
- 🟡 Can proceed with plan to fix
- 📋 Must fix before deployment
- 📝 Track in issue log

**P2 Violation** (Recommended):
- ℹ️ Note for improvement
- 🟢 Can proceed
- 💡 Fix in next iteration
- 📝 Track in backlog

---

## Rule Summary Table

| Rule ID | Description | Severity | Compliance |
|---------|-------------|----------|------------|
| **P0.1** | Database Safety (no fresh/reset) | 🔴 Critical | 100% |
| **P0.2** | SQL Injection Prevention | 🔴 Critical | 100% |
| **P0.3** | Transaction Wrapping | 🔴 Critical | 100% |
| **P0.4** | Authorization Enforcement | 🔴 Critical | 100% |
| **P0.5** | OL Configuration Verification | 🔴 Critical | 100% |
| **P1.1** | Mode Coverage (I/U/D) | 🟡 High | ≥95% |
| **P1.2** | Permission Mapping | 🟡 High | ≥95% |
| **P1.3** | Validation Completeness | 🟡 High | ≥95% |
| **P1.4** | Audit Logging | 🟡 High | ≥95% |
| **P1.5** | Detail Line Constraints | 🟡 High | ≥95% |
| **P1.6** | Delphi Reference Comments | 🟡 High | ≥95% |
| **P2.1** | Type Hints | 🟢 Medium | ≥80% |
| **P2.2** | Code Formatting (Pint) | 🟢 Medium | ≥80% |
| **P2.3** | Indonesian Error Messages | 🟢 Medium | ≥80% |
| **P2.4** | Retrospective Documentation | 🟢 Medium | ≥80% |
| **P2.5** | Pre-Migration Advice | 🟢 Medium | ≥80% |

---

## Quick Reference

**Before Starting**:
1. ✅ Read SOP-DELPHI-MIGRATION.md
2. ✅ Run `/delphi-advise`
3. ✅ Verify OL configuration (P0.5)
4. ✅ Check database schema (P0.1)

**During Implementation**:
1. ✅ Use parameter binding (P0.2)
2. ✅ Wrap in transactions (P0.3)
3. ✅ Add authorization (P0.4)
4. ✅ Implement all modes (P1.1)
5. ✅ Map all permissions (P1.2)
6. ✅ Complete all validations (P1.3)
7. ✅ Add audit logging (P1.4)

**Before Deployment**:
1. ✅ Run Pint (P2.2)
2. ✅ Complete manual testing (TEST.1)
3. ✅ Verify database (TEST.2)
4. ✅ Run `/delphi-retrospective` (P2.4)
5. ✅ Get user approval (WF.1)

---

**RULES v1.0** | Compliance is mandatory for production deployment
**Last Updated**: 2026-01-03
**Next Review**: 2026-04-03 (Quarterly)

For questions about rules, refer to SOP-DELPHI-MIGRATION.md or PATTERN-GUIDE.md.
