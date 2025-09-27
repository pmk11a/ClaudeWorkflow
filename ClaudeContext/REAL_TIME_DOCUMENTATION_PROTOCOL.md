# Real-Time Documentation Protocol

🎯 **TUJUAN**: Mencegah solusi hilang dari dokumentasi - No more trial-error cycles!

## 📋 MANDATORY WORKFLOW

### Setiap Melakukan Fix APAPUN:

```markdown
1. 🔍 IDENTIFY: Apa masalahnya?
2. 🔧 FIX: Apply solution
3. 📝 DOCUMENT IMMEDIATELY: Write down what was done
4. ✅ VERIFY: Confirm it works
5. ➡️ CONTINUE: Move to next issue
```

**❌ JANGAN PERNAH**: Fix semua → Document later (ini yang bikin CSS hilang!)

## 🎯 Fix Tracking Template

⚠️ **IMPORTANT**: Dokumentasi HANYA untuk solusi yang **CONFIRMED WORKING**, bukan trial-error attempts!

### Filter Criteria:
```markdown
✅ DOCUMENT: Solution yang fix masalah dan verified working
❌ JANGAN: Trial attempts, temporary fixes, atau yang tidak berhasil
```

Untuk FINAL WORKING SOLUTION saja:

```markdown
### Fix #N: [Brief Description]
- **File**: `path/to/file.ext:line_numbers`
- **Problem**: [Specific issue encountered]
- **Solution**: [Exact changes made - FINAL VERSION ONLY]
- **Why**: [Technical explanation mengapa ini berhasil]
- **Verification**: [Proof that it works - screenshots, tests, etc]
- **Time**: [When final working solution applied]
```

### Trial-Error Handling:
```markdown
JANGAN dokumentasi semua attempts:
❌ "Tried X, didn't work"
❌ "Attempted Y, failed"
❌ "Maybe Z will work"

HANYA final solution:
✅ "Applied Z solution: [exact working code/config]"
✅ "Verified working: [proof]"
```

## 🔄 Integration dengan TodoWrite

```markdown
SELALU gunakan TodoWrite untuk track:
✅ "Analyze database structure"
✅ "Fix backend hierarchy logic"
✅ "Update template compatibility"
✅ "Fix CSS layout issues"
✅ "Document all solutions"
```

## 📊 Quality Control

### Before Marking Task Complete:
- [ ] All fixes documented with template above
- [ ] Screenshots/evidence captured
- [ ] Verification steps recorded
- [ ] Why it works explained

### Red Flags (STOP and document):
- You changed any file without documenting THE WORKING SOLUTION
- You found working solution but didn't document it immediately
- You moved to next task without documenting what actually worked

### Quality Filter:
```markdown
BEFORE DOCUMENTING, ASK:
1. Apakah ini FINAL working solution?
2. Sudah di-verify benar-benar fix masalah?
3. Ada proof/evidence bahwa ini berhasil?

If ANY answer is NO → JANGAN dokumentasi dulu
If ALL answers are YES → WAJIB dokumentasi immediately
```

## 🔄 Context Update Protocol

### Session State Updates:
```json
// Update session_state.json after each fix:
{
  "current_patterns": "Add new patterns being used",
  "recent_errors": "Add last 3 errors + solutions",
  "architecture_decisions": "Document new technical decisions",
  "blocked_tasks": "Update/remove resolved blockers"
}
```

### Information Prioritization:
**HIGH PRIORITY** (Always track):
- Working solutions that fix real problems
- New patterns that work across multiple scenarios
- Technical decisions that affect architecture
- Errors that caused significant delay

**LOW PRIORITY** (Skip):
- Trial-error attempts that didn't work
- Temporary workarounds
- Obvious/trivial solutions
- One-time specific fixes with no reuse value

### Context Validation Checklist:
```bash
# Before session end:
1. Is session_state.json current?
2. Are patterns accurately documented?
3. Are error solutions complete?
4. Are architectural decisions captured?
5. Is CLAUDE.md Quick Decision section updated if needed?
```

### Context Maintenance Rules:
- **Max 3 recent_errors** (remove oldest when adding new)
- **Archive old decisions** (move to completed_decisions if needed)
- **Update current_patterns** based on actual usage
- **Remove resolved blocked_tasks**

## 🎓 Learning Integration

### After Each Session:
1. Review all fixes made
2. Create/update case study with ALL solutions
3. Identify patterns and methodologies
4. Update future reference guides
5. **VALIDATE CONTEXT** using checklist above

**RESULT**: Complete troubleshooting record → No lost solutions → No trial-error repeats → Current context!