# Delphi to Laravel Migration Pattern Guide

**Version**: 2.0
**Last Updated**: 2026-01-03
**Purpose**: Quick reference untuk mendeteksi dan mengimplementasikan pattern dari Delphi ke Laravel

---

## 📑 Daftar Isi

1. [Pattern Overview](#pattern-overview)
2. [Pattern 1: Mode-Based Operations (Choice:Char)](#pattern-1-mode-based-operations-choicechar)
3. [Pattern 2: Permission System](#pattern-2-permission-system)
4. [Pattern 3: Field Dependencies](#pattern-3-field-dependencies)
5. [Pattern 4: Validation Rules (8 Sub-Patterns)](#pattern-4-validation-rules)
6. [Pattern 5: Authorization Workflow (OL-Based)](#pattern-5-authorization-workflow)
7. [Pattern 6: Audit Logging](#pattern-6-audit-logging)
8. [Pattern 7: Master-Detail Forms](#pattern-7-master-detail-forms)
9. [Pattern 8: Lookup & Search](#pattern-8-lookup--search)
10. [Pattern Detection Checklist](#pattern-detection-checklist)
11. [Implementation Checklist](#implementation-checklist)

---

## Pattern Overview

### Coverage Matrix

| Pattern | Frequency | Complexity | Impact | Priority |
|---------|-----------|------------|--------|----------|
| 1. Mode Operations | 100% | Medium | Critical | P0 |
| 2. Permissions | 100% | Low | Critical | P0 |
| 3. Field Dependencies | 70% | Medium | High | P1 |
| 4. Validation Rules | 95% | High | Critical | P0 |
| 5. Authorization Workflow | 60% | High | High | P1 |
| 6. Audit Logging | 100% | Low | Critical | P0 |
| 7. Master-Detail | 50% | High | High | P1 |
| 8. Lookup & Search | 80% | Medium | Medium | P2 |

### Success Metrics Target

- ✅ **Mode Coverage**: 100% (all I/U/D detected)
- ✅ **Permission Coverage**: 100% (all permission variables mapped)
- ✅ **Validation Coverage**: ≥95% (all 8 sub-patterns)
- ✅ **Audit Coverage**: 100% (all LoggingData calls)
- ✅ **Manual Work**: <5% (mostly config adjustments)

---

## Pattern 1: Mode-Based Operations (Choice:Char)

### 🔍 Detection in Delphi

**Primary Signature**:
```pascal
Procedure TFrmXXX.UpdateDataXXX(Choice:Char);
begin
  if Choice='I' then
    // INSERT mode logic
  else if Choice='U' then
    // UPDATE mode logic
  else if Choice='D' then
    // DELETE mode logic
end;
```

**Alternative Signatures**:
```pascal
// Variant 1: Case statement
case Choice of
  'I': // Insert
  'U': // Update
  'D': // Delete
end;

// Variant 2: String parameter
Procedure SaveData(Mode: String);
if Mode = 'INSERT' then ...

// Variant 3: Separate procedures
Procedure InsertData;
Procedure UpdateData;
Procedure DeleteData;
```

**Where to Look**:
- Line range: Usually 200-500 lines into .pas file
- Look for: `Choice:Char`, `Mode:String`, `Operation:String`
- Button handlers: `BtnTambahClick`, `BtnKoreksiClick`, `BtnHapusClick`
- Variable tracking: `XChoice`, `SaveMode`, `CurrentOperation`

**Detection Checklist**:
- [ ] Found procedure with Choice/Mode parameter
- [ ] Found if/case statement on Choice value
- [ ] Found INSERT logic (Choice='I')
- [ ] Found UPDATE logic (Choice='U')
- [ ] Found DELETE logic (Choice='D')
- [ ] Found different parameter setup per mode
- [ ] Found different error handling per mode
- [ ] Found mode-specific post-processing

### 🎯 Implementation in Laravel

**Architecture**: Controller → Request → Service

**Step 1: Service Layer** (Business Logic)
```php
// app/Services/XXXService.php
namespace App\Services;

use App\Models\DbXXX;
use App\Models\DbXXXDET;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class XXXService
{
    /**
     * INSERT mode (Choice='I')
     * Delphi: FrmXXX.pas, UpdateDataXXX(Choice:Char), line XXX
     */
    public function create(array $headerData, array $detailData): DbXXX
    {
        return DB::transaction(function () use ($headerData, $detailData) {
            // 1. Validate business rules (Delphi pre-checks)
            $this->validateCreate($headerData, $detailData);

            // 2. Generate document number
            $noBukti = $this->generateDocumentNumber($headerData);

            // 3. Create header (ExecProc equivalent for INSERT)
            $header = DbXXX::create([
                'NOBUKTI' => $noBukti,
                'TglBukti' => $headerData['tgl_bukti'],
                'KodeSupplier' => $headerData['kode_supplier'],
                // ... map all Delphi parameters
            ]);

            // 4. Create details
            foreach ($detailData as $index => $detail) {
                DbXXXDET::create([
                    'NOBUKTI' => $noBukti,
                    'NoUrut' => $index + 1,
                    'KODEBRG' => $detail['kode_brg'],
                    'Qnt' => $detail['quantity'],
                    // ... map all detail fields
                ]);
            }

            // 5. Log activity (LoggingData equivalent)
            $this->logActivity('I', $noBukti, $headerData);

            return $header->fresh();
        });
    }

    /**
     * UPDATE mode (Choice='U')
     * Delphi: FrmXXX.pas, UpdateDataXXX(Choice:Char), line XXX
     */
    public function update(string $noBukti, array $headerData, array $detailData): DbXXX
    {
        return DB::transaction(function () use ($noBukti, $headerData, $detailData) {
            // 1. Find existing record
            $header = DbXXX::where('NOBUKTI', $noBukti)->firstOrFail();

            // 2. Validate can update (Delphi pre-checks)
            $this->validateUpdate($header, $headerData);

            // 3. Update header (ExecProc equivalent for UPDATE)
            $header->update([
                'TglBukti' => $headerData['tgl_bukti'],
                'KodeSupplier' => $headerData['kode_supplier'],
                // ... update fields (some may be immutable)
            ]);

            // 4. Update details (delete old, insert new pattern)
            DbXXXDET::where('NOBUKTI', $noBukti)->delete();
            foreach ($detailData as $index => $detail) {
                DbXXXDET::create([
                    'NOBUKTI' => $noBukti,
                    'NoUrut' => $index + 1,
                    // ... detail fields
                ]);
            }

            // 5. Log activity
            $this->logActivity('U', $noBukti, $headerData);

            return $header->fresh();
        });
    }

    /**
     * DELETE mode (Choice='D')
     * Delphi: FrmXXX.pas, UpdateDataXXX(Choice:Char), line XXX
     */
    public function delete(string $noBukti): bool
    {
        return DB::transaction(function () use ($noBukti) {
            // 1. Find existing record
            $header = DbXXX::where('NOBUKTI', $noBukti)->firstOrFail();

            // 2. Validate can delete (Delphi pre-checks)
            $this->validateDelete($header);

            // 3. Delete details first (cascade)
            DbXXXDET::where('NOBUKTI', $noBukti)->delete();

            // 4. Delete header (ExecProc equivalent for DELETE)
            $deleted = $header->delete();

            // 5. Log activity
            $this->logActivity('D', $noBukti, []);

            return $deleted;
        });
    }

    // Validation methods
    protected function validateCreate(array $headerData, array $detailData): void
    {
        // Business rules from Delphi
        // e.g., period lock, stock validation, etc.
    }

    protected function validateUpdate(DbXXX $header, array $headerData): void
    {
        // Cannot update if authorized
        if ($header->IsOtorisasi1 == 1) {
            throw new \Exception('Dokumen sudah diotorisasi, tidak dapat diubah');
        }
    }

    protected function validateDelete(DbXXX $header): void
    {
        // Cannot delete if authorized
        if ($header->IsOtorisasi1 == 1) {
            throw new \Exception('Dokumen sudah diotorisasi, tidak dapat dihapus');
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

**Step 2: Controller Layer** (HTTP Handling)
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

    /**
     * INSERT mode (Choice='I')
     * Delphi: BtnTambahClick
     */
    public function store(StoreXXXRequest $request)
    {
        try {
            $result = $this->service->create(
                $request->only(['tgl_bukti', 'kode_supplier', ...]),
                $request->input('details', [])
            );

            return redirect()
                ->route('xxx.show', $result->NOBUKTI)
                ->with('success', 'Data berhasil disimpan');
        } catch (\Exception $e) {
            return redirect()
                ->back()
                ->withInput()
                ->with('error', 'Gagal menyimpan: ' . $e->getMessage());
        }
    }

    /**
     * UPDATE mode (Choice='U')
     * Delphi: BtnKoreksiClick
     */
    public function update(UpdateXXXRequest $request, string $noBukti)
    {
        try {
            $result = $this->service->update(
                $noBukti,
                $request->only(['tgl_bukti', 'kode_supplier', ...]),
                $request->input('details', [])
            );

            return redirect()
                ->route('xxx.show', $noBukti)
                ->with('success', 'Data berhasil diubah');
        } catch (\Exception $e) {
            return redirect()
                ->back()
                ->withInput()
                ->with('error', 'Gagal mengubah: ' . $e->getMessage());
        }
    }

    /**
     * DELETE mode (Choice='D')
     * Delphi: BtnHapusClick
     */
    public function destroy(string $noBukti)
    {
        try {
            $this->service->delete($noBukti);

            return redirect()
                ->route('xxx.index')
                ->with('success', 'Data berhasil dihapus');
        } catch (\Exception $e) {
            return redirect()
                ->back()
                ->with('error', 'Gagal menghapus: ' . $e->getMessage());
        }
    }
}
```

**Step 3: Request Classes** (Validation per Mode)
```php
// app/Http/Requests/XXX/StoreXXXRequest.php
// For INSERT mode (Choice='I')
namespace App\Http\Requests\XXX;

use Illuminate\Foundation\Http\FormRequest;

class StoreXXXRequest extends FormRequest
{
    public function authorize(): bool
    {
        // IsTambah permission check
        return app(\App\Services\MenuAccessService::class)
            ->canCreate(auth()->user(), 'MODULE', 'L1_CODE');
    }

    public function rules(): array
    {
        return [
            // All fields required for INSERT
            'tgl_bukti' => 'required|date',
            'kode_supplier' => 'required|exists:dbsupplier,KODESUPPLIER',
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
}

// app/Http/Requests/XXX/UpdateXXXRequest.php
// For UPDATE mode (Choice='U')
class UpdateXXXRequest extends FormRequest
{
    public function authorize(): bool
    {
        // IsKoreksi permission check
        return app(\App\Services\MenuAccessService::class)
            ->canUpdate(auth()->user(), 'MODULE', 'L1_CODE');
    }

    public function rules(): array
    {
        return [
            // Some fields may be immutable in UPDATE mode
            'tgl_bukti' => 'required|date',
            'kode_supplier' => 'required|exists:dbsupplier,KODESUPPLIER',
            'details' => 'required|array|min:1',
            'details.*.kode_brg' => 'required|exists:dbbarang,KODEBRG',
            'details.*.quantity' => 'required|numeric|min:0.01',
        ];
    }
}
```

### ✅ Implementation Checklist

- [ ] Created service with create/update/delete methods
- [ ] Mapped INSERT logic (Choice='I') to create()
- [ ] Mapped UPDATE logic (Choice='U') to update()
- [ ] Mapped DELETE logic (Choice='D') to delete()
- [ ] Created StoreRequest for INSERT validation
- [ ] Created UpdateRequest for UPDATE validation
- [ ] Added controller methods: store(), update(), destroy()
- [ ] Wrapped operations in DB::transaction()
- [ ] Added error handling try/catch
- [ ] Added activity logging
- [ ] Tested INSERT flow
- [ ] Tested UPDATE flow
- [ ] Tested DELETE flow

### 📊 Real Example: PPL Module

**Delphi**: `FrmPPL.pas`, line 425
```pascal
Procedure TFrmPPL.UpdateDataPPL(Choice:Char);
begin
  if Choice='I' then
  begin
    // INSERT: All parameters needed
    sp_PPL.Parameters[2].Value := NoBukti.Text;
    sp_PPL.Parameters[3].Value := TglBukti.Date;
    // ... 15+ parameters
  end
  else if Choice='U' then
  begin
    // UPDATE: Same parameters
    sp_PPL.Parameters[2].Value := NoBukti.Text;
    // ... update parameters
  end
  else if Choice='D' then
  begin
    // DELETE: Only ID needed
    sp_PPL.Parameters[2].Value := NoBukti.Text;
  end;

  sp_PPL.ExecProc;
  LoggingData(IDUser, Choice, 'PPL', NoBukti.Text, Keterangan);
end;
```

**Laravel**: `app/Services/PPLService.php`
```php
public function create(array $data): DbPPL
{
    return DB::transaction(function () use ($data) {
        $noBukti = $this->generatePPLNumber($data);

        $ppl = DbPPL::create([
            'NOBUKTI' => $noBukti,
            'TglBukti' => $data['tgl_bukti'],
            // ... all INSERT fields
        ]);

        foreach ($data['details'] as $index => $detail) {
            DbPPLDET::create([...]);
        }

        $this->logActivity('I', $noBukti, $data);
        return $ppl;
    });
}
```

**Coverage**: ✅ 100% (all I/U/D modes implemented)

---

## Pattern 2: Permission System

### 🔍 Detection in Delphi

**Primary Signature**:
```pascal
// Form variable declarations
private
  IsTambah: Boolean;
  IsKoreksi: Boolean;
  IsHapus: Boolean;
  IsCetak: Boolean;
  IsExcel: Boolean;

// Button visibility control
BtnTambah.Enabled := IsTambah;
BtnKoreksi.Enabled := IsKoreksi;
BtnHapus.Enabled := IsHapus;

// Permission check in action
if not IsTambah then
begin
  ShowMessage('Anda tidak memiliki akses untuk menambah data');
  Exit;
end;
```

**Where to Look**:
- Form declaration section (private/public variables)
- FormCreate/FormShow procedures
- Button click handlers
- Look for: `IsTambah`, `IsKoreksi`, `IsHapus`, `IsCetak`, `IsExcel`

**Detection Checklist**:
- [ ] Found IsTambah variable (create permission)
- [ ] Found IsKoreksi variable (update permission)
- [ ] Found IsHapus variable (delete permission)
- [ ] Found IsCetak variable (print permission)
- [ ] Found IsExcel variable (export permission)
- [ ] Found button enable/disable based on permissions
- [ ] Found permission checks in procedures

### 🎯 Implementation in Laravel

**Architecture**: Request → Policy → MenuAccessService → DBFLMENU

**Step 1: Policy Class**
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

    /**
     * IsTambah - Create permission
     * Delphi: FrmXXX.pas, IsTambah variable
     */
    public function create(User $user): bool
    {
        return $this->menuAccessService->canCreate(
            $user,
            'MODULE_CODE',  // e.g., 'BP', 'PPL', 'PO'
            'L1_CODE'       // e.g., '05006'
        );
    }

    /**
     * IsKoreksi - Update permission
     * Delphi: FrmXXX.pas, IsKoreksi variable
     */
    public function update(User $user, DbXXX $model): bool
    {
        return $this->menuAccessService->canUpdate(
            $user,
            'MODULE_CODE',
            'L1_CODE'
        );
    }

    /**
     * IsHapus - Delete permission
     * Delphi: FrmXXX.pas, IsHapus variable
     */
    public function delete(User $user, DbXXX $model): bool
    {
        return $this->menuAccessService->canDelete(
            $user,
            'MODULE_CODE',
            'L1_CODE'
        );
    }

    /**
     * IsCetak - Print permission
     * Delphi: FrmXXX.pas, IsCetak variable
     */
    public function print(User $user, DbXXX $model): bool
    {
        $access = $this->menuAccessService->getMenuAccess(
            $user->IDUser,
            'MODULE_CODE',
            'L1_CODE'
        );

        return $access && $access->IsCetak == '1';
    }

    /**
     * IsExcel - Export permission
     * Delphi: FrmXXX.pas, IsExcel variable
     */
    public function export(User $user): bool
    {
        $access = $this->menuAccessService->getMenuAccess(
            $user->IDUser,
            'MODULE_CODE',
            'L1_CODE'
        );

        return $access && $access->IsExcel == '1';
    }
}
```

**Step 2: Request Authorization**
```php
// app/Http/Requests/XXX/StoreXXXRequest.php
public function authorize(): bool
{
    // Check IsTambah permission
    return $this->user()->can('create', DbXXX::class);
}

// app/Http/Requests/XXX/UpdateXXXRequest.php
public function authorize(): bool
{
    // Check IsKoreksi permission
    $model = $this->route('xxx'); // Get model from route
    return $this->user()->can('update', $model);
}
```

**Step 3: Controller Authorization**
```php
// app/Http/Controllers/XXXController.php

public function create()
{
    // Check IsTambah permission
    if (!auth()->user()->can('create', DbXXX::class)) {
        return redirect()
            ->route('xxx.index')
            ->with('error', 'Anda tidak memiliki permission untuk membuat data. Hubungi administrator untuk mengaktifkan permission "Tambah" (ISTAMBAH).');
    }

    return view('xxx.create');
}

public function edit(string $noBukti)
{
    $model = DbXXX::where('NOBUKTI', $noBukti)->firstOrFail();

    // Check IsKoreksi permission
    if (!auth()->user()->can('update', $model)) {
        return redirect()
            ->route('xxx.show', $noBukti)
            ->with('error', 'Anda tidak memiliki permission untuk mengubah data. Hubungi administrator untuk mengaktifkan permission "Ubah/Koreksi" (ISKOREKSI).');
    }

    return view('xxx.edit', compact('model'));
}

public function destroy(string $noBukti)
{
    $model = DbXXX::where('NOBUKTI', $noBukti)->firstOrFail();

    // Check IsHapus permission
    $this->authorize('delete', $model);

    // Delete logic...
}
```

**Step 4: View Permission Checks**
```blade
{{-- resources/views/xxx/index.blade.php --}}

{{-- IsTambah: Show create button --}}
@can('create', App\Models\DbXXX::class)
    <a href="{{ route('xxx.create') }}" class="btn btn-primary">
        <i class="fas fa-plus"></i> Tambah Data
    </a>
@endcan

{{-- List items --}}
@foreach($items as $item)
    <tr>
        <td>{{ $item->NOBUKTI }}</td>
        <td>{{ $item->TglBukti }}</td>
        <td>
            {{-- IsKoreksi: Show edit button --}}
            @can('update', $item)
                <a href="{{ route('xxx.edit', $item->NOBUKTI) }}" class="btn btn-sm btn-warning">
                    <i class="fas fa-edit"></i> Edit
                </a>
            @endcan

            {{-- IsHapus: Show delete button --}}
            @can('delete', $item)
                <form method="POST" action="{{ route('xxx.destroy', $item->NOBUKTI) }}" style="display:inline">
                    @csrf @method('DELETE')
                    <button class="btn btn-sm btn-danger" onclick="return confirm('Yakin hapus?')">
                        <i class="fas fa-trash"></i> Hapus
                    </button>
                </form>
            @endcan

            {{-- IsCetak: Show print button --}}
            @can('print', $item)
                <a href="{{ route('xxx.print', $item->NOBUKTI) }}" class="btn btn-sm btn-info" target="_blank">
                    <i class="fas fa-print"></i> Cetak
                </a>
            @endcan
        </td>
    </tr>
@endforeach

{{-- IsExcel: Show export button --}}
@can('export', App\Models\DbXXX::class)
    <a href="{{ route('xxx.export') }}" class="btn btn-success">
        <i class="fas fa-file-excel"></i> Export Excel
    </a>
@endcan
```

### ✅ Implementation Checklist

- [ ] Created Policy class with all permission methods
- [ ] Mapped IsTambah to create() policy
- [ ] Mapped IsKoreksi to update() policy
- [ ] Mapped IsHapus to delete() policy
- [ ] Mapped IsCetak to print() policy
- [ ] Mapped IsExcel to export() policy
- [ ] Added authorize() in Request classes
- [ ] Added permission checks in Controller
- [ ] Added @can directives in views
- [ ] Verified DBFLMENU has correct permissions
- [ ] Tested with user who has permissions
- [ ] Tested with user who lacks permissions

### 📊 Real Example: Penyerahan Bahan (PB)

**Delphi**: `FrmMainPB.pas`
```pascal
IsTambah, IsKoreksi, IsHapus, IsCetak, IsExcel: Boolean;

procedure TFrmMainPB.FormCreate(Sender: TObject);
begin
  // Load permissions from database
  IsTambah := GetPermission('ISTAMBAH');
  IsKoreksi := GetPermission('ISKOREKSI');
  IsHapus := GetPermission('ISHAPUS');

  // Set button visibility
  BtnTambah.Enabled := IsTambah;
  BtnKoreksi.Enabled := IsKoreksi;
  BtnHapus.Enabled := IsHapus;
end;
```

**Laravel**: `app/Policies/PenyerahanBhnPolicy.php`
```php
public function create(User $user): bool
{
    return $this->menuAccessService->canCreate($user, 'BP', '05006');
}

public function update(User $user, DbPenyerahanBhn $model): bool
{
    return $this->menuAccessService->canUpdate($user, 'BP', '05006');
}
```

**Coverage**: ✅ 100% (all permission types mapped)

---

## Pattern 3: Field Dependencies

### 🔍 Detection in Delphi

**Primary Signature**:
```pascal
// Field change triggers dependent field update
procedure TFrmXXX.FieldAChange(Sender: TObject);
begin
  // Load options for FieldB based on FieldA
  LoadFieldBOptions(FieldA.Text);
end;

// Example: Warehouse change loads SPK items
procedure TFrmPB.GudangChange(Sender: TObject);
begin
  QuSPK.Close;
  QuSPK.SQL.Clear;
  QuSPK.SQL.Add('SELECT * FROM DBSPKDET WHERE KodeGdg = :KodeGdg');
  QuSPK.Parameters.ParamByName('KodeGdg').Value := Gudang.Text;
  QuSPK.Open;
end;

// Example: Type change shows/hides panels
procedure TFrmPO.TipeChange(Sender: TObject);
begin
  if Tipe.Text = 'Lokal' then
  begin
    PanelLokal.Visible := True;
    PanelImport.Visible := False;
  end
  else
  begin
    PanelLokal.Visible := False;
    PanelImport.Visible := True;
  end;
end;
```

**Where to Look**:
- OnChange event handlers
- OnExit event handlers
- Conditional panel visibility
- Cascading combobox/lookup
- Look for: Query reopen, SQL parameter changes, Visible := condition

**Detection Checklist**:
- [ ] Found field OnChange handlers
- [ ] Found query reload based on field value
- [ ] Found panel/field visibility conditions
- [ ] Found cascading lookup (A → B → C)
- [ ] Found conditional required fields
- [ ] Found field enable/disable based on other fields

### 🎯 Implementation in Laravel

**Architecture**: View (JavaScript) → AJAX → Controller → JSON Response

**Step 1: AJAX Endpoint**
```php
// app/Http/Controllers/XXXController.php

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
        ->select('ID', 'Name', 'OtherFields')
        ->get();

    return response()->json($options);
}

// Example: PB - Get SPK items by warehouse
public function getAvailableSPKItems(Request $request)
{
    $kodegdg = $request->get('kodegdg');

    $items = DB::table('DBSPKDET as SPKDET')
        ->leftJoin('DBBARANG as BAR', 'BAR.KODEBRG', '=', 'SPKDET.KODEBRG')
        ->leftJoin('DBSPK as SPK', 'SPK.NOBUKTI', '=', 'SPKDET.NOBUKTI')
        ->where('SPK.KodeGdg', $kodegdg)
        ->where(function ($q) {
            $q->whereNull('SPK.IsCLose')->orWhere('SPK.IsCLose', 0);
        })
        ->select([
            'SPKDET.NOBUKTI',
            'SPKDET.NoUrut',
            'SPKDET.KODEBRG',
            'BAR.NAMABRG',
            'SPKDET.Qnt as QntRencana',
            // ... other fields
        ])
        ->get();

    return response()->json($items);
}
```

**Step 2: Route Registration**
```php
// routes/web.php

Route::prefix('xxx')->group(function () {
    // ... other routes

    Route::get('/api/dependent-options', [XXXController::class, 'getDependentOptions'])
        ->name('xxx.api.dependent-options');

    // Example: PB
    Route::get('/api/spk-items', [PenyerahanBhnController::class, 'getAvailableSPKItems'])
        ->name('penyerahan-bhn.api.spk-items');
});
```

**Step 3: JavaScript Handler**
```javascript
// resources/views/xxx/create.blade.php

<script>
document.addEventListener('DOMContentLoaded', function() {
    // Parent field change handler
    const parentField = document.getElementById('parent_field');
    const dependentField = document.getElementById('dependent_field');

    parentField.addEventListener('change', function() {
        const parentValue = this.value;

        // Show loading state
        dependentField.innerHTML = '<option>Loading...</option>';
        dependentField.disabled = true;

        // Fetch dependent options
        fetch(`/xxx/api/dependent-options?parent_value=${parentValue}`)
            .then(response => response.json())
            .then(data => {
                // Clear and populate options
                dependentField.innerHTML = '<option value="">-- Pilih --</option>';

                data.forEach(item => {
                    const option = document.createElement('option');
                    option.value = item.ID;
                    option.textContent = item.Name;
                    dependentField.appendChild(option);
                });

                dependentField.disabled = false;
            })
            .catch(error => {
                console.error('Error loading options:', error);
                dependentField.innerHTML = '<option>Error loading data</option>';
            });
    });
});
</script>
```

**Step 4: Conditional Field Visibility**
```javascript
// Show/hide fields based on type selection
const tipeField = document.getElementById('tipe');
const panelLokal = document.getElementById('panel_lokal');
const panelImport = document.getElementById('panel_import');

tipeField.addEventListener('change', function() {
    if (this.value === 'Lokal') {
        panelLokal.style.display = 'block';
        panelImport.style.display = 'none';

        // Make lokal fields required
        document.querySelectorAll('#panel_lokal input[data-required]').forEach(input => {
            input.required = true;
        });

        // Make import fields optional
        document.querySelectorAll('#panel_import input[data-required]').forEach(input => {
            input.required = false;
        });
    } else {
        panelLokal.style.display = 'none';
        panelImport.style.display = 'block';

        // Reverse required status
        document.querySelectorAll('#panel_lokal input[data-required]').forEach(input => {
            input.required = false;
        });
        document.querySelectorAll('#panel_import input[data-required]').forEach(input => {
            input.required = true;
        });
    }
});
```

### ✅ Implementation Checklist

- [ ] Identified all field dependencies in Delphi
- [ ] Created AJAX endpoint for each dependency
- [ ] Added routes for AJAX endpoints
- [ ] Implemented JavaScript change handlers
- [ ] Added loading states (UX)
- [ ] Added error handling
- [ ] Implemented conditional visibility
- [ ] Implemented conditional required fields
- [ ] Tested cascading updates
- [ ] Tested with empty/null values

### 📊 Real Example: PB - Warehouse → SPK Items

**Delphi**: `FrmPB.pas`
```pascal
procedure TFrmPB.GudangChange(Sender: TObject);
begin
  QuSPK.Close;
  QuSPK.SQL.Clear;
  QuSPK.SQL.Add('SELECT SPKDET.*, BAR.NAMABRG FROM DBSPKDET SPKDET');
  QuSPK.SQL.Add('LEFT JOIN DBSPK SPK ON SPK.NOBUKTI = SPKDET.NOBUKTI');
  QuSPK.SQL.Add('LEFT JOIN DBBARANG BAR ON BAR.KODEBRG = SPKDET.KODEBRG');
  QuSPK.SQL.Add('WHERE SPK.KodeGdg = :KodeGdg AND SPK.IsCLose = 0');
  QuSPK.Parameters.ParamByName('KodeGdg').Value := Gudang.Text;
  QuSPK.Open;
end;
```

**Laravel**:
- Endpoint: `GET /penyerahan-bhn/api/spk-items?kodegdg=XXX`
- Handler: JavaScript change listener on warehouse dropdown
- Response: JSON array of available SPK items

**Coverage**: ✅ 100% (warehouse dependency implemented)

---

## Pattern 4: Validation Rules

### Overview: 8 Sub-Patterns

| Pattern | Delphi | Laravel | Frequency |
|---------|--------|---------|-----------|
| 4.1 Range | `if Value < Min` | `min:0` | 95% |
| 4.2 Unique | `QuCheck.Locate(...)` | `unique:table,field` | 80% |
| 4.3 Required | `if Text = ''` | `required` | 100% |
| 4.4 Format | `IsValidDate(...)` | `date_format:Y-m-d` | 70% |
| 4.5 Lookup/FK | `if not QuTable.Locate` | `exists:table,field` | 90% |
| 4.6 Conditional | `if Type=1 then if Field...` | `required_if:type,1` | 60% |
| 4.7 Enum | `if not (Status in [...])` | `in:A,B,C` | 50% |
| 4.8 Custom | `raise Exception.Create(...)` | `withValidator()` | 40% |

### 4.1 Range Validation

**Delphi**:
```pascal
if Quantity.AsFloat < 0 then
  raise Exception.Create('Quantity harus >= 0');

if Discount.AsFloat > 100 then
  raise Exception.Create('Diskon maksimal 100%');

if (Price.AsFloat < MinPrice.AsFloat) or (Price.AsFloat > MaxPrice.AsFloat) then
  raise Exception.Create('Harga diluar range yang diizinkan');
```

**Laravel**:
```php
public function rules(): array
{
    return [
        'quantity' => 'required|numeric|min:0',
        'discount' => 'required|numeric|min:0|max:100',
        'price' => 'required|numeric|min:' . $minPrice . '|max:' . $maxPrice,
    ];
}
```

### 4.2 Unique Validation

**Delphi**:
```pascal
if QuCheck.Locate('KodeBarang', KodeBarang.Text, []) then
  raise Exception.Create('Kode barang sudah digunakan');

// For UPDATE: Check unique excluding current record
if QuCheck.Locate('KodeBarang', KodeBarang.Text, []) and
   (QuCheck.FieldByName('ID').AsInteger <> CurrentID) then
  raise Exception.Create('Kode barang sudah digunakan');
```

**Laravel**:
```php
// For INSERT
'kode_barang' => 'required|unique:dbbarang,KODEBRG'

// For UPDATE
use Illuminate\Validation\Rule;

'kode_barang' => [
    'required',
    Rule::unique('dbbarang', 'KODEBRG')->ignore($this->route('id')),
]
```

### 4.3 Required Validation

**Delphi**:
```pascal
if NamaBarang.Text = '' then
  raise Exception.Create('Nama barang harus diisi');

if (Supplier.Text = '') or (Supplier.Text = '0') then
  raise Exception.Create('Supplier harus dipilih');
```

**Laravel**:
```php
'nama_barang' => 'required|string|max:100',
'supplier' => 'required|not_in:0',
```

### 4.4 Format Validation

**Delphi**:
```pascal
if not IsValidDate(TanggalInput.Text) then
  raise Exception.Create('Format tanggal tidak valid');

if not IsValidEmail(Email.Text) then
  raise Exception.Create('Format email tidak valid');

if Length(NoHP.Text) < 10 then
  raise Exception.Create('No HP minimal 10 digit');
```

**Laravel**:
```php
'tanggal' => 'required|date_format:Y-m-d',
'email' => 'required|email:rfc,dns',
'no_hp' => 'required|regex:/^[0-9]{10,15}$/',
```

### 4.5 Lookup/Foreign Key Validation

**Delphi**:
```pascal
if not QuBarang.Locate('KODEBRG', KodeBarang.Text, []) then
  raise Exception.Create('Kode barang tidak ditemukan');

if not QuSupplier.Locate('KODESUPPLIER', KodeSupplier.Text, []) then
  raise Exception.Create('Supplier tidak ditemukan');
```

**Laravel**:
```php
'kode_barang' => 'required|exists:dbbarang,KODEBRG',
'kode_supplier' => 'required|exists:dbsupplier,KODESUPPLIER',

// With additional conditions
'kode_barang' => [
    'required',
    Rule::exists('dbbarang', 'KODEBRG')->where(function ($query) {
        $query->where('ISAKTIF', 1);
    }),
]
```

### 4.6 Conditional Validation

**Delphi**:
```pascal
if TipeBarang.Text = 'Jadi' then
  if KodeProses.Text = '' then
    raise Exception.Create('Kode proses harus diisi untuk barang jadi');

if JenisPO.Text = 'Import' then
begin
  if PIB.Text = '' then
    raise Exception.Create('No PIB harus diisi untuk PO Import');
  if NoPemasok.Text = '' then
    raise Exception.Create('No Pemasok harus diisi untuk PO Import');
end;
```

**Laravel**:
```php
'kode_proses' => 'required_if:tipe_barang,Jadi',

// Multiple conditional fields
'no_pib' => 'required_if:jenis_po,Import',
'no_pemasok' => 'required_if:jenis_po,Import',

// Conditional with multiple values
'payment_proof' => 'required_if:payment_method,Transfer,QRIS',
```

### 4.7 Enum Validation

**Delphi**:
```pascal
if not (Status.Text in ['Aktif', 'Nonaktif', 'Pending']) then
  raise Exception.Create('Status tidak valid');

if not (TipeTransaksi.Text in ['PO', 'PR', 'DO']) then
  raise Exception.Create('Tipe transaksi tidak valid');
```

**Laravel**:
```php
'status' => 'required|in:Aktif,Nonaktif,Pending',
'tipe_transaksi' => 'required|in:PO,PR,DO',
```

### 4.8 Custom Business Logic Validation

**Delphi**:
```pascal
// Stock check
if (Quantity.AsFloat > StokTersedia.AsFloat) and (TipeTransaksi.Text <> 'PO') then
  raise Exception.Create('Stok tidak mencukupi');

// Period lock check
if IsPeriodLocked(TglBukti.Date) then
  raise Exception.Create('Period sudah ditutup');

// Authorization check
if (IsOtorisasi.AsInteger = 1) and (Action = 'Edit') then
  raise Exception.Create('Data sudah diotorisasi, tidak dapat diubah');
```

**Laravel**:
```php
public function withValidator($validator)
{
    $validator->after(function ($validator) {
        // Stock check
        if ($this->quantity > $this->getAvailableStock() && $this->tipe !== 'PO') {
            $validator->errors()->add('quantity', 'Stok tidak mencukupi');
        }

        // Period lock check
        if ($this->isPeriodLocked($this->tgl_bukti)) {
            $validator->errors()->add('tgl_bukti', 'Period sudah ditutup');
        }

        // Authorization check
        $model = $this->route('model');
        if ($model && $model->IsOtorisasi1 == 1) {
            $validator->errors()->add('general', 'Data sudah diotorisasi, tidak dapat diubah');
        }
    });
}
```

### ✅ Validation Implementation Checklist

- [ ] Detected all required field validations
- [ ] Detected all unique constraints
- [ ] Detected all range checks
- [ ] Detected all format validations
- [ ] Detected all foreign key lookups
- [ ] Detected all conditional validations
- [ ] Detected all enum validations
- [ ] Detected all custom business logic
- [ ] Implemented in Request rules() method
- [ ] Implemented custom validation in withValidator()
- [ ] Added user-friendly error messages (Indonesian)
- [ ] Tested all validation scenarios
- [ ] Tested validation error display in UI

---

## Pattern 5: Authorization Workflow (OL-Based)

### 🔍 Detection in Delphi

**Primary Signature**:
```pascal
// Authorization fields in table
IsOtorisasi1, IsOtorisasi2, IsOtorisasi3, IsOtorisasi4, IsOtorisasi5: Integer;
OtoUser1, OtoUser2, OtoUser3, OtoUser4, OtoUser5: String;
TglOto1, TglOto2, TglOto3, TglOto4, TglOto5: TDateTime;

// Authorization procedure
procedure TFrmXXX.OtorisasiClick(Sender: TObject);
begin
  if IsOtorisasi1 = 0 then
  begin
    // Authorize level 1
    IsOtorisasi1 := 1;
    OtoUser1 := IDUser;
    TglOto1 := Now;
  end
  else if IsOtorisasi2 = 0 then
  begin
    // Authorize level 2
    IsOtorisasi2 := 1;
    OtoUser2 := IDUser;
    TglOto2 := Now;
  end;
  // ... more levels
end;
```

**Where to Look**:
- Authorization button click handlers
- Table field definitions (IsOtorisasi1-5)
- DBMENU table → OL field (determines max levels)
- DBFLMENU table → IsOtorisasi1-5 permissions
- Look for: `IsOtorisasi`, `OtoUser`, `TglOto`, `OL`

**Detection Checklist**:
- [ ] Found IsOtorisasi1-5 fields in table
- [ ] Found OtoUser1-5 fields
- [ ] Found TglOto1-5 fields
- [ ] Found authorization button/procedure
- [ ] Found OL configuration in DBMENU
- [ ] Found authorization permission checks
- [ ] Found cascading logic (L2 requires L1)

### 🎯 Implementation in Laravel

**Architecture**: Controller → AuthorizationService → Model (IsOtorisasi fields)

**Step 1: Check OL Configuration**
```sql
-- CRITICAL: Always check OL before implementing
SELECT L1, KODEMENU, NAMA, OL FROM DBMENU WHERE KODEMENU = 'XXXX';

-- Examples:
-- PPL: OL=2 (2 levels)
-- PO:  OL=3 (3 levels)
-- PB:  OL=2 (2 levels)
```

**Step 2: Service Layer**
```php
// app/Services/XXXService.php

/**
 * Authorize document at specific level
 * Delphi: FrmXXX.pas, OtorisasiClick
 */
public function authorize(string $noBukti, int $level): DbXXX
{
    $model = DbXXX::where('NOBUKTI', $noBukti)->firstOrFail();

    // 1. Validate can authorize
    $this->validateCanAuthorize($model, $level);

    // 2. Check user has permission for this level
    $this->checkAuthorizationPermission($level);

    // 3. Update authorization fields
    $authField = "IsOtorisasi{$level}";
    $userField = "OtoUser{$level}";
    $dateField = "TglOto{$level}";

    $model->update([
        $authField => 1,
        $userField => auth()->user()->IDUser,
        $dateField => now(),
    ]);

    // 4. Log activity
    Log::info("XXX authorized L{$level}", [
        'nobukti' => $noBukti,
        'level' => $level,
        'user' => auth()->user()->IDUser,
    ]);

    return $model->fresh();
}

/**
 * Cancel authorization at specific level
 * Delphi: FrmXXX.pas, BatalOtorisasiClick
 */
public function cancelAuthorization(string $noBukti, int $level): DbXXX
{
    $model = DbXXX::where('NOBUKTI', $noBukti)->firstOrFail();

    // 1. Validate can cancel
    $this->validateCanCancelAuth($model, $level);

    // 2. Clear authorization fields for this level AND higher levels (cascade)
    for ($i = $level; $i <= 5; $i++) {
        $authField = "IsOtorisasi{$i}";
        $userField = "OtoUser{$i}";
        $dateField = "TglOto{$i}";

        $model->update([
            $authField => 0,
            $userField => null,
            $dateField => null,
        ]);
    }

    // 3. Log activity
    Log::info("XXX authorization cancelled L{$level}", [
        'nobukti' => $noBukti,
        'level' => $level,
        'user' => auth()->user()->IDUser,
    ]);

    return $model->fresh();
}

protected function validateCanAuthorize(DbXXX $model, int $level): void
{
    // Cannot authorize if cancelled
    if ($model->IsBatal == 1) {
        throw new \Exception('Dokumen sudah dibatalkan');
    }

    // Must authorize in order (L1 before L2)
    if ($level > 1) {
        $prevLevel = $level - 1;
        $prevAuthField = "IsOtorisasi{$prevLevel}";

        if ($model->$prevAuthField != 1) {
            throw new \Exception("Harus otorisasi level {$prevLevel} terlebih dahulu");
        }
    }

    // Check not already authorized
    $authField = "IsOtorisasi{$level}";
    if ($model->$authField == 1) {
        throw new \Exception("Level {$level} sudah diotorisasi");
    }
}
```

**Step 3: Controller**
```php
// app/Http/Controllers/XXXController.php

/**
 * Authorize document
 * Delphi: BtnOtorisasiClick
 */
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
            ->with('error', 'Gagal otorisasi: ' . $e->getMessage());
    }
}

/**
 * Cancel authorization
 * Delphi: BtnBatalOtorisasiClick
 */
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
            ->with('error', 'Gagal membatalkan otorisasi: ' . $e->getMessage());
    }
}
```

**Step 4: View - Dynamic Authorization Columns**
```blade
{{-- resources/views/xxx/index.blade.php --}}

{{-- Get max visible level from OL configuration --}}
@php
    $maxVisibleLevel = 2; // From DBMENU.OL
@endphp

<table class="table">
    <thead>
        <tr>
            <th>No Bukti</th>
            <th>Tanggal</th>

            {{-- Dynamic authorization columns based on OL --}}
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

                {{-- Show authorization status for each level --}}
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
                            <small>{{ $item->$dateField ? $item->$dateField->format('d-m-Y H:i') : '' }}</small>

                            {{-- Cancel button if not cancelled --}}
                            @if(!$item->IsBatal)
                                <button class="btn btn-xs btn-outline-warning"
                                        onclick="cancelAuth('{{ $item->NOBUKTI }}', {{ $level }})">
                                    ✕ Batalkan
                                </button>
                            @endif
                        @else
                            {{-- Show authorize button if user has permission for this level --}}
                            @if(canAuthorizeLevel($level) && !$item->IsBatal)
                                <button class="btn btn-xs btn-primary"
                                        onclick="authorizeDoc('{{ $item->NOBUKTI }}', {{ $level }})">
                                    ✓ L{{ $level }}
                                </button>
                            @else
                                <span class="text-muted">-</span>
                            @endif
                        @endif
                    </td>
                @endfor

                <td>
                    {{-- Action buttons --}}
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
        })
        .then(response => response.json())
        .then(data => {
            location.reload();
        });
    }
}

function cancelAuth(nobukti, level) {
    if (confirm(`Batalkan otorisasi level ${level}? Ini akan membatalkan level ${level} dan level diatasnya.`)) {
        fetch(`/xxx/${nobukti}/cancel-authorization`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': '{{ csrf_token() }}'
            },
            body: JSON.stringify({ level: level })
        })
        .then(response => response.json())
        .then(data => {
            location.reload();
        });
    }
}
</script>
```

### ✅ Implementation Checklist

- [ ] Checked DBMENU.OL to determine max levels
- [ ] Verified DBFLMENU has IsOtorisasi1-N permissions
- [ ] Created authorize() service method
- [ ] Created cancelAuthorization() service method
- [ ] Implemented cascading logic (L1→L2→L3)
- [ ] Implemented cancel cascade (L2 cancel → clear L2,L3,L4,L5)
- [ ] Added authorize/cancel routes
- [ ] Created controller methods
- [ ] Implemented dynamic view columns based on OL
- [ ] Added permission checks per level
- [ ] Tested authorization workflow L1→L2→...→LN
- [ ] Tested cancel authorization cascade
- [ ] Tested cannot edit/delete authorized documents

### 📊 Real Example: PPL Module (OL=2)

**DBMENU**:
```sql
L1='02', KODEMENU='02002', NAMA='Permintaan Pembelian', OL='2'
```

**Service**: `app/Services/PPLService.php`
```php
// Only handles L1 and L2 (OL=2)
public function authorize(string $noBukti, int $level): DbPPL
{
    // Validates level is 1 or 2
    if ($level > 2) {
        throw new \Exception('PPL hanya memiliki 2 level otorisasi');
    }

    // ... rest of authorization logic
}
```

**View**: Dynamic columns show only L1 and L2

**Coverage**: ✅ 100% (2-level authorization implemented correctly)

---

## Pattern 6: Audit Logging

### 🔍 Detection in Delphi

**Primary Signature**:
```pascal
// After successful INSERT
LoggingData(IDUser, 'I', 'ModuleName', NoBukti.Text, 'Description');

