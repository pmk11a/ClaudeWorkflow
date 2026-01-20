# ADW Architecture & Integration Map

**Document**: ADW-ARCHITECTURE.md
**Version**: 2.1 (Hybrid Tools + Agent)
**Last Updated**: 2026-01-15
**Status**: 🟢 Active

## Complete System Overview

**ADW v2.1** integrates 5 layers with **Python tools** for parsing/generation + **AI agents** for review/gap-filling:

```
┌─────────────────────────────────────────────────────┐
│  User                                               │
│  ./scripts/adw/adw-migration.sh <MODULE>            │
└────────────────┬────────────────────────────────────┘
                 │
        ┌────────▼────────┐
        │ ADW Orchestrator│  (bash scripts)
        │ ─────────────────│
        │ • adw-migration │
        │ • adw-validation│
        │ • adw-review    │
        └────────┬────────┘
                 │
    ┌────────────┼────────────┐
    │            │            │
┌───▼────┐  ┌───▼─────┐  ┌───▼────┐
│ Tools  │  │ Agents  │  │Resource│
├────────┤  ├─────────┤  ├────────┤
│PYTHON: │  │Analysis │  │Pattern │
│parser  │  │ (LIGHT) │  │Registry│
│dfm_par │  │         │  │Lessons │
│        │  │Review   │  │Templat.│
│GEN:    │  │ Agent   │  │Command.│
│contrl  │  │(FILLS   │  │        │
│service │  │ GAPS)   │  │        │
│request │  │         │  │        │
│policy  │  │         │  │        │
│model   │  │         │  │        │
│view    │  │         │  │        │
│test    │  │         │  │        │
│        │  │         │  │        │
│PHP:    │  │         │  │        │
│validat.│  │         │  │        │
└────────┘  └─────────┘  └────────┘
```

**Key Change (v2.1)**: Tools now do 80% of work (parsing + generation), agents do 20% (review + gaps)

## Component Layers (Bottom-Up)

### Layer 1: Knowledge Base (Persistent)

**Location**: `.claude/skills/delphi-migration/` + `ai_docs/lessons/`

**Contents**:
```
Patterns (11 total)
├── 1. Mode Operations (I/U/D)
├── 2. Permission Checks
├── 3. Field Dependencies
├── 4. Validation Rules
├── 5. Authorization Workflow
├── 6. Audit Logging
├── 7. Master-Detail Forms
├── 8. Lookup & Search
├── 9. Composite Keys
├── 10. Mixed Data Access (SP + SQL)
└── 11. Missing Audit Logs

Migration Registry (5 completed)
├── PPL (4.5h, 89/100)
├── GROUP (2.5h, 95/100)
├── ARUS_KAS (3.5h, 98/100)
├── PO (3.5h, 93/100)
└── PB (8h, 88/100)

Lessons Learned (12 documents)
├── Lock period validation
├── Authorization nulls constraint
├── Composite key patterns
├── Multi-level authorization
└── ... (8 more lessons)
```

**Used By**: Agents (to understand patterns) + Humans (to learn)
**Updated**: After each migration with new lessons

### Layer 2: Tools (Validation)

**Location**: `tools/`

**Tools**:
```
validate_migration.php
├── Input: Module name + Form name
├── Process: Analyzes Delphi source + Laravel code
└── Output: Coverage gaps report

extract_validation_rules.php
├── Input: Delphi .pas file
├── Process: Parses validation logic
└── Output: List of rules found

verify-migration.php
├── Input: Module name
├── Process: Comprehensive verification
└── Output: Pass/fail status + recommendations
```

**Used By**: ADW validation pipeline (Phase R)
**Invoked By**: adw-validation.sh

### Layer 3: Templates (Specification)

**Location**: `templates/`

**Templates**:
```
migration-spec.md
├── P: Problem (module overview, source files)
├── I: Instructions (requirements, mode operations)
├── T: Tools (database, API endpoints)
├── E: Examples (similar migrations, lessons)
└── R: Review (acceptance criteria, sign-off)

validation-check.md
├── Functionality checklist
├── Code quality checklist
├── Security checklist
└── Authorization checklist
```

**Used By**: adw-migration.sh (Phase P) to create structured specs
**Output**: Filled-in spec files for user review

### Layer 4: Agents (Intelligence)

**Location**: Invoked via `claude` CLI commands

**Agents**:
```
Analysis Agent (Phase I)
├── Reads: Delphi .pas file + Spec
├── Analyzes: Business logic, procedures, validations
└── Produces: Analysis report

Implementation Agent (Phase 4)
├── Reads: Spec + Analysis + Patterns
├── Generates: Models, services, controllers, views, tests
└── Produces: Complete Laravel code

Review Agent (Phase R, optional)
├── Reads: Generated code + Tests
├── Evaluates: Quality, patterns, completeness
└── Produces: Review verdict (APPROVE / REQUEST_CHANGES)
```

**Used By**: ADW orchestrator
**Integration**: Via Claude Code CLI (`claude` command)

