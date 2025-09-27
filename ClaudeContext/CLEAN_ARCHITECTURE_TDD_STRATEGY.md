# Clean Architecture + TDD Strategy for DAPEN Project

🏛️ **STRATEGI CLEAN ARCHITECTURE + TDD** - Comprehensive strategy for implementing Clean Architecture with Test-Driven Development methodology

## Table of Contents

1. [Overview](#overview)
2. [Clean Architecture Layers](#clean-architecture-layers)
3. [TDD Workflow](#tdd-workflow)
4. [Implementation Strategy](#implementation-strategy)
5. [Laravel Implementation](#laravel-implementation)
6. [React Implementation](#react-implementation)
7. [Testing Strategy](#testing-strategy)
8. [Quality Gates](#quality-gates)
9. [Development Workflow](#development-workflow)
10. [Best Practices](#best-practices)

## Overview

Smart Accounting DAPEN-KA menggunakan **Clean Architecture** combined dengan **Test-Driven Development (TDD)** untuk memastikan:

- **Maintainability**: Code yang mudah dipelihara dan diubah
- **Testability**: Setiap layer dapat ditest secara independen
- **Scalability**: Arsitektur yang dapat berkembang seiring kebutuhan
- **Business Logic Protection**: Core business rules terlindungi dari perubahan framework
- **Quality Assurance**: High code quality melalui TDD practices

### Key Principles

#### Clean Architecture Principles
1. **Dependency Inversion**: Dependencies point inward toward the domain
2. **Single Responsibility**: Each layer has one clear responsibility
3. **Interface Segregation**: Depend on abstractions, not concretions
4. **Open/Closed**: Open for extension, closed for modification

#### TDD Principles
1. **Red**: Write failing test first
2. **Green**: Write minimal code to make test pass
3. **Refactor**: Improve code while keeping tests green
4. **Fast Feedback**: Quick test execution for rapid development

## Clean Architecture Layers

### Layer Structure

```
┌─────────────────────────────────────────┐
│           Domain Layer                  │
│  ┌─────────────────────────────────┐    │
│  │  Entities & Business Rules      │    │
│  │  - Accounting Entities          │    │
│  │  - Domain Services              │    │
│  │  - Business Rule Validation     │    │
│  └─────────────────────────────────┘    │
└─────────────────────────────────────────┘
┌─────────────────────────────────────────┐
│         Application Layer               │
│  ┌─────────────────────────────────┐    │
│  │  Use Cases & App Services       │    │
│  │  - Journal Entry Use Cases      │    │
│  │  - Application Workflows        │    │
│  │  - Cross-cutting Concerns       │    │
│  └─────────────────────────────────┘    │
└─────────────────────────────────────────┘
┌─────────────────────────────────────────┐
│        Interface Layer                  │
│  ┌─────────────────────────────────┐    │
│  │  Controllers & Adapters         │    │
│  │  - HTTP Controllers             │    │
│  │  - Repository Interfaces        │    │
│  │  - Response Formatters          │    │
│  └─────────────────────────────────┘    │
└─────────────────────────────────────────┘
┌─────────────────────────────────────────┐
│      Infrastructure Layer               │
│  ┌─────────────────────────────────┐    │
│  │  Framework & External Services  │    │
│  │  - Database (Eloquent)          │    │
│  │  - Web Framework (Laravel)      │    │
│  │  - External APIs                │    │
│  └─────────────────────────────────┘    │
└─────────────────────────────────────────┘
```

### 1. Domain Layer (Core Business)

**Purpose**: Contains pure business logic without external dependencies

#### Components
- **Entities**: Core business objects (Account, Transaction, JournalEntry)
- **Value Objects**: Immutable objects (Money, AccountNumber, Date)
- **Domain Services**: Business logic that doesn't belong to entities
- **Domain Events**: Business events for loose coupling
- **Repository Interfaces**: Abstract data access contracts

#### Example: Accounting Domain
```php
namespace App\Domain\Accounting\Entities;

class JournalEntry
{
    private JournalEntryId $id;
    private TransactionDate $date;
    private Description $description;
    private Money $totalDebit;
    private Money $totalCredit;
    private array $journalLines;

    public function addLine(JournalLine $line): void
    {
        $this->journalLines[] = $line;
        $this->recalculateTotals();

        if (!$this->isBalanced()) {
            throw new UnbalancedJournalException();
        }
    }

    public function isBalanced(): bool
    {
        return $this->totalDebit->equals($this->totalCredit);
    }

    private function recalculateTotals(): void
    {
        $debitTotal = Money::zero();
        $creditTotal = Money::zero();

        foreach ($this->journalLines as $line) {
            if ($line->isDebit()) {
                $debitTotal = $debitTotal->add($line->getAmount());
            } else {
                $creditTotal = $creditTotal->add($line->getAmount());
            }
        }

        $this->totalDebit = $debitTotal;
        $this->totalCredit = $creditTotal;
    }
}
```

### 2. Application Layer (Use Cases)

**Purpose**: Orchestrates domain objects and implements application-specific business rules

#### Components
- **Use Cases**: Application business logic workflows
- **Application Services**: Coordinate multiple use cases
- **DTOs**: Data transfer objects for input/output
- **Application Events**: Application-level events

#### Example: Journal Entry Use Case
```php
namespace App\Application\Accounting\UseCases;

class CreateJournalEntryUseCase
{
    public function __construct(
        private JournalEntryRepositoryInterface $repository,
        private AccountRepositoryInterface $accountRepository,
        private EventDispatcher $eventDispatcher
    ) {}

    public function execute(CreateJournalEntryCommand $command): JournalEntryResponse
    {
        // 1. Validate input
        $this->validateCommand($command);

        // 2. Create domain object
        $journalEntry = new JournalEntry(
            JournalEntryId::generate(),
            new TransactionDate($command->date),
            new Description($command->description)
        );

        // 3. Add journal lines
        foreach ($command->lines as $lineData) {
            $account = $this->accountRepository->findByCode($lineData['account_code']);

            $line = new JournalLine(
                $account,
                new Money($lineData['amount']),
                JournalLineType::fromString($lineData['type'])
            );

            $journalEntry->addLine($line);
        }

        // 4. Save to repository
        $this->repository->save($journalEntry);

        // 5. Dispatch events
        $this->eventDispatcher->dispatch(
            new JournalEntryCreated($journalEntry->getId())
        );

        return new JournalEntryResponse($journalEntry);
    }
}
```

### 3. Interface Layer (Adapters)

**Purpose**: Adapts external world to application use cases

#### Components
- **Controllers**: Handle HTTP requests/responses
- **Repositories**: Implement domain repository interfaces
- **Presenters**: Format data for external consumers
- **Gateways**: Integrate with external services

#### Example: HTTP Controller
```php
namespace App\Http\Controllers\Accounting;

class JournalEntryController extends Controller
{
    public function __construct(
        private CreateJournalEntryUseCase $createUseCase,
        private GetJournalEntryUseCase $getUseCase
    ) {}

    public function store(CreateJournalEntryRequest $request): JsonResponse
    {
        try {
            $command = new CreateJournalEntryCommand(
                $request->input('date'),
                $request->input('description'),
                $request->input('lines')
            );

            $response = $this->createUseCase->execute($command);

            return response()->json([
                'data' => JournalEntryResource::make($response->getJournalEntry()),
                'message' => 'Journal entry created successfully'
            ], 201);

        } catch (DomainException $e) {
            return response()->json([
                'error' => $e->getMessage()
            ], 422);
        }
    }

    public function show(string $id): JsonResponse
    {
        $query = new GetJournalEntryQuery($id);
        $response = $this->getUseCase->execute($query);

        return response()->json([
            'data' => JournalEntryResource::make($response->getJournalEntry())
        ]);
    }
}
```

### 4. Infrastructure Layer (Implementation Details)

**Purpose**: Implements interfaces defined in inner layers

#### Components
- **Database Repositories**: Eloquent implementations
- **External Service Clients**: API clients, file systems
- **Framework Configurations**: Laravel configurations
- **Third-party Integrations**: Payment gateways, etc.

#### Example: Repository Implementation
```php
namespace App\Infrastructure\Accounting\Repositories;

class EloquentJournalEntryRepository implements JournalEntryRepositoryInterface
{
    public function save(JournalEntry $journalEntry): void
    {
        DB::transaction(function () use ($journalEntry) {
            $model = EloquentJournalEntry::updateOrCreate(
                ['id' => $journalEntry->getId()->toString()],
                [
                    'date' => $journalEntry->getDate()->toString(),
                    'description' => $journalEntry->getDescription()->toString(),
                    'total_debit' => $journalEntry->getTotalDebit()->getAmount(),
                    'total_credit' => $journalEntry->getTotalCredit()->getAmount(),
                ]
            );

            // Save journal lines
            $model->lines()->delete();
            foreach ($journalEntry->getLines() as $line) {
                $model->lines()->create([
                    'account_code' => $line->getAccount()->getCode(),
                    'amount' => $line->getAmount()->getAmount(),
                    'type' => $line->getType()->toString(),
                ]);
            }
        });
    }

    public function findById(JournalEntryId $id): ?JournalEntry
    {
        $model = EloquentJournalEntry::with('lines.account')->find($id->toString());

        if (!$model) {
            return null;
        }

        return $this->toDomainEntity($model);
    }

    private function toDomainEntity(EloquentJournalEntry $model): JournalEntry
    {
        $journalEntry = new JournalEntry(
            new JournalEntryId($model->id),
            new TransactionDate($model->date),
            new Description($model->description)
        );

        foreach ($model->lines as $lineModel) {
            $account = new Account(
                new AccountCode($lineModel->account->code),
                new AccountName($lineModel->account->name)
            );

            $line = new JournalLine(
                $account,
                new Money($lineModel->amount),
                JournalLineType::fromString($lineModel->type)
            );

            $journalEntry->addLine($line);
        }

        return $journalEntry;
    }
}
```

## TDD Workflow

### Red-Green-Refactor Cycle

#### 1. Red Phase (Write Failing Test)
```php
class CreateJournalEntryUseCaseTest extends TestCase
{
    /** @test */
    public function it_creates_journal_entry_with_balanced_lines(): void
    {
        // Arrange
        $command = new CreateJournalEntryCommand(
            '2024-01-15',
            'Office supplies purchase',
            [
                ['account_code' => '5001', 'amount' => 100.00, 'type' => 'debit'],
                ['account_code' => '1001', 'amount' => 100.00, 'type' => 'credit']
            ]
        );

        $this->accountRepository->shouldReceive('findByCode')
            ->with('5001')
            ->andReturn($this->expenseAccount);

        $this->accountRepository->shouldReceive('findByCode')
            ->with('1001')
            ->andReturn($this->cashAccount);

        $this->journalRepository->shouldReceive('save')
            ->once()
            ->with(Mockery::type(JournalEntry::class));

        // Act
        $response = $this->useCase->execute($command);

        // Assert
        $this->assertInstanceOf(JournalEntryResponse::class, $response);
        $this->assertTrue($response->getJournalEntry()->isBalanced());
    }

    /** @test */
    public function it_throws_exception_for_unbalanced_journal_entry(): void
    {
        // Arrange
        $command = new CreateJournalEntryCommand(
            '2024-01-15',
            'Unbalanced entry',
            [
                ['account_code' => '5001', 'amount' => 100.00, 'type' => 'debit'],
                ['account_code' => '1001', 'amount' => 50.00, 'type' => 'credit']
            ]
        );

        // Assert
        $this->expectException(UnbalancedJournalException::class);

        // Act
        $this->useCase->execute($command);
    }
}
```

#### 2. Green Phase (Make Test Pass)
```php
// Minimal implementation to make test pass
class CreateJournalEntryUseCase
{
    public function execute(CreateJournalEntryCommand $command): JournalEntryResponse
    {
        $journalEntry = new JournalEntry(
            JournalEntryId::generate(),
            new TransactionDate($command->date),
            new Description($command->description)
        );

        foreach ($command->lines as $lineData) {
            $account = $this->accountRepository->findByCode($lineData['account_code']);

            $line = new JournalLine(
                $account,
                new Money($lineData['amount']),
                JournalLineType::fromString($lineData['type'])
            );

            $journalEntry->addLine($line); // This will throw if unbalanced
        }

        $this->repository->save($journalEntry);

        return new JournalEntryResponse($journalEntry);
    }
}
```

#### 3. Refactor Phase (Improve Code)
```php
// Refactored with better structure
class CreateJournalEntryUseCase
{
    public function execute(CreateJournalEntryCommand $command): JournalEntryResponse
    {
        $this->validateCommand($command);

        $journalEntry = $this->createJournalEntry($command);
        $this->addJournalLines($journalEntry, $command->lines);

        $this->repository->save($journalEntry);
        $this->dispatchEvents($journalEntry);

        return new JournalEntryResponse($journalEntry);
    }

    private function validateCommand(CreateJournalEntryCommand $command): void
    {
        if (empty($command->lines)) {
            throw new InvalidJournalEntryException('Journal entry must have at least one line');
        }

        if (count($command->lines) < 2) {
            throw new InvalidJournalEntryException('Journal entry must have at least two lines');
        }
    }

    private function createJournalEntry(CreateJournalEntryCommand $command): JournalEntry
    {
        return new JournalEntry(
            JournalEntryId::generate(),
            new TransactionDate($command->date),
            new Description($command->description)
        );
    }

    private function addJournalLines(JournalEntry $journalEntry, array $lines): void
    {
        foreach ($lines as $lineData) {
            $account = $this->findAccount($lineData['account_code']);

            $line = new JournalLine(
                $account,
                new Money($lineData['amount']),
                JournalLineType::fromString($lineData['type'])
            );

            $journalEntry->addLine($line);
        }
    }

    private function findAccount(string $accountCode): Account
    {
        $account = $this->accountRepository->findByCode($accountCode);

        if (!$account) {
            throw new AccountNotFoundException("Account {$accountCode} not found");
        }

        return $account;
    }
}
```

## Laravel Implementation

### Directory Structure
```
app/
├── Domain/                     # Domain Layer
│   ├── Accounting/
│   │   ├── Entities/
│   │   │   ├── JournalEntry.php
│   │   │   ├── Account.php
│   │   │   └── JournalLine.php
│   │   ├── ValueObjects/
│   │   │   ├── Money.php
│   │   │   ├── AccountCode.php
│   │   │   └── TransactionDate.php
│   │   ├── Services/
│   │   │   └── BalanceCalculator.php
│   │   ├── Events/
│   │   │   └── JournalEntryCreated.php
│   │   └── Repositories/
│   │       ├── JournalEntryRepositoryInterface.php
│   │       └── AccountRepositoryInterface.php
│   └── Shared/
│       ├── Exceptions/
│       └── ValueObjects/
├── Application/                # Application Layer
│   ├── Accounting/
│   │   ├── UseCases/
│   │   │   ├── CreateJournalEntryUseCase.php
│   │   │   ├── GetJournalEntryUseCase.php
│   │   │   └── UpdateJournalEntryUseCase.php
│   │   ├── Commands/
│   │   │   ├── CreateJournalEntryCommand.php
│   │   │   └── UpdateJournalEntryCommand.php
│   │   ├── Queries/
│   │   │   └── GetJournalEntryQuery.php
│   │   ├── Responses/
│   │   │   └── JournalEntryResponse.php
│   │   └── Services/
│   │       └── JournalEntryService.php
│   └── Shared/
│       ├── Events/
│       └── Services/
├── Http/                       # Interface Layer
│   ├── Controllers/
│   │   └── Accounting/
│   │       └── JournalEntryController.php
│   ├── Requests/
│   │   └── Accounting/
│   │       ├── CreateJournalEntryRequest.php
│   │       └── UpdateJournalEntryRequest.php
│   ├── Resources/
│   │   └── Accounting/
│   │       └── JournalEntryResource.php
│   └── Middleware/
└── Infrastructure/             # Infrastructure Layer
    ├── Accounting/
    │   ├── Repositories/
    │   │   ├── EloquentJournalEntryRepository.php
    │   │   └── EloquentAccountRepository.php
    │   └── Models/
    │       ├── EloquentJournalEntry.php
    │       ├── EloquentAccount.php
    │       └── EloquentJournalLine.php
    ├── Persistence/
    │   └── Migrations/
    └── External/
        └── Services/
```

### Service Provider Configuration
```php
namespace App\Providers;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        // Repository bindings
        $this->app->bind(
            JournalEntryRepositoryInterface::class,
            EloquentJournalEntryRepository::class
        );

        $this->app->bind(
            AccountRepositoryInterface::class,
            EloquentAccountRepository::class
        );

        // Use case bindings
        $this->app->bind(CreateJournalEntryUseCase::class, function ($app) {
            return new CreateJournalEntryUseCase(
                $app->make(JournalEntryRepositoryInterface::class),
                $app->make(AccountRepositoryInterface::class),
                $app->make(EventDispatcher::class)
            );
        });
    }
}
```

## React Implementation

### Clean Architecture in React

#### Component Structure
```
src/
├── domain/                     # Domain Layer
│   ├── entities/
│   │   ├── JournalEntry.ts
│   │   ├── Account.ts
│   │   └── JournalLine.ts
│   ├── valueObjects/
│   │   ├── Money.ts
│   │   └── AccountCode.ts
│   └── services/
│       └── ValidationService.ts
├── application/                # Application Layer
│   ├── useCases/
│   │   ├── CreateJournalEntryUseCase.ts
│   │   └── GetJournalEntryUseCase.ts
│   ├── services/
│   │   └── JournalEntryService.ts
│   └── ports/
│       ├── JournalEntryRepository.ts
│       └── ApiClient.ts
├── adapters/                   # Interface Layer
│   ├── api/
│   │   ├── HttpClient.ts
│   │   └── JournalEntryApiAdapter.ts
│   ├── repositories/
│   │   └── ApiJournalEntryRepository.ts
│   └── presenters/
│       └── JournalEntryPresenter.ts
├── infrastructure/             # Infrastructure Layer
│   ├── http/
│   │   └── AxiosClient.ts
│   ├── storage/
│   │   └── LocalStorageAdapter.ts
│   └── external/
│       └── ThirdPartyServices.ts
└── presentation/               # UI Layer
    ├── components/
    │   ├── JournalEntry/
    │   │   ├── JournalEntryForm.tsx
    │   │   ├── JournalEntryList.tsx
    │   │   └── JournalLineInput.tsx
    │   └── shared/
    ├── pages/
    │   └── JournalEntryPage.tsx
    ├── hooks/
    │   ├── useJournalEntry.ts
    │   └── useValidation.ts
    └── contexts/
        └── JournalEntryContext.tsx
```

#### Example: React Use Case
```typescript
// application/useCases/CreateJournalEntryUseCase.ts
export class CreateJournalEntryUseCase {
    constructor(
        private repository: JournalEntryRepository,
        private validator: ValidationService
    ) {}

    async execute(command: CreateJournalEntryCommand): Promise<JournalEntry> {
        // 1. Validate input
        const validationResult = this.validator.validate(command);
        if (!validationResult.isValid) {
            throw new ValidationError(validationResult.errors);
        }

        // 2. Create domain entity
        const journalEntry = JournalEntry.create({
            date: command.date,
            description: command.description,
            lines: command.lines.map(line => JournalLine.create(line))
        });

        // 3. Business rule validation
        if (!journalEntry.isBalanced()) {
            throw new UnbalancedJournalError('Debit and credit amounts must be equal');
        }

        // 4. Save via repository
        return await this.repository.save(journalEntry);
    }
}

// presentation/hooks/useJournalEntry.ts
export const useJournalEntry = () => {
    const [journalEntry, setJournalEntry] = useState<JournalEntry | null>(null);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);

    const createJournalEntry = useCallback(async (data: CreateJournalEntryData) => {
        try {
            setLoading(true);
            setError(null);

            const command = new CreateJournalEntryCommand(data);
            const useCase = new CreateJournalEntryUseCase(
                container.get(JournalEntryRepository),
                container.get(ValidationService)
            );

            const result = await useCase.execute(command);
            setJournalEntry(result);

        } catch (err) {
            setError(err instanceof Error ? err.message : 'Unknown error');
        } finally {
            setLoading(false);
        }
    }, []);

    return {
        journalEntry,
        loading,
        error,
        createJournalEntry
    };
};

// presentation/components/JournalEntry/JournalEntryForm.tsx
export const JournalEntryForm: React.FC = () => {
    const { createJournalEntry, loading, error } = useJournalEntry();
    const [formData, setFormData] = useState<JournalEntryFormData>({
        date: '',
        description: '',
        lines: []
    });

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        await createJournalEntry(formData);
    };

    return (
        <form onSubmit={handleSubmit}>
            <DateInput
                value={formData.date}
                onChange={(date) => setFormData(prev => ({ ...prev, date }))}
                required
            />

            <TextInput
                value={formData.description}
                onChange={(description) => setFormData(prev => ({ ...prev, description }))}
                placeholder="Transaction description"
                required
            />

            <JournalLinesInput
                lines={formData.lines}
                onChange={(lines) => setFormData(prev => ({ ...prev, lines }))}
            />

            {error && <ErrorMessage message={error} />}

            <Button
                type="submit"
                disabled={loading}
                loading={loading}
            >
                Create Journal Entry
            </Button>
        </form>
    );
};
```

## Testing Strategy

### Testing Pyramid

```
                    ┌─────────────────┐
                    │   E2E Tests     │ ← Few, Slow, Expensive
                    │   (Playwright)  │
                ┌───┴─────────────────┴───┐
                │   Integration Tests     │ ← Some, Medium Speed
                │   (Feature Tests)       │
            ┌───┴─────────────────────────┴───┐
            │        Unit Tests               │ ← Many, Fast, Cheap
            │   (Domain, Use Cases, etc.)     │
        └───────────────────────────────────────┘
```

### 1. Unit Tests (Domain & Application Layer)

#### Domain Entity Tests
```php
class JournalEntryTest extends TestCase
{
    /** @test */
    public function it_creates_journal_entry_with_valid_data(): void
    {
        $journalEntry = new JournalEntry(
            new JournalEntryId('journal-123'),
            new TransactionDate('2024-01-15'),
            new Description('Office supplies purchase')
        );

        $this->assertEquals('journal-123', $journalEntry->getId()->toString());
        $this->assertEquals('2024-01-15', $journalEntry->getDate()->toString());
        $this->assertEquals('Office supplies purchase', $journalEntry->getDescription()->toString());
    }

    /** @test */
    public function it_validates_balanced_journal_lines(): void
    {
        $journalEntry = new JournalEntry(
            new JournalEntryId('journal-123'),
            new TransactionDate('2024-01-15'),
            new Description('Test entry')
        );

        $debitLine = new JournalLine(
            $this->createAccount('5001'),
            new Money(100.00),
            JournalLineType::DEBIT
        );

        $creditLine = new JournalLine(
            $this->createAccount('1001'),
            new Money(100.00),
            JournalLineType::CREDIT
        );

        $journalEntry->addLine($debitLine);
        $journalEntry->addLine($creditLine);

        $this->assertTrue($journalEntry->isBalanced());
    }

    /** @test */
    public function it_throws_exception_for_unbalanced_journal(): void
    {
        $this->expectException(UnbalancedJournalException::class);

        $journalEntry = new JournalEntry(
            new JournalEntryId('journal-123'),
            new TransactionDate('2024-01-15'),
            new Description('Unbalanced entry')
        );

        $debitLine = new JournalLine(
            $this->createAccount('5001'),
            new Money(100.00),
            JournalLineType::DEBIT
        );

        $creditLine = new JournalLine(
            $this->createAccount('1001'),
            new Money(50.00), // Unbalanced amount
            JournalLineType::CREDIT
        );

        $journalEntry->addLine($debitLine);
        $journalEntry->addLine($creditLine); // Should throw
    }
}
```

#### Use Case Tests
```php
class CreateJournalEntryUseCaseTest extends TestCase
{
    private CreateJournalEntryUseCase $useCase;
    private MockObject $journalRepository;
    private MockObject $accountRepository;

    protected function setUp(): void
    {
        $this->journalRepository = $this->createMock(JournalEntryRepositoryInterface::class);
        $this->accountRepository = $this->createMock(AccountRepositoryInterface::class);

        $this->useCase = new CreateJournalEntryUseCase(
            $this->journalRepository,
            $this->accountRepository,
            new InMemoryEventDispatcher()
        );
    }

    /** @test */
    public function it_creates_journal_entry_successfully(): void
    {
        // Arrange
        $command = new CreateJournalEntryCommand(
            '2024-01-15',
            'Office supplies',
            [
                ['account_code' => '5001', 'amount' => 100.00, 'type' => 'debit'],
                ['account_code' => '1001', 'amount' => 100.00, 'type' => 'credit']
            ]
        );

        $this->accountRepository
            ->method('findByCode')
            ->willReturnMap([
                ['5001', $this->createAccount('5001', 'Office Supplies')],
                ['1001', $this->createAccount('1001', 'Cash')]
            ]);

        $this->journalRepository
            ->expects($this->once())
            ->method('save')
            ->with($this->isInstanceOf(JournalEntry::class));

        // Act
        $response = $this->useCase->execute($command);

        // Assert
        $this->assertInstanceOf(JournalEntryResponse::class, $response);
        $this->assertTrue($response->getJournalEntry()->isBalanced());
    }

    /** @test */
    public function it_throws_exception_when_account_not_found(): void
    {
        // Arrange
        $command = new CreateJournalEntryCommand(
            '2024-01-15',
            'Invalid account test',
            [
                ['account_code' => '9999', 'amount' => 100.00, 'type' => 'debit'],
                ['account_code' => '1001', 'amount' => 100.00, 'type' => 'credit']
            ]
        );

        $this->accountRepository
            ->method('findByCode')
            ->with('9999')
            ->willReturn(null);

        // Assert
        $this->expectException(AccountNotFoundException::class);

        // Act
        $this->useCase->execute($command);
    }
}
```

### 2. Integration Tests (Interface Layer)

```php
class JournalEntryControllerTest extends TestCase
{
    use RefreshDatabase;

    /** @test */
    public function it_creates_journal_entry_via_api(): void
    {
        // Arrange
        $user = User::factory()->create();

        Account::factory()->create(['code' => '5001', 'name' => 'Office Supplies']);
        Account::factory()->create(['code' => '1001', 'name' => 'Cash']);

        $requestData = [
            'date' => '2024-01-15',
            'description' => 'Office supplies purchase',
            'lines' => [
                ['account_code' => '5001', 'amount' => 100.00, 'type' => 'debit'],
                ['account_code' => '1001', 'amount' => 100.00, 'type' => 'credit']
            ]
        ];

        // Act
        $response = $this->actingAs($user)
            ->postJson('/api/journal-entries', $requestData);

        // Assert
        $response->assertStatus(201)
            ->assertJsonStructure([
                'data' => [
                    'id',
                    'date',
                    'description',
                    'total_debit',
                    'total_credit',
                    'lines'
                ],
                'message'
            ]);

        $this->assertDatabaseHas('journal_entries', [
            'date' => '2024-01-15',
            'description' => 'Office supplies purchase',
            'total_debit' => 100.00,
            'total_credit' => 100.00
        ]);
    }

    /** @test */
    public function it_validates_journal_entry_data(): void
    {
        // Arrange
        $user = User::factory()->create();

        $invalidData = [
            'date' => 'invalid-date',
            'description' => '',
            'lines' => []
        ];

        // Act
        $response = $this->actingAs($user)
            ->postJson('/api/journal-entries', $invalidData);

        // Assert
        $response->assertStatus(422)
            ->assertJsonValidationErrors(['date', 'description', 'lines']);
    }
}
```

### 3. End-to-End Tests (Full Application)

```javascript
// tests/e2e/journal-entry.spec.js
import { test, expect } from '@playwright/test';

test.describe('Journal Entry Management', () => {
    test.beforeEach(async ({ page }) => {
        await page.goto('/login');
        await page.fill('[data-testid="email"]', 'admin@example.com');
        await page.fill('[data-testid="password"]', 'password');
        await page.click('[data-testid="login-button"]');
        await page.waitForURL('/dashboard');
    });

    test('should create a new journal entry', async ({ page }) => {
        // Navigate to journal entry page
        await page.click('[data-testid="accounting-menu"]');
        await page.click('[data-testid="journal-entries-link"]');
        await page.click('[data-testid="create-journal-entry"]');

        // Fill journal entry form
        await page.fill('[data-testid="date-input"]', '2024-01-15');
        await page.fill('[data-testid="description-input"]', 'Office supplies purchase');

        // Add debit line
        await page.click('[data-testid="add-line-button"]');
        await page.selectOption('[data-testid="account-select-0"]', '5001');
        await page.fill('[data-testid="amount-input-0"]', '100.00');
        await page.selectOption('[data-testid="type-select-0"]', 'debit');

        // Add credit line
        await page.click('[data-testid="add-line-button"]');
        await page.selectOption('[data-testid="account-select-1"]', '1001');
        await page.fill('[data-testid="amount-input-1"]', '100.00');
        await page.selectOption('[data-testid="type-select-1"]', 'credit');

        // Submit form
        await page.click('[data-testid="submit-button"]');

        // Verify success
        await expect(page.locator('[data-testid="success-message"]')).toBeVisible();
        await expect(page.locator('[data-testid="journal-entry-list"]')).toContainText('Office supplies purchase');
    });

    test('should validate unbalanced journal entry', async ({ page }) => {
        await page.goto('/journal-entries/create');

        // Fill unbalanced entry
        await page.fill('[data-testid="date-input"]', '2024-01-15');
        await page.fill('[data-testid="description-input"]', 'Unbalanced entry');

        // Add unbalanced lines
        await page.click('[data-testid="add-line-button"]');
        await page.selectOption('[data-testid="account-select-0"]', '5001');
        await page.fill('[data-testid="amount-input-0"]', '100.00');
        await page.selectOption('[data-testid="type-select-0"]', 'debit');

        await page.click('[data-testid="add-line-button"]');
        await page.selectOption('[data-testid="account-select-1"]', '1001');
        await page.fill('[data-testid="amount-input-1"]', '50.00'); // Unbalanced
        await page.selectOption('[data-testid="type-select-1"]', 'credit');

        // Try to submit
        await page.click('[data-testid="submit-button"]');

        // Verify validation error
        await expect(page.locator('[data-testid="error-message"]')).toContainText('Journal entry must be balanced');
    });
});
```

## E2E Testing Protocol (Playwright)

### Auto-Run Strategy
```bash
# Automated testing sequence
1. Unit Tests (Domain + Application)     → MUST PASS
2. Integration Tests (Controllers + DB)  → MUST PASS
3. Playwright E2E Tests                  → FINAL GATE
4. Only then: git commit && git push
```

### Trigger Conditions
- **Before every commit/push**
- **After changes to:**
  - `app/Http/Controllers/` (API endpoints)
  - `routes/` (route definitions)
  - `resources/views/` (Blade templates)
  - `frontend/src/components/` (React components)

### Failure Recovery Protocol
```javascript
// FAILED: Element not found
await expect(page.locator('.sidebar')).toBeVisible();

// ANALYZE: UI timing vs real bug
if (timing_issue) {
    // FIX: Add proper waits
    await page.waitForLoadState('networkidle');
    await expect(page.locator('.sidebar')).toBeVisible({ timeout: 10000 });
} else {
    // REAL BUG: Back to RED phase
    // Fix in Unit/Integration tests first
    // Then re-run full sequence
}
```

### E2E as Gatekeeper
- **Playwright FAIL** = **NO DEPLOYMENT**
- **Back to TDD RED** if real bug found
- **Fix root cause** in Unit/Integration layer
- **Re-run sequence** until all pass

## Quality Gates

### Code Quality Metrics

#### Required Metrics
- **Test Coverage**: Minimum 80% overall, 90% for domain layer
- **Cyclomatic Complexity**: Maximum 10 per method
- **Code Duplication**: Maximum 3%
- **Technical Debt Ratio**: Maximum 5%

#### Static Analysis Tools
```php
// phpstan.neon
parameters:
    level: 8
    paths:
        - app/Domain
        - app/Application
        - app/Http
        - app/Infrastructure
    ignoreErrors:
        - '#Access to an undefined property#'

// rector.php
use Rector\Config\RectorConfig;

return static function (RectorConfig $rectorConfig): void {
    $rectorConfig->paths([
        __DIR__ . '/app/Domain',
        __DIR__ . '/app/Application',
        __DIR__ . '/app/Http',
        __DIR__ . '/app/Infrastructure',
    ]);

    $rectorConfig->sets([
        SetList::CODE_QUALITY,
        SetList::DEAD_CODE,
        SetList::EARLY_RETURN,
        SetList::TYPE_DECLARATION,
    ]);
};
```

#### CI/CD Pipeline Quality Gates
```yaml
# .github/workflows/quality-gates.yml
name: Quality Gates

on: [push, pull_request]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: 8.1
      - name: Install dependencies
        run: composer install
      - name: Run unit tests
        run: vendor/bin/phpunit --testsuite=Unit --coverage-clover=coverage.xml
      - name: Check coverage threshold
        run: |
          coverage=$(php artisan coverage:check --min=80)
          echo "Coverage: $coverage"

  integration-tests:
    runs-on: ubuntu-latest
    needs: unit-tests
    steps:
      - uses: actions/checkout@v3
      - name: Setup environment
        run: |
          cp .env.testing .env
          php artisan key:generate
      - name: Run integration tests
        run: vendor/bin/phpunit --testsuite=Feature

  static-analysis:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: PHPStan Analysis
        run: vendor/bin/phpstan analyse
      - name: Rector Quality Check
        run: vendor/bin/rector process --dry-run

  architecture-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Architecture Tests
        run: vendor/bin/phpunit --testsuite=Architecture

  e2e-tests:
    runs-on: ubuntu-latest
    needs: [unit-tests, integration-tests]
    steps:
      - uses: actions/checkout@v3
      - name: Install Playwright
        run: npx playwright install
      - name: Run E2E tests
        run: npx playwright test

  deployment:
    runs-on: ubuntu-latest
    needs: [unit-tests, integration-tests, static-analysis, architecture-tests, e2e-tests]
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Deploy to staging
        run: echo "Deploying to staging..."
```

### Architecture Compliance Tests

```php
// tests/Architecture/CleanArchitectureTest.php
class CleanArchitectureTest extends TestCase
{
    /** @test */
    public function domain_layer_should_not_depend_on_outer_layers(): void
    {
        $this->assertArchRule(
            classes()->that()->haveNameMatching('App\\Domain\\.*')
                ->should()->notDependOnClasses([
                    'App\\Application\\.*',
                    'App\\Http\\.*',
                    'App\\Infrastructure\\.*',
                    'Illuminate\\.*'
                ])
        );
    }

    /** @test */
    public function application_layer_should_not_depend_on_interface_or_infrastructure(): void
    {
        $this->assertArchRule(
            classes()->that()->haveNameMatching('App\\Application\\.*')
                ->should()->notDependOnClasses([
                    'App\\Http\\.*',
                    'App\\Infrastructure\\.*'
                ])
        );
    }

    /** @test */
    public function controllers_should_only_depend_on_use_cases(): void
    {
        $this->assertArchRule(
            classes()->that()->haveNameMatching('App\\Http\\Controllers\\.*')
                ->should()->onlyDependOnClasses([
                    'App\\Application\\.*\\UseCases\\.*',
                    'App\\Http\\Requests\\.*',
                    'App\\Http\\Resources\\.*',
                    'Illuminate\\.*'
                ])
        );
    }

    /** @test */
    public function repositories_should_implement_domain_interfaces(): void
    {
        $this->assertArchRule(
            classes()->that()->haveNameMatching('App\\Infrastructure\\.*\\Repositories\\.*')
                ->should()->implement('App\\Domain\\.*\\Repositories\\.*Interface')
        );
    }
}
```

## Development Workflow

### Daily Development Cycle

#### 1. Feature Development (TDD Approach)
```bash
# 1. Create feature branch
git checkout -b feature/journal-entry-validation

# 2. Write failing test (Red)
php artisan make:test CreateJournalEntryUseCaseTest --unit

# 3. Run test to see it fail
vendor/bin/phpunit tests/Unit/CreateJournalEntryUseCaseTest.php

# 4. Write minimal code to pass (Green)
# Implement use case logic

# 5. Run test to see it pass
vendor/bin/phpunit tests/Unit/CreateJournalEntryUseCaseTest.php

# 6. Refactor code (Refactor)
# Improve code structure, extract methods, etc.

# 7. Run all tests to ensure nothing breaks
vendor/bin/phpunit

# 8. Commit changes
git add .
git commit -m "feat: add journal entry validation use case

- Implement CreateJournalEntryUseCase with balance validation
- Add comprehensive unit tests with edge cases
- Follow TDD red-green-refactor cycle

Closes #123"
```

#### 2. Code Review Process
```markdown
## Pull Request Checklist

### Code Quality
- [ ] All tests pass (unit, integration, E2E)
- [ ] Test coverage ≥ 80%
- [ ] No static analysis violations
- [ ] Architecture compliance verified
- [ ] Code follows Clean Architecture principles

### TDD Compliance
- [ ] Tests written before implementation
- [ ] Tests cover happy path and edge cases
- [ ] Tests are readable and maintainable
- [ ] Mock objects used appropriately
- [ ] Test names clearly describe behavior

### Domain Modeling
- [ ] Domain entities are pure (no framework dependencies)
- [ ] Business rules are properly encapsulated
- [ ] Value objects are immutable
- [ ] Domain events are well-defined

### Implementation
- [ ] Use cases are focused and testable
- [ ] Controllers are thin and focused
- [ ] Repository interfaces are well-defined
- [ ] Dependencies flow inward only
```

#### 3. Continuous Integration
```yaml
# .github/workflows/ci.yml
name: Continuous Integration

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        php-version: [8.1, 8.2]

    steps:
    - uses: actions/checkout@v3

    - name: Setup PHP
      uses: shivammathur/setup-php@v2
      with:
        php-version: ${{ matrix.php-version }}
        extensions: mbstring, xml, ctype, iconv, intl, pdo_sqlite

    - name: Cache Composer packages
      uses: actions/cache@v3
      with:
        path: vendor
        key: ${{ runner.os }}-php-${{ hashFiles('**/composer.lock') }}

    - name: Install dependencies
      run: composer install --prefer-dist --no-progress

    - name: Setup environment
      run: |
        cp .env.testing .env
        php artisan key:generate

    - name: Run unit tests
      run: vendor/bin/phpunit --testsuite=Unit --coverage-clover=coverage.xml

    - name: Run integration tests
      run: vendor/bin/phpunit --testsuite=Feature

    - name: Run architecture tests
      run: vendor/bin/phpunit --testsuite=Architecture

    - name: Static analysis
      run: vendor/bin/phpstan analyse

    - name: Code style check
      run: vendor/bin/php-cs-fixer fix --dry-run --diff

    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.xml
```

## Best Practices

### 1. Domain Modeling Best Practices

#### Rich Domain Model
```php
// ✅ Good: Rich domain model with behavior
class JournalEntry
{
    private JournalEntryId $id;
    private TransactionDate $date;
    private Description $description;
    private array $lines = [];

    public function addLine(JournalLine $line): void
    {
        $this->lines[] = $line;

        if (!$this->isBalanced()) {
            throw new UnbalancedJournalException();
        }
    }

    public function isBalanced(): bool
    {
        $debitTotal = Money::zero();
        $creditTotal = Money::zero();

        foreach ($this->lines as $line) {
            if ($line->isDebit()) {
                $debitTotal = $debitTotal->add($line->getAmount());
            } else {
                $creditTotal = $creditTotal->add($line->getAmount());
            }
        }

        return $debitTotal->equals($creditTotal);
    }

    public function canBePosted(): bool
    {
        return $this->isBalanced() &&
               count($this->lines) >= 2 &&
               $this->date->isNotInFuture();
    }
}

// ❌ Bad: Anemic domain model (just data)
class JournalEntry
{
    public string $id;
    public string $date;
    public string $description;
    public array $lines;

    // No behavior, just getters/setters
}
```

#### Value Objects
```php
// ✅ Good: Immutable value objects
class Money
{
    private float $amount;
    private Currency $currency;

    public function __construct(float $amount, Currency $currency = null)
    {
        if ($amount < 0) {
            throw new InvalidArgumentException('Money amount cannot be negative');
        }

        $this->amount = $amount;
        $this->currency = $currency ?? Currency::defaultCurrency();
    }

    public function add(Money $other): Money
    {
        $this->ensureSameCurrency($other);
        return new Money($this->amount + $other->amount, $this->currency);
    }

    public function equals(Money $other): bool
    {
        return $this->amount === $other->amount &&
               $this->currency->equals($other->currency);
    }

    public static function zero(Currency $currency = null): Money
    {
        return new Money(0, $currency);
    }
}
```

### 2. Use Case Best Practices

#### Single Responsibility
```php
// ✅ Good: Focused use case
class CreateJournalEntryUseCase
{
    public function execute(CreateJournalEntryCommand $command): JournalEntryResponse
    {
        // Single responsibility: create journal entry
        $journalEntry = $this->buildJournalEntry($command);
        $this->validateBusinessRules($journalEntry);
        $this->saveJournalEntry($journalEntry);
        $this->publishEvents($journalEntry);

        return new JournalEntryResponse($journalEntry);
    }
}

// ❌ Bad: Multiple responsibilities
class JournalEntryUseCase
{
    public function createJournalEntry($data) { }
    public function updateJournalEntry($id, $data) { }
    public function deleteJournalEntry($id) { }
    public function getJournalEntry($id) { }
    // Too many responsibilities in one class
}
```

#### Command/Query Separation
```php
// ✅ Good: Separate commands and queries
class CreateJournalEntryCommand
{
    public function __construct(
        public readonly string $date,
        public readonly string $description,
        public readonly array $lines
    ) {}
}

class GetJournalEntryQuery
{
    public function __construct(
        public readonly string $id
    ) {}
}

// Different use cases for commands vs queries
class CreateJournalEntryUseCase { } // Command
class GetJournalEntryUseCase { }    // Query
```

### 3. Testing Best Practices

#### Test Naming and Structure
```php
// ✅ Good: Descriptive test names and AAA structure
class CreateJournalEntryUseCaseTest extends TestCase
{
    /** @test */
    public function it_creates_balanced_journal_entry_with_valid_data(): void
    {
        // Arrange
        $command = new CreateJournalEntryCommand(
            '2024-01-15',
            'Office supplies',
            [
                ['account_code' => '5001', 'amount' => 100.00, 'type' => 'debit'],
                ['account_code' => '1001', 'amount' => 100.00, 'type' => 'credit']
            ]
        );

        // Act
        $response = $this->useCase->execute($command);

        // Assert
        $this->assertInstanceOf(JournalEntryResponse::class, $response);
        $this->assertTrue($response->getJournalEntry()->isBalanced());
    }

    /** @test */
    public function it_throws_exception_when_journal_entry_is_unbalanced(): void
    {
        // Arrange
        $command = new CreateJournalEntryCommand(
            '2024-01-15',
            'Unbalanced entry',
            [
                ['account_code' => '5001', 'amount' => 100.00, 'type' => 'debit'],
                ['account_code' => '1001', 'amount' => 50.00, 'type' => 'credit']
            ]
        );

        // Assert
        $this->expectException(UnbalancedJournalException::class);
        $this->expectExceptionMessage('Journal entry must be balanced');

        // Act
        $this->useCase->execute($command);
    }
}
```

#### Test Data Builders
```php
// ✅ Good: Use test data builders for complex objects
class JournalEntryBuilder
{
    private string $id = 'default-id';
    private string $date = '2024-01-01';
    private string $description = 'Default description';
    private array $lines = [];

    public static function create(): self
    {
        return new self();
    }

    public function withId(string $id): self
    {
        $this->id = $id;
        return $this;
    }

    public function withDate(string $date): self
    {
        $this->date = $date;
        return $this;
    }

    public function withDescription(string $description): self
    {
        $this->description = $description;
        return $this;
    }

    public function withBalancedLines(float $amount = 100.00): self
    {
        $this->lines = [
            ['account_code' => '5001', 'amount' => $amount, 'type' => 'debit'],
            ['account_code' => '1001', 'amount' => $amount, 'type' => 'credit']
        ];
        return $this;
    }

    public function build(): JournalEntry
    {
        $journalEntry = new JournalEntry(
            new JournalEntryId($this->id),
            new TransactionDate($this->date),
            new Description($this->description)
        );

        foreach ($this->lines as $lineData) {
            $account = AccountBuilder::create()
                ->withCode($lineData['account_code'])
                ->build();

            $line = new JournalLine(
                $account,
                new Money($lineData['amount']),
                JournalLineType::fromString($lineData['type'])
            );

            $journalEntry->addLine($line);
        }

        return $journalEntry;
    }
}

// Usage in tests
$journalEntry = JournalEntryBuilder::create()
    ->withId('journal-123')
    ->withDate('2024-01-15')
    ->withDescription('Test journal entry')
    ->withBalancedLines(150.00)
    ->build();
```

### 4. Error Handling Best Practices

#### Domain Exceptions
```php
// ✅ Good: Specific domain exceptions
namespace App\Domain\Accounting\Exceptions;

class UnbalancedJournalException extends DomainException
{
    public function __construct(Money $debitTotal, Money $creditTotal)
    {
        parent::__construct(
            "Journal entry is unbalanced. Debit total: {$debitTotal->getAmount()}, Credit total: {$creditTotal->getAmount()}"
        );
    }
}

class AccountNotFoundException extends DomainException
{
    public function __construct(string $accountCode)
    {
        parent::__construct("Account with code '{$accountCode}' was not found");
    }
}

class InvalidTransactionDateException extends DomainException
{
    public function __construct(string $date, string $reason)
    {
        parent::__construct("Invalid transaction date '{$date}': {$reason}");
    }
}
```

#### Error Response Handling
```php
// ✅ Good: Consistent error response format
class JournalEntryController extends Controller
{
    public function store(CreateJournalEntryRequest $request): JsonResponse
    {
        try {
            $command = CreateJournalEntryCommand::fromRequest($request);
            $response = $this->createUseCase->execute($command);

            return response()->json([
                'data' => JournalEntryResource::make($response->getJournalEntry()),
                'message' => 'Journal entry created successfully'
            ], 201);

        } catch (UnbalancedJournalException $e) {
            return response()->json([
                'error' => 'UNBALANCED_JOURNAL',
                'message' => $e->getMessage(),
                'details' => [
                    'debit_total' => $e->getDebitTotal(),
                    'credit_total' => $e->getCreditTotal()
                ]
            ], 422);

        } catch (AccountNotFoundException $e) {
            return response()->json([
                'error' => 'ACCOUNT_NOT_FOUND',
                'message' => $e->getMessage(),
                'details' => [
                    'account_code' => $e->getAccountCode()
                ]
            ], 404);

        } catch (DomainException $e) {
            return response()->json([
                'error' => 'DOMAIN_ERROR',
                'message' => $e->getMessage()
            ], 422);

        } catch (Exception $e) {
            Log::error('Unexpected error creating journal entry', [
                'exception' => $e,
                'request_data' => $request->all()
            ]);

            return response()->json([
                'error' => 'INTERNAL_ERROR',
                'message' => 'An unexpected error occurred'
            ], 500);
        }
    }
}
```

## Conclusion

Clean Architecture + TDD strategy untuk Smart Accounting DAPEN-KA memberikan foundation yang solid untuk:

1. **Maintainable Code**: Separation of concerns yang jelas
2. **Testable Architecture**: Setiap layer dapat ditest independen
3. **Business Logic Protection**: Core business rules terisolasi dari framework
4. **Quality Assurance**: TDD memastikan code quality tinggi
5. **Scalable Design**: Mudah untuk extend dan modify
6. **Team Collaboration**: Structure yang konsisten untuk semua developer

Dengan mengikuti strategy ini, proyek DAPEN-KA akan memiliki codebase yang robust, maintainable, dan siap untuk pertumbuhan jangka panjang.

## Related Learning Resources

### Practical Application
- **[Experiential Programming Education](EXPERIENTIAL_PROGRAMMING_EDUCATION.md)** - See TDD methodology applied in real-world scenarios
- **[Learning Cases](learning-cases/)** - Detailed examples of Clean Architecture principles in practice:
  - **[Case 1: Session Persistence](learning-cases/case-001-session-persistence-crisis.md)** - Multi-layer debugging following Clean Architecture
  - **[Case 3: Data Structure Alignment](learning-cases/case-003-data-structure-mismatch.md)** - Service-View layer separation
  - **[Case 4: Quality Workflow](learning-cases/case-004-quality-workflow-automation.md)** - TDD automation implementation

### Troubleshooting & Debugging
- **[Session Persistence Troubleshooting](SESSION_PERSISTENCE_TROUBLESHOOTING.md)** - Systematic debugging approach
- **[User Interaction Protocol](USER_INTERACTION_PROTOCOL.md)** - Communication best practices