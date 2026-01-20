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

### TEST.1: 3-Layer Testing Pyramid Required
**MUST test at all 3 layers - Service, Integration, HTTP**

⚠️ **CRITICAL DISCOVERY**: Passing service tests does NOT mean production ready!

**Testing Pyramid**:
```
        ┌─────────────────┐
        │  HTTP Routes    │  ← Most realistic, slowest (5-10% of tests)
        │  Full Requests  │
        ├─────────────────┤
        │ View Rendering  │  ← Integration layer (15-25% of tests)
        │ Controller Flow │
        ├─────────────────┤
        │ Service Layer   │  ← Unit tests, fastest (65-80% of tests)
        │ Business Logic  │
        └─────────────────┘
```

**Why All 3 Matter**:
- ✅ Service tests: Catch business logic bugs
- ✅ Integration tests: Catch view/data binding errors
- ✅ HTTP tests: Catch routing, auth, real-world failures

❌ DON'T: Test only service layer and declare "all pass"
✅ DO: Test all 3 layers, highest-to-lowest priority

**Impact**: Previous missing layer tests cost 1.5 hours to discover and fix

---

### TEST.2: HTTP Route Testing
**MUST test all HTTP endpoints before deployment**

**Test Coverage Required**:
```php
// Test create form rendering
GET /module/create
  → Status: 200
  → View renders without errors
  → Form has correct action="/module/store"

// Test store endpoint
POST /module
  → Valid data: Status 201, created in DB
  → Invalid data: Status 422, validation errors
  → Unauthorized: Status 403, permission denied

// Test edit form rendering
GET /module/{id}/edit
  → Status: 200
  → View renders without errors
  → Form pre-filled with data
  → Form has correct action="/module/{id}"

// Test update endpoint
PUT /module/{id}
  → Valid data: Status 200, updated in DB
  → Invalid data: Status 422, validation errors
  → Authorized document: Status 403, cannot edit

// Test delete endpoint
DELETE /module/{id}
  → Valid: Status 200, deleted from DB
  → With constraint: Status 403, error message
  → Unauthorized: Status 403, permission denied
```

**Pseudo-Test Template**:
```php
// Test HTTP endpoint (full request cycle)
$response = $this->post('/memorial/store', [
    'no_bukti' => '00001/TEST/001',
    'tanggal' => '2026-01-18',
    'divisi_id' => '01',
    'details' => [...]
]);

// Verify HTTP response
$response->assertStatus(201);
$response->assertJson(['success' => true]);

// Verify database
$this->assertDatabaseHas('dbTrans', [
    'NoBukti' => '00001/TEST/001'
]);
```

**Key Points**:
- Test with authenticated user
- Test with different permission levels
- Test valid AND invalid data
- Test redirect URLs
- Verify database state after request

---

### TEST.3: View Rendering Testing
**MUST test all view templates render without null errors**

**Common View Testing Issues**:

**Issue 1: Null Object Access**
```blade
<!-- ❌ WRONG - Fails when $memorial is null -->
<a href="{{ route('memorial.edit', $memorial->no_bukti) }}">Edit</a>

<!-- ✅ CORRECT - Safe with null -->
<a href="{{ route('memorial.edit', $memorial?->no_bukti) }}">Edit</a>
```

**Issue 2: Missing Null-Safe in Ternary**
```blade
<!-- ❌ WRONG - Evaluates false branch even in create mode -->
action="{{ $mode === 'create' ? route('memorial.store') : route('memorial.update', $memorial->no_bukti) }}"

<!-- ✅ CORRECT - Uses null-safe operator -->
action="{{ $mode === 'create' ? route('memorial.store') : route('memorial.update', $memorial?->no_bukti) }}"
```

**Issue 3: Undefined Variables**
```blade
<!-- ❌ WRONG - Missing $errors variable -->
@error('field')
    <div class="error">{{ $message }}</div>
@enderror

<!-- ✅ CORRECT - Provide $errors in view call -->
view('form', ['memorial' => null, 'errors' => new ViewErrorBag()])
```

