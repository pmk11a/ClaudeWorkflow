---
name: delphi-laravel-migration
version: 2.0.0
description: Migrate Delphi VCL applications to modern Laravel by extracting business logic, permissions, validation rules, and mode-dependent operations from Delphi source files (.dfm, .pas) and generating production-ready Laravel code with services, controllers, requests, and policies.
---

# Delphi to Laravel Migration Skill v2.0

Transform your legacy Delphi applications into modern Laravel applications with **rigorous business logic preservation**.

## What's New in v2.0

✅ **Full Pattern Detection** - Choice:Char, permissions, LoggingData, all 8 validation patterns  
✅ **Request Classes** - Separate Store/Update/Delete request classes  
✅ **Service Layer** - Mode-based operations with audit logging  
✅ **Policy Classes** - Permission mapping from Delphi  
✅ **Laravel Structure** - Proper directory layout  

## Quick Start

### 1. Analyze Your Delphi Form

```bash
python delphi-migrate-enhanced.py analyze FrmAktiva.pas
```

This will show:
- Detected permissions (IsTambah, IsKoreksi, IsHapus)
- Choice:Char procedures with modes (I/U/D)
- Validation rules found
- LoggingData calls

### 2. Run Full Migration

```bash
python delphi-migrate-enhanced.py migrate FrmAktiva.pas --model Aktiva
```

This generates:
- `app/Http/Controllers/AktivaController.php`
- `app/Http/Requests/Aktiva/StoreAktivaRequest.php`
- `app/Http/Requests/Aktiva/UpdateAktivaRequest.php`
- `app/Services/AktivaService.php`
- `app/Policies/AktivaPolicy.php`
- `app/Support/AuditLog.php`
- `routes/aktiva_routes.php`

### 3. Verify Generated Files

```bash
python delphi-migrate-enhanced.py verify
```

## Pattern Detection

### Mode-Based Operations (Choice:Char)

**Delphi:**
```pascal
Procedure TFrAktiva.UpdateDataAktiva(Choice:Char);
begin
  if Choice='I' then  // INSERT
    // ...
  else if Choice='U' then  // UPDATE
    // ...
  else if Choice='D' then  // DELETE
    // ...
end;
```

**Generated Laravel:**
- `store()` method → Choice='I'
- `update()` method → Choice='U'  
- `destroy()` method → Choice='D'

### Permission Mapping

| Delphi | Laravel Request | Laravel Policy |
|--------|-----------------|----------------|
| `IsTambah` | `StoreRequest::authorize()` | `Policy::create()` |
| `IsKoreksi` | `UpdateRequest::authorize()` | `Policy::update()` |
| `IsHapus` | - | `Policy::delete()` |
| `IsCetak` | - | `Policy::print()` |
| `IsExcel` | - | `Policy::export()` |

### Validation Patterns

| Pattern | Delphi | Laravel |
|---------|--------|---------|
| Range | `if Value < 0 then` | `min:0` |
| Unique | `if QuCheck.Locate(...)` | `unique:table,field` |
| Required | `if Text = '' then` | `required` |
| Format | `if not IsValidDate(...)` | `date_format:Y-m-d` |
| Lookup | `if not QuTable.Locate(...)` | `exists:table,field` |
| Conditional | `if Type=1 then if Field...` | `required_if:type,1` |
| Enum | `if not (Status in [...])` | `in:A,B,C` |
| Custom | `raise Exception.Create(...)` | `withValidator()` |

### Audit Logging

**Delphi:**
```pascal
LoggingData(IDUser, Choice, 'Aktiva', NoBukti, Keterangan);
```

**Generated Laravel:**
```php
AuditLog::log('I', 'Aktiva', $noBukti, auth()->id(), $keterangan);
```

## Generated Code Structure

```
output/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   └── AktivaController.php    # Uses Service, FormRequest
│   │   └── Requests/
│   │       └── Aktiva/
│   │           ├── StoreAktivaRequest.php   # INSERT validation
│   │           ├── UpdateAktivaRequest.php  # UPDATE validation
│   │           └── DeleteAktivaRequest.php  # DELETE validation
│   ├── Models/
│   │   └── Aktiva.php
│   ├── Policies/
│   │   └── AktivaPolicy.php           # Permission checks
│   ├── Services/
│   │   └── AktivaService.php          # Business logic
│   └── Support/
│       └── AuditLog.php               # Logging helper
├── database/
│   └── migrations/
│       └── create_log_activity_table.php
└── routes/
    └── aktiva_routes.php
```

## CLI Commands

```bash
# Analyze PAS file
python delphi-migrate-enhanced.py analyze <file.pas>

# Full migration
python delphi-migrate-enhanced.py migrate <file.pas> [--model Name] [--output dir]

# Generate only requests
python delphi-migrate-enhanced.py generate-requests <file.pas> --model Name

# Generate only service
python delphi-migrate-enhanced.py generate-service <file.pas> --model Name

# Verify output
python delphi-migrate-enhanced.py verify [--output dir]
```

## Success Criteria

Your migration is **rigorous** when:

✅ **100% Mode Coverage** - All I/U/D logic identified  
✅ **100% Permission Coverage** - All permission checks mapped  
✅ **95%+ Validation Coverage** - All 8 patterns detected  
✅ **100% Audit Coverage** - All LoggingData calls mapped  
✅ **<5% Manual Work** - Generated code is production-ready  

## Files Reference

| File | Purpose |
|------|---------|
| `parsers/pas_parser_enhanced.py` | Enhanced PAS parser with full pattern detection |
| `parsers/dfm_parser.py` | DFM form parser |
| `generators/request_generator.py` | FormRequest class generator |
| `generators/service_generator.py` | Service class generator |
| `generators/controller_generator_enhanced.py` | Controller generator |
| `generators/policy_generator.py` | Policy class generator |
| `generators/audit_log_generator.py` | AuditLog support generator |
| `delphi-migrate-enhanced.py` | Main CLI tool |

## Version History

- **v2.0.0** (2025-01-01): Full rewrite with complete pattern detection
- **v1.0.0**: Initial release with basic CRUD generation

---

**Use this Skill when:**
- ✅ Migrating Delphi VCL forms to Laravel
- ✅ Extracting business logic from Delphi applications
- ✅ Converting Delphi permission checks to Laravel authorization
- ✅ Translating Delphi validation rules to Laravel
- ✅ Building audit logging from LoggingData calls

**Do not use this Skill for:**
- ❌ Simple CRUD forms without complex business logic
- ❌ Third-party Delphi component migration
- ❌ Complex SQL stored procedures (manual review required)
