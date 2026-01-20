# Skill ↔ ADW Integration Map

**Navigation guide for moving between ADW scripts and Skill documentation**

**Status**: ✅ 100% Integrated
**Last Updated**: 2026-01-12
**Purpose**: Help users find what they need across both systems

---

## 🚀 Starting Points

### Starting from ADW
User runs: `./scripts/adw/adw-migration.sh <MODULE>`

**Next steps:**
1. **First time?** → Go to: `.claude/skills/delphi-migration/00-README-START-HERE.md`
2. **Need architecture?** → Go to: `.claude/skills/delphi-migration/ADW-ARCHITECTURE.md`
3. **Quick reference?** → Go to: `.claude/skills/delphi-migration/QUICK-REFERENCE.md`
4. **Learning real example?** → Go to: `scripts/adw/WALKTHROUGH.md` (PPL migration)

### Starting from Skill Documentation
User opens: `.claude/skills/delphi-migration/README.md`

**Next steps:**
1. **Want to migrate?** → Run: `./scripts/adw/adw-migration.sh <MODULE>`
2. **Need to understand how?** → Read: `.claude/skills/delphi-migration/ADW-ARCHITECTURE.md`
3. **Want a real example?** → Read: `scripts/adw/WALKTHROUGH.md`
4. **Reference something specific?** → Use: `.claude/skills/delphi-migration/QUICK-REFERENCE.md`

---

## 📍 Detailed Navigation Map

### When ADW Runs Phases...

#### **Phase 0: Discovery**
| ADW Action | Skill Reference | Purpose |
|-----------|-----------------|---------|
| Finds Delphi files | [PHASE-0-DISCOVERY.md](./phases/PHASE-0-DISCOVERY.md) | Step-by-step guide |
| Auto-analyzes complexity | [ADW-ARCHITECTURE.md](./ADW-ARCHITECTURE.md) Layer 1 | How complexity scoring works |
| Creates migration plan | [QUICK-REFERENCE.md](./QUICK-REFERENCE.md) Phase 0 | Quick lookup |

**User needs to understand?**
→ Read: `./phases/PHASE-0-DISCOVERY.md` (10 min)

#### **Phase 1: Analysis (P - Problem)**
| ADW Action | Skill Reference | Purpose |
|-----------|-----------------|---------|
| Extracts Delphi logic | [PATTERN-GUIDE.md](./PATTERN-GUIDE.md) Patterns 1-8 | All patterns explained |
| Finds validation rules | [PATTERN-GUIDE.md](./PATTERN-GUIDE.md) Pattern 4 | Validation rules deep dive |
| Maps permissions | [PATTERN-GUIDE.md](./PATTERN-GUIDE.md) Pattern 2 | Permission checks explained |

**User needs to understand?**
→ Read: `./phases/PHASE-1-ANALYZE.md` (20 min)
→ Reference: `./PATTERN-GUIDE.md` for specific patterns (30 min)

#### **Phase 2: Check Existing (I - Instructions)**
| ADW Action | Skill Reference | Purpose |
|-----------|-----------------|---------|
| Scans existing Laravel code | [PHASE-2-CHECK.md](./phases/PHASE-2-CHECK.md) | Step-by-step checks |
| Finds gaps | [OBSERVATIONS.md](./OBSERVATIONS.md) | Past lessons on gaps |

**User needs to understand?**
→ Read: `./phases/PHASE-2-CHECK.md` (10 min)

#### **Phase 3: Plan (T - Tools & E - Examples)**
| ADW Action | Skill Reference | Purpose |
|-----------|-----------------|---------|
| Creates detailed spec | [PHASE-3-PLAN.md](./phases/PHASE-3-PLAN.md) | Planning guide |
| Shows migration registry examples | [migrations-registry/successful/](./migrations-registry/successful/) | Real completed migrations |
| Prepares for approval gate | [ADW-ARCHITECTURE.md](./ADW-ARCHITECTURE.md) Approval Gates | What happens at gates |

**User needs to review?**
→ Read: `./phases/PHASE-3-PLAN.md` (15 min)
→ Examples: `./migrations-registry/successful/` (30 min)
→ Understanding gates: `./ADW-ARCHITECTURE.md` (10 min)

