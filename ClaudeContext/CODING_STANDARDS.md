# Coding Standards - DAPEN Project

📋 **Detailed coding guidelines and best practices for Smart Accounting DAPEN-KA**

*Extracted from CLAUDE.md for better organization*

## Code Organization Principles

### 1. Single Responsibility Principle (SRP)
```php
// ❌ Bad: Controller doing too much
class UserController {
    public function store(Request $request) {
        // Validation logic
        // Business logic
        // Database operations
        // Email sending
        // File operations
    }
}

// ✅ Good: Separated responsibilities
class UserController {
    public function store(StoreUserRequest $request) {
        return $this->userService->createUser($request->validated());
    }
}

class UserService {
    public function createUser(array $data): User {
        // Business logic only
    }
}
```

### 2. Dependency Injection & Service Layer
```php
// ✅ Service layer pattern
class TransactionService {
    public function __construct(
        private TransactionRepository $repository,
        private ValidationService $validator,
        private NotificationService $notifier
    ) {}

    public function processTransaction(array $data): Transaction {
        $this->validator->validate($data);
        $transaction = $this->repository->create($data);
        $this->notifier->sendConfirmation($transaction);
        return $transaction;
    }
}
```

## Naming Conventions

### PHP/Laravel Backend
```php
// ✅ Classes: PascalCase
class UserAccountService {}
class TransactionController {}

// ✅ Methods & Variables: camelCase
public function calculateTotal() {}
private $userBalance = 0;

// ✅ Constants: UPPER_SNAKE_CASE
const MAX_RETRY_ATTEMPTS = 3;

// ✅ Database columns: snake_case (existing schema)
'user_id', 'created_at', 'total_amount'
```

### React Frontend
```javascript
// ✅ Components: PascalCase
const UserDashboard = () => {};
const TransactionForm = () => {};

// ✅ Variables & Functions: camelCase
const userBalance = 0;
const calculateTotal = () => {};

// ✅ Constants: UPPER_SNAKE_CASE
const API_BASE_URL = 'http://localhost:8000';

// ✅ Files: kebab-case
user-dashboard.jsx
transaction-form.jsx
```

## Function Design

### Keep Functions Small & Focused
```php
// ❌ Bad: Long function with multiple responsibilities
public function processOrder($data) {
    // 50+ lines of validation
    // Database operations
    // Email sending
    // PDF generation
    // Inventory updates
}

// ✅ Good: Small, focused functions
public function processOrder(array $orderData): Order {
    $validatedData = $this->validateOrderData($orderData);
    $order = $this->createOrder($validatedData);
    $this->updateInventory($order);
    $this->sendConfirmationEmail($order);
    return $order;
}

private function validateOrderData(array $data): array {
    // Only validation logic
}

private function createOrder(array $data): Order {
    // Only order creation logic
}
```

### Use Descriptive Names
```php
// ❌ Bad: Unclear names
public function calc($d) {}
public function getData() {}

// ✅ Good: Descriptive names
public function calculateMonthlyInterest(float $principal): float {}
public function getUserTransactionHistory(int $userId): Collection {}
```

## Error Handling

### Use Try-Catch Appropriately
```php
// ✅ Good error handling
public function processPayment(array $paymentData): PaymentResult {
    try {
        DB::beginTransaction();

        $payment = $this->createPayment($paymentData);
        $this->updateAccountBalance($payment);
        $this->logTransaction($payment);

        DB::commit();
        return new PaymentResult(true, $payment);

    } catch (PaymentException $e) {
        DB::rollBack();
        Log::error('Payment processing failed', [
            'error' => $e->getMessage(),
            'data' => $paymentData
        ]);
        throw $e;
    }
}
```

### Frontend Error Handling
```javascript
// ✅ Good React error handling
const TransactionForm = () => {
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);

    const handleSubmit = async (formData) => {
        try {
            setLoading(true);
            setError(null);

            const result = await transactionService.create(formData);
            onSuccess(result);

        } catch (err) {
            setError(err.message);
            console.error('Transaction creation failed:', err);
        } finally {
            setLoading(false);
        }
    };
};
```

## Documentation Standards

### PHP DocBlocks
```php
/**
 * Calculate compound interest for pension fund investment
 *
 * @param float $principal Initial investment amount
 * @param float $rate Annual interest rate (as decimal)
 * @param int $years Number of years for investment
 * @param int $compoundFrequency Times per year interest is compounded
 *
 * @return float Final amount after compound interest
 *
 * @throws InvalidArgumentException When rate or years are negative
 */
public function calculateCompoundInterest(
    float $principal,
    float $rate,
    int $years,
    int $compoundFrequency = 12
): float {
    // Implementation
}
```

### JSDoc for React
```javascript
/**
 * Transaction form component for processing financial transactions
 *
 * @param {Object} props Component properties
 * @param {Function} props.onSubmit Callback when form is submitted
 * @param {Object} props.initialValues Initial form values
 * @param {boolean} props.disabled Whether form is disabled
 *
 * @returns {JSX.Element} Transaction form component
 */
const TransactionForm = ({ onSubmit, initialValues, disabled }) => {
    // Implementation
};
```

