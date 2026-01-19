# Phase 0: Discovery & Analysis

**Purpose:** Pre-migration analysis to determine approach
**Prerequisite:** User provides .pas and .dfm files
**Output:** Migration plan document + complexity assessment
**Time:** 30-60 minutes

---

## 📍 You Are Here (Navigation)

**This File:** Phase 0 executor - **Discovery & complexity assessment**
- Validates user inputs
- Assesses module complexity (SIMPLE/MEDIUM/COMPLEX)
- Generates migration plan
- Includes real-world examples
- Provides troubleshooting guide

**Related Files in This Workflow:**
1. **[delphi-laravel-migration.md](.claude/commands/delphi-laravel-migration.md)** ← Main entry point
   - Shows overall 5-phase SOP workflow
   - Explains quality gates
   - Lists all resources and templates
   - Shows command entry point

2. **[delphi-laravel-migration-complexity-loader.md](.claude/commands/delphi-laravel-migration-complexity-loader.md)** ← Scoring engine
   - Implements complexity scoring algorithm
   - Determines which skill files to load
   - References complexity indicators below
   - Calculates token savings

**Your Role in This Phase:**
```
AI (this file):
   → Scans your .pas file (procedures, functions, logic)
   → Scans your .dfm file (components, forms, handlers)
   → Runs complexity scoring algorithm
   → Loads only needed skill files

You:
   → Provide module files
   → Review complexity assessment
   → Review migration plan
   → Approve before Phase 1 starts
```

---

## 🎯 Phase 0: Discovery & Analysis (MANDATORY)

**SEBELUM mulai coding atau planning, HARUS complete discovery ini!**

### 0.1 Pre-Flight Input Validation

**AI HARUS verify:**
- [ ] User provide .pas file path atau file content
- [ ] User provide .dfm file path atau file content (jika UI ada)
- [ ] Module name clearly specified (contoh: "FrmPenjualan", "FrmUtama")
- [ ] User expectation clear (full migration vs analysis only?)

**If any unchecked:** STOP dan minta user lengkapi input

---

### 0.2 Module Complexity Assessment

**AI WILL scan your files and determine complexity, then load only needed skill files!**

#### 🟢 SIMPLE (Express Path - 2-4 hours)
Characteristics:
- Single form CRUD
- No complex calculations
- Standard validation only
- Basic grid display
- No MyProcedure dependencies
- Examples: Customer Master, Item Master, Category

**Skill Files Loaded:**
- ✓ DELPHI_BUSINESS_LOGIC_MIGRATION.md (1,267 lines)
- ✗ Event Handler skill (skip - not needed)
- ✗ Workflow guide (skip - not needed)
- ✗ Quick Reference (skip - not needed)

**Token Savings: ~2,500 tokens (75% reduction)**

---

#### 🟡 MEDIUM (Standard Path - 4-8 hours)
Characteristics:
- Master-detail forms
- Some business logic/calculations
- Multi-step workflows
- Single/dual-level authorization
- Few MyProcedure dependencies (1-3)
- Examples: Purchase Order, Sales Invoice, Stock Transfer

**Skill Files Loaded:**
- ✓ DELPHI_BUSINESS_LOGIC_MIGRATION.md (1,267 lines)
- ✓ DELPHI_EVENT_HANDLER_MIGRATION.md (1,426 lines)
- ✗ Workflow guide (skip)
- ✗ Quick Reference (skip)

**Token Savings: ~1,500 tokens (27% reduction)**

---

#### 🔴 COMPLEX (Deep Dive - 8-12+ hours)
Characteristics:
- Multiple related forms
- Complex calculations/algorithms
- Multi-level approval workflow (3+ levels)
- Stock/inventory impacts
- Heavy MyProcedure usage (3+ functions)
- Many cross-module dependencies
- Examples: UbahKemasan, Cost Processing, Inventory Adjustment

**Skill Files Loaded:**
- ✓ DELPHI_BUSINESS_LOGIC_MIGRATION.md (1,267 lines)
- ✓ DELPHI_EVENT_HANDLER_MIGRATION.md (1,426 lines)
- ✓ MIGRATION_WORKFLOW.md (1,064 lines)
- ✓ QUICK_REFERENCE.md (715 lines)

