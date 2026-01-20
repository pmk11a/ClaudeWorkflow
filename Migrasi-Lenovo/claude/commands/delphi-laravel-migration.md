# Migrate Delphi to Laravel - Standard Operating Procedure

---

## 🚀 **RECOMMENDED: Use ADW (AI Developer Workflows)**

**For fastest, most reliable migrations:**
```bash
./scripts/adw/adw-migration.sh <MODULE>
```

**ADW Benefits:**
- ⚡ **50-60% faster** than manual (4.5h vs 8-12h)
- 🎯 **Automated** discovery, analysis, planning, code generation
- ✅ **88-98/100 quality** score (proven across 5+ migrations)
- 🚨 Approval gates at Phase 3 & 5 (you maintain control)

**See:** [scripts/adw/README.md](../../scripts/adw/README.md) + [WALKTHROUGH.md](../../scripts/adw/WALKTHROUGH.md)

**Or read below for manual SOP (fallback if ADW unavailable)**

---

**Purpose:** Migrate Delphi 6 module (.pas, .dfm) to Laravel 10.x using 5-phase SOP
**Input:** Module name or file paths
**Output:** Complete Laravel module with tests & documentation
**Time:** 2-20 hours (depends on complexity) | **4-6 hours with ADW**

**📋 Manual SOP (Fallback):** Using formal **DELPHI-MIGRATION-SOP** with 5 phases

---

## 📍 You Are Here (Navigation)

**This File:** Main entry point - **5-phase SOP workflow overview**
- Shows how the command works
- Explains phases and quality gates
- Lists resources and requirements
- Shows real-world examples

**Related Files in This Workflow:**
1. **[delphi-laravel-migration-discovery.md](.claude/commands/delphi-laravel-migration-discovery.md)** ← Phase 0 executor
   - Performs complexity assessment
   - Validates inputs
   - Generates migration plan
   - Includes troubleshooting guide

2. **[delphi-laravel-migration-complexity-loader.md](.claude/commands/delphi-laravel-migration-complexity-loader.md)** ← Intelligence engine
   - Scores module complexity
   - Determines skill files to load
   - Calculates token savings
   - Analyzes patterns

**How They Work Together:**
```
User runs: /delphi-laravel-migration "Module.pas Module.dfm"
   ↓
This file (Main) displays welcome
   ↓
Discovery file (Phase 0) runs assessment
   ↓
Complexity Loader (Engine) calculates score
   ↓
Discovery file shows plan
   ↓
User reviews & approves
   ↓
Phases 1-5 execute (per this file's SOP)
```

---

## 🔄 How This Command Works

**When you run:** `/delphi-laravel-migration "Module.pas Module.dfm"`

**What happens:**

```
Step 1: Load & Display This File
   ↓ Welcome + Quick Start shown
   ↓
Step 2: Execute Phase 0 (Discovery)
   ↓ Validate input files
   ↓ Scan for complexity (SIMPLE/MEDIUM/COMPLEX)
   ↓ Load right skill files (based on complexity)
   ↓ Generate migration plan
   ↓
Step 3: You Review & Approve Plan
   ↓ Review Phase 0 assessment
   ↓ Approve or request changes
   ↓
Step 4: Execute SOP Phases 1-5 (11-18 hours)
   ↓ Phase 1: ANALYZE (2-3h) - Understanding Delphi code
   ↓ Phase 2: CHECK EXISTING (1-2h) - Avoid duplicate work
   ↓ Phase 3: PLAN (1-2h) → 🚨 GET YOUR APPROVAL
   ↓ Phase 4: IMPLEMENT (4-6h) - Write code
   ↓ Phase 5: TEST & DOCUMENT (3-5h) → 🚨 GET YOUR SIGN-OFF
   ↓
Step 5: DONE! Ready for production deployment
```

**You'll be involved at:**
- ✋ Initial command (provide files)
- ✋ Phase 0 review (complexity assessment)
- ✋ Phase 3 approval (critical gate - before coding)
- ✋ Phase 5 sign-off (critical gate - final approval)

**AI handles automatically:**
- ✅ File scanning and analysis
- ✅ Complexity assessment
- ✅ Skill file loading
- ✅ Code generation
- ✅ Test execution

