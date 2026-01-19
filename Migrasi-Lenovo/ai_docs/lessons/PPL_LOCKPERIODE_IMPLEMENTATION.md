# PPL Lock Period Control Implementation

## Overview

**Status**: ✅ COMPLETE

Lock period control untuk PR (Permohonan Pembelian) sudah **FULLY IMPLEMENTED**.

Sistem sekarang SEPENUHNYA melindungi PR saat periode terkunci:

**Create Operations:**
- ✅ Create page **ACCESSIBLE** (opens with form)
- ⚠️ **WARNING MODAL** shown if current month is locked
- ✅ Form visible but user warned about locked period
- ❌ Form submission **BLOCKED** (422 error for any locked date)

**Edit Operations:**
- ✅ Edit page **ACCESSIBLE** (opens with form)
- ⚠️ **WARNING MODAL** shown if PR month is locked
- ❌ Form controls **DISABLED** when period locked
- ✅ User can view form but cannot edit (buttons disabled)

**Detail Operations:**
- ❌ Add detail **BLOCKED** (422 error)
- ❌ Edit detail **BLOCKED** (422 error)
- ❌ Delete detail **BLOCKED** (422 error)

**View/Read Access:**
- ✅ View page **ACCESSIBLE** (read-only, no action buttons)
- ✅ User can see PR details but cannot modify

### Key Features
1. **Backend Validation** - Service layer checks DBLOCKPERIODE table
2. **Controller Create() Check** - create() shows warning modal if current month locked
3. **Controller Store() Check** - store() blocks 422 before creating any PR for locked date
4. **Controller Edit() Check** - edit() shows warning modal if PR month locked
5. **JSON Error Responses** - 422 status code + error message, no redirects
6. **Modal Warnings** - Both create and edit show warning modals for locked periods

### Implementation Strategy
- **Create Page** - Accessible ✅ with warning modal if current month locked
- **Create Button** - Accessible ✅ (opens page with modal if locked)
- **Create Form** - Visible ✅ (user warned via modal)
- **Create Submit** - Blocked ❌ (422 error) for any locked date
- **Edit Page** - Accessible ✅ with warning modal if PR month locked
- **Edit Form** - Disabled controls when period locked
- **View Page** - Accessible ✅ read-only, no action buttons
- **Detail Operations** - All blocked ❌ (422 error)

## How It Works

### 1. Lock Period Detection
- **Table**: `DBLOCKPERIODE`
- **Columns**:
  - Financial locks: `BULAN` / `TAHUN`
  - Non-financial locks: `NKBULAN` / `NKTAHUN`
- **Service**: `LockPeriodService::getLockedMonths($year)`

### 2. Validation Points

| Operation | Method | Check Point | Response |
|-----------|--------|-------------|----------|
| Create page | `PPLController::create()` | Check current month | **Pass warning modal if current month locked** |
| Create PR | `PPLController::store()` | Before calling service | **422 JSON error if date locked** |
| Edit PR form | `PPLController::edit()` | Before returning view | **Pass warning modal if month locked** |
| Update PR | `PPLController::update()` | Before DB update | 422 JSON error |
| Add detail | `PPLController::addDetail()` | Before add | 422 JSON error |
| Update detail | `PPLController::updateDetail()` | Before update | 422 JSON error |
| Delete detail | `PPLController::deleteDetail()` | Before delete | 422 JSON error |

### 3. User Experience

#### Creating PR - Current Month Locked
1. User clicks "Tambah PR Baru" button
2. ✅ Create page opens
3. ⚠️ **WARNING MODAL** appears: "Periode saat ini sudah terkunci. Tidak dapat membuat PR untuk bulan ini."
4. Form visible but user warned about locked period
5. User can close modal via "Kembali" button or try to submit
6. If tries to submit with current month → 422 error

#### Creating PR - Different Month (but that month is locked)
1. Create page opens (current month not locked, or modal dismissed)
2. User fills in date for locked month
3. Clicks "Simpan PR" button
4. ❌ Server checks lock period in store()
5. Date month locked → returns 422 error
6. Error displayed inline: "Periode terkunci. Tidak dapat membuat PR untuk bulan/tahun ini."
7. Form stays open (user can change date or go back)

#### Editing PR (Bulan Terkunci)
1. User opens edit page: `/ppl/PR/0001/12/2025/edit`
2. ✅ Edit page loads
3. ⚠️ **WARNING MODAL** appears: "Periode untuk PR ini sudah terkunci. Edit tidak diperbolehkan."
4. Form visible but controls **DISABLED**
5. User can view PR details but cannot edit
6. User can click "Kembali" button to close modal and go back

