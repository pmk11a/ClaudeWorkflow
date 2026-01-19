# Delphi to Laravel Migration - Quick Reference Card

**Version**: 1.0 | **Last Updated**: 2026-01-03

---

## 🚀 Quick Start

```bash
# 1. Get advice before starting
/delphi-advise
"I want to migrate FrmXXXX to Laravel"

# 2. Read the SOP (20 min)
cat .claude/skills/delphi-migration/SOP-DELPHI-MIGRATION.md

# 3. After migration - document lessons
/delphi-retrospective
```

---

## 📋 Pattern Detection Quick Reference

### Pattern 1: Mode Operations (Choice:Char)
**🔍 Delphi**: `Procedure UpdateDataXXX(Choice:Char)`
**✅ Laravel**: `create()`, `update()`, `delete()` in Service

| Delphi | Laravel Service | Controller | Request |
|--------|-----------------|------------|---------|
| `Choice='I'` | `create()` | `store()` | `StoreXXXRequest` |
| `Choice='U'` | `update()` | `update()` | `UpdateXXXRequest` |
| `Choice='D'` | `delete()` | `destroy()` | - |

---

### Pattern 2: Permissions
**🔍 Delphi**: `IsTambah`, `IsKoreksi`, `IsHapus`
**✅ Laravel**: Policy + MenuAccessService

| Delphi | Laravel Policy | MenuAccessService |
|--------|----------------|-------------------|
| `IsTambah` | `create()` | `canCreate()` |
| `IsKoreksi` | `update()` | `canUpdate()` |
| `IsHapus` | `delete()` | `canDelete()` |
| `IsCetak` | `print()` | Manual check |
| `IsExcel` | `export()` | Manual check |

---

### Pattern 3: Field Dependencies
**🔍 Delphi**: `FieldAChange(Sender: TObject)`
**✅ Laravel**: AJAX endpoint + JavaScript

```javascript
// Delphi OnChange → Laravel AJAX
fieldA.addEventListener('change', () => {
    fetch(`/api/dependent-options?parent=${fieldA.value}`)
        .then(response => response.json())
        .then(data => populateFieldB(data));
});
```

---

### Pattern 4: Validation (8 Sub-Patterns)

| Pattern | Delphi | Laravel |
|---------|--------|---------|
| Required | `if Text = ''` | `'required'` |
| Unique | `QuCheck.Locate(...)` | `'unique:table,field'` |
| Range | `if Value < 0` | `'min:0'` |
| Format | `IsValidDate(...)` | `'date_format:Y-m-d'` |
| Lookup | `if not QuTable.Locate` | `'exists:table,field'` |
| Conditional | `if Type=1 then if Field...` | `'required_if:type,1'` |
| Enum | `if not (Status in [...])` | `'in:A,B,C'` |
| Custom | `raise Exception.Create(...)` | `withValidator()` |

---

### Pattern 5: Authorization Workflow

**🔍 Check OL First**:
```sql
SELECT L1, KODEMENU, NAMA, OL FROM DBMENU WHERE KODEMENU = 'XXXX';
```

**Authorization Levels**:
- OL=1 → 1 level only
- OL=2 → PPL, PB (2 levels)
- OL=3 → PO (3 levels)
- OL=5 → Complex modules (5 levels)

**✅ Service Methods**:
- `authorize(string $noBukti, int $level): Model`
- `cancelAuthorization(string $noBukti, int $level): Model`

---

### Pattern 6: Audit Logging
**🔍 Delphi**: `LoggingData(IDUser, Choice, 'Module', NoBukti, Desc)`
**✅ Laravel**: `Log::channel('activity')->info(...)`

```php
protected function logActivity(string $mode, string $noBukti, array $data): void
{
    Log::channel('activity')->info("XXX {$mode}", [
        'user_id' => auth()->id(),
        'mode' => $mode,  // I/U/D/O
        'nobukti' => $noBukti,
        'data' => $data,
    ]);
}
```

---

### Pattern 7: Master-Detail Forms

**Single-Item** (PB pattern):
```php
// Validation
'details' => 'required|array|size:1'  // Exactly 1

// Constraint
if (count($details) > 1) {
    throw new \Exception('Hanya boleh 1 detail');
}
```

