# Pattern Library - Quick Reference

🚀 **Quick access untuk semua established patterns dalam DAPEN project**

## 🎯 Architecture Patterns

### Clean Architecture Layers
```
Domain → Application → Interface → Infrastructure
```

### Service Layer Pattern
```php
class UserPermissionService {
    public function getUserMenus(string $userId): array {
        // Business logic - unit testable
    }
}
```

### Repository Pattern
```php
// Complex queries = Raw SQL, Simple = Eloquent
$data = DB::select("SELECT * FROM table WHERE id = ?", [$id]);
```

## 🧪 TDD Patterns

### Red-Green-Refactor
```bash
1. Write failing test (RED)
2. Make it pass (GREEN)
3. Refactor code (REFACTOR)
```

### Unit Test Pattern
```php
public function test_service_returns_user_menus()
{
    // Mock data, no database dependencies
    $mockData = ['menu1', 'menu2'];
    // Assert business logic
}
```

## 🎨 Template Refactoring Patterns

### Component Extraction Steps
```
1. Extract inline JS → external files
2. Create reusable components
3. Separate concerns
4. Break into partials
```

### Dashboard Component Suite
```blade
<x-dashboard-welcome-info :user="$user" />
<x-dashboard-quick-stats :user="$user" />
<x-dashboard-system-stats />
```

### Flash Messages
```blade
<x-flash-messages />
```

## 📁 File Organization Patterns

### View Structure
```
resources/views/
├── components/          # Reusable components
├── layouts/partials/    # CSS/JS partials
└── module/partials/     # Module-specific partials
```

### CSS Management
```blade
@push('styles')
<link href="{{ asset('css/module.css') }}" rel="stylesheet">
@endpush
```

## 🔐 Authentication Patterns

### Controller Pattern
```php
public function login(Request $request): RedirectResponse|JsonResponse
{
    return $this->authService->authenticate($request->validated());
}
```

### Middleware Pattern
```php
// Use existing Laravel middleware
Route::middleware(['auth'])->group(function () {
    // Protected routes
});
```

## 🗄️ Database Patterns

### Query Strategy
- **Complex** (JOINs) = Raw SQL + parameter binding
- **Simple** CRUD = Eloquent ORM

### Parameter Binding
```php
DB::select("WHERE id = ?", [$id])  // Always use parameter binding
```

## 🔗 Menu & Navigation Patterns

### Menu Route Resolution Pattern
**Problem**: Route names in database need to be converted to proper URLs
**Solution**: Template logic with fallback handling
```php
@php
    $routeUrl = '#';
    if (!empty($item['route'])) {
        try {
            if (\Route::has($item['route'])) {
                $routeUrl = route($item['route']);
            } elseif (str_starts_with($item['route'], '/')) {
                $routeUrl = $item['route'];
            } else {
                $routeUrl = '/' . ltrim($item['route'], '/');
            }
        } catch (\Exception $e) {
            $routeUrl = str_starts_with($item['route'], '/') ? $item['route'] : '/' . $item['route'];
        }
    }
@endphp
<a href="{{ $routeUrl }}" class="nav-link">{{ $item['title'] }}</a>
```
**Supports**: Route names, direct URLs, relative paths, error handling
**Documentation**: [MENU_ROUTE_RESOLUTION_PATTERN.md](./MENU_ROUTE_RESOLUTION_PATTERN.md)

## 🚦 Safety Protocols

### Mandatory Before Work
```bash
./safety/backup-before-work.sh
```

### Working State Checkpoints
```bash
./safety/checkpoint-working-state.sh "feature completed"
```

### Git Tree Visualization
```bash
git tree -15    # Enhanced tree view
git treebr -10  # Branch relationships
```

## 📊 Quality Metrics

### Template Quality Score
- **Line reduction**: Target 60-70%
- **Components created**: 2-3+ per template
- **Concerns separated**: Clean layer boundaries

### Clean Code Indicators
- ✅ Main template under 30 lines
- ✅ No inline JavaScript over 5 lines
- ✅ Reusable components created
- ✅ All functionality preserved

## 🛠️ Development Tools

### MCP Servers
- **context7**: Library documentation
- **playwright**: Browser automation
- **simple**: Project context helpers

### Laravel Commands
```bash
php artisan serve          # Start server
php artisan make:model     # Create model
php artisan migrate        # Run migrations
```

### React Commands
```bash
npm run dev               # Start dev server
npm install              # Install dependencies
```

## 🎓 Learning Patterns

### Case Study Structure
```
Problem → Analysis → Solution → Results → Lessons
```

### Documentation Pattern
- **Real-time**: Document fixes immediately
- **Evidence-based**: Include proof of success
- **Reusable**: Create patterns for future use

## 🔄 Workflow Patterns

### TodoWrite Protocol
1. Create task list BEFORE work
2. Mark in_progress when starting
3. Mark completed IMMEDIATELY when done

### Systematic Debugging
```
Database → Service → Controller → Composer → View → Frontend
```

## 📚 Reference Links

### Essential Files
- **[CLAUDE.md](../../CLAUDE.md)** - Main project guidelines
- **[Template Patterns](TEMPLATE_PATTERNS.md)** - Detailed template examples
- **[Component Patterns](COMPONENT_PATTERNS.md)** - Reusable components
- **[Coding Standards](CODING_STANDARDS.md)** - Code quality guidelines

### Learning Cases
- **[Case 001](learning-cases/case-001-session-persistence-crisis.md)** - Session debugging
- **[Case 005](learning-cases/case-005-login-template-clean-code-refactoring.md)** - Template refactoring

---

**🎯 Purpose**: Quick reference untuk established patterns, methodologies, dan best practices dalam DAPEN project development.