#### Detail Operations (Bulan Terkunci)
1. User tries to add/edit/delete detail
2. JavaScript sends request
3. ❌ Error returned via JSON
4. Error message displayed
5. Form stays open (no page reload)

## Example: Period 2025 Locked

```
Locked Months for 2025:
- Financial: 4, 5, 12
- NK: 1, 2, 12

PR/0001/12/2025 (Date: 2025-12-16):
- Month 12 = LOCKED (both types)

Scenarios:

1. **Creating new PR for month 12 (and current month=12, locked):**
   - Create button: ✅ Accessible
   - GET /ppl/create → **Page loads with warning modal**
   - ⚠️ "Periode saat ini sudah terkunci. Tidak dapat membuat PR untuk bulan ini."
   - Form visible but user warned
   - Form submit: ❌ Blocked (422 error if submitted)

2. **Creating new PR for month 12 (current month NOT locked, but month 12 locked):**
   - Create page: ✅ Accessible (current month not locked)
   - Fill form with date in month 12
   - Form submit: ❌ Blocked
   - POST /ppl → **422 JSON error** "Periode terkunci..."
   - Error shown inline, form stays open

3. **Editing existing PR for month 12:**
   - Edit page: ✅ Accessible
   - GET /ppl/PR/0001/12/2025/edit → **Page loads with warning modal**
   - ⚠️ "Periode untuk PR ini sudah terkunci. Edit tidak diperbolehkan."
   - Form visible but controls **DISABLED**
   - Cannot edit, can only view and navigate back

4. **Viewing existing PR for month 12:**
   - Show page: ✅ Accessible
   - GET /ppl/PR/0001/12/2025 → Show page loads (read-only)
   - User can view details but no edit/delete buttons

5. **Detail operations on PR for month 12:**
   - Add detail: ❌ Blocked
   - Edit detail: ❌ Blocked
   - Delete detail: ❌ Blocked
   - POST/PUT/DELETE /ppl/.../detail → **422 JSON error**
```

## Code Architecture

### Backend (Service Layer)

#### PPLService
```php
// Dependency injection
private LockPeriodService $lockPeriodService;

// Constructor
public function __construct(LockPeriodService $lockPeriodService) {
    $this->lockPeriodService = $lockPeriodService;
}

// Private method for reuse in create/update/delete
private function isLockPeriode(Carbon $date, string $deptCode = null): bool {
    $lockedMonths = $this->lockPeriodService->getLockedMonths($date->year);
    return in_array($date->month, $lockedMonths['financial']) ||
           in_array($date->month, $lockedMonths['nk']);
}
```

#### PPLController
```php
// In create() - Show warning modal if current month is locked
$currentYear = now()->year;
$currentMonth = now()->month;
$lockedMonths = $lockService->getLockedMonths($currentYear);

$currentMonthLockedWarning = null;
$isCurrentMonthLocked = in_array($currentMonth, $lockedMonths['financial']) ||
                        in_array($currentMonth, $lockedMonths['nk']);

if ($isCurrentMonthLocked) {
    $currentMonthLockedWarning = 'Periode saat ini sudah terkunci. Tidak dapat membuat PR untuk bulan ini.';
}

return view('ppl.create', [
    'lockedMonths' => $lockedMonths,
    'currentYear' => $currentYear,
    'currentMonthLockedWarning' => $currentMonthLockedWarning,
]);

// In store() - Check lock period BEFORE creating (for any date)
$tanggal = Carbon::parse($validated['tanggal']);
$lockedMonths = $lockService->getLockedMonths($tanggal->year);
if (in_array($tanggal->month, $lockedMonths['financial']) ||
    in_array($tanggal->month, $lockedMonths['nk'])) {
    return response()->json([
        'success' => false,
        'message' => 'Periode terkunci. Tidak dapat membuat PR untuk bulan/tahun ini.',
    ], 422);
}

// Only if period not locked, proceed to create
$ppl = $this->pplService->create($headerData, $detailsData);

// In edit() - Show warning modal if period is locked
if ($isFinancialLocked || $isNKLocked) {
    $periodLockedWarning = 'Periode untuk PR ini sudah terkunci. Edit tidak diperbolehkan.';
    $isEditDisabled = true;
    // Pass to view - form will show modal and disabled controls
}

return view('ppl.edit', [
    'ppl' => $ppl,
    'departments' => $departments,
    'periodLockedWarning' => $periodLockedWarning,
    'isEditDisabled' => $isEditDisabled,
]);

// In update/detail operations - JSON error response
if (in_array($month, $lockedMonths['financial']) || in_array($month, $lockedMonths['nk'])) {
    return response()->json([
        'success' => false,
        'message' => 'Periode terkunci. Tidak dapat mengubah PR untuk bulan/tahun ini.',
    ], 422);
}
```

