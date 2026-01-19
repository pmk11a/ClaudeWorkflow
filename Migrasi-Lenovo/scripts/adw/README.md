# ADW (AI Developer Workflows) - Automated Migration Pipeline

**Status**: ✅ Production Ready
**Version**: 1.0
**Last Updated**: 2026-01-12
**Framework**: PITER (Problem, Instructions, Tools, Examples, Review)

## What is ADW?

ADW is the **primary automation system** for Delphi-to-Laravel migrations, implementing the PITER framework to orchestrate complex, multi-step migrations with minimal manual intervention.

### Quick Stats

| Metric | Value |
|--------|-------|
| **Time Savings** | 50-60% vs manual (4-6h vs 8-12h) |
| **Success Rate** | 100% (5 migrations completed) |
| **Quality Score** | 88-98/100 average |
| **Adoption Target** | 80%+ for all new migrations |

---

## 📚 Quick Documentation Links

**Before Using ADW**, review these resources:

### Essential Reading (30 minutes)
1. **[ADW Architecture](../.claude/skills/delphi-migration/ADW-ARCHITECTURE.md)** - How ADW works (15 min)
2. **[Skill Documentation](../.claude/skills/delphi-migration/00-README-START-HERE.md)** - Full skill overview (15 min)

### Reference During Migration
- **[QUICK-REFERENCE.md](../.claude/skills/delphi-migration/QUICK-REFERENCE.md)** - All commands & patterns
- **[PATTERN-GUIDE.md](../.claude/skills/delphi-migration/PATTERN-GUIDE.md)** - 8 migration patterns explained
- **[Phase Documentation](../.claude/skills/delphi-migration/phases/)** - Step-by-step phase guides (Phase 0-5)
- **[Lessons Learned](../.claude/skills/delphi-migration/OBSERVATIONS.md)** - From past migrations

### Learning From Real Examples
- **[WALKTHROUGH.md](./WALKTHROUGH.md)** - Real PPL migration (4.5 hours, 89/100 quality)
- **[Migration Registry](../.claude/skills/delphi-migration/migrations-registry/successful/)** - 5 completed migrations
  - PPL (4.5h, 89/100)
  - GROUP (2.5h, 95/100)
  - ARUS_KAS (3.5h, 98/100)
  - PO (3.5h, 93/100)
  - PB (8h, 88/100)

---

### 1. adw-migration.sh - Complete Migration Pipeline

**Purpose**: End-to-end automation from Delphi code to production Laravel
**Time**: 4-6 hours (vs 8-12 manual)
**Input**: Module name
**Output**: Complete migrated code + tests + documentation

**Features**:
- ✅ Auto-discovers Delphi files (Phase 0)
- ✅ Generates spec from template (Phase P)
- ✅ Runs analysis agent (Phase I)
- ✅ Checks existing code (Phase T)
- ✅ Loads example patterns (Phase E)
- ✅ 2 approval gates (Phase 3 + Final)
- ✅ Auto-validation and testing (Phase R)
- ✅ Generates migration registry entry

**Usage**:
```bash
./scripts/adw/adw-migration.sh <MODULE>

# Example:
./scripts/adw/adw-migration.sh PPL
# Output: Complete PPL migration in 4-6 hours with 89/100 quality
```

### 2. adw-validation.sh - Post-Migration Validation

**Purpose**: Comprehensive validation of completed migrations
**Time**: 10-15 minutes
**Input**: Module name + form name
**Output**: Validation report

**Checks**:
- ✅ Migration validation tool (PHP) → Detects coverage gaps
- ✅ Test suite execution → Ensures tests pass
- ✅ Code quality (Pint + security) → PSR-12 compliance + no SQL injection
- ✅ Database constraints → NOT NULL field handling
- ✅ Audit logging coverage → All CRUD operations logged
- ✅ Permission implementation → Authorization policies present

**Usage**:
```bash
./scripts/adw/adw-validation.sh <MODULE> <FORM>

# Example:
./scripts/adw/adw-validation.sh PPL FrmPPL
# Output: Validation report with pass/fail status
```

### 3. adw-review.sh - Automated Code Review

**Purpose**: Quality assurance and readiness for merge
**Time**: 5-10 minutes
**Input**: Branch name
**Output**: Review verdict (APPROVE / REQUEST_CHANGES)

