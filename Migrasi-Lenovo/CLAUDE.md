# CLAUDE.md - Delphi Migration Project

> **Delphi 6 → Laravel 12** | SQL Server 2008 (192.168.56.1:1433/dbwbcp2)

## Context

- **Source**: `d:\ykka\migrasi\pwt\` (.pas, .dfm files)
- **Focus**: Preserve business logic validation, NOT create new tables
- **Pattern**: Controller → Request → Service → Model

## Quick Start

```bash
# RECOMMENDED: ADW Pipeline (4-6 hours, 50% faster)
./scripts/adw/adw-migration.sh <MODULE>

# Validation only
./scripts/adw/adw-validation.sh <MODULE> <FORM>

# Manual (fallback)
/delphi-laravel-migration "FrmXXX.pas FrmXXX.dfm"
```

## Essential Commands

| Command | Purpose |
|---------|---------|
| `php artisan test` | Run tests |
| `./vendor/bin/pint` | Format code (PSR-12) |
| `php artisan migrate` | ✅ Safe |
| `php artisan migrate:rollback` | ✅ Safe |

## 🚫 Critical Rules

```bash
# ❌ NEVER (deletes ALL data)
php artisan migrate:fresh / reset / refresh / db:wipe

# ❌ NEVER (SQL injection)
DB::select("SELECT * FROM X WHERE Y = '$var'");

# ❌ NEVER (breaks FK constraints)
use RefreshDatabase;  # Use DatabaseTransactions instead
```

## Key Details

| Item | Value |
|------|-------|
| **Auth Model** | `Trade2Exchange\User` (NOT default) |
| **Test Trait** | `DatabaseTransactions` (NOT RefreshDatabase) |
| **Column Style** | PascalCase (`KodeBrg`, not `kode_brg`) |
| **NOT NULL varchar** | Use `''` instead of `null` |
| **Menu Codes** | PPL=03001, PO=03002 (see dbMenu) |

## 📚 Documentation Map

| Need | Read |
|------|------|
| **Start migration** | `.claude/skills/delphi-migration/00-README-START-HERE.md` |
| **ADW architecture** | `.claude/skills/delphi-migration/ADW-ARCHITECTURE.md` |
| **All patterns (8)** | `.claude/skills/delphi-migration/PATTERN-GUIDE.md` |
| **Implementation recipes** | `.claude/skills/delphi-migration/KNOWLEDGE-BASE.md` |
| **Rules & standards** | `.claude/skills/delphi-migration/RULES.md` |
| **Commands cheatsheet** | `.claude/skills/delphi-migration/QUICK-REFERENCE.md` |
| **Past lessons** | `ai_docs/lessons/` |
| **ADW walkthrough** | `scripts/adw/WALKTHROUGH.md` |

## Agent Instructions

1. **Read** `.claude/skills/delphi-migration/00-README-START-HERE.md` first
2. **Use** ADW: `./scripts/adw/adw-migration.sh <MODULE>`
3. **Approve** at Phase 3 (before implement) and Phase 5 (before deploy)
4. **Log** lessons to `ai_docs/lessons/`
5. **Cleanup** - No markdown in root, delete temp scripts

## File Organization

| Type | Location |
|------|----------|
| Migration summaries | `.claude/skills/delphi-migration/` |
| Lessons learned | `ai_docs/lessons/` |
| Temp scripts | Delete after use |
| **NO** markdown in root | Use folders only |

---

*Version 3.0 Lean | 2026-01-16*
