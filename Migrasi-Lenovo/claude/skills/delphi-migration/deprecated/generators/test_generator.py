#!/usr/bin/env python3
"""
Laravel PHPUnit Test Generator
Version: 1.0

Generates:
- Feature tests for API endpoints
- Unit tests for Service classes
- Unit tests for Request validation
"""

from typing import List, Dict, Any, Optional
from dataclasses import dataclass


@dataclass
class TestField:
    """Represents a field for testing"""
    name: str
    type: str = "string"
    required: bool = False
    max_length: int = 0
    min_value: float = None
    max_value: float = None
    valid_value: str = ""
    invalid_value: str = ""


class LaravelTestGenerator:
    """Generate PHPUnit tests for Laravel"""
    
    def __init__(self, model_name: str):
        self.model_name = model_name
        self.model_lower = model_name.lower()
        self.model_snake = self._to_snake_case(model_name)
        
        self.fields: List[TestField] = []
        self.has_soft_deletes = True
        self.has_audit_log = True
        
    def _to_snake_case(self, name: str) -> str:
        """Convert to snake_case"""
        import re
        result = re.sub(r'([A-Z])', r'_\1', name).lower()
        return result.lstrip('_')
    
    def add_field(self, name: str, **kwargs) -> 'LaravelTestGenerator':
        """Add a field for testing"""
        field = TestField(name=name, **kwargs)
        
        # Generate valid/invalid values if not provided
        if not field.valid_value:
            field.valid_value = self._generate_valid_value(field)
        if not field.invalid_value:
            field.invalid_value = self._generate_invalid_value(field)
        
        self.fields.append(field)
        return self
    
    def _generate_valid_value(self, field: TestField) -> str:
        """Generate a valid test value"""
        if field.type == 'numeric' or field.type == 'integer':
            if field.min_value is not None:
                return str(int(field.min_value) + 1)
            return "100"
        elif field.type == 'date':
            return "'2024-01-15'"
        elif field.type == 'boolean':
            return "true"
        elif field.type == 'email':
            return "'test@example.com'"
        else:
            if field.max_length > 0:
                return f"'Test {field.name[:min(10, field.max_length-5)]}'"
            return f"'Test {field.name}'"
    
    def _generate_invalid_value(self, field: TestField) -> str:
        """Generate an invalid test value"""
        if field.type == 'numeric' or field.type == 'integer':
            return "'not-a-number'"
        elif field.type == 'date':
            return "'invalid-date'"
        elif field.type == 'boolean':
            return "'not-boolean'"
        elif field.type == 'email':
            return "'not-an-email'"
        else:
            if field.max_length > 0:
                return f"str_repeat('x', {field.max_length + 10})"
            return "null"
    
    def generate_feature_test(self) -> str:
        """Generate feature test for API/Web endpoints"""
        valid_data = self._generate_valid_data()
        required_fields = [f for f in self.fields if f.required]
        
        return f'''<?php

namespace Tests\\Feature;

use App\\Models\\{self.model_name};
use App\\Models\\User;
use Illuminate\\Foundation\\Testing\\RefreshDatabase;
use Illuminate\\Foundation\\Testing\\WithFaker;
use Tests\\TestCase;

class {self.model_name}Test extends TestCase
{{
    use RefreshDatabase, WithFaker;

    protected User $user;
    protected User $admin;

    protected function setUp(): void
    {{
        parent::setUp();
        
        $this->user = User::factory()->create();
        $this->admin = User::factory()->create(['is_admin' => true]);
    }}

    /**
     * @test
     * Test: Dapat melihat daftar {self.model_lower}
     */
    public function user_can_view_{self.model_snake}_list(): void
    {{
        {self.model_name}::factory()->count(5)->create();

        $response = $this->actingAs($this->user)
            ->get(route('{self.model_lower}.index'));

        $response->assertStatus(200);
        $response->assertViewIs('{self.model_lower}.index');
    }}

    /**
     * @test
     * Test: Dapat melihat form tambah {self.model_lower}
     */
    public function user_can_view_create_form(): void
    {{
        $response = $this->actingAs($this->user)
            ->get(route('{self.model_lower}.create'));

        $response->assertStatus(200);
        $response->assertViewIs('{self.model_lower}.create');
    }}

    /**
     * @test
     * Test: Dapat menambah {self.model_lower} baru
     */
    public function user_can_create_{self.model_snake}(): void
    {{
        $data = [{valid_data}
        ];

        $response = $this->actingAs($this->user)
            ->post(route('{self.model_lower}.store'), $data);

        $response->assertRedirect(route('{self.model_lower}.index'));
        $this->assertDatabaseHas('{self.model_lower}s', [
            '{self.fields[0].name if self.fields else 'name'}' => $data['{self.fields[0].name if self.fields else 'name'}'],
        ]);
    }}

    /**
     * @test
     * Test: Validasi field required saat tambah
     */
    public function create_validation_requires_mandatory_fields(): void
    {{
        $response = $this->actingAs($this->user)
            ->post(route('{self.model_lower}.store'), []);

        $response->assertSessionHasErrors([{self._generate_required_field_list()}]);
    }}

    /**
     * @test
     * Test: Dapat melihat detail {self.model_lower}
     */
    public function user_can_view_{self.model_snake}_detail(): void
    {{
        ${self.model_lower} = {self.model_name}::factory()->create();

        $response = $this->actingAs($this->user)
            ->get(route('{self.model_lower}.show', ${self.model_lower}));

        $response->assertStatus(200);
        $response->assertViewIs('{self.model_lower}.show');
    }}

    /**
     * @test
     * Test: Dapat melihat form edit {self.model_lower}
     */
    public function user_can_view_edit_form(): void
    {{
        ${self.model_lower} = {self.model_name}::factory()->create();

        $response = $this->actingAs($this->user)
            ->get(route('{self.model_lower}.edit', ${self.model_lower}));

        $response->assertStatus(200);
        $response->assertViewIs('{self.model_lower}.edit');
    }}

    /**
     * @test
     * Test: Dapat mengupdate {self.model_lower}
     */
    public function user_can_update_{self.model_snake}(): void
    {{
        ${self.model_lower} = {self.model_name}::factory()->create();
        
        $data = [{valid_data}
        ];

        $response = $this->actingAs($this->user)
            ->put(route('{self.model_lower}.update', ${self.model_lower}), $data);

        $response->assertRedirect(route('{self.model_lower}.index'));
        $this->assertDatabaseHas('{self.model_lower}s', [
            'id' => ${self.model_lower}->id,
            '{self.fields[0].name if self.fields else 'name'}' => $data['{self.fields[0].name if self.fields else 'name'}'],
        ]);
    }}

    /**
     * @test
     * Test: Dapat menghapus {self.model_lower}
     */
    public function user_can_delete_{self.model_snake}(): void
    {{
        ${self.model_lower} = {self.model_name}::factory()->create();

        $response = $this->actingAs($this->user)
            ->delete(route('{self.model_lower}.destroy', ${self.model_lower}));

        $response->assertRedirect(route('{self.model_lower}.index'));
        {self._generate_soft_delete_assertion()}
    }}

    /**
     * @test
     * Test: Guest tidak dapat mengakses
     */
    public function guest_cannot_access_{self.model_snake}(): void
    {{
        $response = $this->get(route('{self.model_lower}.index'));
        $response->assertRedirect(route('login'));
    }}

    /**
     * @test
     * Test: Dapat melakukan pencarian
     */
    public function user_can_search_{self.model_snake}(): void
    {{
        {self.model_name}::factory()->create(['{self.fields[0].name if self.fields else 'name'}' => 'Test Pencarian']);
        {self.model_name}::factory()->create(['{self.fields[0].name if self.fields else 'name'}' => 'Data Lain']);

        $response = $this->actingAs($this->user)
            ->get(route('{self.model_lower}.index', ['search' => 'Pencarian']));

        $response->assertStatus(200);
        $response->assertSee('Test Pencarian');
        $response->assertDontSee('Data Lain');
    }}

    /**
     * @test
     * Test: Pagination bekerja dengan benar
     */
    public function pagination_works_correctly(): void
    {{
        {self.model_name}::factory()->count(25)->create();

        $response = $this->actingAs($this->user)
            ->get(route('{self.model_lower}.index'));

        $response->assertStatus(200);
        // Default pagination 15 items
        $response->assertViewHas('data', function ($data) {{
            return $data->count() <= 15;
        }});
    }}
{self._generate_export_test()}
{self._generate_restore_test()}
}}
'''
    
    def generate_service_test(self) -> str:
        """Generate unit test for Service class"""
        return f'''<?php

namespace Tests\\Unit\\Services;

use App\\Models\\{self.model_name};
use App\\Models\\User;
use App\\Services\\{self.model_name}Service;
use Illuminate\\Foundation\\Testing\\RefreshDatabase;
use Illuminate\\Validation\\ValidationException;
use Tests\\TestCase;

class {self.model_name}ServiceTest extends TestCase
{{
    use RefreshDatabase;

    protected {self.model_name}Service $service;
    protected User $user;

    protected function setUp(): void
    {{
        parent::setUp();
        
        $this->service = app({self.model_name}Service::class);
        $this->user = User::factory()->create();
        $this->actingAs($this->user);
    }}

    /**
     * @test
     * Test: Service dapat mendaftarkan data baru
     */
    public function service_can_register_new_data(): void
    {{
        $data = [{self._generate_valid_data()}
        ];

        $result = $this->service->register($data);

        $this->assertInstanceOf({self.model_name}::class, $result);
        $this->assertDatabaseHas('{self.model_lower}s', [
            '{self.fields[0].name if self.fields else 'name'}' => $data['{self.fields[0].name if self.fields else 'name'}'],
        ]);
    }}

    /**
     * @test
     * Test: Service dapat mengupdate data
     */
    public function service_can_update_data(): void
    {{
        ${self.model_lower} = {self.model_name}::factory()->create();
        
        $data = [{self._generate_valid_data()}
        ];

        $result = $this->service->update(${self.model_lower}, $data);

        $this->assertInstanceOf({self.model_name}::class, $result);
        $this->assertEquals($data['{self.fields[0].name if self.fields else 'name'}'], $result->{self.fields[0].name if self.fields else 'name'});
    }}

    /**
     * @test
     * Test: Service dapat menghapus data
     */
    public function service_can_delete_data(): void
    {{
        ${self.model_lower} = {self.model_name}::factory()->create();

        $result = $this->service->delete(${self.model_lower});

        $this->assertTrue($result);
        {self._generate_soft_delete_assertion()}
    }}

    /**
     * @test
     * Test: Service mencatat audit log saat register
     */
    public function service_logs_audit_on_register(): void
    {{
        $data = [{self._generate_valid_data()}
        ];

        $this->service->register($data);

        $this->assertDatabaseHas('log_activity', [
            'activity' => 'I',
            'table_name' => '{self.model_lower}s',
            'user_id' => $this->user->id,
        ]);
    }}

    /**
     * @test
     * Test: Service mencatat audit log saat update
     */
    public function service_logs_audit_on_update(): void
    {{
        ${self.model_lower} = {self.model_name}::factory()->create();
        
        $data = [{self._generate_valid_data()}
        ];

        $this->service->update(${self.model_lower}, $data);

        $this->assertDatabaseHas('log_activity', [
            'activity' => 'U',
            'table_name' => '{self.model_lower}s',
            'record_id' => ${self.model_lower}->id,
        ]);
    }}

    /**
     * @test
     * Test: Service mencatat audit log saat delete
     */
    public function service_logs_audit_on_delete(): void
    {{
        ${self.model_lower} = {self.model_name}::factory()->create();

        $this->service->delete(${self.model_lower});

        $this->assertDatabaseHas('log_activity', [
            'activity' => 'D',
            'table_name' => '{self.model_lower}s',
            'record_id' => ${self.model_lower}->id,
        ]);
    }}

    /**
     * @test
     * Test: Service menggunakan database transaction
     */
    public function service_uses_database_transaction(): void
    {{
        // Simulate failure after insert
        $this->expectException(\\Exception::class);
        
        // This test verifies transaction rollback behavior
        // Implementation depends on how you want to trigger the failure
    }}
}}
'''
    
    def generate_request_test(self) -> str:
        """Generate unit test for Request validation"""
        return f'''<?php

namespace Tests\\Unit\\Requests;

use App\\Http\\Requests\\{self.model_name}\\Store{self.model_name}Request;
use App\\Http\\Requests\\{self.model_name}\\Update{self.model_name}Request;
use App\\Models\\{self.model_name};
use App\\Models\\User;
use Illuminate\\Foundation\\Testing\\RefreshDatabase;
use Illuminate\\Support\\Facades\\Validator;
use Tests\\TestCase;

class {self.model_name}RequestTest extends TestCase
{{
    use RefreshDatabase;

    protected User $user;

    protected function setUp(): void
    {{
        parent::setUp();
        $this->user = User::factory()->create();
    }}

    // =========================================================================
    // Store Request Tests
    // =========================================================================

    /**
     * @test
     * Test: Store request menerima data valid
     */
    public function store_request_accepts_valid_data(): void
    {{
        $data = [{self._generate_valid_data()}
        ];

        $request = new Store{self.model_name}Request();
        $validator = Validator::make($data, $request->rules());

        $this->assertFalse($validator->fails());
    }}

    /**
     * @test
     * Test: Store request menolak data tanpa field required
     */
    public function store_request_rejects_missing_required_fields(): void
    {{
        $data = [];

        $request = new Store{self.model_name}Request();
        $validator = Validator::make($data, $request->rules());

        $this->assertTrue($validator->fails());
        {self._generate_required_field_assertions()}
    }}
{self._generate_field_validation_tests('Store')}

    // =========================================================================
    // Update Request Tests
    // =========================================================================

    /**
     * @test
     * Test: Update request menerima data valid
     */
    public function update_request_accepts_valid_data(): void
    {{
        $data = [{self._generate_valid_data()}
        ];

        $request = new Update{self.model_name}Request();
        $validator = Validator::make($data, $request->rules());

        $this->assertFalse($validator->fails());
    }}
{self._generate_field_validation_tests('Update')}
}}
'''
    
    def generate_factory(self) -> str:
        """Generate model factory"""
        return f'''<?php

namespace Database\\Factories;

use App\\Models\\{self.model_name};
use Illuminate\\Database\\Eloquent\\Factories\\Factory;

/**
 * @extends Factory<{self.model_name}>
 */
class {self.model_name}Factory extends Factory
{{
    protected $model = {self.model_name}::class;

    /**
     * Define the model's default state.
     */
    public function definition(): array
    {{
        return [
{self._generate_factory_fields()}
            'is_aktif' => true,
            'created_by' => 1,
        ];
    }}

    /**
     * Indicate that the model is inactive.
     */
    public function inactive(): static
    {{
        return $this->state(fn (array $attributes) => [
            'is_aktif' => false,
        ]);
    }}
}}
'''
    
    def _generate_valid_data(self) -> str:
        """Generate valid data array for tests"""
        lines = []
        for field in self.fields:
            lines.append(f"            '{field.name}' => {field.valid_value},")
        return '\n'.join(lines) if lines else "            'name' => 'Test Name',"
    
    def _generate_required_field_list(self) -> str:
        """Generate list of required fields for assertion"""
        required = [f"'{f.name}'" for f in self.fields if f.required]
        return ', '.join(required) if required else "'name'"
    
    def _generate_required_field_assertions(self) -> str:
        """Generate assertions for required fields"""
        lines = []
        for field in self.fields:
            if field.required:
                lines.append(f"        $this->assertTrue($validator->errors()->has('{field.name}'));")
        return '\n'.join(lines) if lines else "        $this->assertTrue($validator->errors()->has('name'));"
    
    def _generate_field_validation_tests(self, request_type: str) -> str:
        """Generate validation tests for each field"""
        tests = []
        
        for field in self.fields:
            # Max length test
            if field.max_length > 0:
                tests.append(f'''
    /**
     * @test
     * Test: {request_type} request menolak {field.name} yang terlalu panjang
     */
    public function {request_type.lower()}_request_rejects_{field.name}_exceeding_max_length(): void
    {{
        $data = [
            '{field.name}' => str_repeat('x', {field.max_length + 1}),
        ];

        $request = new {request_type}{self.model_name}Request();
        $validator = Validator::make($data, $request->rules());

        $this->assertTrue($validator->fails());
        $this->assertTrue($validator->errors()->has('{field.name}'));
    }}''')
            
            # Numeric validation test
            if field.type in ['numeric', 'integer']:
                tests.append(f'''
    /**
     * @test
     * Test: {request_type} request menolak {field.name} non-numeric
     */
    public function {request_type.lower()}_request_rejects_non_numeric_{field.name}(): void
    {{
        $data = [
            '{field.name}' => 'not-a-number',
        ];

        $request = new {request_type}{self.model_name}Request();
        $validator = Validator::make($data, $request->rules());

        $this->assertTrue($validator->fails());
        $this->assertTrue($validator->errors()->has('{field.name}'));
    }}''')
        
        return '\n'.join(tests)
    
    def _generate_soft_delete_assertion(self) -> str:
        """Generate soft delete assertion"""
        if self.has_soft_deletes:
            return f"$this->assertSoftDeleted('{self.model_lower}s', ['id' => ${self.model_lower}->id]);"
        return f"$this->assertDatabaseMissing('{self.model_lower}s', ['id' => ${self.model_lower}->id]);"
    
    def _generate_export_test(self) -> str:
        """Generate export test"""
        return f'''
    /**
     * @test
     * Test: Dapat export data ke Excel
     */
    public function user_can_export_to_excel(): void
    {{
        {self.model_name}::factory()->count(5)->create();

        $response = $this->actingAs($this->user)
            ->get(route('{self.model_lower}.export'));

        $response->assertStatus(200);
        $response->assertHeader('content-type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    }}'''
    
    def _generate_restore_test(self) -> str:
        """Generate restore test for soft deletes"""
        if not self.has_soft_deletes:
            return ""
        
        return f'''
    /**
     * @test
     * Test: Admin dapat restore data yang dihapus
     */
    public function admin_can_restore_deleted_{self.model_snake}(): void
    {{
        ${self.model_lower} = {self.model_name}::factory()->create();
        ${self.model_lower}->delete();

        $response = $this->actingAs($this->admin)
            ->post(route('{self.model_lower}.restore', ${self.model_lower}->id));

        $response->assertRedirect();
        $this->assertDatabaseHas('{self.model_lower}s', [
            'id' => ${self.model_lower}->id,
            'deleted_at' => null,
        ]);
    }}'''
    
    def _generate_factory_fields(self) -> str:
        """Generate factory field definitions"""
        lines = []
        for field in self.fields:
            if field.type == 'numeric' or field.type == 'integer':
                if field.min_value is not None and field.max_value is not None:
                    lines.append(f"            '{field.name}' => fake()->numberBetween({int(field.min_value)}, {int(field.max_value)}),")
                else:
                    lines.append(f"            '{field.name}' => fake()->randomNumber(5),")
            elif field.type == 'date':
                lines.append(f"            '{field.name}' => fake()->date(),")
            elif field.type == 'boolean':
                lines.append(f"            '{field.name}' => fake()->boolean(),")
            elif field.type == 'email':
                lines.append(f"            '{field.name}' => fake()->unique()->safeEmail(),")
            else:
                if field.max_length > 0:
                    lines.append(f"            '{field.name}' => fake()->text({min(field.max_length, 50)}),")
                else:
                    lines.append(f"            '{field.name}' => fake()->sentence(3),")
        
        return '\n'.join(lines) if lines else "            'name' => fake()->sentence(3),"
    
    def generate_all(self) -> Dict[str, str]:
        """Generate all test files"""
        return {
            f'{self.model_name}Test.php': self.generate_feature_test(),
            f'{self.model_name}ServiceTest.php': self.generate_service_test(),
            f'{self.model_name}RequestTest.php': self.generate_request_test(),
            f'{self.model_name}Factory.php': self.generate_factory(),
        }


