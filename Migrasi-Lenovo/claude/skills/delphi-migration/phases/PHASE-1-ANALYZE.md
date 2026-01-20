# Phase 1: Analyze & Extract Business Logic

---

## ⚡ ADW Automation (Recommended)

**This entire phase is automated in ADW!**

```bash
# Run ADW to auto-analyze Delphi files
./scripts/adw/adw-migration.sh <MODULE>
```

**What ADW Does Automatically**:
- ✅ Extracts all I/U/D mode procedures
- ✅ Maps all permission variables (IsTambah/IsKoreksi/IsHapus)
- ✅ Detects all 8 validation patterns
- ✅ Identifies authorization levels (OL value)
- ✅ Maps audit logging calls
- ✅ Discovers field dependencies
- ✅ Extracts master-detail structure

**Time Saved**: 2-3 hours → 15 minutes (87% faster)

**For Manual Steps**: Follow instructions below (if ADW unavailable)

---

**⏱️ Estimated Time**: 2-3 hours

**🎯 Objective**: Deep dive into Delphi source code to extract and document all business logic, permissions, validation rules, and authorization workflows that need to be migrated.

---

## Step 1: Extract Mode-Based Operations (Pattern 1)

### Find Choice:Char Procedures

**In Delphi file, search for**:
```pascal
Procedure UpdateData*(Choice:Char)
// or variations like:
Procedure SaveData(Mode: String)
Procedure XXXProcess(Choice:Char)
```

### Document Each Mode

For each procedure found, extract:

**INSERT Mode (Choice='I')**:
- Line numbers where INSERT logic starts/ends
- Parameters passed to stored procedure
- Business rules checked (validations)
- Post-processing (queries refreshed, events fired)

**UPDATE Mode (Choice='U')**:
- Line numbers where UPDATE logic starts/ends
- Which fields can be updated (immutable fields?)
- Different validations vs INSERT
- Lookup refreshes needed

**DELETE Mode (Choice='D')**:
- Line numbers where DELETE logic starts/ends
- Pre-delete checks (authorization, lock periods)
- Cascade delete requirements
- Related records cleanup

**Record in spreadsheet**:
| Procedure | Lines | INSERT | UPDATE | DELETE | Notes |
|-----------|-------|--------|--------|--------|-------|
| UpdateDataPPL | 425-550 | ✅ | ✅ | ✅ | Simple CRUD |
| UpdateDataDetail | 620-680 | ✅ | ⚠️ Immutable | ❌ No delete | Detail only |

---

## Step 2: Extract Permission Checks (Pattern 2)

### Find Permission Variables

**Search for**:
```pascal
IsTambah, IsKoreksi, IsHapus, IsCetak, IsExcel: Boolean
```

### Document Permissions

For each permission found:
- [ ] IsTambah (Create permission)
- [ ] IsKoreksi (Update permission)
- [ ] IsHapus (Delete permission)
- [ ] IsCetak (Print permission)
- [ ] IsExcel (Export permission)

**Where loaded**:
```pascal
// Usually in FormCreate or FormShow
IsTambah := GetPermission('ISTAMBAH');
```

**How checked**:
```pascal
if not IsTambah then
  ShowMessage('Anda tidak memiliki akses');
```

---

## Step 3: Extract Validation Rules (Pattern 4)

### Find All Validation Checks

Search for patterns:

**Required Fields**:
```pascal
if EdtField.Text = '' then
  raise Exception.Create('Field harus diisi');
```

**Range Validation**:
```pascal
if Value.AsFloat < MinValue then
  raise Exception.Create('Value too low');
```

**Unique Checks**:
```pascal
if QuCheck.Locate('Field', Value, []) then
  raise Exception.Create('Sudah ada');
```

**Lookup Validation**:
```pascal
if not QuTable.Locate('Code', EdtCode.Text, []) then
  raise Exception.Create('Not found');
```

**Conditional Validation**:
```pascal
if TipeBarang = 'Jadi' then
  if EdtProses.Text = '' then
    raise Exception.Create('...');
```

### Map 8 Validation Patterns

Create table with all validations:

| Field | Pattern Type | Rule | Error Message |
|-------|--------------|------|---------------|
| tgl_bukti | Required | required | Tanggal harus diisi |
| tgl_bukti | Format | date_format:Y-m-d | Format tanggal salah |
| kode_supplier | Lookup | exists:dbsupplier,KODESUPPLIER | Supplier tidak ditemukan |
| quantity | Range | min:0.01 | Qty harus lebih dari 0 |

---

## Step 4: Extract Authorization Workflow (Pattern 5)

### Find Authorization Fields

Search for in table structure or procedure:
```
IsOtorisasi1, IsOtorisasi2, IsOtorisasi3, IsOtorisasi4, IsOtorisasi5
OtoUser1, OtoUser2, OtoUser3, ...
TglOto1, TglOto2, TglOto3, ...
```

### Document Workflow

**Steps**:
1. User creates document (IsOtorisasi1 = 0)
2. Level 1 approver authorizes (IsOtorisasi1 = 1, OtoUser1 = user, TglOto1 = now)
3. Level 2 approver authorizes (IsOtorisasi2 = 1)
4. Document locked for editing after full authorization

