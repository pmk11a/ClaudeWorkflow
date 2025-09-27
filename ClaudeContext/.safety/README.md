# Safety and Backup Documentation

🛡️ **CRITICAL**: This directory contains safety protocols to prevent enhancement loss and program breakage.

## 📋 Available Scripts

### 1. `backup-before-work.sh`
- **Purpose**: Create backup before any implementation work
- **Usage**: Run before starting any feature/fix
- **Result**: Creates timestamped backup branch with current state

### 2. `checkpoint-working-state.sh`
- **Purpose**: Create checkpoint when program is working
- **Usage**: Run after successful enhancements
- **Result**: Creates checkpoint branch + tag for easy restoration

### 3. `safe-restore.sh`
- **Purpose**: Safe restoration without losing enhancements
- **Usage**: When program breaks, restore to working state safely
- **Result**: Investigates changes, creates backup of broken state, restores safely

## 🚨 MANDATORY PROTOCOLS

### Before Any Work:
1. ✅ Run `./safety/backup-before-work.sh`
2. ✅ Create feature branch (never work on main/develop directly)
3. ✅ Test functionality after each significant change

### When Program Works:
1. ✅ Run `./safety/checkpoint-working-state.sh`
2. ✅ Document what's working in commit message
3. ✅ Push checkpoint branches to origin

### When Following Claude Suggestions:
1. ✅ Demand backup strategy from Claude
2. ✅ Demand branch-based approach (not direct changes)
3. ✅ Demand testing protocol and rollback plan
4. ✅ NEVER accept destructive operations without backups

## 🏷️ Branch Naming Conventions

- `backup/before-YYYYMMDD-HHMMSS` - Pre-work backups
- `checkpoint/working-YYYYMMDD-HHMMSS` - Working state checkpoints
- `backup/broken-state-YYYYMMDD-HHMMSS` - Broken state preservation
- `fix/restore-to-working-state` - Safe restoration branches

## 🏗️ Recovery Strategy

If program breaks:
1. **DON'T PANIC** - Don't immediately restore/reset
2. **Investigate** - Check what changed with `git diff`
3. **Backup broken state** - Preserve for analysis
4. **Selective restore** - Try fixing specific files first
5. **Full restore** - Only if selective approach fails
6. **Cherry-pick** - Restore good enhancements from backup

## 📊 Lessons Learned

### ❌ Previous Mistake:
- Program working → Feature → Fixes → Program broken
- Claude suggested `git restore` → User agreed → Lost all enhancements
- Result: Back to basic files, lost significant work

### ✅ New Protocol:
- Always backup before work
- Checkpoint when working
- Branch-based development
- Safe restoration with enhancement preservation
- Multiple restore points available

---

**Remember**: Enhancement loss is preventable with proper safety protocols!