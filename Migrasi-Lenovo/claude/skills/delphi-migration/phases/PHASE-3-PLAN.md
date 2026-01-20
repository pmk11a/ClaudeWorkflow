# Phase 3: Plan Implementation Strategy

---

## ⚡ ADW Automation (Recommended)

**This phase is mostly automated in ADW!**

```bash
# Run ADW to generate detailed implementation spec
./scripts/adw/adw-migration.sh <MODULE>
```

**What ADW Does Automatically**:
- ✅ Analyzes Delphi source + existing Laravel code
- ✅ Proposes architecture decisions
- ✅ Details all validation rules
- ✅ Creates implementation specification
- ✅ Estimates work breakdown
- ✅ Generates approval checklist

**ADW Approval Gate**: ADW presents spec for your review and approval before Phase 4

**Time Saved**: 1-2 hours → 10 minutes (90% faster to spec)

**For Manual Steps**: Follow instructions below (if ADW unavailable)

---

**⏱️ Estimated Time**: 1-2 hours

**🎯 Objective**: Create detailed implementation plan with architecture decisions. **🚨 USER APPROVAL GATE** - do not proceed to Phase 4 without approval.

---

## Step 1: Architecture Decisions

### Mode-Based Request Classes

Decide on approach:
```php
// Option A: Single Request class (complex)
class StoreOrUpdateRequest extends FormRequest

// Option B: Separate Request classes (recommended)
class StoreRequest extends FormRequest
class UpdateRequest extends FormRequest
```

**Recommendation**: Option B (separate) - clearer validation per mode

### Service Layer Structure

```php
// Option A: Single service with create/update/delete
class ModuleService { create(), update(), delete() }

// Option B: Separate services per form
class ModuleService { create(), update(), delete() }
class ModuleDetailService { create(), update(), delete() }
```

**Recommendation**: Option A for simple modules, Option B for complex

### Authorization Implementation

```php
// Option A: Permission checks in Policy
class ModulePolicy { create(), update(), delete() }

// Option B: Permission checks in Service
class ModuleService { validatePermissions() }
```

**Recommendation**: Option A (Policy) - Laravel standard

---

## Step 2: Detail Complex Logic

For each validation rule found in Phase 1:
- [ ] Required fields list
- [ ] Range validations (min/max)
- [ ] Unique constraints
- [ ] Lookup dependencies
- [ ] Conditional validations
- [ ] Custom business rules

**Example**:
```
FIELD: quantity
TYPE: Range
RULE: min:0.01, max:9999.99
MESSAGE: Qty harus antara 0.01 dan 9999.99
```

---

## Step 3: Create Implementation Spec

File: `.claude/skills/delphi-migration/[MODULE]_PHASE-3-SPEC.md`

```markdown
# [Module] Implementation Specification

## Architecture Decisions

✅ Request Classes: Separate (StoreRequest, UpdateRequest)
✅ Service Structure: Single ModuleService with detail methods
✅ Authorization: Policy-based with MenuAccessService
✅ Validation: Request rules + Service business logic

## Validation Rules Summary

### Required Fields (6 total)
- tgl_bukti: required|date
- kode_supplier: required|exists:dbsupplier,KODESUPPLIER
- details: required|array|min:1

### Range Validations (2 total)
- quantity: numeric|min:0.01|max:9999.99

### Conditional Rules (2 total)
- IF type='Import' THEN pib_number required

## Authorization Model

- Menu Code: 03001
- OL Level: 2 (2 approval levels)
- Permissions:
  - IsTambah → Policy::create()
  - IsKoreksi → Policy::update()
  - IsHapus → Policy::delete()

## Master-Detail Structure

- Master: DbPPL
- Detail: DbPPLDET
- Relationship: one-to-many
- Detail constraint: minimum 1, no maximum
- Detail immutable fields: KodeGdg (after creation)

## File Structure

```
app/Http/Controllers/PPLController.php
app/Http/Requests/PPL/StoreRequest.php
app/Http/Requests/PPL/UpdateRequest.php
app/Services/PPLService.php
app/Services/PPLDetailService.php
app/Policies/PPLPolicy.php
app/Models/DbPPL.php
app/Models/DbPPLDET.php
tests/Feature/PPL/PPLTest.php
resources/views/ppl/
```

## Estimated Work Breakdown

- Model setup: 30 min
- Service logic: 2 hours
- Controller: 1 hour
- Requests: 1 hour
- Policy: 30 min
- Views: 1-2 hours
- Tests: 2 hours
- **Total**: 8-10 hours (estimated for MEDIUM)

## Approval

- [ ] Architecture approved
- [ ] Validation rules verified
- [ ] Authorization model confirmed
- [ ] Timeline acceptable
- [ ] Ready for Phase 4

**Approved by**: _________________
**Approval Date**: _________________
```

---

## Step 4: Get Team Approval

**CRITICAL GATE** - Do not proceed without approval

Required approvals:
- [ ] Project Manager or Team Lead
- [ ] Business Analyst (validation rules correct?)
- [ ] DBA (schema understanding?)
- [ ] Your manager (timeline OK?)

---

## Phase 3 Checklist

- [ ] Architecture decisions documented
- [ ] All validation rules detailed
- [ ] Authorization model defined
- [ ] Master-detail constraints specified
- [ ] File structure planned
- [ ] Work breakdown estimated
- [ ] Implementation spec created
- [ ] All approvals obtained

---

## ⚠️ Do Not Proceed Until Approved

If issues found during Phase 3:
1. Go back to Phase 1 and re-analyze
2. Update specifications
3. Get re-approval
4. Continue to Phase 4

---

## Next Steps

🚨 **APPROVAL GATE** - After approval, proceed to [Phase 4: Implement](./PHASE-4-IMPLEMENT.md)

---

← [Phase 2: Check](./PHASE-2-CHECK.md) | [Phase 4: Implement](./PHASE-4-IMPLEMENT.md) →

**Document Version**: 1.0
**Last Updated**: 2026-01-11
