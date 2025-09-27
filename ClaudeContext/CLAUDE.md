# CLAUDE.md

🚨 **MANDATORY SESSION START**: Claude MUST read this file AND `dokumentasi/claude/README.md` at the start of EVERY session!

## 📋 ESSENTIAL READING CHECKLIST
- [ ] ✅ Read CLAUDE.md (this file) - Project context and guidelines
- [ ] 📚 Read dokumentasi/claude/README.md - Documentation index
- [ ] 🔄 Check .claude/session_state.json - Current project progress
- [ ] ⚡ Run ./quick_context.sh - Enhanced status overview
- [ ] 📝 Read dokumentasi/claude/REAL_TIME_DOCUMENTATION_PROTOCOL.md - Fix tracking
- [ ] 🧪 Read dokumentasi/claude/REAL_USER_TESTING_PROTOCOL.md - Comprehensive testing approach
- [ ] 🎓 Read dokumentasi/claude/EXPERIENTIAL_PROGRAMMING_EDUCATION.md - Learning methodology
- [ ] 🏗️ Read dokumentasi/claude/CLEAN_ARCHITECTURE_TDD_STRATEGY.md - Development strategy
- [ ] 🗄️ Read dokumentasi/claude/DATABASE_GUIDE.md - Database practices
- [ ] 📋 Read dokumentasi/claude/CODING_STANDARDS.md - Code standards

## 🔒 MANDATORY PROTOCOL DOCUMENTS (NEW)
- [ ] ✅ Read dokumentasi/claude/MANDATORY_PROTOCOL_CHECKLIST.md - Session compliance checklist
- [ ] 📝 Read dokumentasi/claude/REAL_TIME_DOCUMENTATION_TEMPLATE.md - Documentation templates
- [ ] 🔍 Read dokumentasi/claude/SYSTEMATIC_DEBUGGING_METHODOLOGY.md - Debugging approach
- [ ] 📊 Read dokumentasi/claude/PROTOCOL_VIOLATION_TRACKING.md - Violation tracking system

## 🎯 Project Overview

**Smart Accounting DAPEN-KA** - Delphi desktop to Laravel 9.0 + React 18 web migration.

### 🔧 Development Methodology (CRITICAL!)
- **Architecture**: Clean Code Architecture (Domain → Application → Interface → Infrastructure)
- **Development Approach**: **Test-Driven Development (TDD) - Red, Green, Refactor**
- **Code Quality**: SOLID principles, dependency inversion, single responsibility

### 📊 Migration Context
- **Source**: Delphi desktop (320+ forms, SQL Server)
- **Target**: Laravel 9.0 API + React 18 SPA
- **Database**: Preserved existing schema (100+ tables)
- **Procedures**: 418 stored procedures maintained

## ⚡ Quick Commands

### Backend (Laravel)
```bash
cd backend && php artisan serve                    # Start server (:8000)
cd backend && php artisan make:controller Name     # Create controller
cd backend && php artisan migrate                  # Run migrations
```

### Frontend (React)
```bash
cd frontend && npm run dev                         # Start dev server (:5173)
cd frontend && npm install                        # Install dependencies
```

## 🏗️ Architecture

### Directory Structure
```
backend/     # Laravel 9.0 API (MAIN)
frontend/    # React 18 SPA (MAIN)
Delphi/      # Reference: Original desktop app
Boba/        # Reference: Alternative implementation
dokumentasi/ # Project documentation
```

### Key Technologies
- **Backend**: Laravel 9.0, PHP 8.0+, SQL Server, Laravel Sanctum
- **Frontend**: React 18, Vite, Ant Design, Tailwind CSS
- **Database**: SQL Server (legacy schema preserved)

## 🗄️ Database Policy

### Query Strategy
- **Complex queries** (JOINs, aggregations): Use RAW SQL + parameter binding
- **Simple CRUD**: Use Eloquent ORM
- **Always**: Parameter binding for security (`DB::select("WHERE id = ?", [$id])`)

### CRITICAL: User Approval Required
**ALL database modifications require explicit user approval:**
- CREATE, UPDATE, DELETE operations
- Migrations and schema changes
- Bulk data operations

## 📂 File Organization

### Documentation
- **All Claude docs**: `dokumentasi/claude/`
- **Playwright files**: `dokumentasi/playwright/`
- **Never leave files in root directory**

### Agents & Tools
- **Unified UI Migration Agent**: Progressive complexity handling (Level 1-3)
  - Level 1: Basic forms (80% of cases) - Standard procedures
  - Level 2: Complex layouts (15% of cases) - Enhanced procedures
  - Level 3: Enterprise features (5% of cases) - Advanced Layout Toolkit
