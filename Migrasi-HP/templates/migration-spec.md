# Migration Specification: [MODULE_NAME]

> Template untuk specification migration Delphi → Laravel
> Gunakan format PITER: Problem, Instructions, Tools, Examples, Review

**Created**: [DATE]
**Status**: Draft / In Progress / Complete
**Complexity**: 🟢 SIMPLE / 🟡 MEDIUM / 🔴 COMPLEX
**Estimated Time**: [X] hours

---

## P - PROBLEM: What Are We Migrating?

### 1. Module Overview
**Module Name**: [e.g., Permintaan Pembelian (PPL)]
**Menu Code**: [e.g., 03001]
**Description**: [Brief description of what this module does]

### 2. Delphi Source Files
```
.pas file: d:\ykka\migrasi\pwt\[path]\[FormName].pas
.dfm file: d:\ykka\migrasi\pwt\[path]\[FormName].dfm
Dependencies: MyProcedure.pas, [other shared units]
```

### 3. Current State (Delphi)
- **Lines of Code**: [X] lines
- **Forms**: [List forms: main form, child forms]
- **Tables**: [List database tables used]
- **Procedures**: [Key procedures to migrate]

### 4. Target State (Laravel)
- **Model(s)**: Db[TABLE].php
- **Service**: [MODULE]Service.php
- **Controller**: [MODULE]Controller.php
- **Views**: resources/views/[module]/

---

## I - INSTRUCTIONS: Requirements

### Functional Requirements

#### Mode Operations (Choice:Char)
| Mode | Delphi | Laravel | Status |
|------|--------|---------|--------|
| Insert (I) | `Choice='I'` → `UpdateData()` | `store()` + StoreRequest | ⬜ |
| Update (U) | `Choice='U'` → `UpdateData()` | `update()` + UpdateRequest | ⬜ |
| Delete (D) | `Choice='D'` → `UpdateData()` | `destroy()` + authorization | ⬜ |

#### Permissions
| Permission | Delphi Check | Laravel Implementation | Status |
|------------|-------------|----------------------|--------|
| Create | `IsTambah` | `can('create', Model::class)` | ⬜ |
| Update | `IsKoreksi` | `can('update', $model)` | ⬜ |
| Delete | `IsHapus` | `can('delete', $model)` | ⬜ |
| Print | `IsCetak` | `can('print', $model)` | ⬜ |

#### Validations to Migrate
| # | Delphi Code | Type | Laravel Equivalent | Status |
|---|-------------|------|-------------------|--------|
| 1 | `if QuXXX.IsEmpty then` | Empty check | `required` validation | ⬜ |
| 2 | `RecordCount > 0` | Exists check | `exists:table,column` | ⬜ |
| 3 | `IsLockPeriode()` | Period lock | `LockPeriodService` | ⬜ |
| 4 | `CekOtorisasi()` | Authorization | `AuthorizationService` | ⬜ |
| 5 | [More validations...] | | | ⬜ |

#### Business Rules
| # | Rule Description | Delphi Location | Status |
|---|-----------------|-----------------|--------|
| 1 | [Rule 1] | Line XXX | ⬜ |
| 2 | [Rule 2] | Line XXX | ⬜ |

### Non-Functional Requirements
- [ ] Response time < 500ms for CRUD operations
- [ ] All operations logged to DBLOGFILE
- [ ] Indonesian error messages
- [ ] Works with existing database (no schema changes)

---

## T - TOOLS: Technical Design

### Database Tables
| Table | Model | Purpose | Columns (key) |
|-------|-------|---------|--------------|
| [TABLE] | Db[TABLE] | Main data | [key columns] |
| [TABLEDET] | Db[TABLEDET] | Detail data | [key columns] |

### API Endpoints
| Method | Route | Controller@Method | Purpose |
|--------|-------|------------------|---------|
| GET | /[module] | [Module]Controller@index | List all |
| GET | /[module]/create | [Module]Controller@create | Show create form |
| POST | /[module] | [Module]Controller@store | Create new |
| GET | /[module]/{id} | [Module]Controller@show | Show detail |
| GET | /[module]/{id}/edit | [Module]Controller@edit | Show edit form |
| PUT | /[module]/{id} | [Module]Controller@update | Update |
| DELETE | /[module]/{id} | [Module]Controller@destroy | Delete |

