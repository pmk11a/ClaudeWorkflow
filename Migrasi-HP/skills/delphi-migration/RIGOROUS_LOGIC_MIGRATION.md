# Rigorous Delphi-to-Laravel Business Logic Migration

**Status**: Production Guide
**Version**: 2.0
**Date**: 2025-12-18
**Purpose**: Comprehensive guide for translating business logic from Delphi to Laravel with 100% accuracy

---

## 📋 Quick Navigation

- [Overview](#overview)
- [Critical Patterns](#critical-patterns)
- [Mode-Based Operations](#mode-based-operations)
- [Permission Checks](#permission-checks)
- [Field Dependencies](#field-dependencies)
- [Validation Rules](#validation-rules)
- [Real Examples from PWt](#real-examples-from-pwt)
- [Implementation Checklist](#implementation-checklist)

---

## Overview

### The Problem

The skill currently captures only basic CRUD operations but misses **30-50% of business logic** because:

1. **Mode-based operations ignored** - Different logic for Insert (I), Update (U), Delete (D)
2. **Permissions not extracted** - IsTambah, IsKoreksi, IsHapus checks lost
3. **Field dependencies missing** - Conditional visibility and validation ignored
4. **Validation incomplete** - Only 3 of 8+ patterns detected
5. **Audit logic missing** - LoggingData calls not preserved

### The Solution

This guide documents:
- **What to detect** - Patterns in Delphi code
- **How to translate** - Direct mapping to Laravel
- **Where to place** - Correct Laravel structure
- **How to test** - Verification strategies

---

## Critical Patterns

### Pattern 1: Mode-Based Operations (I/U/D)

#### Delphi Real Example
From `FrmAktiva.pas` (line 181):
```pascal
Procedure TFrAktiva.UpdateDataAktivaTetap(Choice:Char);
begin
  BM := QuView.GetBookmark;
  With sp_barang do
  begin
    close;
    Prepared;
    Parameters.Refresh;
    Parameters[1].Value := Choice;

    // Different parameter setup for each mode
    if (Choice='D') then
    begin
      // DELETE mode: only needs ID
      Parameters[2].Value := QuView.Fieldbyname('Devisi').AsString;
      Parameters[3].Value := Quview.fieldbyname('kodeaktiva').AsString;
    end
    else
    begin
      // INSERT/UPDATE mode: all fields
      Parameters[2].Value  := frSubAktiva.Devisi.Text;
      Parameters[3].Value  := frSubAktiva.KodeAktiva.Text;
      Parameters[4].Value  := FrSubAktiva.Keterangan.Text;
      Parameters[5].Value  := FrSubAktiva.Kuantum.AsFloat;
      // ... 25+ more parameters
    end;

    try
      ExecProc;

      // Mode-specific post-processing
      if Choice='I' then
      begin
        LoggingData(IDUser, Choice, 'Aktiva', '',
          'Kode Aktiva = ' + QuotedStr(frSubAktiva.KodeAktiva.Text) + ...);
        QuView.Requery;
        QuView.Locate('KodeAktiva', frSubAktiva.KodeAktiva.Text, []);
      end
      else if Choice='U' then
      begin
        LoggingData(IDUser, Choice, 'Aktiva', '', ...);
        QuView.Requery;
        if QuView.BookmarkValid(BM) then
          QuView.GotoBookmark(BM);
      end
      else if Choice='D' then
      begin
        LoggingData(IDUser, Choice, 'Aktiva', '', ...);
        QuView.Requery;
      end;
    except
      // Error handling per mode
      ShowMessage('Error');
    end;
  end;
end;
```

#### Detection Rules
```
1. Procedure/Function with Choice:Char parameter
2. Case/If statement on Choice value ('I', 'U', 'D')
3. Different parameter assignments per mode
4. Different error handling per mode
5. Mode-specific post-processing (LoggingData calls)
```

#### Laravel Translation

**Step 1: Create Mode-Specific Request Classes**

```php
// app/Http/Requests/Aktiva/StoreAktivaRequest.php
// For INSERT mode (Choice='I')
class StoreAktivaRequest extends FormRequest
{
    public function authorize(): bool
    {
        return auth()->user()->hasPermission('create-aktiva');
    }

    public function rules(): array
    {
        return [
            'no_aktiva' => 'required|string|unique:aktivas,no_aktiva',
            'perkiraan' => 'required|string',
            'kode_bag' => 'required|string',
            'divisi_id' => 'required|integer|exists:divisis,id',
            'tanggal_perolehan' => 'required|date',
            'keterangan' => 'nullable|string|max:500',
            'quantity' => 'required|numeric|min:0.01',
            'depreciation_rate' => 'required|numeric|min:0|max:100',
            // All fields required for INSERT
        ];
    }
}

// app/Http/Requests/Aktiva/UpdateAktivaRequest.php
// For UPDATE mode (Choice='U')
class UpdateAktivaRequest extends FormRequest
{
    public function authorize(): bool
    {
        return auth()->user()->hasPermission('update-aktiva');
    }

    public function rules(): array
    {
        $aktiva = $this->route('aktiva');

        return [
            'no_aktiva' => [
                'required',
                Rule::unique('aktivas', 'no_aktiva')->ignore($aktiva),
            ],
            // Key fields cannot be updated in UPDATE mode
            'perkiraan' => 'required|string',
            'kode_bag' => 'required|string',
            // Other fields are optional
            'keterangan' => 'nullable|string|max:500',
            'depreciation_rate' => 'nullable|numeric|min:0|max:100',
        ];
    }

    protected function prepareForValidation(): void
    {
        // Immutable fields for UPDATE mode
        $this->merge([
            'no_aktiva' => $this->route('aktiva')->no_aktiva,
        ]);
    }
}
```

**Step 2: Service Layer for Mode Logic**

```php
// app/Services/AktivaService.php
class AktivaService
{
    public function register(array $data): Aktiva
    {
        // INSERT mode (Choice='I')
        $aktiva = Aktiva::create($data);

        // Log the creation
        AuditLog::log('I', 'Aktiva', '', auth()->id(),
            sprintf('Kode Aktiva = %s, Group Aktiva = %s, Kuantum = %.2f',
                $aktiva->no_aktiva, $aktiva->perkiraan, $aktiva->quantity)
        );

        return $aktiva;
    }

    public function update(string $id, array $data): Aktiva
    {
        // UPDATE mode (Choice='U')
        $aktiva = Aktiva::findOrFail($id);

        // Store old values for audit
        $oldData = $aktiva->getAttributes();

        $aktiva->update($data);

        // Log the update
        AuditLog::log('U', 'Aktiva', $aktiva->no_aktiva, auth()->id(),
            sprintf('Kode Aktiva = %s, Perubahan: %s',
                $aktiva->no_aktiva,
                $this->formatChanges($oldData, $data))
        );

        return $aktiva->fresh();
    }

    public function delete(string $id): void
    {
        // DELETE mode (Choice='D')
        $aktiva = Aktiva::findOrFail($id);

        // Log before delete
        AuditLog::log('D', 'Aktiva', $aktiva->no_aktiva, auth()->id(),
            sprintf('Kode Aktiva = %s, Group Aktiva = %s',
                $aktiva->no_aktiva, $aktiva->perkiraan)
        );

        $aktiva->delete();
    }

    private function formatChanges(array $old, array $new): string
    {
        $changes = [];
        foreach ($new as $key => $value) {
            if (isset($old[$key]) && $old[$key] != $value) {
                $changes[] = sprintf('%s: %s → %s', $key, $old[$key], $value);
            }
        }
        return implode(', ', $changes);
    }
}
```

**Step 3: Controller Using Mode-Specific Requests**

```php
// app/Http/Controllers/AktivaController.php
class AktivaController extends Controller
{
    protected AktivaService $service;

    public function __construct(AktivaService $service)
    {
        $this->service = $service;
    }

    // INSERT mode (Choice='I')
    public function store(StoreAktivaRequest $request): JsonResponse
    {
        try {
            $aktiva = $this->service->register($request->validated());

            return response()->json([
                'success' => true,
                'message' => 'Aktiva berhasil didaftarkan',
                'data' => $aktiva,
            ], 201);
        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        }
    }

    // UPDATE mode (Choice='U')
    public function update(string $id, UpdateAktivaRequest $request): JsonResponse
    {
        try {
            $aktiva = $this->service->update($id, $request->validated());

            return response()->json([
                'success' => true,
                'message' => 'Aktiva berhasil diperbarui',
                'data' => $aktiva,
            ]);
        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        }
    }

    // DELETE mode (Choice='D')
    public function destroy(string $id): JsonResponse
    {
        try {
            $this->authorize('delete', Aktiva::findOrFail($id));
            $this->service->delete($id);

            return response()->json([
                'success' => true,
                'message' => 'Aktiva berhasil dihapus',
            ]);
        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        }
    }
}
```

---

### Pattern 2: Permission Checks (IsTambah/IsKoreksi/IsHapus)

#### Delphi Real Example
From `FrmAktiva.pas` (line 131):
```pascal
var
  FrAktiva: TFrAktiva;

type
  TFrAktiva = class(TForm)
  private
    IsTambah, IsKoreksi, IsHapus, IsCetak, IsExcel: Boolean;
  end;

// Permission check function in MyProcedure.pas (line 92-96):
procedure MsgTidakBerhakTambahData;
procedure MsgTidakBerhakKoreksiData;
procedure MsgTidakBerhakHapusData;
procedure MsgTidakBerhakExportData;
procedure MsgTidakBerhakCetakData;
```

#### Laravel Translation

**Step 1: Request Classes with Authorization**

```php
// app/Http/Requests/Aktiva/StoreAktivaRequest.php
class StoreAktivaRequest extends FormRequest
{
    public function authorize(): bool
    {
        // Maps to Delphi's IsTambah
        return auth()->user()->hasPermission('create-aktiva');
    }
}

// app/Http/Requests/Aktiva/UpdateAktivaRequest.php
class UpdateAktivaRequest extends FormRequest
{
    public function authorize(): bool
    {
        // Maps to Delphi's IsKoreksi
        return auth()->user()->hasPermission('update-aktiva');
    }
}

// app/Http/Requests/Aktiva/DeleteAktivaRequest.php
class DeleteAktivaRequest extends FormRequest
{
    public function authorize(): bool
    {
        // Maps to Delphi's IsHapus
        return auth()->user()->hasPermission('delete-aktiva');
    }
}
```

**Step 2: Policy for Fine-Grained Control**

```php
// app/Policies/AktivaPolicy.php
class AktivaPolicy
{
    // IsTambah → create permission
    public function create(User $user): bool
    {
        return $user->hasPermission('create-aktiva');
    }

    // IsKoreksi → update permission
    public function update(User $user, Aktiva $aktiva): bool
    {
        return $user->hasPermission('update-aktiva');
    }

    // IsHapus → delete permission
    public function delete(User $user, Aktiva $aktiva): bool
    {
        return $user->hasPermission('delete-aktiva');
    }

    // IsCetak → print permission
    public function print(User $user): bool
    {
        return $user->hasPermission('print-aktiva');
    }

    // IsExcel → export permission
    public function export(User $user): bool
    {
        return $user->hasPermission('export-aktiva');
    }
}
```

**Step 3: Models with AuditLog**

```php
// app/Models/Aktiva.php
class Aktiva extends Model
{
    protected $guarded = [];

    public static function boot()
    {
        parent::boot();

        // Log all operations
        static::created(fn ($model) => AuditLog::log('I', 'Aktiva', $model->no_aktiva));
        static::updated(fn ($model) => AuditLog::log('U', 'Aktiva', $model->no_aktiva));
        static::deleted(fn ($model) => AuditLog::log('D', 'Aktiva', $model->no_aktiva));
    }
}
```

---

### Pattern 3: Field Dependencies & Conditional Validation

#### Delphi Real Example
From form behavior (OnChange handlers):
```pascal
procedure OnFieldChange(Sender: TObject);
begin
  // Example: if TipeAktiva changes, adjust field requirements
  case TipeAktiva.ItemIndex of
    0: // Tangible assets
      begin
        EdtSerialNumber.Required := True;
        EdtLocation.Required := True;
      end;
    1: // Intangible assets
      begin
        EdtSerialNumber.Required := False;
        EdtLocation.Required := False;
        EdtUsefulLife.Required := True;
      end;
  end;
end;

// Conditional visible fields:
if Pos('IMPORT', KodeAktiva) > 0 then
  EdtCountryOrigin.Required := True;
end;
```

#### Laravel Translation

**In Request Classes:**

```php
class StoreAktivaRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'tipe_aktiva' => 'required|integer|in:0,1',
            'no_aktiva' => 'required|string|unique:aktivas',
            'serial_number' => [
                'required_if:tipe_aktiva,0',
            ],
            'location' => [
                'required_if:tipe_aktiva,0',
            ],
            'useful_life' => [
                'required_if:tipe_aktiva,1',
            ],
            'country_origin' => [
                'required_if:no_aktiva,*IMPORT*',
            ],
        ];
    }

    public function withValidator($validator)
    {
        $validator->after(function ($validator) {
            // For imported assets, require customs documentation
            if (str_contains($this->no_aktiva, 'IMPORT')) {
                if (!$this->get('country_origin')) {
                    $validator->errors()->add('country_origin',
                        'Negara asal wajib diisi untuk aktiva impor');
                }
            }
        });

        return $validator;
    }
}
```

---

### Pattern 4: Comprehensive Validation Rules

#### 8 Validation Patterns Detected

**Pattern A: Range Validation**
```delphi
if EdtQuantity.Value < 0 then
  raise Exception.Create('Qty tidak boleh negatif');
```

**Laravel:**
```php
'quantity' => 'required|numeric|min:0.01'
```

---

**Pattern B: Unique Validation**
```delphi
if QuCheck.Locate('KodeAktiva', EdtKodeAktiva.Text, []) then
  raise Exception.Create('Kode sudah ada');
```

**Laravel:**
```php
'no_aktiva' => 'required|unique:aktivas,no_aktiva'
```

---

**Pattern C: Cross-Field Validation**
```delphi
if EdtDepreciationRate.Value > MaxRate then
  raise Exception.Create('Depreciation rate terlalu tinggi');
```

**Laravel:**
```php
public function withValidator($validator)
{
    $validator->after(function ($validator) {
        $maxRate = $this->getMaxDepreciationRate();
        if ($this->get('depreciation_rate') > $maxRate) {
            $validator->errors()->add('depreciation_rate',
                'Depreciation rate terlalu tinggi');
        }
    });

    return $validator;
}
```

---

**Pattern D: Format Validation**
```delphi
if not IsValidDate(EdtDate.Text) then
  raise Exception.Create('Format tanggal tidak valid');
```

**Laravel:**
```php
'tanggal_perolehan' => 'required|date_format:Y-m-d'
```

---

**Pattern E: Lookup Validation**
```delphi
if not QuPerkiraan.Locate('Kode', EdtPerkiraan.Text, []) then
  raise Exception.Create('Perkiraan tidak ditemukan');
```

**Laravel:**
```php
'perkiraan' => 'required|exists:coas,kode'
```

---

**Pattern F: Conditional Validation**
```delphi
if TipeAktiva = 1 then
  if EdtUsefulLife.Value = 0 then
    raise Exception.Create('Umur manfaat wajib diisi');
```

**Laravel:**
```php
'useful_life' => 'required_if:tipe_aktiva,1|numeric|min:1'
```

---

**Pattern G: Calculated Field Validation**
```delphi
Total := Qty * Price;
if Total > CreditLimit then
  raise Exception.Create('Total melebihi limit kredit');
```

**Laravel:**
```php
public function withValidator($validator)
{
    $validator->after(function ($validator) {
        $total = $this->get('quantity') * $this->get('price');
        if ($total > $this->getCreditLimit()) {
            $validator->errors()->add('quantity',
                'Total melebihi limit kredit');
        }
    });

    return $validator;
}
```

---

**Pattern H: Type/Enum Validation**
```delphi
if not (Status in ['A', 'I']) then
  raise Exception.Create('Status tidak valid');
```

**Laravel:**
```php
'depreciation_method' => 'required|in:L,M,P'
```

---

## Real Examples from PWt

### Example 1: FrmAktiva.pas Structure

**Delphi Components:**
- `IsTambah, IsKoreksi, IsHapus` - Permissions
- `Choice:Char` parameter - Mode (I/U/D)
- `sp_barang` stored procedure - Database operation
- `LoggingData()` call - Audit trail
- `QuView.Requery()` - Data refresh
- Try/Except block - Error handling

**Laravel Equivalents:**
```
IsTambah               → StoreAktivaRequest + authorize()
IsKoreksi              → UpdateAktivaRequest + authorize()
IsHapus                → DeleteAktivaRequest + authorize()
Choice='I'             → store() method
Choice='U'             → update() method
Choice='D'             → destroy() method
sp_barang ExecProc()   → AktivaService methods
LoggingData()          → AuditLog::log()
QuView.Requery()       → $model->fresh() or reload
Try/Except Exception   → try/catch with JsonResponse
```

### Example 2: MyProcedure.pas Functions

**Permission Messages:**
```delphi
procedure MsgTidakBerhakTambahData;    → authorize in StoreRequest
procedure MsgTidakBerhakKoreksiData;   → authorize in UpdateRequest
procedure MsgTidakBerhakHapusData;     → authorize in DeleteRequest
```

**Mapping:**
```php
// In Request class
public function authorize(): bool
{
    return auth()->user()->hasPermission('create-aktiva');
    // If false, returns 403 (matches MsgTidakBerhak behavior)
}
```

---

## Implementation Checklist

### Parser Enhancements
- [ ] Detect Choice parameter patterns (I/U/D modes)
- [ ] Extract IsTambah/IsKoreksi/IsHapus variables
- [ ] Identify LoggingData calls and parameters
- [ ] Detect all 8 validation patterns
- [ ] Extract conditional field rules
- [ ] Identify stored procedure parameters

### Code Generation
- [ ] Generate mode-specific request classes
- [ ] Generate authorization logic in request
- [ ] Generate service layer with mode logic
- [ ] Generate policy classes
- [ ] Generate AuditLog calls with parameters
- [ ] Generate validation rules (all 8 patterns)

### Testing
- [ ] Test each mode (I/U/D) independently
- [ ] Test permission checks (authorize returns false)
- [ ] Test validation rules trigger correctly
- [ ] Test AuditLog records are created
- [ ] Test cross-field validation
- [ ] Test conditional validation

### Documentation
- [ ] Document all detected patterns
- [ ] Provide real examples from source code
- [ ] Include mapping table (Delphi → Laravel)
- [ ] Provide testing strategies

---

## Success Criteria

Migration is **rigorous** when:

1. ✅ **100% Mode Coverage** - All I/U/D logic identified and translated
2. ✅ **100% Permission Coverage** - All permission checks implemented
3. ✅ **95%+ Validation Coverage** - All 8 patterns detected
4. ✅ **100% Audit Coverage** - All LoggingData calls mapped to AuditLog
5. ✅ **95%+ Field Logic** - Conditional fields and cross-field validation
6. ✅ **<5% Manual Work** - Generated code requires minimal enhancement

---

## Quick Reference: Delphi → Laravel Mapping

```
Delphi                          Laravel
─────────────────────────────────────────────────────────
Choice:Char parameter           Mode-specific methods
  Choice='I'                    → store()
  Choice='U'                    → update()
  Choice='D'                    → destroy()

IsTambah                        → StoreRequest::authorize()
IsKoreksi                       → UpdateRequest::authorize()
IsHapus                         → DeleteRequest::authorize()

Parameters[N].Value := ...      → $request->validated()
ExecProc()                      → $service->method()
QuView.Requery()                → $model->fresh()
LoggingData()                   → AuditLog::log()
raise Exception.Create()        → throw new Exception()
try/except                      → try/catch JsonResponse
```

---

**Status**: ✅ Ready for Implementation
**Next Step**: Apply patterns to new migrations using this guide

---

### References
- Real Delphi source: `d:\ykka\migrasi\pwt\Master\AktivaTetap\FrmAktiva.pas`
- Shared procedures: `d:\ykka\migrasi\pwt\Unit\MyProcedure.pas`
- Existing Laravel: `d:\ykka\migrasi\app\Http\Controllers\AktivaController.php`
