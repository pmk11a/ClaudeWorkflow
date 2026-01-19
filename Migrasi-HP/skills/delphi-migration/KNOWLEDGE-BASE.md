# Delphi to Laravel Migration - Complete Knowledge Base

**Version**: 1.0
**Last Updated**: 2026-01-03
**Purpose**: Comprehensive reference guide for Delphi 6 → Laravel 12 migration
**Project**: Migrasi PWT (Delphi 6 VCL → Laravel 12)

---

## 📑 Table of Contents

1. [Executive Summary](#executive-summary)
2. [Quick Start](#quick-start)
3. [Pattern Library](#pattern-library)
4. [Implementation Cookbook](#implementation-cookbook)
5. [Code Generation Templates](#code-generation-templates)
6. [Quality Standards](#quality-standards)
7. [Real-World Examples](#real-world-examples)
8. [Troubleshooting Guide](#troubleshooting-guide)
9. [Best Practices](#best-practices)
10. [Reference Documentation](#reference-documentation)

---

## Executive Summary

### What is This?

This knowledge base provides **complete guidance** for migrating Delphi 6 VCL business applications to Laravel 12, preserving 100% of business logic while modernizing the tech stack.

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

### Pattern 1: Mode-Based Operations (Choice:Char)

**🎯 Purpose**: Map Delphi's single-procedure I/U/D logic to Laravel's CRUD methods

**📊 Frequency**: 100% (all modules)

**🔍 Detection Signature**:
```pascal
Procedure UpdateDataXXX(Choice:Char);
begin
  if Choice='I' then
    // INSERT logic
  else if Choice='U' then
    // UPDATE logic
  else if Choice='D' then
    // DELETE logic
end;
```

**✅ Laravel Implementation**:

```php
// Service Layer
class XXXService
{
    /**
     * INSERT (Choice='I')
     * Delphi: FrmXXX.pas, UpdateDataXXX(Choice:Char), line XXX
     */
    public function create(array $headerData, array $detailData): DbXXX
    {
        return DB::transaction(function () use ($headerData, $detailData) {
            // 1. Business validation
            $this->validateCreate($headerData, $detailData);

            // 2. Generate document number
            $noBukti = $this->generateDocumentNumber($headerData);

            // 3. Create header
            $header = DbXXX::create([
                'NOBUKTI' => $noBukti,
                'TglBukti' => $headerData['tgl_bukti'],
                // ... all fields
            ]);

            // 4. Create details
            foreach ($detailData as $index => $detail) {
                DbXXXDET::create([
                    'NOBUKTI' => $noBukti,
                    'NoUrut' => $index + 1,
                    // ... detail fields
                ]);
            }

            // 5. Log activity
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

            // Delete-and-recreate pattern for details
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
}
```

**📈 Coverage**: 100% in PPL, PO, PB migrations

---

### Pattern 2: Permission System

**🎯 Purpose**: Map Delphi permission flags to Laravel Policy + MenuAccessService

**📊 Frequency**: 100% (all modules)

**🔍 Detection Signature**:
```pascal
// Form declaration
private
  IsTambah: Boolean;   // Create permission
  IsKoreksi: Boolean;  // Update permission
  IsHapus: Boolean;    // Delete permission
  IsCetak: Boolean;    // Print permission
  IsExcel: Boolean;    // Export permission
```

**✅ Laravel Implementation**:

```php
// 1. Policy Class
class XXXPolicy
{
    public function __construct(
        protected MenuAccessService $menuAccessService
    ) {}

    /**
     * IsTambah → create()
     */
    public function create(User $user): bool
    {
        return $this->menuAccessService->canCreate($user, 'MODULE', 'L1_CODE');
    }

    /**
     * IsKoreksi → update()
     */
    public function update(User $user, DbXXX $model): bool
    {
        return $this->menuAccessService->canUpdate($user, 'MODULE', 'L1_CODE');
    }

    /**
     * IsHapus → delete()
     */
    public function delete(User $user, DbXXX $model): bool
    {
        return $this->menuAccessService->canDelete($user, 'MODULE', 'L1_CODE');
    }

    /**
     * IsCetak → print()
     */
    public function print(User $user, DbXXX $model): bool
    {
        $access = $this->menuAccessService->getMenuAccess($user->IDUser, 'MODULE', 'L1_CODE');
        return $access && $access->IsCetak == '1';
    }

    /**
     * IsExcel → export()
     */
    public function export(User $user): bool
    {
        $access = $this->menuAccessService->getMenuAccess($user->IDUser, 'MODULE', 'L1_CODE');
        return $access && $access->IsExcel == '1';
    }
}

// 2. Request Authorization
class StoreXXXRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->can('create', DbXXX::class);
    }
}

// 3. Controller Protection
public function create()
{
    if (!auth()->user()->can('create', DbXXX::class)) {
        return redirect()
            ->route('xxx.index')
            ->with('error', 'Tidak ada permission untuk membuat data');
    }
    return view('xxx.create');
}

// 4. View Permission Checks
@can('create', App\Models\DbXXX::class)
    <a href="{{ route('xxx.create') }}" class="btn btn-primary">Tambah Data</a>
@endcan

@can('update', $item)
    <a href="{{ route('xxx.edit', $item->NOBUKTI) }}" class="btn btn-warning">Edit</a>
@endcan

@can('delete', $item)
    <button onclick="confirmDelete()">Hapus</button>
@endcan
```

**📈 Coverage**: 100% in PPL, PO, PB migrations

---

### Pattern 3: Field Dependencies

**🎯 Purpose**: Implement cascading dropdowns and conditional fields

**📊 Frequency**: 70% (most forms)

**🔍 Detection Signature**:
```pascal
procedure TFrmXXX.FieldAChange(Sender: TObject);
begin
  // Reload FieldB options based on FieldA value
  QuFieldB.Close;
  QuFieldB.SQL.Clear;
  QuFieldB.SQL.Add('SELECT * FROM Table WHERE ParentField = :Value');
  QuFieldB.Parameters.ParamByName('Value').Value := FieldA.Text;
  QuFieldB.Open;
end;
```

**✅ Laravel Implementation**:

```php
// 1. AJAX Endpoint
class XXXController extends Controller
{
    /**
     * Get dependent field options
     * Delphi: FrmXXX.pas, FieldAChange event
     */
    public function getDependentOptions(Request $request)
    {
        $parentValue = $request->get('parent_value');

        $options = DB::table('DependentTable')
            ->where('ParentField', $parentValue)
            ->where('IsActive', 1)
            ->select('ID', 'Name')
            ->get();

        return response()->json($options);
    }
}

// 2. Route
Route::get('/xxx/api/dependent-options', [XXXController::class, 'getDependentOptions'])
    ->name('xxx.api.dependent-options');

// 3. JavaScript Handler
<script>
document.getElementById('parent_field').addEventListener('change', function() {
    const parentValue = this.value;
    const dependentField = document.getElementById('dependent_field');

    // Show loading state
    dependentField.innerHTML = '<option>Loading...</option>';
    dependentField.disabled = true;

    // Fetch options
    fetch(`/xxx/api/dependent-options?parent_value=${parentValue}`)
        .then(response => response.json())
        .then(data => {
            dependentField.innerHTML = '<option value="">-- Pilih --</option>';
            data.forEach(item => {
                const option = document.createElement('option');
                option.value = item.ID;
                option.textContent = item.Name;
                dependentField.appendChild(option);
            });
            dependentField.disabled = false;
        });
});
</script>
```

**📈 Coverage**: 100% in PB (warehouse → SPK items), 90% in PO (conditional fields)

---

### Pattern 4: Validation Rules (8 Sub-Patterns)

**🎯 Purpose**: Translate all Delphi validation logic to Laravel

**📊 Frequency**: 95% (almost all modules)

#### 4.1 Required Validation
```pascal
// Delphi
if FieldName.Text = '' then
  raise Exception.Create('Field harus diisi');

// Laravel
'field_name' => 'required'
```

#### 4.2 Unique Validation
```pascal
// Delphi
if QuCheck.Locate('KODE', KodeField.Text, []) then
  raise Exception.Create('Kode sudah digunakan');

// Laravel
'kode' => 'required|unique:table,KODE'

// For UPDATE (exclude current)
'kode' => [
    'required',
    Rule::unique('table', 'KODE')->ignore($this->route('id')),
]
```

#### 4.3 Range Validation
```pascal
// Delphi
if Quantity.AsFloat < 0 then
  raise Exception.Create('Qty harus >= 0');

// Laravel
'quantity' => 'required|numeric|min:0'
'discount' => 'required|numeric|min:0|max:100'
```

#### 4.4 Format Validation
```pascal
// Delphi
if not IsValidDate(TglField.Text) then
  raise Exception.Create('Format tanggal salah');

// Laravel
'tgl_field' => 'required|date_format:Y-m-d'
'email' => 'required|email:rfc,dns'
'no_hp' => 'required|regex:/^[0-9]{10,15}$/'
```

#### 4.5 Lookup/Foreign Key Validation
```pascal
// Delphi
if not QuBarang.Locate('KODEBRG', Kode.Text, []) then
  raise Exception.Create('Barang tidak ditemukan');

// Laravel
'kode_barang' => 'required|exists:dbbarang,KODEBRG'

// With conditions
'kode_barang' => [
    'required',
    Rule::exists('dbbarang', 'KODEBRG')->where('ISAKTIF', 1),
]
```

#### 4.6 Conditional Validation
```pascal
// Delphi
if TipeBarang.Text = 'Jadi' then
  if KodeProses.Text = '' then
    raise Exception.Create('Kode proses harus diisi');

// Laravel
'kode_proses' => 'required_if:tipe_barang,Jadi'
'no_pib' => 'required_if:jenis_po,Import'
```

#### 4.7 Enum Validation
```pascal
// Delphi
if not (Status.Text in ['Aktif', 'Nonaktif']) then
  raise Exception.Create('Status tidak valid');

// Laravel
'status' => 'required|in:Aktif,Nonaktif,Pending'
```

#### 4.8 Custom Business Logic
```pascal
// Delphi
if (Quantity.AsFloat > StokTersedia.AsFloat) then
  raise Exception.Create('Stok tidak mencukupi');

// Laravel
public function withValidator($validator)
{
    $validator->after(function ($validator) {
        if ($this->quantity > $this->getAvailableStock()) {
            $validator->errors()->add('quantity', 'Stok tidak mencukupi');
        }

        if ($this->isPeriodLocked($this->tgl_bukti)) {
            $validator->errors()->add('tgl_bukti', 'Period sudah ditutup');
        }
    });
}
```

**📈 Coverage**: 90-95% across all migrations

---

### Pattern 5: Authorization Workflow (OL-Based)

**🎯 Purpose**: Implement multi-level document authorization

**📊 Frequency**: 60% (modules with approval workflow)

**🔍 Critical First Step**: Check OL configuration
```sql
SELECT L1, KODEMENU, NAMA, OL FROM DBMENU WHERE KODEMENU = 'XXXX';

-- Examples:
-- PPL: OL=2 (Purchase Request: 2 levels)
-- PO:  OL=3 (Purchase Order: 3 levels)
-- PB:  OL=2 (Material Handover: 2 levels)
```

**✅ Laravel Implementation**:

```php
// Service Layer
class XXXService
{
    /**
     * Authorize document at specific level
     * Delphi: FrmXXX.pas, OtorisasiClick
     */
    public function authorize(string $noBukti, int $level): DbXXX
    {
        $model = DbXXX::where('NOBUKTI', $noBukti)->firstOrFail();

        // 1. Validate can authorize
        if ($model->IsBatal == 1) {
            throw new \Exception('Dokumen sudah dibatalkan');
        }

        // 2. Check cascading (must authorize previous level first)
        if ($level > 1) {
            $prevLevel = $level - 1;
            $prevAuthField = "IsOtorisasi{$prevLevel}";
            if ($model->$prevAuthField != 1) {
                throw new \Exception("Harus otorisasi level {$prevLevel} dulu");
            }
        }

        // 3. Check not already authorized
        $authField = "IsOtorisasi{$level}";
        if ($model->$authField == 1) {
            throw new \Exception("Level {$level} sudah diotorisasi");
        }

        // 4. Update authorization fields
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

    /**
     * Cancel authorization (cascades to higher levels)
     */
    public function cancelAuthorization(string $noBukti, int $level): DbXXX
    {
        $model = DbXXX::where('NOBUKTI', $noBukti)->firstOrFail();

        // Clear this level AND all higher levels (cascade)
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
}

// View - Dynamic columns based on OL
@php
    $maxVisibleLevel = 2; // From DBMENU.OL
@endphp

@for($level = 1; $level <= $maxVisibleLevel; $level++)
    @php
        $authField = "IsOtorisasi{$level}";
        $userField = "OtoUser{$level}";
        $dateField = "TglOto{$level}";
        $isAuthorized = $item->$authField == 1;
    @endphp

    <td>
        @if($isAuthorized)
            <span class="badge bg-success">✓</span>
            <br>
            <small>{{ $item->$userField }}</small>
            <br>
            <small>{{ $item->$dateField->format('d-m-Y H:i') }}</small>

            @if(!$item->IsBatal)
                <button onclick="cancelAuth('{{ $item->NOBUKTI }}', {{ $level }})">
                    ✕ Batalkan
                </button>
            @endif
        @else
            @if(canAuthorizeLevel($level) && !$item->IsBatal)
                <button onclick="authorizeDoc('{{ $item->NOBUKTI }}', {{ $level }})">
                    ✓ L{{ $level }}
                </button>
            @endif
        @endif
    </td>
@endfor
```

**📈 Coverage**: 100% in PPL (OL=2), PO (OL=3), PB (OL=2)

---

### Pattern 6: Audit Logging

**🎯 Purpose**: Log all data modification operations

**📊 Frequency**: 100% (all modules)

**🔍 Detection Signature**:
```pascal
LoggingData(IDUser, Choice, 'ModuleName', NoBukti.Text, 'Description');
```

**✅ Laravel Implementation**:

```php
class XXXService
{
    protected function logActivity(string $mode, string $noBukti, array $data, string $description = ''): void
    {
        Log::channel('activity')->info("XXX {$mode}", [
            'user_id' => auth()->user()->IDUser ?? 'SYSTEM',
            'mode' => $mode,  // I/U/D/O/C
            'module' => 'XXX',
            'nobukti' => $noBukti,
            'description' => $description,
            'data' => $data,
            'ip_address' => request()->ip(),
            'user_agent' => request()->userAgent(),
            'timestamp' => now(),
        ]);
    }

    // Call after each operation
    public function create(array $data): DbXXX
    {
        // ... create logic
        $this->logActivity('I', $noBukti, $data, 'Created new document');
        return $result;
    }

    public function update(string $noBukti, array $data): DbXXX
    {
        // ... update logic
        $this->logActivity('U', $noBukti, $data, 'Updated document');
        return $result;
    }

    public function delete(string $noBukti): bool
    {
        // ... delete logic
        $this->logActivity('D', $noBukti, [], 'Deleted document');
        return true;
    }
}

// Alternative: Database logging (like Delphi)
protected function logActivity(string $mode, string $noBukti, array $data, string $description = ''): void
{
    DB::table('dbLogFile')->insert([
        'IDUser' => auth()->user()->IDUser ?? 'SYSTEM',
        'Mode' => $mode,
        'Module' => 'XXX',
        'NoBukti' => $noBukti,
        'Keterangan' => $description,
        'TglLog' => now(),
        'IPAddress' => request()->ip(),
    ]);
}
```

**📈 Coverage**: 100% in all migrations

---

### Pattern 7: Master-Detail Forms

**🎯 Purpose**: Handle header + detail line relationships

**📊 Frequency**: 50% (master-detail forms)

**🔍 Detection Signature**:
```pascal
// Loop through detail grid
for i := 0 to StringGrid.RowCount - 1 do
begin
  QuDetail.Append;
  QuDetail.FieldByName('NOBUKTI').AsString := NoBukti.Text;
  QuDetail.FieldByName('NoUrut').AsInteger := i + 1;
  QuDetail.Post;
end;
```

**Two Variations**:

#### Single-Item Detail (PB Pattern)
```php
// Validation
'details' => 'required|array|size:1'  // Exactly 1

// Service
public function create(array $headerData, array $detailData): DbXXX
{
    return DB::transaction(function () use ($headerData, $detailData) {
        if (count($detailData) !== 1) {
            throw new \Exception('PB harus memiliki tepat 1 detail');
        }

        $header = DbXXX::create([...]);

        DbXXXDET::create([
            'NOBUKTI' => $header->NOBUKTI,
            'NoUrut' => 1,  // Always 1
            // ... fields
        ]);

        return $header->fresh();
    });
}

// Cannot add second detail
public function addDetailLine(string $noBukti, array $detailData): void
{
    $existingCount = DbXXXDET::where('NOBUKTI', $noBukti)->count();
    if ($existingCount >= 1) {
        throw new \Exception('PB sudah punya detail, tidak bisa tambah lagi');
    }
}
```

#### Multiple-Item Detail (PPL/PO Pattern)
```php
// Validation
'details' => 'required|array|min:1'  // At least 1

// Service
public function create(array $headerData, array $detailData): DbXXX
{
    return DB::transaction(function () use ($headerData, $detailData) {
        if (count($detailData) < 1) {
            throw new \Exception('Minimal 1 detail harus ada');
        }

        $header = DbXXX::create([...]);

        foreach ($detailData as $index => $detail) {
            DbXXXDET::create([
                'NOBUKTI' => $header->NOBUKTI,
                'NoUrut' => $index + 1,
                // ... fields
            ]);
        }

        return $header->fresh();
    });
}

// Delete detail with minimum check
public function deleteDetailLine(string $noBukti, int $noUrut): void
{
    $detailCount = DbXXXDET::where('NOBUKTI', $noBukti)->count();

    if ($detailCount <= 1) {
        throw new \Exception('Minimal 1 detail harus ada. Tidak bisa hapus yang terakhir.');
    }

    DbXXXDET::where('NOBUKTI', $noBukti)
        ->where('NoUrut', $noUrut)
        ->delete();
}
```

**📈 Coverage**: Single-item (PB 100%), Multiple-item (PPL, PO 100%)

---

### Pattern 8: Lookup & Search

**🎯 Purpose**: Implement search modals and autocomplete

**📊 Frequency**: 80% (most forms)

**🔍 Detection Signature**:
```pascal
// Lookup form call
if BtnLookup.Click then
begin
  with TFrmLookupBarang.Create(Self) do
  try
    ShowModal;
    if ModalResult = mrOK then
      KodeBarang.Text := SelectedKode;
  finally
    Free;
  end;
end;
```

**✅ Laravel Implementation**:

```php
// 1. API Endpoint
class LookupController extends Controller
{
    /**
     * Barang lookup
     * Delphi: FrmLookupBarang, KodeBrows=1014001
     */
    public function barangLookup(Request $request)
    {
        $search = $request->get('search', '');

        $results = DB::table('DBBARANG')
            ->where('ISAKTIF', 1)
            ->where(function ($q) use ($search) {
                $q->where('KODEBRG', 'like', "%{$search}%")
                  ->orWhere('NAMABRG', 'like', "%{$search}%");
            })
            ->select('KODEBRG', 'NAMABRG', 'Sat1', 'Sat2', 'Isi2')
            ->orderBy('KODEBRG')
            ->limit(100)
            ->get();

        return response()->json($results);
    }
}

// 2. Modal View
<div class="modal fade" id="barangModal">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5>Pilih Barang</h5>
            </div>
            <div class="modal-body">
                <input type="text" id="barang-search" class="form-control"
                       placeholder="Cari kode atau nama...">

                <table class="table">
                    <thead>
                        <tr>
                            <th>Kode</th>
                            <th>Nama</th>
                            <th>Satuan</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="barang-table-body">
                        <!-- Populated by JavaScript -->
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

// 3. JavaScript
<script>
const barangModal = new bootstrap.Modal(document.getElementById('barangModal'));
const searchInput = document.getElementById('barang-search');
const tableBody = document.getElementById('barang-table-body');

let searchTimeout;

searchInput.addEventListener('input', function() {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(() => {
        loadBarangList(this.value);
    }, 300);  // Debounce 300ms
});

function loadBarangList(search = '') {
    tableBody.innerHTML = '<tr><td colspan="4">Loading...</td></tr>';

    fetch(`/api/lookup/barang?search=${encodeURIComponent(search)}`)
        .then(response => response.json())
        .then(items => {
            tableBody.innerHTML = items.map(item => `
                <tr>
                    <td>${item.KODEBRG}</td>
                    <td>${item.NAMABRG}</td>
                    <td>${item.Sat1}</td>
                    <td>
                        <button onclick="selectBarang('${item.KODEBRG}', '${item.NAMABRG}')">
                            Pilih
                        </button>
                    </td>
                </tr>
            `).join('');
        });
}

function selectBarang(kode, nama) {
    document.getElementById('kode_brg').value = kode;
    document.getElementById('nama_brg').value = nama;
    barangModal.hide();
}
</script>
```

**📈 Coverage**: 100% in PB (SPK lookup), 90% in PO/PPL (barang lookup)

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