- **Advanced Layout Toolkit (MCP)**: Enterprise-grade automation for Level 3 only
- **MCP Servers**: Development automation tools

## 🚀 Development Workflow

1. **Read Documentation**: Complete this checklist first
2. **Apply TDD**: Red → Green → Refactor (MANDATORY)
3. **Follow Clean Architecture**: Domain → Application → Interface → Infrastructure
4. **REAL-TIME DOCUMENTATION**: Track every fix immediately (see REAL_TIME_DOCUMENTATION_PROTOCOL.md)
5. **Get Approval**: For any database modifications
6. **Update Documentation**: Keep docs current

## 🔒 STRICT PROTOCOL ENFORCEMENT (MANDATORY)

### 🚨 ZERO TOLERANCE VIOLATIONS
**These protocols MUST be followed without exception:**

#### **1. MANDATORY TodoWrite Protocol**
```
❌ NEVER start any task without TodoWrite
✅ ALWAYS create task list BEFORE any work
✅ ALWAYS mark tasks in_progress when working
✅ ALWAYS mark tasks completed IMMEDIATELY when done
```

#### **2. MANDATORY Safety Protocol**
```
❌ NEVER edit files without backup first
✅ ALWAYS run ./safety/backup-before-work.sh
✅ ALWAYS verify backup completed successfully
✅ ALWAYS create checkpoints during work
```

#### **3. MANDATORY Systematic Debugging**
```
❌ NEVER use trial-error approach
✅ ALWAYS test layers systematically: Database → Service → Controller → Composer → View → Frontend
✅ ALWAYS document findings at each layer IMMEDIATELY
✅ ALWAYS test each fix before moving to next layer
```

#### **4. MANDATORY Real-Time Documentation**
```
❌ NEVER batch documentation at end
✅ ALWAYS document EVERY fix immediately when applied
✅ ALWAYS include: File, Lines, Problem, Solution, Why it works, Verification
✅ ALWAYS update TodoWrite progress in real-time
```

#### **5. MANDATORY Planning Phase**
```
❌ NEVER start coding immediately
✅ ALWAYS analyze problem systematically first
✅ ALWAYS create comprehensive plan with TodoWrite
✅ ALWAYS get user confirmation for approach
```

#### **6. MANDATORY Real User Testing Protocol**
```
❌ NEVER rely on Playwright automation alone for UI validation
✅ ALWAYS apply 5-phase real user testing for critical interactions
✅ ALWAYS validate CSS interference and event handling
✅ ALWAYS test both automation AND real user scenarios
✅ Phase 1: DOM Readiness → Phase 2: CSS Interference → Phase 3: Event Handlers → Phase 4: Real User Click → Phase 5: Data Loading
```

### 🛡️ PROTOCOL ENFORCEMENT MECHANISMS

#### **Self-Monitoring Checklist (REQUIRED for every task)**
- [ ] ✅ TodoWrite task list created and active
- [ ] ✅ Safety backup completed
- [ ] ✅ Systematic approach planned
- [ ] ✅ Real-time documentation ready
- [ ] ✅ Layer-by-layer testing strategy defined
- [ ] ✅ Real user testing protocol applied for UI interactions

#### **Protocol Violation Tracking**
```
VIOLATIONS WILL BE DOCUMENTED and ANALYZED:
- Trial-error attempts without systematic approach
- File edits without TodoWrite tracking
- Missing safety backups
- Batch documentation instead of real-time
- Skipping user confirmation for critical changes
```

#### **Mandatory Reflection Protocol**
```
After EVERY major task:
1. Rate protocol compliance (1-10)
2. Document any violations and why they occurred
3. Identify process improvements
4. Update protocol based on learnings
```

### 🎯 EXPECTED BEHAVIOR STANDARDS

#### **For Complex Problems:**
1. **STOP** - Don't immediately start fixing
2. **PLAN** - Create TodoWrite task breakdown
3. **BACKUP** - Run safety scripts
4. **ANALYZE** - Systematic layer investigation
5. **DOCUMENT** - Real-time fix tracking
6. **VERIFY** - Test each change individually
7. **REFLECT** - Protocol compliance review

#### **For Simple Tasks:**
1. **TodoWrite** - Even simple tasks need tracking
2. **BACKUP** - No exceptions to safety
3. **DOCUMENT** - Real-time, not afterward
4. **VERIFY** - Test before marking complete

### 🚀 PROTOCOL SUCCESS METRICS

