#!/bin/bash

# safe-restore.sh
# 🔧 Safe restoration without losing enhancements
# Usage: ./safety/safe-restore.sh

echo "🔧 SAFE RESTORATION: Investigating and restoring safely..."
echo "========================================================"

# Check if in git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ ERROR: Not in a git repository"
    exit 1
fi

CURRENT_BRANCH=$(git branch --show-current)
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

echo "📍 Current branch: $CURRENT_BRANCH"
echo "🕐 Timestamp: $TIMESTAMP"
echo ""

# Step 1: Investigation
echo "🔍 STEP 1: INVESTIGATING CHANGES"
echo "================================"

echo "📊 Recent commits:"
git log --oneline -5

echo ""
echo "📝 Changed files in last commit:"
git diff --name-only HEAD~1 HEAD

echo ""
echo "📈 Lines changed in last commit:"
git diff --stat HEAD~1 HEAD

echo ""
echo "🔍 What specific changes were made?"
echo "   (Run 'git show HEAD' for detailed view)"

# Step 2: Create backup of current (potentially broken) state
echo ""
echo "💾 STEP 2: BACKING UP CURRENT STATE"
echo "==================================="

BROKEN_BACKUP="backup/broken-state-$(date +%Y%m%d-%H%M%S)"
echo "🚨 Creating backup of current state: $BROKEN_BACKUP"

git checkout -b $BROKEN_BACKUP
if git push -u origin $BROKEN_BACKUP; then
    echo "✅ Broken state backed up to: $BROKEN_BACKUP"
else
    echo "⚠️  Offline: Broken state saved locally only"
fi

git checkout $CURRENT_BRANCH

# Step 3: Show available restoration options
echo ""
echo "🎯 STEP 3: RESTORATION OPTIONS"
echo "=============================="

echo "Available checkpoints:"
if [ -f ".safety/checkpoints.log" ]; then
    cat .safety/checkpoints.log
else
    echo "⚠️  No checkpoints found. Checking for working tags..."
    git tag -l "working-*" | tail -5
fi

echo ""
echo "Available backup branches:"
git branch -r | grep "backup\|checkpoint" | tail -5

echo ""
echo "🎯 RESTORATION STRATEGIES:"
echo ""
echo "1️⃣  SELECTIVE FILE RESTORATION (Try this first):"
echo "   git checkout HEAD~1 -- path/to/specific/problematic/file"
echo "   (Restore only specific problematic files)"
echo ""
echo "2️⃣  COMMIT-BY-COMMIT ANALYSIS:"
echo "   git show HEAD~1  # Check what the previous commit changed"
echo "   git show HEAD~2  # Check commit before that"
echo ""
echo "3️⃣  CHERRY-PICK GOOD CHANGES:"
echo "   git checkout <working-tag>"
echo "   git checkout -b fix/restore-with-enhancements"
echo "   git cherry-pick <good-commit-1>"
echo "   git cherry-pick <good-commit-2>"
echo ""
echo "4️⃣  FULL RESTORATION (Last resort):"
echo "   git checkout <working-tag>"
echo "   git checkout -b fix/full-restore"
echo ""

# Step 4: Interactive restoration
echo "🤔 STEP 4: CHOOSE RESTORATION APPROACH"
echo "======================================"
echo ""
echo "What would you like to do?"
echo "1) Try selective file restoration"
echo "2) Restore to last working checkpoint"
echo "3) Analyze changes manually first"
echo "4) Show available working states"
echo "5) Exit (investigate manually)"
echo ""
read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        echo ""
        echo "📝 Selective file restoration:"
        echo "First, identify problematic files:"
        echo "git diff --name-only HEAD~1 HEAD"
        echo ""
        echo "Then restore specific files:"
        echo "git checkout HEAD~1 -- path/to/file"
        echo ""
        echo "Test after each file restoration!"
        ;;
    2)
        echo ""
        if [ -f ".safety/checkpoints.log" ]; then
            LATEST_TAG=$(grep "Tag:" .safety/checkpoints.log | tail -1 | cut -d' ' -f3)
            if [ ! -z "$LATEST_TAG" ]; then
                echo "🔄 Restoring to latest checkpoint: $LATEST_TAG"
                git checkout $LATEST_TAG
                git checkout -b fix/restore-from-checkpoint-$(date +%Y%m%d-%H%M%S)
                echo "✅ Restored to working state!"
                echo "🔀 Now on branch: $(git branch --show-current)"
            else
                echo "❌ No checkpoint tags found"
            fi
        else
            echo "❌ No checkpoints available"
        fi
        ;;
    3)
        echo ""
        echo "🔍 Manual analysis commands:"
        echo "git log --graph --oneline -10"
        echo "git diff HEAD~1 HEAD"
        echo "git show HEAD"
        echo ""
        echo "Use these to understand what changed before restoring"
        ;;
    4)
        echo ""
        echo "🏷️  Available working states:"
        git tag -l "working-*"
        echo ""
        echo "📂 Available checkpoint branches:"
        git branch -r | grep checkpoint
        ;;
    5)
        echo ""
        echo "👋 Exiting. Your broken state is backed up in: $BROKEN_BACKUP"
        echo "💡 Use investigation commands to understand what went wrong"
        ;;
    *)
        echo "❌ Invalid choice"
        ;;
esac

echo ""
echo "📄 Restoration attempt logged in: .safety/restoration.log"
echo "[$TIMESTAMP] Restoration attempt - Broken state backed up: $BROKEN_BACKUP" >> .safety/restoration.log

echo ""
echo "✅ ===== SAFE RESTORATION COMPLETE ===== ✅"
echo "🛡️  Your broken state is preserved in: $BROKEN_BACKUP"
echo "💡 You can always return to investigate: git checkout $BROKEN_BACKUP"
echo "========================================================"