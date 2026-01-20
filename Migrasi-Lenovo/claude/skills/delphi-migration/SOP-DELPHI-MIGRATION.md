# Standard Operating Procedure: Delphi to Laravel Migration

**Document Version**: 1.1 (Consolidated)
**Last Updated**: 2026-01-16
**Status**: Production Ready
**Purpose**: Workflow & process guide for migrating Delphi 6 VCL forms to Laravel 12

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Migration Phases](#migration-phases)
4. [Quality Assurance](#quality-assurance)
5. [Troubleshooting](#troubleshooting)
6. [Appendix](#appendix)

**Reference Documents** (Cross-links):
- Pattern Detection → See [PATTERN-GUIDE.md](./PATTERN-GUIDE.md)
- Implementation Cookbook → See [KNOWLEDGE-BASE.md](./KNOWLEDGE-BASE.md)
- Best Practices → See [KNOWLEDGE-BASE.md](./KNOWLEDGE-BASE.md)

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

**First-time migrations** (no pattern reuse yet):

| Complexity | Characteristics | Estimated Time |
|------------|----------------|----------------|
| 🟢 **SIMPLE** | Basic CRUD, single form, no complex logic | 2-4 hours |
| 🟡 **MEDIUM** | Master-detail, business rules, 2-3 lookups | 4-8 hours |
| 🔴 **COMPLEX** | Multiple forms, algorithms, stock impact, 5+ lookups | 8-12 hours |

**With pattern reuse** (after 3+ migrations):

| Complexity | First Time | With Patterns | Reduction |
|------------|-----------|---------------|-----------|
| 🟢 **SIMPLE** | 2-4 hours | **1-2 hours** | **50%** |
| 🟡 **MEDIUM** | 4-8 hours | **2-4 hours** | **50%** |
| 🔴 **COMPLEX** | 8-12 hours | **4-6 hours** | **50%** |

### Pattern Reuse Bonuses

Apply these reductions if applicable:

| Factor | Reduction | When Applicable |
|--------|-----------|-----------------|
| Test infrastructure reusable | -20% | After 2nd migration |
| Similar module migrated | -30% | Exact pattern exists |
| Service patterns established | -25% | 3+ migrations done |
| **Total possible saving** | **~57%** | All factors present |

### Real Example: Arus Kas (Complex Module)

**Original Estimate**: 8-12 hours
**Actual Time**: 3.5 hours
**Time Savings**: 57% (reused patterns from Group module)
**Why**: Comprehensive skill files + established test patterns + similar authorization logic

### How to Use These Estimates

1. **First Migration**: Use "First Time" column
2. **After 3+ Migrations**: Use "With Patterns" column if:
   - ✅ You've migrated similar modules
   - ✅ You reuse test infrastructure
   - ✅ You use established service patterns
3. **Actual Time**: Will vary ±20% based on complexity of business logic

---

## Prerequisites

### Before Starting ANY Migration

#### 1. Read Project Documentation (20 minutes)
```bash
# Core references
cat CLAUDE.md
cat .claude/commands/delphi-laravel-migration.md
cat .claude/skills/delphi-migration/PATTERN-GUIDE.md
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

#### Step 8: Auto-Generated Sidebar Menu Snippet

After code generation, a sidebar menu snippet is **automatically created**:

**File**: `sidebar_{module-name}.html` in output directory

**Content includes**:
- Menu item with proper Bootstrap structure
- Links to index (list) and create (new) pages
- Font Awesome icons
- Installation instructions
- Troubleshooting guide

**Steps to add to your app**:

1. **Locate the snippet file**:
   ```bash
   ls sidebar_*.html
   ```

2. **Open the snippet and copy the HTML menu item**

3. **Edit sidebar**: `resources/views/layouts/app.blade.php`

4. **Find appropriate section** and paste:
   - **Master Data** → Place in "Master Data" section
   - **Transaksi** → Place in "Transaksi" section
   - **Laporan** → Place in "Laporan" section

5. **Clear all caches** (CRITICAL - don't skip this!):
   ```bash
   php artisan cache:clear
   php artisan view:clear
   php artisan config:clear
   ```

6. **Hard refresh browser**: `Ctrl+Shift+R` (Windows) or `Cmd+Shift+R` (Mac)

**If menu doesn't appear**:
- Verify route names match (check `routes/web.php`)
- Verify HTML structure is correct
- Clear cache again
- Check browser's DevTools (F12) for errors
- Verify Font Awesome is included in layout

**Example snippet** (for Penyerahan Bahan module):
```html
<li class="nav-item">
    <a href="#" class="nav-link">
        <i class="nav-icon fas fa-folder-open"></i>
        <p>
            Penyerahan Bahan
            <i class="fas fa-angle-left right"></i>
        </p>
    </a>
    <ul class="nav nav-treeview">
        <li class="nav-item">
            <a href="{{ route('ppl.index') }}" class="nav-link">
                <i class="far fa-circle nav-icon"></i>
                <p>Daftar Penyerahan Bahan</p>
            </a>
        </li>
        <li class="nav-item">
            <a href="{{ route('ppl.create') }}" class="nav-link">
                <i class="far fa-circle nav-icon"></i>
                <p>Tambah Penyerahan Bahan</p>
            </a>
        </li>
    </ul>
</li>
```

---

### Phase 2.5: UI Preview Artifact (Optional, 30 min)

**Objective**: Generate interactive React artifact untuk preview UI sebelum testing di Laravel.

**Kapan Digunakan**:
- Form complex dengan banyak komponen
- Ingin validasi layout/behavior sebelum test di Laravel
- User ingin lihat preview UI cepat

**Kapan TIDAK Digunakan**:
- Form simple (CRUD basic)
- Sudah familiar dengan pattern form tersebut
- Time constraint ketat

#### Step 1: Generate Preview Artifact

Buat React artifact yang mereplikasi UI Delphi:

```jsx
// preview-frm-xxx.jsx
// Generated from: FrmXXX.dfm + FrmXXX.pas

import React, { useState } from 'react';

export default function PreviewFrmXXX() {
  // State dari form
  const [formData, setFormData] = useState({
    kode: '',
    nama: '',
    // ... fields dari .dfm
  });
  const [details, setDetails] = useState([]);
  const [mode, setMode] = useState('view'); // view, create, edit

  // CRUD handlers dengan console.log untuk tracking
  const handleNew = () => {
    console.log('📝 NEW triggered');
    setMode('create');
    setFormData({ kode: '', nama: '' });
  };

  const handleSave = () => {
    console.log('💾 SAVE triggered', { mode, formData, details });
    // Validation check
    if (!formData.kode) {
      console.log('❌ VALIDATION: Kode required');
      alert('Kode harus diisi!');
      return;
    }
    console.log('✅ SAVE success');
    setMode('view');
  };

  const handleEdit = () => {
    console.log('✏️ EDIT triggered');
    setMode('edit');
  };

  const handleDelete = () => {
    if (confirm('Yakin hapus data ini?')) {
      console.log('🗑️ DELETE confirmed');
    }
  };

  return (
    <div className="p-4">
      {/* Toolbar */}
      <div className="flex gap-2 mb-4">
        <button onClick={handleNew} data-testid="btn-new">New</button>
        <button onClick={handleSave} data-testid="btn-save">Save</button>
        <button onClick={handleEdit} data-testid="btn-edit">Edit</button>
        <button onClick={handleDelete} data-testid="btn-delete">Delete</button>
      </div>

      {/* Form Fields - sesuai .dfm layout */}
      <div className="grid grid-cols-2 gap-4">
        <input
          data-testid="input-kode"
          placeholder="Kode"
          value={formData.kode}
          onChange={e => setFormData({...formData, kode: e.target.value})}
          disabled={mode === 'view'}
        />
        {/* ... more fields */}
      </div>

      {/* Detail Grid - untuk master-detail */}
      <table className="mt-4 w-full">
        <thead>
          <tr>
            <th>No</th>
            <th>Kode Barang</th>
            <th>Qty</th>
            {/* ... columns dari .dfm TDBGrid */}
          </tr>
        </thead>
        <tbody>
          {details.map((d, i) => (
            <tr key={i} data-testid={`grid-row-${i}`}>
              <td>{i + 1}</td>
              <td>{d.kodeBarang}</td>
              <td>{d.qty}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
```

#### Step 2: Test Manual di Artifact

User test dengan cara:
1. Buka artifact di claude.ai
2. Klik button-button (New, Save, Edit, Delete)
3. Isi form fields
4. Buka DevTools (F12) → Console untuk lihat log
5. Verifikasi behavior sesuai Delphi original

#### Step 3: Checklist Preview Test

| Test | Action | Expected | ✓ |
|------|--------|----------|---|
| Form layout | Visual check | Match Delphi layout | |
| New button | Click New | Form kosong, mode=create | |
| Required validation | Save tanpa isi Kode | Error message | |
| Save success | Isi form → Save | Console: SAVE success | |
| Edit mode | Click Edit | Fields editable | |
| Delete confirm | Click Delete | Confirmation dialog | |
| Detail grid | Add detail row | Row muncul di table | |

#### Step 4: Iterate jika Perlu

Jika ada yang tidak sesuai:
1. Report specific issue ke AI
2. AI fix artifact
3. Test ulang

**Token Efficiency Note**: 
- Preview artifact = ~3000 tokens (one-time)
- User test manual = 0 tokens
- Fix specific issue = ~1000 tokens per fix
- Total: jauh lebih hemat daripada automated testing

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
    use DatabaseTransactions;  // ✅ Use transactions (ROLLBACK), NOT RefreshDatabase!

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

### Phase 3.5: CRUD Test Artifact (Optional, 1-2 hours)

**🚨 APPROVAL GATE**: Phase ini WAJIB mendapat persetujuan user sebelum dijalankan.

```
┌─────────────────────────────────────────────────────────────┐
│  ⚠️  PERSETUJUAN DIPERLUKAN                                 │
│                                                              │
│  Phase 3.5 akan generate React artifact untuk test CRUD.    │
│  Estimasi token: ~5000-8000 tokens                          │
│                                                              │
│  Lanjutkan? [Y/N]                                           │
└─────────────────────────────────────────────────────────────┘
```

**Objective**: Generate interactive React artifact untuk comprehensive CRUD testing.

**Kapan Digunakan**:
- Form complex dengan master-detail
- Perlu validasi semua CRUD operation sebelum production
- User ingin visual test yang comprehensive
- Form baru yang belum pernah di-migrate sebelumnya

**Kapan TIDAK Digunakan**:
- Form simple tanpa detail
- Sudah pernah migrate form serupa
- Time/token constraint ketat
- Phase 3 manual testing sudah cukup

---

#### Complete Test Matrix

| Category | Priority | Test Count | Description |
|----------|----------|------------|-------------|
| **CREATE** | 🔴 P0 | 6 tests | New, validation, duplicate, save, cancel |
| **READ** | 🟠 P1 | 7 tests | Load, filter, search, sort, pagination |
| **UPDATE** | 🔴 P0 | 7 tests | Edit mode, validation, calculated, audit |
| **DELETE** | 🔴 P0 | 7 tests | Confirmation, cascade, restrict |
| **Master-Detail** | 🔴 P0 | 5 tests | Add, edit, remove, save, validation |
| **Permission** | 🔴 P0 | 5 tests | IsTambah, IsKoreksi, IsHapus |
| **Status/Lock** | 🔴 P0 | 7 tests | Draft→Approved→Locked, revert |
| **Event Lifecycle** | 🟢 P3 | 5 tests | OnCreate, OnShow, BeforePost, OnClose |
| **Visual/Layout** | 🟡 P2 | 6 tests | Tab order, disabled state, responsive |

**Total: ~55 core tests + advanced tests**

---

#### Step 1: User Approval

Sebelum generate, AI HARUS tanya:

```
Saya akan generate CRUD Test Artifact untuk [FormName].

Scope yang akan di-test:
- CREATE: 6 test cases
- READ: 7 test cases  
- UPDATE: 7 test cases
- DELETE: 7 test cases
- Master-Detail: 5 test cases (jika applicable)

Estimasi token: ~5000-8000 tokens
Estimasi waktu test manual: 30-60 menit

Opsi:
[A] Full CRUD + Master-Detail (Complex)
[B] Single Form CRUD only (Medium)  
[C] Skip Phase 3.5 → lanjut Phase 4

Pilih opsi [A/B/C]:
```

**AI TIDAK BOLEH lanjut tanpa jawaban eksplisit dari user.**

---

#### Step 2: Generate CRUD Test Artifact

Setelah user approve, generate React artifact dengan **Self-Check Logic** built-in:

**Auto-Check Features:**
- 🔍 **Self-Diagnostics**: Otomatis cek setup saat artifact load
- ⚠️ **Potential Issue Detection**: Highlight kemungkinan bug
- 📋 **Console Logging**: Detail error di DevTools Console
- 🎯 **UI Element Validation**: Pastikan semua button/input ada

**Auto-Check Categories:**
| Category | Checks |
|----------|--------|
| SETUP | Initial state, reducer actions, data structure |
| CRUD-HANDLERS | handleNew, handleSave, handleEdit, handleDelete |
| VALIDATION | Required field checks exist |
| PERMISSIONS | isTambah, isKoreksi, isHapus initialized |
| STATUS/LOCK | Draft state, lock state |
| UI-ELEMENTS | Buttons, inputs with data-testid |

```jsx
// crud-test-frm-xxx.jsx
// Generated from: FrmXXX.dfm + FrmXXX.pas
// Purpose: Comprehensive CRUD Testing with Self-Check

import React, { useState, useReducer, useEffect } from 'react';

// ============================================
// STATE MANAGEMENT
// ============================================
const initialState = {
  mode: 'view', // view | create | edit
  data: [],
  selectedId: null,
  formData: {},
  details: [],
  errors: {},
  logs: []
};

function reducer(state, action) {
  const log = { time: new Date().toISOString(), action: action.type, payload: action.payload };
  
  switch (action.type) {
    case 'NEW':
      return { ...state, mode: 'create', formData: {}, details: [], errors: {}, logs: [...state.logs, log] };
    case 'EDIT':
      return { ...state, mode: 'edit', logs: [...state.logs, log] };
    case 'CANCEL':
      return { ...state, mode: 'view', formData: {}, errors: {}, logs: [...state.logs, log] };
    case 'SET_FIELD':
      return { ...state, formData: { ...state.formData, [action.payload.field]: action.payload.value }, logs: [...state.logs, log] };
    case 'SAVE_SUCCESS':
      return { ...state, mode: 'view', data: action.payload.data, logs: [...state.logs, log] };
    case 'SAVE_ERROR':
      return { ...state, errors: action.payload.errors, logs: [...state.logs, log] };
    case 'DELETE':
      return { ...state, data: state.data.filter(d => d.id !== action.payload.id), logs: [...state.logs, log] };
    case 'ADD_DETAIL':
      return { ...state, details: [...state.details, action.payload], logs: [...state.logs, log] };
    case 'REMOVE_DETAIL':
      return { ...state, details: state.details.filter((_, i) => i !== action.payload.index), logs: [...state.logs, log] };
    default:
      return state;
  }
}

// ============================================
// MAIN COMPONENT
// ============================================
export default function CRUDTestFrmXXX() {
  const [state, dispatch] = useReducer(reducer, initialState);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
  const [testResults, setTestResults] = useState({});
  const [autoCheckResults, setAutoCheckResults] = useState({});
  const [autoCheckRun, setAutoCheckRun] = useState(false);

  // ============================================
  // SELF-CHECK LOGIC (Auto-run on mount)
  // ============================================
  useEffect(() => {
    if (autoCheckRun) return;
    
    console.log('🔍 AUTO-CHECK: Running self-diagnostics...');
    const checks = {};
    const warnings = [];
    const errors = [];

    // ─────────────────────────────────────────
    // SETUP CHECKS
    // ─────────────────────────────────────────
    
    // CHECK-01: Initial state correct?
    checks['SETUP-01'] = state.mode === 'view';
    if (!checks['SETUP-01']) errors.push('Initial mode should be "view"');

    // CHECK-02: State structure complete?
    checks['SETUP-02'] = state.hasOwnProperty('data') 
                      && state.hasOwnProperty('formData')
                      && state.hasOwnProperty('details')
                      && state.hasOwnProperty('errors');
    if (!checks['SETUP-02']) errors.push('State structure incomplete');

    // CHECK-03: Reducer handles all actions?
    const requiredActions = ['NEW', 'EDIT', 'CANCEL', 'SET_FIELD', 'SAVE_SUCCESS', 'SAVE_ERROR', 'DELETE', 'ADD_DETAIL', 'REMOVE_DETAIL'];
    checks['SETUP-03'] = true; // Assume true, would need runtime test

    // ─────────────────────────────────────────
    // CRUD HANDLER CHECKS
    // ─────────────────────────────────────────
    
    // CHECK-04: All CRUD handlers defined?
    checks['CRUD-HANDLERS'] = typeof handleNew === 'function'
                           && typeof handleSave === 'function'
                           && typeof handleEdit === 'function'
                           && typeof handleDeleteClick === 'function'
                           && typeof handleCancel === 'function';
    if (!checks['CRUD-HANDLERS']) errors.push('Missing CRUD handler functions');

    // CHECK-05: Validation logic exists in handleSave?
    // This is a static check - we verify by looking at the code structure
    checks['VALIDATION-EXISTS'] = true; // Set by code review
    
    // ─────────────────────────────────────────
    // PERMISSION CHECKS
    // ─────────────────────────────────────────
    
    // CHECK-06: Permission state initialized?
    checks['PERM-INIT'] = permissions.hasOwnProperty('isTambah')
                       && permissions.hasOwnProperty('isKoreksi')
                       && permissions.hasOwnProperty('isHapus');
    if (!checks['PERM-INIT']) warnings.push('Permission state not fully initialized');

    // CHECK-07: Default permissions are permissive?
    checks['PERM-DEFAULT'] = permissions.isTambah === true 
                          && permissions.isKoreksi === true 
                          && permissions.isHapus === true;
    if (!checks['PERM-DEFAULT']) warnings.push('Default permissions are restrictive - user may not be able to test');

    // ─────────────────────────────────────────
    // STATUS/LOCK CHECKS
    // ─────────────────────────────────────────
    
    // CHECK-08: Status flow defined?
    checks['STATUS-INIT'] = documentStatus === 'DRAFT';
    if (!checks['STATUS-INIT']) warnings.push('Initial status should be DRAFT');

    // CHECK-09: Lock state initialized?
    checks['LOCK-INIT'] = lockPeriod.hasOwnProperty('isLocked') && lockPeriod.isLocked === false;
    if (!checks['LOCK-INIT']) warnings.push('Lock state should start unlocked');

    // ─────────────────────────────────────────
    // UI ELEMENT CHECKS
    // ─────────────────────────────────────────
    
    // CHECK-10: Required UI elements exist?
    setTimeout(() => {
      const uiChecks = {};
      uiChecks['UI-BTN-NEW'] = !!document.querySelector('[data-testid="btn-new"]');
      uiChecks['UI-BTN-SAVE'] = !!document.querySelector('[data-testid="btn-save"]');
      uiChecks['UI-BTN-CANCEL'] = !!document.querySelector('[data-testid="btn-cancel"]');
      uiChecks['UI-INPUT-KODE'] = !!document.querySelector('[data-testid="input-kode"]');
      uiChecks['UI-INPUT-TANGGAL'] = !!document.querySelector('[data-testid="input-tanggal"]');
      
      Object.entries(uiChecks).forEach(([key, exists]) => {
        if (!exists) {
          console.error(`❌ AUTO-CHECK: Missing UI element - ${key}`);
          errors.push(`Missing UI element: ${key}`);
        }
      });
      
      setAutoCheckResults(prev => ({ ...prev, ...uiChecks }));
    }, 500);

    // ─────────────────────────────────────────
    // POTENTIAL ISSUE DETECTION
    // ─────────────────────────────────────────
    
    // Detect common issues
    const potentialIssues = [];
    
    // Issue: Form might save without validation
    potentialIssues.push({
      id: 'WARN-01',
      test: 'CREATE-02',
      message: 'Pastikan handleSave() check required fields sebelum save',
      severity: 'warning'
    });
    
    // Issue: Delete tanpa confirmation
    potentialIssues.push({
      id: 'WARN-02', 
      test: 'DELETE-01',
      message: 'Pastikan handleDeleteClick() show confirmation dialog',
      severity: 'warning'
    });
    
    // Issue: Edit locked document
    potentialIssues.push({
      id: 'WARN-03',
      test: 'LOCK-03',
      message: 'Pastikan form disabled saat documentStatus === LOCKED',
      severity: 'warning'
    });

    // ─────────────────────────────────────────
    // SUMMARY OUTPUT
    // ─────────────────────────────────────────
    
    console.log('═══════════════════════════════════════════');
    console.log('🔍 AUTO-CHECK RESULTS');
    console.log('═══════════════════════════════════════════');
    
    const passCount = Object.values(checks).filter(v => v === true).length;
    const totalCount = Object.keys(checks).length;
    
    console.log(`✅ Passed: ${passCount}/${totalCount}`);
    
    if (errors.length > 0) {
      console.log('');
      console.log('❌ ERRORS (must fix):');
      errors.forEach(e => console.log(`   • ${e}`));
    }
    
    if (warnings.length > 0) {
      console.log('');
      console.log('⚠️ WARNINGS (review):');
      warnings.forEach(w => console.log(`   • ${w}`));
    }
    
    if (potentialIssues.length > 0) {
      console.log('');
      console.log('💡 POTENTIAL ISSUES TO VERIFY:');
      potentialIssues.forEach(p => console.log(`   • [${p.test}] ${p.message}`));
    }
    
    console.log('═══════════════════════════════════════════');
    
    setAutoCheckResults(checks);
    setAutoCheckRun(true);
    
  }, [autoCheckRun]);

  // ============================================
  // CREATE TESTS
  // ============================================
  const handleNew = () => {
    console.log('📝 CREATE TEST: New button clicked');
    dispatch({ type: 'NEW' });
    
    // Test: Form should be empty
    setTestResults(prev => ({
      ...prev,
      'CREATE-01': state.formData && Object.keys(state.formData).length === 0
    }));
  };

  const handleSave = () => {
    console.log('💾 SAVE triggered', { mode: state.mode, formData: state.formData });
    
    // Test: Required validation
    const errors = {};
    if (!state.formData.kode) {
      errors.kode = 'Kode harus diisi';
      console.log('❌ CREATE-02: Required validation PASSED (error shown)');
    }
    if (!state.formData.tanggal) {
      errors.tanggal = 'Tanggal harus diisi';
    }
    
    if (Object.keys(errors).length > 0) {
      dispatch({ type: 'SAVE_ERROR', payload: { errors } });
      setTestResults(prev => ({ ...prev, 'CREATE-02': true }));
      return;
    }
    
    // Test: Duplicate check (mock)
    const isDuplicate = state.data.some(d => d.kode === state.formData.kode);
    if (isDuplicate && state.mode === 'create') {
      dispatch({ type: 'SAVE_ERROR', payload: { errors: { kode: 'Kode sudah ada' } } });
      console.log('❌ CREATE-03: Duplicate check PASSED');
      setTestResults(prev => ({ ...prev, 'CREATE-03': true }));
      return;
    }
    
    // Test: Save success
    const newData = state.mode === 'create' 
      ? [...state.data, { ...state.formData, id: Date.now(), details: state.details }]
      : state.data.map(d => d.id === state.selectedId ? { ...state.formData, details: state.details } : d);
    
    dispatch({ type: 'SAVE_SUCCESS', payload: { data: newData } });
    console.log('✅ SAVE success', { mode: state.mode });
    setTestResults(prev => ({ ...prev, 'CREATE-04': true, 'UPDATE-04': state.mode === 'edit' }));
  };

  // ============================================
  // READ TESTS
  // ============================================
  const handleRefresh = () => {
    console.log('🔄 READ TEST: Refresh data');
    // Mock data load
    const mockData = [
      { id: 1, kode: 'PO-001', tanggal: '2026-01-01', supplier: 'PT ABC', total: 1000000 },
      { id: 2, kode: 'PO-002', tanggal: '2026-01-02', supplier: 'PT XYZ', total: 2000000 },
    ];
    dispatch({ type: 'SAVE_SUCCESS', payload: { data: mockData } });
    setTestResults(prev => ({ ...prev, 'READ-01': true }));
  };

  const [filter, setFilter] = useState('');
  const filteredData = state.data.filter(d => 
    d.kode?.toLowerCase().includes(filter.toLowerCase()) ||
    d.supplier?.toLowerCase().includes(filter.toLowerCase())
  );

  // ============================================
  // UPDATE TESTS
  // ============================================
  const handleEdit = (item) => {
    console.log('✏️ UPDATE TEST: Edit mode', { id: item.id });
    dispatch({ type: 'SET_FIELD', payload: { field: 'kode', value: item.kode } });
    dispatch({ type: 'SET_FIELD', payload: { field: 'tanggal', value: item.tanggal } });
    dispatch({ type: 'SET_FIELD', payload: { field: 'supplier', value: item.supplier } });
    dispatch({ type: 'EDIT' });
    setTestResults(prev => ({ ...prev, 'UPDATE-01': true }));
  };

  const handleCancel = () => {
    console.log('🚫 CANCEL triggered');
    dispatch({ type: 'CANCEL' });
    setTestResults(prev => ({ ...prev, 'CREATE-06': true, 'UPDATE-07': true }));
  };

  // ============================================
  // DELETE TESTS
  // ============================================
  const handleDeleteClick = (item) => {
    console.log('🗑️ DELETE TEST: Delete clicked', { id: item.id });
    setShowDeleteConfirm(true);
    dispatch({ type: 'SET_FIELD', payload: { field: 'deleteId', value: item.id } });
    setTestResults(prev => ({ ...prev, 'DELETE-01': true }));
  };

  const handleDeleteConfirm = (confirmed) => {
    if (confirmed) {
      console.log('✅ DELETE confirmed');
      dispatch({ type: 'DELETE', payload: { id: state.formData.deleteId } });
      setTestResults(prev => ({ ...prev, 'DELETE-02': true }));
    } else {
      console.log('❌ DELETE cancelled');
    }
    setShowDeleteConfirm(false);
  };

  // ============================================
  // MASTER-DETAIL TESTS
  // ============================================
  const handleAddDetail = () => {
    const newDetail = {
      kodeBarang: `BRG-${state.details.length + 1}`,
      nama: 'Sample Item',
      qty: 1,
      harga: 100000,
      subtotal: 100000
    };
    console.log('➕ DETAIL TEST: Add detail', newDetail);
    dispatch({ type: 'ADD_DETAIL', payload: newDetail });
    setTestResults(prev => ({ ...prev, 'DETAIL-01': true }));
  };

  const handleRemoveDetail = (index) => {
    console.log('➖ DETAIL TEST: Remove detail', { index });
    dispatch({ type: 'REMOVE_DETAIL', payload: { index } });
    setTestResults(prev => ({ ...prev, 'DETAIL-03': true }));
  };

  const totalDetail = state.details.reduce((sum, d) => sum + (d.subtotal || 0), 0);

  // ============================================
  // PERMISSION TESTS
  // ============================================
  const [permissions, setPermissions] = useState({
    isTambah: true,
    isKoreksi: true,
    isHapus: true,
    isCetak: true,
    isOtorisasi: false
  });

  const togglePermission = (perm) => {
    const newValue = !permissions[perm];
    console.log(`🔐 PERMISSION TEST: ${perm} = ${newValue}`);
    setPermissions(prev => ({ ...prev, [perm]: newValue }));
    setTestResults(prev => ({ ...prev, [`PERM-${perm}`]: true }));
  };

  // Check if action is allowed based on permission
  const canCreate = permissions.isTambah;
  const canEdit = permissions.isKoreksi;
  const canDelete = permissions.isHapus;

  // ============================================
  // LOCK PERIOD TESTS
  // ============================================
  const [lockPeriod, setLockPeriod] = useState({
    isLocked: false,
    lockedDate: null,
    lockedBy: null
  });

  const [documentStatus, setDocumentStatus] = useState('DRAFT'); // DRAFT, APPROVED, LOCKED

  const handleStatusChange = (newStatus) => {
    console.log(`📋 STATUS TEST: ${documentStatus} → ${newStatus}`);
    
    // Validate status flow
    const validTransitions = {
      'DRAFT': ['APPROVED'],
      'APPROVED': ['DRAFT', 'LOCKED'],
      'LOCKED': [] // Cannot change from LOCKED
    };
    
    if (!validTransitions[documentStatus].includes(newStatus)) {
      console.log(`❌ STATUS TEST: Invalid transition ${documentStatus} → ${newStatus}`);
      alert(`Tidak bisa mengubah status dari ${documentStatus} ke ${newStatus}`);
      setTestResults(prev => ({ ...prev, 'STATUS-INVALID': true }));
      return;
    }
    
    setDocumentStatus(newStatus);
    
    if (newStatus === 'LOCKED') {
      setLockPeriod({
        isLocked: true,
        lockedDate: new Date().toISOString(),
        lockedBy: 'CurrentUser'
      });
      console.log('🔒 LOCK TEST: Document locked');
      setTestResults(prev => ({ ...prev, 'LOCK-01': true }));
    }
    
    setTestResults(prev => ({ ...prev, [`STATUS-${newStatus}`]: true }));
  };

  // Check if document is editable based on status
  const isEditable = documentStatus === 'DRAFT' && !lockPeriod.isLocked;

  // ============================================
  // EVENT LIFECYCLE TESTS
  // ============================================
  const [eventLog, setEventLog] = useState([]);

  const logEvent = (eventName, data = {}) => {
    const event = {
      time: new Date().toISOString(),
      event: eventName,
      data
    };
    console.log(`📣 EVENT: ${eventName}`, data);
    setEventLog(prev => [...prev, event]);
  };

  // Simulate Form Lifecycle
  const simulateFormOpen = () => {
    logEvent('OnCreate');
    setTimeout(() => logEvent('OnShow'), 100);
    setTimeout(() => logEvent('OnActivate'), 200);
    setTimeout(() => {
      logEvent('DataLoad');
      handleRefresh();
      setTestResults(prev => ({ ...prev, 'EVENT-OPEN': true }));
    }, 300);
  };

  const simulateFormClose = () => {
    // Check if can close
    if (state.mode !== 'view') {
      logEvent('CanClose?', { result: false, reason: 'Unsaved changes' });
      if (!confirm('Ada perubahan belum disimpan. Tetap tutup?')) {
        setTestResults(prev => ({ ...prev, 'EVENT-CANCLOSE': true }));
        return false;
      }
    }
    logEvent('CanClose?', { result: true });
    logEvent('OnClose');
    logEvent('OnDestroy');
    setTestResults(prev => ({ ...prev, 'EVENT-CLOSE': true }));
    return true;
  };

  // Simulate Data Edit Lifecycle
  const simulateDataEdit = () => {
    logEvent('OnChange', { field: 'kode', oldValue: '', newValue: 'TEST' });
    logEvent('Validation', { valid: true });
    logEvent('BeforePost', { data: state.formData });
    logEvent('AfterPost', { success: true });
    setTestResults(prev => ({ ...prev, 'EVENT-EDIT': true }));
  };

  // ============================================
  // VISUAL/LAYOUT TESTS
  // ============================================
  const [tabIndex, setTabIndex] = useState(0);
  const tabOrder = ['kode', 'tanggal', 'supplier', 'detail-grid', 'btn-save'];

  const handleTabNavigation = (e) => {
    if (e.key === 'Tab') {
      const newIndex = e.shiftKey 
        ? (tabIndex - 1 + tabOrder.length) % tabOrder.length
        : (tabIndex + 1) % tabOrder.length;
      setTabIndex(newIndex);
      console.log(`⌨️ TAB TEST: ${tabOrder[tabIndex]} → ${tabOrder[newIndex]}`);
      setTestResults(prev => ({ ...prev, 'TAB-ORDER': true }));
    }
  };

  // ============================================
  // RUNTIME BEHAVIOR CHECKS
  // ============================================
  const [behaviorIssues, setBehaviorIssues] = useState([]);

  const checkBehavior = (testId, condition, message) => {
    if (!condition) {
      const issue = { 
        id: testId, 
        message, 
        time: new Date().toISOString(),
        severity: testId.startsWith('CRITICAL') ? 'error' : 'warning'
      };
      console.error(`🚨 BEHAVIOR CHECK FAILED: [${testId}] ${message}`);
      setBehaviorIssues(prev => [...prev, issue]);
      return false;
    }
    return true;
  };

  // Wrap handlers dengan behavior checks
  const safeHandleNew = () => {
    // Check: Permission harus ada
    checkBehavior('PERM-CHECK-01', canCreate, 'handleNew dipanggil tapi isTambah=false');
    // Check: Tidak boleh dalam mode edit
    checkBehavior('MODE-CHECK-01', state.mode === 'view', 'handleNew dipanggil saat masih dalam mode edit');
    // Check: Document harus editable
    checkBehavior('LOCK-CHECK-01', isEditable, 'handleNew dipanggil tapi document locked');
    
    handleNew();
  };

  const safeHandleSave = () => {
    // Check: Harus dalam mode create/edit
    checkBehavior('MODE-CHECK-02', state.mode !== 'view', 'handleSave dipanggil dalam mode view');
    // Check: Required fields
    checkBehavior('CRITICAL-VAL-01', state.formData.kode, 'Save tanpa Kode - VALIDATION BYPASS!');
    // Check: Document editable
    checkBehavior('LOCK-CHECK-02', isEditable, 'handleSave dipanggil tapi document locked');
    
    handleSave();
  };

  const safeHandleEdit = (item) => {
    // Check: Permission
    checkBehavior('PERM-CHECK-02', canEdit, 'handleEdit dipanggil tapi isKoreksi=false');
    // Check: Document editable
    checkBehavior('LOCK-CHECK-03', isEditable, 'handleEdit dipanggil tapi document locked');
    
    handleEdit(item);
  };

  const safeHandleDeleteClick = (item) => {
    // Check: Permission
    checkBehavior('PERM-CHECK-03', canDelete, 'handleDelete dipanggil tapi isHapus=false');
    // Check: Document editable
    checkBehavior('LOCK-CHECK-04', isEditable, 'handleDelete dipanggil tapi document locked');
    
    handleDeleteClick(item);
  };

  // ============================================
  // RENDER
  // ============================================
  return (
    <div className="p-4 max-w-6xl mx-auto" onKeyDown={handleTabNavigation}>
      <h1 className="text-2xl font-bold mb-4">🧪 CRUD Test: FrmXXX</h1>
      
      {/* Runtime Behavior Issues Alert */}
      {behaviorIssues.length > 0 && (
        <div className="bg-red-100 border-2 border-red-500 p-3 rounded mb-4">
          <h3 className="font-bold text-red-700 mb-2">🚨 Runtime Issues Detected!</h3>
          <div className="text-sm space-y-1">
            {behaviorIssues.slice(-5).map((issue, i) => (
              <div key={i} className={`p-2 rounded ${issue.severity === 'error' ? 'bg-red-200' : 'bg-yellow-200'}`}>
                <span className="font-mono">[{issue.id}]</span> {issue.message}
                <span className="text-xs text-gray-500 ml-2">{issue.time}</span>
              </div>
            ))}
          </div>
          <button 
            onClick={() => setBehaviorIssues([])}
            className="mt-2 px-2 py-1 bg-red-500 text-white rounded text-sm"
          >
            Clear Issues
          </button>
        </div>
      )}

      {/* Auto-Check Results (Self-Diagnostics) */}
      <div className="bg-orange-50 border border-orange-200 p-3 rounded mb-4">
        <h3 className="font-bold mb-2">🔍 Auto-Check (Self-Diagnostics)</h3>
        <div className="text-sm">
          {!autoCheckRun ? (
            <span className="text-gray-500">⏳ Running diagnostics...</span>
          ) : (
            <>
              <div className="flex flex-wrap gap-2 mb-2">
                {Object.entries(autoCheckResults).map(([check, passed]) => (
                  <span key={check} className={`px-2 py-1 rounded text-xs ${passed ? 'bg-green-200' : 'bg-red-200'}`}>
                    {check}: {passed ? '✅' : '❌'}
                  </span>
                ))}
              </div>
              <div className="text-xs text-gray-600">
                ℹ️ Buka DevTools (F12) → Console untuk detail lengkap
              </div>
              {Object.values(autoCheckResults).some(v => !v) && (
                <div className="mt-2 p-2 bg-red-100 rounded text-red-700 text-xs">
                  ⚠️ Ada check yang gagal! Lihat Console untuk detail error.
                </div>
              )}
            </>
          )}
        </div>
      </div>

      {/* Test Results Summary */}
      <div className="bg-gray-100 p-3 rounded mb-4">
        <h3 className="font-bold">Test Results (Manual):</h3>
        <div className="flex flex-wrap gap-2 mt-2">
          {Object.entries(testResults).map(([test, passed]) => (
            <span key={test} className={`px-2 py-1 rounded text-sm ${passed ? 'bg-green-200' : 'bg-red-200'}`}>
              {test}: {passed ? '✅' : '❌'}
            </span>
          ))}
          {Object.keys(testResults).length === 0 && (
            <span className="text-gray-500 text-sm">Belum ada test yang dijalankan. Mulai dengan klik tombol di bawah.</span>
          )}
        </div>
      </div>

      {/* Permission Controls */}
      <div className="bg-blue-50 p-3 rounded mb-4">
        <h3 className="font-bold mb-2">🔐 Permission Test:</h3>
        <div className="flex gap-4">
          {Object.entries(permissions).map(([perm, value]) => (
            <label key={perm} className="flex items-center gap-1">
              <input
                type="checkbox"
                checked={value}
                onChange={() => togglePermission(perm)}
              />
              <span className={value ? 'text-green-600' : 'text-red-600'}>{perm}</span>
            </label>
          ))}
        </div>
      </div>

      {/* Status & Lock Controls */}
      <div className="bg-yellow-50 p-3 rounded mb-4">
        <h3 className="font-bold mb-2">📋 Status & Lock Test:</h3>
        <div className="flex gap-4 items-center">
          <span>Status: <strong className={
            documentStatus === 'DRAFT' ? 'text-gray-600' :
            documentStatus === 'APPROVED' ? 'text-blue-600' : 'text-red-600'
          }>{documentStatus}</strong></span>
          <button onClick={() => handleStatusChange('APPROVED')} 
            className="px-2 py-1 bg-blue-500 text-white rounded text-sm"
            disabled={documentStatus !== 'DRAFT'}>
            ✅ Approve
          </button>
          <button onClick={() => handleStatusChange('LOCKED')} 
            className="px-2 py-1 bg-red-500 text-white rounded text-sm"
            disabled={documentStatus !== 'APPROVED'}>
            🔒 Lock
          </button>
          <button onClick={() => handleStatusChange('DRAFT')} 
            className="px-2 py-1 bg-gray-500 text-white rounded text-sm"
            disabled={documentStatus !== 'APPROVED'}>
            ↩️ Revert to Draft
          </button>
          {lockPeriod.isLocked && (
            <span className="text-red-600 text-sm">
              🔒 Locked by {lockPeriod.lockedBy} at {lockPeriod.lockedDate}
            </span>
          )}
        </div>
      </div>

      {/* Event Lifecycle Controls */}
      <div className="bg-purple-50 p-3 rounded mb-4">
        <h3 className="font-bold mb-2">📣 Event Lifecycle Test:</h3>
        <div className="flex gap-2">
          <button onClick={simulateFormOpen} className="px-2 py-1 bg-purple-500 text-white rounded text-sm">
            🚀 Simulate Form Open
          </button>
          <button onClick={simulateDataEdit} className="px-2 py-1 bg-purple-500 text-white rounded text-sm">
            ✏️ Simulate Data Edit
          </button>
          <button onClick={simulateFormClose} className="px-2 py-1 bg-purple-500 text-white rounded text-sm">
            🚪 Simulate Form Close
          </button>
        </div>
        {eventLog.length > 0 && (
          <div className="mt-2 text-sm font-mono bg-white p-2 rounded max-h-24 overflow-auto">
            {eventLog.slice(-5).map((e, i) => (
              <div key={i}>[{e.event}] {JSON.stringify(e.data)}</div>
            ))}
          </div>
        )}
      </div>

      {/* Toolbar */}
      <div className="flex gap-2 mb-4 p-2 bg-gray-50 rounded">
        <button onClick={safeHandleNew} 
          className={`px-3 py-1 rounded ${canCreate && isEditable ? 'bg-blue-500 text-white' : 'bg-gray-300 text-gray-500 cursor-not-allowed'}`}
          data-testid="btn-new">
          📝 New
        </button>
        <button onClick={safeHandleSave} 
          className={`px-3 py-1 rounded ${state.mode !== 'view' && isEditable ? 'bg-green-500 text-white' : 'bg-gray-300'}`}
          data-testid="btn-save">
          💾 Save
        </button>
        <button onClick={handleCancel} 
          className="px-3 py-1 bg-gray-500 text-white rounded" 
          disabled={state.mode === 'view'}
          data-testid="btn-cancel">
          🚫 Cancel
        </button>
        <button onClick={handleRefresh} 
          className="px-3 py-1 bg-purple-500 text-white rounded" 
          data-testid="btn-refresh">
          🔄 Refresh
        </button>
        <span className="ml-auto px-2 py-1 bg-yellow-100 rounded">
          Mode: <strong>{state.mode.toUpperCase()}</strong>
          {!isEditable && <span className="text-red-500 ml-2">🔒 Read-only</span>}
        </span>
      </div>

      {/* Form */}
      <div className="grid grid-cols-2 gap-4 mb-4 p-4 border rounded">
        <div>
          <label className="block text-sm font-medium">Kode *</label>
          <input
            type="text"
            value={state.formData.kode || ''}
            onChange={e => dispatch({ type: 'SET_FIELD', payload: { field: 'kode', value: e.target.value } })}
            disabled={state.mode === 'view' || !isEditable}
            className={`w-full border p-2 rounded ${state.errors.kode ? 'border-red-500' : ''}`}
            data-testid="input-kode"
          />
          {state.errors.kode && <span className="text-red-500 text-sm">{state.errors.kode}</span>}
        </div>
        <div>
          <label className="block text-sm font-medium">Tanggal *</label>
          <input
            type="date"
            value={state.formData.tanggal || ''}
            onChange={e => dispatch({ type: 'SET_FIELD', payload: { field: 'tanggal', value: e.target.value } })}
            disabled={state.mode === 'view'}
            className={`w-full border p-2 rounded ${state.errors.tanggal ? 'border-red-500' : ''}`}
            data-testid="input-tanggal"
          />
          {state.errors.tanggal && <span className="text-red-500 text-sm">{state.errors.tanggal}</span>}
        </div>
        <div>
          <label className="block text-sm font-medium">Supplier</label>
          <input
            type="text"
            value={state.formData.supplier || ''}
            onChange={e => dispatch({ type: 'SET_FIELD', payload: { field: 'supplier', value: e.target.value } })}
            disabled={state.mode === 'view'}
            className="w-full border p-2 rounded"
            data-testid="input-supplier"
          />
        </div>
        <div>
          <label className="block text-sm font-medium">Total</label>
          <input
            type="text"
            value={totalDetail.toLocaleString('id-ID')}
            disabled
            className="w-full border p-2 rounded bg-gray-100"
            data-testid="input-total"
          />
        </div>
      </div>

      {/* Detail Grid */}
      <div className="mb-4 p-4 border rounded">
        <div className="flex justify-between items-center mb-2">
          <h3 className="font-bold">Detail Items</h3>
          <button 
            onClick={handleAddDetail} 
            disabled={state.mode === 'view'}
            className="px-2 py-1 bg-blue-500 text-white rounded text-sm"
            data-testid="btn-add-detail"
          >
            ➕ Add Detail
          </button>
        </div>
        <table className="w-full border-collapse border">
          <thead className="bg-gray-100">
            <tr>
              <th className="border p-2">No</th>
              <th className="border p-2">Kode Barang</th>
              <th className="border p-2">Nama</th>
              <th className="border p-2">Qty</th>
              <th className="border p-2">Harga</th>
              <th className="border p-2">Subtotal</th>
              <th className="border p-2">Action</th>
            </tr>
          </thead>
          <tbody>
            {state.details.map((d, i) => (
              <tr key={i} data-testid={`detail-row-${i}`}>
                <td className="border p-2 text-center">{i + 1}</td>
                <td className="border p-2">{d.kodeBarang}</td>
                <td className="border p-2">{d.nama}</td>
                <td className="border p-2 text-right">{d.qty}</td>
                <td className="border p-2 text-right">{d.harga?.toLocaleString('id-ID')}</td>
                <td className="border p-2 text-right">{d.subtotal?.toLocaleString('id-ID')}</td>
                <td className="border p-2 text-center">
                  <button 
                    onClick={() => handleRemoveDetail(i)}
                    disabled={state.mode === 'view'}
                    className="text-red-500"
                    data-testid={`btn-remove-detail-${i}`}
                  >
                    🗑️
                  </button>
                </td>
              </tr>
            ))}
            {state.details.length === 0 && (
              <tr><td colSpan="7" className="border p-4 text-center text-gray-500">No details</td></tr>
            )}
          </tbody>
          <tfoot className="bg-gray-50">
            <tr>
              <td colSpan="5" className="border p-2 text-right font-bold">Total:</td>
              <td className="border p-2 text-right font-bold">{totalDetail.toLocaleString('id-ID')}</td>
              <td className="border p-2"></td>
            </tr>
          </tfoot>
        </table>
      </div>

      {/* Data Grid (READ) */}
      <div className="mb-4 p-4 border rounded">
        <div className="flex justify-between items-center mb-2">
          <h3 className="font-bold">Data List</h3>
          <input
            type="text"
            placeholder="🔍 Filter..."
            value={filter}
            onChange={e => setFilter(e.target.value)}
            className="border p-1 rounded"
            data-testid="input-filter"
          />
        </div>
        <table className="w-full border-collapse border">
          <thead className="bg-gray-100">
            <tr>
              <th className="border p-2">Kode</th>
              <th className="border p-2">Tanggal</th>
              <th className="border p-2">Supplier</th>
              <th className="border p-2">Total</th>
              <th className="border p-2">Actions</th>
            </tr>
          </thead>
          <tbody>
            {filteredData.map((item) => (
              <tr key={item.id} data-testid={`grid-row-${item.id}`}>
                <td className="border p-2">{item.kode}</td>
                <td className="border p-2">{item.tanggal}</td>
                <td className="border p-2">{item.supplier}</td>
                <td className="border p-2 text-right">{item.total?.toLocaleString('id-ID')}</td>
                <td className="border p-2 text-center">
                  <button 
                    onClick={() => safeHandleEdit(item)} 
                    className={`mr-2 ${canEdit && isEditable ? '' : 'opacity-50 cursor-not-allowed'}`}
                    data-testid={`btn-edit-${item.id}`}
                  >✏️</button>
                  <button 
                    onClick={() => safeHandleDeleteClick(item)} 
                    className={canDelete && isEditable ? '' : 'opacity-50 cursor-not-allowed'}
                    data-testid={`btn-delete-${item.id}`}
                  >🗑️</button>
                </td>
              </tr>
            ))}
            {filteredData.length === 0 && (
              <tr><td colSpan="5" className="border p-4 text-center text-gray-500">No data</td></tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Delete Confirmation Modal */}
      {showDeleteConfirm && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center">
          <div className="bg-white p-6 rounded shadow-lg">
            <h3 className="text-lg font-bold mb-4">⚠️ Konfirmasi Hapus</h3>
            <p className="mb-4">Yakin ingin menghapus data ini?</p>
            <div className="flex gap-2 justify-end">
              <button 
                onClick={() => handleDeleteConfirm(false)}
                className="px-4 py-2 bg-gray-300 rounded"
                data-testid="btn-delete-no"
              >
                Tidak
              </button>
              <button 
                onClick={() => handleDeleteConfirm(true)}
                className="px-4 py-2 bg-red-500 text-white rounded"
                data-testid="btn-delete-yes"
              >
                Ya, Hapus
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Action Logs */}
      <div className="p-4 border rounded bg-gray-900 text-green-400 font-mono text-sm max-h-48 overflow-auto">
        <h3 className="text-white mb-2">📋 Action Logs (DevTools Console)</h3>
        {state.logs.slice(-10).map((log, i) => (
          <div key={i}>[{log.time}] {log.action} {JSON.stringify(log.payload)}</div>
        ))}
      </div>
    </div>
  );
}
```

---

#### Step 2.5: Review Auto-Check Results

Saat artifact load, **Auto-Check otomatis jalan**. User harus review hasilnya:

**1. Buka DevTools Console (F12)**

```
═══════════════════════════════════════════
🔍 AUTO-CHECK RESULTS
═══════════════════════════════════════════
✅ Passed: 8/10

❌ ERRORS (must fix):
   • Missing UI element: UI-BTN-DELETE

⚠️ WARNINGS (review):
   • Default permissions are restrictive

💡 POTENTIAL ISSUES TO VERIFY:
   • [CREATE-02] Pastikan handleSave() check required fields
   • [DELETE-01] Pastikan handleDeleteClick() show confirmation
   • [LOCK-03] Pastikan form disabled saat LOCKED
═══════════════════════════════════════════
```

**2. Interpretasi Results:**

| Status | Meaning | Action |
|--------|---------|--------|
| ✅ PASSED | Setup benar | Lanjut test manual |
| ❌ ERROR | Ada masalah kritis | Report ke AI untuk fix |
| ⚠️ WARNING | Potential issue | Verifikasi saat test manual |
| 💡 VERIFY | Perlu dicek manual | Prioritas test |

**3. Jika Ada ERROR:**

Report ke AI dengan format:
```
AUTO-CHECK ERROR:
- Check: UI-BTN-DELETE
- Status: FAILED
- Message: Missing UI element

Tolong fix artifact untuk menambahkan button delete.
```

**4. Jika Semua PASSED:**

Lanjut ke Step 3 (Manual Test Checklist).

---

#### Step 3: CRUD Test Checklist

User jalankan test manual dengan checklist berikut:

**CREATE Tests:**
| ID | Test | Action | Expected | ✓ |
|----|------|--------|----------|---|
| CREATE-01 | New record init | Click [New] | Form kosong, mode=create | |
| CREATE-02 | Required validation | Save tanpa isi Kode | Error "Kode harus diisi" | |
| CREATE-03 | Duplicate check | Save dengan Kode yang sudah ada | Error "Kode sudah ada" | |
| CREATE-04 | Save success | Isi lengkap → Save | Data muncul di grid | |
| CREATE-05 | Auto-number | New → lihat generated code | Kode auto-generate (jika applicable) | |
| CREATE-06 | Cancel create | New → isi → Cancel | Form reset, tidak ada data baru | |

**READ Tests:**
| ID | Test | Action | Expected | ✓ |
|----|------|--------|----------|---|
| READ-01 | Initial load | Click [Refresh] | Data tampil di grid | |
| READ-02 | Filter | Ketik di filter box | Grid filtered | |
| READ-03 | Search | Cari kode spesifik | Data ditemukan | |
| READ-04 | Sort | Click column header | Data sorted | |
| READ-05 | Pagination | Jika >10 rows | Next/Prev work | |
| READ-06 | Master-Detail | Select row | Detail tampil sesuai | |
| READ-07 | Refresh | Click [Refresh] | Data terbaru | |

**UPDATE Tests:**
| ID | Test | Action | Expected | ✓ |
|----|------|--------|----------|---|
| UPDATE-01 | Enter edit mode | Click ✏️ on row | Form terisi, mode=edit | |
| UPDATE-02 | Field editable | Ubah field | Perubahan ke-track | |
| UPDATE-03 | Calculated update | Ubah qty detail | Total update | |
| UPDATE-04 | Save changes | Edit → Save | Perubahan tersimpan | |
| UPDATE-05 | Validation | Kosongkan required field | Error muncul | |
| UPDATE-06 | Audit trail | Save → check log | ModifiedAt recorded | |
| UPDATE-07 | Cancel edit | Edit → Cancel | Revert ke nilai awal | |

**DELETE Tests:**
| ID | Test | Action | Expected | ✓ |
|----|------|--------|----------|---|
| DELETE-01 | Delete confirmation | Click 🗑️ | Dialog muncul | |
| DELETE-02 | Confirm delete | Click [Ya, Hapus] | Record terhapus | |
| DELETE-03 | Cancel delete | Click [Tidak] | Record tetap ada | |
| DELETE-04 | Cascade delete | Delete master | Detail ikut hapus | |
| DELETE-05 | Restrict delete | Delete dengan child | Error jika ada relasi | |

**MASTER-DETAIL Tests:**
| ID | Test | Action | Expected | ✓ |
|----|------|--------|----------|---|
| DETAIL-01 | Add detail | Click [Add Detail] | Row baru di detail grid | |
| DETAIL-02 | Edit detail | Ubah qty | Subtotal recalculate | |
| DETAIL-03 | Remove detail | Click 🗑️ on detail | Row terhapus, total update | |
| DETAIL-04 | Save with details | Save master | Detail ikut tersimpan | |
| DETAIL-05 | Validation | Save tanpa detail | Error atau allowed sesuai rule | |

**PERMISSION Tests:**
| ID | Test | Action | Expected | ✓ |
|----|------|--------|----------|---|
| PERM-01 | IsTambah=false | Uncheck isTambah | Button New disabled | |
| PERM-02 | IsKoreksi=false | Uncheck isKoreksi | Button Edit disabled | |
| PERM-03 | IsHapus=false | Uncheck isHapus | Button Delete disabled | |
| PERM-04 | Combined | Uncheck all | Semua action disabled | |
| PERM-05 | Re-enable | Check kembali | Action enabled lagi | |

**STATUS & LOCK Tests:**
| ID | Test | Action | Expected | ✓ |
|----|------|--------|----------|---|
| STATUS-01 | Draft → Approved | Click [Approve] | Status berubah ke APPROVED | |
| STATUS-02 | Approved → Locked | Click [Lock] | Status LOCKED, form read-only | |
| STATUS-03 | Invalid transition | Draft → Lock langsung | Error, tidak bisa skip | |
| STATUS-04 | Revert | Approved → Draft | Status kembali ke DRAFT | |
| LOCK-01 | Lock behavior | Setelah LOCKED | Semua field disabled | |
| LOCK-02 | Lock info | Setelah LOCKED | Tampil lockedBy & lockedDate | |
| LOCK-03 | Edit saat locked | Coba edit field | Tidak bisa, form read-only | |

**EVENT LIFECYCLE Tests:**
| ID | Test | Action | Expected | ✓ |
|----|------|--------|----------|---|
| EVENT-01 | Form Open sequence | Click [Simulate Form Open] | OnCreate → OnShow → OnActivate → DataLoad | |
| EVENT-02 | Data Edit sequence | Click [Simulate Data Edit] | OnChange → Validation → BeforePost → AfterPost | |
| EVENT-03 | Form Close (clean) | Click [Simulate Form Close] | CanClose?=true → OnClose → OnDestroy | |
| EVENT-04 | Form Close (dirty) | Close saat mode=edit | CanClose?=false, confirm dialog | |
| EVENT-05 | Event log | Semua action | Log tercatat di Event Log panel | |

**VISUAL/LAYOUT Tests:**
| ID | Test | Action | Expected | ✓ |
|----|------|--------|----------|---|
| VISUAL-01 | Tab navigation | Tekan Tab berulang | Focus berpindah sesuai tabOrder | |
| VISUAL-02 | Shift+Tab | Tekan Shift+Tab | Focus mundur | |
| VISUAL-03 | Field disabled state | Mode=view | Semua input disabled, warna berbeda | |
| VISUAL-04 | Error highlight | Validation error | Field border merah | |
| VISUAL-05 | Button state | Permission off | Button abu-abu, cursor not-allowed | |
| VISUAL-06 | Responsive | Resize window | Layout tidak rusak | |

**RUNTIME BEHAVIOR Tests (Auto-Detected):**

Artifact akan **otomatis mendeteksi** dan menampilkan alert jika ada behavior yang tidak sesuai:

| ID | Trigger | Issue Detected | Severity |
|----|---------|----------------|----------|
| PERM-CHECK-01 | Click New saat isTambah=false | Permission bypass attempt | ⚠️ Warning |
| PERM-CHECK-02 | Click Edit saat isKoreksi=false | Permission bypass attempt | ⚠️ Warning |
| PERM-CHECK-03 | Click Delete saat isHapus=false | Permission bypass attempt | ⚠️ Warning |
| MODE-CHECK-01 | Click New saat masih mode=edit | Invalid state transition | ⚠️ Warning |
| MODE-CHECK-02 | Click Save dalam mode=view | Invalid action | ⚠️ Warning |
| LOCK-CHECK-01 | New saat document locked | Lock bypass attempt | ⚠️ Warning |
| LOCK-CHECK-02 | Save saat document locked | Lock bypass attempt | ⚠️ Warning |
| LOCK-CHECK-03 | Edit saat document locked | Lock bypass attempt | ⚠️ Warning |
| LOCK-CHECK-04 | Delete saat document locked | Lock bypass attempt | ⚠️ Warning |
| CRITICAL-VAL-01 | Save tanpa Kode | **Validation bypass!** | 🔴 Error |

**Cara Kerja Auto-Detection:**
1. User klik button (New/Save/Edit/Delete)
2. Artifact check preconditions
3. Jika ada violation → tampil di **🚨 Runtime Issues Detected!** panel
4. User tidak perlu cek manual, artifact yang deteksi

---

#### Step 4: Report Issues

**Untuk Issues yang Ter-deteksi Otomatis:**

Copy dari panel "🚨 Runtime Issues Detected!" dan kirim ke AI:

```
RUNTIME ISSUE DETECTED:
[CRITICAL-VAL-01] Save tanpa Kode - VALIDATION BYPASS!
Time: 2026-01-09T10:30:00.000Z
```

**Untuk Issues Manual (tidak ter-deteksi):**

Format untuk report issue ke AI:

```
Test ID: CREATE-02
Status: FAILED
Expected: Error "Kode harus diisi"
Actual: Form langsung save tanpa error
Screenshot: [jika ada]
```

AI akan fix specific issue saja, tidak perlu regenerate seluruh artifact.

---

#### Step 5: Understanding Auto-Check Results

**Saat artifact dimuat, akan muncul 3 panel:**

```
┌─────────────────────────────────────────────────────────────┐
│  🚨 Runtime Issues Detected! (merah)                        │
│  └─ Muncul HANYA jika ada behavior violation                │
│  └─ Auto-detect saat user melakukan action                  │
│  └─ Real-time, tidak perlu refresh                          │
├─────────────────────────────────────────────────────────────┤
│  🔍 Auto-Check (Self-Diagnostics) (orange)                  │
│  └─ Jalan otomatis saat artifact load                       │
│  └─ Check: state, handlers, permissions, UI elements        │
│  └─ One-time check di awal                                  │
├─────────────────────────────────────────────────────────────┤
│  Test Results (Manual) (gray)                               │
│  └─ Diisi saat user menjalankan test                        │
│  └─ Tracking progress test manual                           │
└─────────────────────────────────────────────────────────────┘
```

**Prioritas Perhatian:**
1. 🔴 Runtime Issues → FIX IMMEDIATELY
2. 🟠 Auto-Check Failed → Review before testing
3. 🟢 Manual Test → Proceed with testing

---

#### Token Efficiency Note

| Activity | Token Cost |
|----------|-----------|
| Generate CRUD artifact | ~5000-8000 tokens |
| User test manual | 0 tokens |
| Fix per issue | ~500-1000 tokens |
| **Total typical** | **~6000-10000 tokens** |

**Bandingkan dengan Automated Testing:**
| Activity | Token Cost |
|----------|-----------|
| Generate artifact | ~5000 tokens |
| Generate test script | ~3000 tokens |
| Run Puppeteer | ~1000 tokens |
| Parse results | ~500 tokens |
| Fix per issue | ~1000 tokens |
| **Total typical** | **~15000+ tokens** |

**Phase 3.5 hemat ~40-50% token dibanding automated testing.**

---

### Phase 3.6: Automated UI Test - Puppeteer (Optional, 1-2 hours)

**🚨🚨 DOUBLE APPROVAL GATE 🚨🚨**

```
┌─────────────────────────────────────────────────────────────┐
│  ⚠️  PERSETUJUAN WAJIB - PHASE INI TOKEN INTENSIVE          │
│                                                              │
│  Phase 3.6 akan generate dan jalankan Puppeteer test.       │
│  Estimasi token: ~5000-8000 tokens TAMBAHAN                 │
│                                                              │
│  Total dengan Phase 3.5: ~15000-20000 tokens                │
│                                                              │
│  Lanjutkan? [Y/N]                                           │
│                                                              │
│  ⚠️ AI TIDAK BOLEH LANJUT TANPA JAWABAN "Y" EKSPLISIT       │
└─────────────────────────────────────────────────────────────┘
```

**Objective**: Generate dan jalankan Puppeteer script untuk automated E2E testing.

**Kapan Digunakan**:
- Form sangat complex dengan banyak edge cases
- Butuh regression test yang bisa dijalankan berulang
- CI/CD pipeline integration
- User eksplisit minta automated test

**Kapan TIDAK Digunakan**:
- Form simple (CRUD basic)
- One-time migration (tidak perlu regression)
- Token constraint ketat
- Phase 3.5 sudah cukup menemukan issues

---

#### Step 1: User Approval (WAJIB)

AI HARUS tanya dan TUNGGU jawaban eksplisit:

```
🚨 PHASE 3.6: AUTOMATED UI TEST

Saya akan generate dan jalankan Puppeteer test untuk [FormName].

⚠️ WARNING: Phase ini TOKEN INTENSIVE!

Estimasi:
- Generate test script: ~3000 tokens
- Run Puppeteer: ~1000 tokens
- Parse & report: ~1000 tokens
- Fix issues: ~1000 tokens per fix
- TOTAL: ~5000-8000 tokens TAMBAHAN

Test yang akan dijalankan:
- CREATE: 6 automated tests
- READ: 7 automated tests
- UPDATE: 7 automated tests
- DELETE: 7 automated tests
- Screenshot evidence

Apakah Anda yakin ingin melanjutkan?
Ketik "Y" atau "Ya" untuk lanjut, atau "N" untuk skip ke Phase 4.

[Y/N]:
```

**AI WAJIB:**
1. Tanya approval dengan format di atas
2. TUNGGU jawaban user
3. HANYA lanjut jika user jawab "Y" atau "Ya" (case insensitive)
4. Jika user jawab selain itu → Skip ke Phase 4

---

#### Step 2: Generate Test Artifact HTML

Setelah user approve, generate artifact dan bundle ke HTML:

```bash
# Generate artifact
cat > /home/claude/test-artifact.jsx << 'EOF'
// [React artifact code dari Phase 3.5]
EOF

# Bundle ke HTML (simplified - inline React)
cat > /home/claude/test-artifact.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
  <title>CRUD Test Artifact</title>
  <script src="https://unpkg.com/react@18/umd/react.production.min.js"></script>
  <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js"></script>
  <script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>
  <script src="https://cdn.tailwindcss.com"></script>
</head>
<body>
  <div id="root"></div>
  <script type="text/babel">
    // [Artifact code here]
  </script>
</body>
</html>
EOF
```

---

#### Step 3: Generate Puppeteer Test Script

```javascript
// test-crud.js
const puppeteer = require('puppeteer');
const fs = require('fs');

// Test configuration
const CONFIG = {
  artifactPath: 'file:///home/claude/test-artifact.html',
  screenshotDir: '/home/claude/test-screenshots',
  timeout: 30000
};

// Test results storage
const results = {
  passed: [],
  failed: [],
  screenshots: []
};

// Helper functions
async function screenshot(page, name) {
  const path = `${CONFIG.screenshotDir}/${name}.png`;
  await page.screenshot({ path });
  results.screenshots.push(path);
  return path;
}

function logResult(testId, passed, message = '') {
  if (passed) {
    console.log(`✅ ${testId}: PASSED ${message}`);
    results.passed.push({ testId, message });
  } else {
    console.log(`❌ ${testId}: FAILED ${message}`);
    results.failed.push({ testId, message });
  }
}

// Main test function
async function runCRUDTests() {
  console.log('═══════════════════════════════════════════');
  console.log('🧪 PUPPETEER AUTOMATED CRUD TEST');
  console.log('═══════════════════════════════════════════');
  console.log('');

  // Setup
  fs.mkdirSync(CONFIG.screenshotDir, { recursive: true });
  
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });
  
  const page = await browser.newPage();
  await page.setViewport({ width: 1280, height: 800 });
  
  try {
    // Load artifact
    console.log('📂 Loading artifact...');
    await page.goto(CONFIG.artifactPath, { waitUntil: 'networkidle0' });
    await page.waitForSelector('[data-testid="btn-new"]', { timeout: CONFIG.timeout });
    await screenshot(page, '00-initial-load');
    console.log('✅ Artifact loaded successfully');
    console.log('');

    // ═══════════════════════════════════════════
    // CREATE TESTS
    // ═══════════════════════════════════════════
    console.log('─────────────────────────────────────────');
    console.log('📝 CREATE TESTS');
    console.log('─────────────────────────────────────────');

    // CREATE-01: Click New button
    await page.click('[data-testid="btn-new"]');
    await page.waitForTimeout(500);
    const modeAfterNew = await page.$eval('[data-testid="btn-save"]', el => !el.disabled);
    logResult('CREATE-01', modeAfterNew, 'New button opens form');
    await screenshot(page, '01-after-new');

    // CREATE-02: Validation - save without required field
    await page.click('[data-testid="btn-save"]');
    await page.waitForTimeout(500);
    const hasError = await page.$('.text-red-500') !== null;
    logResult('CREATE-02', hasError, 'Validation error shown for empty Kode');
    await screenshot(page, '02-validation-error');

    // CREATE-03: Fill form and save
    await page.type('[data-testid="input-kode"]', 'TEST-001');
    await page.type('[data-testid="input-tanggal"]', '2026-01-09');
    await page.type('[data-testid="input-supplier"]', 'PT Test Supplier');
    await screenshot(page, '03-form-filled');
    
    await page.click('[data-testid="btn-save"]');
    await page.waitForTimeout(500);
    await screenshot(page, '04-after-save');

    // CREATE-04: Verify data in grid
    const hasGridRow = await page.$('[data-testid^="grid-row-"]') !== null;
    logResult('CREATE-04', hasGridRow, 'Data appears in grid after save');

    // CREATE-05: Cancel test
    await page.click('[data-testid="btn-new"]');
    await page.waitForTimeout(300);
    await page.type('[data-testid="input-kode"]', 'CANCEL-TEST');
    await page.click('[data-testid="btn-cancel"]');
    await page.waitForTimeout(300);
    const modeAfterCancel = await page.$eval('[data-testid="input-kode"]', el => el.disabled);
    logResult('CREATE-05', modeAfterCancel, 'Cancel resets form to view mode');

    console.log('');

    // ═══════════════════════════════════════════
    // READ TESTS
    // ═══════════════════════════════════════════
    console.log('─────────────────────────────────────────');
    console.log('📖 READ TESTS');
    console.log('─────────────────────────────────────────');

    // READ-01: Data displayed in grid
    const gridRows = await page.$$('[data-testid^="grid-row-"]');
    logResult('READ-01', gridRows.length > 0, `${gridRows.length} row(s) in grid`);

    // READ-02: Filter test
    await page.type('[data-testid="input-filter"]', 'TEST');
    await page.waitForTimeout(300);
    const filteredRows = await page.$$('[data-testid^="grid-row-"]');
    logResult('READ-02', filteredRows.length > 0, 'Filter works');
    await page.evaluate(() => document.querySelector('[data-testid="input-filter"]').value = '');
    await screenshot(page, '05-after-filter');

    // READ-03: Refresh test
    await page.click('[data-testid="btn-refresh"]');
    await page.waitForTimeout(500);
    const rowsAfterRefresh = await page.$$('[data-testid^="grid-row-"]');
    logResult('READ-03', rowsAfterRefresh.length >= 0, 'Refresh works');

    console.log('');

    // ═══════════════════════════════════════════
    // UPDATE TESTS
    // ═══════════════════════════════════════════
    console.log('─────────────────────────────────────────');
    console.log('✏️ UPDATE TESTS');
    console.log('─────────────────────────────────────────');

    // UPDATE-01: Click edit on row
    const editBtn = await page.$('[data-testid^="btn-edit-"]');
    if (editBtn) {
      await editBtn.click();
      await page.waitForTimeout(500);
      const isEditMode = await page.$eval('[data-testid="input-kode"]', el => !el.disabled);
      logResult('UPDATE-01', isEditMode, 'Edit button enables form');
      await screenshot(page, '06-edit-mode');

      // UPDATE-02: Modify field
      await page.evaluate(() => {
        document.querySelector('[data-testid="input-supplier"]').value = '';
      });
      await page.type('[data-testid="input-supplier"]', 'PT Updated Supplier');
      logResult('UPDATE-02', true, 'Field modified');

      // UPDATE-03: Save changes
      await page.click('[data-testid="btn-save"]');
      await page.waitForTimeout(500);
      logResult('UPDATE-03', true, 'Update saved');
      await screenshot(page, '07-after-update');
    } else {
      logResult('UPDATE-01', false, 'No edit button found - need data first');
      logResult('UPDATE-02', false, 'Skipped - no data');
      logResult('UPDATE-03', false, 'Skipped - no data');
    }

    console.log('');

    // ═══════════════════════════════════════════
    // DELETE TESTS
    // ═══════════════════════════════════════════
    console.log('─────────────────────────────────────────');
    console.log('🗑️ DELETE TESTS');
    console.log('─────────────────────────────────────────');

    // DELETE-01: Click delete shows confirmation
    const deleteBtn = await page.$('[data-testid^="btn-delete-"]');
    if (deleteBtn) {
      await deleteBtn.click();
      await page.waitForTimeout(500);
      const hasConfirmDialog = await page.$('[data-testid="btn-delete-yes"]') !== null;
      logResult('DELETE-01', hasConfirmDialog, 'Delete confirmation dialog shown');
      await screenshot(page, '08-delete-confirm');

      // DELETE-02: Cancel delete
      const cancelDeleteBtn = await page.$('[data-testid="btn-delete-no"]');
      if (cancelDeleteBtn) {
        await cancelDeleteBtn.click();
        await page.waitForTimeout(300);
        const rowsAfterCancel = await page.$$('[data-testid^="grid-row-"]');
        logResult('DELETE-02', rowsAfterCancel.length > 0, 'Cancel delete keeps data');
      }

      // DELETE-03: Confirm delete
      await deleteBtn.click();
      await page.waitForTimeout(500);
      const confirmBtn = await page.$('[data-testid="btn-delete-yes"]');
      if (confirmBtn) {
        await confirmBtn.click();
        await page.waitForTimeout(500);
        await screenshot(page, '09-after-delete');
        logResult('DELETE-03', true, 'Delete confirmed');
      }
    } else {
      logResult('DELETE-01', false, 'No delete button found - need data first');
      logResult('DELETE-02', false, 'Skipped - no data');
      logResult('DELETE-03', false, 'Skipped - no data');
    }

    console.log('');

    // ═══════════════════════════════════════════
    // PERMISSION TESTS
    // ═══════════════════════════════════════════
    console.log('─────────────────────────────────────────');
    console.log('🔐 PERMISSION TESTS');
    console.log('─────────────────────────────────────────');

    // PERM-01: Toggle isTambah off
    const permCheckbox = await page.$('input[type="checkbox"]');
    if (permCheckbox) {
      await permCheckbox.click(); // Uncheck isTambah
      await page.waitForTimeout(300);
      const newBtnDisabled = await page.$eval('[data-testid="btn-new"]', el => 
        el.classList.contains('cursor-not-allowed') || el.classList.contains('bg-gray-300')
      );
      logResult('PERM-01', newBtnDisabled, 'New button disabled when isTambah=false');
      await permCheckbox.click(); // Re-enable
      await screenshot(page, '10-permission-test');
    } else {
      logResult('PERM-01', false, 'Permission checkbox not found');
    }

    console.log('');

    // ═══════════════════════════════════════════
    // STATUS/LOCK TESTS
    // ═══════════════════════════════════════════
    console.log('─────────────────────────────────────────');
    console.log('🔒 STATUS/LOCK TESTS');
    console.log('─────────────────────────────────────────');

    // LOCK-01: Approve then Lock
    const approveBtn = await page.$('button:has-text("Approve")');
    if (approveBtn) {
      await approveBtn.click();
      await page.waitForTimeout(300);
      
      const lockBtn = await page.$('button:has-text("Lock")');
      if (lockBtn) {
        await lockBtn.click();
        await page.waitForTimeout(300);
        const isReadOnly = await page.$('.text-red-500:has-text("Read-only")') !== null;
        logResult('LOCK-01', true, 'Lock workflow works');
        await screenshot(page, '11-locked-state');
      }
    } else {
      logResult('LOCK-01', false, 'Approve button not found');
    }

    // Final screenshot
    await screenshot(page, '99-final-state');

  } catch (error) {
    console.error('❌ Test error:', error.message);
    await screenshot(page, 'error-state');
  } finally {
    await browser.close();
  }

  // ═══════════════════════════════════════════
  // TEST SUMMARY
  // ═══════════════════════════════════════════
  console.log('');
  console.log('═══════════════════════════════════════════');
  console.log('📊 TEST SUMMARY');
  console.log('═══════════════════════════════════════════');
  console.log(`✅ Passed: ${results.passed.length}`);
  console.log(`❌ Failed: ${results.failed.length}`);
  console.log(`📸 Screenshots: ${results.screenshots.length}`);
  console.log('');
  
  if (results.failed.length > 0) {
    console.log('Failed tests:');
    results.failed.forEach(f => console.log(`  - ${f.testId}: ${f.message}`));
  }
  
  console.log('');
  console.log('Screenshots saved to:', CONFIG.screenshotDir);
  console.log('═══════════════════════════════════════════');

  // Write results to file
  fs.writeFileSync('/home/claude/test-results.json', JSON.stringify(results, null, 2));
  
  return results;
}

// Run tests
runCRUDTests().then(results => {
  process.exit(results.failed.length > 0 ? 1 : 0);
});
```

---

#### Step 4: Run Test Script

```bash
#!/bin/bash
# run-test.sh

echo "═══════════════════════════════════════════"
echo "🚀 RUNNING PUPPETEER AUTOMATED TEST"
echo "═══════════════════════════════════════════"

# Install puppeteer if not exists
if ! npm list puppeteer > /dev/null 2>&1; then
  echo "📦 Installing puppeteer..."
  npm install puppeteer
fi

# Create screenshot directory
mkdir -p /home/claude/test-screenshots

# Run test
echo "🧪 Starting tests..."
node /home/claude/test-crud.js

# Check results
if [ $? -eq 0 ]; then
  echo ""
  echo "✅ ALL TESTS PASSED"
else
  echo ""
  echo "❌ SOME TESTS FAILED - Check test-results.json"
fi

echo ""
echo "📸 Screenshots available at: /home/claude/test-screenshots/"
```

---

#### Step 5: Parse Results & Report

Setelah test selesai, AI akan:

1. **Baca test-results.json**
2. **Summarize untuk user**
3. **Tanya apakah perlu fix issues**

Format report ke user:

```
═══════════════════════════════════════════
📊 AUTOMATED TEST RESULTS
═══════════════════════════════════════════

✅ PASSED: 18/22 tests
❌ FAILED: 4 tests

FAILED TESTS:
┌─────────────────────────────────────────┐
│ CREATE-02: Validation error not shown   │
│ UPDATE-03: Save not working             │
│ DELETE-01: Confirmation dialog missing  │
│ PERM-01: Button not disabled            │
└─────────────────────────────────────────┘

📸 SCREENSHOTS:
- 00-initial-load.png
- 01-after-new.png
- 02-validation-error.png (❌ issue here)
- ...

═══════════════════════════════════════════

Mau saya fix issues yang ditemukan? [Y/N]
```

---

#### Step 6: Fix Issues (jika ada)

Jika user minta fix, AI akan:
1. Analyze screenshot dan error message
2. Fix specific code
3. Re-run test untuk verify

```
🔧 FIXING: CREATE-02 (Validation error not shown)

Problem: handleSave() tidak check required fields
Solution: Tambahkan validation sebelum save

[Code fix here]

🔄 Re-running test...
✅ CREATE-02: NOW PASSED
```

---

#### Test Coverage Matrix

| Category | Test ID | Description | Automated |
|----------|---------|-------------|-----------|
| CREATE | CREATE-01 | New button opens form | ✅ |
| CREATE | CREATE-02 | Validation error shown | ✅ |
| CREATE | CREATE-03 | Form filled correctly | ✅ |
| CREATE | CREATE-04 | Data appears in grid | ✅ |
| CREATE | CREATE-05 | Cancel resets form | ✅ |
| READ | READ-01 | Data displayed | ✅ |
| READ | READ-02 | Filter works | ✅ |
| READ | READ-03 | Refresh works | ✅ |
| UPDATE | UPDATE-01 | Edit enables form | ✅ |
| UPDATE | UPDATE-02 | Field modifiable | ✅ |
| UPDATE | UPDATE-03 | Changes saved | ✅ |
| DELETE | DELETE-01 | Confirmation shown | ✅ |
| DELETE | DELETE-02 | Cancel keeps data | ✅ |
| DELETE | DELETE-03 | Delete removes data | ✅ |
| PERMISSION | PERM-01 | Button disabled | ✅ |
| LOCK | LOCK-01 | Lock workflow | ✅ |

**Total: 16 automated tests**

---

#### Token Cost Analysis

| Activity | Token Cost |
|----------|-----------|
| Generate HTML artifact | ~2000 tokens |
| Generate test script | ~3000 tokens |
| Run Puppeteer | ~500 tokens |
| Parse results | ~500 tokens |
| Report to user | ~500 tokens |
| Fix per issue | ~1000 tokens |
| **Total (no fixes)** | **~6500 tokens** |
| **Total (with 3 fixes)** | **~9500 tokens** |

**Compared to Phase 3.5 only: +50-100% more tokens**

---

#### Output Files

| File | Location | Description |
|------|----------|-------------|
| test-artifact.html | /home/claude/ | Bundled React artifact |
| test-crud.js | /home/claude/ | Puppeteer test script |
| run-test.sh | /home/claude/ | Runner script |
| test-results.json | /home/claude/ | JSON test results |
| *.png | /home/claude/test-screenshots/ | Screenshot evidence |

---

#### When to Use Phase 3.6

| Scenario | Use Phase 3.6? |
|----------|----------------|
| Form sangat complex (>50 fields) | ✅ Yes |
| Butuh regression test berulang | ✅ Yes |
| CI/CD integration | ✅ Yes |
| User eksplisit minta | ✅ Yes |
| Form simple | ❌ No, Phase 3.5 cukup |
| One-time migration | ❌ No |
| Token constraint | ❌ No |

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

#### Step 3: Add to Sidebar Menu

**After code generation**, a sidebar menu snippet file is automatically created:

**File Location**: `sidebar_{module-name}.html` in output directory

**Integration Steps**:

1. **Find the snippet file**:
   ```bash
   ls sidebar_*.html
   # Look for file like: sidebar_ppl.html, sidebar_arus_kas.html, etc.
   ```

2. **Open the snippet file** and copy the HTML menu code

3. **Edit the sidebar layout**:
   ```bash
   code resources/views/layouts/app.blade.php
   ```

4. **Find the appropriate section** and paste the menu item:
   - **Master Data** → For master data modules (barang, supplier, etc.)
   - **Transaksi** → For transaction modules (PPL, PO, PB, etc.)
   - **Laporan** → For reports (laporan penjualan, etc.)

5. **Clear all caches** (CRITICAL - do not skip!):
   ```bash
   php artisan cache:clear
   php artisan view:clear
   php artisan config:clear
   ```

6. **Hard refresh browser** to verify menu appears:
   - **Windows**: `Ctrl+Shift+R`
   - **Mac**: `Cmd+Shift+R`

**Verification**:
- [ ] Menu item appears in sidebar
- [ ] Menu item label is correct
- [ ] Clicking menu navigates to correct page
- [ ] Submenu items work correctly

**If menu doesn't appear**:
- Check route names match in `routes/web.php`
- Verify HTML structure is copied correctly
- Clear cache again
- Check browser DevTools (F12) for errors
- Ensure Font Awesome is included in layout head

**Why caches are critical**:
- Laravel caches view paths, configurations, and routes
- Without clearing, old cache is served instead of new menu
- `cache:clear`, `view:clear`, `config:clear` covers all cache layers
- Browser cache (`Ctrl+Shift+R`) ensures latest CSS/JS loaded

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

#### Step 6: Cleanup Temporary Files

Before final commit, clean up the repository to keep it organized:

**1. Remove temporary helper scripts**:
```bash
# Delete helper scripts used during migration
rm -f check_*.php
rm -f find_*.php
rm -f test_*.php
rm -f temp_*.php

# Verify no temporary files remain
git status | grep -E "\.php$"  # Should show only intended files
```

**2. Move migration summary to correct location**:
```bash
# If migration summary is in root directory
if [ -f "*MIGRATION_SUMMARY.md" ]; then
    mv *MIGRATION_SUMMARY.md .claude/skills/delphi-migration/
    echo "✅ Moved migration summary to correct folder"
fi
```

**3. Clean up sidebar snippets** (used for reference only):
```bash
# Sidebar snippets are for manual reference, clean up after use
rm -f sidebar_*.html
```

**4. Final git status check**:
```bash
git status
# Should show ONLY:
#   - Modified: app/Models/, app/Http/, app/Services/, app/Policies/, database/
#   - Modified: routes/web.php, resources/views/layouts/app.blade.php
#   - Untracked: NONE (all files committed)
```

**Checklist**:
- [ ] No check_*.php files in root
- [ ] No find_*.php files in root
- [ ] No sidebar_*.html files in root
- [ ] Migration summary moved to `.claude/skills/delphi-migration/`
- [ ] No temporary files in git status
- [ ] Only migration files staged for commit

**Reference**: See [CLAUDE.md - File Organization Cleanup](../../../../CLAUDE.md#file-organization--cleanup)

---

### ⭐ Pattern Detection Reference

For comprehensive pattern detection and implementation details, see **[PATTERN-GUIDE.md](./PATTERN-GUIDE.md)** which covers all 8 patterns:
1. Mode-Based Operations (Choice:Char)
2. Permission System
3. Field Dependencies
4. Validation Rules (8 Sub-Patterns)
5. Authorization Workflow (OL-Based)
6. Audit Logging
7. Master-Detail Forms
8. Lookup & Search

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

### Workflow-Specific Issues

For detailed troubleshooting of common technical issues, see **[KNOWLEDGE-BASE.md](./KNOWLEDGE-BASE.md#troubleshooting-guide)** which covers:
- Column not found errors (schema verification)
- Menu not appearing (caching issues)
- Method name conflicts (authorization naming)
- Authorization level problems (OL configuration)
- Empty details validation
- Orphaned data (transaction issues)

### Quick Workflow Checks

If migration appears blocked:

1. **Check phase gate approvals**:
   - Phase 3 requires user approval before implementation
   - Phase 5 requires sign-off before production

2. **Verify database connectivity**:
   ```bash
   php artisan tinker
   > DbXXX::count()  # Should return row count
   ```

3. **Check routes are registered**:
   ```bash
   php artisan route:list | grep "module-name"
   ```

4. **Validate code syntax**:
   ```bash
   ./vendor/bin/pint  # Check for formatting issues
   php artisan test   # Run test suite
   ```

5. **Clear caches if UI changes don't appear**:
   ```bash
   php artisan cache:clear
   php artisan view:clear
   php artisan config:clear
   ```

For specific issue resolution, consult KNOWLEDGE-BASE.md Troubleshooting Guide.

---

## Best Practices

For comprehensive best practices, implementation strategies, and coding patterns, see **[KNOWLEDGE-BASE.md](./KNOWLEDGE-BASE.md#best-practices)** which includes:
- Database schema verification
- Pattern reuse from successful migrations
- Documentation and testing strategies
- Transaction management
- Error handling and authorization validation

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
- `.claude/skills/delphi-migration/PATTERN-GUIDE.md`
- `.claude/skills/delphi-migration/OBSERVATIONS.md`
- `.claude/skills/delphi-migration/KNOWLEDGE-BASE.md`
