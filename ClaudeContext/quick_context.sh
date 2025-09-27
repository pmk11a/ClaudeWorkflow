#!/bin/bash
# Quick Context Summary Script

echo "🚀 QUICK CONTEXT SUMMARY"
echo "========================"
echo ""
echo "🚨 REMINDER: Have you read the mandatory files?"
echo "  📋 CLAUDE.md - Project overview"
echo "  📚 dokumentasi/claude/README.md - Documentation index"
echo ""

# Project basics
echo "📁 Project: Smart Accounting DAPEN-KA (Delphi → Laravel Migration)"
echo "📂 Main dirs: backend/, frontend/, Delphi/ (ref), Boba/ (ref)"

# Current status
if [ -f ".claude/session_state.json" ]; then
    LAST_ACTIVITY=$(jq -r '.last_session.activity // "No previous activity"' .claude/session_state.json 2>/dev/null || echo "Unable to read")
    SESSION_COUNT=$(jq -r '.session_count // 0' .claude/session_state.json 2>/dev/null || echo "0")
    echo "📊 Sessions: $SESSION_COUNT | Last: $LAST_ACTIVITY"
else
    echo "📊 Sessions: 0 | No previous sessions"
fi

# Key files
echo "📋 Key files to check:"
echo "  • CLAUDE.md (project guide)"
echo "  • dokumentasi/claude/ (documentation)"
echo "  • .claude/session_state.json (session data)"
echo "  • verify_tests.sh (test verification)"

# Quick status
echo "⚡ Quick checks:"
[ -f "CLAUDE.md" ] && echo "  ✅ CLAUDE.md exists" || echo "  ❌ CLAUDE.md missing"
[ -d "backend" ] && echo "  ✅ Backend directory found" || echo "  ❌ Backend directory missing"
[ -d "frontend" ] && echo "  ✅ Frontend directory found" || echo "  ❌ Frontend directory missing"
[ -f ".claude/session_state.json" ] && echo "  ✅ Session state found" || echo "  ❌ Session state missing"
[ -f "verify_tests.sh" ] && echo "  ✅ Test verification script found" || echo "  ❌ Test verification script missing"

# Protocol status
echo "🔧 Protocols:"
[ -f "dokumentasi/claude/CLAUDE_HONEST_TEST_PROTOCOL.md" ] && echo "  ✅ Honest Test Protocol implemented" || echo "  ❌ Test Protocol missing"
[ -f "dokumentasi/claude/CLAUDE_MULTI_SESSION_PROTOCOL.md" ] && echo "  ✅ Multi-Session Protocol implemented" || echo "  ❌ Session Protocol missing"

# EPE System Status
echo "🎓 EPE (Experiential Programming Education):"
[ -f "dokumentasi/claude/EXPERIENTIAL_PROGRAMMING_EDUCATION.md" ] && echo "  ✅ EPE Methodology implemented" || echo "  ❌ EPE Methodology missing"
[ -d "dokumentasi/claude/learning-cases" ] && echo "  ✅ Learning cases directory found" || echo "  ❌ Learning cases missing"

# Count learning cases
if [ -d "dokumentasi/claude/learning-cases" ]; then
    CASE_COUNT=$(find dokumentasi/claude/learning-cases -name "case-*.md" | wc -l 2>/dev/null || echo "0")
    echo "  📚 Available learning cases: $CASE_COUNT"
    if [ "$CASE_COUNT" -gt 0 ]; then
        echo "    • Case 1: Session Persistence Crisis"
        echo "    • Case 2: User Interaction Protocol Evolution"
        echo "    • Case 3: Data Structure Mismatch Resolution"
        echo "    • Case 4: Quality Workflow Automation"
    fi
fi

# EPE Cross-references status
EPE_REFERENCES=0
[ -f "CLAUDE.md" ] && grep -q "Experiential Programming Education" CLAUDE.md && EPE_REFERENCES=$((EPE_REFERENCES + 1))
[ -f "dokumentasi/claude/CODING_STANDARDS.md" ] && grep -q "EXPERIENTIAL_PROGRAMMING_EDUCATION" dokumentasi/claude/CODING_STANDARDS.md && EPE_REFERENCES=$((EPE_REFERENCES + 1))
[ -f "dokumentasi/claude/SESSION_PERSISTENCE_TROUBLESHOOTING.md" ] && grep -q "learning-cases" dokumentasi/claude/SESSION_PERSISTENCE_TROUBLESHOOTING.md && EPE_REFERENCES=$((EPE_REFERENCES + 1))

echo "  🔗 EPE cross-references: $EPE_REFERENCES/3 files"

