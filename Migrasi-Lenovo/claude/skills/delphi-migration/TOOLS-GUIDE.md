# Delphi Migration Tools Guide

**Document**: TOOLS-GUIDE.md
**Version**: 1.0
**Last Updated**: 2026-01-15
**Status**: 🟢 Active

## Overview

This guide explains how the Python tools work for automated Delphi-to-Laravel migration. These tools are called **automatically** by ADW scripts - you don't need to run them manually unless debugging or testing.

## Tool Categories

1. **Parsers** - Extract patterns from Delphi files
2. **Generators** - Create Laravel code from analysis
3. **Orchestrator** - delphi-migrate.py CLI

---

## Parsers

### `tools/parsers/pas_parser.py`

**Purpose**: Parses Delphi .pas files to extract business logic

**INPUT**: Delphi Pascal source file (.pas)

**OUTPUT**: Structured analysis data (dict/JSON)

**DETECTS**:
- Choice:Char patterns → I/U/D modes
- Permission variables → IsTambah, IsKoreksi, IsHapus, IsCetak, IsExcel
- LoggingData() calls → Audit trail
- Validation rules (8 patterns):
  1. Range validation (if X > max then...)
  2. Unique constraints (duplicate checks)
  3. Required fields (if Trim(X) = '' then...)
  4. Format validation (regex-like patterns)
  5. Lookup validation (foreign key checks)
  6. Conditional validation (if A then check B)
  7. Enum validation (if X not in [A,B,C])
  8. Custom business rules
- Stored procedure calls → ExecProc(), ExecSQL()
- Event handlers → Button1Click, EditChange, etc.
- SQL queries → SELECT, INSERT, UPDATE, DELETE
- Database table references

**ALGORITHM**:
1. Tokenize Pascal source
2. Extract procedures/functions with regex
3. Detect parameters (esp. `Choice:Char`)
4. Parse procedure bodies for IF statements
5. Extract validation conditions
6. Match LoggingData() calls with params
7. Identify SQL queries and SP calls
8. Return structured data object

**EXAMPLE**:
```python
from parsers.pas_parser import EnhancedPASParser

parser = EnhancedPASParser()
analysis = parser.parse_file("FrmPPL.pas")

print(analysis.procedures)  # List of ProcedureFunction objects
print(analysis.permissions)  # List of PermissionCheck objects
print(analysis.validations)  # List of ValidationRule objects
print(analysis.logging_calls)  # List of LoggingCall objects
```

---

### `tools/parsers/dfm_parser.py`

**PURPOSE**: Parses Delphi .dfm files to extract UI components

**INPUT**: Delphi form file (.dfm)

**OUTPUT**: UI component tree

**DETECTS**:
- Form properties (Caption, Width, Height)
- Components (TEdit, TButton, TComboBox, TStringGrid, etc.)
- Component properties (Name, Caption, TabOrder)
- Event handlers (OnClick, OnChange, OnExit)
- Master-detail grids
- Lookup combo boxes
- Data-bound components

**ALGORITHM**:
1. Parse DFM hierarchical structure
2. Extract component tree
3. Map components to HTML equivalents
4. Identify data binding patterns
5. Return component metadata

**EXAMPLE**:
```python
from parsers.dfm_parser import EnhancedDFMParser

parser = EnhancedDFMParser()
ui_data = parser.parse_file("FrmPPL.dfm")

print(ui_data.form_name)  # "FrmPPL"
print(ui_data.components)  # List of UI components
```

---

## Generators

All generators follow the same pattern:
- INPUT: Analysis data (from parsers)
- OUTPUT: Laravel code file
- TEMPLATES: Use Laravel best practices

### `tools/generators/controller_generator.py`

**GENERATES**: Laravel Resource Controller

**INPUT**: ANALYSIS.md (markdown) or analysis dict

**OUTPUT**: `app/Http/Controllers/{Module}Controller.php`

**CREATES**:
- `index()` method - List view with filters
- `create()` method - Create form view
- `store()` method - Insert (from Choice='I')
- `edit()` method - Edit form view
- `update()` method - Update (from Choice='U')
- `destroy()` method - Delete (from Choice='D')
- Authorization via FormRequest classes

