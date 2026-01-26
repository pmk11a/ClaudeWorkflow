# Standardization Checklist - All Modules

**Generated**: 2026-01-25
**Purpose**: Ensure consistent standards across all migrated modules

---

## 📋 Module Standardization Checklist

### For Each Module, Verify:

### ✅ 1. Code Structure
- [ ] Controller uses resource pattern (index, create, store, show, edit, update, destroy)
- [ ] Service layer contains business logic
- [ ] Model has proper relationships and scopes
- [ ] Policy implements all permission checks
- [ ] Request classes for validation
- [ ] Views follow Blade template structure

### ✅ 2. Authorization
- [ ] Policy registered in AuthServiceProvider
- [ ] SA user bypass implemented in policy
- [ ] Direct policy instantiation used in controller
- [ ] Menu code properly configured
- [ ] All CRUD operations have permission checks
- [ ] Multi-level authorization (if applicable)

### ✅ 3. Validation
- [ ] Period lock validation implemented
- [ ] Business rule validation in Service
- [ ] Request validation for create/update
- [ ] Database constraint validation
- [ ] Quantity validation (for transaction modules)
- [ ] Balance validation (for financial modules)

### ✅ 4. Audit Logging
- [ ] Create operation logged
- [ ] Update operation logged
- [ ] Delete operation logged
- [ ] Authorization operations logged
- [ ] User ID captured
- [ ] Timestamp captured

### ✅ 5. Error Handling
- [ ] Try-catch blocks in controller
- [ ] Meaningful error messages
- [ ] Exceptions properly thrown
- [ ] Redirect with error messages
- [ ] Log errors with context

### ✅ 6. Database Operations
- [ ] DB::transaction() wrapper used
- [ ] Parameterized queries (no SQL injection)
- [ ] No NULL assignments to NOT NULL columns
- [ ] Proper foreign key handling
- [ ] Rollback on error

### ✅ 7. Code Quality
- [ ] PSR-12 compliant (Pint)
- [ ] No unused imports
- [ ] Proper indentation
- [ ] Consistent naming conventions
- [ ] Delphi references in comments

### ✅ 8. UI/UX
- [ ] Form layout matches Delphi structure
- [ ] Required fields marked with *
- [ ] Validation messages displayed
- [ ] Success/error flash messages
- [ ] Back/Cancel buttons
- [ ] Dynamic detail grid (for master-detail)

### ✅ 9. JavaScript (for transaction modules)
- [ ] Dynamic row add/remove
- [ ] AJAX lookups implemented
- [ ] Auto-calculation functions
- [ ] Client-side validation
- [ ] Dropdown population

### ✅ 9.1 Lookup/Autocomplete Validation
**Server-Side (API Endpoint)**
- [ ] API endpoint created for lookup (e.g., `/api/spk-lookup`)
- [ ] Input validation (minimum 2 characters before search)
- [ ] Parameterized queries (prevent SQL injection)
- [ ] Result limit (max 20-50 results)
- [ ] Proper HTTP status codes (200, 400, 404, 422)
- [ ] JSON response format with `success` flag
- [ ] Error handling with meaningful messages
- [ ] Logging of lookup queries
- [ ] Permission check (user can access referenced data)
- [ ] Performance optimization (indexed columns)

**Client-Side (JavaScript)**
- [ ] Debounce/throttle search input (300ms delay)
- [ ] Minimum character validation (2+ chars)
- [ ] Loading indicator during search
- [ ] Dropdown display with results
- [ ] Keyboard navigation (arrow keys, enter)
- [ ] Click to select result
- [ ] Auto-populate related fields on selection
- [ ] Clear button to reset lookup
- [ ] Error message display
- [ ] Prevent form submission on invalid lookup

**Data Validation**
- [ ] Validate selected value exists in database
- [ ] Check if referenced record is active/valid
- [ ] Validate composite keys (if applicable)
- [ ] Prevent duplicate selections (in detail grid)
- [ ] Validate lookup result matches expected type

