# Delphi to Laravel Migration - Reference & Implementation Cookbook

**Version**: 1.1 (Consolidated)
**Last Updated**: 2026-01-16
**Purpose**: Implementation cookbook, code templates, troubleshooting, and best practices for Delphi migrations
**Project**: Migrasi PWT (Delphi 6 VCL → Laravel 12)

**Note**: For pattern detection and detailed implementation of all 8 migration patterns, see **[PATTERN-GUIDE.md](./PATTERN-GUIDE.md)**

---

## 📑 Table of Contents

1. [Executive Summary](#executive-summary)
2. [Quick Start](#quick-start)
3. [Implementation Cookbook](#implementation-cookbook) - Real-world recipes for common tasks
4. [Code Generation Templates](#code-generation-templates) - Reusable Laravel code templates
5. [Quality Standards](#quality-standards) - Code quality checklists
6. [Real-World Examples](#real-world-examples) - Successful migration case studies
7. [Troubleshooting Guide](#troubleshooting-guide) - Solutions to common technical issues
8. [Best Practices](#best-practices) - Proven strategies from 3+ migrations
9. [Reference Documentation](#reference-documentation) - Links to other resources

---

## Executive Summary

### What is This?

This knowledge base provides **implementation guidance and code recipes** for migrating Delphi 6 VCL business applications to Laravel 12, including:
- Step-by-step recipes for common migration tasks (CRUD, master-detail, authorization)
- Reusable code templates and boilerplate
- Troubleshooting solutions for technical issues
- Best practices from 3+ successful production migrations
- Real-world examples from PPL, PB, PO modules

### Key Success Metrics

From 3 successful migrations (PPL, PO, PB):

| Metric | Target | Achieved |
|--------|--------|----------|
| **Pattern Coverage** | 100% | ✅ 100% |
| **Business Logic Preservation** | 100% | ✅ 100% |
| **Permission Mapping** | 100% | ✅ 100% |
| **Validation Coverage** | ≥95% | ✅ 90-95% |
| **Code Quality Score** | ≥85/100 | ✅ 88-92/100 |
| **Time vs Estimate** | <20% variance | ✅ ~15% variance |
| **Manual Work** | <5% | ✅ ~2-5% |

### Architecture Overview

```
Delphi 6 VCL (Desktop)          →         Laravel 12 (Web)
━━━━━━━━━━━━━━━━━━━━              ━━━━━━━━━━━━━━━━━━━━━━━━━

TFrmModule.pas                  →    Controller (HTTP)
  └─ UpdateData(Choice:Char)    →      ├─ store()
  └─ BtnTambahClick            →      ├─ update()
  └─ BtnHapusClick             →      └─ destroy()

Business Logic                  →    Service Layer
  └─ ExecProc(sp_XXX)          →      ├─ create()
  └─ Validation checks         →      ├─ update()
  └─ LoggingData()             →      └─ delete()

IsTambah/IsKoreksi             →    Policy + Request
  └─ Permission checks         →      ├─ authorize()
                                     └─ rules()

StringGrid (Detail)            →    Blade Views
  └─ Master-Detail form        →      ├─ create.blade.php
                                     └─ edit.blade.php

SQL Server 2008                →    SQL Server 2008
  └─ Tables (PRESERVED)        →      └─ Same tables
```

---

## Quick Start

### Before Your First Migration

**⏱️ Time**: 30 minutes

```bash
# 1. Read project context (5 min)
cat CLAUDE.md

# 2. Read migration SOP (20 min)
cat .claude/skills/delphi-migration/SOP-DELPHI-MIGRATION.md

# 3. Get pre-migration advice (5 min)
claude
> /delphi-advise
> "I want to migrate FrmXXXX"
```

### Your First Migration (SIMPLE module)

**⏱️ Estimated Time**: 2-4 hours

```bash
# Phase 0: Analysis (1h)
1. Read FrmXXX.pas and FrmXXX.dfm
2. Identify patterns using PATTERN-GUIDE.md
3. Document findings

# Phase 1: Plan (30min)
4. Create migration plan
5. Get user approval 🚨

# Phase 2: Implement (1-2h)
6. Generate code using templates
7. Customize for specific business logic

# Phase 3: Test (30min)
8. Manual testing (CRUD)
9. Permission testing
10. Validation testing

# Phase 4: Document (10min)
11. Run /delphi-retrospective
12. Commit changes
```

### Essential Commands

```bash
# Get advice before starting
/delphi-advise "Module description"

# After migration - document lessons
/delphi-retrospective

# Format code
./vendor/bin/pint

# Test
php artisan test

# Run migration
php artisan migrate

# List routes
php artisan route:list | grep "module"
```

---

## Pattern Library

### ⭐ See PATTERN-GUIDE.md for Complete Pattern Documentation

**All 8 Delphi-to-Laravel patterns are documented in detail in [PATTERN-GUIDE.md](./PATTERN-GUIDE.md)**:

1. **Pattern 1**: Mode-Based Operations (Choice:Char)
2. **Pattern 2**: Permission System
3. **Pattern 3**: Field Dependencies
4. **Pattern 4**: Validation Rules (8 Sub-Patterns)
5. **Pattern 5**: Authorization Workflow (OL-Based)
6. **Pattern 6**: Audit Logging
7. **Pattern 7**: Master-Detail Forms
8. **Pattern 8**: Lookup & Search

**This KNOWLEDGE-BASE focuses on Implementation Cookbook and real-world examples.**

---

### ✅ All Pattern Details in PATTERN-GUIDE.md

For complete detection signatures, Laravel implementations, and examples for all 8 patterns, see **[PATTERN-GUIDE.md](./PATTERN-GUIDE.md)**.

---



## Implementation Cookbook

### Recipe 1: New CRUD Module Migration

**Ingredients**:
- FrmXXX.pas (Delphi source)
- FrmXXX.dfm (Form design)
- DbXXX table (already exists)

**Steps**:

1. **Analyze Delphi Code** (1h)
```bash
# Read source
code d:/ykka/migrasi/pwt/path/to/FrmXXX.pas

# Detect patterns
- [ ] Find UpdateDataXXX(Choice:Char)
- [ ] Find IsTambah, IsKoreksi, IsHapus
- [ ] List all validation logic
- [ ] Identify lookups
```

2. **Generate Service** (30min)
```php
// app/Services/XXXService.php
namespace App\Services;

use App\Models\DbXXX;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class XXXService
{
    public function create(array $data): DbXXX
    {
        return DB::transaction(function () use ($data) {
            // Business logic from Delphi Choice='I'
            $this->validateCreate($data);

            $result = DbXXX::create($data);

            $this->logActivity('I', $result->ID, $data);

            return $result;
        });
    }

    public function update(string $id, array $data): DbXXX
    {
        return DB::transaction(function () use ($id, $data) {
            $model = DbXXX::findOrFail($id);

            $this->validateUpdate($model, $data);

            $model->update($data);

            $this->logActivity('U', $id, $data);

            return $model;
        });
    }

    public function delete(string $id): bool
    {
        return DB::transaction(function () use ($id) {
            $model = DbXXX::findOrFail($id);

            $this->validateDelete($model);

            $deleted = $model->delete();

            $this->logActivity('D', $id, []);

            return $deleted;
        });
    }

    protected function validateCreate(array $data): void
    {
        // Business rules from Delphi
    }

    protected function validateUpdate(DbXXX $model, array $data): void
    {
        if ($model->IsOtorisasi1 == 1) {
            throw new \Exception('Dokumen sudah diotorisasi');
        }
    }

    protected function validateDelete(DbXXX $model): void
    {
        if ($model->IsOtorisasi1 == 1) {
            throw new \Exception('Dokumen sudah diotorisasi');
        }
    }

    protected function logActivity(string $mode, string $id, array $data): void
    {
        Log::channel('activity')->info("XXX {$mode}", [
            'user_id' => auth()->id(),
            'mode' => $mode,
            'id' => $id,
            'data' => $data,
        ]);
    }
}
```

3. **Generate Controller** (20min)
```php
// app/Http/Controllers/XXXController.php
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
        $items = DbXXX::orderBy('created_at', 'desc')->paginate(20);
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
            $result = $this->service->create($request->validated());
            return redirect()
                ->route('xxx.show', $result->ID)
                ->with('success', 'Data berhasil disimpan');
        } catch (\Exception $e) {
            return redirect()
                ->back()
                ->withInput()
                ->with('error', 'Gagal: ' . $e->getMessage());
        }
    }

    public function show(string $id)
    {
        $model = DbXXX::findOrFail($id);
        return view('xxx.show', compact('model'));
    }

    public function edit(string $id)
    {
        $model = DbXXX::findOrFail($id);
        $this->authorize('update', $model);
        return view('xxx.edit', compact('model'));
    }

    public function update(UpdateXXXRequest $request, string $id)
    {
        try {
            $result = $this->service->update($id, $request->validated());
            return redirect()
                ->route('xxx.show', $id)
                ->with('success', 'Data berhasil diubah');
        } catch (\Exception $e) {
            return redirect()
                ->back()
                ->withInput()
                ->with('error', 'Gagal: ' . $e->getMessage());
        }
    }

    public function destroy(string $id)
    {
        $model = DbXXX::findOrFail($id);
        $this->authorize('delete', $model);

        try {
            $this->service->delete($id);
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

4. **Generate Requests** (20min)
```php
// app/Http/Requests/XXX/StoreXXXRequest.php
namespace App\Http\Requests\XXX;

use Illuminate\Foundation\Http\FormRequest;
use App\Services\MenuAccessService;

class StoreXXXRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->can('create', DbXXX::class);
    }

    public function rules(): array
    {
        return [
            'field1' => 'required|string|max:100',
            'field2' => 'required|numeric|min:0',
            'field3' => 'required|exists:dbtable,FIELD',
            // ... all validation rules from Delphi
        ];
    }

    public function messages(): array
    {
        return [
            'field1.required' => 'Field 1 harus diisi',
            'field2.min' => 'Field 2 harus >= 0',
        ];
    }

    public function withValidator($validator)
    {
        $validator->after(function ($validator) {
            // Custom business logic validation from Delphi
        });
    }
}
```

5. **Generate Policy** (10min)
```php
// app/Policies/XXXPolicy.php
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
        return $this->menuAccessService->canCreate($user, 'XXX', 'L1_CODE');
    }

    public function update(User $user, DbXXX $model): bool
    {
        return $this->menuAccessService->canUpdate($user, 'XXX', 'L1_CODE');
    }

    public function delete(User $user, DbXXX $model): bool
    {
        return $this->menuAccessService->canDelete($user, 'XXX', 'L1_CODE');
    }
}
```

6. **Add Routes** (5min)
```php
// routes/web.php
Route::prefix('xxx')->name('xxx.')->group(function () {
    Route::get('/', [XXXController::class, 'index'])->name('index');
    Route::get('/create', [XXXController::class, 'create'])->name('create');
    Route::post('/', [XXXController::class, 'store'])->name('store');
    Route::get('/{id}', [XXXController::class, 'show'])->name('show');
    Route::get('/{id}/edit', [XXXController::class, 'edit'])->name('edit');
    Route::put('/{id}', [XXXController::class, 'update'])->name('update');
    Route::delete('/{id}', [XXXController::class, 'destroy'])->name('destroy');
});
```

7. **Create Views** (1h)
- index.blade.php
- create.blade.php
- edit.blade.php
- show.blade.php

8. **Test** (30min)
- [ ] Create document
- [ ] Read/view document
- [ ] Update document
- [ ] Delete document
- [ ] Test permissions
- [ ] Test validations

**Total Time**: ~3.5 hours

---

### Recipe 2: Master-Detail Form Migration

**Additional Steps** (on top of Recipe 1):

1. **Identify Detail Pattern** (10min)
```pascal
// Delphi - Check for detail grid loop
for i := 0 to StringGrid.RowCount - 1 do
begin
  QuDetail.Append;
  QuDetail.FieldByName('NOBUKTI').AsString := NoBukti.Text;
  QuDetail.FieldByName('NoUrut').AsInteger := i + 1;
  QuDetail.Post;
end;
```

2. **Determine Constraint** (5min)
- **Single-item**: Only 1 detail allowed (like PB)
- **Multiple-item**: 1+ details allowed (like PPL, PO)

3. **Update Service** (30min)
```php
// For multiple-item
public function create(array $headerData, array $detailData): DbXXX
{
    return DB::transaction(function () use ($headerData, $detailData) {
        // 1. Validate minimum details
        if (count($detailData) < 1) {
            throw new \Exception('Minimal 1 detail harus ada');
        }

        // 2. Create header
        $noBukti = $this->generateDocumentNumber($headerData);
        $header = DbXXX::create([
            'NOBUKTI' => $noBukti,
            // ... fields
        ]);

        // 3. Create details with NoUrut sequencing
        foreach ($detailData as $index => $detail) {
            DbXXXDET::create([
                'NOBUKTI' => $noBukti,
                'NoUrut' => $index + 1,
                'KODEBRG' => $detail['kode_brg'],
                'Qnt' => $detail['quantity'],
                // ... fields
            ]);
        }

        $this->logActivity('I', $noBukti, $headerData);
        return $header->fresh();
    });
}

public function update(string $noBukti, array $headerData, array $detailData): DbXXX
{
    return DB::transaction(function () use ($noBukti, $headerData, $detailData) {
        $header = DbXXX::where('NOBUKTI', $noBukti)->firstOrFail();
        $this->validateUpdate($header, $headerData);

        // Update header
        $header->update($headerData);

        // Delete-and-recreate pattern for details
        DbXXXDET::where('NOBUKTI', $noBukti)->delete();
        foreach ($detailData as $index => $detail) {
            DbXXXDET::create([
                'NOBUKTI' => $noBukti,
                'NoUrut' => $index + 1,
                // ... fields
            ]);
        }

        $this->logActivity('U', $noBukti, $headerData);
        return $header->fresh();
    });
}

public function deleteDetailLine(string $noBukti, int $noUrut): void
{
    $detailCount = DbXXXDET::where('NOBUKTI', $noBukti)->count();

    if ($detailCount <= 1) {
        throw new \Exception('Minimal 1 detail. Tidak bisa hapus yang terakhir.');
    }

    DbXXXDET::where('NOBUKTI', $noBukti)
        ->where('NoUrut', $noUrut)
        ->delete();
}
```

4. **Update Request Validation** (10min)
```php
public function rules(): array
{
    return [
        // Header
        'tgl_bukti' => 'required|date',
        'kode_supplier' => 'required|exists:dbsupplier,KODESUPPLIER',

        // Details
        'details' => 'required|array|min:1',  // At least 1
        'details.*.kode_brg' => 'required|exists:dbbarang,KODEBRG',
        'details.*.quantity' => 'required|numeric|min:0.01',
        'details.*.satuan' => 'required|string|max:10',
    ];
}
```

5. **Create Detail Management View** (30min)
```blade
<!-- edit.blade.php -->

<!-- Detail Table -->
<table class="table">
    <thead>
        <tr>
            <th>No</th>
            <th>Kode Barang</th>
            <th>Nama Barang</th>
            <th>Qty</th>
            <th>Satuan</th>
            <th>Actions</th>
        </tr>
    </thead>
    <tbody id="detail-table-body">
        @forelse($model->details as $index => $detail)
            <tr>
                <td>{{ $index + 1 }}</td>
                <td>{{ $detail->KODEBRG }}</td>
                <td>{{ $detail->NAMABRG }}</td>
                <td>
                    <input type="number" class="form-control"
                           value="{{ $detail->Qnt }}" step="0.01">
                </td>
                <td>
                    <input type="text" class="form-control"
                           value="{{ $detail->Sat }}" maxlength="10">
                </td>
                <td>
                    <button class="btn btn-primary btn-sm"
                            onclick="updateDetail({{ $index }})">
                        Simpan
                    </button>
                    <button class="btn btn-danger btn-sm"
                            onclick="deleteDetail({{ $detail->NoUrut }})">
                        Hapus
                    </button>
                </td>
            </tr>
        @empty
            <tr>
                <td colspan="6" class="text-center">Tidak ada detail</td>
            </tr>
        @endforelse
    </tbody>
</table>

<script>
function deleteDetail(noUrut) {
    if (!confirm('Hapus detail ini?')) return;

    fetch(`/xxx/{{ $model->NOBUKTI }}/detail/${noUrut}`, {
        method: 'DELETE',
        headers: {
            'X-CSRF-TOKEN': '{{ csrf_token() }}'
        }
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            location.reload();
        } else {
            alert('Error: ' + data.message);
        }
    });
}
</script>
```

**Additional Time**: +1.5 hours (total ~5 hours)

---

### Recipe 3: Adding Authorization Workflow

**Prerequisites**:
- Base CRUD module already migrated
- OL configuration checked in DBMENU

**Steps**:

1. **Verify OL Configuration** (5min)
```sql
SELECT L1, KODEMENU, NAMA, OL FROM DBMENU WHERE KODEMENU = 'XXXX';
-- Store OL value (e.g., OL=2 for PPL)
```

2. **Add Authorization Service Methods** (30min)
```php
// app/Services/XXXService.php

public function authorize(string $noBukti, int $level): DbXXX
{
    $model = DbXXX::where('NOBUKTI', $noBukti)->firstOrFail();

    // Validate
    if ($model->IsBatal == 1) {
        throw new \Exception('Dokumen sudah dibatalkan');
    }

    // Cascading check
    if ($level > 1) {
        $prevLevel = $level - 1;
        $prevAuthField = "IsOtorisasi{$prevLevel}";
        if ($model->$prevAuthField != 1) {
            throw new \Exception("Otorisasi level {$prevLevel} dulu");
        }
    }

    // Not already authorized
    $authField = "IsOtorisasi{$level}";
    if ($model->$authField == 1) {
        throw new \Exception("Level {$level} sudah diotorisasi");
    }

    // Update
    $userField = "OtoUser{$level}";
    $dateField = "TglOto{$level}";

    $model->update([
        $authField => 1,
        $userField => auth()->user()->IDUser,
        $dateField => now(),
    ]);

    $this->logActivity('O', $noBukti, ['level' => $level]);
    return $model->fresh();
}

public function cancelAuthorization(string $noBukti, int $level): DbXXX
{
    $model = DbXXX::where('NOBUKTI', $noBukti)->firstOrFail();

    // Cascade to higher levels
    for ($i = $level; $i <= 5; $i++) {
        $model->update([
            "IsOtorisasi{$i}" => 0,
            "OtoUser{$i}" => null,
            "TglOto{$i}" => null,
        ]);
    }

    $this->logActivity('C', $noBukti, ['level' => $level]);
    return $model->fresh();
}
```

3. **Add Controller Methods** (15min)
```php
// app/Http/Controllers/XXXController.php

public function authorize(Request $request, string $noBukti)
{
    $level = $request->input('level', 1);

    try {
        $this->service->authorize($noBukti, $level);
        return redirect()
            ->back()
            ->with('success', "Otorisasi level {$level} berhasil");
    } catch (\Exception $e) {
        return redirect()
            ->back()
            ->with('error', 'Gagal: ' . $e->getMessage());
    }
}

public function cancelAuthorization(Request $request, string $noBukti)
{
    $level = $request->input('level', 1);

    try {
        $this->service->cancelAuthorization($noBukti, $level);
        return redirect()
            ->back()
            ->with('success', "Otorisasi level {$level} berhasil dibatalkan");
    } catch (\Exception $e) {
        return redirect()
            ->back()
            ->with('error', 'Gagal: ' . $e->getMessage());
    }
}
```

4. **Add Routes** (2min)
```php
// routes/web.php
Route::post('/{nobukti}/authorize', [XXXController::class, 'authorize'])
    ->name('authorize');
Route::post('/{nobukti}/cancel-authorization', [XXXController::class, 'cancelAuthorization'])
    ->name('cancel-authorization');
```

5. **Update Index View** (30min)
```blade
<!-- index.blade.php -->

@php
    $maxVisibleLevel = 2; // From DBMENU.OL
@endphp

<table class="table">
    <thead>
        <tr>
            <th>No Bukti</th>
            <th>Tanggal</th>

            @for($level = 1; $level <= $maxVisibleLevel; $level++)
                <th>Otorisasi L{{ $level }}</th>
            @endfor

            <th>Actions</th>
        </tr>
    </thead>
    <tbody>
        @foreach($items as $item)
            <tr>
                <td>{{ $item->NOBUKTI }}</td>
                <td>{{ $item->TglBukti }}</td>

                @for($level = 1; $level <= $maxVisibleLevel; $level++)
                    @php
                        $authField = "IsOtorisasi{$level}";
                        $userField = "OtoUser{$level}";
                        $dateField = "TglOto{$level}";
                        $isAuthorized = $item->$authField == 1;
                    @endphp

                    <td>
                        @if($isAuthorized)
                            <span class="badge bg-success">✓</span><br>
                            <small>{{ $item->$userField }}</small><br>
                            <small>{{ $item->$dateField->format('d-m-Y H:i') }}</small>

                            @if(!$item->IsBatal)
                                <button class="btn btn-xs btn-warning"
                                        onclick="cancelAuth('{{ $item->NOBUKTI }}', {{ $level }})">
                                    ✕ Batalkan
                                </button>
                            @endif
                        @else
                            @if(canAuthorizeLevel($level) && !$item->IsBatal)
                                <button class="btn btn-xs btn-primary"
                                        onclick="authorizeDoc('{{ $item->NOBUKTI }}', {{ $level }})">
                                    ✓ L{{ $level }}
                                </button>
                            @endif
                        @endif
                    </td>
                @endfor

                <td>
                    <a href="{{ route('xxx.show', $item->NOBUKTI) }}">View</a>
                </td>
            </tr>
        @endforeach
    </tbody>
</table>

<script>
function authorizeDoc(nobukti, level) {
    if (confirm(`Otorisasi level ${level}?`)) {
        fetch(`/xxx/${nobukti}/authorize`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': '{{ csrf_token() }}'
            },
            body: JSON.stringify({ level: level })
        }).then(() => location.reload());
    }
}

function cancelAuth(nobukti, level) {
    if (confirm(`Batalkan otorisasi level ${level}?`)) {
        fetch(`/xxx/${nobukti}/cancel-authorization`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': '{{ csrf_token() }}'
            },
            body: JSON.stringify({ level: level })
        }).then(() => location.reload());
    }
}
</script>
```

**Total Time**: ~1.5 hours

---

## Code Generation Templates

See previous sections for complete templates of:
- Service Layer
- Controller
- Request Classes
- Policy
- Views (index, create, edit, show)

---

## Quality Standards

### Code Quality Checklist

Before marking migration as "complete":

**Code Structure**:
- [ ] All files formatted with Pint (PSR-12)
- [ ] No hardcoded values
- [ ] Type hints on all methods
- [ ] Delphi references in comments

**Functionality**:
- [ ] Can create document (INSERT mode)
- [ ] Can read/view document
- [ ] Can update document (UPDATE mode)
- [ ] Can delete document (DELETE mode)
- [ ] Authorization workflow works (if OL > 0)
- [ ] All permissions work
- [ ] All validations work
- [ ] Audit logging works

**Testing**:
- [ ] Manual CRUD testing completed
- [ ] Permission testing completed
- [ ] Validation testing completed
- [ ] Database verification completed
- [ ] Edge case testing done

**Documentation**:
- [ ] Migration summary created
- [ ] Retrospective completed (`/delphi-retrospective`)
- [ ] Lessons documented

### Quality Score Calculation

```
Quality Score = (Mode + Permission + Validation + Audit + Format + Testing) / 6