#### **Phase 4: Implement (R - Review)**
| ADW Action | Skill Reference | Purpose |
|-----------|-----------------|---------|
| Generates code | [PATTERN-GUIDE.md](./PATTERN-GUIDE.md) Pattern mapping | Pattern detection & implementation |
| Code templates | [KNOWLEDGE-BASE.md](./KNOWLEDGE-BASE.md) Recipes | Reusable code templates |
| Validates coverage | [PHASE-4-IMPLEMENT.md](./phases/PHASE-4-IMPLEMENT.md) Quality gates | Implementation standards |
| Adds tests | [SOP-DELPHI-MIGRATION.md](./SOP-DELPHI-MIGRATION.md) Testing section | Testing requirements |

**Developer needs reference?**
→ Patterns: `./PATTERN-GUIDE.md` (reference during analysis)
→ Recipes/Templates: `./KNOWLEDGE-BASE.md` (reference during coding)
→ Quality standards: `./PHASE-4-IMPLEMENT.md` (15 min)


#### **Phase 5: Test & Document**
| ADW Action | Skill Reference | Purpose |
|-----------|-----------------|---------|
| Runs validation | [PHASE-5-TEST-DOCUMENT.md](./phases/PHASE-5-TEST-DOCUMENT.md) | Testing checklist |
| Generates docs | [SOP-DELPHI-MIGRATION.md](./SOP-DELPHI-MIGRATION.md) Documentation section | Doc standards |
| Prepares sign-off | [ADW-ARCHITECTURE.md](./ADW-ARCHITECTURE.md) Approval Gates | Final gate info |

**User needs to validate?**
→ Checklist: `./phases/PHASE-5-TEST-DOCUMENT.md` (20 min)
→ Standards: `./PHASE-5-TEST-DOCUMENT.md` (15 min)

---

## 🔍 Quick Lookup by Use Case

### "I don't know what ADW is"
1. Start: `./00-README-START-HERE.md` (20 min)
2. Then: `./ADW-ARCHITECTURE.md` (15 min)
3. Then: `./scripts/adw/README.md` (10 min)
4. Try: `./scripts/adw/adw-migration.sh <TEST_MODULE>` (30 min)

### "I have validation questions"
1. Reference: `./QUICK-REFERENCE.md` Pattern 4 (2 min)
2. Deep dive: `./PATTERN-GUIDE.md` Pattern 4 (30 min)
3. Examples: `./migrations-registry/successful/` (20 min)
4. Lessons: `./OBSERVATIONS.md` (15 min)

### "I'm at Phase 3 (Planning) and need approval"
1. Read: `./phases/PHASE-3-PLAN.md` (15 min)
2. Review: `./migrations-registry/successful/PPL.md` (20 min)
3. Review: `./scripts/adw/WALKTHROUGH.md` (30 min) - Real example
4. Decide & approve

### "I'm at Phase 4 (Implementing) and stuck"
1. Quick ref: `./QUICK-REFERENCE.md` (5 min find pattern)
2. Pattern guide: `./PATTERN-GUIDE.md` (30 min deep dive)
3. Code recipe: `./KNOWLEDGE-BASE.md` (15 min find implementation recipe)
4. Troubleshoot: `./KNOWLEDGE-BASE.md` Troubleshooting section (10 min find solution)
5. Lessons: `./OBSERVATIONS.md` (15 min for similar issue)
6. Example code: `app/Services/` in Laravel project (reference)

### "I just completed migration, what next?"
1. Read: `./phases/PHASE-5-TEST-DOCUMENT.md` (20 min)
2. Run validation: `./scripts/adw/adw-validation.sh <MODULE>` (15 min)
3. Review results: Check validation report
4. Document: `./migrations-registry/successful/` entry (30 min)
5. Lessons: `./OBSERVATIONS.md` (add new findings)

### "I want to learn from past migrations"
1. Registry: `./migrations-registry/successful/` (all 5 migrations)
   - PPL (4.5h, 89/100) ← Start here (most complex)
   - GROUP (2.5h, 95/100)
   - ARUS_KAS (3.5h, 98/100)
   - PO (3.5h, 93/100)
   - PB (8h, 88/100)
2. Lessons: `./ai_docs/lessons/` (12 documents)
3. Observations: `./OBSERVATIONS.md` (full history)

### "I need implementation recipes & code templates"
1. Cookbook: `./KNOWLEDGE-BASE.md` (60 min read as reference)
   - Recipe 1: New CRUD Module Migration (20 min)
   - Recipe 2: Master-Detail Form Migration (20 min)
   - Recipe 3: Adding Authorization Workflow (20 min)