**Token Use: Full allocation (all needed)**

---

### 🎯 How Assessment Works

**AI scans your files for:**
1. Number of lines in .pas file
2. Number of procedures/functions
3. MyProcedure dependencies count
4. Event handlers count
5. Components in .dfm file
6. Form structure (single, master-detail, multiple)
7. Presence of calculations/validations
8. Approval workflow levels

**Then calculates:**
- Complexity score (0-10)
- Appropriate skill files
- Time estimate
- Resources needed

**Then announces:**
```
"📊 Complexity: 🟢 SIMPLE
 Estimated Time: 2-4 hours
 Skill Files: Business Logic only
 Tokens Saved: ~2,500"
```

---

**Action based on complexity:**
- SIMPLE → Use EXPRESS path (Phase 0 → quick Phases 1-3)
- MEDIUM → Use STANDARD path (All phases normal pace)
- COMPLEX → Use DEEP DIVE (All phases + extra analysis)

---

### 0.3 Scan for Critical Dependencies

**MUST check untuk setiap modul:**

```bash
# 1. MyProcedure.pas dependencies
grep -i "DataBuka\|MyFindField\|Check_Nomor\|CekPeriode\|GenerateCode\|MyProcedure" [PAS_FILE]

# 2. Cross-module dependencies
grep -i "uses.*Unit\|interface.*calls\|external.*procedure" [PAS_FILE]

# 3. Database operations
grep -i "Query\|SQL\|Table\|Dataset\|Open\|Close\|Post\|Cancel" [PAS_FILE]

# 4. Special validations
grep -i "if.*then\|validate\|check\|verify\|require" [PAS_FILE]
```

**If found:** Document ALL dependencies dengan detail

---

### 0.4 Reference Similar Migrations

**Check existing migrations untuk learning:**

```bash
# Find similar module migrations
ls docs/MIGRATION_SUMMARY_*.md
ls docs/UBAHKEMASAN*.md
```

**For each similar migration:**
- Copy structure & patterns
- Adapt services to current module
- Reuse validation approaches
- Reference integration points

---

### 0.5 Create Comprehensive Migration Plan

**Output plan document ini SEBELUM generate code:**

```markdown
# [MODULE_NAME] Migration Plan
**Generated**: [DATE]
**Status**: PLANNING

## 📊 Module Assessment
- **Complexity**: [SIMPLE/MEDIUM/COMPLEX]
- **Estimated Time**: [X] hours
- **Dependencies**: [List all]
- **Similar Modules Reference**: [Link if found]

## 📁 Files to Migrate
- **Source**: [PAS file path] - [X] lines
- **UI**: [DFM file path] - [Y] components
- **Database**: [X] tables involved

## 🔍 Key Findings

### Business Logic Identified
1. Procedure [Name] - Purpose: [X] - Maps to: [Service method]
2. Function [Name] - Algorithm: [X] - Maps to: [Service method]
3. Validation [Name] - Rules: [X] - Maps to: [Validation class]

### Event Handlers Identified
1. [EventName] → [Laravel equivalent]
2. [EventName] → [Laravel equivalent]

### MyProcedure Dependencies
1. [Function] - Purpose: [X] - Laravel equiv: [Method]
2. [Function] - Purpose: [X] - Laravel equiv: [Method]
[Or: NONE - this module has no MyProcedure dependencies]

### Database Operations
- Tables: [List]
- Queries: [X] queries identified
- Transactions: [Yes/No]
- Special operations: [List]

## 🛠️ Migration Approach
- **Strategy**: [Standard/Express/Deep]
- **Tools**: [Livewire/Controller/Service]
- **Testing Strategy**: [Unit/Feature/Integration]
- **Integration Points**: [List]

## ✅ Quality Gates Checklist

### Phase 1: Analysis Complete
- [ ] All procedures identified
- [ ] All functions identified
- [ ] All events identified
- [ ] MyProcedure dependencies mapped
- [ ] Database operations documented
- [ ] Similar migrations referenced

### Phase 2: Database Ready
- [ ] Models created
- [ ] Migrations generated
- [ ] Relationships verified
- [ ] Composite keys handled (if any)

### Phase 3: Services Complete
- [ ] Service created
- [ ] All procedures converted
- [ ] All functions converted
- [ ] Tests written
- [ ] Delphi comparison data included

### Phase 4: Views/Components Complete
- [ ] All UI components mapped
- [ ] Forms created
- [ ] Modals created (if needed)
- [ ] Validation feedback working

### Phase 5: Integration Working
- [ ] Routes registered
- [ ] Controllers complete
- [ ] Request validation
- [ ] Error handling

### Phase 6: Testing Complete
- [ ] Service tests passing
- [ ] Feature tests passing
- [ ] Delphi comparison passing
- [ ] No TODOs left

### Phase 7: Documentation Complete
- [ ] Migration summary written
- [ ] Delphi source references present
- [ ] Known limitations documented
- [ ] Integration points documented

## ⚠️ Identified Risks
- Risk 1: [Description] → Mitigation: [Strategy]
- Risk 2: [Description] → Mitigation: [Strategy]

## 📝 TODO Items
[Auto-populate from analysis]
```