Components:
- Mode Coverage: 100% (all I/U/D implemented)
- Permission Coverage: 100% (all permissions mapped)
- Validation Coverage: ≥95% (all patterns detected)
- Audit Coverage: 100% (all operations logged)
- Code Format: 100% (Pint passes)
- Testing: 100% (all checklist items done)

Example:
100% + 100% + 95% + 100% + 100% + 100% = 595%
595% / 6 = 99.2/100 ✅ EXCELLENT
```

**Deployment Criteria**:
- ✅ Score ≥ 90/100 → Ready for production
- ⚠️ Score 70-89/100 → Needs improvement
- ❌ Score < 70/100 → REJECT, rework required

---

## Real-World Examples

### Example 1: PPL (Purchase Request) - MEDIUM Complexity

**Stats**:
- **Complexity**: 🟡 MEDIUM
- **Time Taken**: 4-5 hours
- **Quality Score**: 94/100
- **Status**: ✅ Success

**Patterns Used**:
1. ✅ Mode Operations (I/U/D)
2. ✅ Permissions (IsTambah/IsKoreksi/IsHapus)
3. ✅ Validation (8 sub-patterns)
4. ✅ Authorization (OL=2, 2-level workflow)
5. ✅ Master-Detail (multiple items, min:1)
6. ✅ Audit Logging

**Key Features**:
- Purchase Request creation
- Multi-detail line management
- 2-level authorization (Bagian Pembelian → Wakil Direktur)
- Cannot edit/delete after authorization
- Minimum 1 detail line enforced

**Files Generated**: 13 files
- PPLController.php
- PPLService.php
- PPLPolicy.php
- StoreRequest, UpdateRequest
- 5 views

**Lessons Learned**:
- Multi-layer validation (client + server) works well
- Delete-and-recreate pattern for details is simple
- OL-based authorization is flexible

---

### Example 2: PB (Material Handover) - MEDIUM Complexity

**Stats**:
- **Complexity**: 🟡 MEDIUM
- **Time Taken**: 4-5 hours
- **Quality Score**: 88/100
- **Status**: ✅ Success

**Patterns Used**:
1. ✅ Mode Operations (I/U/D)
2. ✅ Permissions
3. ✅ Field Dependencies (warehouse → SPK items)
4. ✅ Validation
5. ✅ Authorization (OL=2)
6. ✅ Master-Detail (**single-item constraint**)
7. ✅ Lookup (SPK modal)

**Key Features**:
- Exactly 1 detail per document (strict constraint)
- Warehouse selection → filters SPK items
- SPK lookup modal with search
- 2-level authorization

**Challenges**:
- Menu code constant (PB_MENU_CODE) needed verification
- Column name mismatch (NAMA vs NamaGdg)
- Method name conflict (authorize() → authorizeDocument())

**Files Generated**: 13+ files

**Lessons Learned**:
- Always check actual schema before queries
- Single-item constraint needs multi-layer enforcement
- Cache clearing critical after sidebar changes

---

### Example 3: PO (Purchase Order) - COMPLEX

**Stats**:
- **Complexity**: 🔴 COMPLEX
- **Time Taken**: 8-12 hours
- **Quality Score**: 92/100
- **Status**: ✅ Success

**Patterns Used**: All 8 patterns

**Key Features**:
- Complex master-detail (unlimited items)
- 3-level authorization (OL=3)
- Multiple conditional fields (Lokal vs Import)
- Stock impact validation
- Price calculation with discount
- Multiple lookups (supplier, barang, etc.)

**Challenges**:
- ~3,700 lines of Delphi code
- 199 procedures/functions
- Complex business validation
- Multiple detail types

**Files Generated**: 15+ files

**Lessons Learned**:
- Break complex forms into phases
- Test each feature incrementally
- Document complex business rules clearly

---

## Troubleshooting Guide

### Problem 1: "Column not found" Error

**Symptom**:
```
SQLSTATE[42S22]: Column not found: Invalid column name 'NamaGdg'
```

**Cause**: Assumed column name differs from actual schema

**Solution**:
```sql
-- Check actual schema
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dbGudang';