2. Code templates: `./KNOWLEDGE-BASE.md` Code Generation Templates section (copy & customize)
3. Real examples: `./migrations-registry/successful/` (reference actual implementations)

---

## 📊 File Structure Map

```
ADW (Scripts)
├── scripts/adw/
│   ├── README.md ✅ Links to skills/
│   ├── WALKTHROUGH.md ✅ Links to skills/
│   ├── adw-migration.sh
│   ├── adw-validation.sh
│   └── adw-review.sh

Skill Documentation
├── .claude/skills/delphi-migration/
│   ├── README.md ✅ Emphasizes ADW
│   ├── 00-README-START-HERE.md ✅ Links to ADW
│   ├── QUICK-REFERENCE.md ✅ ADW commands
│   ├── ADW-ARCHITECTURE.md ✅ System design
│   ├── PATTERN-GUIDE.md (patterns reference during analysis)
│   ├── KNOWLEDGE-BASE.md (recipes/templates reference during coding)
│   ├── SOP-DELPHI-MIGRATION.md (manual fallback workflow)
│   ├── INTEGRATION-MAP.md (this file - navigation guide)
│   ├── phases/ (Phase 0-5 guides)
│   │   ├── PHASE-0-DISCOVERY.md ✅ ADW section
│   │   ├── PHASE-1-ANALYZE.md ✅ ADW section
│   │   ├── PHASE-2-CHECK.md ✅ ADW section
│   │   ├── PHASE-3-PLAN.md ✅ ADW section
│   │   ├── PHASE-4-IMPLEMENT.md ✅ ADW section
│   │   └── PHASE-5-TEST-DOCUMENT.md ✅ ADW section
│   ├── migrations-registry/ (completed migrations)
│   │   └── successful/
│   │       ├── PPL.md
│   │       ├── GROUP.md
│   │       ├── ARUS_KAS.md
│   │       ├── PO.md
│   │       └── PB.md
│   ├── deprecated/ (archive - tools ACTIVE in tools/)
│   └── INTEGRATION-MAP.md ⭐ YOU ARE HERE

Commands
├── .claude/commands/
│   ├── delphi-laravel-migration.md ✅ Shows ADW
│   ├── delphi-laravel-migration-discovery.md ✅ Shows ADW
│   ├── delphi-laravel-migration-complexity-loader.md ✅ Shows ADW
│   ├── delphi-advise.md
│   └── delphi-retrospective.md

Main Documentation
├── CLAUDE.md ✅ Complete ADW section
└── README.md (project root)
```

---

## ✅ Integration Checklist

### Skill → ADW Links
- ✅ README.md mentions ADW
- ✅ 00-README-START-HERE.md points to scripts/adw/
- ✅ QUICK-REFERENCE.md shows ADW commands
- ✅ All 6 phase files have ADW automation sections
- ✅ ADW-ARCHITECTURE.md explains system

### ADW → Skill Links
- ✅ scripts/adw/README.md links to skill docs
- ✅ scripts/adw/WALKTHROUGH.md references skill docs
- ✅ adw-migration.sh mentions skill resources
- ✅ metrics.sh links to skill docs

### Commands → Both
- ✅ delphi-laravel-migration.md shows ADW first
- ✅ delphi-laravel-migration-discovery.md explains ADW
- ✅ delphi-laravel-migration-complexity-loader.md notes ADW usage

### Main Documentation
- ✅ CLAUDE.md has complete ADW + Skill sections
- ✅ All documentation consistent

---

## 🎯 Success Metrics

| Aspect | Target | Status |
|--------|--------|--------|
| Forward links (Skill→ADW) | 100% | ✅ Complete |
| Backward links (ADW→Skill) | 100% | ✅ Complete |
| Command integration | 100% | ✅ Complete |
| Phase documentation | 100% | ✅ Complete |
| User journey clarity | 100% | ✅ Clear |
| **Overall Integration** | 100% | ✅ **COMPLETE** |

---

## 📝 How to Use This Document

1. **Confused about flow?** → Scroll to "Starting Points"
2. **Need specific help?** → Use "Quick Lookup by Use Case"
3. **Want to understand structure?** → See "Detailed Navigation Map"
4. **Lost in docs?** → Check "File Structure Map"

---

**Last Updated**: 2026-01-12
**Maintained by**: Claude Code
**Integration Status**: ✅ 100% Complete