**Checks**:
- ✅ Static analysis (Pint formatter + PHP syntax)
- ✅ Security review (SQL injection, hardcoded credentials, auth checks)
- ✅ Test suite execution
- ✅ Migration-specific patterns (transactions, audit logs, OL configuration)
- ✅ Documentation quality (Delphi references, PHPDoc)
- ✅ AI-powered review (if Claude CLI available)

**Usage**:
```bash
./scripts/adw/adw-review.sh <BRANCH>

# Example:
./scripts/adw/adw-review.sh feature/ppl-migration
# Output: Review report with recommendations
```

## Quick Start

### First-Time Setup

```bash
# 1. Make scripts executable
chmod +x scripts/adw/*.sh

# 2. Verify PHP tools exist
ls tools/*.php
# Expected: validate_migration.php, extract_validation_rules.php, verify-migration.php

# 3. Check templates available
ls templates/*.md
# Expected: migration-spec.md, validation-check.md
```

### Run Your First Migration

```bash
# 1. Start migration pipeline
./scripts/adw/adw-migration.sh YOUR_MODULE

# 2. ADW will create in-progress files
# → migrations-registry/in-progress/YOUR_MODULE_SPEC.md

# 3. Complete the spec file (30 minutes)
# → Review Delphi code and fill in requirements
# → Check database tables and menu codes

# 4. Run ADW again to continue
./scripts/adw/adw-migration.sh YOUR_MODULE

# 5. Approve at Phase 3 gate
# → Review spec + analysis report
# → Enter 'y' to proceed with implementation

# 6. Wait for code generation (3 hours automated)

# 7. Final sign-off
# → Review tests and validation results
# → Enter 'y' for production deployment

# 8. Done!
# → Check migrations-registry/successful/
```

## Integration with Other Tools

### PHP Validation Tools

ADW automatically calls:

```bash
tools/validate_migration.php      # Gap detection (coverage analysis)
tools/extract_validation_rules.php # Rule extraction (from Delphi source)
tools/verify-migration.php        # Comprehensive verification (overall health)
```

These run automatically in Phase R (Review) - no manual execution needed.

### PITER Templates

ADW uses templates from `templates/`:

```bash
templates/migration-spec.md       # Specification form (filled during Phase P)
templates/validation-check.md     # Checklist form (reference for validation)
```

These are copied and auto-filled by ADW based on Delphi analysis.

### Knowledge Base

ADW references existing patterns:

```bash
.claude/skills/delphi-migration/
├── PATTERN-GUIDE.md              # 11 migration patterns
├── QUICK-REFERENCE.md            # Syntax quick lookup
├── KNOWLEDGE-BASE.md             # Domain knowledge
└── migrations-registry/
    └── successful/               # 5 completed migrations (reference examples)

ai_docs/lessons/                   # 12 lessons learned from past migrations
```

## Approval Gates

ADW has 2 critical approval gates where human judgment is required:

### Gate 1: Phase 3 (Before Implementation)

**Location**: After analysis, before code generation
**Duration**: 5 minutes to review
**Decision Point**: Proceed with implementation or revise spec?

**Review**:
- Spec file: Is the problem clearly defined?
- Analysis report: Are all Delphi patterns identified?
- Complexity assessment: Is it realistic?

**If you say NO**:
- ADW pauses
- Revise the spec file
- Run ADW again to re-analyze

### Gate 2: Final Sign-Off (After Implementation)

**Location**: After validation, before production deployment
**Duration**: 5 minutes to verify
**Decision Point**: Ready for production?

**Review**:
- Test results: All tests pass?
- Validation gaps: Are critical features covered?
- Code quality: Pint and security checks pass?

**If you say NO**:
- ADW suggests fixes
- Implement changes
- Re-run validation
- Approve again

## Output Files

After successful migration, ADW creates:

```bash
migrations-registry/successful/
├── MODULE_SPEC.md        # Specification (moved from in-progress)
├── MODULE_SUMMARY.md     # Auto-generated completion summary
└── MODULE_ANALYSIS.md    # Business logic analysis report

logs/adw/
└── migration_MODULE_TIMESTAMP.log  # Complete execution log (for debugging)
```

## Troubleshooting

### "Claude Code not found"

ADW tries to use `claude` CLI for AI agents (analysis + implementation).