**Security**
- [ ] No sensitive data in lookup results
- [ ] Escape HTML in results (prevent XSS)
- [ ] Rate limiting on API endpoint
- [ ] CSRF token validation
- [ ] User authorization check

**Testing**
- [ ] Test with valid search term
- [ ] Test with invalid search term
- [ ] Test with special characters
- [ ] Test with SQL injection attempts
- [ ] Test with minimum characters (1 char - should fail)
- [ ] Test with empty input
- [ ] Test result selection and field population
- [ ] Test keyboard navigation
- [ ] Test concurrent lookups
- [ ] Test with large result sets

**Performance**
- [ ] Query uses indexed columns
- [ ] Result limit prevents large datasets
- [ ] Debounce prevents excessive API calls
- [ ] Response time < 500ms
- [ ] No N+1 queries in lookup

### ✅ 10. Document Number Generation
**For Transaction Modules**
- [ ] Auto-generate document number (NoBukti)
- [ ] Format follows pattern: PREFIX/YYYYMM/SEQUENCE/SUFFIX
- [ ] Sequence increments per month/period
- [ ] Handle concurrent requests (avoid duplicate numbers)
- [ ] Use database sequence or stored procedure
- [ ] Validate uniqueness before save
- [ ] Include year/month in document number
- [ ] Support different prefixes per transaction type
- [ ] Support different numbering per division/warehouse (if applicable)
- [ ] Document number displayed to user before save

**Implementation Pattern**
```php
// Service method
public function generateNoBukti(string $prefix, int $isPPN, string $kodeSupp): string
{
    // Format: PREFIX/YYYYMM/SEQUENCE/SUFFIX
    // Example: PBL/202601/00001/SUP001
}
```

### ✅ 11. Stored Procedure Integration
**For Delphi-migrated modules**
- [ ] Identify all stored procedures used in Delphi
- [ ] Document stored procedure parameters
- [ ] Use DB::statement() with parameterized calls
- [ ] Wrap stored procedure calls in DB::transaction()
- [ ] Handle stored procedure errors gracefully
- [ ] Log stored procedure execution
- [ ] Validate parameters before calling SP
- [ ] Map Delphi Mode parameter ('I', 'U', 'D')
- [ ] Handle NULL parameters correctly
- [ ] Test with all parameter combinations

**Common Stored Procedures**
- [ ] SP_Supplier - Supplier CRUD (69 parameters)
- [ ] SP_InsertOutstandingPO - Convert PO to Beli
- [ ] sp_RefreshTempOutstandingPO - Load outstanding data
- [ ] sp_UpdateSO - Recalculate totals
- [ ] sp_HasilPrd - Production results CRUD

### ✅ 12. Multi-Currency Support
**For Financial/Transaction Modules**
- [ ] Currency code field (Valas) - default 'IDR'
- [ ] Exchange rate field (Kurs) - default 1
- [ ] Original currency tracking (ValasOriginal)
- [ ] Original exchange rate (KursOriginal)
- [ ] Payment exchange rate (KursBayar)
- [ ] Auto-calculate IDR amount (Jumlah * Kurs)
- [ ] Display both foreign currency and IDR amounts
- [ ] Validate exchange rate > 0
- [ ] Handle currency conversion on updates
- [ ] Support multiple currencies in same document
- [ ] Exchange rate difference handling

### ✅ 13. Deletion Protection
**For Transaction Modules**
- [ ] Check for dependent/child records before delete
- [ ] Validate no downstream documents exist
- [ ] Check related tables (e.g., Invoice → Payment, PO → Beli)
- [ ] Show meaningful error with list of blocking documents
- [ ] Prevent delete if document is authorized
- [ ] Prevent delete if period is locked
- [ ] Soft delete vs hard delete decision
- [ ] Cascade delete for master-detail (if applicable)
- [ ] Log deletion attempts (successful and failed)
- [ ] User-friendly error messages