**PAUSE here:** Get user confirmation before proceeding to code generation!

---

### 0.6 Auto-Generated Migration Checklist

**Berdasarkan Phase 0 discovery, AI akan generate checklist ini:**

```markdown
# [MODULE_NAME] Migration Checklist
Generated: [DATE]
Complexity: [SIMPLE/MEDIUM/COMPLEX]
Estimated Time: [X] hours

## Phase 1: Analysis ✓
- [ ] [X] procedures identified
- [ ] [Y] functions identified
- [ ] [Z] event handlers identified
- [ ] MyProcedure dependencies: [COUNT or NONE]
- [ ] Database tables: [LIST]
- [ ] Similar migrations referenced: [YES/NO]

## Phase 2: Database ✓
- [ ] All models created
- [ ] [COUNT] relationships defined
- [ ] Migrations generated
- [ ] Composite keys handled: [YES/NO]

## Phase 3: Services ✓
- [ ] Service class: [NAME]
- [ ] [COUNT] methods implemented
- [ ] All procedures mapped: [YES/NO]
- [ ] Tests written: [COUNT]
- [ ] Delphi comparison data included: [YES/NO]

## Phase 4: Views ✓
- [ ] Index view created
- [ ] Form view created
- [ ] Modals created: [COUNT or NONE]
- [ ] Validation feedback: [YES/NO]

## Phase 5: Integration ✓
- [ ] [COUNT] routes registered
- [ ] Controllers complete: [YES/NO]
- [ ] Request validation: [YES/NO]
- [ ] Error handling: [YES/NO]

## Phase 6: Testing ✓
- [ ] Service tests: [COUNT]
- [ ] Feature tests: [COUNT]
- [ ] All tests passing: [YES/NO]
- [ ] Delphi comparison passing: [YES/NO]

## Phase 7: Documentation ✓
- [ ] Migration summary: [YES/NO]
- [ ] Business logic documented: [YES/NO]
- [ ] Known limitations: [YES/NO]
- [ ] Integration points: [YES/NO]

## Outstanding Items
[Auto-list any unchecked items]

## Next Actions
1. [First priority]
2. [Second priority]
3. [Third priority]

## Final Sign-Off
- [ ] All phases complete
- [ ] Ready for production deployment
- Deployed: [DATE]
```

**This checklist:**
- ✓ Auto-generated berdasarkan module complexity
- ✓ Tracks completion per phase
- ✓ Identifies outstanding items
- ✓ Provides next actions
- ✓ Used untuk progress tracking & sign-off

---

## 📋 Pre-Migration Checklist

Sebelum mulai, pastikan Anda punya:
- [ ] File .pas (Pascal source code)
- [ ] File .dfm (Form definitions)
- [ ] Database schema/structure
- [ ] List business rules
- [ ] Sample data untuk testing

---

## 🔧 How to Use Phase 0

**For Developers:**
1. Provide .pas file(s) to be migrated
2. I'll perform discovery (scan dependencies, assess complexity)
3. I'll create migration plan document
4. You review & approve plan before code generation

**For AI:**
1. Read .pas files
2. Identify: procedures, functions, events, dependencies
3. Assess complexity (SIMPLE/MEDIUM/COMPLEX)
4. Generate migration plan
5. Output: Migration checklist + approach decision

