---
description: Analyze and document lessons learned from the migration session
allowed-tools:
  - Bash(cat:*)
  - Bash(echo:*)
  - Bash(date:*)
  - FileWrite(OBSERVATIONS.md)
---

# Delphi Migration Retrospective

Analyze this migration session and document lessons learned for continuous improvement.

## Process

1. **Review the session** and identify:
   - Which form was migrated
   - Which patterns were used
   - What worked well
   - What was challenging
   - What was discovered
   - Time spent

2. **Extract key information**:
   - Form name and source files
   - Delphi patterns detected
   - Laravel files generated
   - Quality metrics
   - Manual interventions needed
   - Time measurements

3. **Document observations** by:
   - Reading current OBSERVATIONS.md
   - Adding new entry with template
   - Including all details from this session
   - Recording specific issues encountered
   - Noting new patterns discovered
   - Capturing improvement ideas

4. **Generate summary** showing:
   - Success/failure status
   - Time taken vs expected
   - Quality score achieved
   - Patterns that need attention
   - Documentation improvements needed

## Template to Follow

Use this structure in OBSERVATIONS.md:

```markdown
## Migration: [Form Name] - [Date]

### Basic Info
- **Form**: FrmXXX
- **Date**: 2025-MM-DD
- **Migrated By**: [Name]
- **Time Taken**: Xh Xm
- **Status**: ✅ Success | ⚠️ Partial | ❌ Failed

### Delphi Analysis
- **Source Files**: 
  - `.pas` file: [path]
  - `.dfm` file: [path]
- **Form Complexity**: Low | Medium | High | Very High
- **Lines of Code**: XXX

### Patterns Detected
[List which of the 4 patterns were used]

### Laravel Output
- **Generated Files**: [List all files]
- **Lines Generated**: XXX
- **Manual Changes Required**: XX lines (X%)

### Quality Metrics
[List all coverage percentages and overall score]

### What Worked Well ✅
[List 3-5 items]

### Challenges Encountered ⚠️
[List issues with solutions and time impact]

### New Patterns Discovered 🔍
[Any new patterns not in documentation]

### Improvements Needed 💡
[Documentation, automation, examples, validation]

### Lessons Learned 📚
[Key takeaways from this migration]

### Recommendations for Next Time
[Action items for future migrations]
```

## Key Questions to Answer

1. **Pattern Usage**
   - Was Pattern 1 (Mode Operations) needed? How well did it work?
   - Was Pattern 2 (Permission Checks) needed? Any issues?
   - Was Pattern 3 (Field Dependencies) needed? Complexity?
   - Was Pattern 4 (Validation) needed? Which sub-patterns?

2. **Time Analysis**
   - Total time spent?
   - Time spent on analysis?
   - Time spent on generation?
   - Time spent on manual work?
   - Compared to expected 2-3 hours?

3. **Quality Assessment**
   - Verification tool score?
   - Any patterns missed?
   - Any manual corrections needed?
   - Code quality concerns?

4. **Issues & Solutions**
   - What blocked progress?
   - How was it resolved?
   - Could it be automated?
   - Should documentation be updated?

5. **Knowledge Capture**
   - Any new Delphi patterns discovered?
   - Any Laravel patterns that work well?
   - Any edge cases found?
   - Any workarounds created?

## Output Format

After analysis, create a structured entry in OBSERVATIONS.md that:
1. Follows the template exactly
2. Includes specific file paths and line numbers
3. Quantifies time and quality metrics
4. Provides actionable improvement suggestions
5. Captures lessons for future migrations

## Update Related Files

After adding to OBSERVATIONS.md:
1. Update METRICS-DASHBOARD.md with new statistics
2. Add any new issues to KNOWN-ISSUES.md
3. Note any documentation gaps
4. Suggest improvements to CONTINUOUS-IMPROVEMENT-PLAN.md

## Example Usage

```
> /delphi-retrospective

I'll analyze this migration session and document the lessons learned.

[Analysis of conversation history]
[Extraction of key events and metrics]
[Generation of structured entry]

Added detailed retrospective to OBSERVATIONS.md:
- Form: FrmBarang
- Status: ✅ Success
- Time: 2h 15m (target: 2-3h)
- Quality: 94/100
- Patterns: 1, 2, 4 (Mode, Permissions, Validation)

Key improvements identified:
1. Add example for nested field validation
2. Automate custom rule generation
3. Improve permission variable detection

Would you like me to:
1. Update METRICS-DASHBOARD.md with these results?
2. Add the nested validation issue to KNOWN-ISSUES.md?
3. Review similar forms for pattern recommendations?
```

## Success Criteria

A good retrospective:
- ✅ Captures all key events from the session
- ✅ Includes specific metrics and measurements
- ✅ Identifies concrete improvement opportunities
- ✅ Documents new patterns or edge cases
- ✅ Provides value for future migrations
- ✅ Takes less than 5 minutes to complete

## Remember

The goal is **continuous improvement**. Every migration teaches us something. Capture it while it's fresh!

---

Run this command after each migration to build institutional knowledge and improve the skill over time.