# Last Session Analysis & EPE Recommendations
echo ""
echo "🧠 Session Analysis & Methodology Guidance:"
if [ -f ".claude/session_state.json" ] && [ "$LAST_ACTIVITY" != "No previous activity" ] && [ "$LAST_ACTIVITY" != "Unable to read" ]; then
    echo "  📋 Last Activity: $LAST_ACTIVITY"

    # Pattern recognition for EPE case recommendations
    case "$LAST_ACTIVITY" in
        *"session"*|*"login"*|*"auth"*|*"persistence"*)
            echo "  💡 Suggested EPE Case: Case 1 - Session Persistence Crisis"
            echo "     🔧 Focus: Authentication debugging, session management"
            ;;
        *"template"*|*"data"*|*"structure"*|*"array"*|*"object"*)
            echo "  💡 Suggested EPE Case: Case 3 - Data Structure Mismatch"
            echo "     🔧 Focus: Service-template alignment, data flow debugging"
            ;;
        *"workflow"*|*"process"*|*"automation"*|*"quality"*)
            echo "  💡 Suggested EPE Case: Case 4 - Quality Workflow Automation"
            echo "     🔧 Focus: Process optimization, automation opportunities"
            ;;
        *"interaction"*|*"protocol"*|*"user"*|*"communication"*)
            echo "  💡 Suggested EPE Case: Case 2 - User Interaction Protocol"
            echo "     🔧 Focus: Communication optimization, workflow improvement"
            ;;
        *)
            echo "  💡 General EPE Methodology Available"
            echo "     🔧 Focus: 6-phase debugging cycle for systematic problem-solving"
            ;;
    esac

    # Quality workflow triggers
    if echo "$LAST_ACTIVITY" | grep -E "(completed|finished|done|implemented|fixed)" > /dev/null; then
        echo "  ⚡ Quality Workflow Trigger Detected!"
        echo "     📝 Consider running 4-step quality process:"
        echo "     • Testing & Validation • Code Quality Checks"
        echo "     • Documentation Updates • Commit Preparation"
    fi
else
    echo "  📋 No previous session data - Fresh start"
    echo "  💡 Recommended: Review EPE methodology for systematic approach"
    echo "     🔧 Start with: 6-phase debugging cycle for any development work"
fi

# 6-Phase Debugging Methodology Quick Reference
echo ""
echo "🔍 EPE 6-Phase Debugging Quick Reference:"
echo "  1️⃣ Problem Identification → What is the user experiencing?"
echo "  2️⃣ Investigation → Data gathering, logs, error analysis"
echo "  3️⃣ Root Cause Analysis → What exactly is failing?"
echo "  4️⃣ Solution Design → Evaluate options, assess impact"
echo "  5️⃣ Implementation → Incremental changes, validation"
echo "  6️⃣ Verification → Testing, documentation, knowledge transfer"

# Learning Opportunity Detection
echo ""
echo "🚀 Learning & Automation Opportunities:"

# Check for trigger keywords in recent development
if [ -f ".claude/session_state.json" ]; then
    # Check if development work may need quality workflow
    if echo "$LAST_ACTIVITY" | grep -E "(development|implementation|fix|code|feature)" > /dev/null; then
        echo "  📝 Development work detected - Monitor for completion signals:"
        echo "     • 'sudah muncul sempurna' • 'tampil sempurna'"
        echo "     • 'berfungsi sempurna' • 'berhasil sempurna' • 'fix sempurna'"
        echo "     ➡️  These trigger automatic 5-step quality workflow:"
        echo "     • Testing & Validation • Code Quality Checks"
        echo "     • Documentation Updates • Commit Preparation • Commit Reminder"
    fi

    # Learning case creation opportunity
    SESSION_COUNT_NUM=$(echo "$SESSION_COUNT" | grep -o '[0-9]\+' || echo "0")
    if [ "$SESSION_COUNT_NUM" -gt 0 ]; then
        echo "  🧠 Session Count: $SESSION_COUNT_NUM"
        if [ "$SESSION_COUNT_NUM" -ge 5 ]; then
            echo "     💡 Consider: Document recurring patterns as new EPE case study"
        fi
    fi
fi

# EPE methodology progression
if [ -d "dokumentasi/claude/learning-cases" ] && [ "$CASE_COUNT" -gt 0 ]; then
    echo "  📚 EPE System Maturity: $CASE_COUNT learning cases available"
    echo "     🎯 Apply proven patterns from past problem-solving experiences"
    if [ "$CASE_COUNT" -lt 10 ]; then
        echo "     📈 Growth opportunity: Create new cases for novel problem types"
    fi
fi

# Quality automation status
if [ -f "dokumentasi/claude/USER_INTERACTION_PROTOCOL.md" ]; then
    echo "  ⚙️  Quality Automation: Trigger keywords configured"
    echo "     ✅ Completion signals will auto-execute quality workflow"
else
    echo "  ⚙️  Quality Automation: Manual triggers only"
fi

echo ""
echo "========================"
echo "📖 Run: cat CLAUDE.md | head -20 (read project overview)"
echo "🔍 Run: ./restore_context.sh (full context restore)"
echo "✅ Run: ./verify_tests.sh (test verification)"
echo "🎓 Quick EPE: Read dokumentasi/claude/EXPERIENTIAL_PROGRAMMING_EDUCATION.md"
echo "📚 Case Studies: ls dokumentasi/claude/learning-cases/"