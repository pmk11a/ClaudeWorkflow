# Complexity-Based Skill File Loader

**Purpose:** Load only the skill files needed based on module complexity
**Benefit:** Save 2,000-3,000 tokens per simple migration
**Implementation:** AI logic for Phase 0 assessment

---

## 📍 You Are Here (Navigation)

**This File:** Intelligence engine - **Complexity scoring & skill file loader**
- Implements complexity scoring algorithm
- Determines skill files to load per complexity level
- Calculates token efficiency
- Analyzes pattern characteristics

**Related Files in This Workflow:**
1. **[delphi-laravel-migration.md](.claude/commands/delphi-laravel-migration.md)** ← Main entry point
   - Shows overall workflow
   - References this complexity loader
   - Entry point for user command

2. **[delphi-laravel-migration-discovery.md](.claude/commands/delphi-laravel-migration-discovery.md)** ← Phase 0 executor
   - **Uses complexity definitions from this file** (lines 30-85)
   - Calls complexity scoring algorithm (lines 125-160 in this file)
   - Applies scoring to assess your module
   - Shows results to you

**Data Flow (Behind the Scenes):**
```
User provides .pas + .dfm files
   ↓
Discovery file (Phase 0) scans files
   ↓
This file (Complexity Loader) scores:
   → Line count of .pas file
   → Number of procedures/functions
   → MyProcedure dependencies
   → .dfm component count
   → Form structure complexity
   ↓
Score calculated (SIMPLE=0-2, MEDIUM=3-5, COMPLEX=6+)
   ↓
Skill files loaded:
   → SIMPLE: Load 1 file (~3,000 tokens)
   → MEDIUM: Load 2 files (~6,500 tokens)
   → COMPLEX: Load 4 files (~12,800 tokens)
   ↓
Discovery shows assessment to you
```

---

## 🎯 How It Works

### Assessment Phase (Phase 0)

User provides: Module name + file paths (or description)

AI performs:
```
1. Scan .pas file for:
   - Number of procedures/functions
   - Presence of MyProcedure dependencies
   - Complexity of calculations
   - Number of event handlers
   - Database operations

2. Scan .dfm file for:
   - Number of components
   - Form complexity (modal, master-detail, etc)
   - Number of event handlers

3. Calculate complexity score:
   - Single form + basic CRUD = SIMPLE
   - Master-detail + some logic = MEDIUM
   - Multiple forms + heavy logic = COMPLEX
```

### Dynamic File Loading

Based on complexity:

```
SIMPLE:
├─ Load: delphi-laravel-migration-discovery.md
├─ Load: DELPHI_BUSINESS_LOGIC_MIGRATION.md (1,267 lines)
└─ Skip: Event handlers, Workflow, Quick Reference
   Tokens saved: ~2,500 tokens

MEDIUM:
├─ Load: delphi-laravel-migration-discovery.md
├─ Load: DELPHI_BUSINESS_LOGIC_MIGRATION.md (1,267 lines)
├─ Load: DELPHI_EVENT_HANDLER_MIGRATION.md (1,426 lines)
└─ Skip: Workflow, Quick Reference
   Tokens saved: ~1,500 tokens

COMPLEX:
├─ Load: delphi-laravel-migration-discovery.md
├─ Load: DELPHI_BUSINESS_LOGIC_MIGRATION.md (1,267 lines)
├─ Load: DELPHI_EVENT_HANDLER_MIGRATION.md (1,426 lines)
├─ Load: MIGRATION_WORKFLOW.md (1,064 lines)
├─ Load: QUICK_REFERENCE.md (715 lines)
└─ Additional analysis
   Tokens used: Full allocation (no savings)
```

---

## 📝 Implementation Rules

### Complexity Detection Rules

**See:** `delphi-laravel-migration-discovery.md` (lines 30-85) for detailed complexity indicators and definitions.

**This file implements the scoring algorithm based on those rules.**

---

## 🔍 Complexity Scoring Algorithm

```
Score = 0

# Check .pas file complexity
if file_lines < 100:       score += 0
elif file_lines < 300:     score += 1
elif file_lines < 600:     score += 2
else:                      score += 3

# Check for MyProcedure
myproc_count = grep(file, "MyProcedure")
score += min(myproc_count, 3)

# Check .dfm components
component_count = count_dfm_objects(file)
if component_count < 20:   score += 0
elif component_count < 50: score += 1
else:                      score += 2

# Check form structure
if has_master_detail:      score += 2
if multiple_forms:         score += 1
if has_modals:             score += 1

# Check business logic
if has_calculations:       score += 1
if has_validations:        score += 1
if has_approvals:          score += 1

# Determine complexity
if score <= 2:             complexity = SIMPLE
elif score <= 5:           complexity = MEDIUM
else:                      complexity = COMPLEX
```

---

## 💻 What AI Does (Phase 0)

### Step 1: Scan Files

```bash
# Count procedures/functions
grep -c "procedure\|function" module.pas

# Count components
grep -c "object " module.dfm

# Find MyProcedure calls
grep -c "MyProcedure\|DataBuka\|MyFindField" module.pas

# Check for key patterns
grep "OnClick\|OnChange\|OnValidate" module.pas
grep "master\|detail\|grid" module.dfm
```

### Step 2: Assess Complexity

```
After scanning, AI announces:

"📊 Complexity Assessment:
Module: CustomerMaster.pas
- Procedures: 3
- Functions: 2
- MyProcedure calls: 0
- Components: 15
- Event handlers: 4
- Form type: Single CRUD

→ Complexity: 🟢 SIMPLE (2-4 hours)
→ Skill files to load: Business Logic only
→ Estimated savings: 2,500 tokens"
```

### Step 3: Load Appropriate Files