-- Use alias in query
SELECT NAMA AS NamaGdg FROM dbGudang;
```

---

### Problem 2: Menu Not Appearing in Sidebar

**Symptom**: Added menu HTML but not showing in browser

**Cause**: View cache not cleared

**Solution**:
```bash
# Clear all caches
php artisan cache:clear
php artisan view:clear
php artisan config:clear
composer dump-autoload

# Hard refresh browser (Ctrl+F5)
```

---

### Problem 3: Method Name Conflicts

**Symptom**:
```
Declaration of authorize() must be compatible with base class
```

**Cause**: Method name conflicts with Laravel's base Controller

**Solution**:
```php
// ❌ Wrong
public function authorize(Request $request) { }

// ✅ Correct
public function authorizeDocument(Request $request) { }
```

---

### Problem 4: Wrong Authorization Levels

**Symptom**: Implementing 5 levels but form only needs 2

**Cause**: Not checking DBMENU.OL first

**Solution**:
```sql
-- ALWAYS check OL first
SELECT OL FROM DBMENU WHERE KODEMENU = 'XXXX';

-- Then use actual OL in code
$maxLevel = $menu->OL;  // e.g., 2
```

---

### Problem 5: Empty Details Allowed

**Symptom**: User can save document without details

**Cause**: Missing validation

**Solution**:
```php
// Multi-layer validation

