---
name: delphi-laravel-migration-prompts
description: Ready-to-use prompt templates for triggering the delphi-laravel-migration skill
---

# Delphi-to-Laravel Migration - Prompt Templates

Copy and adapt these templates to trigger the migration skill effectively.

---

## Template 1: Analyze Delphi Form (Quick Analysis)

**When to use**: You have a Delphi form and want to understand what patterns it uses

```
I need to migrate a Delphi form to Laravel. Please analyze this form structure:

Form: FrmAktiva.pas (from d:\ykka\migrasi\pwt\Master\AktivaTetap\FrmAktiva.pas)

Questions:
1. What permission checks does this form use? (IsTambah, IsKoreksi, IsHapus, etc.)
2. What mode-dependent operations exist? (Choice parameter with I/U/D modes)
3. What validation rules are implemented?
4. Are there field dependencies or conditional validations?
5. What logging is done? (LoggingData calls)

Please provide a summary of the business logic that needs to be preserved during migration.
```

---

## Template 2: Migrate Mode-Based Operations

**When to use**: Your Delphi form has a Choice parameter with I/U/D (Insert/Update/Delete) modes

```
I need to migrate this Delphi procedure to Laravel. It has mode-dependent logic:

Delphi Code:
```pascal
Procedure TFrAktiva.UpdateDataAktivaTetap(Choice:Char);
begin
  if (Choice='D') then
    // DELETE mode: only parameter ID
  else
    // INSERT/UPDATE mode: all parameters
  end;

  if Choice='I' then
    LoggingData(IDUser, 'I', 'Aktiva', '', 'Kode = ...');
  else if Choice='U' then
    LoggingData(IDUser, 'U', 'Aktiva', '', 'Kode = ...');
  else if Choice='D' then
    LoggingData(IDUser, 'D', 'Aktiva', '', 'Kode = ...');
end;
```

Please help me:
1. Create mode-specific Laravel request classes (StoreAktivaRequest, UpdateAktivaRequest)
2. Create a service layer that separates the I/U/D logic
3. Show how to map the LoggingData calls to Laravel AuditLog
4. Show the controller methods that use these requests/services

Reference the Delphi-to-Laravel Migration skill if needed.
```

---

## Template 3: Migrate Permission Checks

**When to use**: Your Delphi form has permission variables like IsTambah, IsKoreksi, IsHapus

```
I need to translate Delphi permission checks to Laravel authorization.

Delphi Code has:
- IsTambah (user can add)
- IsKoreksi (user can edit)
- IsHapus (user can delete)
- IsCetak (user can print)
- IsExcel (user can export)

With checks like:
```pascal
if not IsTambah then
  ShowMessage('Anda tidak memiliki akses untuk menambah data');

if not IsKoreksi then
  ShowMessage('Anda tidak memiliki akses untuk koreksi data');

if not IsHapus then
  ShowMessage('Anda tidak memiliki akses untuk hapus data');
```

Please:
1. Create request authorization classes that map IsTambah → create, IsKoreksi → update, IsHapus → delete
2. Create a Laravel Policy class for fine-grained permission control
3. Show how to implement these in the controller
4. Provide the proper error messages when authorization fails

Use the Delphi-to-Laravel Migration skill for reference.
```

---

## Template 4: Migrate Validation Rules

**When to use**: Your Delphi form has complex validation logic

```
I need to translate these Delphi validation rules to Laravel validation:

Delphi Code:
```pascal
// Range validation
if EdtQuantity.Value < 1 then
  raise Exception.Create('Qty minimal 1');
if EdtQuantity.Value > 999999 then
  raise Exception.Create('Qty maksimal 999999');

// Unique validation
if QuCheck.Locate('KodeAktiva', EdtKodeAktiva.Text, []) then
  raise Exception.Create('Kode sudah ada');

// Cross-field validation
if EdtAmount.Value > EdtCreditLimit.Value then
  raise Exception.Create('Amount melebihi credit limit');

// Conditional validation
if EdtProductType.Text = 'IMPORT' then
  if EdtCountryOrigin.Text = '' then
    raise Exception.Create('Negara asal wajib diisi untuk produk IMPORT');

// Format validation
if not IsValidDate(EdtDate.Text) then
  raise Exception.Create('Format tanggal tidak valid');