## Testing Guidelines

### Unit Test Structure
```php
// ✅ Good test structure
class UserServiceTest extends TestCase {
    public function test_creates_user_with_valid_data(): void {
        // Arrange
        $userData = [
            'name' => 'John Doe',
            'email' => 'john@example.com',
            'password' => 'securePassword123'
        ];

        // Act
        $user = $this->userService->createUser($userData);

        // Assert
        $this->assertInstanceOf(User::class, $user);
        $this->assertEquals('John Doe', $user->name);
        $this->assertTrue(Hash::check('securePassword123', $user->password));
    }
}
```

## Security Best Practices

### Input Validation
```php
// ✅ Laravel Request validation
class StoreTransactionRequest extends FormRequest {
    public function rules(): array {
        return [
            'amount' => 'required|numeric|min:0.01|max:999999.99',
            'account_id' => 'required|exists:accounts,id',
            'description' => 'required|string|max:255',
            'transaction_date' => 'required|date|before_or_equal:today'
        ];
    }
}
```

### SQL Injection Prevention
```php
// ❌ Bad: String concatenation
$query = "SELECT * FROM users WHERE id = " . $userId;

// ✅ Good: Parameter binding
$user = DB::select("SELECT * FROM users WHERE id = ?", [$userId]);

// ✅ Good: Eloquent ORM
$user = User::find($userId);
```

## Performance Optimization

### Database Queries
```php
// ❌ Bad: N+1 Query Problem
$users = User::all();
foreach ($users as $user) {
    echo $user->profile->name; // Additional query for each user
}

// ✅ Good: Eager Loading
$users = User::with('profile')->get();
foreach ($users as $user) {
    echo $user->profile->name; // No additional queries
}
```

### React Performance
```javascript
// ✅ Good: Memoization for expensive calculations
const TransactionSummary = ({ transactions }) => {
    const totalAmount = useMemo(() => {
        return transactions.reduce((sum, transaction) => sum + transaction.amount, 0);
    }, [transactions]);

    return <div>Total: {totalAmount}</div>;
};

// ✅ Good: Component memoization
const TransactionItem = memo(({ transaction }) => {
    return <div>{transaction.description}</div>;
});
```

## Code Review Checklist

### Before Committing
- [ ] **Functionality**: Code works as expected
- [ ] **Readability**: Code is self-documenting
- [ ] **Performance**: No obvious performance issues
- [ ] **Security**: No security vulnerabilities
- [ ] **Testing**: Adequate test coverage
- [ ] **Documentation**: Updated when necessary
- [ ] **Standards**: Follows project coding standards
- [ ] **Dependencies**: No unnecessary dependencies added

### Git Commit Messages
```bash
# ✅ Good commit message format
feat: add user authentication with JWT tokens

- Implement login/logout functionality
- Add middleware for protected routes
- Include password hashing with bcrypt
- Add unit tests for auth service

Closes #123
```

## Migration-Specific Guidelines

### Preserving Legacy Compatibility
```php
// ✅ Good: Maintain database field names for compatibility
class DbBarang extends Model {
    protected $table = 'DBBARANG';
    protected $primaryKey = 'KODEBRG';
    public $incrementing = false;

    // Map legacy field names to readable accessors
    public function getItemCodeAttribute(): string {
        return $this->KODEBRG;
    }

    public function getItemNameAttribute(): string {
        return $this->NAMABRG;
    }
}
```

### Business Logic Translation
```php
// ✅ Good: Document Delphi equivalent
/**
 * Calculate stock value using FIFO method
 *
 * Equivalent to Delphi procedure: CalculateStockValue()
 * File: MyProcedure.pas, Line 245
 */
public function calculateStockValueFifo(string $itemCode): float {
    // Implementation that matches Delphi logic
}
```

## 🧹 Template Clean Code Standards

### Template Refactoring Guidelines

#### 1. Separation of Concerns
```blade
<!-- ❌ Bad: Mixed concerns in single template -->
<!DOCTYPE html>
<html>
<head>
    <link href="https://cdnjs.cloudflare.com/..." rel="stylesheet">
    <link href="{{ asset('css/auth.css') }}" rel="stylesheet">
</head>
<body>
    <!-- Lots of inline HTML -->
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            if (errorMessage) { showError(errorMessage); }
        });
    </script>
</body>
</html>

<!-- ✅ Good: Clean separation -->
<!DOCTYPE html>
<html>
<head>
    @include('layouts.partials.auth-styles')
</head>
<body>
    <div class="container">
        @include('auth.partials.header')
        @include('auth.partials.form')
        @include('auth.partials.footer')
    </div>

    <script src="{{ asset('js/auth.js') }}"></script>
    <x-flash-messages />
</body>
</html>
```

