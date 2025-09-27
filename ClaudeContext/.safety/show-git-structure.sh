#!/bin/bash

# show-git-structure.sh
# 🌳 Comprehensive git structure visualization for project management
# Usage: ./safety/show-git-structure.sh

echo "🌳 DAPEN PROJECT - Git Structure Overview"
echo "========================================"
echo ""

# Current status
CURRENT_BRANCH=$(git branch --show-current)
echo "📍 Current Branch: $CURRENT_BRANCH"
echo "🕐 Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Branch overview
echo "📂 BRANCH STRUCTURE"
echo "===================="
echo ""
echo "🏠 Main Branches:"
git branch | grep -E "(master|develop)" | sed 's/^/   /'
echo ""
echo "🚀 Feature Branches:"
git branch | grep "feature/" | sed 's/^/   /'
echo ""
echo "🛡️ Safety Branches:"
git branch | grep -E "(backup|checkpoint)" | sed 's/^/   /'
echo ""
echo "☁️ Remote Branches:"
git branch -r | head -8 | sed 's/^/   /'
echo ""

# Recent commits tree
echo "🎯 RECENT COMMITS TREE (Enhanced)"
echo "=================================="
git tree -15
echo ""

# Tags and checkpoints
echo "🏷️ WORKING STATE TAGS"
echo "====================="
if git tag -l "working-*" | head -5 | grep -q .; then
    git tag -l "working-*" | head -5 | sed 's/^/   ✅ /'
else
    echo "   No working state tags found"
fi
echo ""

# Safety information
echo "🛡️ SAFETY BACKUP STATUS"
echo "======================="
if [ -f ".safety/checkpoints.log" ]; then
    echo "📄 Latest Checkpoint Info:"
    tail -3 .safety/checkpoints.log | sed 's/^/   /'
else
    echo "   No checkpoint information available"
fi
echo ""

if [ -f ".safety/last-backup-info.txt" ]; then
    echo "📄 Latest Backup Info:"
    grep -E "(Backup Branch|Timestamp)" .safety/last-backup-info.txt | sed 's/^/   /'
else
    echo "   No backup information available"
fi
echo ""

# Branch relationships
echo "🔗 BRANCH RELATIONSHIPS"
echo "======================="
echo "📊 Branch ahead/behind status:"
if git rev-list --count HEAD ^origin/develop >/dev/null 2>&1; then
    AHEAD=$(git rev-list --count HEAD ^origin/develop 2>/dev/null || echo "0")
    BEHIND=$(git rev-list --count origin/develop ^HEAD 2>/dev/null || echo "0")
    echo "   $CURRENT_BRANCH is $AHEAD commits ahead, $BEHIND commits behind origin/develop"
else
    echo "   Cannot determine branch relationship (develop may not exist on origin)"
fi
echo ""

# Project progress indicators
echo "📈 PROJECT PROGRESS INDICATORS"
echo "=============================="
echo "🎯 Feature Implementation:"
FEATURE_COMMITS=$(git log --oneline --grep="feat:" | wc -l)
echo "   - Feature commits: $FEATURE_COMMITS"

DOC_COMMITS=$(git log --oneline --grep="docs:" | wc -l)
echo "   - Documentation commits: $DOC_COMMITS"

TEST_COMMITS=$(git log --oneline --grep="test:" | wc -l)
echo "   - Testing commits: $TEST_COMMITS"

SAFETY_COMMITS=$(git log --oneline --grep="safety:" | wc -l)
echo "   - Safety commits: $SAFETY_COMMITS"
echo ""

# Quick reference commands
echo "⚡ QUICK REFERENCE COMMANDS"
echo "=========================="
echo "🌳 Enhanced tree view:     git tree -20"
echo "🔀 Compact branch view:    git treebr -15"
echo "📊 All branches detailed:  git treeall -20"
echo "🛡️ Create backup:         ./.safety/backup-before-work.sh"
echo "🎯 Create checkpoint:      ./.safety/checkpoint-working-state.sh"
echo "🔧 Safe restoration:       ./.safety/safe-restore.sh"
echo ""

# Development status
echo "🚦 DEVELOPMENT STATUS"
echo "===================="
if git diff-index --quiet HEAD --; then
    echo "✅ Working directory: Clean (no uncommitted changes)"
else
    echo "⚠️  Working directory: Has uncommitted changes"
    echo "   Modified files: $(git diff --name-only | wc -l)"
    echo "   Untracked files: $(git ls-files --others --exclude-standard | wc -l)"
fi

if git log --oneline -1 --grep="checkpoint\|backup" >/dev/null 2>&1; then
    echo "✅ Safety: Recent backup/checkpoint available"
else
    echo "⚠️  Safety: Consider creating checkpoint if code is working"
fi
echo ""

echo "📋 For detailed analysis, use individual git tree commands above"
echo "🛡️ Always backup before major changes: ./.safety/backup-before-work.sh"
echo "========================================================================"