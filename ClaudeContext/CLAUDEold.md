# CLAUDE.md

🚨 **MANDATORY SESSION START**: Claude MUST read this file AND `dokumentasi/claude/README.md` at the start of EVERY session!

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 📋 ESSENTIAL READING CHECKLIST
- [ ] ✅ Read CLAUDE.md (this file) - Project context and guidelines
- [ ] 📚 Read dokumentasi/claude/README.md - Complete documentation index
- [ ] 🔄 Check .claude/session_state.json - Current project progress
- [ ] ⚡ Run ./quick_context.sh - Quick status overview

## Project Overview

This is a **Smart Accounting DAPEN-KA** system - a comprehensive accounting application migrated from Delphi desktop to modern web architecture. The project uses Laravel 9.0 backend with React 18 frontend, representing a complete transformation from monolithic desktop application to scalable web-based solution.

### Migration Background
- **Source**: Delphi desktop application (320+ forms, ADO connections)
- **Target**: Laravel 9.0 + React 18 web application
- **Database**: Preserved existing SQL Server schema with 100+ tables
- **Business Logic**: Migrated from Object Pascal procedures to Laravel services

### Development Methodology
- **Architecture**: Clean Code Architecture (Domain → Application → Interface → Infrastructure)
- **Development Approach**: Test-Driven Development (TDD) - Red, Green, Refactor
- **Code Quality**: SOLID principles, dependency inversion, single responsibility

## Development Commands

