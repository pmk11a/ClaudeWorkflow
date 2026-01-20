# Delphi Migration Tools - API Reference

**Document**: TOOLS-API.md
**Version**: 1.0
**Last Updated**: 2026-01-15
**Status**: 🟢 Reference

## Command-Line Interface

Quick reference for all Python tool commands.

---

## Main CLI: delphi-migrate.py

**Location**: `.claude/skills/delphi-migration/tools/delphi-migrate.py`

### analyze command

**Parse Delphi files and extract patterns**

```bash
python3 .claude/skills/delphi-migration/tools/delphi-migrate.py analyze [OPTIONS]
```

**OPTIONS**:
- `--pas-file PATH` - Path to Delphi .pas file (required)
- `--dfm-file PATH` - Path to Delphi .dfm file (optional)
- `--output PATH` - Output file for analysis (default: `ANALYSIS.md`)
- `--detect-patterns` - Enable pattern detection (default: `true`)
- `--detect-validations` - Enable validation extraction (default: `true`)
- `--verbose` - Show detailed output
- `--dry-run` - Preview without writing files

**EXAMPLES**:

```bash
# Basic analysis
python3 .claude/skills/delphi-migration/tools/delphi-migrate.py analyze \
  --pas-file d:/ykka/migrasi/pwt/FrmPPL.pas

# With DFM and custom output
python3 .claude/skills/delphi-migration/tools/delphi-migrate.py analyze \
  --pas-file d:/ykka/migrasi/pwt/FrmPPL.pas \
  --dfm-file d:/ykka/migrasi/pwt/FrmPPL.dfm \
  --output migrations-registry/in-progress/PPL_ANALYSIS.md

# Verbose mode for debugging
python3 .claude/skills/delphi-migration/tools/delphi-migrate.py analyze \
  --pas-file d:/ykka/migrasi/pwt/FrmPPL.pas \
  --verbose
```

**OUTPUT**: Markdown file with structured analysis

---

### generate command

**Generate all Laravel files from analysis**

```bash
python3 .claude/skills/delphi-migration/tools/delphi-migrate.py generate [OPTIONS]
```

**OPTIONS**:
- `--input PATH` - Analysis file (required)
- `--module NAME` - Module name (required)
- `--output-dir PATH` - Output directory (default: current dir)
- `--components LIST` - Comma-separated list of components to generate
  - Options: `controller,service,request,policy,model,view,test,all`
  - Default: `all`
- `--force` - Overwrite existing files
- `--dry-run` - Preview without writing files

**EXAMPLES**:

```bash
# Generate all components
python3 .claude/skills/delphi-migration/tools/delphi-migrate.py generate \
  --input migrations-registry/in-progress/PPL_ANALYSIS.md \
  --module PPL

# Generate only controller and service
python3 .claude/skills/delphi-migration/tools/delphi-migrate.py generate \
  --input migrations-registry/in-progress/PPL_ANALYSIS.md \
  --module PPL \
  --components controller,service

# Preview without writing
python3 .claude/skills/delphi-migration/tools/delphi-migrate.py generate \
  --input migrations-registry/in-progress/PPL_ANALYSIS.md \
  --module PPL \
  --dry-run
```

**OUTPUT**: Laravel files in app/, resources/, tests/

---

## Individual Generators

All generators can be called individually if needed.

### controller_generator.py

```bash
python3 .claude/skills/delphi-migration/tools/generators/controller_generator.py \
  --input <ANALYSIS_FILE> \
  --module <MODULE_NAME> \
  --output <OUTPUT_FILE>
```

**OPTIONS**:
- `--input PATH` - Analysis markdown file (required)
- `--module NAME` - Module name (e.g., PPL, PO) (required)
- `--output PATH` - Output file path (required)
- `--include-export` - Add export functionality
- `--include-print` - Add print functionality
- `--include-authorize` - Add multi-level authorization methods

**EXAMPLE**:
```bash
python3 .claude/skills/delphi-migration/tools/generators/controller_generator.py \
  --input migrations-registry/in-progress/PPL_ANALYSIS.md \
  --module PPL \
  --output app/Http/Controllers/PPLController.php
```

---

### service_generator.py

