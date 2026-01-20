# Phase 0: Discovery & Pre-Flight Validation

---

## ⚡ ADW Automation (Recommended)

**This entire phase is automated in ADW!**

```bash
# Run ADW to auto-discover files and validate
./scripts/adw/adw-migration.sh <MODULE>
```

**What ADW Does Automatically**:
- ✅ Auto-discovers .pas and .dfm files
- ✅ Creates specification template
- ✅ Extracts database tables and fields
- ✅ Validates menu codes and OL levels
- ✅ Assesses complexity automatically
- ✅ Identifies blocking issues upfront

**Time Saved**: 30-45 minutes → 5 minutes (85% faster)

**For Manual Steps**: Follow instructions below (if ADW unavailable)

---

**⏱️ Estimated Time**: 30-45 minutes

**🎯 Objective**: Validate that the Delphi form is ready for migration and identify any blockers before starting actual implementation work.

**📊 Success Criteria**:
- [ ] Delphi source files identified (.pas and .dfm)
- [ ] All tables and fields documented in SQL Server
- [ ] Menu code and authorization level (OL) confirmed
- [ ] Complexity level assessed (SIMPLE/MEDIUM/COMPLEX)
- [ ] No blocking issues identified (or issues documented for Phase 3)
- [ ] Estimated time calculated with adjustments for patterns/reuse

---

## Step 1: Identify Source Files

### Locate Delphi Files

1. **Find the .pas file** (main Delphi form source):
   ```bash
   find d:/ykka/migrasi/pwt -name "Frm*.pas" | grep -i "ppl\|po\|aktiva"  # Example
   ```

2. **Locate the .dfm file** (Delphi form definition):
   - Usually same name as .pas file with .dfm extension
   - Example: `FrmPPL.pas` and `FrmPPL.dfm`

3. **Record file information**:
   - [ ] Delphi source file: `_________________`
   - [ ] DFM design file: `_________________`
   - [ ] Module name: `_________________` (e.g., "Penyerahan Bahan")
   - [ ] Menu code: `_________________` (e.g., "03001")

### Verify File Access

```bash
# Windows PowerShell
ls "d:\ykka\migrasi\pwt\Master\PPL\FrmPPL.pas"
ls "d:\ykka\migrasi\pwt\Master\PPL\FrmPPL.dfm"

# Should show file details if accessible
```

---

## Step 2: Discover Menu Code & Authorization Level

### Why This Matters

The **menu code** and **authorization level (OL)** are CRITICAL:
- Menu code determines which permissions to check in DBFLMENU table
- OL (authorization level) determines how many approval levels exist (1-5)
- Wrong values cause FK constraint errors in tests and policies

### Find Menu Code

**Option A: Use Auto-Discovery Command** (Recommended):
```bash
php artisan migrate:discover-menu "Penyerahan Bahan"
```

**Output Example**:
```
✅ Found exact match!
Use in Policy:
  protected string $menuCode = '03001';
  protected int $authorizationLevel = 2;
```

**Option B: Manual SQL Query**:
```sql
SELECT L1, KODEMENU, NAMA, OL
FROM DBMENU
WHERE NAMA LIKE '%Penyerahan Bahan%';

-- Example result:
-- L1='05', KODEMENU='03001', NAMA='Master Penyerahan Bahan', OL='2'
```

### Record Menu Information

- [ ] Menu Code: `_________________` (e.g., "03001")
- [ ] L1 Level: `_________________` (e.g., "05")
- [ ] Module Name: `_________________`
- [ ] OL (Auth Levels): `_________________` (1-5)

**Critical Notes**:
- ⚠️ Do NOT use placeholder values (e.g., "PENYERAHAN_BAHAN")
- ⚠️ Always verify against DBMENU table first
- ⚠️ OL value is NOT the same as menu level - it's approval levels

---

## Step 3: Verify Database Tables

### List Tables Required for Migration