#### **Efficiency Indicators:**
- Zero trial-error attempts
- All fixes documented in real-time
- 100% TodoWrite compliance
- 100% safety backup compliance
- Systematic debugging approach used

#### **Quality Indicators:**
- User satisfaction with first attempt
- Zero protocol violations per session
- Complete documentation available
- All changes properly tested and verified

**🎯 GOAL: Transform from reactive trial-error to proactive systematic methodology**

## 📚 Detailed Documentation

**🎯 Quick Patterns**: [PATTERN_LIBRARY.md](dokumentasi/claude/PATTERN_LIBRARY.md) - All patterns at a glance

For comprehensive guides:
- **[Template Patterns](dokumentasi/claude/TEMPLATE_PATTERNS.md)** - Template refactoring examples
- **[Component Patterns](dokumentasi/claude/COMPONENT_PATTERNS.md)** - Reusable component library
- **[Coding Standards](dokumentasi/claude/CODING_STANDARDS.md)** - Code quality guidelines
- **[TDD Strategy](dokumentasi/claude/CLEAN_ARCHITECTURE_TDD_STRATEGY.md)** - Complete TDD methodology
- **[Database Guide](dokumentasi/claude/DATABASE_GUIDE.md)** - Database best practices
- **[Real User Testing Protocol](dokumentasi/claude/REAL_USER_TESTING_PROTOCOL.md)** - Comprehensive UI testing methodology

## 🎓 Learning & Problem-Solving