**View Testing Checklist**:
```php
// Test 1: Create form renders without errors
$view = view('memorial.form', [
    'memorial' => null,
    'mode' => 'create',
    'errors' => new \Illuminate\Support\ViewErrorBag()
]);
$rendered = $view->render();

// Verify
assert(!str_contains($rendered, 'Attempt to read property'));
assert(!str_contains($rendered, 'Undefined variable'));
assert(str_contains($rendered, 'name="no_bukti"'));

// Test 2: Edit form renders with data
$memorial = (object) ['no_bukti' => 'TEST/001', 'tanggal' => now()];
$view = view('memorial.form', [
    'memorial' => $memorial,
    'mode' => 'edit',
    'errors' => new \Illuminate\Support\ViewErrorBag()
]);
$rendered = $view->render();

// Verify data present
assert(str_contains($rendered, 'TEST/001'));
assert(str_contains($rendered, route('memorial.update', 'TEST/001')));
```

**Required Null-Safety Pattern**:
```blade
<!-- Always use ?-> for optional object properties -->
<input value="{{ $memorial?->field ?? old('field') }}">
<input value="{{ $memorial?->date?->format('Y-m-d') ?? old('date') }}">

<!-- Conditionals for optional objects -->
@if ($mode === 'edit' && $memorial?->id)
    <a href="{{ route('memorial.delete', $memorial->id) }}">Delete</a>
@endif
```

---

### TEST.4: Controller Integration Testing
**MUST test controller flow: HTTP → Service → Model → View**

**Integration Test Scope**:
```php
// Full flow test
1. User submits form via HTTP POST
   ↓
2. FormRequest validates data
   ↓
3. Controller authorizes action
   ↓
4. Service creates/updates data
   ↓
5. Database constraint enforced
   ↓
6. Response returned to user
   ↓
7. View renders response
```

**Integration Test Template**:
```php
public function testMemorialCreateFullFlow()
{
    // Arrange
    $user = User::where('username', 'sa')->first();
    $this->actingAs($user, 'trade2exchange');

    $data = [
        'no_bukti' => 'TEST/001/2026',
        'tanggal' => '2026-01-18',
        'divisi_id' => '01',
        'details' => [
            [
                'perkiraan' => '1111.1',
                'lawan' => '2101.1',
                'debet' => 1000000,
                'kredit' => 0,
                'valas' => 'IDR',
                'kurs' => 1
            ]
        ]
    ];

    // Act
    $response = $this->post(route('memorial.store'), $data);

    // Assert - HTTP layer
    $response->assertStatus(201);
    $response->assertJson(['success' => true]);

    // Assert - Database layer
    $this->assertDatabaseHas('dbTrans', [
        'NoBukti' => 'TEST/001/2026'
    ]);

    $this->assertDatabaseHas('dbTransaksi', [
        'NoBukti' => 'TEST/001/2026',
        'Urut' => 1
    ]);

    // Assert - View layer
    $response = $this->get(route('memorial.edit', 'TEST/001/2026'));
    $response->assertStatus(200);
    $response->assertViewHas('memorial');
    $response->assertDontSee('Attempt to read property'); // No errors
}
```

**Integration Test Checklist**:
- [ ] HTTP endpoint reachable (correct route, status code)
- [ ] Request validation works (valid + invalid data)
- [ ] Authorization enforced (auth + permission checks)
- [ ] Data persisted correctly (database state verified)
- [ ] No null reference errors in response
- [ ] View renders without exceptions
- [ ] Error messages appear for invalid data
- [ ] Redirect URLs correct (after create/update)
- [ ] Authorization headers required (401 if missing)
- [ ] Permission checks work (403 if unauthorized)

---

### TEST.5: Error Scenario Testing
**MUST test all error paths, not just happy path**

**Required Error Tests**:
```php
// Test 1: Missing required field
POST /memorial
Data: { no_bukti: '', tanggal: '...' }
Expected: 422 Validation Error
  Message: "No. Bukti wajib diisi"

// Test 2: Invalid foreign key
POST /memorial
Data: { no_bukti: '...', divisi_id: '999' } // Invalid divisi
Expected: 422 Validation Error
  Message: "Divisi tidak valid"

// Test 3: Unbalanced debet/kredit
POST /memorial
Data: { details: [{ debet: 100, kredit: 50 }] }
Expected: 422 Validation Error
  Message: "Debet dan Kredit tidak seimbang"

// Test 4: Null object in view
GET /memorial/create
Data: memorial = null
Expected: 200 OK (form renders)
NOT Expected: "Attempt to read property on null"

// Test 5: Unauthorized access
POST /memorial
Auth: User without IsTambah permission
Expected: 403 Forbidden

// Test 6: Period locked
POST /memorial
Data: { tanggal: '2025-01-15' } (period locked)
Expected: 422 Validation Error
  Message: "Periode telah terkunci"
```