**Multiple-Item** (PPL/PO pattern):
```php
// Validation
'details' => 'required|array|min:1'  // At least 1

// Delete constraint
if ($detailCount <= 1) {
    throw new \Exception('Minimal harus ada 1 detail');
}
```

---

### Pattern 8: Lookup & Search

**AJAX Endpoint**:
```php
public function lookupItems(Request $request)
{
    $search = $request->get('search');

    return DB::table('Table')
        ->where('Field', 'like', "%{$search}%")
        ->select('ID', 'Name', 'Other')
        ->get();
}
```

**JavaScript**:
```javascript
fetch(`/api/lookup/items?search=${search}`)
    .then(response => response.json())
    .then(items => renderTable(items));
```

---

## 🎯 File Structure Template

```
app/
├── Http/
│   ├── Controllers/
│   │   └── XXXController.php              # HTTP layer
│   └── Requests/XXX/
│       ├── StoreXXXRequest.php            # INSERT validation
│       └── UpdateXXXRequest.php           # UPDATE validation
├── Models/
│   ├── DbXXX.php                          # Master table model
│   └── DbXXXDET.php                       # Detail table model
├── Policies/
│   └── XXXPolicy.php                      # Authorization
└── Services/
    └── XXXService.php                     # Business logic

resources/views/xxx/
├── index.blade.php                        # List view
├── create.blade.php                       # Create form
├── edit.blade.php                         # Edit form
├── show.blade.php                         # Detail view
└── print.blade.php                        # Print view

routes/web.php                             # Add XXX routes
```

---

## 💻 Code Templates

### Service Template

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
     * INSERT (Choice='I')
     * Delphi: FrmXXX.pas, UpdateDataXXX(Choice:Char), line XXX
     */
    public function create(array $headerData, array $detailData): DbXXX
    {
        return DB::transaction(function () use ($headerData, $detailData) {
            $this->validateCreate($headerData, $detailData);

            $noBukti = $this->generateDocumentNumber($headerData);

            $header = DbXXX::create([
                'NOBUKTI' => $noBukti,
                // ... fields
            ]);

            foreach ($detailData as $index => $detail) {
                DbXXXDET::create([
                    'NOBUKTI' => $noBukti,
                    'NoUrut' => $index + 1,
                    // ... fields
                ]);
            }

            $this->logActivity('I', $noBukti, $headerData);

            return $header->fresh();
        });
    }

    /**
     * UPDATE (Choice='U')
     */
    public function update(string $noBukti, array $headerData, array $detailData): DbXXX
    {
        return DB::transaction(function () use ($noBukti, $headerData, $detailData) {
            $header = DbXXX::where('NOBUKTI', $noBukti)->firstOrFail();

            $this->validateUpdate($header, $headerData);

            $header->update($headerData);

            DbXXXDET::where('NOBUKTI', $noBukti)->delete();
            foreach ($detailData as $index => $detail) {
                DbXXXDET::create([...]);
            }

            $this->logActivity('U', $noBukti, $headerData);

            return $header->fresh();
        });
    }

    /**
     * DELETE (Choice='D')
     */
    public function delete(string $noBukti): bool
    {
        return DB::transaction(function () use ($noBukti) {
            $header = DbXXX::where('NOBUKTI', $noBukti)->firstOrFail();

            $this->validateDelete($header);

            DbXXXDET::where('NOBUKTI', $noBukti)->delete();
            $deleted = $header->delete();

            $this->logActivity('D', $noBukti, []);

            return $deleted;
        });
    }

    protected function validateCreate(array $headerData, array $detailData): void
    {
        // Business rules from Delphi
    }

    protected function validateUpdate(DbXXX $header, array $headerData): void
    {
        if ($header->IsOtorisasi1 == 1) {
            throw new \Exception('Dokumen sudah diotorisasi');
        }
    }

    protected function validateDelete(DbXXX $header): void
    {
        if ($header->IsOtorisasi1 == 1) {
            throw new \Exception('Dokumen sudah diotorisasi');
        }
    }

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

---

### Controller Template