// After successful UPDATE
LoggingData(IDUser, 'U', 'ModuleName', NoBukti.Text, 'Description');

// After successful DELETE
LoggingData(IDUser, 'D', 'ModuleName', NoBukti.Text, 'Description');

// Custom logging
LoggingData(IDUser, 'O', 'ModuleName', NoBukti.Text, 'Otorisasi Level 1');
```

**Where to Look**:
- After ExecProc calls
- Inside try/except blocks
- After successful operations
- Look for: `LoggingData`, `WriteLog`, `AuditTrail`

**Detection Checklist**:
- [ ] Found LoggingData calls after INSERT
- [ ] Found LoggingData calls after UPDATE
- [ ] Found LoggingData calls after DELETE
- [ ] Found LoggingData calls for authorization
- [ ] Found all parameters: user, mode, module, docno, description

### 🎯 Implementation in Laravel

**Step 1: Use Laravel Log Facade**
```php
// app/Services/XXXService.php

use Illuminate\Support\Facades\Log;

protected function logActivity(string $mode, string $noBukti, array $data, string $description = ''): void
{
    Log::channel('activity')->info("XXX {$mode}", [
        'user_id' => auth()->user()->IDUser ?? 'SYSTEM',
        'mode' => $mode,  // I/U/D/O
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

    $this->logActivity('I', $noBukti, $data, 'Created new XXX document');

    return $result;
}

public function update(string $noBukti, array $data): DbXXX
{
    // ... update logic

    $this->logActivity('U', $noBukti, $data, 'Updated XXX document');

    return $result;
}

public function delete(string $noBukti): bool
{
    // ... delete logic

    $this->logActivity('D', $noBukti, [], 'Deleted XXX document');

    return true;
}

public function authorize(string $noBukti, int $level): DbXXX
{
    // ... authorize logic

    $this->logActivity('O', $noBukti, ['level' => $level], "Authorized level {$level}");

    return $result;
}
```

**Step 2: Configure Log Channel** (Optional)
```php
// config/logging.php

'channels' => [
    // ... other channels

    'activity' => [
        'driver' => 'daily',
        'path' => storage_path('logs/activity.log'),
        'level' => 'info',
        'days' => 90,  // Keep 90 days
    ],
],
```

**Step 3: Database Logging** (Alternative)
```php
// If you want to use dbLogFile table like Delphi

use Illuminate\Support\Facades\DB;

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

### ✅ Implementation Checklist

- [ ] Identified all LoggingData calls in Delphi
- [ ] Created logActivity() method in service
- [ ] Added logging after create() operation
- [ ] Added logging after update() operation
- [ ] Added logging after delete() operation
- [ ] Added logging after authorize() operation
- [ ] Included all parameters (user, mode, module, docno)
- [ ] Configured log channel (if using file)
- [ ] Tested log entries created correctly
- [ ] Verified log contains enough detail for audit

### 📊 Real Example: PPL Module

**Delphi**: `FrmPPL.pas`
```pascal
LoggingData(IDUser, Choice, 'PPL', NoBukti.Text,
  'Supplier: ' + KodeSupplier.Text + ', Total: ' + FormatFloat('#,##0', Total));
```

**Laravel**: `app/Services/PPLService.php`
```php
$this->logActivity('I', $noBukti, $data,
  sprintf('Supplier: %s, Total: %s',
    $data['kode_supplier'],
    number_format($data['total'], 0, ',', '.')
  )
);
```

**Coverage**: ✅ 100% (all operations logged)

---

## Pattern 7: Master-Detail Forms

### 🔍 Detection in Delphi

**Primary Signature**:
```pascal
// Two related tables
QuMaster: TADOQuery;  // Main document
QuDetail: TADOQuery;  // Detail lines

// Saving detail lines
for i := 0 to StringGrid.RowCount - 1 do
begin
  QuDetail.Append;
  QuDetail.FieldByName('NoBukti').AsString := NoBukti.Text;
  QuDetail.FieldByName('NoUrut').AsInteger := i + 1;
  QuDetail.FieldByName('KodeBarang').AsString := StringGrid.Cells[0, i];
  QuDetail.FieldByName('Quantity').AsFloat := StrToFloat(StringGrid.Cells[1, i]);
  QuDetail.Post;
end;
```

**Where to Look**:
- Two related tables (master + detail)
- StringGrid/DBGrid for detail lines
- Loop through grid rows for saving
- Look for: `for i := 0 to`, `NoUrut`, `NOBUKTI` foreign key

**Special Cases**:
- **Single-item constraint**: Some forms allow only 1 detail (e.g., PB module)
- **Multiple details**: Most forms allow N details (e.g., PPL, PO)

**Detection Checklist**:
- [ ] Found master table
- [ ] Found detail table with NOBUKTI foreign key
- [ ] Found NoUrut sequence field
- [ ] Found detail line saving loop
- [ ] Determined if single or multiple details allowed
- [ ] Found detail validation rules
- [ ] Found detail deletion logic

### 🎯 Implementation in Laravel

**Single-Item Detail** (PB Pattern):
```php
// app/Services/PenyerahanBhnService.php

/**
 * Create PB with single detail line
 * Delphi: FrmPB.pas, PB can only have 1 detail line
 */
public function create(array $headerData, array $detailData): DbPenyerahanBhn
{
    return DB::transaction(function () use ($headerData, $detailData) {
        // 1. Validate single-item constraint
        if (count($detailData) > 1) {
            throw new \Exception('PB hanya boleh memiliki 1 baris detail');
        }

        // 2. Create header
        $header = DbPenyerahanBhn::create([
            'NOBUKTI' => $this->generateNumber($headerData),
            'TglBukti' => $headerData['tgl_bukti'],
            'KodeGdg' => $headerData['kode_gdg'],
            // ... other fields
        ]);

        // 3. Create single detail
        DbPenyerahanBhnDET::create([
            'NOBUKTI' => $header->NOBUKTI,
            'NoUrut' => 1,  // Always 1 for single-item
            'KODEBRG' => $detailData[0]['kode_brg'],
            'Qnt' => $detailData[0]['quantity'],
            // ... other fields
        ]);

        return $header->fresh();
    });
}

/**
 * Cannot add second detail line
 */
public function addDetailLine(string $noBukti, array $detailData): void
{
    $existingCount = DbPenyerahanBhnDET::where('NOBUKTI', $noBukti)->count();

    if ($existingCount >= 1) {
        throw new \Exception('PB sudah memiliki detail, tidak dapat menambah lagi');
    }

    // Create detail...
}
```

**Multiple-Item Detail** (PPL/PO Pattern):
```php
// app/Services/PPLService.php

/**
 * Create PPL with multiple detail lines
 * Delphi: FrmPPL.pas, PPL can have multiple details
 */
public function create(array $headerData, array $detailData): DbPPL
{
    return DB::transaction(function () use ($headerData, $detailData) {
        // 1. Validate minimum detail
        if (count($detailData) < 1) {
            throw new \Exception('PPL harus memiliki minimal 1 baris detail');
        }

        // 2. Create header
        $header = DbPPL::create([
            'NOBUKTI' => $this->generateNumber($headerData),
            'TglBukti' => $headerData['tgl_bukti'],
            'KodeSupplier' => $headerData['kode_supplier'],
            // ... other fields
        ]);

        // 3. Create multiple details
        foreach ($detailData as $index => $detail) {
            DbPPLDET::create([
                'NOBUKTI' => $header->NOBUKTI,
                'NoUrut' => $index + 1,
                'KODEBRG' => $detail['kode_brg'],
                'Qnt' => $detail['quantity'],
                'Satuan' => $detail['satuan'],
                // ... other fields
            ]);
        }

        return $header->fresh();
    });
}

/**
 * Update details (delete all, insert new pattern)
 */
public function updateDetails(string $noBukti, array $detailData): void
{
    DB::transaction(function () use ($noBukti, $detailData) {
        // 1. Delete existing details
        DbPPLDET::where('NOBUKTI', $noBukti)->delete();

        // 2. Insert new details
        foreach ($detailData as $index => $detail) {
            DbPPLDET::create([
                'NOBUKTI' => $noBukti,
                'NoUrut' => $index + 1,
                // ... fields
            ]);
        }
    });
}

/**
 * Delete single detail line
 */
public function deleteDetailLine(string $noBukti, int $noUrut): void
{
    // 1. Check minimum detail constraint
    $detailCount = DbPPLDET::where('NOBUKTI', $noBukti)->count();

    if ($detailCount <= 1) {
        throw new \Exception('PPL harus memiliki minimal 1 baris detail. Tidak dapat menghapus item terakhir.');
    }

    // 2. Delete detail
    DbPPLDET::where('NOBUKTI', $noBukti)
        ->where('NoUrut', $noUrut)
        ->delete();

    // 3. Resequence NoUrut (optional, depends on requirement)
    $this->resequenceDetails($noBukti);
}
```

**Request Validation**:
```php
// For single-item detail
public function rules(): array
{
    return [
        'details' => 'required|array|size:1',  // Exactly 1
        'details.0.kode_brg' => 'required|exists:dbbarang,KODEBRG',
        'details.0.quantity' => 'required|numeric|min:0.01',
    ];
}

// For multiple-item detail
public function rules(): array
{
    return [
        'details' => 'required|array|min:1',  // At least 1
        'details.*.kode_brg' => 'required|exists:dbbarang,KODEBRG',
        'details.*.quantity' => 'required|numeric|min:0.01',
    ];
}
```

**View - Detail Table**:
```blade
{{-- Edit form with detail table --}}
<table class="table" id="detail-table">
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
    <tbody>
        @forelse($model->details as $index => $detail)
            <tr>
                <td>{{ $index + 1 }}</td>
                <td>{{ $detail->KODEBRG }}</td>
                <td>{{ $detail->NAMABRG }}</td>
                <td>
                    <input type="number" class="form-control detail-qnt"
                           value="{{ $detail->Qnt }}" step="0.01" min="0.01">
                </td>
                <td>
                    <input type="text" class="form-control detail-sat"
                           value="{{ $detail->Sat }}" maxlength="5">
                </td>
                <td>
                    <button class="btn btn-sm btn-primary"
                            onclick="updateDetail({{ $index }})">
                        Simpan
                    </button>
                    <button class="btn btn-sm btn-danger"
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

{{-- Add detail form (if multiple allowed) --}}
@if(count($model->details) == 0 || !$singleItemConstraint)
    <div class="card mt-3">
        <div class="card-header">Tambah Detail Baru</div>
        <div class="card-body">
            {{-- Form fields for adding detail --}}
        </div>
    </div>
@endif
```

### ✅ Implementation Checklist

- [ ] Identified master table
- [ ] Identified detail table
- [ ] Determined single vs multiple detail constraint
- [ ] Created service methods for create with details
- [ ] Created service methods for update details
- [ ] Created service methods for delete detail
- [ ] Implemented NoUrut sequencing
- [ ] Added minimum detail validation
- [ ] Added maximum detail validation (if single-item)
- [ ] Created view with detail table
- [ ] Added JavaScript for inline editing
- [ ] Tested create with details
- [ ] Tested update details
- [ ] Tested delete detail
- [ ] Tested cannot delete last detail (if minimum=1)

### 📊 Real Examples

**Single-Item**: Penyerahan Bahan (PB)
- Constraint: Exactly 1 detail per document
- Validation: `'details' => 'required|array|size:1'`
- Cannot add 2nd detail
- Cannot delete last detail (always have 1)

**Multiple-Item**: PPL, PO
- Constraint: Minimum 1 detail, no maximum
- Validation: `'details' => 'required|array|min:1'`
- Can add unlimited details
- Cannot delete last detail (minimum 1)

---

## Pattern 8: Lookup & Search

### 🔍 Detection in Delphi

**Primary Signature**:
```pascal
// Lookup form call
if BtnLookup.Click then
begin
  with TFrmLookupBarang.Create(Self) do
  try
    ShowModal;
    if ModalResult = mrOK then
    begin
      KodeBarang.Text := SelectedKode;
      NamaBarang.Text := SelectedNama;
    end;
  finally
    Free;
  end;
end;

// Or inline lookup with QuCheck
QuCheck.Close;
QuCheck.SQL.Clear;
QuCheck.SQL.Add('SELECT * FROM DBBARANG WHERE KODEBRG = :Kode');
QuCheck.Parameters.ParamByName('Kode').Value := KodeBarang.Text;
QuCheck.Open;
if not QuCheck.IsEmpty then
begin
  NamaBarang.Text := QuCheck.FieldByName('NAMABRG').AsString;
end;
```

**Where to Look**:
- Browse form references (`KodeBrows` parameter)
- Lookup button click handlers
- OnExit field validation with Locate
- QuCheck queries
- Look for: `TFrmLookup`, `KodeBrows`, `SelectedValue`, `Locate`

**Detection Checklist**:
- [ ] Found lookup button/field
- [ ] Found browse form reference (KodeBrows)
- [ ] Found selected value assignment
- [ ] Found dependent field population (name, description)
- [ ] Found search/filter in lookup
- [ ] Found validation on exit

### 🎯 Implementation in Laravel

**Step 1: API Endpoint**
```php
// app/Http/Controllers/Api/LookupController.php

/**
 * Barang lookup
 * Delphi: FrmLookupBarang, KodeBrows=1014001
 */
public function barangLookup(Request $request)
{
    $search = $request->get('search', '');
    $filter = $request->get('filter', []);

    $query = DB::table('DBBARANG as BAR')
        ->where('BAR.ISAKTIF', 1);

    // Search filter
    if ($search) {
        $query->where(function ($q) use ($search) {
            $q->where('BAR.KODEBRG', 'like', "%{$search}%")
              ->orWhere('BAR.NAMABRG', 'like', "%{$search}%");
        });
    }

    // Additional filters
    if (isset($filter['tipe'])) {
        $query->where('BAR.TIPEBARANG', $filter['tipe']);
    }

    $results = $query
        ->select([
            'BAR.KODEBRG',
            'BAR.NAMABRG',
            'BAR.Sat1',
            'BAR.Sat2',
            'BAR.Isi2',
            // ... other fields
        ])
        ->orderBy('BAR.KODEBRG')
        ->limit(100)
        ->get();

    return response()->json($results);
}
```

**Step 2: Modal View**
```blade
{{-- resources/views/xxx/create.blade.php --}}

{{-- Lookup modal --}}
<div class="modal fade" id="barangModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Pilih Barang</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                {{-- Search input --}}
                <div class="mb-3">
                    <input type="text" id="barang-search" class="form-control"
                           placeholder="Cari kode atau nama barang...">
                </div>

                {{-- Results table --}}
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>Kode</th>
                            <th>Nama Barang</th>
                            <th>Satuan</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="barang-table-body">
                        <tr>
                            <td colspan="4" class="text-center">
                                <span class="spinner-border spinner-border-sm"></span>
                                Loading...
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

{{-- Barang field with lookup button --}}
<div class="row mb-3">
    <label class="col-sm-3 col-form-label">Kode Barang</label>
    <div class="col-sm-9">
        <div class="input-group">
            <input type="text" name="kode_brg" id="kode_brg" class="form-control" readonly>
            <button type="button" class="btn btn-primary" id="btn-lookup-barang">
                <i class="fas fa-search"></i> Cari
            </button>
        </div>
    </div>
</div>

<div class="row mb-3">
    <label class="col-sm-3 col-form-label">Nama Barang</label>
    <div class="col-sm-9">
        <input type="text" name="nama_brg" id="nama_brg" class="form-control" readonly>
    </div>
</div>
```

**Step 3: JavaScript**
```javascript
// Lookup functionality
document.addEventListener('DOMContentLoaded', function() {
    const barangModal = new bootstrap.Modal(document.getElementById('barangModal'));
    const btnLookup = document.getElementById('btn-lookup-barang');
    const searchInput = document.getElementById('barang-search');
    const tableBody = document.getElementById('barang-table-body');

    let searchTimeout;

    // Open modal
    btnLookup.addEventListener('click', function() {
        barangModal.show();
        loadBarangList();
    });

    // Search with debounce
    searchInput.addEventListener('input', function() {
        clearTimeout(searchTimeout);
        searchTimeout = setTimeout(() => {
            loadBarangList(this.value);
        }, 300);
    });

    // Load barang list
    function loadBarangList(search = '') {
        tableBody.innerHTML = '<tr><td colspan="4" class="text-center">Loading...</td></tr>';

        fetch(`/api/lookup/barang?search=${encodeURIComponent(search)}`)
            .then(response => response.json())
            .then(items => {
                if (items.length === 0) {
                    tableBody.innerHTML = '<tr><td colspan="4" class="text-center">Tidak ada data</td></tr>';
                    return;
                }

                tableBody.innerHTML = items.map(item => `
                    <tr>
                        <td>${item.KODEBRG}</td>
                        <td>${item.NAMABRG}</td>
                        <td>${item.Sat1}</td>
                        <td>
                            <button type="button" class="btn btn-sm btn-primary btn-select-barang"
                                    data-kodebrg="${item.KODEBRG}"
                                    data-namabrg="${item.NAMABRG}"
                                    data-satuan="${item.Sat1}"
                                    data-isi="${item.Isi2}">
                                Pilih
                            </button>
                        </td>
                    </tr>
                `).join('');

                // Add click handlers
                document.querySelectorAll('.btn-select-barang').forEach(btn => {
                    btn.addEventListener('click', function() {
                        selectBarang(
                            this.dataset.kodebrg,
                            this.dataset.namabrg,
                            this.dataset.satuan,
                            this.dataset.isi
                        );
                    });
                });
            })
            .catch(error => {
                console.error('Error loading barang:', error);
                tableBody.innerHTML = '<tr><td colspan="4" class="text-center text-danger">Error loading data</td></tr>';
            });
    }

    // Select barang
    function selectBarang(kode, nama, satuan, isi) {
        document.getElementById('kode_brg').value = kode;
        document.getElementById('nama_brg').value = nama;
        document.getElementById('satuan').value = satuan;
        document.getElementById('isi').value = isi;

        barangModal.hide();
    }
});
```

### ✅ Implementation Checklist

- [ ] Identified all lookup forms in Delphi
- [ ] Created API endpoint for each lookup
- [ ] Added search/filter logic
- [ ] Created modal view for lookup
- [ ] Implemented JavaScript handlers
- [ ] Added debounce to search
- [ ] Implemented result selection
- [ ] Populated dependent fields
- [ ] Added loading states
- [ ] Added error handling
- [ ] Tested search functionality
- [ ] Tested selection functionality

### 📊 Real Example: PB - SPK Lookup

**Delphi**: `FrmPB.pas`, KodeBrows=1014121
```pascal
// Lookup SPK items for selected warehouse
if BtnLookupSPK.Click then
  CallBrowseForm(1014121, 'SPK', KodeGdg.Text);
```

**Laravel**:
- Endpoint: `GET /api/lookup/pb-barang?kodegdg=XXX`
- Modal: Bootstrap modal with search + table
- Selection: Populates kode_brg, nama_brg, nospk, urutspk

**Coverage**: ✅ 100% (lookup implemented with search)

---

## Pattern Detection Checklist

Use this when analyzing Delphi source files:

### Phase 1: Initial Scan
- [ ] Read .pas file completely (note line count)
- [ ] Read .dfm file for UI components
- [ ] Identify complexity (SIMPLE/MEDIUM/COMPLEX)
- [ ] List all table names referenced

### Phase 2: Pattern 1 - Mode Operations
- [ ] Search for `Choice:Char` parameter
- [ ] Search for `if Choice='I'`
- [ ] Search for `if Choice='U'`
- [ ] Search for `if Choice='D'`
- [ ] Note line numbers for each mode

### Phase 3: Pattern 2 - Permissions
- [ ] Search for `IsTambah`
- [ ] Search for `IsKoreksi`
- [ ] Search for `IsHapus`
- [ ] Search for `IsCetak`
- [ ] Search for `IsExcel`

### Phase 4: Pattern 3 - Field Dependencies
- [ ] List all `OnChange` event handlers
- [ ] List all query reopens triggered by field changes
- [ ] List all conditional panel visibility

### Phase 5: Pattern 4 - Validation
- [ ] Search for `if Field = ''` (required)
- [ ] Search for `QuCheck.Locate` (unique)
- [ ] Search for `if Value <` (range)
- [ ] Search for `IsValidDate` (format)
- [ ] Search for `if not QuTable.Locate` (lookup)
- [ ] Search for custom `raise Exception`

### Phase 6: Pattern 5 - Authorization
- [ ] Query DBMENU for OL value
- [ ] Search for `IsOtorisasi1`
- [ ] Count authorization levels (1-5)
- [ ] Note cascading logic

### Phase 7: Pattern 6 - Audit Logging
- [ ] Search for `LoggingData`
- [ ] Note parameters passed
- [ ] Count total LoggingData calls

### Phase 8: Pattern 7 - Master-Detail
- [ ] Identify master table
- [ ] Identify detail table
- [ ] Check for single vs multiple details
- [ ] Note NoUrut usage

### Phase 9: Pattern 8 - Lookup
- [ ] List all `KodeBrows` values
- [ ] List all lookup form calls
- [ ] Note dependent field populations

---

## Implementation Checklist

Use this when implementing Laravel code:

### Phase 1: Setup
- [ ] Created service class
- [ ] Created controller class
- [ ] Created policy class
- [ ] Created request classes (Store/Update)
- [ ] Verified models exist

### Phase 2: Pattern 1 Implementation
- [ ] Service: create() method
- [ ] Service: update() method
- [ ] Service: delete() method
- [ ] Controller: store() method
- [ ] Controller: update() method
- [ ] Controller: destroy() method
- [ ] Request: StoreRequest with validation
- [ ] Request: UpdateRequest with validation

### Phase 3: Pattern 2 Implementation
- [ ] Policy: create() method
- [ ] Policy: update() method
- [ ] Policy: delete() method
- [ ] Policy: print() method (if applicable)
- [ ] Policy: export() method (if applicable)
- [ ] View: @can directives

### Phase 4: Pattern 3 Implementation
- [ ] Controller: AJAX endpoints
- [ ] Routes: API routes
- [ ] View: JavaScript handlers
- [ ] View: Conditional visibility

### Phase 5: Pattern 4 Implementation
- [ ] Request: All validation rules
- [ ] Request: Custom validation (withValidator)
- [ ] Request: Error messages in Indonesian

### Phase 6: Pattern 5 Implementation
- [ ] Service: authorize() method
- [ ] Service: cancelAuthorization() method
- [ ] Controller: authorize endpoint
- [ ] Controller: cancel endpoint
- [ ] View: Authorization columns (dynamic)
- [ ] View: Authorization buttons

### Phase 7: Pattern 6 Implementation
- [ ] Service: logActivity() method
- [ ] Service: Logging in create()
- [ ] Service: Logging in update()
- [ ] Service: Logging in delete()
- [ ] Service: Logging in authorize()

### Phase 8: Pattern 7 Implementation
- [ ] Service: Detail creation logic
- [ ] Service: Detail update logic
- [ ] Service: Detail delete logic
- [ ] Service: NoUrut sequencing
- [ ] View: Detail table
- [ ] View: Add detail form (if applicable)

### Phase 9: Pattern 8 Implementation
- [ ] Controller: Lookup endpoints
- [ ] Routes: Lookup routes
- [ ] View: Lookup modals
- [ ] View: JavaScript for lookup

### Phase 10: Testing
- [ ] Manual test: Create
- [ ] Manual test: Read
- [ ] Manual test: Update
- [ ] Manual test: Delete
- [ ] Manual test: Authorization (if applicable)
- [ ] Manual test: Permissions
- [ ] Manual test: Validation
- [ ] Manual test: Lookup

### Phase 11: Documentation
- [ ] Migration summary created
- [ ] Retrospective completed
- [ ] Lessons learned documented

---

## Pattern 9: Composite Primary Keys

### 🔍 Problem in Delphi

```pascal
// Table: DBArusKasDet has composite primary key
// Primary Key: KodeAK + KodeSubAK (2 columns)

procedure TFrmSubArusKas.LoadData;
begin
  // Locate by composite key
  QuArusKasDet.Locate(
    ['KodeAK', 'KodeSubAK'],
    [FKodeAK, FKodeSubAK]
  );
end;
```

### 🔴 Laravel Challenge

**Eloquent `find()` only accepts single key**:
```php
// ❌ Won't work:
$detail = DbArusKasDet::find(['03010', '001']);  // Error!

// ❌ Laravel route model binding breaks:
Route::put('/details/{detail}', ...);  // Can't use composite key

// ❌ JSON serialization needs special handling
```

### ✅ Solution 1: Route Parameter + Manual Query (RECOMMENDED)

**Simplest, works with any form of composite key**

```php
// Route definition
Route::put('/arus-kas/{arusKa}/details/{detailId}', [
    ArusKasDetController::class, 'update'
]);

// Controller
class ArusKasDetController extends Controller
{
    public function update(DbArusKas $arusKa, string $detailId, UpdateRequest $request)
    {
        // Manually query by both keys
        $detail = DbArusKasDet::where('KodeAK', $arusKa->KodeAK)
            ->where('KodeSubAK', $detailId)
            ->firstOrFail();

        $detail->update($request->validated());

        return response()->json($detail);
    }

    public function destroy(DbArusKas $arusKa, string $detailId)
    {
        $detail = DbArusKasDet::where('KodeAK', $arusKa->KodeAK)
            ->where('KodeSubAK', $detailId)
            ->firstOrFail();

        $detail->delete();

        return response()->json(['success' => true]);
    }
}
```

**Pros**:
- ✅ Simple and straightforward
- ✅ Works with any composite key
- ✅ Easy to understand
- ✅ No complex model configuration

**Cons**:
- ⚠️ Slightly more code per method
- ⚠️ Manual model resolution

---

### ✅ Solution 2: Set Composite Key in Model (ADVANCED)

**Configure model to handle composite keys**

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DbArusKasDet extends Model
{
    // Explicitly define composite primary key
    protected $primaryKey = ['KodeAK', 'KodeSubAK'];
    public $incrementing = false;
    public $keyType = 'string';

    // Don't use timestamps if not needed
    public $timestamps = false;

    protected $fillable = [
        'KodeAK',
        'KodeSubAK',
        'Qty',
        'Harga',
        'Total',
    ];

    // Override save query to handle composite key
    protected function setKeysForSaveQuery($query)
    {
        $keys = $this->getKeyName();

        if (!is_array($keys)) {
            return parent::setKeysForSaveQuery($query);
        }

        foreach ($keys as $keyName) {
            $query->where($keyName, '=', $this->getAttribute($keyName));
        }

        return $query;
    }

    // Override method to handle composite key retrieval
    public function getKey()
    {
        if (!is_array($this->primaryKey)) {
            return $this->getAttribute($this->primaryKey);
        }

        $key = [];
        foreach ($this->primaryKey as $keyName) {
            $key[$keyName] = $this->getAttribute($keyName);
        }

        return $key;
    }

    // Define relationships
    public function arusKas()
    {
        return $this->belongsTo(DbArusKas::class, 'KodeAK', 'KodeAK');
    }
}
```

**Pros**:
- ✅ More "ORM-ish"
- ✅ Works with some Laravel features
- ✅ Cleaner relationship definitions

**Cons**:
- ⚠️ Complex model code
- ⚠️ May break with Laravel updates
- ⚠️ Harder to debug
- ⚠️ Route model binding still doesn't work well

---

### 🔍 Detection Checklist

```bash
# Find composite keys in your database:
SELECT TABLE_NAME, COLUMN_NAME, ORDINAL_POSITION
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME LIKE 'Db%'
AND CONSTRAINT_NAME LIKE 'PK%'
GROUP BY TABLE_NAME
HAVING COUNT(*) > 1
ORDER BY TABLE_NAME;
```

**Common composite key tables**:
| Table | Keys | Example |
|-------|------|---------|
| DBArusKasDet | KodeAK + KodeSubAK | (03010, 001) |
| DbPPLDet | KodePPL + NoItem | (PPL-001, 1) |
| DbPODet | KodePO + NoItem | (PO-0001, 1) |
| DbBranChain | KodeBrg + KodeGdg | (BR001, GD001) |

---

### ⚠️ Common Mistakes

```php
// ❌ WRONG: Using single key
$detail = DbArusKasDet::find($detailId);

// ✅ CORRECT: Query both keys
$detail = DbArusKasDet::where('KodeAK', $arusKa->KodeAK)
    ->where('KodeSubAK', $detailId)
    ->first();

// ❌ WRONG: Route model binding
Route::get('/details/{detail}', ...);  // Won't work!

// ✅ CORRECT: Manual resolution
Route::get('/details/{detailId}', [DetailController::class, 'show']);
public function show(string $detailId) {
    $detail = DbArusKasDet::where('KodeAK', auth()->user()->kode_ak)
        ->where('KodeSubAK', $detailId)
        ->firstOrFail();
}
```

---

### 📝 Implementation Recommendation

**Use Solution 1** (Manual Query) unless you have specific reason for Solution 2:

```php
// RECOMMENDED - Clean, simple, maintainable
class ArusKasDetController extends Controller
{
    public function index(DbArusKas $arusKa)
    {
        $details = DbArusKasDet::where('KodeAK', $arusKa->KodeAK)
            ->paginate();

        return view('details.index', compact('details'));
    }

    public function show(DbArusKas $arusKa, string $detailId)
    {
        $detail = DbArusKasDet::where('KodeAK', $arusKa->KodeAK)
            ->where('KodeSubAK', $detailId)
            ->firstOrFail();

        return view('details.show', compact('detail'));
    }

    public function update(DbArusKas $arusKa, string $detailId, UpdateRequest $request)
    {
        $detail = DbArusKasDet::where('KodeAK', $arusKa->KodeAK)
            ->where('KodeSubAK', $detailId)
            ->firstOrFail();

        $detail->update($request->validated());
        return response()->json($detail);
    }
}
```

---

## Test Data Best Practices

### Auto-Generating Test Data

**Problem**: Simple test IDs (AK01, PB01) conflict with production data, causing 7/8 tests to fail.

**Solution**: Use `TEST{MODULE}NN` format with auto-generation.

### Naming Convention

```
Format: TEST{MODULE}{NN}

Examples:
  TEST + AK + 01 = TESTAK01
  TEST + PJ + 01 = TESTPJ01
  TEST + PB + 01 = TESTPB01
```

### Why This Matters

| Issue | Impact | Solution |
|-------|--------|----------|
| Simple IDs conflict with production | 7/8 tests fail | Use TEST prefix |
| Duplicate key errors on first run | 15-30 min debugging | Unique codes per test |
| Hard to identify test data | Cleanup difficult | TEST prefix = easy LIKE query |
| Manual code generation | Error-prone | Auto-increment sequence |

### Implementation in Tests

```php
<?php

namespace Tests\Feature;

use Database\Factories\TestDataFactory;
use Illuminate\Foundation\Testing\DatabaseTransactions;
use Tests\TestCase;

class ArusKasTest extends TestCase
{
    use DatabaseTransactions;

    protected function setUp(): void
    {
        parent::setUp();
        // Reset sequence for each test class
        TestDataFactory::resetSequence();
    }

    public function test_can_create_arus_kas()
    {
        // Generate unique test code
        $code = TestDataFactory::generateCode('AK', 2);  // TESTAK01

        $data = TestDataFactory::forModule('ArusKas', [
            'KodeAK' => $code,
            'NamaAK' => 'Test Arus Kas',
            'Keterangan' => 'Test data for migration',
        ]);

        $response = $this->post(route('arus-kas.store'), $data);

        $response->assertStatus(201);
        $this->assertDatabaseHas('DBArusKas', [
            'KodeAK' => $code,
        ]);
    }

    public function test_can_update_arus_kas()
    {
        $code = TestDataFactory::generateCode('AK', 2);  // TESTAK02

        $data = TestDataFactory::forModule('ArusKas', [
            'KodeAK' => $code,
            'NamaAK' => 'Original Name',
        ]);

        // Create initial record
        $arus_kas = DbArusKas::create($data);

        // Update it
        $updated = TestDataFactory::forModule('ArusKas', [
            'NamaAK' => 'Updated Name',
        ]);

        $response = $this->put(route('arus-kas.update', $arus_kas->KodeAK), $updated);

        $response->assertStatus(200);
        $this->assertDatabaseHas('DBArusKas', [
            'KodeAK' => $code,
            'NamaAK' => 'Updated Name',
        ]);
    }
}
```

### Auto-Reset Between Tests

```php
// Option 1: Reset in setUp() (recommended)
protected function setUp(): void
{
    parent::setUp();
    TestDataFactory::resetSequence();  // TESTAK01, TESTAK02, ...
}

// Option 2: Reset in individual test
public function test_with_fresh_sequence()
{
    TestDataFactory::resetSequence();
    $code1 = TestDataFactory::generateCode('AK', 2);  // TESTAK01
    // ...
}
```

### Module Mapping Guide

| Module | Code | Test Prefix | Example |
|--------|------|-------------|---------|
| Arus Kas | AK | TESTAK | TESTAK01, TESTAK02 |
| Penjualan | PJ | TESTPJ | TESTPJ01, TESTPJ02 |
| Pembelian | PB | TESTPB | TESTPB01, TESTPB02 |
| Purchase Order | PO | TESTPO | TESTPO01, TESTPO02 |
| Material Handover | PL | TESTPL | TESTPL01, TESTPL02 |
| Gudang (Warehouse) | GD | TESTGD | TESTGD01, TESTGD02 |

### Cleanup

```sql
-- Delete all test data for specific module
DELETE FROM DBArusKas WHERE KodeAK LIKE 'TEST%';
DELETE FROM DbArusKasDet WHERE KodeAK LIKE 'TEST%';

-- Or more specific
DELETE FROM DBArusKas WHERE KodeAK IN ('TESTAK01', 'TESTAK02');
```

### Benefits Summary

✅ **No Conflicts**: TEST prefix ensures uniqueness
✅ **Auto-Incrementing**: Sequence handles numbering
✅ **Identifiable**: Easy to spot test vs production
✅ **Cleanable**: Simple LIKE query for cleanup
✅ **Consistent**: All tests use same format
✅ **Reusable**: Factory works across all modules

---

## Pattern 10: Mixed Data Access (Stored Procedures + Direct SQL)

### 🔍 Delphi Pattern

Many modules use **both** stored procedures AND direct SQL queries:

```pascal
// Master operations use stored procedure
procedure TFrmArusKas.UpdateDataBeli(Choice:Char);
begin
  if Choice='I' then
  begin
    // Complex business logic in SP
    ExecProc('sp_MasterArusKas', [
      FKodeAK, FNamaAK, FTanggal, FKeterangan
    ]);
  end;
end;

// Detail operations use direct SQL
procedure TFrmSubArusKas.UpdateDataSubBeli(Choice:Char);
begin
  if Choice='I' then
  begin
    // Simple CRUD via direct queries
    QuArusKasDet.Insert;
    QuArusKasDet.FieldByName('KodeAK').AsString := FKodeAK;
    QuArusKasDet.FieldByName('KodeSubAK').AsString := FKodeSubAK;
    QuArusKasDet.Post;
  end;
end;
```

### 🎯 Laravel Implementation

**Key Decision**: Preserve stored procedures, use Eloquent for simple CRUD

```php
<?php

namespace App\Services;

use Illuminate\Support\Facades\DB;

class ArusKasService
{
    /**
     * Master create - preserve complex SP logic
     * Delphi: ExecProc('sp_MasterArusKas', ...)
     */
    public function create(array $data): DbArusKas
    {
        // Call stored procedure for complex business logic
        $result = DB::statement('EXEC sp_MasterArusKas ?, ?, ?, ?', [
            $data['KodeAK'],
            $data['NamaAK'],
            $data['TanggalBeli'],
            $data['Keterangan']
        ]);

        if (!$result) {
            throw new \Exception('Stored procedure failed');
        }

        // Retrieve the created record
        return DbArusKas::where('KodeAK', $data['KodeAK'])
            ->firstOrFail();
    }

    /**
     * Update master
     * Delphi: ExecProc('sp_MasterArusKas', ...) with Choice='U'
     */
    public function update(string $kodeAK, array $data): DbArusKas
    {
        $result = DB::statement('EXEC sp_MasterArusKas_Update ?, ?, ?, ?', [
            $kodeAK,
            $data['NamaAK'] ?? null,
            $data['TanggalBeli'] ?? null,
            $data['Keterangan'] ?? null
        ]);

        if (!$result) {
            throw new \Exception('Update failed');
        }

        return DbArusKas::where('KodeAK', $kodeAK)->firstOrFail();
    }
}

class ArusKasDetService
{
    /**
     * Detail create - use Eloquent for simple operations
     * Delphi: QuArusKasDet.Insert; QuArusKasDet.Post;
     */
    public function create(array $data): DbArusKasDet
    {
        $detail = DbArusKasDet::create([
            'KodeAK' => $data['KodeAK'],
            'KodeSubAK' => $data['KodeSubAK'],
            'Qty' => $data['Qty'],
            'Harga' => $data['Harga'],
            'SubTotal' => $data['Qty'] * $data['Harga'],
        ]);

        // Add audit logging (improvement over Delphi!)
        AuditLogService::log('create', 'arus_kas_det', $detail->toArray());

        return $detail;
    }

    /**
     * Detail update - use Eloquent
     * Delphi: QuArusKasDet.Edit; QuArusKasDet.Post;
     */
    public function update(string $kodeAK, string $kodeSubAK, array $data): DbArusKasDet
    {
        $detail = DbArusKasDet::where('KodeAK', $kodeAK)
            ->where('KodeSubAK', $kodeSubAK)
            ->firstOrFail();

        $oldData = $detail->toArray();

        $detail->update([
            'Qty' => $data['Qty'],
            'Harga' => $data['Harga'],
            'SubTotal' => $data['Qty'] * $data['Harga'],
        ]);

        // Log changes
        AuditLogService::log('update', 'arus_kas_det', $detail->toArray(), $oldData);

        return $detail;
    }
}
```

### 🎯 When to Use Each

| Scenario | Use Stored Procedure | Use Eloquent |
|----------|---------------------|--------------|
| Complex calculations | ✅ Yes | ❌ No |
| Multi-table updates | ✅ Yes | ❌ No |
| Business rule validation | ✅ Preserve from Delphi | ⚠️ May also validate in service |
| Simple CRUD | ❌ No | ✅ Yes |
| Audit logging needed | ❌ No | ✅ Yes (improvement!) |
| Stock calculations | ✅ Yes | ✅ + Eloquent validation |

### ✅ Detection Strategy

Check Delphi code for mixed patterns:

```bash
# Look for both ExecProc AND query statements
grep -n "ExecProc\|Query\|SQL.Text" FrmArusKas.pas

# If both found → Mixed data access pattern
# Plan: Keep SP for master, use Eloquent for detail
```

### ⚠️ Common Mistakes

```php
// ❌ WRONG: Move everything to Eloquent (loses SP logic)
public function create(array $data)
{
    // This misses complex business logic in original SP!
    return DbArusKas::create($data);
}

// ✅ CORRECT: Preserve SP, wrap in service
public function create(array $data)
{
    // Call SP for business logic
    DB::statement('EXEC sp_MasterArusKas ?, ?, ?, ?', [...]);

    // Retrieve result
    return DbArusKas::where('KodeAK', $data['KodeAK'])->firstOrFail();
}

// ❌ WRONG: No audit logging for details
public function createDetail(array $data)
{
    return DbArusKasDet::create($data);  // No logging!
}

// ✅ CORRECT: Add logging (improvement over Delphi!)
public function createDetail(array $data)
{
    $detail = DbArusKasDet::create($data);
    AuditLogService::log('create', 'arus_kas_det', $detail->toArray());
    return $detail;
}
```

---

## Pattern 11: Missing Audit Logs (Improvement Opportunity)

### 🔍 Delphi Anti-Pattern

Detail forms often lack audit logging:

```pascal
// ❌ Detail procedure with NO logging
procedure TFrmSubArusKas.UpdateDataBeli(Choice:Char);
begin
  if Choice='I' then
  begin
    QuArusKasDet.Insert;
    QuArusKasDet.FieldByName('KodeAK').AsString := FKodeAK;
    QuArusKasDet.FieldByName('Qty').AsFloat := StrToFloat(edtQty.Text);
    QuArusKasDet.Post;
    // ❌ NO LoggingData() call!
  end
  else if Choice='U' then
  begin
    QuArusKasDet.Edit;
    QuArusKasDet.FieldByName('Qty').AsFloat := StrToFloat(edtQty.Text);
    QuArusKasDet.Post;
    // ❌ NO LoggingData() call!
  end
  else if Choice='D' then
  begin
    QuArusKasDet.Delete;
    // ❌ NO LoggingData() call!
  end;
end;
```

### ✅ Laravel Improvement

**This is an OPPORTUNITY to improve over Delphi**, not just preservation:

```php
<?php

namespace App\Services;

use App\Models\DbArusKasDet;
use Illuminate\Support\Facades\Log;

class ArusKasDetService
{
    /**
     * Create detail with audit logging
     *
     * Delphi didn't log this - we IMPROVE by adding logging
     */
    public function create(array $data): DbArusKasDet
    {
        $detail = DbArusKasDet::create([
            'KodeAK' => $data['KodeAK'],
            'KodeSubAK' => $data['KodeSubAK'],
            'Qty' => $data['Qty'],
            'Harga' => $data['Harga'],
        ]);

        // ✅ ADD LOGGING (Delphi didn't have this!)
        $this->auditLog('create', $detail);

        return $detail;
    }

    /**
     * Update detail with change tracking
     *
     * Delphi didn't track what changed - we IMPROVE by logging old values
     */
    public function update(string $kodeAK, string $kodeSubAK, array $data): DbArusKasDet
    {
        $detail = DbArusKasDet::where('KodeAK', $kodeAK)
            ->where('KodeSubAK', $kodeSubAK)
            ->firstOrFail();

        // Track old values BEFORE update
        $oldData = [
            'Qty' => $detail->Qty,
            'Harga' => $detail->Harga,
        ];

        // Apply update
        $detail->update([
            'Qty' => $data['Qty'],
            'Harga' => $data['Harga'],
        ]);

        // ✅ LOG THE CHANGE (improvement!)
        $this->auditLog('update', $detail, $oldData);

        return $detail;
    }

    /**
     * Delete detail with before-deletion log
     *
     * Delphi didn't record what was deleted - we IMPROVE
     */
    public function delete(string $kodeAK, string $kodeSubAK): bool
    {
        $detail = DbArusKasDet::where('KodeAK', $kodeAK)
            ->where('KodeSubAK', $kodeSubAK)
            ->firstOrFail();

        // ✅ LOG BEFORE DELETION (improvement!)
        $this->auditLog('delete', $detail);

        return $detail->delete();
    }

    /**
     * Central audit logging method
     */
    protected function auditLog(string $action, DbArusKasDet $detail, ?array $oldData = null): void
    {
        Log::channel('audit')->info("Detail {$action}", [
            'user_id' => auth()->id(),
            'action' => strtoupper($action),
            'table' => 'arus_kas_det',
            'kode_ak' => $detail->KodeAK,
            'kode_sub_ak' => $detail->KodeSubAK,
            'new_data' => $detail->toArray(),
            'old_data' => $oldData,
            'ip_address' => request()->ip(),
            'user_agent' => request()->userAgent(),
        ]);
    }
}
```

### 🎯 Philosophy: Improvement, Not Preservation

**Key Mindset Change**: This is where Laravel migration becomes **better than Delphi**

| Aspect | Delphi | Laravel |
|--------|--------|---------|
| **Detail CREATE logging** | ❌ Missing | ✅ **Added** |
| **Detail UPDATE logging** | ❌ Missing | ✅ **With old/new values** |
| **Detail DELETE logging** | ❌ Missing | ✅ **Record before delete** |
| **User context** | ❌ Not captured | ✅ **auth()->id() + IP + User Agent** |
| **Audit trail quality** | 🟡 Partial | 🟢 **Complete** |

### ✅ Implementation Checklist

- [ ] ALL CRUD operations have audit logging
- [ ] DELETE operations log data BEFORE deletion
- [ ] UPDATE operations log both old AND new values
- [ ] User ID captured (not just username)
- [ ] IP address and user agent logged
- [ ] Timestamp automatic (Laravel timestamps)
- [ ] Audit logs in separate `audit` channel (separate from application logs)
- [ ] Sensitive data (passwords, tokens) EXCLUDED from logs

### 💡 Recommendation

**Always add audit logging**, regardless of whether Delphi had it. This is a **quality improvement** that makes the Laravel version better than the original.

---

**End of Pattern Guide**

For detailed SOP and implementation steps, refer to:
- `SOP-DELPHI-MIGRATION.md`
- `OBSERVATIONS.md`
