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
# I - Instructions: Analysis Phase (AUTOMATED with Python Tools)
# =============================================================================
step "I - INSTRUCTIONS: Analyzing Delphi Code (Python Tools)"

ANALYSIS_FILE="${SPEC_DIR}/${MODULE}_ANALYSIS.md"

# NEW: Execute Python parser instead of prompting agent
if [ -n "$PAS_FILES" ]; then
    log "Running Delphi parser on .pas file..."

    # Use the first .pas file found
    FIRST_PAS=$(echo "$PAS_FILES" | head -1)
    FIRST_DFM=$(echo "$DFM_FILES" | head -1)

    # Execute Python parser
    TOOLS_DIR=".claude/skills/delphi-migration/tools"
    if python3 "${TOOLS_DIR}/delphi-migrate.py" analyze \
        --pas-file "$FIRST_PAS" \
        ${FIRST_DFM:+--dfm-file "$FIRST_DFM"} \
        --output "$ANALYSIS_FILE" 2>&1 | tee -a "$LOG_FILE"; then

        success "Pattern analysis complete - automated extraction finished"
        log "Analysis report: $ANALYSIS_FILE"

        # Show summary of detected patterns
        if [ -f "$ANALYSIS_FILE" ]; then
            echo -e "${CYAN}Patterns detected:${NC}"
            grep -E "^##|^###|Choice:|IsTambah|IsKoreksi|LoggingData" "$ANALYSIS_FILE" | head -20
        fi
    else
        error "Parser failed. Check logs for details."
    fi
else
    warn "No .pas files found - creating empty analysis file"
    echo "# Analysis: $MODULE" > "$ANALYSIS_FILE"
    echo "No Delphi files found to analyze." >> "$ANALYSIS_FILE"
fi

# =============================================================================
# T - Tools: Code Generation (AUTOMATED with Python Generators)
# =============================================================================
step "T - TOOLS: Generating Laravel Code (Python Generators)"

log "Generating Laravel files from analysis..."

# Check if analysis exists
if [ ! -f "$ANALYSIS_FILE" ]; then
    error "Analysis file not found. Run Phase I first."
fi

TOOLS_DIR=".claude/skills/delphi-migration/tools"
GENERATED_FILES=""

# 1. Generate Controller
log "Generating Controller..."
if python3 "${TOOLS_DIR}/generators/controller_generator.py" \
    --input "$ANALYSIS_FILE" \
    --module "$MODULE" \
    --output "app/Http/Controllers/${MODULE}Controller.php" 2>&1 | tee -a "$LOG_FILE"; then
    success "Controller generated"
    GENERATED_FILES="${GENERATED_FILES}\n  ✅ app/Http/Controllers/${MODULE}Controller.php"
else
    warn "Controller generation failed"
fi

# 2. Generate Service
log "Generating Service..."
if python3 "${TOOLS_DIR}/generators/service_generator.py" \
    --input "$ANALYSIS_FILE" \
    --module "$MODULE" \
    --output "app/Services/${MODULE}Service.php" 2>&1 | tee -a "$LOG_FILE"; then
    success "Service generated"
    GENERATED_FILES="${GENERATED_FILES}\n  ✅ app/Services/${MODULE}Service.php"
else
    warn "Service generation failed"
fi

# 3. Generate Requests
log "Generating Request classes..."
mkdir -p "app/Http/Requests/${MODULE}"
if python3 "${TOOLS_DIR}/generators/request_generator.py" \
    --input "$ANALYSIS_FILE" \
    --module "$MODULE" \
    --output "app/Http/Requests/${MODULE}/" 2>&1 | tee -a "$LOG_FILE"; then
    success "Requests generated"
    GENERATED_FILES="${GENERATED_FILES}\n  ✅ app/Http/Requests/${MODULE}/"
else
    warn "Request generation failed"
fi

# 4. Generate Policy
log "Generating Policy..."
if python3 "${TOOLS_DIR}/generators/policy_generator.py" \
    --input "$ANALYSIS_FILE" \
    --module "$MODULE" \
    --output "app/Policies/${MODULE}Policy.php" 2>&1 | tee -a "$LOG_FILE"; then
    success "Policy generated"
    GENERATED_FILES="${GENERATED_FILES}\n  ✅ app/Policies/${MODULE}Policy.php"
else
    warn "Policy generation failed"
fi