### Layer 5: Orchestrator (Automation)

**Location**: `scripts/adw/*.sh`

**Scripts**:
```
adw-migration.sh
├── Phase 0: Discovery (find files)
├── Phase P: Problem (create spec)
├── Phase I: Instructions (analyze)
├── Phase T: Tools (check existing)
├── Phase E: Examples (load patterns)
├── Gate 1: User approval
├── Phase 4: Implement (generate code)
├── Phase R: Review (validate)
├── Gate 2: Final sign-off
└── Outputs: Registry entry + Summary

adw-validation.sh
├── Run validation tool
├── Run test suite
├── Code quality checks
├── Security review
└── Generate report

adw-review.sh
├── Static analysis
├── Security check
├── Tests execution
├── Pattern verification
└── AI review (optional)
```

**Role**: Coordinates workflow between tools, agents, and user
**User Interaction**: 2 approval gates where human judgment is applied

## Data Flow (PITER Framework)

```
┌─────────────┐
│   START     │
│ Phase 0:    │
│ Discovery   │  Auto-discover Delphi files
└──────┬──────┘
       │
       ▼
┌─────────────────────────────┐
│ P: PROBLEM                  │  User fills specification
│ (Spec creation from template) │
│ → migrations-registry/in-   │
│   progress/MODULE_SPEC.md   │
└──────┬──────────────────────┘
       │
       ▼
┌─────────────────────────────┐
│ I: INSTRUCTIONS             │  Analysis agent extracts
│ (Analysis & extraction)     │  business logic from Delphi
│ → migrations-registry/in-   │
│   progress/MODULE_ANALYSIS  │
└──────┬──────────────────────┘
       │
       ▼
┌─────────────────────────────┐
│ T: TOOLS                    │  Check existing Laravel code
│ (Existing code check)       │  Load completed migrations
└──────┬──────────────────────┘
       │
       ▼
┌─────────────────────────────┐
│ E: EXAMPLES                 │  Load similar patterns
│ (Pattern & lesson loading)  │  from registry & lessons
└──────┬──────────────────────┘
       │
       ▼
┌──────────────────────────────┐
│ 🚨 APPROVAL GATE 1            │  User reviews spec
│ "Proceed with implementation?"│  + analysis report
└──────┬─────────────────────────┘
       │
       NO ───────────┐
       │             │ Revise spec
       YES           │
       │             ▼
       │        (back to P)
       │
       ▼
┌─────────────────────────────┐
│ Phase 4: IMPLEMENT          │  Implementation agent
│ (Code generation via Claude)│  generates all Laravel code
│ → app/Models/Db*.php        │
│ → app/Services/*.php        │
│ → app/Http/Controllers/*.php│
│ → app/Http/Requests/*.php   │
│ → app/Policies/*.php        │
│ → resources/views/*.blade   │
│ → tests/Feature/*.php       │
└──────┬──────────────────────┘
       │
       ▼
┌─────────────────────────────┐
│ R: REVIEW                   │  Run validation tools
│ (Validation pipeline)       │  Run tests
│ • validate_migration.php    │  Code quality checks
│ • Test suite                │  Security review
│ • Pint + Security check     │
│ → Validation report         │
└──────┬──────────────────────┘
       │
       ▼
┌──────────────────────────────┐
│ 🚨 FINAL SIGN-OFF            │  User reviews results
│ "Production ready?"          │  Tests pass?
└──────┬─────────────────────────┘
       │
       NO ───────────┐
       │             │ Fix issues
       YES           │
       │             ▼
       │        (back to Phase 4)
       │
       ▼
┌─────────────────────────────┐
│ SUCCESS                     │
│ → migrations-registry/      │
│   successful/MODULE_*.md    │
│ → logs/adw/migration_*.log  │
└─────────────────────────────┘
```

## Integration Points

### 1. PITER Framework Integration

Each ADW phase maps to PITER:

```
P - PROBLEM      → Template (migration-spec.md)
I - INSTRUCTIONS → Agent (analysis) + Parser (delphi code)
T - TOOLS        → Tools directory (validation scripts)
E - EXAMPLES     → Registry + Lessons directories
R - REVIEW       → Validation pipeline + adw-review.sh
```

### 2. Approval Gate Integration

ADW implements 2 gates for human judgment:

```
Gate 1 (Phase 3): Approve implementation plan?
│
├─→ YES: Proceed to code generation
└─→ NO: Revise specification, re-run analysis

Gate 2 (Final): Production ready?
│
├─→ YES: Deploy to production
└─→ NO: Fix issues, re-run validation
```

### 3. Phase File Integration

ADW phases align with SOP phases:

```
Phase 0:       Discovery (auto)
Phases 1-3:    PITER framework + Gate 1 (user approval)
Phase 4:       Implementation (agent + tests)
Phase 5:       Review + Gate 2 (user sign-off)
```

### 4. Knowledge Base Integration

Before generating code, ADW loads:

```
PATTERN-GUIDE.md         → Identifies applicable patterns
migrations-registry/     → References similar implementations
ai_docs/lessons/         → Prevents past mistakes
QUICK-REFERENCE.md       → Provides syntax examples
```

## Usage Patterns

### Pattern A: First Migration (Discovery)

```
User: ./scripts/adw/adw-migration.sh PPL

ADW:
1. Discovers PPL.pas files
2. Creates spec template
3. PAUSES for user to complete spec
4. Runs analysis (2h reading time avoided)
5. Gate 1: User approves
6. Generates all code (3h automation)
7. Runs validation (1h testing time avoided)
8. Gate 2: User signs off
9. Creates registry entry

Result: 4.5 hours (vs 8-10 hours manual)
```

### Pattern B: Similar Module (Pattern Reuse)

```
User: ./scripts/adw/adw-migration.sh PO

ADW:
1. Discovers PO files
2. Creates spec (uses PPL as reference from registry)
3. Runs analysis (similar patterns detected)
4. Gate 1: User approves (30 min vs 2 hours)
5. Generates code (reuses PPL patterns)
6. Runs validation
7. Gate 2: User signs off

Result: 3.5 hours (44% savings via pattern reuse)
```

### Pattern C: Complex Module (Careful Review)

```
User: ./scripts/adw/adw-migration.sh ARUS_KAS

ADW:
1. Discovers ARUS_KAS files (5 forms)
2. Creates detailed spec
3. Analyzes cross-module logic
4. Gate 1: Extra time for complex spec review
5. Generates code (with composite key patterns)
6. Runs comprehensive validation
7. Reports 2 minor gaps
8. Gate 2: User fixes gaps + re-validates
9. Creates registry entry + lessons

Result: 3.5 hours total (71% savings despite complexity)
```

## Performance Characteristics

### Time Distribution (4-6 hour migration)

```
Phase 0 (Discovery):      2 min   (0.6%)  ← automated
Phase P (Spec):          30 min   (8%)    ← user input
Phase I (Analysis):       5 min   (1%)    ← automated
Phase T (Tools):          2 min   (0.5%)  ← automated
Phase E (Examples):       3 min   (1%)    ← automated
Gate 1 (Approval):        5 min   (1%)    ← user review
Phase 4 (Implement):    180 min   (77%)   ← AI automation
Phase R (Review):        10 min   (2%)    ← automated
Gate 2 (Sign-off):        5 min   (1%)    ← user review
─────────────────────────────────────────
TOTAL:               ~4.5 hours

vs. Manual SOP:       8-12 hours (50-60% savings)
```

### Scaling Characteristics

```
1st migration:    6 hours  (learning curve)
2nd migration:    4.5 hours (pattern reuse begins)
3rd+ migration:   3.5 hours (optimized patterns)

5-migration average: 4.5 hours (57% time savings proven)
```

## Extensibility

### Adding a New Validation Tool

```
1. Create: tools/my_validator.php
2. Update: adw-validation.sh
   Add: php tools/my_validator.php "$MODULE"
3. Result: Auto-runs in Phase R
```

### Adding a New Pattern

```
1. Document: PATTERN-GUIDE.md (with example)
2. Update: OBSERVATIONS.md (after discovering)
3. Result: Available to all future migrations
```

### Adding a New Agent

```
1. Create: Agent prompt in ADW script
2. Update: Call via claude CLI if available
3. Fallback: Save prompt for manual execution
4. Result: Extended automation
```

## Failure Scenarios & Recovery

### Scenario: Analysis Agent Not Available

```
If `claude` CLI not found:
├─→ Prompts saved to logs/adw/*_prompt_*.txt
├─→ User runs manually via Claude Code web
├─→ Paste results into ADW workflow
└─→ Migration continues
```

### Scenario: Delphi Files Not Found

```
If files not discovered:
├─→ ADW shows search locations
├─→ User updates paths in ADW script
├─→ Re-run ADW
└─→ Discovery succeeds
```

### Scenario: Validation Gaps

```
If validation finds gaps:
├─→ ADW generates gap report
├─→ User implements fixes
├─→ ADW re-validates
├─→ If all fixed: Gate 2 approval
└─→ Otherwise: Back to Phase 4
```

## Monitoring & Metrics

### Success Metrics (Tracked)

```
Time per migration        (target: 4-6h)
Quality score             (target: 88-98/100)
Test failures             (target: 0)
Validation gaps           (target: < 5%)
User approval time        (target: < 15 min)
ADW adoption rate         (target: 80%+)
```

### Logging

```
logs/adw/migration_MODULE_TIMESTAMP.log
├─ All ADW outputs (discovery, analysis, validation)
├─ Agent interactions (if available)
├─ Test results
├─ Validation reports
└─ Timestamps for performance tracking
```

---

**Architecture Document**: ADW-ARCHITECTURE.md
**Version**: 1.0
**Last Updated**: 2026-01-12
**Integration Level**: Complete - All 5 layers connected and operational
