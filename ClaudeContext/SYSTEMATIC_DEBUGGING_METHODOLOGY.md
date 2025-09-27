# SYSTEMATIC DEBUGGING METHODOLOGY

🚨 **MANDATORY**: Follow this systematic approach for ALL debugging tasks. No trial-error allowed.

## 🎯 DEBUGGING PHILOSOPHY

### **Core Principles**
1. **Systematic over Random** - Test layers in logical order
2. **Evidence-Based** - Every hypothesis must be tested and verified
3. **Documentation-Driven** - Document findings immediately
4. **One-Change Rule** - Test each change individually
5. **Layer Isolation** - Verify each layer before moving to next

### **Anti-Patterns to AVOID**
❌ **Trial-Error Approach** - Random changes hoping something works
❌ **Multi-Change Testing** - Making multiple changes then testing
❌ **Assumption-Based** - Acting on assumptions without verification
❌ **Skip-Layer Testing** - Jumping between layers without systematic approach
❌ **Batch Documentation** - Documenting after multiple fixes

## 🔍 SYSTEMATIC DEBUGGING PROCESS

### **Phase 1: Problem Analysis (MANDATORY)**

#### **1.1 Problem Definition**
```markdown
- [ ] **Exact symptoms** documented
- [ ] **Expected behavior** clearly defined
- [ ] **Actual behavior** precisely described
- [ ] **Reproduction steps** identified
- [ ] **Environment details** noted
- [ ] **Recent changes** reviewed
```

#### **1.2 Initial Investigation Strategy**
```markdown
- [ ] **Layer sequence** planned (Database → Service → Controller → Composer → View → Frontend)
- [ ] **Testing approach** defined for each layer
- [ ] **Hypothesis formation** documented
- [ ] **Success criteria** established
- [ ] **TodoWrite tasks** created
```

### **Phase 2: Layer-by-Layer Investigation**

#### **Layer 1: Database Layer**
```markdown
**Verification Checklist**:
- [ ] **Connection working** - Database accessible
- [ ] **Query correctness** - SQL returns expected data
- [ ] **Data integrity** - Data structure matches expectations
- [ ] **Permissions** - User has required access
- [ ] **Performance** - Queries execute in reasonable time

**Testing Commands**:
- Test connection: `DB::connection()->getPdo()`
- Run raw queries: `DB::select("SELECT ...", [params])`
- Check data: `Model::where(...)->get()`
- Verify permissions: Check user access in database

**Documentation Template**:
Database Layer - [TIMESTAMP]
✅/❌ Connection: [RESULT]
✅/❌ Query correctness: [RESULT]
✅/❌ Data integrity: [RESULT]
Notes: [FINDINGS]
```

#### **Layer 2: Service Layer**
```markdown
**Verification Checklist**:
- [ ] **Service instantiation** - Service can be created
- [ ] **Method existence** - Required methods available
- [ ] **Input validation** - Parameters handled correctly
- [ ] **Business logic** - Logic produces expected results
- [ ] **Error handling** - Errors managed appropriately

**Testing Commands**:
- Test service: `$service = app(ServiceClass::class)`
- Test methods: `$result = $service->methodName($params)`
- Check output: `dd($result)` or `\Log::info()`
- Verify logic: Step through business rules

**Documentation Template**:
Service Layer - [TIMESTAMP]
✅/❌ Service instantiation: [RESULT]
✅/❌ Method calls: [RESULT]
✅/❌ Business logic: [RESULT]
Notes: [FINDINGS]
```

#### **Layer 3: Controller Layer**
```markdown
**Verification Checklist**:
- [ ] **Route binding** - Controller methods properly bound
- [ ] **Request handling** - Input processed correctly
- [ ] **Service integration** - Service calls working
- [ ] **Response formatting** - Output formatted correctly
- [ ] **Error responses** - Errors handled gracefully

**Testing Commands**:
- Test routes: `php artisan route:list`
- API testing: `curl` or Postman requests
- Check logs: Review Laravel logs for errors
- Debug requests: Add `dd()` in controller methods

**Documentation Template**:
Controller Layer - [TIMESTAMP]
✅/❌ Route binding: [RESULT]
✅/❌ Request handling: [RESULT]
✅/❌ Service integration: [RESULT]
Notes: [FINDINGS]
```

#### **Layer 4: View Composer Layer**
```markdown
**Verification Checklist**:
- [ ] **Composer registration** - View composer properly registered
- [ ] **Data binding** - Data passed to views correctly
- [ ] **Service calls** - Composer calls correct service methods
- [ ] **Variable availability** - Variables available in views
- [ ] **Performance** - Composer executes efficiently

**Testing Commands**:
- Check registration: Review `AppServiceProvider.php`
- Test data: Add `\Log::info()` in composer
- Debug variables: `@dump($variable)` in Blade templates
- Test binding: Check view with/without composer

**Documentation Template**:
View Composer Layer - [TIMESTAMP]
✅/❌ Composer registration: [RESULT]
✅/❌ Data binding: [RESULT]
✅/❌ Service integration: [RESULT]
Notes: [FINDINGS]
```