**TEMPLATE STRUCTURE**:
```php
<?php
namespace App\Http\Controllers;

use App\Http\Requests\{Module}\Store{Module}Request;
use App\Http\Requests\{Module}\Update{Module}Request;
use App\Models\{Module};
use App\Services\{Module}Service;

class {Module}Controller extends Controller
{
    public function __construct(
        private readonly {Module}Service $service
    ) {
        $this->middleware('auth');
    }

    public function index(Request $request): View { ... }
    public function store(Store{Module}Request $request): RedirectResponse { ... }
    public function update(Update{Module}Request $request, $id): RedirectResponse { ... }
    public function destroy($id): RedirectResponse { ... }
}
```

**USAGE**:
```bash
python3 tools/generators/controller_generator.py \
  --input migrations-registry/in-progress/PPL_ANALYSIS.md \
  --module PPL \
  --output app/Http/Controllers/PPLController.php
```

---

### `tools/generators/service_generator.py`

**GENERATES**: Business logic service layer

**OUTPUT**: `app/Services/{Module}Service.php`

**CREATES**:
- `create()` method - Choice='I' logic
- `update()` method - Choice='U' logic
- `delete()` method - Choice='D' logic
- Helper methods (validation, lookups)
- Transaction wrapping
- Audit logging calls

**PATTERN**:
```php
class {Module}Service
{
    public function create(array $data): {Module}
    {
        return DB::transaction(function () use ($data) {
            // Validation
            // Insert
            // Audit log
            return $model;
        });
    }
}
```

---

### `tools/generators/request_generator.py`

**GENERATES**: FormRequest classes (mode-specific)

**OUTPUT**:
- `app/Http/Requests/{Module}/Store{Module}Request.php`
- `app/Http/Requests/{Module}/Update{Module}Request.php`
- `app/Http/Requests/{Module}/Delete{Module}Request.php` (if needed)

**CREATES**:
- `authorize()` method - Permission checks (IsTambah → create, IsKoreksi → update, etc.)
- `rules()` method - Validation rules extracted from Delphi
- Custom validation logic

**PATTERN**:
```php
class Store{Module}Request extends FormRequest
{
    public function authorize(): bool
    {
        return MenuAccessService::hasPermission($this->user(), '{module_code}', 'create');
    }

    public function rules(): array
    {
        return [
            'field' => 'required|max:50',
            // ... (from Delphi validations)
        ];
    }
}
```

---

### `tools/generators/policy_generator.py`

**GENERATES**: Authorization policy

**OUTPUT**: `app/Policies/{Module}Policy.php`

**CREATES**:
- `create()` - Check IsTambah
- `update()` - Check IsKoreksi + record state
- `delete()` - Check IsHapus + record state
- `authorize()` - Check OL permissions (if multi-level auth)

---

### `tools/generators/model_generator.py`

