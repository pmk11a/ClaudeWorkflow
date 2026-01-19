# CLAUDE.md - Delphi Migration Agentic System

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 🎯 Project Context

**Delphi 6 → Laravel 12 Migration** | SQL Server 2008 (192.168.56.1:1433/dbwbcp2)

- Delphi source: `d:\ykka\migrasi\pwt\` (.pas, .dfm files)
- Focus: Preserve business logic validation, NOT create new tables
- Ask before assuming - tables exist, don't guess schema
- Jangan buat summary / documentasi tanpa di minta.
- Dokumentasi di folder tersendiri jangan di root.

---

## 🤖 AGENTIC ENGINEERING LAYER

> **"Build the system that builds the system"** - IndyDevDan

This project implements **Codebase Singularity** concepts for automated Delphi-to-Laravel migration.

### The Core Four

| Component | Implementation | Purpose |
|-----------|---------------|---------|
| **Context** | CLAUDE.md + ai_docs/ + .claude/skills/ | Everything agent needs to know |
| **Model** | Claude Code (Opus/Sonnet) | AI reasoning engine |
| **Prompt** | templates/ + commands/ | Reusable migration instructions |
| **Tools** | tools/ + scripts/adw/ | Validation & automation |

### Agentic Layers

```
Layer 4: CODEBASE SINGULARITY
  └─ Multi-agent orchestration
  └─ Self-improving migration patterns
  └─ Automated pattern detection

Layer 3: ZERO TOUCH ENGINEERING (ZTE)
  └─ Full migration runs autonomously
  └─ Self-correcting with validation loops
  └─ Human only reviews final output

Layer 2: OUT OF THE LOOP (PITER)
  └─ P: Problem defined in spec
  └─ I: Instructions in templates
  └─ T: Tools validate output
  └─ E: Examples from past migrations
  └─ R: Review criteria in checklists

Layer 1: IN THE LOOP
  └─ Developer guides each step
  └─ Traditional prompting
```

### Current Status: **Layer 2-3 (Out of Loop → ZTE)**

---

## 📋 Commands Reference

```bash
# === Development ===
composer dev                           # All services
php artisan serve                      # Laravel only
php artisan test                       # Run tests
./vendor/bin/pint                      # Format code (PSR-12)

# === Database (SAFE commands only) ===
php artisan migrate                    # ✅ Safe
php artisan migrate:rollback           # ✅ Safe
# ❌ NEVER: migrate:fresh, migrate:reset, migrate:refresh (delete data!)

# === ADW (AI Developer Workflows) ===
./scripts/adw/adw-migration.sh <module>        # Full migration workflow
./scripts/adw/adw-validation.sh <module>       # Validation only
./scripts/adw/adw-review.sh                    # Code review pipeline

# === Tools ===
php tools/validate_migration.php <module> <form>    # Validation gaps
php tools/extract_validation_rules.php <form>       # Extract Delphi rules
python delphi-migrate.py analyze <form>             # Pattern detection
```

---

## 🏗️ Architecture

**Pattern: Controller → Request → Service → Model**

```
app/
├── Http/
│   ├── Controllers/        # Thin - HTTP only
│   ├── Requests/          # Validation + authorization per mode (I/U/D)
│   └── Policies/          # Authorization rules
├── Services/              # Business logic (Delphi procedures here)
├── Models/
│   ├── Db*.php           # SQL Server tables (e.g., DbPPL, DbBARANG)
│   └── *.php             # Laravel tables
└── Utilities/            # Helpers

.claude/
├── commands/              # Slash commands (agent instructions)
├── skills/
│   └── delphi-migration/  # Migration skill files
└── settings.json          # Claude Code settings

ai_docs/                   # Domain knowledge for agents
├── patterns/              # Migration patterns
├── validation/            # Validation rules
└── examples/              # Completed migrations

templates/                 # Prompt templates (PITER)
├── migration-spec.md      # Feature specification
├── validation-check.md    # Validation checklist
└── review-criteria.md     # Review standards