---

### TEST.6: Null Safety Testing
**MUST test all scenarios with null objects**

**Why This Matters**:
```
❌ Test ONLY with full objects
  → Misses null reference errors
  → Production breaks on create/new forms

✅ Test WITH null objects
  → Catches view rendering errors
  → Prevents "Attempt to read property on null"
```

**Null Test Checklist**:
```php
// Test create form with null memorial
$view = view('form', ['memorial' => null, 'mode' => 'create']);
$rendered = $view->render();
assert(!str_contains($rendered, 'Attempt to read property'));

// Test with empty details array
$memorial = (object) ['details' => []];
$view = view('form', ['memorial' => $memorial]);
$rendered = $view->render();
assert(!str_contains($rendered, 'Attempt to read property'));

// Test with partial object
$memorial = (object) ['no_bukti' => 'TEST'];  // Missing tanggal
$view = view('form', ['memorial' => $memorial]);
$rendered = $view->render();
assert(!str_contains($rendered, 'Attempt to read property'));

// Test with missing optional fields
$memorial = (object) ['no_bukti' => 'TEST'];
assert(null === $memorial->keterangan ?? null); // Safe access
```

---

### TEST.7: Manual Testing Checklist
**MUST test ALL operations before deployment**

Checklist:
- [ ] **Create Operation**
  - [ ] Form loads without errors (GET /create)
  - [ ] Form submits successfully (POST)
  - [ ] Validation errors display (invalid data)
  - [ ] Data saved to database
  - [ ] Redirect to edit form
  - [ ] Activity logged

- [ ] **Read/View Operation**
  - [ ] Document loads (GET /show/{id})
  - [ ] All fields display
  - [ ] No null reference errors
  - [ ] Details render correctly

- [ ] **Update Operation**
  - [ ] Edit form loads (GET /edit/{id})
  - [ ] Form pre-filled with data
  - [ ] Submit updates data
  - [ ] Validation works
  - [ ] Details updated correctly
  - [ ] Activity logged

- [ ] **Delete Operation**
  - [ ] Delete button appears
  - [ ] Confirmation dialog shows
  - [ ] Record deleted from database
  - [ ] Details deleted cascade
  - [ ] Activity logged

- [ ] **Authorization**
  - [ ] User WITH permission: ✅ Can perform action
  - [ ] User WITHOUT permission: ❌ Cannot perform action
  - [ ] 403 error displays
  - [ ] Error message clear

- [ ] **Validation**
  - [ ] Required fields validated
  - [ ] Invalid formats rejected
  - [ ] Error messages in Indonesian
  - [ ] Form sticky (data preserved)

- [ ] **Database Integrity**
  - [ ] Primary keys correct
  - [ ] Foreign keys valid
  - [ ] NOT NULL constraints satisfied
  - [ ] Audit log created

---

### TEST.8: Database Verification
**MUST verify data in database after operations**

```sql
-- After CREATE
SELECT * FROM dbTrans WHERE NoBukti = '00001/TEST/001';
SELECT * FROM dbTransaksi WHERE NoBukti = '00001/TEST/001' ORDER BY Urut;

-- Verify structure
  ✅ dbTrans.NoBukti = primary key
  ✅ dbTransaksi.(NoBukti, Urut) = composite primary key
  ✅ No NULL values in NOT NULL columns
  ✅ All Urut values sequential (1, 2, 3, ...)
  ✅ Foreign keys reference valid records

-- Check activity log
SELECT * FROM dbLogFile
WHERE NoBukti = '00001/TEST/001'
ORDER BY TglLog DESC;
```

---

### TEST.9: Permission Testing Matrix
**SHOULD test with different permission levels**

| Permission | Create | Read | Update | Delete |
|------------|--------|------|--------|--------|
| IsTambah=1 | ✅ YES | ✅ YES | ❌ NO | ❌ NO |
| IsKoreksi=1 | ❌ NO | ✅ YES | ✅ YES | ❌ NO |
| IsHapus=1 | ❌ NO | ✅ YES | ❌ NO | ✅ YES |
| None=0 | ❌ NO | ✅ YES | ❌ NO | ❌ NO |

---

### TEST.10: Feature Test Authentication (Trade2Exchange Apps)
**MUST use correct guard and User model for feature tests in Trade2Exchange apps**

⚠️ **CRITICAL**: Wrong authentication setup causes 401 errors and test failures!

