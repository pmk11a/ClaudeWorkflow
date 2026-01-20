# Phase 2: Check Existing Laravel Implementation

---

## ⚡ ADW Automation (Recommended)

**This entire phase is automated in ADW!**

```bash
# Run ADW to verify existing Laravel code
./scripts/adw/adw-migration.sh <MODULE>
```

**What ADW Does Automatically**:
- ✅ Scans existing Models (DbModule.php)
- ✅ Finds existing Controllers and Services
- ✅ Checks Request/Policy classes
- ✅ Verifies test infrastructure
- ✅ Creates implementation roadmap
- ✅ Identifies gaps and conflicts

**Time Saved**: 1-2 hours → 5 minutes (94% faster)

**For Manual Steps**: Follow instructions below (if ADW unavailable)

---

**⏱️ Estimated Time**: 1-2 hours

**🎯 Objective**: Verify what Laravel code already exists for this module and identify gaps or conflicts.

---

## Step 1: Check Existing Laravel Models

```bash
ls app/Models/Db[ModuleName]*.php
# Example: ls app/Models/DbPPL.php
```

If exists, review:
- [ ] Table name matches SQL Server table
- [ ] Column names correctly cased (PascalCase for SQL Server)
- [ ] Timestamps disabled (if using old tables)
- [ ] Relationships defined
- [ ] Soft delete traits (if needed)

---

## Step 2: Check Existing Controllers/Services

```bash
ls app/Http/Controllers/*[Module]*Controller.php
ls app/Services/*[Module]*Service.php
```

If exist:
- [ ] Controller methods: store, update, destroy
- [ ] Service methods: create, update, delete
- [ ] Request classes: Store/Update Request
- [ ] Policy class with authorization

---

## Step 3: Check Test Infrastructure

```bash
ls tests/Feature/*[Module]*Test.php
ls phpunit.xml  # Check database config
```

- [ ] Test database configured for SQL Server
- [ ] DatabaseTransactions trait (not RefreshDatabase!)
- [ ] Existing test patterns documented

---

## Step 4: Create Implementation Roadmap

| Component | Status | Action |
|-----------|--------|--------|
| Models | ✅ Exists | Review & update if needed |
| Controller | ❌ Missing | Create |
| Service | ❌ Missing | Create |
| Requests | ❌ Missing | Create |
| Policy | ❌ Missing | Create |
| Tests | ⚠️ Partial | Enhance |
| Routes | ✅ Exists | Verify |

---

## Next Steps

→ [Phase 3: Plan](./PHASE-3-PLAN.md)

---

← [Phase 1: Analyze](./PHASE-1-ANALYZE.md)