**Example Checks**
```php
// Check if Invoice has payments
$hasPayments = DB::table('dbPayment')
    ->where('NoInvoice', $noBukti)
    ->exists();

if ($hasPayments) {
    throw new Exception('Cannot delete: Invoice has related payments');
}
```

### ✅ 14. Status Tracking & Workflow
**For Transaction Modules**
- [ ] Status field defined (draft, authorized, posted, cancelled)
- [ ] Status-based validation rules
- [ ] Cannot edit if status = authorized
- [ ] Cannot delete if status = posted
- [ ] Status transition validation (draft → authorized only)
- [ ] Status history tracking (optional)
- [ ] Display status badge/indicator in UI
- [ ] Filter by status in list view
- [ ] Batch status updates (if applicable)
- [ ] Status-based permission checks

**Common Status Values**
- [ ] ISBATAL (Cancelled) - Boolean
- [ ] IsOtorisasi1-5 (Authorization levels) - Boolean
- [ ] NeedOtorisasi (Calculated - requires auth) - Boolean
- [ ] Status field (VARCHAR) - 'DRAFT', 'AUTHORIZED', 'POSTED', 'CANCELLED'

### ✅ 15. Composite Key Handling
**For Hierarchical Master Data**
- [ ] Identify composite primary keys (e.g., Devisi + Perkiraan)
- [ ] Route parameters include all key parts
- [ ] Query uses all key columns in WHERE clause
- [ ] Update validation includes all key parts
- [ ] Delete validation includes all key parts
- [ ] Foreign key references use all key parts
- [ ] Unique constraint on composite key
- [ ] Display all key parts in UI
- [ ] Validate uniqueness of composite key before insert

**Example Modules**
- Aktiva: (Devisi, Perkiraan)
- Group: (KodeGrp, KodeSubGrp, Urut)
- SubGroup: (KodeGrp, KodeSubGrp)
- ArusKasDet: (KodeAK, KodeSubAK)

### ✅ 16. Period Lock Integration
**For All Transaction Modules**
- [ ] Check period lock before create
- [ ] Check period lock before update
- [ ] Check period lock before delete
- [ ] Use LockPeriodService for validation
- [ ] Check both financial and non-financial periods
- [ ] Extract month/year from transaction date
- [ ] Display period lock error message
- [ ] Prevent bypass (even for SA user - optional)
- [ ] Log period lock violations
- [ ] Support period unlock for corrections

**Implementation**
```php
// In controller/service
if ($this->lockPeriodService->isCurrentPeriodLocked()) {
    throw new Exception('Periode sudah dikunci, tidak dapat melakukan transaksi');
}
```

### ✅ 17. Master-Detail Calculations
**For Transaction Modules with Details**
- [ ] Auto-calculate detail line totals
- [ ] Auto-calculate master totals from details
- [ ] Recalculate on detail add/update/delete
- [ ] Handle quantity * price calculations
- [ ] Handle discount calculations (percentage or amount)
- [ ] Handle tax/PPN calculations
- [ ] Round calculations to 2 decimal places
- [ ] Display running totals in UI
- [ ] Validate total amounts match
- [ ] Support multiple calculation methods (stored proc vs PHP)

**Common Calculations**
- Line Total = Qty × Price × (1 - Disc%) - DiscAmt
- Subtotal = Sum of all line totals
- Tax = Subtotal × Tax%
- Grand Total = Subtotal + Tax

### ✅ 18. Outstanding Document Conversion
**For Modules with Outstanding Processing**
- [ ] Load outstanding items from source document
- [ ] Display remaining quantity (qntos)
- [ ] Allow partial quantity selection
- [ ] Validate selected quantity ≤ outstanding quantity
- [ ] Update source document outstanding quantity
- [ ] Use temporary table for user-specific data
- [ ] Clean up temp table after conversion
- [ ] Link converted document to source (NoRef field)
- [ ] Handle concurrent conversions by multiple users
- [ ] Support reversal/cancellation of conversion

