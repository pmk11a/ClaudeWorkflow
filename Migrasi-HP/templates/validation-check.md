# Validation Checklist: [MODULE_NAME]

> Checklist untuk memastikan semua validasi dari Delphi sudah dimigrasi ke Laravel

**Module**: [MODULE]
**Form**: [FORM_NAME]
**Date**: [DATE]
**Reviewer**: [NAME]

---

## 🔴 CRITICAL - Must Fix Before Production

### P0.1: Database Safety
- [ ] No `migrate:fresh`, `migrate:reset`, `migrate:refresh` anywhere
- [ ] No string concatenation in SQL queries
- [ ] All queries use parameter binding

### P0.2: Authorization
- [ ] All store() methods check create permission
- [ ] All update() methods check update permission
- [ ] All destroy() methods check delete permission
- [ ] Policy file exists and is complete

### P0.3: Data Integrity
- [ ] Multi-step operations wrapped in DB::transaction()
- [ ] NOT NULL columns never set to null (use '' for varchar)
- [ ] Foreign key relationships respected

---

## 🟠 HIGH - Should Fix Soon

### Validation Rules from Delphi

| # | Delphi Validation | Laravel Implementation | ✅/❌ |
|---|------------------|----------------------|------|
| 1 | Empty check: `QuXXX.IsEmpty` | `required` rule | ⬜ |
| 2 | Record exists: `RecordCount > 0` | `exists:table,column` or `->exists()` | ⬜ |
| 3 | Period lock: `IsLockPeriode()` | `LockPeriodService::isLocked()` | ⬜ |
| 4 | Authorization: `CekOtorisasi()` | `AuthorizationService::canAuthorize()` | ⬜ |
| 5 | Numeric range: `Value > 0` | `min:1` or custom rule | ⬜ |
| 6 | Date validation | `date` or `date_format` | ⬜ |
| 7 | Unique check | `unique:table,column` | ⬜ |
| 8 | Dependent validation | Custom rule or Request logic | ⬜ |

### Database Query Validations

| # | Delphi Query | Purpose | Laravel | ✅/❌ |
|---|-------------|---------|---------|------|
| 1 | `SELECT ... FROM dbXXX WHERE ...` | [Purpose] | [Implementation] | ⬜ |
| 2 | `SELECT ... FROM dbXXXDET WHERE ...` | [Purpose] | [Implementation] | ⬜ |

### Error Messages

| # | Delphi Message | Laravel Message | Match? |
|---|---------------|-----------------|--------|
| 1 | `[Indonesian message]` | `[Laravel message]` | ⬜ |
| 2 | `[Indonesian message]` | `[Laravel message]` | ⬜ |

---

## 🟡 MEDIUM - Nice to Have

### Audit Logging

| Operation | Delphi LoggingData | Laravel AuditLog | ✅/❌ |
|-----------|-------------------|------------------|------|
| Insert | `LoggingData(user, 'I', ...)` | `AuditLogService::log(...)` | ⬜ |
| Update | `LoggingData(user, 'U', ...)` | `AuditLogService::log(...)` | ⬜ |
| Delete | `LoggingData(user, 'D', ...)` | `AuditLogService::log(...)` | ⬜ |
| Authorize | `LoggingData(user, 'O', ...)` | `AuditLogService::log(...)` | ⬜ |
| Cancel | `LoggingData(user, 'B', ...)` | `AuditLogService::log(...)` | ⬜ |

### Business Rules

| # | Rule | Implemented | ✅/❌ |
|---|------|-------------|------|
| 1 | [Rule description] | [Where implemented] | ⬜ |
| 2 | [Rule description] | [Where implemented] | ⬜ |

---

## 🔵 LOW - Minor Improvements

### Code Quality

- [ ] All methods have type hints
- [ ] PHPDoc comments on public methods
- [ ] Delphi reference comments (line numbers)
- [ ] PSR-12 formatting (Pint passes)

### UI/UX Parity

- [ ] Form layout matches Delphi form
- [ ] Field order is same
- [ ] Keyboard shortcuts (if applicable)
- [ ] Tab order is logical

---

## Validation Tool Results

### Run Command
```bash
php tools/validate_migration.php [MODULE] [FORM]
```

### Results Summary
```
🔴 CRITICAL: [X]
🟠 HIGH: [X]
🟡 MEDIUM: [X]
🔵 LOW: [X]
```

### Detailed Findings
[Paste validation tool output here]

---

## Test Results

### Unit Tests
```bash
php artisan test --filter=[MODULE]Test
```
Result: ⬜ Pass / ⬜ Fail

### Feature Tests
```bash
php artisan test tests/Feature/[MODULE]Test.php
```
Result: ⬜ Pass / ⬜ Fail

### Manual Tests

| # | Test Case | Steps | Expected | Actual | ✅/❌ |
|---|-----------|-------|----------|--------|------|
| 1 | Create new record | [Steps] | [Expected] | [Actual] | ⬜ |
| 2 | Update existing | [Steps] | [Expected] | [Actual] | ⬜ |
| 3 | Delete record | [Steps] | [Expected] | [Actual] | ⬜ |
| 4 | Lock period block | [Steps] | [Expected] | [Actual] | ⬜ |
| 5 | Permission denied | [Steps] | [Expected] | [Actual] | ⬜ |

---

## Sign-Off

### Checklist Complete
- [ ] All 🔴 CRITICAL items resolved
- [ ] All 🟠 HIGH items resolved or documented
- [ ] Tests passing
- [ ] Code reviewed

### Approvals
| Role | Name | Date | Signature |
|------|------|------|-----------|
| Developer | | | |
| Reviewer | | | |
| QA | | | |

### Notes
[Any additional notes or known issues]

---

*Checklist Version: 1.0*
*Based on RIGOROUS_LOGIC_MIGRATION.md patterns*
