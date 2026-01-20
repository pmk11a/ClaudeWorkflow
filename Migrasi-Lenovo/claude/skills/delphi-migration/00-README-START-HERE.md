# 🎯 Delphi to Laravel Migration Skill - START HERE

**Version**: 2.1
**Last Updated**: 2026-01-12
**Project**: PWT Migrasi (Delphi 6 → Laravel 12)

---

## 🚀 **RECOMMENDED: Use ADW (AI Developer Workflows)**

**For all Delphi-to-Laravel migrations, use:**

```bash
./scripts/adw/adw-migration.sh <MODULE>
```

### ADW Benefits
- ⚡ **50-60% faster** (4.5 hours vs 8-12 hours manual)
- ✅ **88-98/100 quality** (proven across 5+ migrations)
- 🎯 **Fully automated** phases with approval gates
- 📊 **Real-world tested** (PPL, PO, PB, GROUP, ARUS_KAS)

**See:**
- Quick Start: [scripts/adw/README.md](../../scripts/adw/README.md)
- Real Example: [scripts/adw/WALKTHROUGH.md](../../scripts/adw/WALKTHROUGH.md)
- Architecture: [ADW-ARCHITECTURE.md](./ADW-ARCHITECTURE.md)

---

## 🚀 Quick Start (New Team Members)

### Your First Hour

**⏱️ Total Time: 60 minutes**

```bash
# 1. Read this file (5 min) ⬅️ You are here
# 2. Read QUICK-REFERENCE.md (10 min)
# 3. Review ADW-ARCHITECTURE.md (15 min)
# 4. Read real example: scripts/adw/WALKTHROUGH.md (20 min)
# 5. Try ADW: ./scripts/adw/adw-migration.sh <MODULE> (10 min)
```

---

## 📚 Documentation Map

### 🟢 **PRIMARY - Start Here (Use ADW)**

1. **[ADW-ARCHITECTURE.md](./ADW-ARCHITECTURE.md)** (15 min)
   - How ADW works
   - What happens in each phase
   - Approval gates

2. **[QUICK-REFERENCE.md](./QUICK-REFERENCE.md)** (10 min)
   - All ADW commands
   - Quick lookup
   - When to use what

3. **[scripts/adw/README.md](../../scripts/adw/README.md)** (20 min)
   - ADW quick start
   - Full workflow explanation
   - Success stories

4. **[scripts/adw/WALKTHROUGH.md](../../scripts/adw/WALKTHROUGH.md)** (30 min)
   - Real PPL migration example
   - Step-by-step walthrough
   - Approval gates in action

### 🟢 **NAVIGATION - Find What You Need**

5. **[INTEGRATION-MAP.md](./INTEGRATION-MAP.md)** (10 min) 🆕
   - Navigate between ADW and Skill docs
   - Find answers by use case
   - Detailed navigation guide
   - **Start here if you're lost!**

### 🟡 **SECONDARY - Reference & Cookbook**

6. **[PATTERN-GUIDE.md](./PATTERN-GUIDE.md)** (30 min)
   - All 8 migration patterns with detection rules
   - When to use each pattern
   - Examples and code snippets

7. **[KNOWLEDGE-BASE.md](./KNOWLEDGE-BASE.md)** (45 min)
   - Implementation recipes (cookbook)
   - Code templates & boilerplate
   - Troubleshooting guide
   - Best practices from 3+ successful migrations

8. **[SOP-DELPHI-MIGRATION.md](./SOP-DELPHI-MIGRATION.md)** (45 min)
   - Manual 5-phase workflow (fallback only)
   - Use only if ADW unavailable
   - Reference for detailed process steps

9. **[OBSERVATIONS.md](./OBSERVATIONS.md)** (variable)
   - Lessons from past migrations
   - Known issues & workarounds
   - Success tips & patterns

### 📂 **ORGANIZATIONAL**

- **[phases/](./phases/)** - Phase 0-5 documentation
- **[migrations-registry/](./migrations-registry/)** - Completed migration records
- **[deprecated/](./deprecated/)** - Archive & history (tools now ACTIVE in tools/)
   - Troubleshooting

2. **[SOP-DELPHI-MIGRATION.md](SOP-DELPHI-MIGRATION.md)** - Step-by-step process (20 min)
   - 5-phase workflow
   - Approval gates
   - Time estimates

3. **[PATTERN-GUIDE.md](PATTERN-GUIDE.md)** - Pattern library (30 min)
   - 8 patterns detailed
   - Detection signatures
   - Laravel implementations

### 🟡 HIGH - Reference During Migration

4. **[RULES.md](RULES.md)** - Compliance rules (15 min)
   - P0 Critical rules
   - P1 Mandatory rules
   - Security standards

5. **[QUICK-REFERENCE.md](QUICK-REFERENCE.md)** - Templates (5 min)
   - Code templates
   - SQL queries
   - Common commands

