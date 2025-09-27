# REAL-TIME DOCUMENTATION TEMPLATE

🚨 **MANDATORY**: Use this template to document EVERY fix as it happens. No batch documentation allowed.

## 📝 IMMEDIATE FIX DOCUMENTATION FORMAT

### **Fix Record Template**
```markdown
## Fix #[NUMBER] - [TIMESTAMP]
**Problem**: [Specific issue description]
**File**: [Full file path]
**Lines**: [Specific line numbers]
**Layer**: [Database/Service/Controller/Composer/View/Frontend]

### Before (BROKEN):
```
[Exact code that was wrong]
```

### After (WORKING):
```
[Exact code that fixes the issue]
```

### Why This Works:
[Technical explanation of why the fix solves the problem]

### Verification:
- [ ] ✅ Fix applied successfully
- [ ] ✅ Functionality tested
- [ ] ✅ No side effects observed
- [ ] ✅ TodoWrite updated

---
```

## 🎯 REAL-TIME DOCUMENTATION WORKFLOW

### **Step 1: BEFORE Starting Any Fix**
1. **Open documentation file** (create if needed)
2. **Timestamp the session**
3. **Document the problem** being investigated
4. **Note investigation strategy** (which layers to check)

### **Step 2: DURING Investigation**
1. **Document each discovery** as you find it
2. **Note each test result** immediately
3. **Record hypothesis** before testing
4. **Capture exact error messages** and stack traces

### **Step 3: IMMEDIATELY After Each Fix**
1. **STOP** - Don't continue to next issue
2. **Document the fix** using template above
3. **Verify the fix works**
4. **Update TodoWrite** progress
5. **Test for side effects**

### **Step 4: Session Wrap-up**
1. **Review all fixes** documented
2. **Verify completeness** of documentation
3. **Create summary** of all changes made
4. **Update case study** if applicable

## 📋 DOCUMENTATION STANDARDS

### **Required Information for Every Fix**
- **Timestamp**: Exact time fix was applied
- **File Path**: Full absolute path to modified file
- **Line Numbers**: Specific lines changed
- **Problem**: What was broken and why
- **Solution**: Exact code changes made
- **Reasoning**: Technical explanation of why fix works
- **Verification**: How the fix was tested and confirmed

### **Quality Standards**
```
✅ GOOD Documentation:
- Specific file paths and line numbers
- Exact before/after code snippets
- Clear explanation of why fix works
- Verification steps included
- Timestamp for when fix was applied

❌ BAD Documentation:
- Vague descriptions ("fixed the menu issue")
- No file paths or line numbers
- Missing code snippets
- No explanation of why fix works
- Batch documentation at end of session
```

## 🔄 REAL-TIME INTEGRATION WITH TODOWRITE

### **TodoWrite Integration Protocol**
```markdown
1. Create TodoWrite task: "Fix [specific issue]"
2. Mark as in_progress when starting
3. Document fix in real-time using template
4. Mark TodoWrite as completed IMMEDIATELY after fix
5. Move to next task
```

### **Example Integration**
```
TodoWrite: "Fix MenuComposer service method call"
Status: in_progress

[Apply fix and document immediately]

Fix #1 - 2025-09-20 21:10:43
Problem: MenuComposer using getUserMenusUnlimited returning 0 groups
File: backend/app/View/Composers/MenuComposer.php
Lines: 26
Layer: Service

Before: $userMenus = $this->permissionService->getUserMenusUnlimited($user->USERID);
After: $userMenus = $this->permissionService->getUserMenus($user->USERID);

Why This Works: getUserMenus returns L0-based hierarchy with 7 business menu groups
Verification: ✅ Menu now displays Berkas, Master Data, etc.

TodoWrite: Mark as completed
```

## 📊 SESSION DOCUMENTATION STRUCTURE

### **File Naming Convention**
```
Format: session-YYYY-MM-DD-HHMMSS-[brief-description].md
Example: session-2025-09-20-211043-sidebar-menu-fix.md
```

### **Session Documentation Template**
```markdown
# Session Documentation - [DATE] - [BRIEF DESCRIPTION]

## Session Overview
**Start Time**: [TIMESTAMP]
**Problem**: [Main issue being addressed]
**Approach**: [Strategy being used]
**TodoWrite Tasks**: [List of planned tasks]

## Real-Time Fix Log

[Use Fix Record Template for each fix]

## Session Summary
**End Time**: [TIMESTAMP]
**Total Fixes**: [NUMBER]
**Protocol Compliance**: [RATING/10]
**User Satisfaction**: [CONFIRMED/NOT CONFIRMED]
**Follow-up Required**: [YES/NO - details if yes]

## Protocol Compliance Review
**Violations**: [List any protocol violations]
**Improvements**: [Areas for better compliance]
**Lessons Learned**: [Key takeaways]
```

## 🚨 MANDATORY CHECKPOINTS

### **Every 30 Minutes During Active Work**
- [ ] **Documentation current** - All fixes documented
- [ ] **TodoWrite updated** - Progress accurately reflected
- [ ] **No pending documentation** - Nothing waiting to be documented
- [ ] **Verification complete** - All recent fixes tested

### **Before Moving to Next Major Task**
- [ ] **Current task fully documented**
- [ ] **TodoWrite marked completed**
- [ ] **User verification** if applicable
- [ ] **Side effects checked**

### **End of Session**
- [ ] **All fixes documented** using proper template
- [ ] **Session summary complete**
- [ ] **Protocol compliance rated**
- [ ] **Case study updated** if significant learning

## 📚 DOCUMENTATION QUALITY ASSURANCE

### **Self-Review Checklist**
- [ ] Every fix has timestamp, file, lines, problem, solution, reasoning
- [ ] Code snippets are exact and complete
- [ ] Technical explanations are clear and accurate
- [ ] Verification steps are documented
- [ ] TodoWrite progress is accurately reflected

### **Documentation Completeness Test**
**Ask yourself**: "Could another developer understand and replicate every fix I made based solely on this documentation?"

**If NO**: Documentation is incomplete and must be enhanced.
**If YES**: Documentation meets real-time standards.

---

**🎯 GOAL**: Create documentation SO comprehensive that any fix can be understood, replicated, and verified by anyone reading it, without any additional context or explanation.