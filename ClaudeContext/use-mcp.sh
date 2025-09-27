#!/bin/bash
# Manual MCP Server Usage Script

echo "🔧 Manual MCP Server Usage"
echo "=========================="

function mcp_read_claude() {
    echo "📋 Reading CLAUDE.md via MCP Simple..."
    echo '{"jsonrpc": "2.0", "method": "tools/call", "params": {"name": "read_claude_md", "arguments": {}}, "id": 1}' | node mcp-simple/dist/index.js 2>/dev/null | jq -r '.result.content[0].text' 2>/dev/null || echo "Error reading CLAUDE.md"
}

function mcp_read_session() {
    echo "🔄 Reading session state via MCP Simple..."
    echo '{"jsonrpc": "2.0", "method": "tools/call", "params": {"name": "read_session_state", "arguments": {}}, "id": 2}' | node mcp-simple/dist/index.js 2>/dev/null | jq -r '.result.content[0].text' 2>/dev/null || echo "Error reading session state"
}

function mcp_quick_context() {
    echo "⚡ Quick context via MCP Simple..."
    echo '{"jsonrpc": "2.0", "method": "tools/call", "params": {"name": "get_quick_context", "arguments": {}}, "id": 3}' | node mcp-simple/dist/index.js 2>/dev/null | jq -r '.result.content[0].text' 2>/dev/null || echo "Error getting quick context"
}

function mcp_list_tools() {
    echo "🛠️ Available tools in MCP Simple..."
    echo '{"jsonrpc": "2.0", "method": "tools/list", "id": 4}' | node mcp-simple/dist/index.js 2>/dev/null | jq -r '.result.tools[].name' 2>/dev/null || echo "Error listing tools"
}

# Context7 MCP Functions
function context7_list_tools() {
    echo "🌐 Available tools in Context7 MCP..."
    echo '{"jsonrpc": "2.0", "method": "tools/list", "id": 1}' | npx -y @upstash/context7-mcp@latest 2>/dev/null | jq -r '.result.tools[].name' 2>/dev/null || echo "Error: Check CONTEXT7_API_KEY"
}

function context7_create_context() {
    local title="$1"
    local content="$2"
    echo "📝 Creating context in Context7: '$title'..."

    if [ -z "$CONTEXT7_API_KEY" ]; then
        echo "❌ Error: CONTEXT7_API_KEY not set. Run: export CONTEXT7_API_KEY='your_key'"
        return 1
    fi

    echo "{\"jsonrpc\": \"2.0\", \"method\": \"tools/call\", \"params\": {\"name\": \"create_context\", \"arguments\": {\"title\": \"$title\", \"content\": \"$content\"}}, \"id\": 2}" | CONTEXT7_API_KEY="$CONTEXT7_API_KEY" npx -y @upstash/context7-mcp@latest 2>/dev/null | jq -r '.result.content[0].text' 2>/dev/null || echo "Error creating context"
}

function context7_search() {
    local query="$1"
    echo "🔍 Searching Context7 for: '$query'..."

    if [ -z "$CONTEXT7_API_KEY" ]; then
        echo "❌ Error: CONTEXT7_API_KEY not set"
        return 1
    fi

    echo "{\"jsonrpc\": \"2.0\", \"method\": \"tools/call\", \"params\": {\"name\": \"search\", \"arguments\": {\"query\": \"$query\"}}, \"id\": 3}" | CONTEXT7_API_KEY="$CONTEXT7_API_KEY" npx -y @upstash/context7-mcp@latest 2>/dev/null | jq -r '.result.content[0].text' 2>/dev/null || echo "Error searching"
}

# Playwright MCP Functions
function playwright_list_tools() {
    echo "🎭 Available tools in Playwright MCP..."
    echo '{"jsonrpc": "2.0", "method": "tools/list", "id": 1}' | npx -y @playwright/mcp@latest 2>/dev/null | jq -r '.result.tools[].name' 2>/dev/null || echo "Error listing Playwright tools"
}

function playwright_navigate() {
    local url="$1"
    echo "🌐 Navigating to: $url..."
    echo "{\"jsonrpc\": \"2.0\", \"method\": \"tools/call\", \"params\": {\"name\": \"navigate\", \"arguments\": {\"url\": \"$url\"}}, \"id\": 2}" | npx -y @playwright/mcp@latest 2>/dev/null | jq -r '.result.content[0].text' 2>/dev/null || echo "Error navigating"
}