// 1. Request
'details' => 'required|array|min:1'

// 2. Controller
if (count($request->input('details', [])) === 0) {
    return back()->with('error', 'Minimal 1 detail');
}

// 3. Service
if (count($detailData) < 1) {
    throw new \Exception('Minimal 1 detail');
}

// 4. JavaScript (client-side)
if (detailCount === 0) {
    alert('Minimal 1 detail');
    return false;
}
```

---

### Problem 6: Orphaned Data After Error

**Symptom**: Header created but details failed → orphan header

**Cause**: Not using transactions

**Solution**:
```php
// ✅ ALWAYS wrap in transaction
DB::transaction(function () {
    $header = DbXXX::create([...]);
    DbXXXDET::create([...]);  // If this fails, header rolls back too
});
```

---

## Best Practices

### From 3 Successful Migrations

**1. Always Verify OL Configuration First** (saves 1+ hour)
```sql
SELECT OL FROM DBMENU WHERE KODEMENU = 'XXXX';
-- Do this BEFORE implementing authorization
```

**2. Multi-Layer Validation** (prevents data corruption)
```
Client JavaScript → Request rules → Controller check → Service validation
```

**3. Use Transactions** (ensures data consistency)
```php
DB::transaction(function () {
    // All database operations here
});
```

**4. Database Schema Verification** (prevents column errors)
```sql
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'TableName';
```

**5. Delphi References in Comments** (aids maintenance)
```php
/**
 * Delphi: FrmPPL.pas, UpdateDataPPL(Choice:Char), line 425
 * Mode: Choice='I' (INSERT)
 */
