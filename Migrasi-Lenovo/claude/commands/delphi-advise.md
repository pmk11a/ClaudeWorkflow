---
description: Get recommendations before starting a migration based on team knowledge
allowed-tools:
  - Bash(grep:*)
  - Bash(cat:*)
  - Bash(find:*)
  - FileRead(OBSERVATIONS.md)
  - FileRead(KNOWN-ISSUES.md)
  - FileRead(migrations-registry/*)
---

# Delphi Migration Advisor

Before starting a migration, pull wisdom from past migrations to avoid pitfalls and accelerate success.

## What This Command Does

Searches the knowledge base for:
1. **Similar forms** previously migrated
2. **Common patterns** in this module/domain
3. **Known issues** with this type of form
4. **Lessons learned** from related migrations
5. **Recommended approach** based on history

## Process

### 1. Analyze the Request
Understand what form/module the user wants to migrate:
- Form name (e.g., FrmBarang)
- Module/domain (e.g., Master data, Transactions)
- Complexity hints (simple CRUD vs complex business logic)

### 2. Search Knowledge Base
Look in these locations for relevant information:

**OBSERVATIONS.md**
- Find similar form names
- Find forms in same module
- Extract lessons learned
- Note success patterns

**KNOWN-ISSUES.md**
- Check for issues with this form type
- Look for module-specific issues
- Review workarounds
- Note critical warnings

**migrations-registry/**
- Search successful migrations
- Look at challenging migrations
- Find pattern combinations
- Review quality scores

### 3. Pattern Prediction
Based on form name and type, predict likely patterns:

**Indicators for Pattern 1 (Mode Operations)**:
- Form name contains: Frm*, Form*
- Likely has: INSERT, UPDATE, DELETE operations
- Keywords: Choice, Mode, Operation

**Indicators for Pattern 2 (Permissions)**:
- All forms typically have this
- Check for: IsTambah, IsKoreksi, IsHapus
- Role-based access common

**Indicators for Pattern 3 (Field Dependencies)**:
- Form name suggests: Master data, Complex forms
- Keywords: Conditional, Dependent, Cascading
- Multiple tabs or sections

**Indicators for Pattern 4 (Validation)**:
- All forms have basic validation
- Complex forms have: 5+ validation types
- Keywords: Validation, Check, Verify

### 4. Generate Recommendations

Provide structured advice:

```markdown
## 🎯 Pre-Migration Analysis: [Form Name]

### Similar Forms in History
- [FormName1]: Migrated [date], Score: [score], Time: [time]
  - Used patterns: [list]
  - Key lesson: [brief]
  
- [FormName2]: Migrated [date], Score: [score], Time: [time]
  - Used patterns: [list]
  - Key lesson: [brief]

### Predicted Patterns
Based on form characteristics:
- ✅ Pattern 1 (Mode Operations): HIGH confidence
  - Reason: [why]
  - Example: [reference]
  
- ✅ Pattern 2 (Permission Checks): HIGH confidence
  - Reason: [why]
  - Example: [reference]
  
- ⚠️ Pattern 3 (Field Dependencies): MEDIUM confidence
  - Reason: [why]
  - Watch for: [specific issues]
  
- ✅ Pattern 4 (Validation): HIGH confidence
  - Expected sub-patterns: [list]
  - Common challenges: [list]

### Known Issues to Watch For
1. [Issue from KNOWN-ISSUES.md]
   - Impact: [description]
   - Workaround: [solution]
   
2. [Another issue]
   - Impact: [description]
   - Workaround: [solution]

### Recommended Approach
1. **Pre-Flight Checks**
   - [ ] Read [relevant section] in PATTERN-GUIDE.md
   - [ ] Review [similar form] implementation
   - [ ] Check for [specific pattern] in Delphi code
   
2. **Migration Strategy**
   - Start with: [which pattern]
   - Pay attention to: [specific issues]
   - Use [specific tool/command]
   
3. **Quality Gates**
   - Verify [specific coverage]
   - Test [specific scenario]
   - Run verification tool

### Estimated Effort
- Complexity: [Low/Medium/High/Very High]
- Estimated Time: [X-Y hours]
- Patterns: [count]
- Validation Rules: [estimated count]

### Success Tips
1. [Tip from past migrations]
2. [Another tip]
3. [One more tip]

### Resources
- Documentation: [relevant sections]
- Examples: [similar forms]
- Code references: [file paths]
```

## Example Usage Scenarios

### Scenario 1: First Time Migrating Master Data Form
```
User: "I want to migrate FrmBarang (Item Master)"

Response:
🎯 Pre-Migration Analysis: FrmBarang

Similar Forms:
- FrmAktiva: Score 95/100, Time 2h 30m
  - Patterns: Mode Ops, Permissions, Validation
  - Lesson: "Permission checks were straightforward"
  
Predicted Patterns:
✅ All 4 patterns likely (95% confidence)

Known Issues:
⚠️ Master data often has unique constraints
- Use unique validation carefully
- Test with existing data

Recommended: Start with Pattern 1 and 2, they're well-documented.
Estimated Time: 2-3 hours
```

### Scenario 2: Complex Transaction Form
```
User: "Need to migrate FrmPurchaseOrder"

Response:
🎯 Pre-Migration Analysis: FrmPurchaseOrder

Similar Forms:
- FrmSalesOrder: Score 88/100, Time 4h 15m
  - Had nested conditionals (Issue #1)
  - Required custom validation rules
  
Predicted Patterns:
✅ Pattern 1: HIGH (multiple modes)
✅ Pattern 2: HIGH (permissions)
⚠️ Pattern 3: VERY HIGH (header-detail relationship)
✅ Pattern 4: VERY HIGH (8+ validation types)

Known Issues:
🔴 Nested conditional validation (Issue #1)
⚠️ Header-detail relationships need careful handling

Recommended: Budget 4-5 hours, read Pattern 3 carefully.
Estimated Complexity: HIGH
```

### Scenario 3: Simple Lookup Form
```
User: "Migrate FrmStatusLookup"

Response:
🎯 Pre-Migration Analysis: FrmStatusLookup

Similar Forms:
- FrmTypeLookup: Score 98/100, Time 1h 10m
  - Simple CRUD, minimal patterns
  
Predicted Patterns:
✅ Pattern 2: HIGH (basic permissions)
⚠️ Pattern 4: LOW (basic validation only)
❌ Patterns 1, 3: Unlikely for lookup tables

Known Issues:
✅ No known issues for simple lookups

Recommended: Straightforward migration, 1-1.5 hours.
Estimated Complexity: LOW
```

## Search Strategy

### 1. Exact Match
```bash
grep -i "Form: Frm${FORM_NAME}" OBSERVATIONS.md
```

### 2. Similar Names
```bash
grep -i "Form: Frm${MODULE}" OBSERVATIONS.md
```

### 3. By Module
```bash
grep -i "${MODULE}" OBSERVATIONS.md | grep "Success"
```

### 4. By Pattern
```bash
grep -A 10 "Pattern ${NUM}" OBSERVATIONS.md | grep "Lesson"
```

## Data Sources Priority

1. **OBSERVATIONS.md** (most recent, most relevant)
2. **migrations-registry/successful/** (proven approaches)
3. **migrations-registry/challenging/** (learn from difficulties)
4. **KNOWN-ISSUES.md** (avoid pitfalls)
5. **PATTERN-GUIDE.md** (best practices)

## Output Guidelines

**Be Specific**:
- Reference actual forms, not generic examples
- Include line numbers when relevant
- Quote lessons learned verbatim
- Link to documentation sections

**Be Actionable**:
- Provide concrete next steps
- Suggest specific sections to read
- Recommend specific examples to review
- Estimate effort realistically

**Be Honest**:
- If no similar forms exist, say so
- If complexity is high, warn early
- If known issues exist, highlight them
- If documentation is lacking, note it

## Success Criteria

Good advice:
- ✅ Surfaces relevant past experiences
- ✅ Provides realistic time estimates
- ✅ Warns about known pitfalls
- ✅ Recommends specific resources
- ✅ Predicts patterns accurately
- ✅ Saves time vs. discovering issues during migration

## Edge Cases

**No Historical Data**:
```
🎯 Pre-Migration Analysis: FrmNewForm

No similar forms found in migration history yet.

Recommendations based on form type:
- [General pattern predictions]
- [Standard approach]
- [Common practices]

This will be a learning opportunity!
Document thoroughly for future migrations.
```

**Contradictory Data**:
```
⚠️ Note: Historical data shows mixed results for this pattern.
- Some forms succeeded with approach A
- Others succeeded with approach B
Recommend: Start with A (more recent), have B as backup.
```

**Many Matches**:
```
Found 15 similar forms. Showing top 3 most relevant:
[Best matches based on recency, quality, similarity]

For full history, see: migrations-registry/[module]/
```

## Integration with Other Commands

**Before Migration**:
1. `/delphi-advise` - Get recommendations
2. Read suggested documentation
3. Review suggested examples
4. Start migration with confidence

**After Migration**:
1. Complete migration
2. `/delphi-retrospective` - Document lessons
3. Update knowledge base
4. Help future migrations

## Remember

Knowledge compounds! Each documented migration makes the next one easier. 

Use this command to:
- **Learn from success** - Replicate what worked
- **Avoid failures** - Skip known issues
- **Estimate accurately** - Based on real data
- **Move faster** - Less trial and error

---

Run this command BEFORE each migration to benefit from team wisdom!
