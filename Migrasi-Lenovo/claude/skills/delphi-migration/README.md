# Delphi to Laravel Migration Skill

**🚀 START HERE**: [00-README-START-HERE.md](./00-README-START-HERE.md)

This is the authoritative onboarding guide for the Delphi migration skill. It contains:
- Quick start guide for new team members
- Complete documentation map
- Links to all resources
- **Primary method: ADW (AI Developer Workflows)**

## 🚀 Quick Start - Use ADW

**For all migrations, use:**
```bash
./scripts/adw/adw-migration.sh <MODULE>
```

Benefits:
- ⚡ 50-60% faster (4.5h vs 8-12h)
- ✅ 88-98/100 quality
- 🎯 Fully automated with approval gates
- 📊 Proven across 5+ successful migrations

See: [scripts/adw/README.md](../../scripts/adw/README.md)

## Quick Links

- **New to this skill?** → [00-README-START-HERE.md](./00-README-START-HERE.md)
- **Ready to migrate?** → Use ADW: `./scripts/adw/adw-migration.sh <MODULE>`
- **Need quick reference?** → [QUICK-REFERENCE.md](./QUICK-REFERENCE.md)
- **Looking for patterns?** → [PATTERN-GUIDE.md](./PATTERN-GUIDE.md)
- **Manual SOP (fallback)?** → [SOP-DELPHI-MIGRATION.md](./SOP-DELPHI-MIGRATION.md)

---

## 📂 Folder Structure

```
delphi-migration/
├── 00-README-START-HERE.md      # ⭐ Onboarding guide
├── QUICK-REFERENCE.md           # ⭐ Commands & quick lookup
├── ADW-ARCHITECTURE.md          # ADW system design
├── INTEGRATION-MAP.md           # 🆕 Skill ↔ ADW navigation guide
├── PATTERN-GUIDE.md             # All 8 migration patterns
├── SOP-DELPHI-MIGRATION.md     # Manual SOP (fallback)
├── OBSERVATIONS.md              # Lessons from past migrations
├── phases/                       # Phase 0-5 documentation
├── migrations-registry/          # Completed migration records
├── tools/                        # ⭐ ACTIVE Python migration tools
│   ├── delphi-migrate.py        # Main CLI (CURRENT - use this)
│   ├── parsers/                 # Enhanced DFM & PAS parsers
│   └── generators/              # Laravel code generators
├── deprecated/                   # Archive - Tools now ACTIVE in tools/ folder
│   ├── generators/              # History only (tools restored to tools/)
│   ├── parsers/                 # History only (tools restored to tools/)
│   ├── delphi-migrate.py        # History only (tools restored to tools/)
│   ├── install.sh               # History only (legacy setup)
│   └── DEPRECATION.md           # Restoration status & architecture
└── [other docs]
```

---

## 📚 Documentation Map

### Primary Resources (Use These)
1. **[ADW-ARCHITECTURE.md](./ADW-ARCHITECTURE.md)** - How ADW works
2. **[QUICK-REFERENCE.md](./QUICK-REFERENCE.md)** - All commands
3. **[scripts/adw/README.md](../../scripts/adw/README.md)** - ADW quick start
4. **[scripts/adw/WALKTHROUGH.md](../../scripts/adw/WALKTHROUGH.md)** - Real example

### Reference & Fallback
- **[SOP-DELPHI-MIGRATION.md](./SOP-DELPHI-MIGRATION.md)** - Manual workflow
- **[PATTERN-GUIDE.md](./PATTERN-GUIDE.md)** - All patterns explained
- **[OBSERVATIONS.md](./OBSERVATIONS.md)** - Lessons learned

### Archive & History
- **[deprecated/](./deprecated/)** - Historical reference (tools now in tools/ and ACTIVE)
  - See [deprecated/DEPRECATION.md](./deprecated/DEPRECATION.md) for restoration status

---

For the complete navigation map and detailed documentation, see [00-README-START-HERE.md](./00-README-START-HERE.md).