```bash
python3 .claude/skills/delphi-migration/tools/generators/service_generator.py \
  --input <ANALYSIS_FILE> \
  --module <MODULE_NAME> \
  --output <OUTPUT_FILE>
```

**OPTIONS**:
- `--input PATH` - Analysis markdown file (required)
- `--module NAME` - Module name (required)
- `--output PATH` - Output file path (required)
- `--include-audit` - Add audit logging (default: true)
- `--include-transactions` - Wrap methods in transactions (default: true)

**EXAMPLE**:
```bash
python3 .claude/skills/delphi-migration/tools/generators/service_generator.py \
  --input migrations-registry/in-progress/PPL_ANALYSIS.md \
  --module PPL \
  --output app/Services/PPLService.php
```

---

### request_generator.py

```bash
python3 .claude/skills/delphi-migration/tools/generators/request_generator.py \
  --input <ANALYSIS_FILE> \
  --module <MODULE_NAME> \
  --output <OUTPUT_DIR>
```

**OPTIONS**:
- `--input PATH` - Analysis markdown file (required)
- `--module NAME` - Module name (required)
- `--output PATH` - Output directory (required, will create multiple files)
- `--separate-delete` - Create separate DeleteRequest class

**EXAMPLE**:
```bash
python3 .claude/skills/delphi-migration/tools/generators/request_generator.py \
  --input migrations-registry/in-progress/PPL_ANALYSIS.md \
  --module PPL \
  --output app/Http/Requests/PPL/
```

**OUTPUT FILES**:
- `Store{Module}Request.php`
- `Update{Module}Request.php`
- `Delete{Module}Request.php` (if --separate-delete)

---

### policy_generator.py

```bash
python3 .claude/skills/delphi-migration/tools/generators/policy_generator.py \
  --input <ANALYSIS_FILE> \
  --module <MODULE_NAME> \
  --output <OUTPUT_FILE>
```

**OPTIONS**:
- `--input PATH` - Analysis markdown file (required)
- `--module NAME` - Module name (required)
- `--output PATH` - Output file path (required)
- `--menu-code CODE` - Menu code for permission checks (auto-detected from analysis)

**EXAMPLE**:
```bash
python3 .claude/skills/delphi-migration/tools/generators/policy_generator.py \
  --input migrations-registry/in-progress/PPL_ANALYSIS.md \
  --module PPL \
  --output app/Policies/PPLPolicy.php
```

---

### model_generator.py

```bash
python3 .claude/skills/delphi-migration/tools/generators/model_generator.py \
  --input <ANALYSIS_FILE> \
  --module <MODULE_NAME> \
  --output <OUTPUT_FILE>
```

**OPTIONS**:
- `--input PATH` - Analysis markdown file (required)
- `--module NAME` - Module name (required)
- `--output PATH` - Output file path (required)
- `--table-name NAME` - Override table name detection
- `--primary-key NAME` - Override primary key detection

**EXAMPLE**:
```bash
python3 .claude/skills/delphi-migration/tools/generators/model_generator.py \
  --input migrations-registry/in-progress/PPL_ANALYSIS.md \
  --module PPL \
  --output app/Models/DbPPL.php
```

**NOTE**: Usually models already exist. Only use if model is missing.

---

### view_generator.py

```bash
python3 .claude/skills/delphi-migration/tools/generators/view_generator.py \
  --input <ANALYSIS_FILE> \
  --module <MODULE_NAME> \
  --output <OUTPUT_DIR>
```

**OPTIONS**:
- `--input PATH` - Analysis markdown file (required)
- `--module NAME` - Module name (required)
- `--output PATH` - Output directory (required, will create multiple files)
- `--template STYLE` - Template style: `bootstrap5` (default), `tailwind`
- `--include-master-detail` - Generate master-detail views

**EXAMPLE**:
```bash
python3 .claude/skills/delphi-migration/tools/generators/view_generator.py \
  --input migrations-registry/in-progress/PPL_ANALYSIS.md \
  --module PPL \
  --output resources/views/ppl/
```

**OUTPUT FILES**:
- `index.blade.php` - List view
- `create.blade.php` - Create form
- `edit.blade.php` - Edit form
- `show.blade.php` - Detail view

---

### test_generator.py

