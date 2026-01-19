# Standard Operating Procedure: Delphi to Laravel Migration

**Document Version**: 1.0
**Last Updated**: 2026-01-03
**Status**: Production Ready
**Purpose**: Complete guide for migrating Delphi 6 VCL forms to Laravel 12

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Migration Phases](#migration-phases)
4. [Pattern Detection & Implementation](#pattern-detection--implementation)
5. [Quality Assurance](#quality-assurance)
6. [Troubleshooting](#troubleshooting)
7. [Best Practices](#best-practices)
8. [Appendix](#appendix)

---

## Overview

### Purpose

This SOP provides a step-by-step process for migrating Delphi 6 VCL business applications to modern Laravel 12, preserving **100% of business logic**, permissions, validation rules, and audit trails.

### Scope

**In Scope**:
- Delphi VCL forms (.pas, .dfm files)
- Business logic migration (Choice:Char patterns)
- Permission mapping (IsTambah, IsKoreksi, IsHapus)
- Validation rule translation (8 patterns)
- Audit logging (LoggingData → AuditLog)
- Authorization workflows (OL-based)
- Master-detail forms
- Lookup dependencies

**Out of Scope**:
- Database schema migration (tables already exist)
- Third-party Delphi components
- Complex SQL stored procedures (manual review required)
- UI/UX redesign (replicates Delphi behavior)

### Success Criteria

A migration is considered **successful** when:
- ✅ **100% Mode Coverage** - All I/U/D logic identified and implemented
- ✅ **100% Permission Coverage** - All permission checks mapped to Laravel
- ✅ **95%+ Validation Coverage** - All 8 validation patterns detected
- ✅ **100% Audit Coverage** - All LoggingData calls preserved
- ✅ **<5% Manual Work** - Generated code is production-ready with minimal adjustments

### Time Estimates by Complexity

| Complexity | Characteristics | Estimated Time |
|------------|----------------|----------------|
| 🟢 **SIMPLE** | Basic CRUD, single form, no complex logic | 2-4 hours |
| 🟡 **MEDIUM** | Master-detail, business rules, 2-3 lookups | 4-8 hours |
| 🔴 **COMPLEX** | Multiple forms, algorithms, stock impact, 5+ lookups | 8-12 hours |

---

## Prerequisites

### Before Starting ANY Migration

#### 1. Read Project Documentation (20 minutes)
```bash
# Core references
cat CLAUDE.md
cat .claude/commands/delphi-laravel-migration.md
cat .claude/skills/delphi-migration/RIGOROUS_LOGIC_MIGRATION.md
```

#### 2. Identify Module Details
- [ ] Delphi source files location: `d:\ykka\migrasi\pwt\`
- [ ] Module name (e.g., "Penyerahan Bahan")
- [ ] Module code (e.g., "PB", "PPL", "PO")
- [ ] Tables involved (check `app/Models/Db*.php`)
- [ ] Dependencies (check `MyProcedure.pas` for shared code)

#### 3. Verify Database Tables Exist
```sql
-- Check tables in SQL Server
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME LIKE 'Db%';

-- Verify models exist
ls app/Models/Db*.php | grep -i "yourmodule"
```

#### 4. Determine Complexity Level
Use this checklist:

**SIMPLE (🟢 2-4h)**:
- [ ] Single form only
- [ ] Basic CRUD operations
- [ ] <500 lines of Delphi code
- [ ] No master-detail
- [ ] 0-1 lookups
- [ ] No stock/inventory impact

**MEDIUM (🟡 4-8h)**:
- [ ] 1-2 forms
- [ ] Master-detail relationship
- [ ] 500-1500 lines of Delphi code
- [ ] 2-3 lookups
- [ ] Business validation rules
- [ ] Some calculations

**COMPLEX (🔴 8-12h)**:
- [ ] 3+ forms
- [ ] Multiple master-detail levels
- [ ] >1500 lines of Delphi code
- [ ] 5+ lookups
- [ ] Complex algorithms
- [ ] Stock/inventory impact
- [ ] Multi-level authorization (OL=3-5)

#### 5. Get Pre-Migration Advice
```bash
claude
> /delphi-advise
> "I want to migrate FrmXXXX to Laravel"

# Review recommendations:
# - Similar forms migrated
# - Expected patterns
# - Known issues
# - Time estimate
```

---

## Migration Phases

### Phase 0: Discovery & Analysis (2-3 hours)

**Objective**: Understand the Delphi form completely before writing any code.

#### Step 1: Read Source Files
```bash
# Open files in editor
code d:/ykka/migrasi/pwt/path/to/FrmModule.pas
code d:/ykka/migrasi/pwt/path/to/FrmModule.dfm
code d:/ykka/migrasi/pwt/path/to/FrmMainModule.pas  # if exists
```

#### Step 2: Document Form Analysis
Create analysis document:
```markdown
## Form: FrmXXXX

### Basic Info
- **Lines of Code**: XXX
- **Complexity**: SIMPLE/MEDIUM/COMPLEX
- **Tables**: List all tables
- **Dependencies**: List shared units

### Patterns Detected
- [ ] Pattern 1: Mode Operations (Choice:Char)
- [ ] Pattern 2: Permission Checks
- [ ] Pattern 3: Field Dependencies
- [ ] Pattern 4: Validation Rules

### Key Procedures
List all procedures/functions with line numbers

### Lookups & Dependencies
List all lookup forms and field dependencies
```

#### Step 3: Extract Key Information

**A. Find Mode-Based Procedure**
```pascal
// Look for:
Procedure TFrmXXX.UpdateDataXXX(Choice:Char);

// Or similar:
Procedure TFrmXXX.SaveData(Mode:String);
```

**B. Identify Permission Variables**
```pascal
// Usually in form declaration:
IsTambah: Boolean;
IsKoreksi: Boolean;
IsHapus: Boolean;
IsCetak: Boolean;
IsExcel: Boolean;
```

**C. Map Database Tables**
```pascal
// Look for table names in queries:
QuView.SQL.Text := 'SELECT * FROM dbTableName';
sp_procedure.Parameters[X].Value := ...;
```

**D. Identify Validation Logic**
```pascal
// Look for:
if FieldX.Text = '' then ShowMessage(...);
if QuTable.Locate(...) then ShowMessage(...);
if Value < MinValue then raise Exception.Create(...);
```

**E. Find Audit Logging**
```pascal
// Look for:
LoggingData(IDUser, Choice, 'Module', NoBukti, Keterangan);
```

#### Step 4: Check Authorization Configuration
```sql
-- Query DBMENU to get OL (Organization Level)
SELECT L1, KODEMENU, NAMA, OL
FROM DBMENU
WHERE L1 = 'XX' AND KODEMENU = 'XXXX';

-- Example: PB module
-- L1='05', KODEMENU='05006', NAMA='Penyerahan Bahan', OL='2'
```

**Important**: OL determines authorization levels:
- OL=1 → Single-level authorization
- OL=2 → Two-level (PPL, PB)
- OL=3 → Three-level (PO)
- OL=5 → Five-level (complex modules)

#### Step 5: Create Migration Plan
Use template:
```markdown
## Migration Plan: [Module Name]

### Estimated Time: X-Y hours

### Files to Generate
1. Controller: app/Http/Controllers/XXXController.php
2. Service: app/Services/XXXService.php
3. Requests:
   - app/Http/Requests/XXX/StoreXXXRequest.php
   - app/Http/Requests/XXX/UpdateXXXRequest.php
   - app/Http/Requests/XXX/DeleteXXXRequest.php (if needed)
4. Policy: app/Policies/XXXPolicy.php
5. Views:
   - resources/views/xxx/index.blade.php
   - resources/views/xxx/create.blade.php
   - resources/views/xxx/edit.blade.php
   - resources/views/xxx/show.blade.php
6. Routes: routes/web.php (add XXX routes)

### Pattern Implementation
- Pattern 1: [Details]
- Pattern 2: [Details]
- Pattern 3: [Details]
- Pattern 4: [Details]

### Risks & Mitigations
- [List potential issues]
```

**🚨 APPROVAL GATE**: Get user approval before proceeding to Phase 1.

---

### Phase 1: Implementation Planning (1-2 hours)

**Objective**: Create detailed implementation specifications.

#### Step 1: Design Service Layer

Map each Delphi procedure to Laravel service method:

```php
// app/Services/XXXService.php

class XXXService
{
    // Choice='I' → create()
    public function create(array $data): ModelName
    {
        // INSERT logic from Delphi
    }

    // Choice='U' → update()
    public function update(string $id, array $data): ModelName
    {
        // UPDATE logic from Delphi
    }

    // Choice='D' → delete()
    public function delete(string $id): bool
    {
        // DELETE logic from Delphi
    }

    // Other business methods...
}
```

#### Step 2: Design Controller Methods

```php
// app/Http/Controllers/XXXController.php

class XXXController extends Controller
{
    public function __construct(
        protected XXXService $service,
        protected AuthorizationService $authService,
        protected MenuAccessService $menuAccessService
    ) {}

    public function index() { /* List view */ }
    public function create() { /* Create form */ }
    public function store(StoreXXXRequest $request) { /* Save new */ }
    public function show($id) { /* Detail view */ }
    public function edit($id) { /* Edit form */ }
    public function update(UpdateXXXRequest $request, $id) { /* Save changes */ }
    public function destroy($id) { /* Delete */ }
}
```

#### Step 3: Design Request Validation

For **each mode** (I/U/D), create separate request class:

```php
// INSERT mode
class StoreXXXRequest extends FormRequest
{
    public function authorize(): bool
    {
        // Check IsTambah permission
        return $this->menuAccessService->canCreate(...);
    }

    public function rules(): array
    {
        return [
            // All INSERT validations from Delphi
            'field1' => 'required|...',
            'field2' => 'unique:table,field',
        ];
    }
}

// UPDATE mode
class UpdateXXXRequest extends FormRequest
{
    public function authorize(): bool
    {
        // Check IsKoreksi permission
        return $this->menuAccessService->canUpdate(...);
    }

    public function rules(): array
    {
        return [
            // All UPDATE validations from Delphi
            // Some fields may be immutable
        ];
    }
}
```

#### Step 4: Design Views

Plan all 5 blade templates:

1. **index.blade.php**: List with filters, search, pagination
2. **create.blade.php**: Form for new entry
3. **edit.blade.php**: Form for updating
4. **show.blade.php**: Read-only detail view
5. **print.blade.php** (optional): Printable document

---

### Phase 2: Code Generation (4-6 hours)

**Objective**: Write all Laravel code implementing the planned design.

#### Step 1: Generate Models (if needed)
```bash
# Usually models already exist (Db*.php)
# Verify relationships
```

#### Step 2: Generate Service Layer

**Template** (copy from existing PPLService.php or PenyerahanBhnService.php):

```php
<?php

namespace App\Services;

use App\Models\DbXXX;
use App\Models\DbXXXDET;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class XXXService
{
    /**
     * Create new XXX document
     * Delphi: FrmXXX.pas, UpdateDataXXX(Choice:Char), Choice='I'
     */
    public function create(array $headerData, array $detailData): DbXXX
    {
        return DB::transaction(function () use ($headerData, $detailData) {
            // 1. Validate business rules
            $this->validateCreate($headerData, $detailData);

            // 2. Generate document number
            $noBukti = $this->generateDocumentNumber($headerData);

            // 3. Create header
            $header = DbXXX::create([
                'NOBUKTI' => $noBukti,
                // ... other fields from Delphi INSERT
            ]);

            // 4. Create details
            foreach ($detailData as $index => $detail) {
                DbXXXDET::create([
                    'NOBUKTI' => $noBukti,
                    'NoUrut' => $index + 1,
                    // ... other fields
                ]);
            }

            // 5. Log activity (LoggingData equivalent)
            $this->logActivity('I', $noBukti, $headerData);

            return $header->fresh();
        });
    }

    /**
     * Update existing XXX document
     * Delphi: FrmXXX.pas, UpdateDataXXX(Choice:Char), Choice='U'
     */
    public function update(string $noBukti, array $headerData, array $detailData): DbXXX
    {
        return DB::transaction(function () use ($noBukti, $headerData, $detailData) {
            // 1. Validate business rules
            $header = DbXXX::where('NOBUKTI', $noBukti)->firstOrFail();
            $this->validateUpdate($header, $headerData);

            // 2. Update header
            $header->update($headerData);

            // 3. Update details (delete old, insert new pattern)
            DbXXXDET::where('NOBUKTI', $noBukti)->delete();
            foreach ($detailData as $index => $detail) {
                DbXXXDET::create([
                    'NOBUKTI' => $noBukti,
                    'NoUrut' => $index + 1,
                    // ... other fields
                ]);
            }

            // 4. Log activity
            $this->logActivity('U', $noBukti, $headerData);

            return $header->fresh();
        });
    }

    /**
     * Delete XXX document
     * Delphi: FrmXXX.pas, UpdateDataXXX(Choice:Char), Choice='D'
     */
    public function delete(string $noBukti): bool
    {
        return DB::transaction(function () use ($noBukti) {
            // 1. Validate can delete
            $header = DbXXX::where('NOBUKTI', $noBukti)->firstOrFail();
            $this->validateDelete($header);

            // 2. Delete details first
            DbXXXDET::where('NOBUKTI', $noBukti)->delete();

            // 3. Delete header
            $deleted = $header->delete();

            // 4. Log activity
            $this->logActivity('D', $noBukti, []);

            return $deleted;
        });
    }

    /**
     * Validation methods
     */
    protected function validateCreate(array $headerData, array $detailData): void
    {
        // Business rules from Delphi
        // e.g., Check period lock, check stock availability, etc.
    }

    protected function validateUpdate(DbXXX $header, array $headerData): void
    {
        // Cannot update if authorized
        if ($header->IsOtorisasi1 == 1) {
            throw new \Exception('Dokumen sudah diotorisasi, tidak dapat diubah');
        }

        // Other business rules
    }

    protected function validateDelete(DbXXX $header): void
    {
        // Cannot delete if authorized
        if ($header->IsOtorisasi1 == 1) {
            throw new \Exception('Dokumen sudah diotorisasi, tidak dapat dihapus');
        }

        // Other business rules
    }

    /**
     * Log activity (LoggingData equivalent)
     */
    protected function logActivity(string $mode, string $noBukti, array $data): void
    {
        Log::channel('activity')->info("XXX {$mode}", [
            'user_id' => auth()->id(),
            'mode' => $mode,
            'nobukti' => $noBukti,
            'data' => $data,
        ]);
    }
}
```

#### Step 3: Generate Controllers

Use existing pattern from PPLController.php or PenyerahanBhnController.php.

Key points:
- Inject services in constructor
- Thin controllers (business logic in service)
- Proper authorization checks
- Return views or JSON responses

#### Step 4: Generate Request Classes

**Critical**: One request class per mode.

```php
// app/Http/Requests/XXX/StoreXXXRequest.php
class StoreXXXRequest extends FormRequest
{
    public function authorize(): bool
    {
        // IsTambah permission check
        $menuAccess = app(MenuAccessService::class);
        return $menuAccess->canCreate(
            auth()->user(),
            'MODULE_CODE',
            'MENU_L1_CODE'
        );
    }

    public function rules(): array
    {
        return [
            // Map ALL Delphi validations for INSERT mode
            'field1' => 'required|string|max:50',
            'field2' => 'required|date',
            'field3' => 'required|numeric|min:0',
            'field4' => 'required|exists:dbtable,FIELD',
            'details' => 'required|array|min:1',
            'details.*.kodebrg' => 'required|exists:dbbarang,KODEBRG',
            'details.*.qnt' => 'required|numeric|min:0.01',
        ];
    }

    public function messages(): array
    {
        return [
            // User-friendly messages in Indonesian
            'field1.required' => 'Field 1 harus diisi',
            'details.min' => 'Minimal harus ada 1 baris detail',
        ];
    }
}
```

#### Step 5: Generate Policy Classes

```php
// app/Policies/XXXPolicy.php
class XXXPolicy
{
    public function viewAny(User $user): bool
    {
        // Can view list
        return true;
    }

    public function view(User $user, DbXXX $model): bool
    {
        // Can view detail
        return true;
    }

    public function create(User $user): bool
    {
        // IsTambah permission
        return app(MenuAccessService::class)->canCreate($user, 'MODULE', 'L1_CODE');
    }

    public function update(User $user, DbXXX $model): bool
    {
        // IsKoreksi permission
        return app(MenuAccessService::class)->canUpdate($user, 'MODULE', 'L1_CODE');
    }

    public function delete(User $user, DbXXX $model): bool
    {
        // IsHapus permission
        return app(MenuAccessService::class)->canDelete($user, 'MODULE', 'L1_CODE');
    }
}
```

#### Step 6: Generate Views

Use Bootstrap 5 + existing layout (`trade2exchange/layouts/app.blade.php`).

**Key patterns**:
- Modals for lookups
- AJAX for dynamic field dependencies
- Inline editing for details
- Authorization status display

Copy structure from existing views (ppl/, penyerahan-bhn/).

#### Step 7: Add Routes

```php
// routes/web.php
Route::prefix('module-name')->name('module-name.')->group(function () {
    Route::get('/', [XXXController::class, 'index'])->name('index');
    Route::get('/create', [XXXController::class, 'create'])->name('create');
    Route::post('/', [XXXController::class, 'store'])->name('store');
    Route::get('/{nobukti}', [XXXController::class, 'show'])
        ->where('nobukti', '\d{5}\/[A-Z]{2,}\/[A-Z]{2,}\/\d{6}')
        ->name('show');
    Route::get('/{nobukti}/edit', [XXXController::class, 'edit'])
        ->where('nobukti', '\d{5}\/[A-Z]{2,}\/[A-Z]{2,}\/\d{6}')
        ->name('edit');
    Route::put('/{nobukti}', [XXXController::class, 'update'])
        ->where('nobukti', '\d{5}\/[A-Z]{2,}\/[A-Z]{2,}\/\d{6}')
        ->name('update');
    Route::delete('/{nobukti}', [XXXController::class, 'destroy'])
        ->where('nobukti', '\d{5}\/[A-Z]{2,}\/[A-Z]{2,}\/\d{6}')
        ->name('destroy');
});
```

#### Step 8: Register Menu

Add to sidebar in `resources/views/trade2exchange/layouts/app.blade.php`:

```html
<li class="nav-item">
    <a class="nav-link" href="{{ route('module-name.index') }}">
        <i class="nav-icon fas fa-icon"></i>
        <p>Module Name</p>
    </a>
</li>
```

---

### Phase 3: Testing & Validation (3-5 hours)

**Objective**: Verify all features work correctly.

#### Step 1: Syntax Validation
```bash
# Check PHP syntax
php -l app/Http/Controllers/XXXController.php
php -l app/Services/XXXService.php

# Check Blade syntax
php artisan view:cache

# Run code formatter
./vendor/bin/pint
```

#### Step 2: Route Testing
```bash
# List all routes
php artisan route:list | grep "module-name"

# Test route access
curl http://127.0.0.1:8000/module-name
```

#### Step 3: Manual Feature Testing

Create test checklist:

**Create Flow**:
- [ ] Can access create form
- [ ] Form shows all fields
- [ ] Lookups work (modal opens, search works, selection works)
- [ ] Validation shows errors correctly
- [ ] Can save new document
- [ ] Document number generated correctly
- [ ] Details saved correctly
- [ ] Activity logged to database

**Read Flow**:
- [ ] Index page shows list
- [ ] Search/filter works
- [ ] Pagination works
- [ ] Can view detail page
- [ ] All fields displayed correctly
- [ ] Authorization status shown correctly

**Update Flow**:
- [ ] Can access edit form
- [ ] Form pre-filled with existing data
- [ ] Can modify fields
- [ ] Can add/edit/delete detail lines
- [ ] Validation works
- [ ] Changes saved correctly
- [ ] Cannot edit if authorized (if applicable)

**Delete Flow**:
- [ ] Delete button appears
- [ ] Confirmation dialog works
- [ ] Delete succeeds
- [ ] Details deleted (cascading)
- [ ] Cannot delete if authorized (if applicable)

**Authorization Flow** (if OL > 0):
- [ ] Authorization buttons appear for correct levels
- [ ] Can authorize at each level
- [ ] User and timestamp recorded
- [ ] Cannot skip levels (L2 requires L1 first)
- [ ] Can cancel authorization
- [ ] Cannot edit/delete after authorization

**Permission Testing**:
- [ ] User without IsTambah cannot create
- [ ] User without IsKoreksi cannot edit
- [ ] User without IsHapus cannot delete
- [ ] Proper error messages shown

#### Step 4: Database Verification
```sql
-- Check data created correctly
SELECT * FROM DbXXX WHERE NOBUKTI = '...';
SELECT * FROM DbXXXDET WHERE NOBUKTI = '...';

-- Check activity log
SELECT * FROM dbLogFile WHERE NoBukti = '...' ORDER BY TglLog DESC;

-- Check authorization fields
SELECT NOBUKTI, IsOtorisasi1, OtoUser1, TglOto1 FROM DbXXX;
```

#### Step 5: Automated Testing (Optional but Recommended)

Create feature tests:

```php
// tests/Feature/XXX/XXXCRUDTest.php
class XXXCRUDTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_create_xxx()
    {
        $user = User::factory()->create();
        $this->actingAs($user);

        $data = [
            'field1' => 'value1',
            'details' => [
                ['kodebrg' => 'BRG001', 'qnt' => 10],
            ],
        ];

        $response = $this->post(route('module-name.store'), $data);

        $response->assertRedirect();
        $this->assertDatabaseHas('DbXXX', [
            'field1' => 'value1',
        ]);
    }
}
```

---

### Phase 4: Documentation (1-2 hours)

**Objective**: Document the migration for future reference.

#### Step 1: Create Migration Summary

File: `.claude/skills/delphi-migration/[MODULE]_MIGRATION_SUMMARY.md`

```markdown
# [Module Name] Migration Summary

**Date**: YYYY-MM-DD
**Status**: ✅ Success
**Time Taken**: X hours

## Overview
- **Delphi Files**: List .pas and .dfm files
- **Lines of Code**: XXX (Delphi) → XXX (Laravel)
- **Complexity**: SIMPLE/MEDIUM/COMPLEX

## Files Generated
List all Laravel files created

## Patterns Implemented
- Pattern 1: Mode Operations - ✅
- Pattern 2: Permissions - ✅
- Pattern 3: Field Dependencies - ✅
- Pattern 4: Validation - ✅

## Quality Metrics
- Mode Coverage: 100%
- Permission Coverage: 100%
- Validation Coverage: XX%
- Audit Coverage: 100%

## Issues Encountered
List any issues and solutions

## Lessons Learned
Key takeaways from this migration
```

#### Step 2: Update OBSERVATIONS.md

Run retrospective:
```bash
> /delphi-retrospective
```

This will automatically document:
- Session details
- What worked well
- Challenges encountered
- New patterns discovered
- Improvements needed
- Lessons learned

---

### Phase 5: Deployment (Variable)

**Objective**: Deploy to production safely.

#### Step 1: Code Review
- [ ] All code follows PSR-12 (Pint formatted)
- [ ] No hardcoded values
- [ ] Proper type hints
- [ ] Comments include Delphi references
- [ ] No security vulnerabilities

#### Step 2: Database Verification
```sql
-- Verify DBMENU entry exists
SELECT * FROM DBMENU WHERE KODEMENU = 'XXXX';

-- Verify DBFLMENU permissions exist
SELECT * FROM DBFLMENU WHERE L1 = 'XX' AND KodeMenu = 'XXXX';
```

#### Step 3: User Acceptance Testing (UAT)
- [ ] User tests create flow
- [ ] User tests edit flow
- [ ] User tests delete flow
- [ ] User tests authorization flow
- [ ] User tests search/filter
- [ ] User tests print/export

#### Step 4: Production Deployment
```bash
# Clear caches
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Optimize for production
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

#### Step 5: Post-Deployment Monitoring
- [ ] Check error logs
- [ ] Monitor user activity
- [ ] Verify performance
- [ ] Collect user feedback

---

## Pattern Detection & Implementation

### Pattern 1: Mode-Based Operations (Choice:Char)

**Delphi Detection**:
```pascal
Procedure TFrmXXX.UpdateDataXXX(Choice:Char);
begin
  if Choice='I' then
    // INSERT logic
  else if Choice='U' then
    // UPDATE logic
  else if Choice='D' then
    // DELETE logic
end;
```

**Laravel Implementation**:
```php
// Service Layer
class XXXService
{
    public function create(array $data): Model
    {
        // INSERT logic (Choice='I')
    }

    public function update(string $id, array $data): Model
    {
        // UPDATE logic (Choice='U')
    }

    public function delete(string $id): bool
    {
        // DELETE logic (Choice='D')
    }
}

// Controller Layer
class XXXController extends Controller
{
    public function store(StoreXXXRequest $request)
    {
        $result = $this->service->create($request->validated());
        return redirect()->route('xxx.show', $result->id);
    }

    public function update(UpdateXXXRequest $request, $id)
    {
        $result = $this->service->update($id, $request->validated());
        return redirect()->route('xxx.show', $id);
    }

    public function destroy($id)
    {
        $this->service->delete($id);
        return redirect()->route('xxx.index');
    }
}
```

**Checklist**:
- [ ] Identified UpdateDataXXX procedure
- [ ] Mapped I/U/D modes to Laravel methods
- [ ] Created separate Request classes per mode
- [ ] Different validation rules per mode
- [ ] Different business logic per mode

---

### Pattern 2: Permission Checks

**Delphi Detection**:
```pascal
// Form declaration
IsTambah, IsKoreksi, IsHapus, IsCetak, IsExcel: Boolean;

// Button visibility
BtnTambah.Enabled := IsTambah;
BtnKoreksi.Enabled := IsKoreksi;
```

**Laravel Implementation**:

**A. Request Authorization**:
```php
// app/Http/Requests/XXX/StoreXXXRequest.php
public function authorize(): bool
{
    return app(MenuAccessService::class)->canCreate(
        auth()->user(),
        'MODULE_CODE',
        'L1_CODE'
    );
}
```

**B. Policy Authorization**:
```php
// app/Policies/XXXPolicy.php
public function create(User $user): bool
{
    // IsTambah check
    return $this->menuAccessService->canCreate($user, 'MODULE', 'L1');
}

public function update(User $user, Model $model): bool
{
    // IsKoreksi check
    return $this->menuAccessService->canUpdate($user, 'MODULE', 'L1');
}

public function delete(User $user, Model $model): bool
{
    // IsHapus check
    return $this->menuAccessService->canDelete($user, 'MODULE', 'L1');
}
```

**C. View Permission Checks**:
```blade
@can('create', App\Models\DbXXX::class)
    <a href="{{ route('xxx.create') }}" class="btn btn-primary">Tambah</a>
@endcan

@can('update', $model)
    <a href="{{ route('xxx.edit', $model->id) }}" class="btn btn-warning">Edit</a>
@endcan

@can('delete', $model)
    <form method="POST" action="{{ route('xxx.destroy', $model->id) }}">
        @csrf @method('DELETE')
        <button class="btn btn-danger">Hapus</button>
    </form>
@endcan
```

**Checklist**:
- [ ] Identified all permission variables
- [ ] Mapped to MenuAccessService checks
- [ ] Created Policy class
- [ ] Added @can directives in views
- [ ] Tested permission denied scenarios

---

### Pattern 3: Field Dependencies

**Delphi Detection**:
```pascal
// Warehouse change triggers SPK lookup update
procedure TFrmPB.GudangChange(Sender: TObject);
begin
  LoadAvailableSPKItems(Gudang.Text);
end;

// Field visibility depends on type
procedure TFrmPO.TipeChange(Sender: TObject);
begin
  if Tipe.Text = 'Lokal' then
    PanelLokal.Visible := True
  else
    PanelImport.Visible := True;
end;
```

**Laravel Implementation**:

**A. AJAX Endpoint**:
```php
// Controller
public function getAvailableSPKItems(Request $request)
{
    $kodegdg = $request->get('kodegdg');

    $items = DB::table('DBSPKDET')
        ->leftJoin('DBSPK', 'DBSPK.NOBUKTI', '=', 'DBSPKDET.NOBUKTI')
        ->where('DBSPK.KodeGdg', $kodegdg)
        ->get();

    return response()->json($items);
}
```

**B. JavaScript Handler**:
```javascript
// View
document.getElementById('kodegdg').addEventListener('change', function() {
    const kodegdg = this.value;

    fetch(`/module-name/api/spk-items?kodegdg=${kodegdg}`)
        .then(response => response.json())
        .then(items => {
            // Update UI with items
            renderItemList(items);
        });
});
```

**Checklist**:
- [ ] Identified all field dependencies
- [ ] Created AJAX endpoints for dynamic data
- [ ] Added JavaScript handlers
- [ ] Tested cascading updates

---

### Pattern 4: Validation Rules

**8 Sub-Patterns**:

#### 4.1 Range Validation
**Delphi**:
```pascal
if Quantity.AsFloat < 0 then
  raise Exception.Create('Quantity harus >= 0');
```
**Laravel**:
```php
'quantity' => 'required|numeric|min:0'
```

#### 4.2 Unique Validation
**Delphi**:
```pascal
if QuCheck.Locate('KodeBarang', KodeBarang.Text, []) then
  raise Exception.Create('Kode barang sudah ada');
```
**Laravel**:
```php
'kode_barang' => 'required|unique:dbbarang,KODEBRG'
```

#### 4.3 Required Validation
**Delphi**:
```pascal
if NamaBarang.Text = '' then
  raise Exception.Create('Nama barang harus diisi');
```
**Laravel**:
```php
'nama_barang' => 'required|string|max:100'
```

#### 4.4 Format Validation
**Delphi**:
```pascal
if not IsValidDate(TanggalInput.Text) then
  raise Exception.Create('Format tanggal tidak valid');
```
**Laravel**:
```php
'tanggal' => 'required|date_format:Y-m-d'
```

#### 4.5 Lookup/Foreign Key Validation
**Delphi**:
```pascal
if not QuBarang.Locate('KODEBRG', KodeBarang.Text, []) then
  raise Exception.Create('Barang tidak ditemukan');
```
**Laravel**:
```php
'kode_barang' => 'required|exists:dbbarang,KODEBRG'
```

#### 4.6 Conditional Validation
**Delphi**:
```pascal
if TipeBarang.Text = 'Jadi' then
  if KodeProses.Text = '' then
    raise Exception.Create('Kode proses harus diisi untuk barang jadi');
```
**Laravel**:
```php
'kode_proses' => 'required_if:tipe_barang,Jadi'
```

#### 4.7 Enum Validation
**Delphi**:
```pascal
if not (Status.Text in ['Aktif', 'Nonaktif', 'Pending']) then
  raise Exception.Create('Status tidak valid');
```
**Laravel**:
```php
'status' => 'required|in:Aktif,Nonaktif,Pending'
```

#### 4.8 Custom Business Logic Validation
**Delphi**:
```pascal
// Complex validation
if (Quantity.AsFloat > StokTersedia.AsFloat) and (TipeTransaksi.Text <> 'PO') then
  raise Exception.Create('Stok tidak mencukupi');
```
**Laravel**:
```php
public function withValidator($validator)
{
    $validator->after(function ($validator) {
        if ($this->quantity > $this->getAvailableStock() && $this->tipe !== 'PO') {
            $validator->errors()->add('quantity', 'Stok tidak mencukupi');
        }
    });
}
```

**Validation Checklist**:
- [ ] All required fields validated
- [ ] All unique constraints enforced
- [ ] All range checks implemented
- [ ] All format validations added
- [ ] All foreign key checks implemented
- [ ] All conditional logic preserved
- [ ] All custom business rules implemented
- [ ] User-friendly error messages in Indonesian

---

## Quality Assurance

### Code Quality Checklist

**General**:
- [ ] All files follow PSR-12 standard (run Pint)
- [ ] No hardcoded values (use constants/config)
- [ ] Proper type hints on all methods
- [ ] Comments include Delphi references (file, line number)
- [ ] No commented-out code
- [ ] No debug statements (dd(), var_dump())

**Security**:
- [ ] No SQL injection (use query builder, not concatenation)
- [ ] No XSS vulnerabilities (use {{ }}, not {!! !!})
- [ ] CSRF protection on all forms (@csrf directive)
- [ ] Authorization checks on all operations
- [ ] Input validation on all requests

**Performance**:
- [ ] Eager loading for relationships (avoid N+1)
- [ ] Indexes on frequently queried columns
- [ ] Pagination on large datasets
- [ ] Database transactions for multi-step operations

**Maintainability**:
- [ ] Service layer for business logic (not in controllers)
- [ ] Reusable code extracted to helpers/traits
- [ ] Consistent naming conventions
- [ ] Clear separation of concerns

### Testing Checklist

**Unit Tests** (Optional but Recommended):
- [ ] Test service methods with various inputs
- [ ] Test validation rules
- [ ] Test business logic edge cases

**Feature Tests**:
- [ ] Test create flow (happy path)
- [ ] Test update flow (happy path)
- [ ] Test delete flow (happy path)
- [ ] Test validation errors
- [ ] Test authorization failures
- [ ] Test permission checks

**Manual Testing**:
- [ ] Create document
- [ ] Edit document
- [ ] Delete document
- [ ] Authorize document (if applicable)
- [ ] Search/filter
- [ ] Print/export
- [ ] Test with different user permissions

---

## Troubleshooting

### Common Issues

#### Issue 1: Route Not Found
**Symptoms**: 404 error when accessing module
**Solutions**:
```bash
# Clear route cache
php artisan route:clear
php artisan route:cache

# List routes to verify
php artisan route:list | grep "module-name"
```

#### Issue 2: Permission Denied
**Symptoms**: User cannot access create/edit/delete
**Solutions**:
```sql
-- Check DBFLMENU permissions
SELECT * FROM DBFLMENU WHERE IDUser = 'USERNAME' AND L1 = 'XX' AND KodeMenu = 'XXXX';

-- Update permissions if needed
UPDATE DBFLMENU SET IsTambah = 1, IsKoreksi = 1 WHERE ...;
```

#### Issue 3: Menu Not Appearing
**Symptoms**: Sidebar menu item not visible
**Solutions**:
```bash
# Clear view cache
php artisan view:clear
php artisan cache:clear

# Hard refresh browser (Ctrl+Shift+R)
```

#### Issue 4: Column Not Found
**Symptoms**: SQLSTATE error about missing column
**Solutions**:
```sql
-- Check actual column names in database
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'DbXXX';

-- Use aliases if names differ
SELECT ACTUALNAME AS ExpectedName FROM DbXXX;
```

#### Issue 5: Authorization Not Working
**Symptoms**: Can edit/delete authorized documents
**Solutions**:
```php
// Add validation in service
if ($model->IsOtorisasi1 == 1) {
    throw new \Exception('Dokumen sudah diotorisasi');
}

// Check in controller
if ($model->isAuthorized()) {
    return redirect()->back()->with('error', 'Tidak dapat mengubah dokumen yang sudah diotorisasi');
}
```

#### Issue 6: Detail Lines Not Saving
**Symptoms**: Header saves but details don't
**Solutions**:
```php
// Ensure transaction wraps both
DB::transaction(function () {
    $header = DbXXX::create($headerData);

    foreach ($details as $detail) {
        DbXXXDET::create([
            'NOBUKTI' => $header->NOBUKTI,  // Ensure foreign key set
            // ... other fields
        ]);
    }
});

// Check detail validation rules
'details' => 'required|array|min:1',
'details.*.field' => 'required',
```

---

## Best Practices

### 1. Always Verify Database Schema First
```sql
-- Before writing queries
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN ('DbXXX', 'DbXXXDET')
ORDER BY TABLE_NAME, ORDINAL_POSITION;
```

### 2. Use Existing Patterns
- Copy from successful migrations (PPL, PB, PO)
- Don't reinvent authorization logic
- Reuse existing services (MenuAccessService, AuthorizationService)

### 3. Document As You Go
- Add Delphi references in comments
- Create migration summary during work
- Update OBSERVATIONS.md immediately after

### 4. Test Early and Often
- Test each feature as you build it
- Don't wait until the end
- Fix issues immediately

### 5. Get User Feedback
- Show work in progress
- Ask for clarification when uncertain
- Validate OL configuration early

### 6. Use Database Transactions
```php
// Always wrap multi-step operations
DB::transaction(function () {
    // Step 1
    // Step 2
    // Step 3
});
```

### 7. Handle Errors Gracefully
```php
try {
    $this->service->create($data);
    return redirect()->back()->with('success', 'Data berhasil disimpan');
} catch (\Exception $e) {
    Log::error('Create failed', ['error' => $e->getMessage()]);
    return redirect()->back()
        ->withInput()
        ->with('error', 'Gagal menyimpan data: ' . $e->getMessage());
}
```

### 8. Validate Authorization Level (OL)
```sql
-- ALWAYS check before implementing authorization
SELECT L1, KODEMENU, NAMA, OL FROM DBMENU WHERE KODEMENU = 'XXXX';
```

### 9. Use Type-Safe Code
```php
// Good
public function create(array $data): DbXXX
{
    // Implementation
}

// Bad
public function create($data)
{
    // Implementation
}
```

### 10. Log Everything Important
```php
Log::info('XXX created', [
    'user_id' => auth()->id(),
    'nobukti' => $nobukti,
    'data' => $data,
]);
```

---

## Appendix

### A. File Structure Template

```
app/
├── Http/
│   ├── Controllers/
│   │   └── XXXController.php
│   └── Requests/
│       └── XXX/
│           ├── StoreXXXRequest.php
│           ├── UpdateXXXRequest.php
│           └── DeleteXXXRequest.php (if needed)
├── Models/
│   ├── DbXXX.php (usually exists)
│   └── DbXXXDET.php (usually exists)
├── Policies/
│   └── XXXPolicy.php
└── Services/
    └── XXXService.php

resources/
└── views/
    └── xxx/
        ├── index.blade.php
        ├── create.blade.php
        ├── edit.blade.php
        ├── show.blade.php
        └── print.blade.php

routes/
└── web.php (add XXX routes)

tests/
└── Feature/
    └── XXX/
        ├── XXXCRUDTest.php
        ├── XXXAuthorizationTest.php
        └── XXXValidationTest.php
```

### B. Useful Commands

```bash
# Code quality
./vendor/bin/pint                          # Format code
php -l file.php                            # Check syntax

# Cache management
php artisan cache:clear                    # Clear application cache
php artisan config:clear                   # Clear config cache
php artisan route:clear                    # Clear route cache
php artisan view:clear                     # Clear view cache

# Development
php artisan serve                          # Start dev server
php artisan route:list                     # List all routes
php artisan route:list | grep "xxx"        # Filter routes

# Testing
php artisan test                           # Run all tests
php artisan test --filter XXXTest          # Run specific test

# Database
php artisan migrate                        # Run migrations
php artisan db:show                        # Show database info
```

### C. SQL Server Queries

```sql
-- List all tables
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';

-- List columns for table
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'DbXXX'
ORDER BY ORDINAL_POSITION;

-- Find menu codes
SELECT L1, KODEMENU, NAMA, OL FROM DBMENU WHERE NAMA LIKE '%keyword%';

-- Check permissions
SELECT * FROM DBFLMENU WHERE IDUser = 'SA' AND L1 = '05' AND KodeMenu = '05006';

-- View document authorization status
SELECT NOBUKTI, IsOtorisasi1, OtoUser1, TglOto1, IsOtorisasi2, OtoUser2, TglOto2
FROM DbXXX
WHERE NOBUKTI = '...';
```

### D. Delphi Pattern Reference

**Mode Operations**:
```pascal
Procedure UpdateDataXXX(Choice:Char);
// Choice='I' → Laravel: service->create()
// Choice='U' → Laravel: service->update()
// Choice='D' → Laravel: service->delete()
```

**Permission Variables**:
```pascal
IsTambah   → MenuAccessService::canCreate()
IsKoreksi  → MenuAccessService::canUpdate()
IsHapus    → MenuAccessService::canDelete()
IsCetak    → Policy::print()
IsExcel    → Policy::export()
```

**Audit Logging**:
```pascal
LoggingData(IDUser, Choice, TipeTrans, NoBukti, Keterangan);
// → Laravel: Log::channel('activity')->info(...)
```

**Validation Patterns**:
```pascal
if Field = '' then raise Exception        → 'required'
if QuTable.Locate(...) then raise         → 'unique:table,field'
if Value < 0 then raise                   → 'min:0'
if not IsValidDate(...) then raise        → 'date_format:Y-m-d'
```

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-03 | Claude | Initial SOP created based on PPL, PB, PO migration experiences |

---

**End of SOP**

For questions or issues, refer to:
- `.claude/skills/delphi-migration/RIGOROUS_LOGIC_MIGRATION.md`
- `.claude/skills/delphi-migration/OBSERVATIONS.md`
- `.claude/skills/delphi-migration/CONTINUOUS-IMPROVEMENT.md`
