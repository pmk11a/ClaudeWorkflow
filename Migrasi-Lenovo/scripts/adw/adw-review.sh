#!/bin/bash
# =============================================================================
# ADW: Delphi Migration Code Review Pipeline
# =============================================================================
# Automated code review for migrated Delphi modules
#
# Usage: ./adw-review.sh [branch-name]
# Example: ./adw-review.sh feature/ppl-migration
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
BRANCH=${1:-$(git branch --show-current 2>/dev/null || echo "main")}
BASE_BRANCH=${2:-main}
LOG_DIR="logs/adw"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${LOG_DIR}/review_${TIMESTAMP}.log"

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
# Pipeline Start
# =============================================================================

echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║       ADW: Delphi Migration Code Review Pipeline                ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║  Branch: ${BRANCH}                                              "
echo "║  Base: ${BASE_BRANCH}                                           "
echo "║  Started: $(date)                                               "
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# =============================================================================
# Step 1: Static Analysis
# =============================================================================
step "Step 1: Static Analysis"

# Run Pint
log "Running Pint..."
if ./vendor/bin/pint --test 2>&1 | tee -a "$LOG_FILE"; then
    success "Code formatting OK"
    LINT_STATUS="✅ Passed"
else
    warn "Code formatting issues"
    LINT_STATUS="⚠️ Issues"
fi

# PHP syntax check
log "Running PHP syntax check..."
SYNTAX_ERRORS=0
for file in $(find app -name "*.php" 2>/dev/null); do
    if ! php -l "$file" > /dev/null 2>&1; then
        error "Syntax error in: $file"
        ((SYNTAX_ERRORS++))
    fi
done

if [ $SYNTAX_ERRORS -eq 0 ]; then
    success "No PHP syntax errors"
    SYNTAX_STATUS="✅ Passed"
else
    error "${SYNTAX_ERRORS} syntax errors found"
    SYNTAX_STATUS="❌ ${SYNTAX_ERRORS} errors"
fi

# =============================================================================
# Step 2: Security Review
# =============================================================================
step "Step 2: Security Review"

SECURITY_ISSUES=0

# Check for SQL injection
log "Checking for SQL injection vulnerabilities..."
if grep -rn "DB::select.*\.\s*\$\|DB::raw.*\.\s*\$" app/ 2>/dev/null; then
    error "CRITICAL: Possible SQL injection found!"
    ((SECURITY_ISSUES++))
else
    success "No SQL injection patterns found"
fi

# Check for forbidden commands in code
log "Checking for forbidden database commands..."
if grep -rn "migrate:fresh\|migrate:reset\|migrate:refresh\|db:wipe" app/ database/ 2>/dev/null; then
    error "CRITICAL: Forbidden migration command in code!"
    ((SECURITY_ISSUES++))
else
    success "No forbidden migration commands"
fi

# Check for hardcoded credentials
log "Checking for hardcoded credentials..."
if grep -rn "password\s*=\s*['\"].*['\"]" app/ --include="*.php" 2>/dev/null | grep -v "password_confirmation\|password_reset"; then
    warn "Possible hardcoded credentials found - please review"
fi

# Check authorization
log "Checking authorization implementation..."
CONTROLLERS=$(find app/Http/Controllers -name "*Controller.php" -newer .git/index 2>/dev/null || find app/Http/Controllers -name "*Controller.php" 2>/dev/null | head -5)

for controller in $CONTROLLERS; do
    if ! grep -q "authorize\|middleware.*auth" "$controller" 2>/dev/null; then
        warn "Controller may be missing authorization: $(basename $controller)"
    fi
done

if [ $SECURITY_ISSUES -eq 0 ]; then
    SECURITY_STATUS="✅ Passed"
else
    SECURITY_STATUS="❌ ${SECURITY_ISSUES} issues"
fi

# =============================================================================
# Step 3: Test Suite
# =============================================================================
step "Step 3: Test Suite"

log "Running test suite..."
if php artisan test 2>&1 | tee -a "$LOG_FILE"; then
    success "All tests passed"
    TEST_STATUS="✅ Passed"
else
    warn "Some tests failed"
    TEST_STATUS="⚠️ Failed"
fi

# =============================================================================
# Step 4: Migration-Specific Checks
# =============================================================================
step "Step 4: Migration-Specific Checks"

log "Checking Delphi migration patterns..."

# Check for mode operations (Choice:Char pattern)
log "Verifying mode operations..."
SERVICES=$(find app/Services -name "*Service.php" 2>/dev/null)

for service in $SERVICES; do
    # Check for transaction wrapping
    if grep -q "DB::transaction" "$service"; then
        log "  ✓ $(basename $service) uses transactions"
    else
        if grep -q "create\|update\|delete" "$service"; then
            warn "  ⚠ $(basename $service) may need transactions"
        fi
    fi
    
    # Check for audit logging
    if grep -q "AuditLog\|logActivity" "$service"; then
        log "  ✓ $(basename $service) has audit logging"
    else
        warn "  ⚠ $(basename $service) missing audit logging"
    fi
done