**Master table** (required):
- [ ] DbPPL (or equivalent Db{Module})

**Related tables** (verify existence):
- [ ] Detail table (e.g., DbPPLDET, DbPODET)
- [ ] Lookup tables (e.g., DbSupplier, DbBarang)
- [ ] Lock period table (e.g., DbPeriode, if needed)

### Check Composite Keys

```bash
# Auto-detection (recommended)
php artisan migrate:validate-delphi d:/path/to/FrmPPL.pas --tables="DbPPL,DbPPLDET"
```

**Manual check** for composite keys:
```sql
-- Check if table has composite primary key
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'DbPPLDET'
AND CONSTRAINT_NAME LIKE 'PK%'
ORDER BY ORDINAL_POSITION;

-- If query returns 2+ columns, it's a composite key
```

### Record Table Information

- [ ] Master Table: `_________________`
- [ ] Detail Table: `_________________`
- [ ] Has Composite Key? `_________________` (Yes/No)
- [ ] Composite Key Columns: `_________________` (if yes)

---

## Step 4: Assess Complexity Level

### Quick Complexity Check

Use this script to automatically assess complexity:

```bash
php artisan migrate:validate-delphi d:/path/to/FrmPPL.pas --menu="Module Name" --tables="DbTable1,DbTable2"
```

**Output includes**:
```
📊 Assessing complexity...
  Lines: 847
  Procedures: 8
  Functions: 3
  🎯 Complexity: MEDIUM
  📈 Estimated Time: 2-4 hours (with patterns)
```

### Manual Assessment

| Level | Characteristics | Examples |
|-------|----------------|----|
| 🟢 **SIMPLE** | <500 lines, 1-2 procedures, basic CRUD, no stored procedures | Supplier maintenance, Category lookup |
| 🟡 **MEDIUM** | 500-1500 lines, 3-6 procedures, master-detail form, 2-3 business rules | PPL (Penyerahan Bahan), Basic PO |
| 🔴 **COMPLEX** | >1500 lines, 6+ procedures, multiple forms, algorithms, stock calculations | PO (Purchase Order), Complex inventory |

### Record Complexity

- [ ] Complexity Level: `_________________` (SIMPLE/MEDIUM/COMPLEX)
- [ ] Reason: `_________________`

---

## Step 5: Check for Blockers

### Common Issues to Identify

**Blocking Issues** (must fix before migration):
- [ ] Delphi source files missing or inaccessible
- [ ] Menu code not found in DBMENU
- [ ] Required tables don't exist in SQL Server
- [ ] No template exists for this module type

**Non-Blocking Issues** (document but proceed):
- [ ] Complex stored procedures (will preserve but need manual review)
- [ ] Missing audit logs in detail forms (opportunity to improve)
- [ ] Composite keys (use manual query pattern)
- [ ] Custom validation not in standard 8 patterns

### Use Auto-Validation Tool

```bash
php artisan migrate:validate-delphi d:/path/to/FrmPPL.pas \
    --menu="Penyerahan Bahan" \
    --tables="DbPPL,DbPPLDET"
```

**Issues Found?**:
```
⚠️  Issues Found: 2
  • Composite key in DbPPLDET
  • Missing audit logging

💡 Recommendations:
  • Use manual query pattern for DbPPLDET (see PATTERN-GUIDE.md Pattern 9)
  • Add audit logging to all CRUD operations (improvement over Delphi)
```

---

## Step 6: Calculate Time Estimate

### Base Estimate by Complexity

| Complexity | First Time | With Patterns |
|------------|-----------|---------------|
| 🟢 SIMPLE | 2-4 hours | 1-2 hours |
| 🟡 MEDIUM | 4-8 hours | 2-4 hours |
| 🔴 COMPLEX | 8-12 hours | 4-6 hours |

### Apply Pattern Bonuses

Add these ONLY if applicable:

```
IF (this is migration 4+) THEN -20% (test infrastructure reuse)
IF (similar module already migrated) THEN -30% (exact pattern exists)
IF (3+ migrations done) THEN -25% (service patterns established)

FINAL_TIME = BASE_TIME - bonuses
```

**Example Calculation**:
```
Base: MEDIUM = 4-8 hours
Migrations done: 5 (past 3)
Similar module exists: YES (PPL done earlier)
Test infrastructure reuse: YES

Calculation:
- Start: 4-8 hours
- Test reuse: -20% = 3.2-6.4 hours
- Similar pattern: -30% = 2.2-4.4 hours
- Service patterns: -25% = 1.65-3.3 hours

Realistic: 2-4 hours
```

### Record Time Estimate

- [ ] Complexity: `_________________`
- [ ] Base Time: `_________________`
- [ ] Bonuses Applied: `_________________`
- [ ] Final Estimate: `_________________`

---

## Step 7: Create Discovery Document

### Output File

Create file: `.claude/skills/delphi-migration/[MODULE]_PHASE-0-DISCOVERY.md`

```markdown
# [Module Name] - Phase 0 Discovery

**Date**: YYYY-MM-DD
**Completed By**: [Your Name]

## Source Files
- Delphi File: d:/ykka/migrasi/pwt/Master/[Module]/Frm[Module].pas
- DFM File: d:/ykka/migrasi/pwt/Master/[Module]/Frm[Module].dfm

## Database Info
- Master Table: DbPPL
- Detail Table: DbPPLDET
- Menu Code: 03001
- OL Level: 2
- Composite Keys: DbPPLDET (KodePPL + NoItem)

## Complexity Assessment
- **Level**: MEDIUM
- **Lines of Code**: 847
- **Procedures**: 8
- **Functions**: 3
- **Reason**: Master-detail form, 2 business rules, 2 approval levels

## Time Estimate
- Base: 4-8 hours
- With Patterns: 2-4 hours
- Estimated: 2.5 hours

## Issues Found
- ⚠️ Composite key in DbPPLDET - use manual query pattern
- ⚠️ Missing audit logging in detail procedures

## Next Phase
Ready to proceed to Phase 1: Analyze

**Approved by**: [Manager Name]
```

---

## Phase 0 Checklist

Before proceeding to Phase 1, verify:

- [ ] Delphi source files (.pas, .dfm) located and accessible
- [ ] Menu code discovered and verified against DBMENU
- [ ] Authorization level (OL) confirmed
- [ ] All required tables exist in SQL Server
- [ ] Composite keys (if any) identified
- [ ] Complexity level assessed
- [ ] No blocking issues remain (or documented for Phase 3)
- [ ] Time estimate calculated
- [ ] Discovery document created
- [ ] Team approval obtained (if required)

---

## If Issues Found

### Blocking Issues

If blocking issues exist, **STOP** and:
1. Document the issue clearly
2. Contact the project lead
3. Resolve before proceeding
4. Return to Phase 0 Step 5

### Non-Blocking Issues

If non-blocking issues found:
1. Document in discovery file
2. Add to Phase 3 plan as "known issues"
3. Proceed to Phase 1 with caution
4. Re-assess after Phase 1 analysis

---

## Common Discovery Mistakes

| ❌ Wrong | ✅ Correct | Why |
|---------|----------|-----|
| Using placeholder menu code | Running migrate:discover-menu | Placeholder causes FK errors |
| Assuming OL=5 | Checking DBMENU.OL value | OL varies by module |
| Skipping composite key check | Running validation tool | Composite keys break route binding |
| Not recording estimates | Tracking time for next migration | Improves future estimates |

---

## Next Steps

✅ **Phase 0 Complete** → Proceed to [Phase 1: Analyze](./PHASE-1-ANALYZE.md)

---

**Document Version**: 1.0
**Last Updated**: 2026-01-11
**Status**: Production Ready

← [Back to SOP](../SOP-DELPHI-MIGRATION.md) | [Phase Guide](../INDEX.md)
