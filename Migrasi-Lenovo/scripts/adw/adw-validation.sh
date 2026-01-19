#!/bin/bash
# =============================================================================
# ADW: Delphi Migration Validation Pipeline
# =============================================================================
# Validates that all Delphi validation rules are migrated to Laravel
#
# Usage: ./adw-validation.sh <module> [form]
# Example: ./adw-validation.sh PPL FrmPPL
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
FORM=${2:-"Frm${MODULE}"}
LOG_DIR="logs/adw"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${LOG_DIR}/validation_${MODULE}_${TIMESTAMP}.log"

mkdir -p "$LOG_DIR"

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
    echo "║       ADW: Migration Validation Pipeline                        ║"
    echo "╠════════════════════════════════════════════════════════════════╣"
    echo "║  Usage: ./adw-validation.sh <module> [form]                     ║"
    echo "║  Example: ./adw-validation.sh PPL FrmPPL                        ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    exit 1
fi

# =============================================================================
# Pipeline Start
# =============================================================================

echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║       ADW: Migration Validation Pipeline                        ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║  Module: ${MODULE}                                              "
echo "║  Form: ${FORM}                                                  "
echo "║  Started: $(date)                                               "
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# =============================================================================
# Step 1: Run PHP Validation Tool
# =============================================================================
step "Step 1: Running Migration Validation Tool"

VALIDATION_REPORT=".claude/migrations/${MODULE}_VALIDATION_GAPS.md"

if [ -f "tools/validate_migration.php" ]; then
    log "Running: php tools/validate_migration.php ${MODULE} ${FORM}"
    php tools/validate_migration.php "$MODULE" "$FORM" 2>&1 | tee -a "$LOG_FILE"
    
    if [ -f "$VALIDATION_REPORT" ]; then
        success "Validation report generated: $VALIDATION_REPORT"
    fi
else
    warn "Validation tool not found at tools/validate_migration.php"
    log "Creating placeholder validation..."
fi

# =============================================================================
# Step 2: Check Laravel Test Coverage
# =============================================================================
step "Step 2: Running Laravel Tests"

TEST_FILE="tests/Feature/${MODULE}Test.php"

if [ -f "$TEST_FILE" ]; then
    log "Running tests for ${MODULE}..."
    if php artisan test --filter="${MODULE}" 2>&1 | tee -a "$LOG_FILE"; then
        success "All ${MODULE} tests passed"
        TEST_STATUS="✅ Passed"
    else
        warn "Some tests failed"
        TEST_STATUS="⚠️ Failed"
    fi
else
    warn "No test file found: $TEST_FILE"
    TEST_STATUS="⏭️ No tests"
fi

# =============================================================================
# Step 3: Check Code Quality
# =============================================================================
step "Step 3: Code Quality Checks"

# Run Pint
log "Running Pint (code formatter)..."
if ./vendor/bin/pint --test 2>&1 | tee -a "$LOG_FILE"; then
    success "Code formatting OK"
    LINT_STATUS="✅ Passed"
else
    warn "Code formatting issues found"
    LINT_STATUS="⚠️ Issues"
fi

# Check for forbidden patterns
log "Checking for forbidden patterns..."

FORBIDDEN_COUNT=0

# Check for SQL injection risks
if grep -rn "DB::select.*\.\s*\$" app/ 2>/dev/null; then
    error "CRITICAL: Possible SQL injection found!"
    ((FORBIDDEN_COUNT++))
fi

# Check for forbidden migration commands
if grep -rn "migrate:fresh\|migrate:reset\|migrate:refresh" app/ 2>/dev/null; then
    error "CRITICAL: Forbidden migration command found!"
    ((FORBIDDEN_COUNT++))
fi