**Example Flows**
- PPL → PO (Outstanding PR to PO)
- PO → Beli (Outstanding PO to Purchase)
- SPK → HasilProduksi (Outstanding Work Order to Production)

### ✅ 19. Testing
- [ ] Feature tests created
- [ ] CRUD operations tested
- [ ] Authorization workflow tested
- [ ] Validation rules tested
- [ ] Edge cases covered
- [ ] Period lock validation tested
- [ ] Deletion protection tested
- [ ] Status transition tested
- [ ] Composite key operations tested
- [ ] Multi-currency calculations tested
- [ ] Outstanding conversion tested

### ✅ 20. Documentation
- [ ] Comparison document created
- [ ] Validation report generated
- [ ] Delphi references documented
- [ ] Business logic documented
- [ ] Known issues listed

---

## 🔍 Module-Specific Validation

### Master Data Modules
- [ ] Simple CRUD operations
- [ ] Export to Excel
- [ ] Search and filter
- [ ] Soft delete (if applicable)

### Transaction Modules (Master-Detail)
- [ ] Master-detail structure
- [ ] Detail line CRUD
- [ ] Lookup integration
- [ ] Balance/total calculation
- [ ] Multi-level authorization
- [ ] Period lock validation
- [ ] Print functionality

### Special Modules
- [ ] Module-specific business rules
- [ ] Complex calculations
- [ ] Multiple table updates
- [ ] Workflow management

---

## 📊 Standardization Priority

### High Priority (Must Have)
1. **Authorization Checks** - Security critical
2. **Audit Logging** - Compliance required
3. **Validation** - Data integrity
4. **Error Handling** - User experience
5. **Database Transactions** - Data consistency

### Medium Priority (Should Have)
1. **Code Quality (Pint)** - Maintainability
2. **Test Coverage** - Regression prevention
3. **Documentation** - Knowledge transfer
4. **UI Consistency** - User experience

### Low Priority (Nice to Have)
1. **Print Functionality** - Reporting
2. **Export to Excel** - Data analysis
3. **Advanced Search** - User convenience
4. **Batch Operations** - Efficiency

---

## 🎯 Module Status Tracking

### ✅ Complete (All Standards Met)
- None yet

### ⚠️ Partial (Some Standards Missing)
- HasilProduksi - Missing tests, print functionality
- Memorial - Missing tests, export functionality
- PPL - Missing tests, print functionality
- PO - Missing tests, print functionality
- BeliGudang - Missing tests, print functionality

### ❌ Not Started
- BeliNota
- Invoice
- PenyerahanBhn
- RPenyerahanBhn
- Koreksi
- HasilPLuar
- Area
- Group
- ArusKas
- LockPeriod
- Aktiva
- Giro
- HutangPiutang

---

## 📝 Standard Templates

### Controller Template
```php
class ModuleController extends Controller
{
    private const GUARD = 'trade2exchange';
    private const MENU_CODE = 'XXXXX';

    public function __construct(
        private readonly ModuleService $service,
        private readonly LockPeriodService $lockPeriodService,
        private readonly MenuAccessService $menuAccessService
    ) {
        $this->middleware('auth:'.self::GUARD);
    }

    private function user() {
        return Auth::guard(self::GUARD)->user();
    }

    private function policy(): ModulePolicy {
        return new ModulePolicy($this->menuAccessService);
    }

    public function index(Request $request): View {
        // List view
    }

    public function create(): View {
        // Check authorization
        $policy = app(\App\Policies\ModulePolicy::class);
        if (!$policy->create($this->user())) {
            abort(403);
        }

        // Check period lock
        if ($this->lockPeriodService->isCurrentPeriodLocked()) {
            return redirect()->back()->with('error', 'Periode terkunci');
        }

        return view('module.create');
    }

    public function store(StoreModuleRequest $request) {
        // Check authorization
        $policy = app(\App\Policies\ModulePolicy::class);
        if (!$policy->create($this->user())) {
            abort(403);
        }

        try {
            $result = $this->service->create($request->validated());
            return redirect()->route('module.show', $result->id)
                ->with('success', 'Berhasil dibuat');
        } catch (Exception $e) {
            Log::error('Error creating module', ['error' => $e->getMessage()]);
            return redirect()->back()
                ->withInput()
                ->with('error', 'Error: '.$e->getMessage());
        }
    }

    // ... other methods
}
```