**If Claude Code not installed**:
1. Prompts are saved to `logs/adw/*_prompt_*.txt`
2. Use prompts manually with Claude Code web interface
3. Or edit ADW scripts to use different AI tool

### "Delphi file not found"

ADW searches `d:/ykka/migrasi/pwt/` by default.

**If files in different location**:
1. Update paths in ADW script (line 25-26)
2. Or manually specify in spec file

### "Approval gate timeout" (waiting for input)

ADW waits for user input at gates with 5-minute timeout.

**If timeout occurs**:
1. Review the requested files
2. Run ADW again to resume
3. Enter 'y' or 'n' at the gate

## Comparison: ADW vs Manual

| Aspect | Manual SOP | ADW Pipeline | Savings |
|--------|-----------|-------------|---------|
| **Phase 0 validation** | 30-60 min | 5 min (automated) | 83% |
| **Spec creation** | 30 min (blank slate) | 2 min (template) | 93% |
| **File discovery** | 15 min (manual search) | 1 min (auto) | 93% |
| **Delphi analysis** | 2 hours (manual reading) | 5 min (agent) | 96% |
| **Pattern lookup** | 30 min (search docs) | 0 min (auto-loaded) | 100% |
| **Validation checks** | 45 min (manual) | 10 min (automated) | 78% |
| **Documentation** | 30 min (manual writing) | 5 min (auto-generated) | 83% |
| **Total** | **8-12 hours** | **4-6 hours** | **50-60%** |

## Success Stories

### PPL (Permintaan Pembelian - Purchase Request)
- **Complexity**: 🟡 MEDIUM
- **Time with ADW**: 4.5 hours
- **Manual estimate**: 8 hours
- **Time savings**: 44%
- **Quality**: 89/100

### ARUS_KAS (Cash Flow Management)
- **Complexity**: 🔴 COMPLEX (5 forms, cross-table logic)
- **Time with ADW**: 3.5 hours
- **Manual estimate**: 12 hours
- **Time savings**: 71%
- **Quality**: 98/100

### GROUP (Group Master Data)
- **Complexity**: 🟡 MEDIUM
- **Time with ADW**: 2.5 hours
- **Manual estimate**: 6 hours
- **Time savings**: 58%
- **Quality**: 95/100 (reference implementation)

## Next Steps

1. **Read this README** (you are here)
2. **Try with a SIMPLE module first** to learn the workflow
3. **Check detailed phase files** in `.claude/skills/delphi-migration/phases/` for step-by-step guidance
4. **Reference PATTERN-GUIDE.md** when you encounter Delphi patterns
5. **Update OBSERVATIONS.md** after each migration with lessons learned

## Key Principles

### 1. Automate What Can Be Automated
- File discovery → automatic
- Spec generation → automatic
- Code analysis → automatic agent
- Code generation → automatic agent
- Validation → automatic

### 2. Gate What Requires Judgment
- **Gate 1**: Is the spec correct and realistic? (Phase 3)
- **Gate 2**: Is the implementation production-ready? (Final)

### 3. Document Everything
- Spec → captures requirements
- Analysis → captures business logic
- Summary → captures completed work
- Registry → captures lessons for future migrations

### 4. Reuse Patterns
- 11 documented patterns avoid re-analysis
- Migration registry provides examples
- Lessons learned prevent repeating mistakes

## Dependencies

ADW requires:
- ✅ Delphi source files (.pas and .dfm)
- ✅ Laravel project (artisan command available)
- ✅ PHP tools (in `tools/` directory)
- ✅ Templates (in `templates/` directory)
- ✅ Optional: Claude Code CLI for AI agents

## Support & Feedback

**Found an issue?**
1. Check `logs/adw/migration_*.log` for detailed execution log
2. Review `.github/ISSUE_TEMPLATE/adw-feedback.md` for issue template
3. Report with context: module name, script used, error message

**Want to contribute?**
- Extend patterns in PATTERN-GUIDE.md
- Add lessons learned to ai_docs/lessons/
- Improve validation tools in tools/
- Suggest new ADW features

---

**ADW Version**: 1.0
**Last Updated**: 2026-01-12
**Framework**: PITER (Problem, Instructions, Tools, Examples, Review)
**Maintained By**: Delphi Migration Team
**Success Rate**: 100% (5/5 migrations completed)
