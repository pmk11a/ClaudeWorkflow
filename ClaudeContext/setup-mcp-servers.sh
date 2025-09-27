#!/bin/bash
# MCP Servers Setup Script
# This script sets up Context7 and Playwright MCP servers for Claude Code

echo "🚀 Setting up MCP Servers for Claude Code"
echo "=========================================="

# Check Node.js version
echo "📋 Checking Node.js version..."
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18+ first."
    exit 1
fi

NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "❌ Node.js version must be 18 or higher. Current version: $(node --version)"
    exit 1
fi

echo "✅ Node.js version: $(node --version)"

# Check NPM
echo "📋 Checking NPM..."
if ! command -v npx &> /dev/null; then
    echo "❌ NPX is not available. Please install npm."
    exit 1
fi

echo "✅ NPM version: $(npm --version)"

# Test Context7 MCP Server
echo ""
echo "🔍 Testing Context7 MCP Server installation..."
if npx -y @upstash/context7-mcp@latest --help &> /dev/null; then
    echo "✅ Context7 MCP Server can be installed"
else
    echo "⚠️  Context7 MCP Server test failed, but will be downloaded on first use"
fi

# Test Playwright MCP Server
echo ""
echo "🔍 Testing Playwright MCP Server installation..."
if npx -y @playwright/mcp@latest --help &> /dev/null; then
    echo "✅ Playwright MCP Server can be installed"
else
    echo "⚠️  Playwright MCP Server test failed, but will be downloaded on first use"
fi

# Setup environment configuration
echo ""
echo "📝 Setting up environment configuration..."

if [ ! -f ".env.mcp" ]; then
    if [ -f ".env.mcp.example" ]; then
        cp .env.mcp.example .env.mcp
        echo "✅ Created .env.mcp from template"
        echo "⚠️  Please edit .env.mcp and add your Context7 API key"
    else
        echo "❌ .env.mcp.example not found"
    fi
else
    echo "✅ .env.mcp already exists"
fi

# Verify MCP configuration
echo ""
echo "🔧 Verifying MCP configuration..."

if [ -f ".claude/mcp.json" ]; then
    echo "✅ Found .claude/mcp.json"

    # Check if new servers are configured
    if grep -q "context7" .claude/mcp.json && grep -q "playwright" .claude/mcp.json; then
        echo "✅ Context7 and Playwright servers are configured"
    else
        echo "⚠️  Context7 or Playwright servers may not be configured properly"
    fi
else
    echo "❌ .claude/mcp.json not found"
fi

# Test existing simple server
echo ""
echo "🧪 Testing existing simple MCP server..."
if [ -f "mcp-simple/dist/index.js" ]; then
    echo "✅ Simple MCP server found"

    # Test if it responds
    if echo '{"jsonrpc": "2.0", "method": "tools/list", "id": 1}' | timeout 5 node mcp-simple/dist/index.js &> /dev/null; then
        echo "✅ Simple MCP server responds correctly"
    else
        echo "⚠️  Simple MCP server may have issues"
    fi
else
    echo "⚠️  Simple MCP server not found at mcp-simple/dist/index.js"
fi

echo ""
echo "🎉 MCP Servers Setup Complete!"
echo ""
echo "📋 Next Steps:"
echo "1. Edit .env.mcp with your Context7 API key"
echo "2. Source environment: source .env.mcp"
echo "3. Test MCP servers: claude mcp list"
echo "4. Use servers manually: source use-mcp.sh"
echo ""
echo "📚 Documentation:"
echo "- Context7: dokumentasi/claude/MCP_CONTEXT7_DOCUMENTATION.md"
echo "- Playwright: dokumentasi/claude/PLAYWRIGHT_MCP_DOCUMENTATION.md"
echo "- Manual usage: dokumentasi/claude/CARA_PAKAI_MCP_MANUAL.md"