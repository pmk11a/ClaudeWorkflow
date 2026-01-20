# Phase 5: Test, Document & Deploy

---

## ⚡ ADW Automation (Recommended)

**This phase is mostly automated in ADW!**

```bash
# Run ADW to validate, test, and document
./scripts/adw/adw-migration.sh <MODULE>
```

**What ADW Does Automatically**:
- ✅ Runs comprehensive test suite
- ✅ Generates validation coverage report
- ✅ Creates migration summary
- ✅ Documents lessons learned
- ✅ Generates code review checklist
- ✅ Creates sidebar menu snippet
- ✅ Formats code with Pint
- ✅ Provides UAT checklist

**ADW Sign-Off Gate**: ADW presents final validation report for your approval before deployment

**Time Saved**: 3-5 hours → 10 minutes validation (97% faster)

**For Manual Steps**: Follow instructions below (if ADW unavailable)

---

**⏱️ Estimated Time**: 3-5 hours

**🎯 Objective**: Validate implementation works correctly, document lessons learned, and prepare for production deployment.

---

## Step 1: Run Tests

### Unit Tests

```bash
php artisan test tests/Feature/Module/ModuleTest.php
```

Tests should cover:
- [ ] Can create new document
- [ ] Can read/view document
- [ ] Can update document
- [ ] Cannot update if authorized
- [ ] Can delete document
- [ ] Authorization workflow (L1 → L2)
- [ ] All validation rules pass
- [ ] All validation rules fail correctly

### Integration Tests

```bash
php artisan test --filter Module
```

Verify:
- [ ] Routes working (index, create, store, etc.)
- [ ] Database records created/updated/deleted
- [ ] Permissions enforced
- [ ] Authorization workflow end-to-end

---

## Step 2: Validation Coverage Report

Run validation tool:

```bash
php tools/validate_migration.php module frm_module
```

**Expected output**:
```
Mode Coverage: 100% (I/U/D all implemented)
Permission Coverage: 100% (IsTambah/IsKoreksi/IsHapus)
Validation Coverage: 95%+ (8 patterns detected)
Audit Coverage: 100% (all LoggingData mapped)
```

---

## Step 3: Sidebar Menu Integration

From Phase 4 output, sidebar snippet is auto-generated:

```bash
# 1. Find snippet
ls sidebar_module.html

# 2. Copy content
cat sidebar_module.html | pbcopy  # macOS
# or open and copy manually

# 3. Edit sidebar
code resources/views/layouts/app.blade.php

# 4. Paste in appropriate section (Master Data / Transaksi / Laporan)

# 5. Clear ALL caches
php artisan cache:clear
php artisan view:clear
php artisan config:clear

# 6. Hard refresh browser: Ctrl+Shift+R
```

**Verification**:
- [ ] Menu item appears in sidebar
- [ ] Submenu items visible
- [ ] Clicking opens correct page

---

## Step 4: Cleanup Temporary Files

**Before final commit**, clean repository:

```bash
# 1. Remove helper scripts
rm -f check_*.php
rm -f find_*.php
rm -f test_*.php
rm -f temp_*.php

# 2. Move migration summary
mv *MIGRATION_SUMMARY.md .claude/skills/delphi-migration/

# 3. Remove sidebar snippets (keep for reference only)
rm -f sidebar_*.html

# 4. Verify git status
git status
# Should show ONLY app/, routes/, resources/views/, etc.
```

**Checklist**:
- [ ] No check_*.php in root
- [ ] No find_*.php in root
- [ ] No sidebar_*.html in root
- [ ] Migration summary moved to correct folder
- [ ] Only intended files in git status

---

## Step 5: Code Review & Formatting

```bash
# Format all code to PSR-12
./vendor/bin/pint

# Check for issues
php -l app/Http/Controllers/ModuleController.php
php -l app/Services/ModuleService.php

# Review quality
php tools/validate_migration.php module frm_module
```

---

## Step 6: Documentation

### Create Migration Summary

**File**: `.claude/skills/delphi-migration/[MODULE]_MIGRATION_SUMMARY.md`

