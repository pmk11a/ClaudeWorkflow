# Phase 4: Implement Code

---

## ⚡ ADW Automation (Recommended)

**This entire phase is automated in ADW!**

```bash
# Run ADW to generate all Laravel code
./scripts/adw/adw-migration.sh <MODULE>
```

**What ADW Generates Automatically**:
- ✅ Models with correct table/column mapping
- ✅ Service layer with all business logic
- ✅ Request classes with validation rules
- ✅ Policy class with permission checks
- ✅ Controller with CRUD methods
- ✅ Routes configuration
- ✅ Views/templates
- ✅ Sidebar menu snippet
- ✅ Test structure

**Time Saved**: 4-6 hours → 5 minutes code generation (98% faster)

**For Manual Steps**: Follow instructions below (if ADW unavailable or custom modifications needed)

---

**⏱️ Estimated Time**: 4-6 hours

**🎯 Objective**: Write Laravel code based on the approved specification from Phase 3. Follow the implementation order to minimize bugs and conflicts.

---

## Step 1: Create Models

```bash
php artisan make:model DbModule
```

**File**: `app/Models/DbModule.php`

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DbModule extends Model
{
    protected $table = 'DbModule';  // SQL Server table name
    protected $primaryKey = 'NOBUKTI';
    public $incrementing = false;
    public $timestamps = false;  // Old SQL Server tables don't have created_at/updated_at
    protected $keyType = 'string';

    protected $fillable = [
        'NOBUKTI', 'TglBukti', 'KodeSupplier', 'Keterangan',
        'IsOtorisasi1', 'OtoUser1', 'TglOto1',
        'IsOtorisasi2', 'OtoUser2', 'TglOto2',
        // ... all other columns
    ];

    // Relationships
    public function details()
    {
        return $this->hasMany(DbModuleDET::class, 'NOBUKTI', 'NOBUKTI');
    }
}
```

---

## Step 2: Create Service Layer

**File**: `app/Services/ModuleService.php`

Implement from approved spec:
- [ ] create() method with all validation
- [ ] update() method with partial validation
- [ ] delete() method with authorization check
- [ ] logActivity() for audit trail
- [ ] All custom business logic

---

## Step 3: Create Request Classes

**Files**:
- `app/Http/Requests/Module/StoreRequest.php`
- `app/Http/Requests/Module/UpdateRequest.php`

**Include**:
- [ ] authorize() method
- [ ] rules() method with all validations
- [ ] messages() method with Indonesian error messages
- [ ] withValidator() for custom business logic

---

## Step 4: Create Policy Class

**File**: `app/Policies/ModulePolicy.php`

**Methods**:
- [ ] create() - check IsTambah
- [ ] update() - check IsKoreksi
- [ ] delete() - check IsHapus
- [ ] print() - check IsCetak (optional)
- [ ] export() - check IsExcel (optional)

---

## Step 5: Create Controller

**File**: `app/Http/Controllers/ModuleController.php`

**Methods**:
- [ ] index() - list view
- [ ] create() - create form
- [ ] store() - handle POST
- [ ] show() - detail view
- [ ] edit() - edit form
- [ ] update() - handle PUT
- [ ] destroy() - handle DELETE

---

## Step 6: Add Routes

**File**: `routes/web.php`

```php
Route::middleware(['auth'])->group(function () {
    Route::resource('module', ModuleController::class);
    Route::get('module/export', [ModuleController::class, 'export'])->name('module.export');
    Route::post('module/{id}/authorize', [ModuleController::class, 'authorize'])->name('module.authorize');
});
```

---

## Step 7: Create Views

**Files**:
- `resources/views/module/index.blade.php` - list
- `resources/views/module/create.blade.php` - create form
- `resources/views/module/edit.blade.php` - edit form
- `resources/views/module/show.blade.php` - detail view

---

## Step 8: Generate Sidebar Snippet

Automatically created after code generation:
- `sidebar_module.html` in output directory
- Copy to `resources/views/layouts/app.blade.php`
- Clear caches: `php artisan cache:clear`

---

## Step 9: Code Review

Before moving to Phase 5:
- [ ] All code follows PSR-12 (run `./vendor/bin/pint`)
- [ ] No hardcoded values
- [ ] Type hints on all methods
- [ ] Comments reference Delphi line numbers
- [ ] No security vulnerabilities
- [ ] All validation rules implemented

---

## Phase 4 Checklist

- [ ] Models created (DbModule, DbModuleDET)
- [ ] Service layer complete
- [ ] Request classes with all validations
- [ ] Policy class with all permission checks
- [ ] Controller with all CRUD methods
- [ ] Routes registered
- [ ] Views created
- [ ] Sidebar snippet generated
- [ ] Code formatted with Pint
- [ ] Code review passed

---

## Next Steps

→ [Phase 5: Test & Document](./PHASE-5-TEST-DOCUMENT.md)

---

← [Phase 3: Plan](./PHASE-3-PLAN.md) | [Phase 5: Test](./PHASE-5-TEST-DOCUMENT.md) →

**Document Version**: 1.0
**Last Updated**: 2026-01-11