# Check for lock period validation
log "Checking lock period implementation..."
if grep -rn "LockPeriod\|isLockPeriode\|IsLockPeriode" app/ 2>/dev/null | head -5; then
    success "Lock period checks found"
else
    warn "Lock period checks may be missing"
fi

# Check for authorization service
log "Checking authorization service..."
if grep -rn "AuthorizationService\|canAuthorize\|CekOtorisasi" app/ 2>/dev/null | head -5; then
    success "Authorization service found"
else
    warn "Authorization service may be missing"
fi

MIGRATION_STATUS="✅ Reviewed"

# =============================================================================
# Step 5: Documentation Check
# =============================================================================
step "Step 5: Documentation Check"

log "Checking documentation..."

DOC_STATUS="✅ Complete"

# Check for Delphi reference comments
log "Checking for Delphi reference comments..."
SERVICES_WITH_REFS=$(grep -rl "Delphi:\|FrmPPL\|FrmPO\|Choice=" app/ 2>/dev/null | wc -l)

if [ "$SERVICES_WITH_REFS" -gt 0 ]; then
    success "Found ${SERVICES_WITH_REFS} files with Delphi references"
else
    warn "No Delphi reference comments found in code"
    DOC_STATUS="⚠️ Add references"
fi

# Check for PHPDoc comments
log "Checking PHPDoc comments..."
METHODS_WITHOUT_DOC=$(grep -rn "public function" app/Services/*.php 2>/dev/null | wc -l)
METHODS_WITH_DOC=$(grep -rn "@param\|@return" app/Services/*.php 2>/dev/null | wc -l)

if [ "$METHODS_WITH_DOC" -gt 0 ]; then
    log "Found ${METHODS_WITH_DOC} documented parameters/returns"
else
    warn "Consider adding PHPDoc comments"
fi

# =============================================================================
# Step 6: AI Review Agent (if Claude available)
# =============================================================================
step "Step 6: AI Review Agent"

REVIEW_PROMPT="
You are a Code Review Agent for Delphi-to-Laravel migrations.

## Review Checklist

### 1. Mode Operations (CRITICAL)
- [ ] Choice='I' → store() implemented correctly
- [ ] Choice='U' → update() implemented correctly
- [ ] Choice='D' → destroy() implemented correctly

### 2. Authorization (CRITICAL)
- [ ] All controllers use authorization
- [ ] Policies check IsTambah/IsKoreksi/IsHapus
- [ ] Lock period validation present

### 3. Database Safety (CRITICAL)
- [ ] No SQL injection vulnerabilities
- [ ] Transactions wrap multi-step operations
- [ ] NOT NULL columns handled correctly

### 4. Audit Logging
- [ ] All CRUD operations logged
- [ ] Log entries match Delphi format

### 5. Validation
- [ ] All Delphi validations migrated
- [ ] Error messages in Indonesian
- [ ] Business rules preserved

### 6. Code Quality
- [ ] PSR-12 compliance
- [ ] Proper type hints
- [ ] Clear method names

## Your Task
Review the recent changes and provide:
1. Summary of what was changed
2. Critical issues (must fix)
3. Suggestions (should consider)
4. Positive highlights
5. Verdict: APPROVE / REQUEST_CHANGES / COMMENT

Run: git diff --stat
Then: Review key files
"

if command -v claude &> /dev/null; then
    log "Running AI Review Agent..."
    REVIEW_OUTPUT=$(claude -p "$REVIEW_PROMPT" 2>&1 | head -100)
    echo "$REVIEW_OUTPUT" | tee -a "$LOG_FILE"
    
    if echo "$REVIEW_OUTPUT" | grep -q "APPROVE"; then
        AI_STATUS="✅ Approved"
    elif echo "$REVIEW_OUTPUT" | grep -q "REQUEST_CHANGES"; then
        AI_STATUS="🔄 Changes Requested"
    else
        AI_STATUS="💬 Comments"
    fi
else
    log "Claude Code not found. Skipping AI review."
    AI_STATUS="⏭️ Skipped"
fi

# =============================================================================
# Summary Report
# =============================================================================
step "Review Summary"

echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║               CODE REVIEW SUMMARY                               ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║  Lint:            ${LINT_STATUS}                                "
echo "║  Syntax:          ${SYNTAX_STATUS}                              "
echo "║  Security:        ${SECURITY_STATUS}                            "
echo "║  Tests:           ${TEST_STATUS}                                "
echo "║  Migration:       ${MIGRATION_STATUS}                           "
echo "║  Documentation:   ${DOC_STATUS}                                 "
echo "║  AI Review:       ${AI_STATUS}                                  "
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║  Log File:        ${LOG_FILE}                                   "
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Determine overall verdict
if [[ "$SECURITY_STATUS" == *"issues"* ]] || [[ "$SYNTAX_STATUS" == *"errors"* ]]; then
    echo -e "${RED}❌ REVIEW FAILED - Critical issues found${NC}"
    exit 1
elif [[ "$TEST_STATUS" == *"Failed"* ]]; then
    echo -e "${YELLOW}⚠️ REVIEW WARNING - Tests need attention${NC}"
    exit 0
else
    echo -e "${GREEN}✅ REVIEW PASSED - Ready for merge${NC}"
    exit 0
fi