function playwright_screenshot() {
    local filename="${1:-screenshot.png}"
    echo "📸 Taking screenshot: $filename..."
    echo "{\"jsonrpc\": \"2.0\", \"method\": \"tools/call\", \"params\": {\"name\": \"screenshot\", \"arguments\": {\"path\": \"$filename\"}}, \"id\": 3}" | npx -y @playwright/mcp@latest 2>/dev/null | jq -r '.result.content[0].text' 2>/dev/null || echo "Error taking screenshot"
}

function playwright_click() {
    local selector="$1"
    echo "👆 Clicking element: $selector..."
    echo "{\"jsonrpc\": \"2.0\", \"method\": \"tools/call\", \"params\": {\"name\": \"click\", \"arguments\": {\"selector\": \"$selector\"}}, \"id\": 4}" | npx -y @playwright/mcp@latest 2>/dev/null | jq -r '.result.content[0].text' 2>/dev/null || echo "Error clicking"
}

function playwright_fill() {
    local selector="$1"
    local value="$2"
    echo "✏️ Filling '$selector' with: $value..."
    echo "{\"jsonrpc\": \"2.0\", \"method\": \"tools/call\", \"params\": {\"name\": \"fill\", \"arguments\": {\"selector\": \"$selector\", \"value\": \"$value\"}}, \"id\": 5}" | npx -y @playwright/mcp@latest 2>/dev/null | jq -r '.result.content[0].text' 2>/dev/null || echo "Error filling form"
}

function playwright_test_login() {
    local username="$1"
    local password="$2"
    echo "🔐 Testing login workflow..."

    # Navigate to login page
    playwright_navigate "http://localhost:5173/login"
    sleep 2

    # Fill login form
    playwright_fill "input[name='username']" "$username"
    playwright_fill "input[name='password']" "$password"

    # Click submit
    playwright_click "button[type='submit']"

    # Take screenshot
    playwright_screenshot "login-test.png"

    echo "✅ Login test completed. Check login-test.png for results."
}

# Combined workflow functions
function mcp_full_test() {
    echo "🧪 Running full MCP servers test..."
    echo ""

    echo "1. Testing Simple MCP..."
    mcp_list_tools
    echo ""

    echo "2. Testing Context7 MCP..."
    context7_list_tools
    echo ""

    echo "3. Testing Playwright MCP..."
    playwright_list_tools
    echo ""

    echo "✅ Full MCP test completed!"
}

function mcp_demo_workflow() {
    echo "🎯 Running MCP demo workflow..."
    echo ""

    # Read project context
    echo "📋 Reading project context..."
    mcp_read_claude
    echo ""

    # Create context in Context7 (if API key available)
    if [ -n "$CONTEXT7_API_KEY" ]; then
        echo "📝 Creating context in Context7..."
        context7_create_context "MCP Demo" "Testing MCP integration with Laravel project"
        echo ""
    fi

    # Test React frontend (if running)
    echo "🎭 Testing React frontend..."
    playwright_navigate "http://localhost:5173"
    playwright_screenshot "frontend-demo.png"
    echo ""

    echo "✅ Demo workflow completed!"
}

# Show usage
echo "Available functions:"
echo ""
echo "📋 Simple MCP Functions:"
echo "  mcp_read_claude       - Read CLAUDE.md"
echo "  mcp_read_session      - Read session state"
echo "  mcp_quick_context     - Get quick context"
echo "  mcp_list_tools        - List available tools"
echo ""
echo "🌐 Context7 MCP Functions (requires API key):"
echo "  context7_list_tools             - List Context7 tools"
echo "  context7_create_context 'title' 'content' - Create context"
echo "  context7_search 'query'         - Search contexts"
echo ""
echo "🎭 Playwright MCP Functions:"
echo "  playwright_list_tools           - List Playwright tools"
echo "  playwright_navigate 'url'       - Navigate to URL"
echo "  playwright_screenshot 'file'    - Take screenshot"
echo "  playwright_click 'selector'     - Click element"
echo "  playwright_fill 'selector' 'value' - Fill form field"
echo "  playwright_test_login 'user' 'pass' - Test login workflow"
echo ""
echo "🧪 Combined Functions:"
echo "  mcp_full_test        - Test all MCP servers"
echo "  mcp_demo_workflow    - Run demo workflow"
echo ""
echo "Usage examples:"
echo "  source use-mcp.sh && mcp_read_claude"
echo "  source use-mcp.sh && mcp_full_test"
echo "  export CONTEXT7_API_KEY='your_key' && context7_search 'laravel'"
echo "  playwright_test_login 'admin' 'password'"

# If called with argument, execute function
if [ "$1" != "" ]; then
    $1
fi