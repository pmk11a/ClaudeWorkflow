#!/bin/bash

# backup-before-work.sh
# 🛡️ MANDATORY: Create backup before any implementation work
# Usage: ./safety/backup-before-work.sh

echo "🛡️ SAFETY PROTOCOL: Creating backup before work..."
echo "=================================================="

# Check if in git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ ERROR: Not in a git repository"
    exit 1
fi

# Get current branch and status
CURRENT_BRANCH=$(git branch --show-current)
BACKUP_NAME="backup/before-work-$(date +%Y%m%d-%H%M%S)"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

echo "📍 Current branch: $CURRENT_BRANCH"
echo "💾 Creating backup: $BACKUP_NAME"

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "⚠️  WARNING: You have uncommitted changes!"
    echo "🔄 Staging all changes for backup..."
    git add .
    git commit -m "safety: backup uncommitted changes before work

Auto-backup created at: $TIMESTAMP
Original branch: $CURRENT_BRANCH

🛡️ This is a safety backup to prevent enhancement loss"
fi

# Create backup branch
echo "🔀 Creating backup branch..."
git checkout -b $BACKUP_NAME

# Push backup to origin
echo "☁️  Pushing backup to origin..."
if git push -u origin $BACKUP_NAME; then
    echo "✅ Backup successfully pushed to origin"
else
    echo "⚠️  Warning: Could not push to origin (working offline?)"
fi

# Return to original branch
echo "🔙 Returning to original branch: $CURRENT_BRANCH"
git checkout $CURRENT_BRANCH

# Create backup info file
echo "📝 Creating backup info..."
cat > .safety/last-backup-info.txt << EOF
Last Backup Information
======================
Backup Branch: $BACKUP_NAME
Original Branch: $CURRENT_BRANCH
Timestamp: $TIMESTAMP
Status: ✅ Backup created successfully

Restoration Commands:
- View backup: git checkout $BACKUP_NAME
- Restore if needed: git checkout $BACKUP_NAME && git checkout -b fix/restore-from-backup
- Compare with current: git diff $BACKUP_NAME

IMPORTANT: This backup preserves your enhancements!
EOF

echo ""
echo "✅ ===== BACKUP COMPLETE ===== ✅"
echo "📂 Backup branch: $BACKUP_NAME"
echo "🏷️  Restore command: git checkout $BACKUP_NAME"
echo "📄 Info saved in: .safety/last-backup-info.txt"
echo ""
echo "🚀 You can now safely start your work!"
echo "💡 Remember to run checkpoint-working-state.sh when things work"
echo "=================================================="