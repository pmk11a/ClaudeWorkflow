#!/bin/bash
# Claude Multi-Session Context Restoration Script

echo "=== CLAUDE MULTI-SESSION CONTEXT RESTORATION ==="
echo "Session Start Time: $(date)"
echo ""
echo "🚨 CRITICAL REMINDER: Claude MUST read these files:"
echo "  📋 CLAUDE.md - Project overview and guidelines"
echo "  📚 dokumentasi/claude/README.md - Documentation index"
echo ""

# Check for existing session data
if [ -f ".claude/session_state.json" ]; then
    echo "📁 Previous session data found"
    echo "Last Session: $(jq -r '.last_session.timestamp // "Unknown"' .claude/session_state.json 2>/dev/null || echo "Unable to read")"
    echo "Session Count: $(jq -r '.session_count // 0' .claude/session_state.json 2>/dev/null || echo "0")"
    echo "Last Activity: $(jq -r '.last_session.activity // "Unknown"' .claude/session_state.json 2>/dev/null || echo "Unknown")"
else
    echo "🆕 No previous session data found - Initializing new session tracking"
    mkdir -p .claude
    cat > .claude/session_state.json << 'EOF'
{
  "session_count": 0,
  "project_info": {
    "name": "Smart Accounting DAPEN-KA",
    "type": "Delphi to Laravel Migration",
    "status": "Active Development",
    "main_directories": ["backend/", "frontend/", "Delphi/", "Boba/"]
  },
  "project_progress": {
    "completed_tasks": [
      "Database model migration (100+ models)",
      "Basic Laravel setup",
      "React frontend structure",
      "Clean code standards documentation",
      "Multi-session protocol implementation",
      "Test verification system"
    ],
    "current_tasks": [],
    "next_priorities": [
      "Authentication system implementation",
      "Core business logic migration"
    ]
  }
}
EOF
fi

echo ""
echo "📋 Reading CLAUDE.md for project context..."
if [ -f "CLAUDE.md" ]; then
    echo "✅ CLAUDE.md found and ready"
    echo "Project: Smart Accounting DAPEN-KA (Delphi to Laravel Migration)"
else
    echo "❌ CLAUDE.md not found - Critical project context missing"
fi

echo ""
echo "📊 Reading project documentation..."
if [ -d "dokumentasi/claude/" ]; then
    DOC_COUNT=$(ls -1 dokumentasi/claude/*.md 2>/dev/null | wc -l)
    echo "✅ Found $DOC_COUNT documentation files in dokumentasi/claude/"
    echo "Key documents:"
    echo "  📄 ANALISIS_MIGRASI_DELPHI_KE_LARAVEL.md"
    echo "  ✅ CLAUDE_HONEST_TEST_PROTOCOL.md"
    echo "  🔄 CLAUDE_MULTI_SESSION_PROTOCOL.md"
else
    echo "❌ No documentation directory found"
fi

echo ""
echo "🏗️ Checking project structure..."
[ -d "backend" ] && echo "✅ Backend directory found" || echo "❌ Backend directory missing"
[ -d "frontend" ] && echo "✅ Frontend directory found" || echo "❌ Frontend directory missing"
[ -d "Delphi" ] && echo "📚 Delphi reference found" || echo "⚠️ Delphi reference missing"
[ -d "Boba" ] && echo "📚 Boba reference found" || echo "⚠️ Boba reference missing"

echo ""
echo "=== CONTEXT RESTORATION COMPLETE ==="
echo "📖 Next: Read CLAUDE.md for full project context"
echo "🔍 Next: Run ./quick_context.sh for quick overview"
echo "✅ Ready for development work"