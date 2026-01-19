# Authorization OtoUser NULL Constraint Fix

## Problem

When cancelling authorization (especially level 2+), the application crashed with SQL Server constraint error:

```
SQLSTATE[23000]: [Microsoft][ODBC Driver 17 for SQL Server][SQL Server]
Cannot insert the value NULL into column 'OtoUser2',
table 'dbwbcp2.dbo.DBPPL'; column does not allow nulls.
UPDATE fails.
```

### Root Cause

In `PPLService::cancelAuthorization()`, the code was trying to set `OtoUser{n}` columns to `NULL`:

```php
$ppl->update([
    "IsOtorisasi{$i}" => false,
    "OtoUser{$i}" => null,      // ❌ WRONG - SQL Server rejects NULL
    "TglOto{$i}" => null,
]);
```

But SQL Server schema has `NOT NULL` constraint on all `OtoUser1-5` columns with default value of empty string `''`.

### Database Schema

```
Column      | Type    | Nullable | Default
------------|---------|----------|----------
OtoUser1-5  | varchar | NO       | ''        ❌ CANNOT BE NULL
TglOto1-5   | datetime| YES      | NULL      ✅ CAN BE NULL
```

## Solution

### 1. Fixed `cancelAuthorization()` Method
File: `app/Services/PPLService.php`, lines 490-497

**Changed:**
```php
// Before
"OtoUser{$i}" => null,

// After
"OtoUser{$i}" => '',  // Cannot be NULL (NOT NULL constraint)
```

### 2. Fixed Type Hint in `logActivity()`
File: `app/Services/PPLService.php`, line 673

Made `$user` parameter nullable to handle cases where `auth()->id()` might return null:

```php
// Before
private function logActivity(string $user, ...): void

// After
private function logActivity(?string $user, ...): void
```

## Why This Happens

In Delphi and SQL Server, when you "cancel" an authorization level:
- You clear the authorization flag (`IsOtorisasi{n}` → false)
- You clear the date the authorization was given (`TglOto{n}` → NULL, which is allowed)
- But you **cannot** clear the user who gave authorization (`OtoUser{n}`)
- Instead, use empty string `''` to indicate "no authorization"

This maintains the NOT NULL constraint while semantically indicating the authorization is inactive.

## Testing

### Before Fix
```
User tries to cancel authorization level 2
→ Server tries: UPDATE DBPPL SET OtoUser2 = NULL WHERE Nobukti = 'PR/0001/12/2025'
→ SQL Server rejects: Cannot insert NULL into OtoUser2 column
→ TypeError: Expected string, got null
```

### After Fix
```
User cancels authorization level 2
→ Server executes: UPDATE DBPPL SET OtoUser2 = '', IsOtorisasi2 = 0, TglOto2 = NULL WHERE Nobukti = 'PR/0001/12/2025'
→ Success! Authorization level 2 is cleared
→ OtoUser2 = '' (empty string)
→ IsOtorisasi2 = false
→ TglOto2 = NULL
```

## Database Safety

✅ **Safe Operations:**
- Setting `OtoUser{n}` to empty string `''` (respects NOT NULL constraint)
- Setting `TglOto{n}` to NULL (nullable column)
- Setting `IsOtorisasi{n}` to false

❌ **Unsafe Operations:**
- Setting `OtoUser{n}` to NULL (violates NOT NULL constraint)

## Related Operations

### Cancel Authorization Cascade
When cancelling level N, all levels >= N are cleared:
```php
for ($i = $authLevel; $i <= 5; $i++) {
    // Cancel level $i
}
```

Example: Cancel level 2 → clears levels 2, 3, 4, 5

## Code Quality

- ✅ Syntax verified with `php -l`
- ✅ Code formatted with Laravel Pint
- ✅ Type hints updated for nullable user
- ✅ No breaking changes
- ✅ Logging still works (doesn't throw on null user)

## Files Modified

| File | Changes | Lines |
|------|---------|-------|
| `app/Services/PPLService.php` | Fixed cancelAuthorization() to use empty string instead of NULL; Made logActivity() $user parameter nullable | 494, 673 |

## Validation Query

To verify the fix in database:

```sql
-- Check DBPPL schema constraints
SELECT COLUMN_NAME, IS_NULLABLE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'DBPPL'
AND COLUMN_NAME LIKE '%OtoUser%' OR COLUMN_NAME LIKE '%TglOto%'
ORDER BY COLUMN_NAME;

-- Result:
-- OtoUser1-5: NOT NULL, DEFAULT = ''
-- TglOto1-5:  NULLABLE, DEFAULT = NULL
```

## Backward Compatibility

✅ No breaking changes:
- External API unchanged
- Only internal NULL handling fixed
- Existing records with empty string OtoUser columns unaffected
- Logging still works with nullable user parameter

## Related Issues

- **Issue**: Cancel authorization fails with SQL constraint error
- **Root Cause**: Code tried to set NOT NULL column to NULL
- **Solution**: Use empty string `''` as "no authorization" indicator
- **Impact**: Users can now cancel authorizations without errors