```php
<?php

namespace App\Http\Controllers;

use App\Services\XXXService;
use App\Http\Requests\XXX\StoreXXXRequest;
use App\Http\Requests\XXX\UpdateXXXRequest;

class XXXController extends Controller
{
    public function __construct(
        protected XXXService $service
    ) {}

    public function index()
    {
        $items = DbXXX::orderBy('TglBukti', 'desc')->paginate(20);
        return view('xxx.index', compact('items'));
    }

    public function create()
    {
        $this->authorize('create', DbXXX::class);
        return view('xxx.create');
    }

    public function store(StoreXXXRequest $request)
    {
        try {
            $result = $this->service->create(
                $request->only([...]),
                $request->input('details', [])
            );

            return redirect()
                ->route('xxx.show', $result->NOBUKTI)
                ->with('success', 'Data berhasil disimpan');
        } catch (\Exception $e) {
            return redirect()
                ->back()
                ->withInput()
                ->with('error', 'Gagal: ' . $e->getMessage());
        }
    }

    public function show(string $noBukti)
    {
        $model = DbXXX::where('NOBUKTI', $noBukti)->firstOrFail();
        return view('xxx.show', compact('model'));
    }

    public function edit(string $noBukti)
    {
        $model = DbXXX::where('NOBUKTI', $noBukti)->firstOrFail();
        $this->authorize('update', $model);
        return view('xxx.edit', compact('model'));
    }

    public function update(UpdateXXXRequest $request, string $noBukti)
    {
        try {
            $result = $this->service->update(
                $noBukti,
                $request->only([...]),
                $request->input('details', [])
            );

            return redirect()
                ->route('xxx.show', $noBukti)
                ->with('success', 'Data berhasil diubah');
        } catch (\Exception $e) {
            return redirect()
                ->back()
                ->withInput()
                ->with('error', 'Gagal: ' . $e->getMessage());
        }
    }

    public function destroy(string $noBukti)
    {
        $model = DbXXX::where('NOBUKTI', $noBukti)->firstOrFail();
        $this->authorize('delete', $model);

        try {
            $this->service->delete($noBukti);

            return redirect()
                ->route('xxx.index')
                ->with('success', 'Data berhasil dihapus');
        } catch (\Exception $e) {
            return redirect()
                ->back()
                ->with('error', 'Gagal: ' . $e->getMessage());
        }
    }
}
```

---

### Request Template

```php
<?php

namespace App\Http\Requests\XXX;

use Illuminate\Foundation\Http\FormRequest;
use App\Services\MenuAccessService;

class StoreXXXRequest extends FormRequest
{
    public function authorize(): bool
    {
        // IsTambah permission check
        return app(MenuAccessService::class)->canCreate(
            auth()->user(),
            'MODULE_CODE',
            'L1_CODE'
        );
    }

    public function rules(): array
    {
        return [
            // Header fields
            'tgl_bukti' => 'required|date',
            'kode_supplier' => 'required|exists:dbsupplier,KODESUPPLIER',

            // Detail validation
            'details' => 'required|array|min:1',
            'details.*.kode_brg' => 'required|exists:dbbarang,KODEBRG',
            'details.*.quantity' => 'required|numeric|min:0.01',
        ];
    }

    public function messages(): array
    {
        return [
            'tgl_bukti.required' => 'Tanggal harus diisi',
            'details.min' => 'Minimal harus ada 1 baris detail',
        ];
    }

    public function withValidator($validator)
    {
        $validator->after(function ($validator) {
            // Custom business logic validation
            if ($this->some_custom_check) {
                $validator->errors()->add('field', 'Error message');
            }
        });
    }
}
```

---

### Policy Template

```php
<?php

namespace App\Policies;

use App\Models\DbXXX;
use App\Models\Trade2Exchange\User;
use App\Services\MenuAccessService;

class XXXPolicy
{
    public function __construct(
        protected MenuAccessService $menuAccessService
    ) {}

    public function create(User $user): bool
    {
        return $this->menuAccessService->canCreate($user, 'MODULE', 'L1_CODE');
    }

    public function update(User $user, DbXXX $model): bool
    {
        return $this->menuAccessService->canUpdate($user, 'MODULE', 'L1_CODE');
    }

    public function delete(User $user, DbXXX $model): bool
    {
        return $this->menuAccessService->canDelete($user, 'MODULE', 'L1_CODE');
    }
}
```

---

## 🔧 Useful Commands

### Development
```bash
# Start server
php artisan serve

# Format code (PSR-12)
./vendor/bin/pint

# Check syntax
php -l app/Http/Controllers/XXXController.php

# List routes
php artisan route:list | grep "xxx"
```

### Cache Management
```bash
# Clear all caches
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Cache for production
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### Database
```bash
# Run migrations
php artisan migrate

