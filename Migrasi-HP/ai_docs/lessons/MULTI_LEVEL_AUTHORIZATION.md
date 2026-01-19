# Multi-Level Authorization Implementation (PPL)

## Overview

Implemented database-driven multi-level authorization workflow for Purchase Request (PPL) following Delphi authorization concept from `MyProcedure.pas`.

**Key Improvement**: Authorization is now **dynamic and database-driven**, not hardcoded.

## Delphi Reference

| Delphi Concept | Delphi Code | Laravel Implementation |
|---|---|---|
| User authorization level | `dbFlpass.Tingkat` | `AuthorizationService::getUserAuthLevel()` |
| Menu max authorization level | `dbMenu.OL` | `AuthorizationService::getMenuMaxLevel()` |
| Authorization validation | `MyProcedure.CekOtorisasi()` line 839 | `AuthorizationService::canAuthorizeLevel()` |
| Cancel authorization | `MyProcedure.BatalOtorisasi()` line 718 | `AuthorizationService::canCancelAuthorizationLevel()` |
| Display auth columns | `MyProcedure.ViewOtorisasi()` line 191 | `AuthorizationService::getVisibleAuthLevels()` |

## Database Configuration

### PPL Menu Definition

```sql
SELECT KODEMENU, Keterangan, OL FROM DBMENU
WHERE KODEMENU = '03001'
-- Result: 03001 | Permintaan Pembelian (PR) | 2
```

- **Menu Code**: `03001`
- **Max Authorization Levels**: `2` (OL field)
- Only 2 levels of authorization needed for PPL

### User Authorization Levels

```sql
SELECT USERID, Tingkat FROM DBFLPASS
-- Tingkat (0-5): User's maximum authorization level
-- 0 = No authorization capability
-- 1 = Can authorize level 1 only
-- 2 = Can authorize levels 1-2
-- etc.
```

### User Menu Permissions

```sql
SELECT USERID, KODEMENU, IsTambah, IsKoreksi, IsHapus, IsCetak
FROM DBFLMENU
WHERE KODEMENU = '03001'
-- IsTambah: Can Create
-- IsKoreksi: Can Update/Correct
-- IsHapus: Can Delete
-- IsCetak: Can Print
```

## Authorization Rules

### 1. User Authorization Level Check

```php
// User's Tingkat must be >= requested level
if ($userLevel < $requestedLevel) {
    throw "Anda hanya bisa otorisasi hingga level {$userLevel}";
}
```

**Example**:
- User with `Tingkat=2` can authorize levels 1 and 2
- User with `Tingkat=1` can only authorize level 1
- User with `Tingkat=0` cannot authorize anything

### 2. Menu Max Level Enforcement

```php
// Cannot authorize beyond menu's max OL level
if ($requestedLevel > $menuMaxLevel) {
    throw "Menu ini hanya memerlukan max {$menuMaxLevel} level otorisasi";
}
```

**Example for PPL**:
- PPL menu has `OL=2`
- Cannot authorize level 3 or higher (even if user has `Tingkat=5`)

### 3. Cascading Rule (Critical)

```php
// Level N+1 can only be authorized AFTER level N is done
if ($requestedLevel > 1 && !$ppl->IsOtorisasi($requestedLevel - 1)) {
    throw "Level " . ($requestedLevel - 1) . " harus diotorisasi terlebih dahulu";
}
```

**Example Workflow**:
```
Level 1: User A authorizes ✓
Level 2: (Can now authorize - L1 is done)
         User B authorizes ✓
Level 3: (Blocked - menu max is 2)
         Cannot authorize ✗
```

### 4. Authorization Cancellation (Cascading)

```php
// Cancelling level N also cancels N+1, N+2, ... 5
for ($i = $authLevel; $i <= 5; $i++) {
    $ppl->update(["IsOtorisasi{$i}" => false]);
}
```

**Example**:
- User cancels Level 1 authorization
- System automatically cancels Level 2 (if authorized)
- Result: Document returns to "Awaiting Authorization" state

### 5. Authorization Only by Authorized User

```php
// Only user who authorized at level N can cancel it (or admin)
$authField = "OtoUser{$authLevel}";
if ($ppl->{$authField} !== $user->USERID && $user->role !== 'admin') {
    throw "Hanya user yang mengotorisasi level ini yang dapat membatalkannya";
}
```

## Implementation Files

### 1. **AuthorizationService** (NEW)
**File**: `app/Services/AuthorizationService.php`

**Methods**:
- `getUserAuthLevel(User)` → Get user's Tingkat from dbFlpass
- `getMenuMaxLevel(string)` → Get menu's OL from dbMenu
- `canAuthorizeLevel(User, DbPPL, int)` → Validate authorization permission
- `canCancelAuthorizationLevel(User, DbPPL, int)` → Validate cancellation permission
- `getVisibleAuthLevels()` → Get dynamic auth levels for UI
- `getAuthorizationStatus(DbPPL)` → Get complete auth status