---

## 📖 REQUIRED READING FIRST

**Before starting ANY migration:**
1. Read: `docs/DELPHI_MIGRATION_SOP.md` (20 minutes)
   - 5-phase workflow: ANALYZE → CHECK → PLAN → IMPLEMENT → TEST
   - 5 critical rules to prevent mistakes
   - Examples and best practices

2. Understand: `docs/SOP_SETUP_COMPLETE.md` (10 minutes)
   - Available templates for each phase
   - How to use the SOP system

**These ensure you avoid duplicate work and follow best practices!**

---

## ⚡ Quick Start (5 Phases - SOP Workflow)

**Phase 1: ANALYZE** (2-3 hours)
- Read Delphi source code (.pas, .dfm)
- Document procedures, variables, database tables
- Use: `docs/templates/delphi_analysis_template.md`
- Output: Analysis report with all findings

**Phase 2: CHECK EXISTING** (1-2 hours)
- Search for existing Laravel implementation
- Document what's already there
- Identify gaps and overlaps
- Output: Existing component inventory

**Phase 3: PLAN** (1-2 hours)
- Create detailed migration plan
- Combine ANALYZE + CHECK findings
- Estimate effort and timeline
- Use: `docs/templates/migration_plan_template.md`
- **Get user approval via ExitPlanMode** (CRITICAL!)

**Phase 4: IMPLEMENT** (4-6 hours)
- Only after user approval!
- Write code based on plan
- Reference skill files for patterns
- Add Delphi source references in comments

**Phase 5: TEST & DOCUMENT** (3-5 hours)
- Execute tests: use `docs/templates/test_checklist_template.md`
- Create API docs: use `docs/templates/api_doc_template.md`
- Get final user approval

---

## 🚨 CRITICAL: Database Safety Rules

**⚠️ Read the complete safety guidelines before starting:**

**→ See: [`docs/DATABASE_SAFETY.md`](../docs/DATABASE_SAFETY.md) for detailed rules and checklist**

Quick summary:
- ❌ NEVER use: `php artisan migrate:fresh` or `migrate:reset` (deletes all data!)
- ❌ NEVER create tables without user confirmation
- ❌ NEVER modify database directly (always use migrations)
- ✅ ALWAYS create backups before production migrations
- ✅ ALWAYS test migrations in development first

---

## 📋 CRITICAL MIGRATION CHECKLIST (TIDAK BOLEH SKIP!)

**SEBELUM SETIAP MIGRATION, LAKUKAN CHECKLIST INI:**

### Phase 0: Pre-Flight Checks
- [ ] Module name & files confirmed
- [ ] Delphi files found & readable
- [ ] Complexity assessed (SIMPLE/MEDIUM/COMPLEX)
- [ ] Time estimate understood
- [ ] Database safety rules reviewed
- [ ] User ready to proceed

### ⚠️ Database Rules WAJIB Diikuti
- [ ] **❌ JANGAN** gunakan `php artisan migrate:fresh` (HAPUS SEMUA DATA!)
- [ ] **❌ JANGAN** gunakan `php artisan migrate:reset` (HAPUS SEMUA DATA!)
- [ ] **❌ JANGAN** buat table baru tanpa konfirmasi user
- [ ] **❌ JANGAN** modify database langsung (gunakan migrations + eloquent)
- [ ] **✅ GUNAKAN** `php artisan migrate` (safe, normal)
- [ ] **✅ GUNAKAN** `php artisan migrate:rollback` (safe, bisa reverse)

### Phase 1: Analyze Delphi Code
- [ ] Baca SEMUA file .pas dan .dfm
- [ ] Identifikasi SEMUA procedures/functions (dengan line numbers)
- [ ] Identifikasi SEMUA event handlers
- [ ] Scan MyProcedure.pas untuk dependencies
- [ ] Identifikasi SEMUA tabel database yang digunakan
- [ ] Document SEMUA logic & business rules
- [ ] Create analysis report 800+ lines