```bash
python3 .claude/skills/delphi-migration/tools/generators/test_generator.py \
  --input <ANALYSIS_FILE> \
  --module <MODULE_NAME> \
  --output <OUTPUT_FILE>
```

**OPTIONS**:
- `--input PATH` - Analysis markdown file (required)
- `--module NAME` - Module name (required)
- `--output PATH` - Output file path (required)
- `--test-type TYPE` - Test type: `feature` (default), `unit`
- `--include-browser-tests` - Add Dusk browser tests

**EXAMPLE**:
```bash
python3 .claude/skills/delphi-migration/tools/generators/test_generator.py \
  --input migrations-registry/in-progress/PPL_ANALYSIS.md \
  --module PPL \
  --output tests/Feature/PPLTest.php
```

---

## Batch Operations

### Generate all files for a module

```bash
# Using main CLI (recommended)
python3 .claude/skills/delphi-migration/tools/delphi-migrate.py generate \
  --input migrations-registry/in-progress/PPL_ANALYSIS.md \
  --module PPL \
  --components all

# Or using ADW script (calls tools automatically)
./scripts/adw/adw-migration.sh PPL
```

### Re-generate single component

```bash
# Just regenerate controller
python3 .claude/skills/delphi-migration/tools/generators/controller_generator.py \
  --input migrations-registry/in-progress/PPL_ANALYSIS.md \
  --module PPL \
  --output app/Http/Controllers/PPLController.php
```

---

## Error Handling

### Common Errors

**Error**: `FileNotFoundError: [Errno 2] No such file or directory`
**Solution**: Check file paths are absolute, not relative

**Error**: `ModuleNotFoundError: No module named 'parsers'`
**Solution**: Run from project root or adjust PYTHONPATH

**Error**: `SyntaxError: invalid syntax in Delphi file`
**Solution**: Check Delphi file is valid Pascal syntax, not corrupted

**Error**: `KeyError: 'module' in analysis data`
**Solution**: Re-run analysis, may be incomplete or corrupted

---

## Output Validation

After running generators, verify output:

```bash
# Check generated files exist
ls -la app/Http/Controllers/PPLController.php
ls -la app/Services/PPLService.php
ls -la app/Http/Requests/PPL/
ls -la app/Policies/PPLPolicy.php
ls -la resources/views/ppl/
ls -la tests/Feature/PPLTest.php

# Run validation tool
php tools/validate_migration.php PPL FrmPPL

# Run tests
php artisan test --filter=PPL

# Format code
./vendor/bin/pint app/Http/Controllers/PPLController.php
```

---

## Development & Debugging

### Run with verbose output

```bash
python3 .claude/skills/delphi-migration/tools/delphi-migrate.py analyze \
  --pas-file d:/ykka/migrasi/pwt/FrmPPL.pas \
  --verbose
```

### Dry-run mode (preview without writing)

```bash
python3 .claude/skills/delphi-migration/tools/delphi-migrate.py generate \
  --input migrations-registry/in-progress/PPL_ANALYSIS.md \
  --module PPL \
  --dry-run
```

### Test parser directly

```python
# Interactive Python
python3
>>> from tools.parsers.pas_parser import EnhancedPASParser
>>> parser = EnhancedPASParser()
>>> analysis = parser.parse_file("d:/ykka/migrasi/pwt/FrmPPL.pas")
>>> print(analysis.procedures)
>>> print(analysis.permissions)
```

---

## Integration with ADW

ADW automatically calls these tools. See the flow in `scripts/adw/adw-migration.sh`:

```bash
# Phase I - Analysis
python3 .claude/skills/delphi-migration/tools/delphi-migrate.py analyze \
  --pas-file "$FIRST_PAS" \
  --dfm-file "$FIRST_DFM" \
  --output "${SPEC_DIR}/${MODULE}_ANALYSIS.md"

# Phase T - Generation (calls each generator)
python3 .claude/skills/delphi-migration/tools/generators/controller_generator.py ...
python3 .claude/skills/delphi-migration/tools/generators/service_generator.py ...
python3 .claude/skills/delphi-migration/tools/generators/request_generator.py ...
# ... etc
```

---

*See TOOLS-GUIDE.md for detailed tool explanations and algorithms*