```
# For SIMPLE:
Load: delphi-laravel-migration-discovery.md (330 lines)
Load: DELPHI_BUSINESS_LOGIC_MIGRATION.md (1,267 lines)
Skip: Event handlers, Workflow, Reference
Tokens: ~1,600 (vs ~4,000 if loaded all)

# For COMPLEX:
Load: All skill files (see discovery.md lines 78-84 for details)
Tokens: ~5,000-6,000 (full allocation)
```

---

## 📊 Token Comparison

### Scenario 1: Customer Master (SIMPLE)

**OLD Approach (load everything):**
```
Main command:           1,071 lines → 2,800 tokens
All skill files:        5,472 lines → 15,000 tokens
────────────────────────────────────
TOTAL:                             → 17,800 tokens
```

**NEW Approach (complexity-based):**
```
Main command:           209 lines → 600 tokens
Discovery:              330 lines → 800 tokens
Business Logic:         1,267 lines → 3,000 tokens
────────────────────────────────────
TOTAL:                             → 4,400 tokens
```

**SAVINGS: 17,800 - 4,400 = 13,400 tokens (75% reduction!)** 🚀

---

### Scenario 2: UbahKemasan (COMPLEX)

**OLD Approach:**
```
Main command:           1,071 lines → 2,800 tokens
All skill files:        5,472 lines → 15,000 tokens
────────────────────────────────────
TOTAL:                             → 17,800 tokens
```

**NEW Approach (same, all needed):**
```
Main command:           209 lines → 600 tokens
Discovery:              330 lines → 800 tokens
SOP Guide:              302 lines → 800 tokens (replaces old phases guide)
Business Logic:         1,267 lines → 3,000 tokens
Event Handlers:         1,426 lines → 3,500 tokens
Workflow:               1,064 lines → 2,500 tokens
Quick Reference:        715 lines → 1,600 tokens
────────────────────────────────────
TOTAL:                             → 12,800 tokens
```

**SAVINGS: 17,800 - 12,800 = 5,000 tokens (28% reduction)** ✅

---

## 🎨 User Experience

### For Simple Module

```
User: /delphi-laravel-migration "CustomerMaster.pas CustomerMaster.dfm"

AI:
"📊 ASSESSING COMPLEXITY...
   Scanning CustomerMaster.pas (87 lines)
   Scanning CustomerMaster.dfm (14 components)
   Analyzing dependencies...

   ✓ Single form
   ✓ Basic CRUD operations
   ✓ No MyProcedure dependencies
   ✓ Standard validations only

   Complexity: 🟢 SIMPLE
   Estimated Time: 2-4 hours

   Loading optimal skill files:
   ✓ SOP Migration Guide (Phase 0)
   ✓ Business Logic Migration Skill
   ⊘ Event Handler Skill (not needed for SIMPLE)
   ⊘ Workflow Guide (not needed for SIMPLE)

   Token savings: ~2,500 tokens

📋 MIGRATION PLAN CREATED
   Ready to execute Phase 0 discovery?
   Provide details and I'll proceed to Phase 1."
```

### For Complex Module

```
User: /delphi-laravel-migration "UbahKemasan.pas"

AI:
"📊 ASSESSING COMPLEXITY...
   Scanning UbahKemasan.pas (650 lines)
   Scanning UbahKemasan.dfm (45 components)
   Analyzing dependencies...

   ✓ Multiple procedures (12)
   ✓ Complex calculations (7)
   ✓ Heavy MyProcedure usage (6 functions)
   ✓ Multi-level approval (5 levels)
   ✓ Stock/inventory impact detected

   Complexity: 🔴 COMPLEX
   Estimated Time: 8-12+ hours

   Loading comprehensive skill files:
   ✓ SOP Migration Guide (5-phase comprehensive workflow)
   ✓ Business Logic Migration Skill
   ✓ Event Handler Migration Skill
   ✓ Migration Workflow Guide
   ✓ Quick Reference

   Additional analysis:
   ✓ Scanning for similar migrations
   ✓ Mapping dependencies
   ✓ Identifying risks

📋 COMPREHENSIVE MIGRATION PLAN CREATED
   Ready to execute detailed Phase 0?"
```

---

## 🔧 Implementation Checklist

- [x] Create modular command files (Step 1 ✅)
- [ ] Add complexity detection logic to Phase 0
- [ ] Implement conditional skill file loading
- [ ] Add complexity scoring algorithm
- [ ] Create user-friendly assessment output
- [ ] Test with sample modules
- [ ] Document complexity indicators
- [ ] Update user guidance

---

## 📚 Integration with Phase 0

In `delphi-laravel-migration-discovery.md`:

```markdown
## 0.2 Module Complexity Assessment

**AI WILL:**
1. Scan your .pas files
2. Analyze your .dfm files
3. Calculate complexity score
4. Load only needed skill files
5. Estimate accurate time
6. Present migration plan

**You WILL:**
1. Receive complexity assessment
2. See which skill files will be used
3. Review estimated time & resources
4. Approve plan or request adjustments
```

---

## 💡 Benefits of Complexity-Based Loading

1. **Token Efficiency**
   - 75% savings for SIMPLE modules
   - 27% savings for COMPLEX modules
   - Optimal resource allocation

2. **User Experience**
   - Clearer expectations (time, resources)
   - Faster feedback (skip unnecessary info)
   - Focused guidance (relevant skill files only)

3. **Quality**
   - Better-matched guidance per module type
   - More thorough analysis for complex modules
   - Streamlined approach for simple modules

4. **Maintenance**
   - Skill files loaded only when needed
   - Easier to add new skill files
   - Scalable approach

---

**Status:** Implementation strategy defined

**Next:** Execute complexity-based loading in Phase 0 logic