```

**6. Run Retrospective After Each Migration** (continuous improvement)
```bash
/delphi-retrospective
```

**7. Test with Different Permission Levels** (security validation)
- User WITH permission → works
- User WITHOUT permission → denied

**8. Clear All Caches After Changes** (prevents "ghost" issues)
```bash
php artisan cache:clear
php artisan view:clear
composer dump-autoload
```

**9. Use Constants, Not Hardcoded Values** (maintainability)
```php
const PB_MENU_CODE = '05006';
```

**10. Format Code with Pint** (consistency)
```bash
./vendor/bin/pint
```

---

## Reference Documentation

### Internal Documentation

1. **PATTERN-GUIDE.md** - Complete pattern library with examples
2. **QUICK-REFERENCE.md** - Quick reference card
3. **RULES.md** - Rules & regulations for compliance
4. **SOP-DELPHI-MIGRATION.md** - Standard Operating Procedure
5. **OBSERVATIONS.md** - Retrospectives from all migrations
6. **STARTER-KIT.md** - Getting started guide

### Project Documentation

- **CLAUDE.md** - Project context and guidelines
- **README.md** - Project overview

### External Resources

- Laravel 12 Documentation: https://laravel.com/docs/12.x
- SQL Server Documentation: https://learn.microsoft.com/sql-server
- PSR-12 Coding Standard: https://www.php-fig.org/psr/psr-12/

---

## Appendix

### A. Complexity Assessment Matrix

| Factor | SIMPLE | MEDIUM | COMPLEX |
|--------|--------|--------|---------|
| **Forms** | 1 | 1-2 | 3+ |
| **Lines of Code** | <500 | 500-1500 | >1500 |
| **Lookups** | 0-1 | 2-3 | 5+ |
| **Business Rules** | Few | Moderate | Many |
| **Master-Detail** | No | Yes (single) | Yes (multiple levels) |
| **Authorization** | None/1 level | 2-3 levels | 4-5 levels |
| **Stock Impact** | No | Maybe | Yes |
| **Estimated Time** | 2-4h | 4-8h | 8-12h |

### B. Pattern Coverage Matrix

| Module | P1 Mode | P2 Perm | P3 Dep | P4 Valid | P5 Auth | P6 Log | P7 Detail | P8 Lookup |
|--------|---------|---------|--------|----------|---------|--------|-----------|-----------|
| PPL    | ✅ 100% | ✅ 100% | ⚪ N/A | ✅ 95%  | ✅ 100% | ✅ 100% | ✅ 100%   | ⚪ N/A    |
| PO     | ✅ 100% | ✅ 100% | ✅ 90% | ✅ 90%  | ✅ 100% | ✅ 100% | ✅ 100%   | ✅ 100%   |
| PB     | ✅ 100% | ✅ 100% | ✅ 100%| ✅ 95%  | ✅ 100% | ✅ 100% | ✅ 100%   | ✅ 100%   |

### C. Time Tracking Template

```markdown
## Migration: [Module Name]