### 🟢 MEDIUM - After Migration

6. **[OBSERVATIONS.md](OBSERVATIONS.md)** - Lessons learned
   - 4 migration retrospectives
   - Real metrics
   - Challenges & solutions

---

## 🎯 Your First Migration (SIMPLE Module)

### Prerequisites (10 min)
```bash
# 1. Verify Delphi source exists
ls d:/ykka/migrasi/pwt/path/to/FrmXXX.pas

# 2. Check if Laravel models exist
ls app/Models/DbXXX.php

# 3. Verify database table exists
# Run SQL: SELECT * FROM DbXXX

# 4. Get advice
claude
> /delphi-advise
> "I want to migrate FrmXXXX to Laravel"
```

### Phase 0: Analysis (1 hour)
```bash
# 1. Read Delphi source files
code d:/ykka/migrasi/pwt/path/to/FrmXXX.pas
code d:/ykka/migrasi/pwt/path/to/FrmXXX.dfm

# 2. Use PATTERN-GUIDE.md to identify patterns
- [ ] Pattern 1: Mode Operations (UpdateData(Choice:Char))
- [ ] Pattern 2: Permissions (IsTambah/IsKoreksi/IsHapus)
- [ ] Pattern 3: Field Dependencies (OnChange events)
- [ ] Pattern 4: Validation (if/raise Exception)
- [ ] Pattern 5: Authorization (OL check)
- [ ] Pattern 6: Audit Logging (LoggingData)
- [ ] Pattern 7: Master-Detail (StringGrid)
- [ ] Pattern 8: Lookup (Lookup forms)

# 3. Document findings
```

### Phase 1: Implementation (2-3 hours)
```bash
# Use KNOWLEDGE-BASE.md § Implementation Cookbook
# Use QUICK-REFERENCE.md for templates

# Generate files:
1. Service (30 min)
2. Controller (20 min)
3. Requests (20 min)
4. Policy (10 min)
5. Views (1 hour)
6. Routes (5 min)
7. Tests (30 min)
```

### Phase 2: Testing (30 min)
```bash
# Manual testing checklist
- [ ] Create document
- [ ] Read/view document
- [ ] Update document
- [ ] Delete document
- [ ] Test permissions (denied scenarios)
- [ ] Test validations (error messages)
```

### Phase 3: Documentation (10 min)
```bash
# After migration
/delphi-retrospective

# Commit changes
git add .
git commit -m "feat(xxx): Complete XXX module migration"
```

**Total Time**: ~4 hours for SIMPLE module

---

## 📊 Success Metrics (Proven Results)

From 3 successful migrations (PPL, PO, PB):

| Metric | Target | Achieved | Status |
|--------|--------|----------|--------|
| Pattern Coverage | 100% | 100% | ✅ |
| Business Logic | 100% | 100% | ✅ |
| Permission Mapping | 100% | 100% | ✅ |
| Validation Coverage | ≥95% | 90-95% | ✅ |
| Code Quality | ≥85/100 | 88-92/100 | ✅ |
| Time Variance | <20% | ~15% | ✅ |
| Manual Work | <5% | 2-5% | ✅ |

---

## 🎨 Architecture (30 Second Overview)

```
DELPHI 6                          LARAVEL 12
─────────────────────             ──────────────────────
TFrmModule.pas                    Controller (HTTP)
  UpdateData(Choice:Char)    →      store/update/destroy
  IsTambah/IsKoreksi         →    Policy + Request
  Validation Logic           →      authorize() + rules()
  LoggingData()              →    Service (Business Logic)
  StringGrid (Details)       →      create/update/delete
                                  Views (Blade)
                                    index/create/edit/show
```

**Key Principle**: 100% business logic preservation

---

## 🛠️ Essential Commands

### Before Migration
```bash
# Get advice
/delphi-advise "I want to migrate FrmXXXX"

# Check database schema
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'DbXXX';

# Check OL configuration
SELECT OL FROM DBMENU WHERE KODEMENU = 'XXXX';

# Check User Menu Permission
SELECT * FROM DBFLMENU WHERE L1='XXXX';
```

### During Migration
```bash
# Format code
./vendor/bin/pint

# Test
php artisan test

# List routes
php artisan route:list | grep "xxx"
```

### After Migration
```bash
# Document lessons
/delphi-retrospective

# Clear caches
php artisan cache:clear
php artisan view:clear

# Commit
git add .
git commit -m "feat(xxx): Complete XXX migration"
```

---

## 🆘 Common Problems (Quick Fixes)

### 1. "Column not found"
```sql
-- Check actual schema first!
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'TableName';
```

### 2. Menu not appearing
```bash
# Clear all caches
php artisan cache:clear
php artisan view:clear
composer dump-autoload
# Hard refresh browser (Ctrl+F5)
```

### 3. Method name conflicts
```php
// ❌ Wrong
public function authorize() { }

// ✅ Correct
public function authorizeDocument() { }
```