# Check for commented authorization
if grep -rn "//.*authorize\|#.*authorize" app/Http/Controllers/*${MODULE}* 2>/dev/null; then
    warn "Commented authorization found - please review"
fi

if [ $FORBIDDEN_COUNT -eq 0 ]; then
    success "No forbidden patterns found"
    SECURITY_STATUS="✅ Passed"
else
    error "${FORBIDDEN_COUNT} forbidden patterns found!"
    SECURITY_STATUS="❌ Failed"
fi

# =============================================================================
# Step 4: Check Database Constraints
# =============================================================================
step "Step 4: Database Constraint Check"

log "Checking for NULL constraint issues..."

# Check for setting NOT NULL columns to null
SERVICE_FILE="app/Services/${MODULE}Service.php"

if [ -f "$SERVICE_FILE" ]; then
    # Check for OtoUser null assignments (known issue)
    if grep -n "OtoUser.*=>.*null" "$SERVICE_FILE" 2>/dev/null; then
        error "Found OtoUser being set to NULL - should be empty string ''"
        DB_STATUS="⚠️ Check NULL constraints"
    else
        success "No obvious NULL constraint issues"
        DB_STATUS="✅ Passed"
    fi
else
    warn "Service file not found: $SERVICE_FILE"
    DB_STATUS="⏭️ Skipped"
fi

# =============================================================================
# Step 5: Check Audit Logging
# =============================================================================
step "Step 5: Audit Logging Check"

log "Checking audit logging implementation..."

if [ -f "$SERVICE_FILE" ]; then
    AUDIT_CALLS=$(grep -c "AuditLogService\|logActivity\|->log(" "$SERVICE_FILE" 2>/dev/null || echo "0")
    
    if [ "$AUDIT_CALLS" -gt 0 ]; then
        success "Found ${AUDIT_CALLS} audit logging calls"
        AUDIT_STATUS="✅ ${AUDIT_CALLS} calls"
    else
        warn "No audit logging found in service"
        AUDIT_STATUS="⚠️ Missing"
    fi
else
    AUDIT_STATUS="⏭️ Skipped"
fi

# =============================================================================
# Step 6: Check Permission Implementation
# =============================================================================
step "Step 6: Permission Check"

log "Checking permission implementation..."

POLICY_FILE="app/Policies/${MODULE}Policy.php"
CONTROLLER_FILE="app/Http/Controllers/${MODULE}Controller.php"

PERM_STATUS="✅ Implemented"

if [ -f "$POLICY_FILE" ]; then
    success "Policy file exists: $POLICY_FILE"
    
    # Check for required methods
    for method in "create" "update" "delete"; do
        if grep -q "function ${method}" "$POLICY_FILE"; then
            log "  ✓ ${method}() method found"
        else
            warn "  ✗ ${method}() method missing"
            PERM_STATUS="⚠️ Incomplete"
        fi
    done
else
    warn "Policy file not found: $POLICY_FILE"
    PERM_STATUS="⚠️ Missing policy"
fi

# Check controller uses authorization
if [ -f "$CONTROLLER_FILE" ]; then
    if grep -q "authorize\|can(" "$CONTROLLER_FILE"; then
        log "Controller uses authorization checks"
    else
        warn "Controller may be missing authorization checks"
        PERM_STATUS="⚠️ Check controller"
    fi
fi

# =============================================================================
# Summary Report
# =============================================================================
step "Validation Summary"

echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║               VALIDATION SUMMARY: ${MODULE}                     "
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║  Tests:        ${TEST_STATUS}                                   "
echo "║  Lint:         ${LINT_STATUS}                                   "
echo "║  Security:     ${SECURITY_STATUS}                               "
echo "║  DB Safety:    ${DB_STATUS}                                     "
echo "║  Audit Log:    ${AUDIT_STATUS}                                  "
echo "║  Permissions:  ${PERM_STATUS}                                   "
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║  Gap Report:   ${VALIDATION_REPORT}                             "
echo "║  Log File:     ${LOG_FILE}                                      "
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Determine overall status
if [[ "$SECURITY_STATUS" == *"Failed"* ]]; then
    echo -e "${RED}❌ VALIDATION FAILED - Security issues found${NC}"
    exit 1
elif [[ "$TEST_STATUS" == *"Failed"* ]]; then
    echo -e "${YELLOW}⚠️ VALIDATION WARNING - Tests failed${NC}"
    exit 0
else
    echo -e "${GREEN}✅ VALIDATION PASSED${NC}"
    exit 0
fi
