# Menu Route Resolution Pattern

## 📋 PATTERN OVERVIEW
**Pattern Type**: Template Logic Pattern
**Use Case**: Resolving Laravel route names to proper URLs in Blade templates
**Complexity**: Intermediate
**Last Updated**: 2025-09-26

## 🎯 PROBLEM SOLVED
Dynamic menu systems often store route information as route names in database, but need to display actual URLs in templates. Direct output of route names causes 404 errors.

## 🏗️ PATTERN IMPLEMENTATION

### Template Logic (Blade)
```php
@php
    $routeUrl = '#';
    if (!empty($item['route'])) {
        try {
            // Check if it's a valid Laravel route name
            if (\Route::has($item['route'])) {
                $routeUrl = route($item['route']);
            } elseif (str_starts_with($item['route'], '/')) {
                // Direct URL starting with /
                $routeUrl = $item['route'];
            } else {
                // Treat as relative URL, add leading slash
                $routeUrl = '/' . ltrim($item['route'], '/');
            }
        } catch (\Exception $e) {
            // If route resolution fails, use direct URL approach
            $routeUrl = str_starts_with($item['route'], '/') ? $item['route'] : '/' . $item['route'];
        }
    }
@endphp
<a href="{{ $routeUrl }}" class="nav-link">
    <!-- Menu content -->
</a>
```

### Service Layer Helper (Optional)
```php
class MenuResolverService
{
    public static function resolveMenuRoute(?string $routename): string
    {
        if (empty($routename)) {
            return '#';
        }

        try {
            // Check if it's a valid Laravel route name
            if (\Route::has($routename)) {
                return route($routename);
            }

            // If it starts with '/', treat as direct URL
            if (str_starts_with($routename, '/')) {
                return $routename;
            }

            // Otherwise, treat as relative URL but add leading slash
            return '/' . ltrim($routename, '/');

        } catch (\Exception $e) {
            // If route resolution fails, return the original value with leading slash
            return str_starts_with($routename, '/') ? $routename : '/' . $routename;
        }
    }
}
```

## 🔧 USAGE PATTERNS

### Pattern 1: Direct Template Usage
```php
{{-- In recursive-menu.blade.php or similar --}}
@php
    $url = MenuResolverService::resolveMenuRoute($item['route']);
@endphp
<a href="{{ $url }}" class="nav-link">{{ $item['title'] }}</a>
```

### Pattern 2: Controller Preprocessing
```php
// In Controller
public function dashboard()
{
    $userMenus = $this->userPermissionService->getUserMenus(auth()->id());

    // Preprocess routes
    foreach ($userMenus as &$group) {
        foreach ($group['items'] as &$item) {
            $item['resolved_route'] = MenuResolverService::resolveMenuRoute($item['route']);
        }
    }

    return view('dashboard', compact('userMenus'));
}
```

### Pattern 3: Collection Mapping
```php
// Using Laravel Collections
$menuItems = collect($menuData)->map(function ($item) {
    $item['url'] = MenuResolverService::resolveMenuRoute($item['route']);
    return $item;
});
```

## 📊 SUPPORTED FORMATS

### Input Format Support
| Input Format | Example | Output |
|-------------|---------|--------|
| Route Name | `users.index` | `/users` |
| Named Route | `laporan-laporan.laporan.erp.dashboard` | `/laporan-laporan/laporan-clean` |
| Direct URL | `/dashboard` | `/dashboard` |
| Relative Path | `admin/users` | `/admin/users` |
| Fragment Only | `#` | `#` |
| Empty/Null | `null` | `#` |

### Error Handling
- **Invalid Route Names**: Falls back to direct URL approach
- **Route Exceptions**: Gracefully handles Laravel route resolution errors
- **Empty Values**: Returns safe default `#`
- **Malformed URLs**: Normalizes with leading slash

## ✅ TESTING STRATEGY

### Unit Testing
```php
class MenuResolverServiceTest extends TestCase
{
    public function test_resolves_valid_route_names()
    {
        Route::get('/test', fn() => 'test')->name('test.route');

        $result = MenuResolverService::resolveMenuRoute('test.route');

        $this->assertEquals('http://localhost/test', $result);
    }

    public function test_handles_direct_urls()
    {
        $result = MenuResolverService::resolveMenuRoute('/direct-path');

        $this->assertEquals('/direct-path', $result);
    }

    public function test_normalizes_relative_paths()
    {
        $result = MenuResolverService::resolveMenuRoute('relative/path');

        $this->assertEquals('/relative/path', $result);
    }
}
```

### Integration Testing (Playwright)
```javascript
test('menu navigation works correctly', async ({ page }) => {
    await page.goto('http://localhost:8000/dashboard');

    // Test route name resolution
    const menuLink = page.locator('a:has-text("Laporan")');
    await expect(menuLink).toHaveAttribute('href', /\/laporan-laporan\/laporan-clean$/);

    // Test actual navigation
    await menuLink.click();
    await expect(page).toHaveURL(/.*laporan-laporan\/laporan-clean$/);
});
```

## 🚀 IMPLEMENTATION CHECKLIST

### Template Implementation
- [ ] Add route resolution logic to menu template
- [ ] Include exception handling for route errors
- [ ] Support multiple URL formats (route names, direct URLs, relative paths)
- [ ] Provide safe fallback for empty/invalid routes

### Service Implementation (Optional)
- [ ] Create MenuResolverService class
- [ ] Implement static resolveMenuRoute method
- [ ] Add comprehensive error handling
- [ ] Write unit tests for all scenarios

### Testing
- [ ] Test with valid route names
- [ ] Test with direct URLs
- [ ] Test with relative paths
- [ ] Test error handling for invalid routes
- [ ] Test browser navigation end-to-end

### Documentation
- [ ] Document supported input formats
- [ ] Provide usage examples
- [ ] Include error handling scenarios
- [ ] Add troubleshooting guide

## 🔍 TROUBLESHOOTING

### Common Issues
1. **Route Not Found**: Check if route name exists in `php artisan route:list`
2. **404 Errors**: Verify route resolution is working correctly
3. **Wrong URLs**: Check URL format in database vs expected format
4. **Exception Errors**: Ensure exception handling is implemented

### Debug Steps
```php
// Debug route resolution
dd([
    'original' => $item['route'],
    'exists' => \Route::has($item['route']),
    'resolved' => route($item['route']) // May throw exception
]);
```

## 📈 PERFORMANCE CONSIDERATIONS

### Caching Strategy
```php
// Cache resolved routes to avoid repeated resolution
$cacheKey = "menu_route_" . md5($routename);
return Cache::remember($cacheKey, 300, function() use ($routename) {
    return $this->resolveMenuRoute($routename);
});
```

### Optimization Tips
- Cache frequently used route resolutions
- Preprocess routes in controller rather than template
- Use service layer for complex menu systems
- Consider lazy loading for large menu structures

## 🔗 RELATED PATTERNS
- [Recursive Menu Component Pattern](./COMPONENT_PATTERNS.md#recursive-menu)
- [User Permission Service Pattern](./PATTERN_LIBRARY.md#user-permissions)
- [Template Logic Patterns](./TEMPLATE_PATTERNS.md#dynamic-urls)

---

**Pattern Status**: ✅ Production Ready
**Last Validated**: 2025-09-26
**Next Review**: 2025-10-26