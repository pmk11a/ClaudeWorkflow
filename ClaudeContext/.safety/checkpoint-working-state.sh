#!/bin/bash

# checkpoint-working-state.sh
# 🎯 Create checkpoint when program is working normally
# Usage: ./safety/checkpoint-working-state.sh

echo "🎯 CHECKPOINT: Creating working state backup..."
echo "=============================================="

# Check if in git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ ERROR: Not in a git repository"
    exit 1
fi

# Get current branch and status
CURRENT_BRANCH=$(git branch --show-current)
CHECKPOINT_NAME="checkpoint/working-$(date +%Y%m%d-%H%M%S)"
TAG_NAME="working-$(date +%Y%m%d-%H%M%S)"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

echo "📍 Current branch: $CURRENT_BRANCH"
echo "✅ Creating checkpoint: $CHECKPOINT_NAME"

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "💾 Committing current working state..."
    git add .

    # Get user input for what's working
    echo ""
    echo "📝 Describe what's working (or press Enter for default):"
    read -r WORKING_DESCRIPTION

    if [ -z "$WORKING_DESCRIPTION" ]; then
        WORKING_DESCRIPTION="Program functioning normally with enhancements"
    fi

    git commit -m "checkpoint: working state - $WORKING_DESCRIPTION

✅ Program Status: WORKING
✅ Timestamp: $TIMESTAMP
✅ Enhancements: Preserved and functional
✅ Branch: $CURRENT_BRANCH

This checkpoint can be used for safe restoration if future changes break functionality."
fi

# Create checkpoint branch
echo "🔀 Creating checkpoint branch..."
git checkout -b $CHECKPOINT_NAME

# Push checkpoint to origin
echo "☁️  Pushing checkpoint to origin..."
if git push -u origin $CHECKPOINT_NAME; then
    echo "✅ Checkpoint successfully pushed to origin"
else
    echo "⚠️  Warning: Could not push to origin (working offline?)"
fi

# Create tag for easy reference
echo "🏷️  Creating tag: $TAG_NAME"
git tag -a $TAG_NAME -m "✅ WORKING STATE CHECKPOINT

Program: ✅ Functional
Enhancements: ✅ Preserved
Timestamp: $TIMESTAMP
Branch: $CURRENT_BRANCH

Safe restoration point - all enhancements working properly."

# Push tags
if git push --tags; then
    echo "✅ Tag successfully pushed to origin"
else
    echo "⚠️  Warning: Could not push tags to origin"
fi

# Return to original branch
echo "🔙 Returning to original branch: $CURRENT_BRANCH"
git checkout $CURRENT_BRANCH

# Update checkpoint info file
echo "📝 Updating checkpoint info..."
cat > .safety/checkpoints.log << EOF
Working State Checkpoints
========================

Latest Checkpoint:
- Branch: $CHECKPOINT_NAME
- Tag: $TAG_NAME
- Timestamp: $TIMESTAMP
- Original Branch: $CURRENT_BRANCH
- Status: ✅ WORKING

Quick Restoration:
- By tag: git checkout $TAG_NAME
- By branch: git checkout $CHECKPOINT_NAME
- Create working branch: git checkout $TAG_NAME && git checkout -b fix/restore-working-state

EOF

# Append to history
echo "[$TIMESTAMP] $CHECKPOINT_NAME (Tag: $TAG_NAME) - From: $CURRENT_BRANCH" >> .safety/checkpoint-history.log

echo ""
echo "✅ ===== CHECKPOINT COMPLETE ===== ✅"
echo "📂 Checkpoint branch: $CHECKPOINT_NAME"
echo "🏷️  Tag: $TAG_NAME"
echo "🔄 Quick restore: git checkout $TAG_NAME"
echo "📄 Info saved in: .safety/checkpoints.log"
echo ""
echo "🛡️  Your working state is now safely preserved!"
echo "💡 Continue development with confidence"
echo "=============================================="