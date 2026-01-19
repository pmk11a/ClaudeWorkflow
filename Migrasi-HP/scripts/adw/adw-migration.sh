#!/bin/bash
# =============================================================================
# ADW: Delphi to Laravel Migration Pipeline
# =============================================================================
# AI Developer Workflow implementing PITER framework for Delphi migration
# Based on "The Codebase Singularity" concepts adapted for Delphi→Laravel
#
# Usage: ./adw-migration.sh <module-code>
# Example: ./adw-migration.sh PPL
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
MODULE=$1
DELPHI_PATH="d:/ykka/migrasi/pwt"
LARAVEL_PATH="d:/ykka/migrasi"
LOG_DIR="logs/adw"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${LOG_DIR}/migration_${MODULE}_${TIMESTAMP}.log"

# =============================================================================
# Helper Functions
# =============================================================================

log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}✅ $1${NC}" | tee -a "$LOG_FILE"
}

warn() {
    echo -e "${YELLOW}⚠️  $1${NC}" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}❌ $1${NC}" | tee -a "$LOG_FILE"
    exit 1
}

step() {
    echo -e "\n${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${PURPLE}📌 $1${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# =============================================================================
# Validation
# =============================================================================

if [ -z "$MODULE" ]; then
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║       ADW: Delphi to Laravel Migration Pipeline                 ║"
    echo "╠════════════════════════════════════════════════════════════════╣"
    echo "║  Usage: ./adw-migration.sh <module-code>                        ║"
    echo "║  Example: ./adw-migration.sh PPL                                ║"
    echo "║                                                                 ║"
    echo "║  Available Modules:                                             ║"
    echo "║    PPL  - Permintaan Pembelian (Purchase Request)              ║"
    echo "║    PO   - Purchase Order                                       ║"
    echo "║    SPK  - Surat Perintah Kerja                                 ║"
    echo "║    PB   - Penyerahan Bahan                                     ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    exit 1
fi

mkdir -p "$LOG_DIR"
mkdir -p "migrations-registry/in-progress"

# =============================================================================
# Pipeline Start
# =============================================================================

echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║       ADW: Delphi to Laravel Migration Pipeline                 ║"
echo "║                   PITER Framework                               ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║  Module: ${MODULE}                                              "
echo "║  Started: $(date)                                               "
echo "║  Log: ${LOG_FILE}                                               "
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# =============================================================================
# Phase 0: Discovery - Find Delphi Files
# =============================================================================
step "PHASE 0: DISCOVERY - Finding Delphi Files"

log "Searching for Delphi files for module: ${MODULE}..."

# Find .pas and .dfm files
PAS_FILES=$(find "${DELPHI_PATH}" -iname "*${MODULE}*.pas" 2>/dev/null || echo "")
DFM_FILES=$(find "${DELPHI_PATH}" -iname "*${MODULE}*.dfm" 2>/dev/null || echo "")

if [ -z "$PAS_FILES" ]; then
    warn "No .pas files found. Trying broader search..."
    PAS_FILES=$(find "${DELPHI_PATH}" -iname "Frm${MODULE}*.pas" 2>/dev/null || echo "")
fi

if [ -n "$PAS_FILES" ]; then
    echo -e "${GREEN}Found Delphi files:${NC}"
    echo "$PAS_FILES" | tee -a "$LOG_FILE"
    echo "$DFM_FILES" | tee -a "$LOG_FILE"
    success "Delphi files located"
else
    warn "No Delphi files found automatically."
    echo "Please specify manually in the spec file."
fi

# =============================================================================
# P - Problem: Create/Check Specification
# =============================================================================
step "P - PROBLEM: Migration Specification"

SPEC_DIR="migrations-registry/in-progress"
SPEC_FILE="${SPEC_DIR}/${MODULE}_SPEC.md"

if [ ! -f "$SPEC_FILE" ]; then
    log "Creating migration spec from template..."
    
    cat > "$SPEC_FILE" << EOF
# Migration Specification: ${MODULE}

**Created**: $(date)
**Status**: In Progress
**Complexity**: [SIMPLE/MEDIUM/COMPLEX]

## 1. Problem Statement
[Describe the Delphi form being migrated]

## 2. Delphi Source Files
- .pas file: ${PAS_FILES:-"[specify path]"}
- .dfm file: ${DFM_FILES:-"[specify path]"}

## 3. Requirements

### Functional Requirements
- [ ] FR1: [Description]
- [ ] FR2: [Description]

### Mode Operations (Choice:Char)
- [ ] Choice='I' (Insert) - store()
- [ ] Choice='U' (Update) - update()
- [ ] Choice='D' (Delete) - destroy()

### Permissions
- [ ] IsTambah - create permission
- [ ] IsKoreksi - update permission
- [ ] IsHapus - delete permission
- [ ] IsCetak - print permission

### Validations to Migrate
- [ ] VAL1: [Description from Delphi]
- [ ] VAL2: [Description from Delphi]

## 4. Acceptance Criteria
- [ ] All mode operations working
- [ ] All permissions enforced
- [ ] All validations migrated
- [ ] Audit logging complete
- [ ] Tests passing

## 5. Technical Design

### Database Tables
| Table | Model | Purpose |
|-------|-------|---------|
| [TABLE] | Db[MODEL] | [Purpose] |

### API Endpoints
| Method | Route | Controller Method |
|--------|-------|------------------|
| GET | /${MODULE,,} | index() |
| POST | /${MODULE,,} | store() |
| PUT | /${MODULE,,}/{id} | update() |
| DELETE | /${MODULE,,}/{id} | destroy() |

### Dependencies
- [ ] Check MyProcedure.pas for shared code
- [ ] Check related modules

## 6. Implementation Plan

### Phase 1: Core
1. Create Model (Db${MODULE}.php)
2. Create Service (${MODULE}Service.php)
3. Create Controller (${MODULE}Controller.php)
4. Create Requests (Store/Update/Delete)

### Phase 2: Views
1. Create index.blade.php
2. Create create.blade.php
3. Create edit.blade.php
4. Create show.blade.php

### Phase 3: Testing
1. Unit tests for Service
2. Feature tests for Controller
3. Browser tests for UI

## 7. Notes for Agent

### DO
- Follow existing patterns in app/
- Check ai_docs/patterns/ for similar cases
- Run validation tools after implementation
- Use transactions for multi-step operations

### DON'T
- Create new database tables
- Skip authorization checks
- Use string concatenation in SQL
- Comment out validations
EOF

    echo -e "${YELLOW}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║  📝 SPEC FILE CREATED: ${SPEC_FILE}                            "
    echo "║                                                                 ║"
    echo "║  ACTION REQUIRED:                                               ║"
    echo "║  1. Review and complete the spec file                          ║"
    echo "║  2. Fill in Delphi file paths if not auto-detected             ║"
    echo "║  3. Add specific requirements from Delphi code                 ║"
    echo "║  4. Run this script again after completing spec                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    exit 0
fi

success "Spec file exists: $SPEC_FILE"

# =============================================================================
# I - Instructions: Analysis Phase
# =============================================================================
step "I - INSTRUCTIONS: Analyzing Delphi Code"

ANALYSIS_PROMPT="
You are a Delphi Migration Agent analyzing module: ${MODULE}

## Context Files to Read First
1. CLAUDE.md - Project overview
2. ai_docs/patterns/RIGOROUS_LOGIC_MIGRATION.md - Migration patterns
3. ${SPEC_FILE} - Migration specification

## Your Task
1. Read the Delphi .pas and .dfm files specified in the spec
2. Extract:
   - All procedure names and their purposes
   - All SQL queries
   - All validation rules (MessageDlg, raise Exception)
   - All database table references
   - All permission checks (IsTambah, IsKoreksi, IsHapus)
   - All LoggingData() calls

3. Identify:
   - Mode operations (Choice:Char patterns)
   - Master-detail relationships
   - Lookup dependencies
   - Period lock checks (IsLockPeriode)
   - Authorization checks (CekOtorisasi)

4. Document findings in a structured format

## Output Format
Create analysis report at: migrations-registry/in-progress/${MODULE}_ANALYSIS.md

Start by reading the spec file:
cat ${SPEC_FILE}
"

echo -e "${CYAN}Analysis prompt prepared.${NC}"

if command -v claude &> /dev/null; then
    log "Running Analysis Agent..."
    claude -p "$ANALYSIS_PROMPT" 2>&1 | tee -a "$LOG_FILE"
    success "Analysis complete"
else
    warn "Claude Code not found. Saving prompt for manual analysis."
    echo "$ANALYSIS_PROMPT" > "${LOG_DIR}/analysis_prompt_${MODULE}.txt"
    log "Analysis prompt saved to: ${LOG_DIR}/analysis_prompt_${MODULE}.txt"
fi

# =============================================================================
# T - Tools: Check Existing Laravel Code
# =============================================================================
step "T - TOOLS: Checking Existing Laravel Code"

log "Searching for existing Laravel implementations..."

# Check for existing files
EXISTING_MODEL=$(find "app/Models" -iname "*${MODULE}*.php" 2>/dev/null || echo "")
EXISTING_SERVICE=$(find "app/Services" -iname "*${MODULE}*.php" 2>/dev/null || echo "")
EXISTING_CONTROLLER=$(find "app/Http/Controllers" -iname "*${MODULE}*.php" 2>/dev/null || echo "")
EXISTING_VIEWS=$(find "resources/views" -iname "*${MODULE,,}*" -type d 2>/dev/null || echo "")

echo -e "${CYAN}Existing Laravel code:${NC}"
echo "Models: ${EXISTING_MODEL:-'None found'}"
echo "Services: ${EXISTING_SERVICE:-'None found'}"
echo "Controllers: ${EXISTING_CONTROLLER:-'None found'}"
echo "Views: ${EXISTING_VIEWS:-'None found'}"

# Check for related patterns
log "Checking for similar implemented patterns..."
SIMILAR_PATTERNS=$(ls -la migrations-registry/successful/ 2>/dev/null | grep -v "^total" || echo "No completed migrations yet")
echo -e "${CYAN}Similar completed migrations:${NC}"
echo "$SIMILAR_PATTERNS"

# =============================================================================
# E - Examples: Load Past Migration Patterns
# =============================================================================
step "E - EXAMPLES: Loading Migration Patterns"

log "Loading examples from completed migrations..."

if [ -d "migrations-registry/successful" ]; then
    EXAMPLE_COUNT=$(ls migrations-registry/successful/*.md 2>/dev/null | wc -l || echo "0")
    echo "Found ${EXAMPLE_COUNT} completed migration examples"
    
    # Show latest examples
    ls -t migrations-registry/successful/*.md 2>/dev/null | head -3 | while read file; do
        echo "  - $(basename $file)"
    done
else
    warn "No completed migrations yet. This will be the first!"
fi

# Load lessons learned
if [ -d "ai_docs/lessons" ]; then
    log "Loading lessons learned..."
    ls ai_docs/lessons/*.md 2>/dev/null | while read file; do
        echo "  - $(basename $file)"
    done
fi

# =============================================================================
# 🚨 APPROVAL GATE - Phase 3: Plan
# =============================================================================
step "🚨 APPROVAL GATE - Implementation Plan"

echo -e "${YELLOW}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    APPROVAL REQUIRED                            ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║  Before proceeding to implementation, please:                   ║"
echo "║                                                                 ║"
echo "║  1. Review the spec file:                                       ║"
echo "║     ${SPEC_FILE}                                                "
echo "║                                                                 ║"
echo "║  2. Check the analysis report:                                  ║"
echo "║     migrations-registry/in-progress/${MODULE}_ANALYSIS.md       "
echo "║                                                                 ║"
echo "║  3. Verify complexity assessment is correct                     ║"
echo "║                                                                 ║"
echo "║  Do you approve proceeding with implementation? (y/n)           ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

read -p "Approve implementation? (y/n): " APPROVAL

if [ "$APPROVAL" != "y" ] && [ "$APPROVAL" != "Y" ]; then
    log "Implementation paused. Awaiting approval."
    echo "Please review and update the spec, then run again."
    exit 0
fi

success "Implementation approved!"

# =============================================================================
# Phase 4: Implementation
# =============================================================================
step "PHASE 4: IMPLEMENTATION"

IMPL_PROMPT="
You are an Implementation Agent for module: ${MODULE}

## Context Files to Read (in order)
1. CLAUDE.md
2. ${SPEC_FILE}
3. migrations-registry/in-progress/${MODULE}_ANALYSIS.md
4. ai_docs/patterns/RIGOROUS_LOGIC_MIGRATION.md

## Implementation Rules
1. Follow TDD: Write tests FIRST
2. Run \`php artisan test\` after each component
3. Run \`./vendor/bin/pint\` before committing
4. Use transactions for multi-step operations
5. Never skip authorization checks

## Files to Create (in order)
1. Model: app/Models/Db${MODULE}.php (if not exists)
2. Service: app/Services/${MODULE}Service.php
3. Requests: app/Http/Requests/${MODULE}/Store*.php, Update*.php
4. Policy: app/Policies/${MODULE}Policy.php
5. Controller: app/Http/Controllers/${MODULE}Controller.php
6. Views: resources/views/${MODULE,,}/
7. Routes: routes/web.php (add routes)
8. Tests: tests/Feature/${MODULE}Test.php

## After EACH file creation
- Run: php artisan test (should pass or be skipped)
- Run: ./vendor/bin/pint <file>

## Reference Patterns
Check these for patterns:
- app/Services/PPLService.php (if exists)
- app/Http/Controllers/PPLController.php (if exists)

Begin implementation now.
"

if command -v claude &> /dev/null; then
    log "Running Implementation Agent..."
    claude -p "$IMPL_PROMPT" 2>&1 | tee -a "$LOG_FILE"
    success "Implementation complete"
else
    warn "Claude Code not found."
    echo "$IMPL_PROMPT" > "${LOG_DIR}/implementation_prompt_${MODULE}.txt"
    log "Implementation prompt saved"
fi

# =============================================================================
# R - Review: Validation Pipeline
# =============================================================================
step "R - REVIEW: Validation Pipeline"

log "Running validation checks..."

# Run tests
echo -e "${CYAN}Running tests...${NC}"
if php artisan test 2>&1 | tee -a "$LOG_FILE"; then
    success "All tests passed"
    TEST_STATUS="✅ Passed"
else
    warn "Some tests failed"
    TEST_STATUS="⚠️ Issues found"
fi

# Run linting
echo -e "${CYAN}Running Pint...${NC}"
if ./vendor/bin/pint 2>&1 | tee -a "$LOG_FILE"; then
    success "Code formatted"
    LINT_STATUS="✅ Passed"
else
    warn "Formatting issues found"
    LINT_STATUS="⚠️ Issues found"
fi

# Run migration validation tool
echo -e "${CYAN}Running validation tool...${NC}"
if [ -f "tools/validate_migration.php" ]; then
    php tools/validate_migration.php "$MODULE" "Frm${MODULE}" 2>&1 | tee -a "$LOG_FILE"
    success "Validation tool completed"
else
    warn "Validation tool not found"
fi

# =============================================================================
# 🚨 FINAL SIGN-OFF
# =============================================================================
step "🚨 FINAL SIGN-OFF"

echo -e "${YELLOW}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    FINAL SIGN-OFF                               ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║  Tests: ${TEST_STATUS}                                          "
echo "║  Lint:  ${LINT_STATUS}                                          "
echo "║                                                                 ║"
echo "║  Please verify:                                                 ║"
echo "║  1. All requirements in spec are implemented                    ║"
echo "║  2. All validations from Delphi are migrated                   ║"
echo "║  3. Authorization works correctly                               ║"
echo "║  4. Audit logging is complete                                   ║"
echo "║                                                                 ║"
echo "║  Approve for production? (y/n)                                  ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

read -p "Sign off? (y/n): " SIGNOFF

if [ "$SIGNOFF" = "y" ] || [ "$SIGNOFF" = "Y" ]; then
    # Move to successful
    mkdir -p "migrations-registry/successful"
    mv "${SPEC_FILE}" "migrations-registry/successful/${MODULE}_COMPLETE.md"
    
    # Create summary
    cat > "migrations-registry/successful/${MODULE}_SUMMARY.md" << EOF
# Migration Complete: ${MODULE}

**Date**: $(date)
**Duration**: [Calculate from log]
**Complexity**: [From spec]

## Files Created
$(find app -name "*${MODULE}*" 2>/dev/null || echo "List manually")

## Test Results
${TEST_STATUS}

## Validation Results
See: .claude/migrations/${MODULE}_VALIDATION_GAPS.md

## Lessons Learned
[Add any insights for future migrations]

---
*Generated by ADW Migration Pipeline*
EOF

    success "Migration completed and documented!"
else
    warn "Migration paused. Issues to address before sign-off."
    exit 0
fi

# =============================================================================
# Summary
# =============================================================================
echo -e "\n${GREEN}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║           ADW: Migration Pipeline COMPLETE                      ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║  Module: ${MODULE}                                              "
echo "║  Status: ✅ PRODUCTION READY                                    "
echo "║  Log: ${LOG_FILE}                                               "
echo "║  Summary: migrations-registry/successful/${MODULE}_SUMMARY.md   "
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