### 4. Wrong authorization levels
```sql
-- ALWAYS check OL first!
SELECT OL FROM DBMENU WHERE KODEMENU = 'XXXX';
```

### 5. Empty details allowed
```php
// Multi-layer validation
'details' => 'required|array|min:1'  // Request
if (count($details) < 1) throw ...   // Service
if (detailCount === 0) return false  // JavaScript
```

**More**: See KNOWLEDGE-BASE.md § Troubleshooting

---

## 📖 Complete Documentation Index

| Document | Purpose | Time | When |
|----------|---------|------|------|
| **KNOWLEDGE-BASE.md** | Complete guide | 30m | Before migration |
| **SOP-DELPHI-MIGRATION.md** | Step-by-step SOP | 20m | Before migration |
| **PATTERN-GUIDE.md** | 8 patterns library | 30m | During analysis |
| **RULES.md** | Compliance rules | 15m | During code review |
| **QUICK-REFERENCE.md** | Quick lookup | 5m | During coding |
| **OBSERVATIONS.md** | Lessons learned | 10m | Learning |
| **STARTER-KIT.md** | Environment setup | 15m | First time |
| **RELEASES.md** | Version history | 2m | Reference |

---

## 🎓 Learning Path

### Week 1: Foundations (Reading)
- Day 1-2: KNOWLEDGE-BASE.md, QUICK-REFERENCE.md
- Day 3-4: PATTERN-GUIDE.md
- Day 5: RULES.md, SOP-DELPHI-MIGRATION.md

### Week 2: Observation (Shadowing)
- Day 1-3: Watch experienced developer do SIMPLE migration
- Day 4-5: Pair programming on MEDIUM migration

### Week 3: Practice (With Review)
- Day 1-2: Solo SIMPLE migration with code review
- Day 3-5: Document learnings, retrospective

### Week 4: Independence
- Day 1-5: Solo MEDIUM migration, update OBSERVATIONS.md

---

## 🎯 Quality Checklist

Before marking migration "complete":

### Code Quality
- [ ] Formatted with Pint (PSR-12)
- [ ] No hardcoded values
- [ ] Type hints on all methods
- [ ] Delphi references in comments

### Functionality
- [ ] Can create document
- [ ] Can read/view document
- [ ] Can update document
- [ ] Can delete document
- [ ] Authorization works (if OL > 0)
- [ ] All permissions work
- [ ] All validations work
- [ ] Audit logging works

### Testing
- [ ] Manual CRUD testing
- [ ] Permission testing (denied scenarios)
- [ ] Validation testing (error messages)
- [ ] Database verification

### Documentation
- [ ] Retrospective completed (`/delphi-retrospective`)
- [ ] Lessons documented in OBSERVATIONS.md

---

## 💡 Pro Tips

1. **Always verify OL first** (saves 1+ hour)
   ```sql
   SELECT OL FROM DBMENU WHERE KODEMENU = 'XXXX';
   ```

2. **Always verify usert menupermission ** (User Previledge)
   ```sql
   SELECT OL FROM DBMENU WHERE KODEMENU = 'XXXX';
   ```

3. **Check database schema** (prevents errors)
   ```sql
   SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS;
   ```

4. **Use transactions** (ensures consistency)
   ```php
   DB::transaction(function () { ... });
   ```

5. **Multi-layer validation** (prevents bad data)
   ```
   JavaScript → Request → Controller → Service
   ```

6. **Run retrospective** (continuous improvement)
   ```bash
   /delphi-retrospective
   ```

---

## 📞 Support

- **Stuck?** → See KNOWLEDGE-BASE.md § Troubleshooting
- **Question?** → Review PATTERN-GUIDE.md
- **Advice?** → Run `/delphi-advise`
- **After migration?** → Run `/delphi-retrospective`

---

## 🚀 Ready to Start?

### Path A: First Time (New Developer)
1. ✅ Read this file (you just did!)
2. → Read KNOWLEDGE-BASE.md Executive Summary (10 min)
3. → Read QUICK-REFERENCE.md (10 min)
4. → Shadow experienced developer (1-2 weeks)

### Path B: Have Experience
1. ✅ Read this file (you just did!)
2. → Review PATTERN-GUIDE.md (30 min)
3. → Read RULES.md (15 min)
4. → Start SIMPLE migration with review

### Path C: Emergency (Need Migration Now)
1. ✅ Read this file (you just did!)
2. → Read QUICK-REFERENCE.md (5 min)
3. → Use KNOWLEDGE-BASE.md § Implementation Cookbook
4. → Review RULES.md P0 Critical rules

---

**Next Step**: Open [KNOWLEDGE-BASE.md](KNOWLEDGE-BASE.md) and read the Executive Summary (10 minutes)

---

**START HERE v1.0**
**Last Updated**: 2026-01-03
**Questions?** Check KNOWLEDGE-BASE.md § Troubleshooting