### Service Template
```php
class ModuleService
{
    public function __construct(
        private readonly AuditLogService $auditLog
    ) {}

    public function create(array $data) {
        try {
            return DB::transaction(function () use ($data) {
                // Create master
                $master = DbMODULE::create($data['header']);

                // Create details
                foreach ($data['details'] as $detail) {
                    $master->details()->create($detail);
                }

                // Audit log
                $this->auditLog->log(
                    auth()->id(),
                    '',
                    'MODULE',
                    $master->id,
                    'Created module'
                );

                return $master;
            });
        } catch (Exception $e) {
            Log::error('Service error', ['error' => $e->getMessage()]);
            throw $e;
        }
    }

    // ... other methods
}
```

### Policy Template
```php
class ModulePolicy
{
    private const MENU_CODE = 'XXXXX';

    public function __construct(
        private readonly MenuAccessService $menuAccessService
    ) {}

    public function create(User $user): bool {
        if (strtoupper($user->USERID ?? '') === 'SA') {
            return true;
        }

        return $this->menuAccessService->hasPermission(
            $user->USERID,
            self::MENU_CODE,
            'IsTambah'
        );
    }

    // ... other methods
}
```

### Lookup API Template
```php
/**
 * API endpoint for lookup/autocomplete
 * GET /api/{entity}-lookup?q=search_term
 *
 * Example: GET /api/spk-lookup?q=SPK001
 */
public function searchEntity(Request $request): JsonResponse
{
    try {
        // Validate input
        $validated = $request->validate([
            'q' => 'required|string|min:2|max:50',
        ]);

        $query = $validated['q'];

        // Search with filters
        $results = DB::table('DBTABLE as t')
            ->select(
                't.field1',
                't.field2',
                't.field3',
                DB::raw('ISNULL(t.calculated_field, 0) as calculated')
            )
            ->leftJoin('RELATED_TABLE as r', 't.foreign_key', '=', 'r.primary_key')
            ->where('t.search_field', 'LIKE', "%{$query}%")
            ->where('t.is_active', true) // Only active records
            ->orderBy('t.search_field', 'desc')
            ->limit(20) // Limit results
            ->get();

        // Return JSON response
        return response()->json([
            'success' => true,
            'data' => $results,
            'count' => $results->count(),
        ]);

    } catch (Exception $e) {
        Log::error('Lookup API error', [
            'error' => $e->getMessage(),
            'query' => $request->input('q'),
        ]);

        return response()->json([
            'success' => false,
            'message' => 'Error searching data: ' . $e->getMessage(),
        ], 422);
    }
}
```