```markdown
# [Module] Migration Summary

**Date**: YYYY-MM-DD
**Status**: ✅ Complete
**Time Taken**: X hours

## Overview
- Delphi File: d:/ykka/migrasi/pwt/Master/Module/FrmModule.pas
- Menu Code: XXXXX
- OL Level: X
- Complexity: SIMPLE/MEDIUM/COMPLEX

## Files Generated
- Controllers: 1
- Services: 1-2
- Models: 2
- Policies: 1
- Requests: 2
- Tests: X
- Total: X files

## Patterns Implemented
- ✅ Pattern 1: Mode Operations (I/U/D)
- ✅ Pattern 2: Permissions (IsTambah/IsKoreksi/IsHapus)
- ✅ Pattern 3: Field Dependencies
- ✅ Pattern 4: Validation Rules (X patterns)
- ✅ Pattern 5: Authorization (OL=X)
- ✅ Pattern 6: Audit Logging
- ✅ Pattern 7: Master-Detail
- ⚠️ Pattern 8: Lookup (X lookups implemented)

## Quality Metrics
- Mode Coverage: 100%
- Permission Coverage: 100%
- Validation Coverage: XX%
- Audit Coverage: 100%
- Test Coverage: XX%

## Issues Encountered
1. Composite key in detail table
   - Solution: Used manual query pattern

2. Missing audit logs in Delphi
   - Solution: Added comprehensive logging in Laravel

## Lessons Learned
- Lock period validation is common pattern
- OL value varies by module (not always 5)
- Detail validation needs separate request class
- Test infrastructure is reusable

## Time Breakdown
- Phase 0 (Discovery): 30 min
- Phase 1 (Analyze): 2 hours
- Phase 2 (Check): 45 min
- Phase 3 (Plan): 1 hour
- Phase 4 (Implement): 5 hours
- Phase 5 (Test): 2.5 hours
- **Total**: 11.75 hours

## Recommendation
Consider extracting [common pattern] for reuse in next module.
```

### Run Retrospective

```bash
/delphi-retrospective
```

This automatically:
- Updates OBSERVATIONS.md
- Documents challenges
- Extracts patterns
- Calculates metrics
- Suggests improvements

---

## Step 7: Database Verification

```sql
-- Verify menu exists
SELECT * FROM DBMENU WHERE KODEMENU = 'XXXXX';

-- Verify permissions exist
SELECT * FROM DBFLMENU
WHERE KodeMenu = 'XXXXX'
AND (IsCreate=1 OR IsEdit=1 OR IsDelete=1);
```

---

## Step 8: User Acceptance Testing (UAT)

**Checklist**:
- [ ] User can create new document
- [ ] User can view document
- [ ] User can edit document (if allowed)
- [ ] User can delete document (if allowed)
- [ ] Authorization workflow works (L1 → L2)
- [ ] Permissions enforced correctly
- [ ] All validations trigger correctly
- [ ] Error messages clear (in Indonesian)
- [ ] Sidebar menu appears
- [ ] Search/filter works
- [ ] Export works (if implemented)

---

## Step 9: Production Deployment

```bash
# 1. Final cache clear
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# 2. Optimize for production
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 3. Verify no errors in logs
tail -f storage/logs/laravel.log

# 4. Monitor performance
php artisan horizon:list  # If using queues
```

---

## Phase 5 Checklist

- [ ] All tests pass
- [ ] Validation coverage ≥95%
- [ ] Sidebar menu integrated and working
- [ ] All temporary files cleaned
- [ ] Code formatted with Pint
- [ ] Documentation complete
- [ ] Retrospective run
- [ ] User acceptance test passed
- [ ] Production caches optimized
- [ ] Error logs clean

---

## Next Steps

✅ **Migration Complete!**

**Options**:
1. Start next migration (use OBSERVATIONS.md for patterns)
2. Maintain and improve current implementation
3. Refactor common patterns for reuse

---

## Success Metrics

After 3+ migrations, track:

| Metric | Target |
|--------|--------|
| Avg time per migration | 4-6 hours |
| Test failures on first run | 0 |
| Pattern reuse rate | 60%+ |
| Validation coverage | 95%+ |
| Code quality (PSR-12) | 100% |

---

← [Phase 4: Implement](./PHASE-4-IMPLEMENT.md) | [Lessons Learned](../../OBSERVATIONS.md) →

**Document Version**: 1.0
**Last Updated**: 2026-01-11