### Server
- `cd backend && php artisan serve` - Start development server (http://localhost:8000)
- `cd backend && php artisan serve --host=0.0.0.0 --port=8000` - Start server accessible from network

### Development Setup
- `cd backend && composer install` - Install PHP dependencies
- `cd backend && composer install --no-dev` - Install production dependencies only
- `cd backend && php artisan key:generate` - Generate application key
- `cd backend && cp .env.example .env` - Copy environment file

### Database
- `cd backend && php artisan migrate` - Run database migrations
- `cd backend && php artisan migrate:rollback` - Rollback migrations
- `cd backend && php artisan db:seed` - Run database seeders

### Artisan Commands
- `cd backend && php artisan make:controller ControllerName` - Create controller
- `cd backend && php artisan make:model ModelName` - Create model
- `cd backend && php artisan make:migration migration_name` - Create migration
- `cd backend && php artisan route:list` - List all routes
- `cd backend && php artisan config:clear` - Clear configuration cache
- `cd backend && php artisan cache:clear` - Clear application cache

## Architecture

### Directory Structure
- `backend/` - Laravel API backend
  - `app/` - Core application code (Models, Controllers, Services)
    - `Http/Controllers/` - HTTP controllers
    - `Models/` - Eloquent models
    - `Providers/` - Service providers
  - `config/` - Configuration files
  - `database/` - Database migrations, factories, and seeders
  - `resources/` - Views, assets, and language files
  - `routes/` - Application routes (web.php, api.php)
  - `public/` - Web server document root
  - `storage/` - Generated files, logs, file uploads
- `frontend/` - React SPA frontend
  - `src/` - React components and application code
  - `public/` - Static assets
  - `package.json` - Frontend dependencies

### Key Components
- **Framework**: Laravel 9.0
- **PHP Version**: 8.0+
- **Authentication**: Laravel Sanctum
- **CORS**: Fruitcake Laravel CORS
- **HTTP Client**: Guzzle

## Documentation

### Claude-Generated Documentation
All documentation created by Claude is stored in `dokumentasi/claude/` directory:

- **[Documentation Index](dokumentasi/claude/README.md)** - Complete index of all Claude-generated documentation
- **[Laravel Installation Guide](dokumentasi/claude/LARAVEL_INSTALLATION_GUIDE.md)** - Complete step-by-step Laravel installation guide with troubleshooting
- **[Migration Analysis](dokumentasi/claude/ANALISIS_MIGRASI_DELPHI_KE_LARAVEL.md)** - Comprehensive analysis of Delphi to Laravel migration

#### Migration-Specific Documentation
- **[Delphi Legacy Reference](dokumentasi/claude/DELPHI_LEGACY_REFERENCE.md)** - Comprehensive reference for understanding the original Delphi desktop application architecture
- **[Business Logic Mapping](dokumentasi/claude/BUSINESS_LOGIC_MAPPING.md)** - Detailed mapping between Delphi business logic and Laravel implementation patterns
- **[Troubleshooting Guide](dokumentasi/claude/TROUBLESHOOTING_GUIDE.md)** - Comprehensive troubleshooting guide for development, deployment, and migration issues
- **[Version Control Strategy](dokumentasi/claude/VERSION_CONTROL_STRATEGY.md)** - Complete version control strategy for managing Delphi to Laravel migration codebase

### Documentation Rules
- All Claude-created documentation goes to `dokumentasi/claude/`
- Use descriptive filenames in Markdown format
- Update the documentation index when adding new files

## Playwright Analysis

### Playwright File Organization
**IMPORTANT**: All Playwright-generated files MUST be organized into `dokumentasi/playwright/` directory:

- **Scripts**: All `.js` files go to `dokumentasi/playwright/scripts/`
- **Screenshots**: All `.png` files go to `dokumentasi/playwright/screenshots/`
- **Analysis Results**: JSON files and logs go to `dokumentasi/playwright/`
- **Documentation**: Analysis reports go to `dokumentasi/playwright/analysis/`

### Playwright Commands
- `node dokumentasi/playwright/scripts/[script-name].js` - Run specific analysis script
- `npm install playwright` - Install Playwright (if needed)

### File Management Rules
1. **NEVER leave Playwright files in root directory**
2. **ALWAYS move files immediately after creation to dokumentasi/playwright/**
3. **UPDATE dokumentasi/playwright/README.md** when adding new files
4. **Clean root directory** of any temporary Playwright files

### Playwright Analysis Workflow
1. Create analysis script → Move to `dokumentasi/playwright/scripts/`
2. Generate screenshots → Move to `dokumentasi/playwright/screenshots/`
3. Create analysis reports → Move to `dokumentasi/playwright/analysis/`
4. Update `dokumentasi/playwright/README.md` with new files
5. Clean root directory of temporary files

## Project Structure

### Working Directory Organization
This workspace contains the main Laravel project with reference implementations:

```
D:\ykka\Dapen/
├── backend/                    # MAIN Laravel API backend
├── frontend/                   # MAIN React SPA frontend
├── Delphi/                     # Reference: Original desktop application
│   ├── MyProject/              # Delphi project files (.dpr)
│   ├── Unit/                   # Core utilities & global variables
│   ├── Master/                 # Master data modules (20+ modules)
│   ├── Trasaksi/               # Transaction modules (15+ modules)
│   ├── Setting/                # System configuration
│   └── ReportPreview/          # Reporting system
├── Boba/                       # Reference: Alternative implementation
│   ├── backend/                # Laravel reference
│   └── frontend/               # React reference
└── dokumentasi/                # Project documentation
```

**IMPORTANT**: The main working directories are `backend/` and `frontend/` in the root. The `Delphi/` and `Boba/` folders are references only.

## React Frontend

### Frontend Development Structure
The React frontend is located at the main `frontend/` directory:

- `frontend/` - React 18 SPA application
  - `src/` - React components and application code
  - `public/` - Static assets
  - `package.json` - Frontend dependencies

### Frontend Development Commands
- `cd frontend && npm install` - Install React dependencies
- `cd frontend && npm run dev` - Start React development server (http://localhost:5173)
- `cd frontend && npm run build` - Build production React application
- `cd frontend && npm run preview` - Preview production build locally

### Full Stack Development Workflow
1. **Start Laravel Backend**: `cd backend && php artisan serve` (http://localhost:8000)
2. **Start React Frontend**: `cd frontend && npm run dev` (http://localhost:5173)
3. **Development**: Both servers run simultaneously for full stack development
4. **API Communication**: React frontend communicates with Laravel API via CORS-enabled endpoints

### Frontend-Backend Integration
- **Authentication**: Token-based authentication using Laravel Sanctum
- **API Endpoints**: Laravel provides RESTful API at `/api/*` routes
- **CORS Configuration**: Configured to allow React development server communication
- **Build Integration**: Production React build serves from Laravel's `public/` directory

### Frontend Architecture
- **Framework**: React 18 with Vite bundler
- **State Management**: React Context API or Redux (as needed)
- **Routing**: React Router for SPA navigation
- **HTTP Client**: Axios for API communication
- **UI Components**: Modern React functional components with hooks

## Database Query Strategy

### Menu System Implementation
The application uses a **hybrid database approach** for the menu system:

#### Database Structure
- **DBMENU**: Master menu table (KODEMENU, Keterangan, L0, ACCESS)
- **DBFLMENU**: User menu permissions (USERID, L1, HASACCESS, ISTAMBAH, ISKOREKSI, ISHAPUS, ISCETAK, ISEXPORT)

#### Query Strategy Guidelines

**Use RAW SQL + Parameter Binding for COMPLEX queries:**
- Multiple JOINs (2+ tables)
- GROUP BY with aggregations (COUNT, SUM, AVG)
- Subqueries or Common Table Expressions (CTE)
- Performance-critical queries (called frequently)
- Advanced SQL functions (CASE, COALESCE)
- Complex business logic hard to express in Eloquent

```php
// Example: Complex JOIN with aggregations
$results = DB::select("
    SELECT A.USERID, B.L0, COUNT(*) as menu_count,
           COUNT(CASE WHEN A.HASACCESS = 1 THEN 1 END) as accessible_count
    FROM DBFLMENU A
    LEFT JOIN DBMENU B ON B.KODEMENU = A.L1
    WHERE A.USERID = ? AND B.ACCESS = ?
    GROUP BY A.USERID, B.L0
", [$userId, 1]);
```

**Use ELOQUENT ORM for SIMPLE queries:**
- Single table operations
- Basic CRUD operations (Create, Read, Update, Delete)
- Simple filtering and sorting
- Built-in relationships with `with()`, `whereHas()`
- Model events needed (creating, updating, deleting hooks)
- Easy testing and mocking required

```php
// Example: Simple CRUD operations
DbFLMENU::where('USERID', $userId)
        ->where('L1', $menuCode)
        ->where('HASACCESS', 1)
        ->first();

DbFLMENU::updateOrCreate(
    ['USERID' => $userId, 'L1' => $menuCode],
    ['HASACCESS' => $hasAccess]
);
```

#### Security Guidelines
- **ALWAYS use parameter binding** for user inputs: `DB::select("WHERE col = ?", [$input])`
- **NEVER use string concatenation**: Avoid `"WHERE col = '" . $input . "'"`
- **Validate all inputs** with Laravel validation rules before queries
- **Use whitelisting** for limited value sets when possible

#### Performance Optimization
- Use **caching** for frequently accessed menu data (5-10 minutes TTL)
- **Raw SQL** for complex joins (2-3x faster than Eloquent)
- **Eloquent** acceptable for simple queries with good maintainability
- Combine both approaches in Service classes for optimal balance

## Database Operations Policy

### User Approval Required for CRUD Operations
**CRITICAL**: All database modifications require explicit user approval before execution:

#### Operations Requiring User Approval:
- **CREATE**: Inserting new records (INSERT statements, model->save(), create())
- **UPDATE**: Modifying existing records (UPDATE statements, model->update(), updateOrCreate())
- **DELETE**: Removing records (DELETE statements, model->delete(), destroy())
- **MIGRATIONS**: Creating, modifying, or dropping tables/columns
- **SEEDERS**: Bulk data insertion operations

#### Approval Process:
1. **Present the proposed changes** clearly to the user
2. **Show exact SQL/Eloquent operations** that will be executed
3. **Wait for explicit user confirmation** before proceeding
4. **Never assume approval** - always ask first

#### Example Approval Flow:
```php
// BEFORE executing this code, ask user:
// "I need to create a new menu permission for user ID 123. 
// This will execute: INSERT INTO DBFLMENU (USERID, L1, HASACCESS) VALUES (123, 'MENU001', 1)
// May I proceed?"

DbFLMENU::create([
    'USERID' => 123,
    'L1' => 'MENU001', 
    'HASACCESS' => 1
]);
```

#### Read-Only Operations (No Approval Required):
- **SELECT**: Reading data (find(), get(), first(), where(), etc.)
- **ANALYSIS**: Counting, aggregating, reporting on existing data
- **SCHEMA INSPECTION**: Checking table structure, relationships

### Exception Handling
- If user denies approval, suggest **alternative approaches**
- Never execute unapproved database modifications
- Log approval requests for audit trail when needed

## Migration Context

### Delphi Legacy System
The original **Smart Accounting DAPEN-KA** was built as a Delphi desktop application with:
- **320+ forms** for comprehensive accounting modules
- **Object Pascal** business logic with global variables
- **ADO connections** to SQL Server database
- **DevExpress components** for rich desktop UI
- **FastReport** for reporting system

### Modern Web Implementation
The new Laravel implementation preserves:
- **Existing database schema** (100+ tables) for minimal disruption
- **Core business logic** migrated to Laravel services
- **User permission system** based on DBMENU/DBFLMENU tables
- **Complex stored procedures** (418 procedures maintained)

### Development Guidelines
- **Database schema preservation** - Never alter existing table structures without approval
- **Gradual migration** - Implement features incrementally to minimize risk
- **Business logic validation** - Cross-reference with Delphi implementation for accuracy
- **Performance optimization** - Use raw SQL for complex queries, Eloquent for simple operations

## Clean Code Standards

### Code Organization Principles

#### 1. Single Responsibility Principle (SRP)
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

#### 2. Dependency Injection & Service Layer
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

### Naming Conventions

#### PHP/Laravel Backend
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

#### React Frontend
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

### Function Design

#### Keep Functions Small & Focused
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

#### Use Descriptive Names
```php
// ❌ Bad: Unclear names
public function calc($d) {}
public function getData() {}

// ✅ Good: Descriptive names
public function calculateMonthlyInterest(float $principal): float {}
public function getUserTransactionHistory(int $userId): Collection {}
```

### Error Handling

#### Use Try-Catch Appropriately
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

#### Frontend Error Handling
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

### Documentation Standards

#### PHP DocBlocks
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

#### JSDoc for React
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

### Testing Guidelines

#### Unit Test Structure
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

### Security Best Practices

#### Input Validation
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

#### SQL Injection Prevention
```php
// ❌ Bad: String concatenation
$query = "SELECT * FROM users WHERE id = " . $userId;

// ✅ Good: Parameter binding
$user = DB::select("SELECT * FROM users WHERE id = ?", [$userId]);

// ✅ Good: Eloquent ORM
$user = User::find($userId);
```

### Performance Optimization

#### Database Queries
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

#### React Performance
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

### Code Review Checklist

#### Before Committing
- [ ] **Functionality**: Code works as expected
- [ ] **Readability**: Code is self-documenting
- [ ] **Performance**: No obvious performance issues
- [ ] **Security**: No security vulnerabilities
- [ ] **Testing**: Adequate test coverage
- [ ] **Documentation**: Updated when necessary
- [ ] **Standards**: Follows project coding standards
- [ ] **Dependencies**: No unnecessary dependencies added

#### Git Commit Messages
```bash
# ✅ Good commit message format
feat: add user authentication with JWT tokens

- Implement login/logout functionality
- Add middleware for protected routes
- Include password hashing with bcrypt
- Add unit tests for auth service

Closes #123
```

### Migration-Specific Guidelines

#### Preserving Legacy Compatibility
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

#### Business Logic Translation
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