scripts/adw/               # AI Developer Workflows
├── adw-migration.sh       # Full migration pipeline
├── adw-validation.sh      # Validation pipeline
└── adw-review.sh          # Review pipeline

tools/                     # Validation tools
├── validate_migration.php
└── extract_validation_rules.php
```

---

## 🔄 Delphi → Laravel Mapping

| Delphi | Laravel |
|--------|---------|
| `Choice='I'` (Insert) | `store()` + `StoreRequest` |
| `Choice='U'` (Update) | `update()` + `UpdateRequest` |
| `Choice='D'` (Delete) | `destroy()` + authorization |
| `IsTambah` permission | `Request::authorize()` → check create |
| `IsKoreksi` permission | `Request::authorize()` → check update |
| `IsHapus` permission | `Request::authorize()` → check delete |
| `LoggingData()` | `AuditLogService::log()` |
| `ExecProc()` | `$service->method()` |
| `IsLockPeriode()` | `LockPeriodService::isLocked()` |
| `CekOtorisasi()` | `AuthorizationService::canAuthorize()` |

**Validation Logic**: See `ai_docs/patterns/RIGOROUS_LOGIC_MIGRATION.md` for complete patterns

---

## ⚠️ Database Rules (CRITICAL)

1. **Tables exist** - check `app/Models/Db*.php`, ask if missing
2. **Single table** → Eloquent: `DbBARANG::where('KodeBrg', $code)->first()`
3. **Multi-table** → Raw with binding: `DB::select('...', [$param])`
4. **Never** string concatenation (SQL injection risk)
5. **Model naming**: `Db{Table}` for SQL Server (e.g., `DbPPL.php`)
6. **NOT NULL columns**: Use empty string `''` instead of `null` for varchar NOT NULL columns

---

## 🚀 Migration Workflow (PITER Framework)

### Use ADW Command:
```bash
./scripts/adw/adw-migration.sh "PPL"
```

### Or Manual with Command:
```
/delphi-laravel-migration "FrmPPL.pas FrmPPL.dfm"
```

### 5 Phases (NEVER skip approval gates):

| Phase | Time | Actions | Gate |
|-------|------|---------|------|
| 0. Discovery | 30m | Read Delphi, identify patterns | - |
| 1. Analyze | 2-3h | Extract business logic | - |
| 2. Check | 1-2h | Find existing Laravel code | - |
| 3. Plan | 1-2h | Create implementation spec | 🚨 **USER APPROVAL** |
| 4. Implement | 4-6h | Write code after approval | - |
| 5. Test | 3-5h | Validate & document | 🚨 **USER SIGN-OFF** |

### Complexity Levels:

| Level | Time | Characteristics |
|-------|------|-----------------|
| 🟢 SIMPLE | 2-4h | Basic CRUD, single form |
| 🟡 MEDIUM | 4-8h | Master-detail, business rules |
| 🔴 COMPLEX | 8-12h | Multiple forms, algorithms, stock impact |

---

## 📊 The 12 Leverage Points (Applied to Migration)

1. **Standard Output** - `php artisan test` output drives decisions
2. **Types/Schemas** - TypeScript-like strict typing in PHP 8.2+
3. **Tests** - Unit tests validate migration correctness
4. **Architecture Docs** - ai_docs/ folder for patterns
5. **Linting/Formatting** - Pint runs after every change
6. **Git History** - Commit messages follow convention
7. **CI/CD** - Tests run on every commit
8. **Error Messages** - Clear Indonesian error messages
9. **Documentation** - CLAUDE.md + ai_docs/
10. **Examples** - migrations-registry/ for patterns
11. **Domain Knowledge** - Delphi MyProcedure.pas reference
12. **Feedback Loops** - Validation tools check coverage

---

## ✅ Validation Checklist

### Before ANY Migration:
- [ ] Read CLAUDE.md (this file)
- [ ] Run `/delphi-laravel-migration` command
- [ ] Check complexity (SIMPLE/MEDIUM/COMPLEX)
- [ ] Verify tables exist in `app/Models/Db*.php`

### After Migration:
- [ ] Run `php tools/validate_migration.php <module> <form>`
- [ ] All tests pass: `php artisan test`
- [ ] Code formatted: `./vendor/bin/pint`
- [ ] No CRITICAL gaps in validation report

### Quality Metrics:
- ✅ **100% Mode Coverage** - All I/U/D logic implemented
- ✅ **100% Permission Coverage** - All permission checks mapped
- ✅ **95%+ Validation Coverage** - All 8 patterns detected
- ✅ **100% Audit Coverage** - All LoggingData preserved

---

## 📚 Key Resources

### Core Documentation:
- `.claude/skills/delphi-migration/SOP-DELPHI-MIGRATION.md` - Full SOP
- `.claude/skills/delphi-migration/PATTERN-GUIDE.md` - All patterns
- `.claude/skills/delphi-migration/RULES.md` - Mandatory rules
- `.claude/skills/delphi-migration/QUICK-REFERENCE.md` - Quick lookup

### Lessons Learned:
- `ai_docs/lessons/PPL_LOCKPERIODE_IMPLEMENTATION.md`
- `ai_docs/lessons/AUTHORIZATION_NULLS_CONSTRAINT_FIX.md`
- `ai_docs/lessons/PPL_PODET_VALIDATION_FIX.md`

### Migration Registry:
- `migrations-registry/successful/` - Completed migrations
- `migrations-registry/challenging/` - Difficult cases
- `migrations-registry/lessons-learned/` - Key learnings

---

## 🔑 Key Details

- **Auth**: `Trade2Exchange\User` model (NOT default User)
- **Tests**: Use SQLite in-memory (see phpunit.xml)
- **SQL Server**: PascalCase columns (e.g., `KodeBrg`, not `kode_brg`)
- **Delphi deps**: Check `pwt/Unit/MyProcedure.pas` for shared code
- **Menu codes**: PPL=03001, PO=03002, etc. (see dbMenu)

---

## 🚫 Forbidden Practices

```bash
# ❌ NEVER run these commands
php artisan migrate:fresh
php artisan migrate:reset
php artisan migrate:refresh
php artisan db:wipe