### Lookup JavaScript Template
```javascript
// Setup autocomplete lookup
function setupLookup(inputElement, targetFields) {
    let searchTimeout;
    const resultsDiv = document.getElementById(`${inputElement.id}-results`);
    const loadingDiv = document.getElementById(`${inputElement.id}-loading`);

    inputElement.addEventListener('input', function() {
        clearTimeout(searchTimeout);
        const query = this.value.trim();

        // Minimum 2 characters
        if (query.length < 2) {
            resultsDiv.classList.remove('show');
            return;
        }

        // Show loading indicator
        if (loadingDiv) loadingDiv.style.display = 'block';

        // Debounce: Wait 300ms before search
        searchTimeout = setTimeout(() => {
            fetch(`/api/entity-lookup?q=${encodeURIComponent(query)}`)
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.json();
                })
                .then(data => {
                    if (loadingDiv) loadingDiv.style.display = 'none';

                    if (!data.success) {
                        throw new Error(data.message || 'Search failed');
                    }

                    // Display results
                    resultsDiv.innerHTML = data.data.map(item => `
                        <a href="#" class="dropdown-item lookup-item"
                           data-field1="${item.field1}"
                           data-field2="${item.field2}"
                           data-field3="${item.field3}">
                            <strong>${item.field1}</strong><br>
                            <small>${item.field2} - ${item.field3}</small>
                        </a>
                    `).join('');

                    resultsDiv.classList.add('show');

                    // Attach click handlers
                    resultsDiv.querySelectorAll('.lookup-item').forEach(link => {
                        link.addEventListener('click', function(e) {
                            e.preventDefault();

                            // Populate target fields
                            targetFields.field1.value = this.dataset.field1;
                            targetFields.field2.value = this.dataset.field2;
                            targetFields.field3.value = this.dataset.field3;

                            // Hide dropdown
                            resultsDiv.classList.remove('show');

                            // Trigger any additional calculations
                            if (typeof onLookupSelect === 'function') {
                                onLookupSelect(this.dataset);
                            }
                        });
                    });
                })
                .catch(error => {
                    if (loadingDiv) loadingDiv.style.display = 'none';
                    console.error('Lookup error:', error);
                    resultsDiv.innerHTML = `
                        <div class="dropdown-item text-danger">
                            Error: ${error.message}
                        </div>
                    `;
                    resultsDiv.classList.add('show');
                });
        }, 300); // 300ms debounce
    });

    // Close dropdown when clicking outside
    document.addEventListener('click', function(e) {
        if (!inputElement.contains(e.target) && !resultsDiv.contains(e.target)) {
            resultsDiv.classList.remove('show');
        }
    });

    // Keyboard navigation (optional)
    inputElement.addEventListener('keydown', function(e) {
        const items = resultsDiv.querySelectorAll('.lookup-item');
        if (items.length === 0) return;

        let currentIndex = -1;
        items.forEach((item, index) => {
            if (item.classList.contains('active')) {
                currentIndex = index;
            }
        });

        if (e.key === 'ArrowDown') {
            e.preventDefault();
            if (currentIndex < items.length - 1) {
                if (currentIndex >= 0) items[currentIndex].classList.remove('active');
                items[currentIndex + 1].classList.add('active');
            }
        } else if (e.key === 'ArrowUp') {
            e.preventDefault();
            if (currentIndex > 0) {
                items[currentIndex].classList.remove('active');
                items[currentIndex - 1].classList.add('active');
            }
        } else if (e.key === 'Enter') {
            e.preventDefault();
            if (currentIndex >= 0) {
                items[currentIndex].click();
            }
        }
    });
}

// Usage example:
// setupLookup(
//     document.getElementById('spk-search'),
//     {
//         field1: document.getElementById('no-spk'),
//         field2: document.getElementById('kode-brg'),
//         field3: document.getElementById('nama-brg')
//     }
// );
```

---

## 🔄 Review Process

### Step 1: Self-Review
- Developer checks module against checklist
- Run Pint formatter
- Create comparison document
- Generate validation report

### Step 2: Peer Review
- Another developer reviews code
- Check standards compliance
- Test functionality
- Verify documentation

### Step 3: Quality Assurance
- Run validation tool
- Execute test suite
- Security scan
- Performance check

### Step 4: Approval
- Module lead approves
- Documentation complete
- Ready for deployment

---

**Checklist Version**: 1.0
**Last Updated**: 2026-01-25
**Status**: Active - Use for All New Modules