```

Please:
1. Create a Laravel request class with all validation rules
2. Use appropriate validators: min, max, unique, required_if, date_format, etc.
3. Create custom validation rules for complex logic (cross-field, calculated)
4. Map the error messages appropriately

Reference the 8 validation patterns in the Delphi-to-Laravel Migration skill.
```

---

## Template 5: Migrate Field Dependencies

**When to use**: Your Delphi form has conditional field visibility or requirements

```
I need to migrate this Delphi field dependency logic to Laravel:

Delphi Code:
```pascal
procedure TFrBarang.OnCodeChange(Sender: TObject);
begin
  // If code contains 'GIFT', require gift card field
  if Pos('GIFT', EdtCode.Text) > 0 then
  begin
    EdtGiftCard.Visible := True;
    EdtGiftCard.Required := True;
  end
  else
  begin
    EdtGiftCard.Visible := False;
    EdtGiftCard.Required := False;
    EdtGiftCard.Clear;
  end;

  // If code contains 'IMPORT', require customs fields
  if Pos('IMPORT', EdtCode.Text) > 0 then
  begin
    EdtCountryOrigin.Required := True;
    EdtTariffCode.Required := True;
    EdtHSCode.Required := True;
  end
  else
  begin
    EdtCountryOrigin.Required := False;
    EdtTariffCode.Required := False;
    EdtHSCode.Required := False;
  end;
end;
```

Please:
1. Create Laravel request classes with conditional validation rules
2. Show how to expose field visibility status in API responses
3. Show how to implement cascading updates when parent field changes
4. Provide a frontend example (Vue/React) showing conditional field rendering

Use Pattern 3 from the Delphi-to-Laravel Migration skill.
```

---

## Template 6: Complete Form Migration

**When to use**: You want to migrate an entire Delphi form with all business logic

```
I need to completely migrate this Delphi form to Laravel with 100% business logic preservation:

**Delphi Form**: FrmAktiva
**Location**: d:\ykka\migrasi\pwt\Master\AktivaTetap\FrmAktiva.pas
**Related Files**: d:\ykka\migrasi\pwt\Unit\MyProcedure.pas (LoggingData, permission checks)

**What needs to be migrated**:
1. ✓ Mode-based operations (UpdateDataAktivaTetap with Choice parameter)
2. ✓ Permission checks (IsTambah, IsKoreksi, IsHapus, IsCetak, IsExcel)
3. ✓ Validation rules (range, unique, cross-field)
4. ✓ Field dependencies (conditional visibility/requirements)
5. ✓ Audit logging (LoggingData calls)
6. ✓ Error handling (try/except patterns)

**Reference Laravel Code**:
- Controller: d:\ykka\migrasi\app\Http\Controllers\AktivaController.php
- Service: d:\ykka\migrasi\app\Services\AktivaService.php

**Deliverables needed**:
1. AktivaRequest classes (Store, Update, Delete variants with mode-specific validation)
2. AktivaService layer (register, update, delete methods with audit logging)
3. AktivaPolicy class (authorization for all operations)
4. Updated AktivaController with proper authorization checks
5. Database migration if needed
6. Test cases for each mode and permission

Please follow the Delphi-to-Laravel Migration skill's comprehensive guide and use the real examples from the PWt/Laravel codebase as reference.
```

---

## Template 7: Clarify Specific Pattern

**When to use**: You want to understand how to implement a specific pattern

```
I'm working on migrating a Delphi form and I need clarification on [specific pattern]:

**My Delphi Code**:
[Paste your specific Delphi code here]

**What I need to understand**:
- How does this map to Laravel?
- What request class/validation is needed?
- Where does this logic go in the service layer?
- How do I test this?

**Context**:
- Is this mode-specific logic? (INSERT/UPDATE/DELETE)
- Is this a permission check? (IsTambah/IsKoreksi/IsHapus)
- Is this a validation rule? (range, unique, cross-field, etc.)
- Is this field dependency logic?
- Is this audit logging?

Please provide:
1. Step-by-step Laravel equivalent
2. Complete code example
3. Where to place this code
4. How to test it

Reference the appropriate pattern from the Delphi-to-Laravel Migration skill.
```

---

## Template 8: Implement with Real Examples

**When to use**: You want to see exactly how to implement something based on real project code

