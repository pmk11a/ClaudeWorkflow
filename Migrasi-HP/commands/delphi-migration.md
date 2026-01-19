# /delphi-migration Command

Start a Delphi to Laravel migration using the PITER framework.

## Usage
```
/delphi-migration <module> "<FormName.pas FormName.dfm>"
```

## Example
```
/delphi-migration PPL "FrmPPL.pas FrmPPL.dfm"
```

## What This Command Does

### Phase 0: Discovery (30 min)
1. Find Delphi source files in `d:\ykka\migrasi\pwt\`
2. Identify module complexity (SIMPLE/MEDIUM/COMPLEX)
3. Create specification from template

### Phase 1: Analysis (2-3h)
1. Read CLAUDE.md for project context
2. Parse Delphi .pas file for:
   - Mode operations (Choice:Char patterns)
   - Permissions (IsTambah, IsKoreksi, IsHapus)
   - Validations (IsLockPeriode, database checks)
   - Audit logging (LoggingData calls)
3. Document findings

### Phase 2: Check Existing (1-2h)
1. Search for existing Laravel implementation
2. Check migrations-registry/ for similar patterns
3. Load lessons learned from ai_docs/lessons/

### Phase 3: Plan (1-2h) → 🚨 APPROVAL REQUIRED
1. Create implementation plan
2. Define files to create
3. **STOP AND GET USER APPROVAL**

### Phase 4: Implement (4-6h)
1. Create Model (Db*.php)
2. Create Service (*Service.php)
3. Create Requests (Store/Update)
4. Create Policy
5. Create Controller
6. Create Views
7. Add Routes
8. Write Tests

After EACH file:
- Run: `php artisan test`
- Run: `./vendor/bin/pint`

### Phase 5: Test (3-5h) → 🚨 SIGN-OFF REQUIRED
1. Run validation tool
2. Run all tests
3. Manual testing
4. **GET USER SIGN-OFF**

## Complexity Levels

| Level | Time | Characteristics |
|-------|------|-----------------|
| 🟢 SIMPLE | 2-4h | Basic CRUD, single form, <500 lines |
| 🟡 MEDIUM | 4-8h | Master-detail, business rules, 2-3 lookups |
| 🔴 COMPLEX | 8-12h | Multiple forms, algorithms, stock impact |

## Critical Rules

### DO ✅
- Follow existing patterns in app/
- Use transactions for multi-step operations
- Add Indonesian error messages
- Reference Delphi line numbers in comments
- Run validation tool after implementation

### DON'T ❌
- Create new database tables
- Skip authorization checks
- Use string concatenation in SQL
- Set NOT NULL columns to null (use '' instead)
- Skip audit logging

## Resources to Read First

1. `CLAUDE.md` - Project overview
2. `ai_docs/patterns/MIGRATION_PATTERNS.md` - Common patterns
3. `ai_docs/lessons/` - Lessons from past migrations
4. `migrations-registry/successful/` - Completed examples

## Validation Command

After implementation, run:
```bash
php tools/validate_migration.php <MODULE> <FORM>
```

Expected: No CRITICAL or HIGH gaps.
