#!/bin/bash
# Claude CLI Skill Installation Script
# Delphi to Laravel Migration Skill

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║   Claude CLI Skill Installer                                  ║"
echo "║   Delphi to Laravel Migration                                 ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SKILL_NAME="delphi-migration"
SKILL_DIR="${HOME}/.claude/skills/${SKILL_NAME}"
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check Python version
echo -e "${BLUE}[1/5]${NC} Checking Python version..."
if ! command -v python3 &> /dev/null; then
    echo -e "${YELLOW}⚠️  Python 3 not found. Please install Python 3.7 or higher.${NC}"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
echo -e "${GREEN}✓${NC} Python ${PYTHON_VERSION} found"

# Check Claude CLI (optional)
echo -e "\n${BLUE}[2/5]${NC} Checking Claude CLI..."
if command -v claude &> /dev/null; then
    CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "unknown")
    echo -e "${GREEN}✓${NC} Claude CLI found (${CLAUDE_VERSION})"
    HAS_CLAUDE_CLI=true
else
    echo -e "${YELLOW}⚠️  Claude CLI not found (skill can still be used standalone)${NC}"
    HAS_CLAUDE_CLI=false
fi

# Create skill directory
echo -e "\n${BLUE}[3/5]${NC} Creating skill directory..."
mkdir -p "${SKILL_DIR}"
echo -e "${GREEN}✓${NC} Directory created: ${SKILL_DIR}"

# Copy files
echo -e "\n${BLUE}[4/5]${NC} Copying skill files..."

# Copy main files
cp "${CURRENT_DIR}/SKILL.md" "${SKILL_DIR}/"
cp "${CURRENT_DIR}/README.md" "${SKILL_DIR}/"
cp "${CURRENT_DIR}/USAGE_GUIDE.md" "${SKILL_DIR}/"
cp "${CURRENT_DIR}/delphi-migrate.py" "${SKILL_DIR}/"

# Copy parsers and generators
cp -r "${CURRENT_DIR}/parsers" "${SKILL_DIR}/"
cp -r "${CURRENT_DIR}/generators" "${SKILL_DIR}/"

# Make executable
chmod +x "${SKILL_DIR}/delphi-migrate.py"

echo -e "${GREEN}✓${NC} Files copied successfully"

# Verify installation
echo -e "\n${BLUE}[5/5]${NC} Verifying installation..."

REQUIRED_FILES=(
    "SKILL.md"
    "README.md"
    "USAGE_GUIDE.md"
    "delphi-migrate.py"
    "parsers/dfm_parser.py"
    "parsers/pas_parser.py"
    "generators/model_generator.py"
    "generators/controller_generator.py"
    "generators/view_generator.py"
)

ALL_GOOD=true
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "${SKILL_DIR}/${file}" ]; then
        echo -e "${GREEN}✓${NC} ${file}"
    else
        echo -e "${YELLOW}✗${NC} ${file} - MISSING"
        ALL_GOOD=false
    fi
done

# Create output directory
mkdir -p "${SKILL_DIR}/output"
echo -e "${GREEN}✓${NC} Output directory created"

# Summary
echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║   Installation Complete!                                      ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}✓ Skill installed to:${NC} ${SKILL_DIR}"
echo ""

# Usage instructions
if [ "$HAS_CLAUDE_CLI" = true ]; then
    echo "📖 Usage with Claude CLI:"
    echo ""
    echo "  # Parse Delphi file"
    echo "  claude \"Parse FrmBarang.dfm\""
    echo ""
    echo "  # Full migration"
    echo "  claude \"Migrate FrmBarang to Laravel\""
    echo ""
    echo "  # Analyze business logic"
    echo "  claude \"Show procedures in FrmBarang.pas\""
    echo ""
fi

echo "📖 Direct usage:"
echo ""
echo "  # Parse DFM file"
echo "  cd ${SKILL_DIR}"
echo "  python3 delphi-migrate.py parse-dfm /path/to/FrmBarang.dfm"
echo ""
echo "  # Full migration"
echo "  python3 delphi-migrate.py migrate /path/to/FrmBarang.dfm /path/to/FrmBarang.pas"
echo ""

# Test command
echo "🧪 Test installation:"
echo ""
echo "  cd ${SKILL_DIR}"
echo "  python3 delphi-migrate.py --help"
echo ""

# Documentation
echo "📚 Documentation:"
echo "  - README: ${SKILL_DIR}/README.md"
echo "  - Usage Guide: ${SKILL_DIR}/USAGE_GUIDE.md"
echo "  - Skill Definition: ${SKILL_DIR}/SKILL.md"
echo ""

# Next steps
echo "🚀 Next Steps:"
echo "  1. Read README.md for overview"
echo "  2. Check USAGE_GUIDE.md for examples"
echo "  3. Try: python3 delphi-migrate.py --help"
if [ "$HAS_CLAUDE_CLI" = true ]; then
    echo "  4. Use with Claude CLI for natural language commands"
fi
echo ""

echo "═══════════════════════════════════════════════════════════════"
echo "Ready to migrate! 🎉"
echo "═══════════════════════════════════════════════════════════════"
echo ""

exit 0