```
I'm migrating [form name] from Delphi and want to see exactly how to implement [pattern type].

**Real Delphi Example**:
File: [file path in d:\ykka\migrasi\pwt\...]
Lines: [line numbers]
Pattern: [which pattern - mode/permission/validation/dependency/logging]

**Real Laravel Reference**:
File: [file path in d:\ykka\migrasi\app\...]
Pattern: [how it's implemented in reference]

**What I need**:
1. Side-by-side comparison (Delphi → Laravel)
2. Complete implementation for my form
3. Explanation of why it's done this way
4. How to test it

Please show me the exact code I should write, adapted for my specific form.
```

---

## Template 9: Ask for Best Practices

**When to use**: You want guidance on how to organize the migration for maintainability

```
I'm about to migrate multiple Delphi forms to Laravel and want to ensure best practices:

**Forms to migrate**:
1. FrmAktiva (complex: modes, permissions, validation, logging)
2. FrmBarang (medium: permissions, validation)
3. FrmArea (simple: basic CRUD)

**Questions**:
1. What's the best project structure for these services/requests/policies?
2. How should I organize the code for maintainability?
3. What testing strategy should I use?
4. How do I handle shared business logic (from MyProcedure.pas)?
5. Should I create traits or base classes for common patterns?

**Constraints**:
- Following existing Laravel conventions in d:\ykka\migrasi\app\
- Using AuditLog for all changes
- Implementing proper authorization
- 95%+ logic preservation requirement

Please guide me through the best approach using the Delphi-to-Laravel Migration skill.
```

---

## Template 10: Quick Reference Lookup

**When to use**: You just need a quick lookup of how something maps

```
Quick reference: How do I translate this Delphi pattern to Laravel?

[Choose one]:
1. Choice:Char parameter (I/U/D modes) → ?
2. IsTambah/IsKoreksi/IsHapus → ?
3. if EdtField.Value > X then → ?
4. if QuTable.Locate(field, value, []) then → ?
5. LoggingData(IDUser, Choice, Table, '', Msg) → ?
6. try/except with ShowMessage → ?
7. OnChange handler with field visibility → ?
8. Required := True/False based on condition → ?

Show me:
- The Laravel equivalent
- Quick code snippet
- Where to put it
- One real example

Use the Delphi-to-Laravel Migration skill.
```

---

## Tips for Using These Templates

### ✅ Best Practices

1. **Be Specific**: Include actual code from your Delphi form
2. **Reference Real Files**: Use paths from your project
3. **State Your Goal**: What do you want to achieve?
4. **Provide Context**: Is it insert/update/delete mode? Permission-based?
5. **Ask for Examples**: Request code you can copy/adapt

### ❌ Avoid

- Generic "how to migrate" without specifics
- Vague questions without code examples
- Ignoring the real codebase in PWt/Laravel folders
- Not specifying which pattern (mode/permission/validation)

### 🎯 Pro Tips

1. **Reference real examples first**: Look at FrmAktiva.pas → AktivaController.php
2. **One pattern at a time**: Don't mix 5 patterns in one question
3. **Copy the template**: Adapt it for your specific needs
4. **Include line numbers**: Makes it easier to find in source code
5. **Ask for tests**: Always request test cases for complex logic

---

## Quick Prompt Builders

### Mode-Based Form
```
I have a Delphi form with procedure UpdateData(Choice:Char) where:
- Choice='I' → INSERT mode
- Choice='U' → UPDATE mode
- Choice='D' → DELETE mode

Show me how to convert this to Laravel with mode-specific validation.
```

### Permission-Based Form
```
My Delphi form checks: IsTambah, IsKoreksi, IsHapus

Show me how to implement this in Laravel with Request authorization + Policy.
```

### Complex Validation Form
```
My Delphi form has this validation:
[paste code]

Show me the Laravel validation rules and any custom rules needed.
```

### Everything Combined
```
Form: [name]
File: [path]
Patterns: mode operations + permission checks + validation

Show me complete implementation using the migration skill.
```

---

## Response Format to Expect

When you use these templates, the skill will provide:

✅ **Code Examples**
- Delphi source with line references
- Laravel equivalent
- Ready to copy/adapt

✅ **Structure Guidance**
- Where each piece goes
- File organization
- Best practices

✅ **Real Project References**
- Links to actual code in PWt/Laravel
- Line numbers for easy lookup
- Patterns you can follow

✅ **Testing Guidance**
- How to test each mode
- Permission testing
- Validation testing

---

**Ready to migrate?** Pick a template above and adapt it to your Delphi form!

---

**Last Updated**: 2025-12-18
**Skill**: delphi-laravel-migration v2.0