def create_from_parser_result(result: dict, model_name: str) -> LaravelTestGenerator:
    """Create TestGenerator from parser result"""
    generator = LaravelTestGenerator(model_name)
    
    # Add fields from validation rules
    for rule in result.get('validation_rules', []):
        if hasattr(rule, 'field_name') and rule.field_name:
            field_type = 'string'
            if hasattr(rule, 'rule_type'):
                if rule.rule_type == 'range':
                    field_type = 'numeric'
                elif rule.rule_type == 'format' and 'date' in str(rule.details).lower():
                    field_type = 'date'
            
            generator.add_field(
                name=rule.field_name,
                type=field_type,
                required=(rule.rule_type == 'required' if hasattr(rule, 'rule_type') else False)
            )
    
    return generator


if __name__ == "__main__":
    # Test
    generator = LaravelTestGenerator('Aktiva')
    
    generator.add_field('kode', type='string', required=True, max_length=25)
    generator.add_field('nama', type='string', required=True, max_length=100)
    generator.add_field('nilai', type='numeric', required=True, min_value=0)
    generator.add_field('tanggal_perolehan', type='date', required=True)
    
    tests = generator.generate_all()
    
    for name, content in tests.items():
        print(f"\n{'='*70}")
        print(f" {name}")
        print('='*70)
        print(content[:2000] + "...")