**Start Time**: YYYY-MM-DD HH:MM
**End Time**: YYYY-MM-DD HH:MM
**Total Duration**: X hours

**Phase Breakdown**:
- Phase 0 (Analysis): X hours
- Phase 1 (Planning): X hours
- Phase 2 (Implementation): X hours
- Phase 3 (Testing): X hours
- Phase 4 (Documentation): X hours

**Complexity**: SIMPLE/MEDIUM/COMPLEX
**Estimated**: X hours
**Actual**: Y hours
**Variance**: +/-Z%
```

### D. Quality Metrics Template

```markdown
## Quality Metrics: [Module Name]

| Metric | Target | Achieved | Notes |
|--------|--------|----------|-------|
| Mode Coverage | 100% | X% | |
| Permission Coverage | 100% | X% | |
| Validation Coverage | ≥95% | X% | |
| Audit Coverage | 100% | X% | |
| Code Format | 100% | X% | |
| Testing | 100% | X% | |
| **Overall Score** | **≥85** | **X/100** | |
```

---

**KNOWLEDGE BASE v1.0**
**Last Updated**: 2026-01-03
**Maintained By**: Delphi Migration Team
**Next Review**: 2026-04-03 (Quarterly)

For questions or updates to this knowledge base, document in OBSERVATIONS.md or update relevant sections.