**Correct Pattern for Trade2Exchange Apps**:
```php
namespace Tests\Feature\Memorial;

use App\Models\Trade2Exchange\User;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Tests\TestCase;

class MemorialFeatureTest extends TestCase
{
    use DatabaseTransactions;

    protected string $guard = 'trade2exchange';  // ← CRITICAL: Specify guard
    protected $user;

    protected function setUp(): void
    {
        parent::setUp();

        // Disable CSRF for feature tests
        $this->withoutMiddleware(\App\Http\Middleware\VerifyCsrfToken::class);

        // Create test user
        $userId = 'TESTUSER_' . time();
        try {
            DB::table('DBFLPASS')->insert([
                'USERID' => $userId,
                'UID2' => '0test01',
                'FullName' => 'Test User',
                'TINGKAT' => 1,
                'STATUS' => 1,
                'HOSTID' => 'LOCALHOST',
                'IPAddres' => '127.0.0.1',
                'kodeBag' => 'BAG',
                'KodeJab' => 'JB',
                'KodeKasir' => 'KS',
                'Kodegdg' => 'GDG',
                'keynik' => 9999,
            ]);
        } catch (\Exception $e) {
            $this->markTestSkipped('DBFLPASS table missing: ' . $e->getMessage());
        }

        // Load user
        $this->user = User::where('USERID', $userId)->first();

        // Add menu permissions for module (e.g., Memorial = '02004')
        DB::table('DBFLMENU')->insert([
            'USERID' => $userId,
            'L1' => '02004',  // Menu code
            'HASACCESS' => 1,
            'ADD_FL' => 'T',
            'EDIT_FL' => 'T',
            'DEL_FL' => 'T',
            'PRINT_FL' => 'T',
            'EXPORT_FL' => 'T',
        ]);
    }

    public function test_create_memorial(): void
    {
        // ← CRITICAL: Use actingAs with guard parameter
        $response = $this->actingAs($this->user, $this->guard)
            ->postJson('/memorial', [
                'no_bukti' => 'TEST/001',
                'tanggal' => now(),
                'divisi_id' => '01',
                'details' => [...]
            ]);

        $response->assertStatus(201);
    }
}
```

**What Goes Wrong Without Correct Guard**:
```php
// ❌ WRONG - Uses wrong guard
$this->actingAs($this->user)->postJson(...)
// Result: 401 Unauthorized

// ❌ WRONG - Forgets guard entirely
$this->postJson(...)
// Result: 401 Unauthorized

// ✅ CORRECT - Uses trade2exchange guard
$this->actingAs($this->user, $this->guard)->postJson(...)
// Result: Works correctly
```

**Required Setup for Feature Tests**:
1. **User Model**: Must use `App\Models\Trade2Exchange\User` (NOT `App\Models\User`)
2. **Guard**: Must specify `'trade2exchange'` guard
3. **DBFLPASS Table**: Required in test database (user credentials)
4. **DBFLMENU Table**: Required for permission checks
5. **Menu Code**: Must match actual code (e.g., '02004' for Memorial)
6. **Permissions**: Set ADD_FL, EDIT_FL, DEL_FL, etc. to 'T'

**Common Issues & Solutions**:

| Issue | Cause | Solution |
|-------|-------|----------|
| 401 Unauthorized | Missing guard parameter | Add `$this->guard` to `actingAs()` |
| DBFLPASS table missing | Test environment incomplete | Run TEST-SETUP.md instructions |
| User "has no menu access" | Wrong menu code | Check MENU-CODES.md for correct code |
| Permission denied (403) | Menu permission not inserted | Insert record in DBFLMENU |
| KODELEVEL mismatch | User level doesn't match menu level | Verify KODELEVEL in both tables |

**Testing Checklist**:
- [ ] Using Trade2Exchange\User model
- [ ] Specified 'trade2exchange' guard in setUp()
- [ ] Called actingAs($user, $guard) in test method
- [ ] DBFLPASS record created for test user
- [ ] DBFLMENU record created with permissions
- [ ] Menu code matches actual module code
- [ ] Permission flags set to 'T' for test
- [ ] Test runs without 401 errors

**References**:
- See `MENU-CODES.md` for all menu codes
- See `TEST-SETUP.md` for environment setup
- See `tests/Feature/ArusKas/ArusKasManagementTest.php` for working example
- See `tests/Feature/Memorial/*.php` for Memorial module examples

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