---

**Phase 0 Output:**
- ✅ Complexity assessment
- ✅ Migration plan document
- ✅ Quality gates checklist
- ✅ Risk identification
- ✅ Skill files to load (based on complexity)

---

**Next Step:** After Phase 0 approval → Load appropriate skill files → Execute Phases 1-7

---

## 📚 Completed Migrations Reference

**Use these real migrations as patterns for your module:**

### SIMPLE Pattern: Area Master
- **Complexity:** 🟢 SIMPLE
- **Time:** 2-4 hours
- **See:** `app/Http/Controllers/AreaController.php`
- **Pattern:** Single controller + service + resource routes
- **What to Learn:** Basic CRUD patterns, simple migrations

### COMPLEX Pattern: SPK Module (Surat Perintah Kerja)
- **Complexity:** 🔴 COMPLEX (9.5 hours actual)
- **Time:** 8-12+ hours
- **See:** `SPK_MIGRATION_SUMMARY.md`
- **Pattern:** Master-detail + 5-level approval + comprehensive tests
- **What to Learn:**
  - Multi-table migrations
  - Complex business logic
  - Approval workflow patterns
  - Complete test coverage

### COMPLEX Pattern: Produksi (In Progress)
- **Complexity:** 🔴 COMPLEX
- **Time:** 8-12+ hours estimated
- **See:** `docs/PRODUKSI_MIGRATION_COMPLETION_REPORT.md`
- **Pattern:** Multiple forms + calculation logic + deep dependencies
- **What to Learn:**
  - MyProcedure dependency handling
  - Complex calculation patterns
  - Multi-form integration

**Why Study These Examples:**
- Real time estimates from actual migrations
- Pattern recognition for your module
- Clear expectations for your complexity level
- Confidence that others have succeeded

---

## ⚠️ Troubleshooting: Common Issues & Solutions

### Issue 1: "Cannot find .pas file"

**Error message:**
```
❌ Phase 0 Pre-Flight Failed
Cannot read file: D:\delphi\module.pas
File may not exist or is not accessible
```

**Solutions:**
1. ✅ Check file path spelling (D:\ vs d:\)
2. ✅ Verify file exists using file explorer
3. ✅ Ensure file is readable (not locked by another program)
4. ✅ Try using absolute full path: `D:\delphi\modules\Module.pas`
5. ✅ Or paste file content directly if path has special characters

**Prevention:**
- Use backslash \ not forward slash /
- Use absolute paths, not relative paths
- Test path by opening file in editor first

---

### Issue 2: "Incomplete input - missing .dfm file"

**Error message:**
```
❌ Phase 0 Pre-Flight Check Failed
Provided: Module.pas
Missing: .dfm file (form definition)
```

**Solutions:**
1. ✅ If module has UI, provide BOTH .pas and .dfm:
   ```bash
   /delphi-laravel-migration "Module.pas Module.dfm"
   ```
2. ✅ If module is business logic only (no UI), just provide .pas:
   ```bash
   /delphi-laravel-migration "Module.pas"
   ```
3. ✅ Check if .dfm file exists (same name as .pas, different extension)

**Prevention:**
- Know if your module has UI or is business logic only
- Have both files ready before starting
- Verify .dfm exists if module has forms

---

### Issue 3: "Complexity assessment failed"

**Error message:**
```
❌ Phase 0 Analysis Failed
Could not assess complexity
File may be corrupted or not valid Delphi code
```

**Solutions:**
1. ✅ Verify file contains valid Delphi code (not binary or corrupted)
2. ✅ Check file is not empty or too large (>10,000 lines)
3. ✅ Ensure proper Delphi syntax (no merge conflicts in code)
4. ✅ Try with simpler file first to test process
5. ✅ Paste file content directly instead of providing path

**Prevention:**
- Test file by opening in Delphi IDE first
- Ensure no merge conflict markers (<<<<<, >>>>>)
- File should be readable text format

---

### Issue 4: "Complexity mismatch - I assessed COMPLEX, you expected SIMPLE"

**What this means:**
```
Scenario: You said your module is SIMPLE
AI Assessment: This is actually COMPLEX
- 12 procedures (not 1-2)
- 6 MyProcedure dependencies (not 0)
- Multi-level approval workflow (not simple CRUD)
- 45+ components (not <20)

Recommendation: Plan for COMPLEX (8-12 hours, not 2-4)
Proceed? Y/N
```