#### 2. Component Reusability
```blade
<!-- ✅ Good: Reusable flash messages component -->
<!-- resources/views/components/flash-messages.blade.php -->
@if(session()->has('error') || session()->has('success') || $errors->any())
<script>
    document.addEventListener('DOMContentLoaded', function() {
        const flashMessages = {
            @if(session('error'))error: @json(session('error')),@endif
            @if(session('success'))success: @json(session('success')),@endif
            @if($errors->any())errors: @json($errors->all()),@endif
        };

        if (window.DapenAuth && typeof window.DapenAuth.processFlashMessages === 'function') {
            window.DapenAuth.processFlashMessages(flashMessages);
        }
    });
</script>
@endif

<!-- Usage: Anywhere in templates -->
<x-flash-messages />
```

#### 3. Template Organization Structure
```
resources/views/
├── auth/
│   ├── login.blade.php           # Main template (minimal)
│   └── partials/
│       ├── login-header.blade.php
│       ├── login-form.blade.php
│       └── login-footer.blade.php
├── components/
│   ├── flash-messages.blade.php  # Reusable components
│   └── form-field.blade.php
└── layouts/
    └── partials/
        ├── auth-styles.blade.php # CSS dependencies
        └── app-scripts.blade.php # JS dependencies
```

#### 4. JavaScript Integration Best Practices
```php
// ❌ Bad: Inline JavaScript in templates
@if(session('error'))
<script>
    document.addEventListener('DOMContentLoaded', function() {
        showError('{{ session('error') }}');
    });
</script>
@endif

// ✅ Good: External JavaScript with clean integration
// In auth.js:
const DapenAuth = {
    processFlashMessages(messages) {
        if (messages.error) this.showError(messages.error);
        if (messages.success) this.showSuccess(messages.success);
        if (messages.errors) messages.errors.forEach(err => this.showError(err));
    }
};

// In template component:
<x-flash-messages /> <!-- Clean, reusable -->
```

#### 5. Asset Management
```blade
<!-- ✅ Good: Centralized asset partials -->
<!-- layouts/partials/auth-styles.blade.php -->
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
<link href="{{ asset('css/auth.css') }}" rel="stylesheet">

<!-- layouts/partials/auth-scripts.blade.php -->
<script src="{{ asset('js/auth.js') }}"></script>

<!-- Usage in templates -->
@include('layouts.partials.auth-styles')
@include('layouts.partials.auth-scripts')
```

### Template Refactoring Checklist

#### Before Refactoring:
- [ ] ✅ **Safety backup**: `./safety/backup-before-work.sh`
- [ ] ✅ **TodoWrite plan**: Create task breakdown
- [ ] ✅ **Analyze template**: Identify mixed concerns, duplication

#### During Refactoring:
- [ ] ✅ **Extract inline JavaScript** to external files
- [ ] ✅ **Create reusable components** for common patterns
- [ ] ✅ **Separate styling concerns** into partials
- [ ] ✅ **Break large templates** into focused partials
- [ ] ✅ **Test each change** individually

#### After Refactoring:
- [ ] ✅ **Test functionality**: Verify all features work
- [ ] ✅ **Check performance**: Ensure no degradation
- [ ] ✅ **Update documentation**: Record patterns used
- [ ] ✅ **Create checkpoint**: Preserve working state

### Clean Code Template Metrics

#### Template Quality Score:
- **Lines of code reduced**: Target 60-70% reduction
- **Reusable components created**: At least 2-3 per template
- **Concerns separated**: Presentation, logic, styling distinct
- **Code duplication eliminated**: DRY principle applied
- **Maintainability improved**: Easier to modify individual parts

#### Success Indicators:
✅ Main template under 30 lines
✅ No inline JavaScript over 5 lines
✅ Reusable components created
✅ Partials with single responsibility
✅ All functionality preserved

## Related Learning Resources

### 📚 Experiential Programming Education
- **[Experiential Programming Education](EXPERIENTIAL_PROGRAMMING_EDUCATION.md)** - Universal methodology dan transferable principles dari real-world problem-solving
- **[Learning Cases Collection](learning-cases/)** - Detailed real-world scenarios:
  - [Case 1: Session Persistence Crisis](learning-cases/case-001-session-persistence-crisis.md) - Authentication vs session debugging
  - [Case 2: User Interaction Protocol Evolution](learning-cases/case-002-user-interaction-protocol.md) - Workflow automation development
  - [Case 3: Data Structure Mismatch Resolution](learning-cases/case-003-data-structure-mismatch.md) - Service-template alignment debugging
  - [Case 4: Quality Workflow Automation](learning-cases/case-004-quality-workflow-automation.md) - Manual to automatic process conversion

### 🏗️ Architecture & Methodology
- **[Clean Architecture TDD Strategy](CLEAN_ARCHITECTURE_TDD_STRATEGY.md)** - Complete TDD methodology and Clean Architecture implementation
- **[Database Guide](DATABASE_GUIDE.md)** - Comprehensive database guidelines and query strategies

### 🛠️ Troubleshooting & Quality
- **[Troubleshooting Guide](TROUBLESHOOTING_GUIDE.md)** - General debugging approaches
- **[User Interaction Protocol](USER_INTERACTION_PROTOCOL.md)** - Communication optimization framework

---

These coding standards ensure consistent, maintainable, and high-quality code throughout the DAPEN migration project.