### Frontend (View Layer)

#### Edit View (ppl/edit.blade.php)
```blade
<!-- No modal or disabled controls needed -->
<!-- If page loads, it means period is NOT locked -->
<!-- (403 Forbidden prevents locked period edits from loading) -->

<!-- Normal editable form -->
<form id="pplForm" method="POST" action="{{ route('ppl.update', $ppl->Nobukti) }}">
    <input type="date" name="tanggal" value="{{ $ppl->Tanggal->format('Y-m-d') }}">
    <input type="checkbox" name="isclose" {{ $ppl->IsClose ? 'checked' : '' }}>

    <!-- Edit and delete detail buttons (enabled) -->
    <button type="button" onclick="editDetail()">Edit</button>
    <button type="button" onclick="deleteDetail()">Delete</button>

    <!-- Submit button (enabled) -->
    <button type="button" onclick="submitPRForm()">Simpan Perubahan</button>
</form>
```

#### Create View (ppl/create.blade.php)
```blade
<!-- Error alert (shows inline, no redirect) -->
<div id="errorAlert" class="alert alert-danger" style="display: none;">
    <strong>Error:</strong> <span id="errorMessage"></span>
</div>

<!-- Submit button uses fetch API -->
<button type="button" onclick="submitPPLForm()" id="submitBtn">
    Simpan PR
</button>

<!-- JavaScript handles JSON responses -->
<script>
function submitPPLForm() {
    fetch('/ppl', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            window.location.href = data.redirect;
        } else {
            // Show error inline - NO REDIRECT
            document.getElementById('errorMessage').textContent = data.message;
            document.getElementById('errorAlert').style.display = 'block';
        }
    });
}
</script>
```

#### Edit View JavaScript
```javascript
// submitPRForm() - Handle update with JSON response
// submitDetailForm() - Handle detail update with JSON response
// deleteDetail(urut) - Handle detail delete with JSON response

// All use fetch API instead of sendBeacon
// All handle JSON responses with 422 status code
// No page redirects on error - errors shown inline
```

## Logging

All lock period checks are logged for audit:
- `laravel.log` contains entries:
  - ✅ "Period lock check START/RESULT"
  - ⚠️ "Period locked (warning shown)"
  - ❌ "Period lock detected for PR - BLOCKING"

## Testing

Run unit tests:
```bash
php artisan test tests/Unit/PPLLockPeriodTest.php
```

Tests verify:
- ✓ Service injection working
- ✓ Lock month detection correct
- ✓ Period status validation

## Troubleshooting

### Create PR still succeeds for locked month
- Check `storage/logs/laravel.log` for "CREATE PR" entries
- Verify error message shows in JSON response (422 status)
- Confirm `DBLOCKPERIODE` table has correct data

### Edit form not showing warning
- Check if `periodLockedWarning` passed to view
- Verify view template displays `$periodLockedWarning`
- Check browser console for JavaScript errors

### Detail operations not blocked
- Verify lock period check exists in controller
- Check AJAX response status (should be 422)
- Verify error message in browser's Network tab

## Related Files

### Backend
- Service: `app/Services/PPLService.php` - isLockPeriode() method
- Service: `app/Services/LockPeriodService.php` - getLockedMonths() method
- Controller: `app/Http/Controllers/PPLController.php` - all action methods
- Tests: `tests/Unit/PPLLockPeriodTest.php` - unit tests

### Frontend
- View: `resources/views/ppl/create.blade.php` - Create form with error handling
- View: `resources/views/ppl/edit.blade.php` - Edit form with warning modal
- JavaScript: submitPPLForm() - Handle POST with JSON errors
- JavaScript: submitPRForm() - Handle PUT with JSON errors
- JavaScript: submitDetailForm() - Handle detail PUT with JSON errors
- JavaScript: deleteDetail() - Handle detail DELETE with JSON errors

### Recent Commits
- `a6d7f8f` - feat(PPL Views): Add lock period warning modals and JSON error handling
- `132be2e` - fix(PPL): Change lock period warnings from blocking to modal alerts
- `4bcca79` - Initial lock period control implementation