### Phase 2: Check Existing Laravel
- [ ] Search existing models untuk tabel yang akan digunakan
- [ ] **JANGAN BUAT TABLE BARU** - gunakan existing atau confirm dulu!
- [ ] Inventory existing Laravel components
- [ ] Identify gaps vs Delphi
- [ ] Document potential conflicts
- [ ] Create check report

### Phase 3: Plan Migration
- [ ] Create detailed migration plan dengan approved template
- [ ] Estimate time untuk setiap component
- [ ] Identifikasi dependencies
- [ ] Define quality gates
- [ ] **MINTA USER APPROVAL** sebelum Phase 4!

### Phase 4: Implement Code
- [ ] **Hanya setelah user approval Phase 3!**
- [ ] Single table → Gunakan **Eloquent ORM**
- [ ] Multiple table → Gunakan **raw query dengan parameter binding**
- [ ] Queries harus readable di TadoQuery Delphi
- [ ] Add Delphi source references di comments
- [ ] Write comprehensive tests
- [ ] Follow PSR-12 code standards

### Phase 5: Test & Validate
- [ ] Run ALL tests (harus 100% passing)
- [ ] Delphi output MUST match exactly
- [ ] Test edge cases & error conditions
- [ ] Manual testing completed
- [ ] API documentation complete
- [ ] **MINTA USER SIGN-OFF** sebelum production!

### Post-Migration Cleanup
- [ ] Delete temporary files (*.tmp, *.bak)
- [ ] Remove file `NUL` (jika ada)
- [ ] Verify `git status` (no unwanted files)
- [ ] Commit changes with proper message
- [ ] Update documentation

---

## 🔍 Database Access Pattern Checklist

**When accessing database, ALWAYS check:**

### ✅ For SINGLE table query:
```php
// ✅ BOLEH: Gunakan Eloquent
$data = DbBARANG::where('KodeBrg', $id)->first();
$list = DbBARANG::all();
```

### ✅ For MULTIPLE table query:
```php
// ✅ BOLEH: Gunakan raw query dengan parameter binding
$results = DB::select('
    SELECT b.*, s.QntSaldo
    FROM db_barng b
    JOIN db_stok s ON b.KodeBrg = s.KodeBrg
    WHERE b.KodeBrg = ?', [$id]
);

// ✅ BOLEH: Named binding (lebih aman)
$results = DB::select('
    SELECT b.*, s.QntSaldo
    FROM db_barng b
    JOIN db_stok s ON b.KodeBrg = s.KodeBrg
    WHERE b.KodeBrg = :id', ['id' => $id]
);
```

### ❌ TIDAK BOLEH: String concatenation
```php
// ❌ TIDAK BOLEH: SQL Injection risk!
$id = request('id');
DB::select("SELECT * FROM db_barng WHERE KodeBrg = '$id'");
```

### ❌ TIDAK BOLEH: Table baru tanpa konfirmasi
```php
// ❌ TIDAK BOLEH: Assume table exists
Schema::create('new_table', function() { ... });

// ✅ HARUS: Check dulu, confirm sama user
if (!Schema::hasTable('db_stok_baru')) {
    throw new Exception("Table 'db_stok_baru' tidak ada. Hubungi admin!");
}
```

---

## 📚 Resources by Module Complexity

### 🟢 SIMPLE (2-4 hours)
**Load skill files:**
- DELPHI_BUSINESS_LOGIC_MIGRATION.md (1,267 lines)

**Focus:**
- Single form, basic CRUD
- Standard validations
- Simple calculations
- No complex dependencies

**Example:** Area, Customer, Item Master

---

### 🟡 MEDIUM (4-8 hours)
**Load skill files:**
- DELPHI_BUSINESS_LOGIC_MIGRATION.md
- DELPHI_EVENT_HANDLER_MIGRATION.md (1,426 lines)

**Focus:**
- Master-detail forms
- Some business rules
- Standard calculations
- Single-dual level approval

**Example:** Purchase Order, Sales Invoice

---

### 🔴 COMPLEX (8-12+ hours)
**Load skill files:**
- DELPHI_BUSINESS_LOGIC_MIGRATION.md
- DELPHI_EVENT_HANDLER_MIGRATION.md
- MIGRATION_WORKFLOW.md (1,064 lines)
- QUICK_REFERENCE.md (715 lines)