# ❌ NEVER do these in code
DB::select("SELECT * FROM X WHERE Y = '$var'");  # SQL injection!
$header = Model::create($data);  # Without transaction for multi-step
// $this->authorize('create', Model::class);  # Commented authorization
```

---

## 🤖 Agent Instructions

### When Starting a Migration:
1. **Read** ai_docs/patterns/ for relevant patterns
2. **Check** migrations-registry/ for similar completed migrations
3. **Use** templates/ for specification format
4. **Run** tools/ after implementation
5. **Log** lessons to migrations-registry/lessons-learned/

### Decision Framework:
```
IF task is "migrate Delphi form"
  → Run ADW: ./scripts/adw/adw-migration.sh
  → Follow PITER framework
  → Get approval at Phase 3 and 5

IF task is "fix validation gap"
  → Check ai_docs/lessons/ for similar issues
  → Run validation tool after fix
  → Document in lessons-learned/

IF task is "review code"
  → Run ADW: ./scripts/adw/adw-review.sh
  → Check RULES.md compliance
  → Verify test coverage
```

### Learning Loop:
```
1. Complete migration
2. Run validation tools
3. Document gaps found
4. Add to lessons-learned/
5. Update patterns if new discovery
6. Next migration uses improved knowledge
```

---

## 📈 KPIs (Agentic Coding Metrics)

| KPI | Target | Description |
|-----|--------|-------------|
| **Plan Velocity** | < 30 min/migration | Time to create spec |
| **Review Velocity** | < 15 min/migration | Time to review output |
| **Autonomy Rate** | > 80% | Tasks without intervention |
| **First-Pass Success** | > 70% | Acceptable first outputs |
| **Validation Coverage** | > 95% | Patterns detected |

---

*Last Updated: 2026-01-03*
*Version: 2.0 (Agentic Engineering Edition)*