# Show database info
php artisan db:show
```

### Testing
```bash
# Run all tests
php artisan test

# Run specific test
php artisan test --filter XXXTest
```

---

## 📊 SQL Server Queries

### Check Table Columns
```sql
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'DbXXX'
ORDER BY ORDINAL_POSITION;
```

### Find Menu Code
```sql
SELECT L1, KODEMENU, NAMA, OL
FROM DBMENU
WHERE NAMA LIKE '%keyword%';
```

### Check Permissions
```sql
SELECT *
FROM DBFLMENU
WHERE IDUser = 'SA' AND L1 = '05' AND KodeMenu = '05006';
```

### Check Authorization Status
```sql
SELECT NOBUKTI,
       IsOtorisasi1, OtoUser1, TglOto1,
       IsOtorisasi2, OtoUser2, TglOto2
FROM DbXXX
WHERE NOBUKTI = '...';
```

---

## ⚠️ Common Pitfalls

### 1. Column Name Mismatch
```sql
-- ❌ Wrong: Assuming column name
SELECT NamaGdg FROM dbGudang;

-- ✅ Correct: Check actual schema first
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'dbGudang';

-- ✅ Use alias
SELECT NAMA AS NamaGdg FROM dbGudang;
```

### 2. Forgetting OL Configuration
```sql
-- ❌ Wrong: Assuming all modules use 5 levels
-- ✅ Correct: Check OL first
SELECT OL FROM DBMENU WHERE KODEMENU = 'XXXX';
```

### 3. Method Name Conflicts
```php
// ❌ Wrong: Conflicts with Laravel base Controller
public function authorize(Request $request) { }

// ✅ Correct: Use specific name
public function authorizeDocument(Request $request) { }
```

### 4. Not Using Transactions
```php
// ❌ Wrong: No atomicity
$header = DbXXX::create([...]);
DbXXXDET::create([...]);  // If this fails, orphan header!

// ✅ Correct: Wrap in transaction
DB::transaction(function () {
    $header = DbXXX::create([...]);
    DbXXXDET::create([...]);
});
```

### 5. Missing Detail Validation
```php
// ❌ Wrong: Allow empty details
'details' => 'array'

// ✅ Correct: Enforce minimum
'details' => 'required|array|min:1'
```

---

## 📈 Quality Targets

| Metric | Target | How to Measure |
|--------|--------|----------------|
| Mode Coverage | 100% | All I/U/D implemented |
| Permission Coverage | 100% | All IsTambah/IsKoreksi/IsHapus mapped |
| Validation Coverage | ≥95% | All 8 validation patterns detected |
| Audit Coverage | 100% | All LoggingData calls mapped |
| Manual Work | <5% | Mostly config adjustments |

---

## 🎯 Success Checklist

Before considering migration complete:

### Code Quality
- [ ] All files formatted with Pint (PSR-12)
- [ ] No hardcoded values
- [ ] Proper type hints on all methods
- [ ] Comments include Delphi references

### Functionality
- [ ] Can create document
- [ ] Can read/view document
- [ ] Can update document
- [ ] Can delete document
- [ ] Authorization workflow works (if OL > 0)
- [ ] Permissions work correctly
- [ ] All validations work
- [ ] Audit logging works

### Testing
- [ ] Manual testing completed
- [ ] Permission testing completed
- [ ] Validation testing completed
- [ ] Database verification completed

### Documentation
- [ ] Migration summary created
- [ ] Retrospective completed (`/delphi-retrospective`)
- [ ] Lessons documented

---

## 📚 Related Documentation

- **SOP**: `.claude/skills/delphi-migration/SOP-DELPHI-MIGRATION.md`
- **Pattern Guide**: `.claude/skills/delphi-migration/PATTERN-GUIDE.md`
- **Rigorous Logic**: `.claude/skills/delphi-migration/RIGOROUS_LOGIC_MIGRATION.md`
- **Observations**: `.claude/skills/delphi-migration/OBSERVATIONS.md`
- **Project Guide**: `CLAUDE.md`

---

## 🆘 Getting Help

**Issue?** → Check troubleshooting section in SOP
**Question?** → Review pattern guide
**Stuck?** → Run `/delphi-advise` for recommendations

---

**Quick Reference v1.0** | For detailed guides, see full SOP and Pattern Guide