**Focus:**
- Multiple related forms
- Complex algorithms
- Multi-level approval (3+)
- Stock/inventory impact
- Heavy dependencies

**Example:** Produksi, SPK, UbahKemasan

---

## 📚 Resource Files (Loaded Based on Complexity)

**For SIMPLE modules:** Load 1 file
- [DELPHI_BUSINESS_LOGIC_MIGRATION.md](../docs/DELPHI_BUSINESS_LOGIC_MIGRATION.md) (1,267 lines)

**For MEDIUM modules:** Load 2 files
- Above + [DELPHI_EVENT_HANDLER_MIGRATION.md](../docs/DELPHI_EVENT_HANDLER_MIGRATION.md) (1,426 lines)

**For COMPLEX modules:** Load ALL 4 files
- Above + [MIGRATION_WORKFLOW.md](../docs/03_Migration_Guide/MIGRATION_WORKFLOW.md) (1,064 lines)
- + [QUICK_REFERENCE.md](../docs/QUICK_REFERENCE.md) (715 lines)

---

## 🎯 5-Phase SOP Workflow

Each phase is mandatory with quality gates:

| Phase | Focus | Time | Output | Critical Gate |
|-------|-------|------|--------|---|
| **1** | ANALYZE Delphi code | 2-3h | Analysis report | ✅ Complete |
| **2** | CHECK existing Laravel | 1-2h | Inventory report | ✅ Gaps identified |
| **3** | PLAN implementation | 1-2h | Migration plan | 🚨 **USER APPROVAL** |
| **4** | IMPLEMENT code | 4-6h | Working code | ✅ All tests pass |
| **5** | TEST & DOCUMENT | 3-5h | Complete docs | 🚨 **USER SIGN-OFF** |

**Total Time**: 11-18 hours (includes quality gates & testing)

**Critical Gates** (MANDATORY):
- ✅ Phase 3: USER APPROVAL before Phase 4 (no exceptions!)
- ✅ Phase 5: USER SIGN-OFF before production

---

## ✅ Phase Success Criteria (Quality Gates)

**Each phase has clear completion criteria. Don't proceed until ALL items checked:**

### Phase 0: Discovery Complete ✓
When complete, you should see:
- [ ] Complexity assessed (SIMPLE/MEDIUM/COMPLEX clearly stated)
- [ ] Migration plan document generated
- [ ] Skill files loaded based on complexity
- [ ] Time estimate shown (2-4h, 4-8h, or 8-12+h)
- [ ] You understand next steps

### Phase 1: Analysis Complete ✓
Before proceeding to Phase 2:
- [ ] All Delphi procedures identified with line numbers
- [ ] All functions documented
- [ ] All event handlers listed
- [ ] MyProcedure dependencies mapped (or "NONE")
- [ ] Database tables identified
- [ ] Analysis report generated (800+ lines)

### Phase 2: Existing Code Checked ✓
Before proceeding to Phase 3:
- [ ] Existing Laravel components inventoried
- [ ] Gaps identified clearly
- [ ] Conflicts detected (if any)
- [ ] Report shows what's missing vs what exists

### Phase 3: Plan Ready (CRITICAL!) 🚨
**BEFORE USER APPROVAL:**
- [ ] Detailed migration plan created
- [ ] All tasks identified and estimated
- [ ] Time breakdown per component
- [ ] Dependencies documented
- [ ] **USER MUST APPROVE** (via ExitPlanMode)

**IF APPROVED:** Proceed to Phase 4
**IF NOT APPROVED:** Review plan, make adjustments, re-submit

### Phase 4: Implementation Done ✓
Before proceeding to Phase 5:
- [ ] All code written per approved plan
- [ ] All tests passing (100% match Delphi)
- [ ] Delphi references in code comments
- [ ] No breaking changes to existing code
- [ ] Code follows Laravel best practices (PSR-12)

### Phase 5: Testing Complete (CRITICAL!) 🚨
**BEFORE USER SIGN-OFF:**
- [ ] Service tests passing (100%)
- [ ] Feature tests passing (100%)
- [ ] Delphi comparison tests passing (output MATCHES)
- [ ] Edge cases tested
- [ ] Error cases handled
- [ ] Manual testing completed
- [ ] Documentation complete
- [ ] **USER MUST SIGN-OFF** (before production)