#### **Layer 5: View/Template Layer**
```markdown
**Verification Checklist**:
- [ ] **Template compilation** - Blade templates compile correctly
- [ ] **Variable access** - Variables accessible in templates
- [ ] **Logic execution** - Template logic executes properly
- [ ] **Component integration** - Components work correctly
- [ ] **Output rendering** - Final HTML renders as expected

**Testing Commands**:
- Check compilation: Review `storage/framework/views/`
- Debug variables: `@dump()`, `@dd()` in templates
- Test components: Isolate component testing
- View source: Check rendered HTML output

**Documentation Template**:
View Layer - [TIMESTAMP]
✅/❌ Template compilation: [RESULT]
✅/❌ Variable access: [RESULT]
✅/❌ Output rendering: [RESULT]
Notes: [FINDINGS]
```

#### **Layer 6: Frontend Layer**
```markdown
**Verification Checklist**:
- [ ] **API communication** - Frontend calls backend correctly
- [ ] **Data processing** - Response data handled properly
- [ ] **State management** - Component state updates correctly
- [ ] **UI rendering** - Interface displays as expected
- [ ] **User interaction** - User actions work properly

**Testing Commands**:
- Check API calls: Browser DevTools Network tab
- Debug state: React DevTools
- Console logs: `console.log()` for debugging
- Component testing: Isolate component behavior

**Documentation Template**:
Frontend Layer - [TIMESTAMP]
✅/❌ API communication: [RESULT]
✅/❌ Data processing: [RESULT]
✅/❌ UI rendering: [RESULT]
Notes: [FINDINGS]
```

### **Phase 3: Fix Implementation**

#### **3.1 Single-Change Protocol**
```markdown
For EACH fix:
1. **Identify exact issue** from layer investigation
2. **Formulate specific fix** hypothesis
3. **Make ONE change only**
4. **Test change immediately**
5. **Document result** using real-time template
6. **Verify no side effects**
7. **Update TodoWrite** progress
8. **Move to next issue** (if any)
```

#### **3.2 Fix Verification Protocol**
```markdown
- [ ] **Primary functionality** - Main issue resolved
- [ ] **Secondary effects** - No new issues introduced
- [ ] **Performance impact** - No degradation observed
- [ ] **User experience** - Meets user expectations
- [ ] **Documentation** - Fix properly documented
```

## 🧪 SYSTEMATIC TESTING METHODOLOGY

### **Testing Hierarchy**
```
1. **Unit Level** - Individual methods/functions
2. **Integration Level** - Layer interactions
3. **System Level** - End-to-end functionality
4. **User Level** - Real user scenarios
```

### **Testing Commands by Technology**

#### **Laravel/PHP Testing**
```bash
# Service testing
php artisan tinker
$service = app(ServiceClass::class);
$result = $service->method($params);
dd($result);

# Database testing
DB::enableQueryLog();
$data = Model::where(...)->get();
dd(DB::getQueryLog());

# Route testing
curl -X GET http://localhost:8000/api/endpoint
curl -X POST -H "Content-Type: application/json" -d '{"key":"value"}' http://localhost:8000/api/endpoint
```

#### **React/Frontend Testing**
```javascript
// Console debugging
console.log('State:', state);
console.log('Props:', props);
console.log('API Response:', response);

// Component testing
// Use React DevTools for state inspection
// Use Browser DevTools for network monitoring
```

### **Verification Standards**

#### **Evidence Requirements**
```markdown
Every assertion must have:
- [ ] **Concrete evidence** (logs, screenshots, test results)
- [ ] **Reproducible test** (can be repeated by others)
- [ ] **Clear success criteria** (what indicates success)
- [ ] **Failure conditions** (what indicates failure)
```

## 📊 DEBUGGING SESSION TEMPLATE

### **Session Structure**
```markdown
# Debugging Session - [DATE] - [ISSUE]

## Problem Definition
**Symptoms**: [Exact behavior observed]
**Expected**: [What should happen]
**Environment**: [System details]
**Recent Changes**: [What changed recently]

## Investigation Strategy
**Layer Sequence**: Database → Service → Controller → Composer → View → Frontend
**Hypothesis**: [Initial theory about problem]
**Testing Plan**: [How to verify each layer]

## Layer Investigation Results

### Database Layer
[Use template above]

### Service Layer
[Use template above]

### Controller Layer
[Use template above]

### View Composer Layer
[Use template above]

### View Layer
[Use template above]

### Frontend Layer
[Use template above]

## Fix Implementation

### Fix #1
[Use real-time documentation template]

### Fix #2
[Use real-time documentation template]

## Session Summary
**Total Issues Found**: [NUMBER]
**Total Fixes Applied**: [NUMBER]
**Protocol Compliance**: [RATING/10]
**User Verification**: [CONFIRMED/PENDING]
```

## 🚨 QUALITY GATES

### **Before Moving to Next Layer**
- [ ] Current layer fully investigated
- [ ] All findings documented
- [ ] Issues clearly identified or layer cleared
- [ ] Evidence collected and recorded

### **Before Applying Any Fix**
- [ ] Root cause identified with evidence
- [ ] Fix strategy formulated and documented
- [ ] Expected outcome clearly defined
- [ ] Rollback plan established

### **Before Marking Task Complete**
- [ ] All issues resolved with evidence
- [ ] User verification obtained
- [ ] Documentation complete and accurate
- [ ] No side effects observed

---

**🎯 GOAL**: Every debugging session should be so systematic and well-documented that any other developer can understand exactly what was investigated, what was found, what was fixed, and why it works.