**GENERATES**: Eloquent Model (only if doesn't exist)

**OUTPUT**: `app/Models/Db{Module}.php`

**CREATES**:
- Table name mapping
- Primary key definition
- Fillable fields
- Relationships (from FK analysis)
- Accessors/Mutators

**NOTE**: Usually models already exist. Generator only runs if model missing.

---

### `tools/generators/view_generator.py`

**GENERATES**: Blade view files

**OUTPUT**:
- `resources/views/{module}/index.blade.php` - List view
- `resources/views/{module}/create.blade.php` - Create form
- `resources/views/{module}/edit.blade.php` - Edit form
- `resources/views/{module}/show.blade.php` - Detail view

**CREATES**:
- Bootstrap 5 styled forms
- DataTables for grids
- Filter controls
- Validation error display
- Master-detail views (if detected)

---

### `tools/generators/test_generator.py`

**GENERATES**: Feature tests

**OUTPUT**: `tests/Feature/{Module}Test.php`

**CREATES**:
- Test for store() (Choice='I')
- Test for update() (Choice='U')
- Test for delete() (Choice='D')
- Authorization tests
- Validation tests

---

### `tools/generators/audit_log_generator.py`

**GENERATES**: Audit logging integration

**OUTPUT**: Adds `AuditLogService::log()` calls to Service

**NOTE**: Usually integrated into service_generator, not standalone

---

## Orchestrator

### `tools/delphi-migrate.py`

**PURPOSE**: Main CLI tool that orchestrates parsers and generators

**COMMANDS**:

#### `analyze` - Parse Delphi files
```bash
python3 tools/delphi-migrate.py analyze \
  --pas-file d:/ykka/migrasi/pwt/FrmPPL.pas \
  --dfm-file d:/ykka/migrasi/pwt/FrmPPL.dfm \
  --output migrations-registry/in-progress/PPL_ANALYSIS.md
```

#### `generate` - Generate all Laravel files
```bash
python3 tools/delphi-migrate.py generate \
  --input migrations-registry/in-progress/PPL_ANALYSIS.md \
  --module PPL \
  --output-dir .
```

**OPTIONS**:
- `--pas-file PATH` - Path to Delphi .pas file (required for analyze)
- `--dfm-file PATH` - Path to Delphi .dfm file (optional)
- `--output PATH` - Output file for analysis (default: ANALYSIS.md)
- `--module NAME` - Module name (required for generate)
- `--verbose` - Show detailed output
- `--dry-run` - Preview without writing files

---

## How ADW Uses Tools

ADW script calls tools in this sequence:

### Phase I - Analysis
```bash
python3 .claude/skills/delphi-migration/tools/delphi-migrate.py analyze \
  --pas-file "$FIRST_PAS" \
  --dfm-file "$FIRST_DFM" \
  --output "${SPEC_DIR}/${MODULE}_ANALYSIS.md"
```

### Phase T - Code Generation
```bash
# Controller
python3 tools/generators/controller_generator.py \
  --input "$ANALYSIS_FILE" \
  --module "$MODULE" \
  --output "app/Http/Controllers/${MODULE}Controller.php"

# Service
python3 tools/generators/service_generator.py \
  --input "$ANALYSIS_FILE" \
  --module "$MODULE" \
  --output "app/Services/${MODULE}Service.php"

# Requests
python3 tools/generators/request_generator.py \
  --input "$ANALYSIS_FILE" \
  --module "$MODULE" \
  --output "app/Http/Requests/${MODULE}/"

# Policy
python3 tools/generators/policy_generator.py \
  --input "$ANALYSIS_FILE" \
  --module "$MODULE" \
  --output "app/Policies/${MODULE}Policy.php"

# Model (if needed)
python3 tools/generators/model_generator.py \
  --input "$ANALYSIS_FILE" \
  --module "$MODULE" \
  --output "app/Models/Db${MODULE}.php"

# Views
python3 tools/generators/view_generator.py \
  --input "$ANALYSIS_FILE" \
  --module "$MODULE" \
  --output "resources/views/${MODULE,,}/"

# Tests
python3 tools/generators/test_generator.py \
  --input "$ANALYSIS_FILE" \
  --module "$MODULE" \
  --output "tests/Feature/${MODULE}Test.php"
```

---

## Tool Output Format

### Analysis Output (ANALYSIS.md)

```markdown
# Delphi Analysis: PPL

## Detected Patterns

### Mode Operations
- Choice='I' → Insert → store()
- Choice='U' → Update → update()
- Choice='D' → Delete → destroy()

### Permissions
- IsTambah → create permission
- IsKoreksi → update permission
- IsHapus → delete permission

### Validations
1. Required: KodeBrg, NamaBrg (if Trim(X) = '')
2. Range: Qty > 0
3. Unique: KodeBrg must be unique
... (all 8 patterns)

### Audit Logging
- LoggingData(User, 'I', 'PPL', NoBukti, Keterangan)
- LoggingData(User, 'U', 'PPL', NoBukti, Keterangan)
- LoggingData(User, 'D', 'PPL', NoBukti, Keterangan)

### Database Tables
- dbPPL (master)
- dbPPLDet (detail)
```

---

## Debugging Tools

If tools fail, check:

1. **Python version**: `python3 --version` (need 3.8+)
2. **Dependencies**: Check if tool has requirements.txt
3. **File paths**: Use absolute paths
4. **Delphi syntax**: Tools expect standard Delphi 6/7 syntax
5. **Logs**: ADW saves logs to `logs/adw/migration_*.log`

---

## Extending Tools

To add new patterns or generators:

1. Update parser in `tools/parsers/pas_parser.py`
2. Add pattern detection regex
3. Update generator templates
4. Test with sample Delphi file
5. Update OBSERVATIONS.md with new pattern

---

*See TOOLS-API.md for complete API reference*
