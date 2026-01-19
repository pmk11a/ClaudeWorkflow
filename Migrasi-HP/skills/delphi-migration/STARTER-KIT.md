# Delphi Migration Skill - Starter Kit

**Version**: 1.0
**Last Updated**: 2026-01-03
**Target**: Developers starting their first migration
**Time to Complete**: 3-4 hours for first simple migration

---

## 🎯 What You'll Get

By the end of this starter kit, you will:
- ✅ Complete your **first migration** (SIMPLE complexity)
- ✅ Understand the **migration workflow**
- ✅ Have **ready-to-use templates**
- ✅ Know how to **validate quality**
- ✅ Be ready for **MEDIUM complexity** migrations

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Setup (15 min)](#quick-setup-15-min)
3. [Your First Migration (3-4h)](#your-first-migration-3-4h)
4. [Ready-to-Use Templates](#ready-to-use-templates)
5. [Checklists](#checklists)
6. [Common Commands](#common-commands)
7. [Quick Troubleshooting](#quick-troubleshooting)
8. [Next Steps](#next-steps)

---

## Prerequisites

### Before You Start

**Knowledge Required**:
- ✅ Basic Laravel (routes, controllers, models)
- ✅ Basic Delphi (can read .pas files)
- ✅ SQL (SELECT, INSERT, UPDATE, DELETE)
- ✅ Git basics

**Tools Required**:
- ✅ Laravel 12 installed
- ✅ PHP 8.2+
- ✅ SQL Server connection working
- ✅ Code editor (VS Code recommended)
- ✅ Git installed

**Files Access**:
- ✅ Delphi source files at `d:\ykka\migrasi\pwt\`
- ✅ Laravel project at `d:\ykka\migrasi\`
- ✅ Database connection to SQL Server (192.168.56.1:1433/dbwbcp2)

### Verify Your Setup

```bash
# 1. Check PHP version
php -v
# Should be: PHP 8.2+

# 2. Check Laravel version
php artisan --version
# Should be: Laravel Framework 12.x

# 3. Check database connection
php artisan db:show
# Should show: dbwbcp2 database info

# 4. Check Git
git --version
# Should show: git version 2.x

# 5. Check Pint (code formatter)
./vendor/bin/pint --version
# Should show: Pint version

# 6. Test server
php artisan serve
# Open: http://127.0.0.1:8000
# Should load without errors
```

**If all checks pass → You're ready! ✅**

---

## Quick Setup (15 min)

### Step 1: Read Essential Documentation (10 min)

**Read these in order**:

1. **INDEX.md** (5 min) - Navigation overview
```bash
cat .claude/skills/delphi-migration/INDEX.md
```

2. **QUICK-REFERENCE.md** (5 min) - Skim the pattern reference table
```bash
cat .claude/skills/delphi-migration/QUICK-REFERENCE.md | head -200
```

### Step 2: Bookmark Key Documents (2 min)

Open these in browser/editor tabs:
- `.claude/skills/delphi-migration/QUICK-REFERENCE.md` ← Keep open while coding
- `.claude/skills/delphi-migration/RULES.md` ← For validation
- `.claude/skills/delphi-migration/PATTERN-GUIDE.md` ← For pattern details

### Step 3: Setup Your Workspace (3 min)

```bash
# Create branch for your first migration
cd d:/ykka/migrasi
git checkout -b feature/my-first-migration

# Create workspace directory (optional)
mkdir -p workspace/migration-notes

# Open project in VS Code
code .
```

**Setup Complete! ✅**

---

## Your First Migration (3-4h)

### Choose Your First Form

**Criteria for SIMPLE form**:
- 🟢 Single table or simple master-detail
- 🟢 Basic CRUD (Create, Read, Update, Delete)
- 🟢 <500 lines of Delphi code
- 🟢 No complex calculations
- 🟢 Max 2-3 lookups

**Example SIMPLE forms**:
- Supplier master (FrmSupplier.pas)
- Customer master (FrmCustomer.pas)
- Category master (FrmCategory.pas)

**For this guide, we'll use a hypothetical "FrmSupplier.pas"**

---

### Phase 0: Discovery (30 min)

#### Task 0.1: Get Pre-Migration Advice
```bash
/delphi-advise
"I want to migrate FrmSupplier to Laravel"

# Review recommendations
# Note any similar forms already migrated
```

#### Task 0.2: Read Delphi Source Files
```bash
# Open files
code d:/ykka/migrasi/pwt/Master/Supplier/FrmSupplier.pas
code d:/ykka/migrasi/pwt/Master/Supplier/FrmSupplier.dfm

# Read through and take notes
```

#### Task 0.3: Complete Analysis Checklist

Copy this to `workspace/migration-notes/analysis.md`:

```markdown
# Supplier Migration Analysis

## Basic Info
- **Delphi Files**: FrmSupplier.pas, FrmSupplier.dfm
- **Lines of Code**: ___ (count lines in .pas file)
- **Complexity**: SIMPLE / MEDIUM / COMPLEX
- **Tables**: List all tables referenced

## Pattern Detection

### Pattern 1: Mode Operations ✅ / ❌
- [ ] Found `Procedure UpdateDataXXX(Choice:Char)`
- [ ] Found `Choice='I'` (INSERT)
- [ ] Found `Choice='U'` (UPDATE)
- [ ] Found `Choice='D'` (DELETE)
- **Line numbers**: ___

### Pattern 2: Permissions ✅ / ❌
- [ ] Found `IsTambah` variable
- [ ] Found `IsKoreksi` variable
- [ ] Found `IsHapus` variable
- [ ] Found `IsCetak` variable
- [ ] Found `IsExcel` variable
- **Line numbers**: ___

### Pattern 3: Field Dependencies ✅ / ❌
- [ ] Found `OnChange` event handlers
- [ ] List dependencies: ___

### Pattern 4: Validation Rules ✅ / ❌
Check which sub-patterns:
- [ ] Required (`if Text = ''`)
- [ ] Unique (`QuCheck.Locate`)
- [ ] Range (`if Value < 0`)
- [ ] Format (`IsValidDate`)
- [ ] Lookup (`if not QuTable.Locate`)
- [ ] Conditional (`if Type=1 then if Field...`)
- [ ] Enum (`if not (Status in [...])`)
- [ ] Custom (`raise Exception.Create`)

### Pattern 6: Audit Logging ✅ / ❌
- [ ] Found `LoggingData` calls
- **Line numbers**: ___

### Pattern 7: Master-Detail ✅ / ❌
- [ ] Has detail table
- [ ] Single-item or multi-item: ___

### Pattern 8: Lookup ✅ / ❌
- [ ] List all lookups with KodeBrows: ___

## Database Verification

```sql
-- Check if table exists
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'DbSupplier';

-- Check columns
SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'DbSupplier' ORDER BY ORDINAL_POSITION;

-- Check if model exists
-- File: app/Models/DbSupplier.php
```

## Complexity Assessment
- Patterns detected: ___ / 8
- Time estimate: ___ hours
- **Final Complexity**: SIMPLE / MEDIUM / COMPLEX
```

**Fill out this analysis before proceeding!**

---

### Phase 1: Planning (30 min)

#### Task 1.1: Create Migration Plan

Copy this to `workspace/migration-notes/plan.md`:

```markdown
# Supplier Migration Plan

## Estimated Time: 3-4 hours

## Files to Create

### 1. Service Layer
- [ ] `app/Services/SupplierService.php`
  - create() method (Choice='I')
  - update() method (Choice='U')
  - delete() method (Choice='D')

### 2. Controller
- [ ] `app/Http/Controllers/SupplierController.php`
  - index() - List view
  - create() - Create form
  - store() - Save new
  - show() - Detail view
  - edit() - Edit form
  - update() - Save changes
  - destroy() - Delete

### 3. Request Classes
- [ ] `app/Http/Requests/Supplier/StoreSupplierRequest.php`
- [ ] `app/Http/Requests/Supplier/UpdateSupplierRequest.php`

### 4. Policy
- [ ] `app/Policies/SupplierPolicy.php`

### 5. Views
- [ ] `resources/views/supplier/index.blade.php`
- [ ] `resources/views/supplier/create.blade.php`
- [ ] `resources/views/supplier/edit.blade.php`
- [ ] `resources/views/supplier/show.blade.php`

### 6. Routes
- [ ] Add to `routes/web.php`

## Implementation Order

1. Models (verify exist)
2. Service (business logic)
3. Requests (validation)
4. Policy (authorization)
5. Controller (HTTP layer)
6. Routes
7. Views
8. Testing

## Risks & Mitigations
- List any concerns
- Plan solutions
```

#### Task 1.2: Get User Approval

**🚨 APPROVAL GATE 1**

Show your analysis and plan to:
- Team lead / Senior developer
- User/stakeholder

Get approval before proceeding to implementation.

---

### Phase 2: Implementation (2h)

#### Task 2.1: Create Service Class (30 min)

Create file: `app/Services/SupplierService.php`

Use this template (from QUICK-REFERENCE.md):

```php
<?php

namespace App\Services;

use App\Models\DbSupplier;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class SupplierService
{
    /**
     * Create new supplier
     * Delphi: FrmSupplier.pas, UpdateDataSupplier(Choice:Char), line XXX
     * Mode: Choice='I' (INSERT)
     */
    public function create(array $data): DbSupplier
    {
        return DB::transaction(function () use ($data) {
            // 1. Validate business rules
            $this->validateCreate($data);

            // 2. Create supplier
            $supplier = DbSupplier::create([
                'KODESUPPLIER' => $data['kode_supplier'],
                'NAMASUPPLIER' => $data['nama_supplier'],
                'ALAMAT' => $data['alamat'],
                'KOTA' => $data['kota'],
                'TELP' => $data['telp'],
                // ... map all fields from Delphi
            ]);

            // 3. Log activity
            $this->logActivity('I', $supplier->KODESUPPLIER, $data);

            return $supplier->fresh();
        });
    }

    /**
     * Update existing supplier
     * Delphi: FrmSupplier.pas, UpdateDataSupplier(Choice:Char), line XXX
     * Mode: Choice='U' (UPDATE)
     */
    public function update(string $kodeSupplier, array $data): DbSupplier
    {
        return DB::transaction(function () use ($kodeSupplier, $data) {
            // 1. Find existing
            $supplier = DbSupplier::where('KODESUPPLIER', $kodeSupplier)->firstOrFail();

            // 2. Validate can update
            $this->validateUpdate($supplier, $data);

            // 3. Update
            $supplier->update([
                'NAMASUPPLIER' => $data['nama_supplier'],
                'ALAMAT' => $data['alamat'],
                'KOTA' => $data['kota'],
                'TELP' => $data['telp'],
                // ... update fields (some may be immutable)
            ]);

            // 4. Log activity
            $this->logActivity('U', $kodeSupplier, $data);

            return $supplier->fresh();
        });
    }

    /**
     * Delete supplier
     * Delphi: FrmSupplier.pas, UpdateDataSupplier(Choice:Char), line XXX
     * Mode: Choice='D' (DELETE)
     */
    public function delete(string $kodeSupplier): bool
    {
        return DB::transaction(function () use ($kodeSupplier) {
            // 1. Find existing
            $supplier = DbSupplier::where('KODESUPPLIER', $kodeSupplier)->firstOrFail();

            // 2. Validate can delete
            $this->validateDelete($supplier);

            // 3. Delete
            $deleted = $supplier->delete();

            // 4. Log activity
            $this->logActivity('D', $kodeSupplier, []);

            return $deleted;
        });
    }

    /**
     * Validation methods
     */
    protected function validateCreate(array $data): void
    {
        // Business rules from Delphi
        // Example: Check if supplier code already exists
    }

    protected function validateUpdate(DbSupplier $supplier, array $data): void
    {
        // Business rules from Delphi
    }

    protected function validateDelete(DbSupplier $supplier): void
    {
        // Business rules from Delphi
        // Example: Check if supplier has transactions
    }

    /**
     * Log activity (LoggingData equivalent)
     */
    protected function logActivity(string $mode, string $kode, array $data): void
    {
        Log::channel('activity')->info("Supplier {$mode}", [
            'user_id' => auth()->id(),
            'mode' => $mode,
            'kode_supplier' => $kode,
            'data' => $data,
        ]);
    }
}
```

**Customize**:
1. Replace `XXX` with actual line numbers from Delphi
2. Map all fields from Delphi to Laravel
3. Add business validation rules from Delphi

#### Task 2.2: Create Request Classes (20 min)

Create file: `app/Http/Requests/Supplier/StoreSupplierRequest.php`

```php
<?php

namespace App\Http\Requests\Supplier;

use Illuminate\Foundation\Http\FormRequest;
use App\Services\MenuAccessService;

class StoreSupplierRequest extends FormRequest
{
    public function authorize(): bool
    {
        // IsTambah permission check
        return app(MenuAccessService::class)->canCreate(
            auth()->user(),
            'SUPPLIER', // Module code
            '01001'     // L1 code (check DBMENU)
        );
    }

    public function rules(): array
    {
        return [
            // Map ALL validation rules from Delphi
            'kode_supplier' => 'required|string|max:20|unique:dbsupplier,KODESUPPLIER',
            'nama_supplier' => 'required|string|max:100',
            'alamat' => 'nullable|string|max:200',
            'kota' => 'nullable|string|max:50',
            'telp' => 'nullable|string|max:20',
            // ... add all fields
        ];
    }

    public function messages(): array
    {
        return [
            'kode_supplier.required' => 'Kode supplier harus diisi',
            'kode_supplier.unique' => 'Kode supplier sudah digunakan',
            'nama_supplier.required' => 'Nama supplier harus diisi',
            // ... add all messages in Indonesian
        ];
    }

    public function withValidator($validator)
    {
        $validator->after(function ($validator) {
            // Custom business logic validation from Delphi
            // Example: Check if supplier is in blacklist
        });
    }
}
```

Create file: `app/Http/Requests/Supplier/UpdateSupplierRequest.php`

```php
<?php

namespace App\Http\Requests\Supplier;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use App\Services\MenuAccessService;

class UpdateSupplierRequest extends FormRequest
{
    public function authorize(): bool
    {
        // IsKoreksi permission check
        return app(MenuAccessService::class)->canUpdate(
            auth()->user(),
            'SUPPLIER',
            '01001'
        );
    }

    public function rules(): array
    {
        $kodeSupplier = $this->route('kode_supplier');

        return [
            // Kode supplier may be immutable in UPDATE mode
            'kode_supplier' => [
                'required',
                Rule::unique('dbsupplier', 'KODESUPPLIER')->ignore($kodeSupplier, 'KODESUPPLIER'),
            ],
            'nama_supplier' => 'required|string|max:100',
            'alamat' => 'nullable|string|max:200',
            'kota' => 'nullable|string|max:50',
            'telp' => 'nullable|string|max:20',
            // ... other fields
        ];
    }

    public function messages(): array
    {
        return [
            'nama_supplier.required' => 'Nama supplier harus diisi',
            // ... messages
        ];
    }
}
```

#### Task 2.3: Create Policy Class (10 min)

Create file: `app/Policies/SupplierPolicy.php`

```php
<?php

namespace App\Policies;

use App\Models\DbSupplier;
use App\Models\Trade2Exchange\User;
use App\Services\MenuAccessService;

class SupplierPolicy
{
    public function __construct(
        protected MenuAccessService $menuAccessService
    ) {}

    public function create(User $user): bool
    {
        return $this->menuAccessService->canCreate($user, 'SUPPLIER', '01001');
    }

    public function update(User $user, DbSupplier $supplier): bool
    {
        return $this->menuAccessService->canUpdate($user, 'SUPPLIER', '01001');
    }

    public function delete(User $user, DbSupplier $supplier): bool
    {
        return $this->menuAccessService->canDelete($user, 'SUPPLIER', '01001');
    }
}
```

#### Task 2.4: Create Controller (30 min)

Create file: `app/Http/Controllers/SupplierController.php`

```php
<?php

namespace App\Http\Controllers;

use App\Models\DbSupplier;
use App\Services\SupplierService;
use App\Http\Requests\Supplier\StoreSupplierRequest;
use App\Http\Requests\Supplier\UpdateSupplierRequest;

class SupplierController extends Controller
{
    public function __construct(
        protected SupplierService $service
    ) {}

    public function index()
    {
        $suppliers = DbSupplier::orderBy('KODESUPPLIER')->paginate(20);
        return view('supplier.index', compact('suppliers'));
    }

    public function create()
    {
        $this->authorize('create', DbSupplier::class);
        return view('supplier.create');
    }

    public function store(StoreSupplierRequest $request)
    {
        try {
            $result = $this->service->create($request->validated());

            return redirect()
                ->route('supplier.show', $result->KODESUPPLIER)
                ->with('success', 'Supplier berhasil ditambahkan');
        } catch (\Exception $e) {
            return redirect()
                ->back()
                ->withInput()
                ->with('error', 'Gagal menambahkan supplier: ' . $e->getMessage());
        }
    }

    public function show(string $kodeSupplier)
    {
        $supplier = DbSupplier::where('KODESUPPLIER', $kodeSupplier)->firstOrFail();
        return view('supplier.show', compact('supplier'));
    }

    public function edit(string $kodeSupplier)
    {
        $supplier = DbSupplier::where('KODESUPPLIER', $kodeSupplier)->firstOrFail();
        $this->authorize('update', $supplier);
        return view('supplier.edit', compact('supplier'));
    }

    public function update(UpdateSupplierRequest $request, string $kodeSupplier)
    {
        try {
            $result = $this->service->update($kodeSupplier, $request->validated());

            return redirect()
                ->route('supplier.show', $kodeSupplier)
                ->with('success', 'Supplier berhasil diubah');
        } catch (\Exception $e) {
            return redirect()
                ->back()
                ->withInput()
                ->with('error', 'Gagal mengubah supplier: ' . $e->getMessage());
        }
    }

    public function destroy(string $kodeSupplier)
    {
        $supplier = DbSupplier::where('KODESUPPLIER', $kodeSupplier)->firstOrFail();
        $this->authorize('delete', $supplier);

        try {
            $this->service->delete($kodeSupplier);

            return redirect()
                ->route('supplier.index')
                ->with('success', 'Supplier berhasil dihapus');
        } catch (\Exception $e) {
            return redirect()
                ->back()
                ->with('error', 'Gagal menghapus supplier: ' . $e->getMessage());
        }
    }
}
```

#### Task 2.5: Add Routes (5 min)

Add to `routes/web.php`:

```php
// Supplier Routes
Route::prefix('supplier')->name('supplier.')->group(function () {
    Route::get('/', [SupplierController::class, 'index'])->name('index');
    Route::get('/create', [SupplierController::class, 'create'])->name('create');
    Route::post('/', [SupplierController::class, 'store'])->name('store');
    Route::get('/{kode_supplier}', [SupplierController::class, 'show'])->name('show');
    Route::get('/{kode_supplier}/edit', [SupplierController::class, 'edit'])->name('edit');
    Route::put('/{kode_supplier}', [SupplierController::class, 'update'])->name('update');
    Route::delete('/{kode_supplier}', [SupplierController::class, 'destroy'])->name('destroy');
});
```

Verify routes:
```bash
php artisan route:list | grep supplier
```

#### Task 2.6: Create Views (25 min)

**Note**: Copy existing views from PPL or PB and modify.

Basic structure for each view:

**resources/views/supplier/index.blade.php**:
- List table with pagination
- Search/filter
- Create button (with permission check)
- Edit/Delete buttons per row

**resources/views/supplier/create.blade.php**:
- Form with all fields
- Validation error display
- Submit button

**resources/views/supplier/edit.blade.php**:
- Pre-filled form
- Similar to create

**resources/views/supplier/show.blade.php**:
- Read-only view
- Edit/Delete buttons

---

### Phase 3: Testing (1h)

#### Task 3.1: Syntax Validation (5 min)

```bash
# Check PHP syntax
php -l app/Services/SupplierService.php
php -l app/Http/Controllers/SupplierController.php
php -l app/Http/Requests/Supplier/StoreSupplierRequest.php
php -l app/Http/Requests/Supplier/UpdateSupplierRequest.php
php -l app/Policies/SupplierPolicy.php

# Check Blade syntax
php artisan view:cache

# Format code
./vendor/bin/pint
```

#### Task 3.2: Route Testing (5 min)

```bash
# List routes
php artisan route:list | grep supplier

# Should show:
# GET    /supplier
# GET    /supplier/create
# POST   /supplier
# GET    /supplier/{kode_supplier}
# GET    /supplier/{kode_supplier}/edit
# PUT    /supplier/{kode_supplier}
# DELETE /supplier/{kode_supplier}
```

#### Task 3.3: Manual Testing (40 min)

Use this checklist (copy to `workspace/migration-notes/testing.md`):

```markdown
# Supplier Testing Checklist

## Create Flow
- [ ] Access /supplier/create
- [ ] Form displays all fields
- [ ] Submit empty form → validation errors shown
- [ ] Fill valid data → submission succeeds
- [ ] Redirected to show page
- [ ] Data visible in show page
- [ ] Database verified (SQL query)

## Read Flow
- [ ] Access /supplier
- [ ] List shows all suppliers
- [ ] Pagination works
- [ ] Search works (if implemented)
- [ ] Click supplier → detail page loads

## Update Flow
- [ ] Access /supplier/{kode}/edit
- [ ] Form pre-filled with data
- [ ] Change some fields
- [ ] Submit → update succeeds
- [ ] Redirected to show page
- [ ] Changes visible
- [ ] Database verified

## Delete Flow
- [ ] Click delete button
- [ ] Confirmation dialog appears
- [ ] Confirm → deletion succeeds
- [ ] Redirected to index
- [ ] Record gone from list
- [ ] Database verified

## Permission Testing
- [ ] User WITHOUT IsTambah → cannot access create
- [ ] User WITHOUT IsKoreksi → cannot access edit
- [ ] User WITHOUT IsHapus → cannot delete
- [ ] Proper error messages shown

## Validation Testing
- [ ] Empty required fields → error
- [ ] Duplicate kode supplier → error
- [ ] Invalid format → error
- [ ] All validation rules tested

## Activity Logging
- [ ] Create logged
- [ ] Update logged
- [ ] Delete logged
- [ ] Check storage/logs/activity.log
```

**Test with real user and data!**

#### Task 3.4: Database Verification (10 min)

```sql
-- After CREATE
SELECT * FROM DbSupplier WHERE KODESUPPLIER = 'TEST001';

-- After UPDATE
SELECT * FROM DbSupplier WHERE KODESUPPLIER = 'TEST001';
-- Verify changes

-- Check activity log
SELECT * FROM dbLogFile
WHERE NoBukti = 'TEST001' OR Keterangan LIKE '%TEST001%'
ORDER BY TglLog DESC;
```

---

### Phase 4: Documentation (15 min)

#### Task 4.1: Run Retrospective

```bash
/delphi-retrospective
```

This will auto-generate entry in OBSERVATIONS.md.

#### Task 4.2: Create Migration Summary

Create file: `workspace/migration-notes/SUMMARY.md`

```markdown
# Supplier Migration Summary

**Date**: 2026-01-03
**Time Taken**: ___ hours
**Status**: ✅ Success / ⚠️ Partial / ❌ Failed

## Overview
- **Delphi Files**: FrmSupplier.pas (XXX lines)
- **Laravel Files**: 7 files, ~XXX lines
- **Complexity**: SIMPLE

## Patterns Implemented
- [x] Pattern 1: Mode Operations (I/U/D)
- [x] Pattern 2: Permissions (IsTambah/IsKoreksi/IsHapus)
- [ ] Pattern 3: Field Dependencies (N/A)
- [x] Pattern 4: Validation (all rules)
- [x] Pattern 6: Audit Logging
- [ ] Pattern 7: Master-Detail (N/A)
- [ ] Pattern 8: Lookup (N/A)

## Quality Metrics
- Mode Coverage: 100% (3/3)
- Permission Coverage: 100% (3/3)
- Validation Coverage: __% (__/__)
- Audit Coverage: 100% (3/3)
- Testing: 100% (all manual tests passed)

**Overall Score**: __/100

## Issues Encountered
1. Issue: ___
   Solution: ___

2. Issue: ___
   Solution: ___

## Lessons Learned
1. ___
2. ___

## Recommendations
1. ___
2. ___
```

---

### Phase 5: Deployment Preparation (15 min)

#### Task 5.1: Final Checklist

```markdown
# Deployment Checklist

## Code Quality
- [ ] All files formatted with Pint
- [ ] No hardcoded values
- [ ] Proper type hints
- [ ] Delphi references in comments
- [ ] No security vulnerabilities

## Functionality
- [ ] All CRUD operations work
- [ ] Permissions work correctly
- [ ] All validations work
- [ ] Audit logging works

## Testing
- [ ] Manual testing completed
- [ ] Permission testing done
- [ ] Database verification done
- [ ] All edge cases tested

## Documentation
- [ ] Migration summary created
- [ ] Retrospective completed
- [ ] Code comments added

## Git
- [ ] All changes committed
- [ ] Meaningful commit messages
- [ ] Branch pushed to remote
```

#### Task 5.2: Commit & Push

```bash
# Stage all changes
git add .

# Commit with meaningful message
git commit -m "feat(supplier): Complete supplier module migration

- Implement CRUD operations (I/U/D modes)
- Add permission checks (IsTambah/IsKoreksi/IsHapus)
- Add validation rules from Delphi
- Add audit logging
- Create all views (index/create/edit/show)

Delphi: FrmSupplier.pas, line 150-450
Quality Score: __/100
Time: __ hours"

# Push to remote
git push -u origin feature/my-first-migration
```

#### Task 5.3: Request Review

Create pull request with:
- Link to migration summary
- Quality score
- Testing results
- Screenshots (optional)

**🚨 APPROVAL GATE 2**: Get approval before merging to main.

---

## Ready-to-Use Templates

All templates are in QUICK-REFERENCE.md. Quick links:

### Service Template
```bash
cat .claude/skills/delphi-migration/QUICK-REFERENCE.md | grep -A 100 "Service Template"
```

### Controller Template
```bash
cat .claude/skills/delphi-migration/QUICK-REFERENCE.md | grep -A 80 "Controller Template"
```

### Request Template
```bash
cat .claude/skills/delphi-migration/QUICK-REFERENCE.md | grep -A 60 "Request Template"
```

### Policy Template
```bash
cat .claude/skills/delphi-migration/QUICK-REFERENCE.md | grep -A 30 "Policy Template"
```

---

## Checklists

### Pre-Migration Checklist

```
Before Starting ANY Migration:
- [ ] Read SOP-DELPHI-MIGRATION.md (at least overview)
- [ ] Run /delphi-advise
- [ ] Verify database tables exist
- [ ] Check if similar form already migrated (OBSERVATIONS.md)
- [ ] Assess complexity (SIMPLE/MEDIUM/COMPLEX)
- [ ] Get time estimate
- [ ] User approved plan
```

### Pattern Detection Checklist

```
For Each Delphi Form:
- [ ] Pattern 1: Mode Operations (Choice:Char)
- [ ] Pattern 2: Permissions (IsTambah/IsKoreksi/IsHapus)
- [ ] Pattern 3: Field Dependencies
- [ ] Pattern 4: Validation (8 sub-patterns)
- [ ] Pattern 5: Authorization (check OL first!)
- [ ] Pattern 6: Audit Logging (LoggingData)
- [ ] Pattern 7: Master-Detail
- [ ] Pattern 8: Lookup (KodeBrows)
```

### Implementation Checklist

```
Files to Create:
- [ ] Service class (business logic)
- [ ] Controller class (HTTP layer)
- [ ] Request classes (Store/Update/Delete if needed)
- [ ] Policy class (authorization)
- [ ] Routes (web.php)
- [ ] Views (index/create/edit/show)

Verify Each File:
- [ ] PHP syntax valid (php -l)
- [ ] Formatted with Pint
- [ ] Delphi references in comments
- [ ] No hardcoded values
- [ ] Proper error handling
```

### Testing Checklist

```
Manual Testing:
- [ ] Create new record
- [ ] Read/view record
- [ ] Update record
- [ ] Delete record
- [ ] Permission denied scenarios
- [ ] Validation error scenarios
- [ ] Database verification
- [ ] Activity log verification

Edge Cases:
- [ ] Empty inputs
- [ ] Duplicate entries
- [ ] Invalid formats
- [ ] Non-existent IDs
- [ ] Concurrent operations
```

### Quality Assurance Checklist

```
Before Deployment:
- [ ] All patterns implemented (100%)
- [ ] All modes covered (I/U/D)
- [ ] All permissions mapped
- [ ] All validations present
- [ ] Audit logging complete
- [ ] Code formatted (Pint)
- [ ] No security vulnerabilities
- [ ] Manual testing passed
- [ ] Documentation complete
- [ ] User approved

Quality Score ≥ 90/100? → Ready for production ✅
```

---

## Common Commands

### Development

```bash
# Start server
php artisan serve

# Clear caches
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Format code
./vendor/bin/pint

# Check syntax
php -l app/Http/Controllers/SupplierController.php

# List routes
php artisan route:list | grep supplier

# Test database connection
php artisan db:show
```

### Git

```bash
# Create feature branch
git checkout -b feature/supplier-migration

# Stage changes
git add .

# Commit
git commit -m "feat(supplier): Description"

# Push
git push -u origin feature/supplier-migration

# View status
git status

# View diff
git diff
```

### SQL Server

```sql
-- Check table exists
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'DbSupplier';

-- Check columns
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'DbSupplier'
ORDER BY ORDINAL_POSITION;

-- Verify data
SELECT * FROM DbSupplier WHERE KODESUPPLIER = 'TEST001';

-- Check activity log
SELECT * FROM dbLogFile
WHERE NoBukti LIKE '%TEST%'
ORDER BY TglLog DESC;
```

---

## Quick Troubleshooting

### Issue: Route not found (404)

**Solution**:
```bash
php artisan route:clear
php artisan route:cache
php artisan route:list | grep supplier
```

### Issue: View not found

**Solution**:
```bash
php artisan view:clear
# Check file exists: resources/views/supplier/index.blade.php
```

### Issue: Class not found

**Solution**:
```bash
composer dump-autoload
# Check namespace matches directory structure
```

### Issue: Permission denied

**Solution**:
```sql
-- Check permissions in database
SELECT * FROM DBFLMENU
WHERE IDUser = 'YOUR_USER' AND L1 = '01' AND KodeMenu = '01001';

-- Update permissions
UPDATE DBFLMENU SET IsTambah = '1', IsKoreksi = '1', IsHapus = '1'
WHERE IDUser = 'YOUR_USER' AND L1 = '01' AND KodeMenu = '01001';
```

### Issue: SQL column not found

**Solution**:
```sql
-- Check actual column names
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'DbSupplier';

-- Use alias if names differ
SELECT ACTUALNAME AS ExpectedName FROM DbSupplier;
```

### Issue: Validation errors not showing

**Solution**:
```blade
<!-- Add to view -->
@if ($errors->any())
    <div class="alert alert-danger">
        <ul>
            @foreach ($errors->all() as $error)
                <li>{{ $error }}</li>
            @endforeach
        </ul>
    </div>
@endif
```

### Issue: Changes not reflecting

**Solution**:
```bash
# Clear ALL caches
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
composer dump-autoload

# Hard refresh browser: Ctrl+Shift+R
```

---

## Next Steps

### After Your First Migration

**Celebrate!** 🎉 You completed your first migration!

**Now**:
1. ✅ Review your quality score
2. ✅ Read OBSERVATIONS.md (your entry)
3. ✅ Identify what to improve next time

### Prepare for Second Migration

**Choose MEDIUM complexity**:
- Master-detail relationship
- 2-3 lookups
- Some field dependencies
- 500-1500 lines Delphi code

**Before starting**:
1. Re-read sections you struggled with
2. Review PATTERN-GUIDE.md for new patterns
3. Check RULES.md for compliance
4. Run `/delphi-advise`

### Level Up

**Week 1**: 1 SIMPLE migration
**Week 2-3**: 2-3 MEDIUM migrations
**Month 2+**: COMPLEX migrations

**Resources**:
- SOP-DELPHI-MIGRATION.md - Full process guide
- PATTERN-GUIDE.md - Deep dive patterns
- RULES.md - Quality compliance
- OBSERVATIONS.md - Learn from past

### Get Help

**Stuck?**
1. Check QUICK-REFERENCE.md → Common Pitfalls
2. Check Quick Troubleshooting (above)
3. Search OBSERVATIONS.md for similar issues
4. Run `/delphi-advise` with your question

**Questions?**
1. Read relevant section in SOP or PATTERN-GUIDE
2. Check RULES.md for compliance requirements
3. Ask team lead / senior developer

---

## Summary

You now have:
- ✅ **Complete workflow** for first migration
- ✅ **Ready-to-use templates** for all files
- ✅ **Checklists** for quality assurance
- ✅ **Common commands** at your fingertips
- ✅ **Quick troubleshooting** for common issues

**Time Investment**:
- Setup: 15 min
- First migration: 3-4 hours
- **Total**: ~4 hours to become productive

**Next migration**: 2-3 hours (faster with experience!)

---

**Starter Kit v1.0** | Your Fast Track to Delphi Migration Success
**Last Updated**: 2026-01-03

For detailed guides, see:
- SOP-DELPHI-MIGRATION.md
- PATTERN-GUIDE.md
- QUICK-REFERENCE.md
- RULES.md

**Ready to start? Follow "Your First Migration" above! 🚀**