**IF SIGNED-OFF:** ✅ Ready for production deployment!
**IF NOT SIGNED-OFF:** Fix issues, re-test, re-submit

---

## 📂 SOP Templates & Skill Files

**SOP Templates** (Use for each phase):
- Phase 1: `docs/templates/delphi_analysis_template.md` (290 lines)
- Phase 3: `docs/templates/migration_plan_template.md` (415 lines)
- Phase 5: `docs/templates/test_checklist_template.md` (485 lines)
- Phase 5: `docs/templates/api_doc_template.md` (630 lines)

**Skill Files** (Load based on complexity):
- **SIMPLE:** `docs/DELPHI_BUSINESS_LOGIC_MIGRATION.md` (1,267 lines)
- **MEDIUM:** + `docs/DELPHI_EVENT_HANDLER_MIGRATION.md` (1,426 lines)
- **COMPLEX:** + `docs/MIGRATION_WORKFLOW.md` (1,064 lines)

**Key Benefit**: Load only what you need for your phase!

---

## 🔧 Complexity Assessment

**Your module will be assessed as SIMPLE, MEDIUM, or COMPLEX during Phase 0.**

- 🟢 **SIMPLE:** 2-4 hours
- 🟡 **MEDIUM:** 4-8 hours
- 🔴 **COMPLEX:** 8-12+ hours

**See Phase 0 output for detailed complexity assessment.**

**See:** `delphi-laravel-migration-discovery.md` for full complexity definitions and examples

---

## ✅ SOP Quality Gates

Mandatory checkpoints at each phase:

```
Phase 1 (ANALYZE)
✅ Delphi code fully analyzed
✅ All procedures documented with line numbers
✅ Database tables & fields identified
✅ Analysis report completed

Phase 2 (CHECK)
✅ Existing Laravel components inventoried
✅ Gaps identified
✅ Potential conflicts found
✅ Check report completed

Phase 3 (PLAN) 🚨 CRITICAL GATE
✅ Migration plan created
✅ All tasks identified
✅ Effort estimated
✅ USER APPROVAL REQUIRED (ExitPlanMode)

Phase 4 (IMPLEMENT)
✅ Code written per approved plan
✅ Delphi references in comments
✅ All tests passing
✅ No breaking changes

Phase 5 (TEST) 🚨 CRITICAL GATE
✅ All test scenarios executed
✅ API documentation complete
✅ Code reviewed & approved
✅ USER SIGN-OFF REQUIRED
```

**Rule**: NEVER skip a gate! If issues found, return to earlier phase.

---

## 🚀 How to Use This Command

### Step 1: Read SOP First
```
Before using this command:
1. Read: docs/DELPHI_MIGRATION_SOP.md (20 min)
2. Understand: docs/SOP_SETUP_COMPLETE.md (10 min)
3. Know: 5 critical rules to prevent mistakes
```

### Step 2: Tell Me Your Module
```
/delphi-laravel-migration "CustomerMaster.pas CustomerMaster.dfm"

OR

/delphi-laravel-migration "UbahKemasan.pas UbahKemasan.dfm"

OR

/delphi-laravel-migration "Module name"
Complexity: SIMPLE / MEDIUM / COMPLEX
```

### 📚 Real Examples from This Project

**Example 1: AreaController (SIMPLE - COMPLETED ✅)**
```bash
/delphi-laravel-migration "Area.pas Area.dfm"
```
**Results:**
- Complexity: 🟢 **SIMPLE**
- Time: **3 hours actual**
- Skills Used: Business Logic only
- Files Created: AreaController + AreaService
- Status: ✅ Already exists in project
- Learn from: `app/Http/Controllers/AreaController.php`

---

**Example 2: ProduksiService (COMPLEX - IN PROGRESS 🔄)**
```bash
/delphi-laravel-migration "Produksi.pas Produksi.dfm"
```
**Results:**
- Complexity: 🔴 **COMPLEX**
- Time: **12 hours estimated** (8+ procedures, 5+ tables)
- Skills Used: ALL skill files loaded
- Files Created: 8 controllers + 5 services + 4 migrations + Tests
- Learn from: `docs/PRODUKSI_MIGRATION_COMPLETION_REPORT.md`