# 5. Generate Model (if not exists)
if [ ! -f "app/Models/Db${MODULE}.php" ]; then
    log "Generating Model..."
    if python3 "${TOOLS_DIR}/generators/model_generator.py" \
        --input "$ANALYSIS_FILE" \
        --module "$MODULE" \
        --output "app/Models/Db${MODULE}.php" 2>&1 | tee -a "$LOG_FILE"; then
        success "Model generated"
        GENERATED_FILES="${GENERATED_FILES}\n  ✅ app/Models/Db${MODULE}.php"
    else
        warn "Model generation failed"
    fi
else
    log "Model already exists - skipping"
fi

# 6. Generate Views
log "Generating Views..."
mkdir -p "resources/views/${MODULE,,}"
if python3 "${TOOLS_DIR}/generators/view_generator.py" \
    --input "$ANALYSIS_FILE" \
    --module "$MODULE" \
    --output "resources/views/${MODULE,,}/" 2>&1 | tee -a "$LOG_FILE"; then
    success "Views generated"
    GENERATED_FILES="${GENERATED_FILES}\n  ✅ resources/views/${MODULE,,}/"
else
    warn "View generation failed"
fi

# 7. Generate Tests
log "Generating Tests..."
if python3 "${TOOLS_DIR}/generators/test_generator.py" \
    --input "$ANALYSIS_FILE" \
    --module "$MODULE" \
    --output "tests/Feature/${MODULE}Test.php" 2>&1 | tee -a "$LOG_FILE"; then
    success "Tests generated"
    GENERATED_FILES="${GENERATED_FILES}\n  ✅ tests/Feature/${MODULE}Test.php"
else
    warn "Test generation failed"
fi

# Summary of generated files
echo -e "${GREEN}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║           Code Generation Complete                              ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║  Generated files:"
echo -e "$GENERATED_FILES"
echo "║                                                                 ║"
echo "║  Next: Agent will review and fill validation gaps               ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

success "Automated code generation completed"

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
# Phase 4: Implementation Review (Agent reviews generated code)
# =============================================================================
step "PHASE 4: IMPLEMENTATION REVIEW & GAP FILLING"

IMPL_PROMPT="
You are a Code Review Agent for module: ${MODULE}

## IMPORTANT: Code has been AUTO-GENERATED by Python tools!

Your role is to:
1. REVIEW generated code (NOT write from scratch)
2. FILL validation gaps
3. FIX any tool generation errors
4. ADD missing business logic
5. RUN tests and ensure they pass

## Context Files to Read (in order)
1. CLAUDE.md
2. ${SPEC_FILE}
3. ${ANALYSIS_FILE}
4. .claude/skills/delphi-migration/PATTERN-GUIDE.md

## Generated Files to Review
Check these files (auto-generated by tools):
- app/Http/Controllers/${MODULE}Controller.php
- app/Services/${MODULE}Service.php
- app/Http/Requests/${MODULE}/
- app/Policies/${MODULE}Policy.php
- app/Models/Db${MODULE}.php (if generated)
- resources/views/${MODULE,,}/
- tests/Feature/${MODULE}Test.php

## Your Tasks
1. READ each generated file
2. VERIFY it follows patterns from CLAUDE.md
3. CHECK for validation gaps:
   - Compare analysis to implementation
   - Ensure all Choice='I'/'U'/'D' logic exists
   - Verify all permissions (IsTambah, IsKoreksi, IsHapus)
   - Confirm all LoggingData() calls migrated
4. FIX any issues found
5. RUN php artisan test after each fix
6. RUN ./vendor/bin/pint for formatting

## What NOT to Do
❌ DO NOT rewrite files from scratch
❌ DO NOT ignore generated code
✅ DO review, fix gaps, enhance

## Validation Checklist
Run this after review:
php tools/validate_migration.php \"$MODULE\" \"Frm${MODULE}\"

Begin code review now.
"

if command -v claude &> /dev/null; then
    log "Running Code Review Agent..."
    claude -p "$IMPL_PROMPT" 2>&1 | tee -a "$LOG_FILE"
    success "Code review complete"
else
    warn "Claude Code not found."
    echo "$IMPL_PROMPT" > "${LOG_DIR}/review_prompt_${MODULE}.txt"
    log "Review prompt saved to: ${LOG_DIR}/review_prompt_${MODULE}.txt"
    echo -e "${YELLOW}Please review generated code manually.${NC}"
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