### 2. **PPLService** (UPDATED)
**File**: `app/Services/PPLService.php`

**Changes**:
- `authorize()` now uses `AuthorizationService::canAuthorizeLevel()`
- `cancelAuthorization()` now uses `AuthorizationService::canCancelAuthorizationLevel()`
- Better error messages with user-friendly Indonesian text
- Logs all authorization attempts

### 3. **PPLPolicy** (UPDATED)
**File**: `app/Policies/PPLPolicy.php`

**Changes**:
- `authorize()` now uses database-driven validation
- `cancelAuthorization()` now uses database-driven validation
- Removed hardcoded role→level mapping
- Delegates to `AuthorizationService`

### 4. **PPLController** (UPDATED)
**File**: `app/Http/Controllers/PPLController.php`

**Changes**:
- `authorizePR()` now provides detailed error messages
- `cancelAuthorization()` explains cascading behavior
- Added comprehensive logging

## Authorization Flow

```
POST /ppl/{nobukti}/authorize
├─ Validate auth_level (1-5)
├─ Get User: user = Auth::user()
├─ Get PPL: ppl = DbPPL::find(nobukti)
├─ AuthorizationService::canAuthorizeLevel(user, ppl, level)
│  ├─ Check: user.Tingkat >= level
│  ├─ Check: level <= menu.OL (from dbMenu)
│  ├─ Check: level > 1 → previous level must be authorized
│  ├─ Check: level not already authorized
│  └─ Return: { can_authorize, reason }
├─ IF allowed:
│  ├─ Update: IsOtorisasi{N} = true
│  ├─ Update: OtoUser{N} = user.USERID
│  ├─ Update: TglOto{N} = now()
│  ├─ Set MaxOL on first authorization
│  └─ Log activity
└─ Return: { success, message, data }
```

## Example Scenarios

### Scenario 1: Valid Authorization

```
User: adminkarir (Tingkat=1)
PPL: PR/0001/02/2024 (MaxOL=2)
Action: Authorize Level 1

✓ User Tingkat (1) >= Level (1) ✓
✓ Level (1) <= Menu OL (2) ✓
✓ First level, no prerequisite ✓
✓ Not already authorized ✓
Result: SUCCESS - Level 1 authorized
```

### Scenario 2: Cascading Required

```
User: ALFATH (Tingkat=2)
PPL: PR/0001/02/2024 (MaxOL=2, IsOtorisasi1=false)
Action: Try to authorize Level 2

✓ User Tingkat (2) >= Level (2) ✓
✓ Level (2) <= Menu OL (2) ✓
✗ Level 1 NOT yet authorized ✗
Result: FAILURE - "Level 1 harus diotorisasi terlebih dahulu"
```

### Scenario 3: User Authority Exceeded

```
User: ALFIAN (Tingkat=1)
PPL: PR/0001/02/2024
Action: Try to authorize Level 2

✗ User Tingkat (1) < Level (2) ✗
Result: FAILURE - "Anda hanya bisa otorisasi hingga level 1, tidak bisa level 2"
```

### Scenario 4: Cascading Cancel

```
User: User who did Level 1 authorization
PPL: PR/0001/02/2024 (IsOtorisasi1=true, IsOtorisasi2=true)
Action: Cancel Level 1

✓ User authorized at Level 1 ✓
✓ PR not cancelled ✓
Result: SUCCESS
- IsOtorisasi1 = false
- IsOtorisasi2 = false (cascaded)
- Document back to "Awaiting Authorization"
```

## Database Queries Used

### Get User Authorization Level
```php
DB::table('dbFlpass')
    ->where('USERID', $userId)
    ->select('Tingkat')
    ->first()
```

### Get Menu Max Authorization Level
```php
DB::table('DBMENU')
    ->where('KODEMENU', '03001')  // PPL menu code
    ->select('OL')
    ->first()
```

## Testing Checklist

- [ ] User with `Tingkat=1` can authorize Level 1
- [ ] User with `Tingkat=1` CANNOT authorize Level 2
- [ ] User with `Tingkat=2` CAN authorize Levels 1-2
- [ ] Cannot authorize Level 3 (menu max is 2)
- [ ] Cannot authorize Level 2 without Level 1 first
- [ ] Cancelling Level 1 also cancels Level 2
- [ ] Only authorizing user can cancel their authorization
- [ ] Admin can authorize/cancel any level
- [ ] Proper error messages in Indonesian
- [ ] Logging of all authorization attempts

## Migration Notes

This implementation:
✓ Preserves all existing PPL data
✓ No database schema changes needed
✓ Backward compatible with existing PPL records
✓ Fully compliant with Delphi authorization concept
✓ Implements exact business rules from MyProcedure.pas

## Future Enhancements

- [ ] Dynamic menu OL levels (allow configurable max levels per menu)
- [ ] User department-based authorization routing
- [ ] Automatic escalation workflows
- [ ] Authorization history/audit trail
- [ ] Notification system for pending authorizations
- [ ] Integration with user group-based permissions