**How to handle:**
1. ✅ **Accept the assessment** - AI has scanned your code
   - It found complexity indicators you may have missed
   - Better to overestimate than underestimate
   - You still proceed with Phases 1-5

2. ✅ **Understand the difference:**
   - SIMPLE: Basic CRUD, no complex logic
   - COMPLEX: Your module has advanced features

3. ✅ **Plan accordingly:**
   - Budget 8-12 hours (not 2-4)
   - Load all skill files (not just business logic)
   - More testing required

**Prevention:**
- Be honest about module complexity upfront
- Count procedures, functions, event handlers
- Check for MyProcedure dependencies yourself

---

### Issue 5: "Phase 0 taking too long (>60 minutes)"

**What this means:**
```
Phase 0 has been running for 60+ minutes
This is unusual - something may be stuck
```

**Solutions:**
1. ✅ **Large files (>1000 lines):** Can take 60+ min for scanning
   - This is normal for COMPLEX modules
   - Wait a bit longer (90+ minutes possible)

2. ✅ **Stuck process:** If taking 2+ hours:
   - Kill the process and restart
   - Try with smaller file (test file first)
   - Paste file content instead of using path

3. ✅ **Memory issue:** If system slow:
   - Close other programs
   - Restart terminal/IDE
   - Try again

**Prevention:**
- Expect 30-60 minutes for COMPLEX modules
- SIMPLE modules should be <15 minutes
- If unexpected delay, it's safe to restart

---

### Issue 6: "Phase 3 plan seems too long (100+ tasks)"

**What this means:**
```
Phase 3 generated migration plan with 100+ tasks
This seems overwhelming for your module
```

**How to handle:**
1. ✅ **This is normal for COMPLEX modules:**
   - 100+ tasks = ~8-12 hours work (as expected)
   - Tasks are granular (easier to track)
   - You approve entire plan, not individual tasks

2. ✅ **Review and understand:**
   - Read all task descriptions
   - Understand dependencies
   - Identify any missing pieces

3. ✅ **Approve if satisfied:**
   - If plan makes sense, approve
   - If missing something, request adjustments
   - Don't proceed until satisfied

**Prevention:**
- Set expectations: COMPLEX = 100+ tasks
- Review similar migrations (SPK had 100+ tasks)
- Plan time to review plan carefully

---

### Issue 7: "Tests failing - output doesn't match Delphi"

**Error message:**
```
❌ Test Failed: Phase 4 Implementation
Test: calculateTotal()
Expected (Delphi): 1,500.00
Got (Laravel): 1,500.50
Difference: 0.50 (rounding error)
```

**How to handle:**
1. ✅ **Find the issue:**
   - Read test failure carefully
   - Compare Delphi calculation with Laravel
   - Check for rounding, data type, or logic differences

2. ✅ **Fix the code:**
   - Adjust Laravel code to match Delphi exactly
   - Test again
   - Repeat until output matches

3. ✅ **If very hard to fix:**
   - Document why Delphi behavior is different
   - Request permission to use "better" calculation
   - Or match Delphi exactly (preferred)

**Prevention:**
- Include Delphi output in tests
- Test with real Delphi sample data
- Match output exactly, don't improve

---

### Issue 8: "Authorization/Permission error during Phase 4"

**Error message:**
```
❌ Cannot write files
Permission denied: app/Services/MyService.php
Check file permissions
```

**Solutions:**
1. ✅ Check file permissions:
   - Use: `ls -la app/Services/`
   - Files should be readable/writable

2. ✅ Fix permissions:
   - `chmod 755 app/Services/`
   - Or: File Properties → Security → Full Control

3. ✅ Run with admin/sudo (if needed):
   - macOS/Linux: `sudo php artisan serve`
   - Windows: Run as Administrator

**Prevention:**
- Ensure Laravel directory is writable
- Run IDE/terminal as administrator
- Check before starting Phase 4

---

**Still having issues?**
- Check GitHub issues: `docs/QUICK_REFERENCE.md`
- Review similar completed migrations
- Ask for help in Phase 0 review