**Constraints**:
- [ ] Cannot edit if any IsOtorisasi = 1
- [ ] Cannot delete if any IsOtorisasi = 1
- [ ] Must authorize in order (L2 requires L1 first)
- [ ] Can cancel authorization (clears that level + higher)

**From Phase 0**: Confirm OL value determines max levels

---

## Step 5: Extract Audit Logging (Pattern 6)

### Find LoggingData Calls

Search for:
```pascal
LoggingData(IDUser, Choice, 'ModuleName', NoBukti, Description);
```

### Document Logging

**When called**:
- After INSERT (Choice='I')
- After UPDATE (Choice='U')
- After DELETE (Choice='D')
- After AUTHORIZATION (Choice='O')

**Parameters passed**:
- User ID
- Operation mode
- Module name
- Document number
- Description (often contains field values)

---

## Step 6: Extract Field Dependencies (Pattern 3)

### Find OnChange Handlers

Search for:
```pascal
procedure OnFieldChange(Sender: TObject);
procedure GudangChange(Sender: TObject);
```

### Document Dependencies

**Example**: Warehouse → SPK Items
```
When: GudangChange event fires
Action: Query DBSPKDET WHERE KodeGdg = selected warehouse
Load into: ComboBox or StringGrid
```

| Source Field | Event | Target Field | Action |
|---|---|---|---|
| Warehouse | Change | SPK Items | Query and load dropdown |
| Supplier | Change | Supplier Name | Query and populate |
| Type | Change | Panels | Show/hide based on type |

---

## Step 7: Extract Master-Detail Structure (Pattern 7)

### Identify Master-Detail Relationship

**Master table**:
```
DbPPL (document header)
- NOBUKTI (primary key)
- TglBukti
- KodeSupplier
```

**Detail table**:
```
DbPPLDET (line items)
- NOBUKTI (foreign key to DbPPL)
- NoUrut (line number)
- KODEBRG
- Qnt
```

### Document Constraints

- [ ] Single-item detail (only 1 line allowed)? OR Multiple items?
- [ ] Can add lines after creation?
- [ ] Can delete lines?
- [ ] Minimum lines required?
- [ ] Maximum lines allowed?

---

## Step 8: Create Patterns Summary

### Generate Analysis Document

File: `.claude/skills/delphi-migration/[MODULE]_PHASE-1-ANALYSIS.md`

```markdown
# [Module] - Phase 1 Analysis

## Patterns Detected

✅ Pattern 1: Mode Operations - Found UpdateData* procedures
  - Lines 425-550: INSERT (Choice='I')
  - Lines 560-620: UPDATE (Choice='U')
  - Lines 625-680: DELETE (Choice='D')

✅ Pattern 2: Permissions - Found 5 permission variables
  - IsTambah, IsKoreksi, IsHapus, IsCetak, IsExcel

✅ Pattern 4: Validation Rules - Found 8 validation patterns
  - Required fields: 6
  - Range checks: 2
  - Unique checks: 1
  - Lookup validation: 3
  - Conditional: 2
  - Total: 14 rules to implement

✅ Pattern 5: Authorization - OL=2 (2 approval levels)
  - IsOtorisasi1, IsOtorisasi2
  - Cannot edit after authorization

✅ Pattern 6: Audit Logging - Found LoggingData calls
  - After each I/U/D operation
  - Total: 4 logging calls identified

✅ Pattern 3: Field Dependencies - 2 dependencies found
  - Warehouse → SPK Items dropdown
  - Type → Panel visibility

✅ Pattern 7: Master-Detail
  - Master: DbPPL
  - Detail: DbPPLDET
  - Multiple items allowed
  - Minimum 1 line required

## Coverage Assessment

- Mode Coverage: 100% (all 3 modes implemented)
- Permission Coverage: 100% (all 5 permissions mapped)
- Validation Coverage: ~95% (14 of 15 rules detected)
- Authorization Coverage: 100% (OL=2 workflow complete)
- Audit Coverage: 100% (all operations logged)

## Complexity Breakdown

- Classes/Procedures: 8 major procedures
- Decision Points: 12+ branching conditions
- Business Rules: 8 distinct validation rules
- External Dependencies: 5 tables referenced

## Next Phase

Ready for Phase 2: Check existing Laravel implementation

→ [Phase 2: Check](./PHASE-2-CHECK.md)
```

---

## Phase 1 Checklist

- [ ] All I/U/D mode procedures identified
- [ ] All permission variables extracted
- [ ] All validation rules documented
- [ ] Authorization workflow understood
- [ ] Master-detail structure identified
- [ ] Field dependencies mapped
- [ ] Audit logging points identified
- [ ] Analysis document created
- [ ] Complexity updated if needed

---

## Common Analysis Mistakes

| ❌ Wrong | ✅ Correct |
|---------|----------|
| Assuming fields in UPDATE are all updatable | Check for immutable field logic |
| Missing authorization levels | Verify OL value = number of levels |
| Assuming all fields are required | Check validation exceptions |
| Skipping field dependencies | Test each OnChange handler |

---

## Next Steps

✅ **Phase 1 Complete** → Proceed to [Phase 2: Check](./PHASE-2-CHECK.md)

---

**Document Version**: 1.0
**Last Updated**: 2026-01-11

← [Phase 0: Discovery](./PHASE-0-DISCOVERY.md) | [Phase 2: Check](./PHASE-2-CHECK.md)
