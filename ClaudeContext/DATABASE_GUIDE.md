# Database Guide - DAPEN Project

🗄️ **Comprehensive database guidelines for Smart Accounting DAPEN-KA**

*Extracted from CLAUDE.md for better organization*

## Query Strategy Guidelines

### Use RAW SQL + Parameter Binding for COMPLEX queries:
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

### Use ELOQUENT ORM for SIMPLE queries:
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

## Security Guidelines

### Parameter Binding (CRITICAL)
- **ALWAYS use parameter binding** for user inputs: `DB::select("WHERE col = ?", [$input])`
- **NEVER use string concatenation**: Avoid `"WHERE col = '" . $input . "'"`
- **Validate all inputs** with Laravel validation rules before queries
- **Use whitelisting** for limited value sets when possible

### Examples
```php
// ❌ DANGEROUS: SQL Injection vulnerable
$query = "SELECT * FROM users WHERE name = '" . $userName . "'";

// ✅ SAFE: Parameter binding
$users = DB::select("SELECT * FROM users WHERE name = ?", [$userName]);

// ✅ SAFE: Eloquent ORM
$users = User::where('name', $userName)->get();
```

## Performance Optimization

### Caching Strategy
- Use **caching** for frequently accessed menu data (5-10 minutes TTL)
- **Raw SQL** for complex joins (2-3x faster than Eloquent)
- **Eloquent** acceptable for simple queries with good maintainability
- Combine both approaches in Service classes for optimal balance

### Query Performance
```php
// ❌ Poor Performance: N+1 queries
$customers = Customer::all();
foreach ($customers as $customer) {
    echo $customer->orders->count(); // N+1 problem
}

// ✅ Optimized: Eager loading
$customers = Customer::withCount('orders')->get();
foreach ($customers as $customer) {
    echo $customer->orders_count; // Single query
}
```

## Database Operations Policy

### CRITICAL: User Approval Required

**ALL database modifications require explicit user approval before execution:**

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

## Menu System Implementation

### Database Structure
- **DBMENU**: Master menu table (KODEMENU, Keterangan, L0, ACCESS)
- **DBFLMENU**: User menu permissions (USERID, L1, HASACCESS, ISTAMBAH, ISKOREKSI, ISHAPUS, ISCETAK, ISEXPORT)

### Hybrid Database Approach
The application uses a **hybrid database approach** for the menu system:

```php
// Complex menu permissions query - Use RAW SQL
$menuPermissions = DB::select("
    SELECT m.KODEMENU, m.Keterangan,
           f.HASACCESS, f.ISTAMBAH, f.ISKOREKSI, f.ISHAPUS
    FROM DBMENU m
    LEFT JOIN DBFLMENU f ON m.KODEMENU = f.L1 AND f.USERID = ?
    WHERE m.ACCESS = 1
    ORDER BY m.L0
", [$userId]);

// Simple permission check - Use Eloquent
$hasAccess = DbFLMENU::where('USERID', $userId)
                    ->where('L1', $menuCode)
                    ->where('HASACCESS', 1)
                    ->exists();
```

## Database Schema Guidelines

### Legacy Compatibility
- **Database schema preservation** - Never alter existing table structures without approval
- **Preserve field naming**: Maintain uppercase legacy field names (USERID, KODEMENU, etc.)
- **Maintain relationships**: Preserve existing foreign key relationships
- **Data integrity**: Ensure data consistency during migration

### Model Configuration
```php
// Proper legacy table configuration
class DbMenu extends Model {
    protected $table = 'DBMENU';
    protected $primaryKey = 'KODEMENU';
    public $incrementing = false;
    protected $keyType = 'string';

    // Preserve legacy field names
    protected $fillable = [
        'KODEMENU', 'Keterangan', 'L0', 'ACCESS'
    ];

    // Add modern accessors if needed
    public function getMenuCodeAttribute(): string {
        return $this->KODEMENU;
    }
}
```

## Testing Database Operations

### Database Testing Strategy
```php
class DatabaseOperationTest extends TestCase {
    use RefreshDatabase;

    public function test_menu_permission_query(): void {
        // Arrange
        $user = User::factory()->create();
        $menu = DbMenu::factory()->create([
            'KODEMENU' => 'TEST001',
            'ACCESS' => 1
        ]);

        // Act
        $hasAccess = DbFLMENU::where('USERID', $user->id)
                            ->where('L1', 'TEST001')
                            ->where('HASACCESS', 1)
                            ->exists();

        // Assert
        $this->assertFalse($hasAccess); // No permission granted yet
    }
}
```

### Migration Testing
```php
public function test_migration_preserves_data_integrity(): void {
    // Test that migrations don't break existing data
    $originalCount = DB::table('DBMENU')->count();

    Artisan::call('migrate');

    $newCount = DB::table('DBMENU')->count();
    $this->assertEquals($originalCount, $newCount);
}
```

---

This database guide ensures secure, performant, and maintainable database operations throughout the DAPEN project.