---

**Example 3: SPK Module (COMPLEX - COMPLETED ✅)**
```bash
/delphi-laravel-migration "SPK.pas SPK.dfm"
```
**Results:**
- Complexity: 🔴 **COMPLEX**
- Time: **9.5 hours actual** (7 phases)
- Skills Used: ALL skill files + comprehensive testing
- Files Created: SPKController + SPKService + 3 Blade templates + 35+ tests
- Learn from: `.claude/skills/delphi-migration/SPK_MIGRATION_SUMMARY.md`

---

**What You Can Learn from These Examples:**
- ✅ SIMPLE modules complete in 2-4 hours (Area example proves it)
- ✅ COMPLEX modules take 8-12 hours (SPK & Produksi confirm it)
- ✅ Time estimates are ACCURATE
- ✅ File patterns for each complexity level
- ✅ Real-world challenges and solutions

### Step 3: I Will Execute SOP Phases
```
Phase 1: ANALYZE your Delphi code
→ Create: Analysis report (850+ lines)
→ Output: All procedures, variables, logic identified

Phase 2: CHECK existing Laravel
→ Search: Existing components
→ Output: Inventory of what exists

Phase 3: PLAN migration
→ Create: Detailed plan using template
→ Ask: User approval via ExitPlanMode
→ STOP if not approved!

Phase 4: IMPLEMENT (after approval)
→ Write: Code based on approved plan
→ Test: Ensure all tests pass
→ Document: Every method with Delphi references

Phase 5: TEST & DOCUMENT (final)
→ Execute: Full test checklist
→ Create: API documentation
→ Sign-off: User approval
```

---

## 📖 Key Resources

**SOP Documentation:**
- `docs/DELPHI_MIGRATION_SOP.md` - Master SOP (READ FIRST!)
- `docs/SOP_SETUP_COMPLETE.md` - SOP system overview
- `docs/SOP_DOCUMENTATION_INDEX.md` - Complete navigation guide

**Phase Templates:**
- `docs/templates/delphi_analysis_template.md` - Phase 1
- `docs/templates/migration_plan_template.md` - Phase 3
- `docs/templates/test_checklist_template.md` - Phase 5
- `docs/templates/api_doc_template.md` - Documentation

**Skill Files (Load per Complexity):**
- `docs/DELPHI_BUSINESS_LOGIC_MIGRATION.md` - Procedure patterns
- `docs/DELPHI_EVENT_HANDLER_MIGRATION.md` - Event patterns
- `docs/MIGRATION_WORKFLOW.md` - Complex workflows

---

## 💡 Critical Success Factors

1. **Read SOP First** - Understand workflow before starting
2. **Follow 5 Phases** - Don't skip, each is mandatory
3. **Quality Gates** - Stop if issues, return to earlier phase
4. **User Approval** - Phase 3 & 5 require explicit approval
5. **Compare with Delphi** - Output MUST match exactly
6. **Document Everything** - References, calculations, logic
7. **Test Thoroughly** - Before considering "done"

---

## 🎯 To Start Migration

**Tell me:**
```
Module: [Name]
Delphi Files: [.pas file path] [.dfm file path]
Complexity: SIMPLE / MEDIUM / COMPLEX (or let me assess)
```

**Then I will:**
1. ✅ Phase 1: ANALYZE your Delphi code (2-3 hours)
2. ✅ Phase 2: CHECK existing Laravel (1-2 hours)
3. ✅ Phase 3: PLAN migration + GET USER APPROVAL (1-2 hours)
4. ✅ Phase 4: IMPLEMENT approved plan (4-6 hours)
5. ✅ Phase 5: TEST & DOCUMENT + GET USER SIGN-OFF (3-5 hours)

**Total Time: 11-18 hours** (includes all quality gates)

---

**Before starting:** Read `docs/DELPHI_MIGRATION_SOP.md` (20 minutes)

**Documentation:** See `docs/CLAUDE.md` for comprehensive guide