### Files to Create/Modify
| File | Action | Purpose |
|------|--------|---------|
| app/Models/Db[TABLE].php | Create/Modify | Eloquent model |
| app/Services/[MODULE]Service.php | Create | Business logic |
| app/Http/Controllers/[MODULE]Controller.php | Create | HTTP handling |
| app/Http/Requests/[MODULE]/StoreRequest.php | Create | Store validation |
| app/Http/Requests/[MODULE]/UpdateRequest.php | Create | Update validation |
| app/Policies/[MODULE]Policy.php | Create | Authorization |
| resources/views/[module]/*.blade.php | Create | UI templates |
| routes/web.php | Modify | Add routes |
| tests/Feature/[MODULE]Test.php | Create | Tests |

### Dependencies
- [ ] Check `MyProcedure.pas` for: [list shared procedures used]
- [ ] Related modules: [list modules this depends on]
- [ ] External services: [list if any]

---

## E - EXAMPLES: Reference Patterns

### Similar Completed Migrations
1. **[MODULE_A]** - migrations-registry/successful/[MODULE_A]_COMPLETE.md
   - Similar because: [reason]
   - Key pattern to reuse: [pattern]

2. **[MODULE_B]** - migrations-registry/successful/[MODULE_B]_COMPLETE.md
   - Similar because: [reason]
   - Key pattern to reuse: [pattern]

### Relevant Lessons Learned
1. **[LESSON_1]** - ai_docs/lessons/[LESSON].md
   - Applicable to: [which part of this migration]

2. **[LESSON_2]** - ai_docs/lessons/[LESSON].md
   - Applicable to: [which part of this migration]

### Code Pattern Examples
```php
// Example: Mode operation pattern from [SIMILAR_MODULE]
public function updateData(array $data, string $choice): void
{
    DB::transaction(function () use ($data, $choice) {
        switch ($choice) {
            case 'I':
                $this->create($data);
                break;
            case 'U':
                $this->update($data);
                break;
            case 'D':
                $this->delete($data);
                break;
        }
        
        $this->logActivity($choice, $data);
    });
}
```

---

## R - REVIEW: Acceptance Criteria

### Must Pass Before Sign-Off

#### Functionality
- [ ] All mode operations (I/U/D) work correctly
- [ ] All permissions enforced
- [ ] All validations from Delphi migrated
- [ ] Audit logging complete for all operations
- [ ] Lock period protection working

#### Code Quality
- [ ] `php artisan test` passes
- [ ] `./vendor/bin/pint` shows no issues
- [ ] No SQL injection vulnerabilities
- [ ] Transactions wrap multi-step operations
- [ ] Type hints on all methods

#### Documentation
- [ ] Delphi reference comments in code
- [ ] PHPDoc on public methods
- [ ] Migration summary created

### Quality Metrics
| Metric | Target | Actual |
|--------|--------|--------|
| Mode Coverage | 100% | ⬜ |
| Permission Coverage | 100% | ⬜ |
| Validation Coverage | 95%+ | ⬜ |
| Audit Coverage | 100% | ⬜ |
| Test Coverage | 80%+ | ⬜ |

### Validation Tool Results
```bash
# Run after implementation
php tools/validate_migration.php [MODULE] [FORM]

# Expected: No CRITICAL gaps
```

---

## Implementation Plan

### Phase 1: Core (Estimated: [X] hours)
1. ⬜ Create/Update Model
2. ⬜ Create Service with business logic
3. ⬜ Create Requests (Store, Update)
4. ⬜ Create Policy

### Phase 2: Controller & Routes (Estimated: [X] hours)
1. ⬜ Create Controller
2. ⬜ Add routes to web.php
3. ⬜ Test API endpoints

### Phase 3: Views (Estimated: [X] hours)
1. ⬜ Create index view
2. ⬜ Create create/edit form
3. ⬜ Create show view
4. ⬜ Add to sidebar/dashboard

### Phase 4: Testing (Estimated: [X] hours)
1. ⬜ Write unit tests
2. ⬜ Write feature tests
3. ⬜ Manual testing
4. ⬜ Run validation tool

### Phase 5: Documentation (Estimated: [X] hours)
1. ⬜ Add Delphi references to code
2. ⬜ Create migration summary
3. ⬜ Update lessons learned

---

## Notes for Agent

### DO ✅
- Follow existing patterns in app/
- Check ai_docs/patterns/ for similar cases
- Run validation tools after implementation
- Use transactions for multi-step operations
- Add Indonesian error messages
- Reference Delphi line numbers in comments

### DON'T ❌
- Create new database tables
- Skip authorization checks
- Use string concatenation in SQL
- Comment out validations
- Set NOT NULL varchar columns to null (use '' instead)
- Skip audit logging

### Key Gotchas for This Module
1. [Gotcha 1 - specific to this module]
2. [Gotcha 2 - specific to this module]

---

*Template Version: 1.0*
*Based on Codebase Singularity PITER Framework*
