# Scripts - Delphi-to-Laravel Migration Tools

## verify-migration.php

**Purpose**: Verify that Delphi-to-Laravel migration patterns are correctly implemented

### Quick Start

```bash
php verify-migration.php
```

### What It Does

This automated verification tool:

1. **Extracts Delphi Patterns**
   - Mode parameters (Choice:Char)
   - Permission variables (IsTambah, IsKoreksi, IsHapus)
   - Mode-based procedures (UpdateDataAktivaTetap)
   - Parameter assignments (Parameters[N].Value)
   - LoggingData calls
   - Validation rules

2. **Extracts Laravel Patterns**
   - Controller methods (store, update, destroy)
   - Authorization checks
   - Service methods (register, update, delete)
   - Logging (AuditLog, Log::info, Log::error)

3. **Compares Patterns**
   - Mode parameter vs controller methods
   - Permission variables vs authorization logic
   - Parameter assignment vs request validation
   - LoggingData calls vs Laravel logging

4. **Generates Report**
   - Verification score (0-100%)
   - Pattern-by-pattern breakdown
   - Evidence from source files

### Configuration

Edit the source file paths in verify-migration.php if needed:

```php
$verifier = new DelphiLaravelVerifier(
    'd:\ykka\migrasi\pwt\Master\AktivaTetap\FrmAktiva.pas',
    'd:\ykka\migrasi\app\Http\Controllers\AktivaController.php',
    'd:\ykka\migrasi\app\Services\AktivaService.php'
);
```

### Verification Patterns

1. ✅ Mode Parameter (Choice:Char)
2. ✅ Permission Variables (IsTambah, IsKoreksi, IsHapus)
3. ✅ Mode Procedure (UpdateDataAktivaTetap)
4. ✅ Parameter Assignment (Parameters[N].Value)
5. ✅ Logging (LoggingData calls)
6. ✅ Validation Rules

### Score Interpretation

- 90-100%: ✅ Ready for production
- 80-89%: ⚠️ Mostly complete
- 70-79%: ❌ Incomplete
- <70%: ❌ Not ready

### Integration with Skill

Reference: `d:\ykka\migrasi\.claude\skills\delphi-migration\SKILL.md` Step 5

**Version**: 1.0 | **Status**: Production Ready | **Last Updated**: 2025-12-19