- **[Experiential Programming Education](dokumentasi/claude/EXPERIENTIAL_PROGRAMMING_EDUCATION.md)** - Real-world problem-solving methodology
- **[Learning Cases](dokumentasi/claude/learning-cases/)** - Detailed case studies from actual development challenges
- **[Troubleshooting Guides](dokumentasi/claude/README.md#database-troubleshooting)** - Systematic debugging approaches

## ⚡ Quick Decision Checklist

### Laravel Backend Decisions:
- **New feature?** → TDD first: Unit → Integration → E2E
- **Database query?** → Complex (JOINs) = Raw SQL, Simple = Eloquent
- **API endpoint?** → Controller → Service → Repository pattern
- **Data modification?** → Get user approval first

### React Frontend Decisions:
- **New component?** → Check existing patterns in `/components/Layout/`
- **State management?** → Local state first, Context if shared
- **API calls?** → Use existing service patterns
- **Styling?** → Ant Design first, Tailwind for custom

### Clean Code Refactoring Decisions:
- **Inline JavaScript?** → Extract to external files, use component methods
- **Flash messages?** → Create reusable `<x-flash-messages />` component
- **Mixed concerns?** → Separate presentation, logic, and styling
- **CDN links?** → Move to partials like `@include('layouts.partials.auth-styles')`
- **Large templates?** → Break into focused partials (`header`, `form`, `footer`)
- **Code duplication?** → Create reusable components and utilities
- **Dashboard sections?** → Component suite: `<x-dashboard-welcome-info />`, `<x-dashboard-quick-stats />`
- **Inline CSS?** → Extract to dedicated CSS files, use `@push('styles')`
- **User data?** → Pass via props: `:user="$user"` for component data binding

### UI Testing Decisions:
- **Button not clickable?** → Apply real user testing protocol: CSS z-index: 9999, pointer-events: auto
- **Playwright passes but users fail?** → Implement 5-phase real user testing validation
- **Event handlers not working?** → Use capture phase: `addEventListener(..., true)`, 500ms DOM delay
- **Filter state bleeding?** → Add `clearReportHeader()` when switching between reports
- **Parameter not used in query?** → Dynamic config: `["field >= ?", ["paramName"]]` with parameter binding

## 🚨 Common Error Solutions

### Backend Errors:
```bash
# Migration issues
php artisan migrate:fresh --seed

# Permission errors
chmod +x scripts/* && ./quick_context.sh

# Service binding
Check AppServiceProvider.php for DI bindings
```

### Frontend Errors:
```bash
# Dependency issues
rm -rf node_modules package-lock.json && npm install

# Build errors
npm run build -- --mode development

# Component not found
Check import paths and component exports
```

## 🎯 Pattern Shortcuts

### Controller Pattern:
```php
// Standard API controller structure
public function index(Request $request): JsonResponse
{
    $result = $this->service->getAll($request->validated());
    return response()->json($result);
}
```

### Service Pattern:
```php
// Standard service with TDD
class UserPermissionService {
    public function getUserMenus(string $userId): array {
        // Business logic here - unit testable
    }
}
```

### React Component Pattern:
```jsx
// Standard functional component
const ComponentName = ({ prop1, prop2 }) => {
    const [state, setState] = useState(initialValue);
    return <div>{/* JSX here */}</div>;
};
```

### Clean Code Template Patterns:
**📚 Detailed patterns:** [TEMPLATE_PATTERNS.md](dokumentasi/claude/TEMPLATE_PATTERNS.md)

- **Main template structure**: Clean layout with partials
- **Flash messages**: `<x-flash-messages />` component
- **Dashboard suite**: `<x-dashboard-welcome-info :user="$user" />`
- **Asset management**: `@include('layouts.partials.module-styles')`

### Real User Testing Patterns:
**📚 Complete protocol:** [REAL_USER_TESTING_PROTOCOL.md](dokumentasi/claude/REAL_USER_TESTING_PROTOCOL.md)

- **Clickable button CSS**: `z-index: 9999; pointer-events: auto; position: relative;`
- **Robust event listener**: `addEventListener('click', handler, true)` with 500ms delay
- **Dynamic parameter config**: `["Tanggal >= ?", ["periodeAwal"]]` for flexible queries
- **Filter state clearing**: `clearReportHeader()` when switching between reports

### Dynamic Report Patterns:
```php
// Parameter extraction from dynamic config
private function getWhereConditionParameters($config, array $parameters): array {
    $whereParams = [];
    $configJson = json_decode($config->CONFIG_JSON, true);
    foreach ($configJson['whereConditions'] as $condition) {
        if (is_array($condition) && count($condition) >= 2) {
            $paramNames = $condition[1];
            foreach ($paramNames as $paramName) {
                if (isset($parameters[$paramName])) {
                    $whereParams[] = $parameters[$paramName];
                }
            }
        }
    }
    return $whereParams;
}
```

## 🛡️ SAFETY PROTOCOLS (MANDATORY)

### Before Any Implementation:
1. ✅ **ALWAYS backup first**: `./safety/backup-before-work.sh`
2. ✅ **Create feature branch**: Never work directly on main/develop
3. ✅ **Test functionality**: After each significant change
4. ✅ **Create checkpoints**: `./safety/checkpoint-working-state.sh` when working

### Before Following Claude Suggestions:
1. ✅ **Demand backup strategy** from Claude
2. ✅ **Demand branch-based approach** (not direct changes)
3. ✅ **Demand testing protocol** and rollback plan
4. ✅ **Demand file impact analysis** before proceeding

### NEVER DO:
❌ `git restore` / `git reset --hard` without backup
❌ Direct modifications to main/develop branches
❌ Follow suggestions without safety protocol
❌ Accept destructive operations without backups

### When Program Breaks:
1. 🛑 **DON'T PANIC** - Don't immediately restore
2. 🔍 **Investigate first**: `git diff`, `git log --oneline -5`
3. 💾 **Backup broken state**: Preserve for analysis
4. 🎯 **Use safe restoration**: `./safety/safe-restore.sh`

### Safety Scripts Available:
- **`.safety/backup-before-work.sh`** - Pre-work backup
- **`.safety/checkpoint-working-state.sh`** - Working state checkpoint
- **`.safety/safe-restore.sh`** - Safe restoration without enhancement loss

## 🌳 Git Tree Visualization

### Available Commands:
- **`git tree -15`** - Enhanced tree with colors and author info
- **`git treebr -10`** - Compact branch tree view
- **`git treeall -20`** - Comprehensive tree with remotes
- **`./.safety/show-git-structure.sh`** - Complete project overview

### When to Use:
- **Before starting new feature** (understand current state)
- **After merging branches** (verify integration)
- **Daily progress review** (see development flow)
- **Team collaboration** (share visual status)
- **Debug branch issues** (understand relationships)

### Quick Project Status:
```bash
# Daily workflow
./.safety/show-git-structure.sh       # Complete overview
git tree -10                          # Recent commits tree
git treebr -15                        # Branch relationships

# Before feature work
git tree -20                          # Understand current state
./.safety/backup-before-work.sh       # Safety backup
```

## ⚠️ Important Reminders

- **TDD is MANDATORY** - No implementation without tests first
- **User approval required** for all CRUD operations
- **Follow Clean Architecture** layers strictly
- **Preserve legacy database** schema compatibility
- **Update documentation** when adding features
- **SAFETY FIRST** - Always backup before work
- **USE GIT TREE** - Visual understanding prevents mistakes

---

**🎯 Focus: Safety first, Quality over speed, Methodology over shortcuts, Documentation over assumptions.**