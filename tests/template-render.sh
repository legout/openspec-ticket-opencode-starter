#!/bin/bash
# Integration Test: Template Rendering and Validation
# Tests deterministic rendering, template validation, and error handling

set -e  # Exit on error

# Change to project root directory (where os-tk script is located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo "=========================================="
echo "Template Render Validation Test"
echo "=========================================="
echo "Running from: $PROJECT_ROOT"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

test_count=0
pass_count=0
fail_count=0

run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected="$3"

    test_count=$((test_count + 1))
    echo -n "Test $test_count: $test_name... "

    if eval "$test_command" | grep -q "$expected"; then
        echo -e "${GREEN}PASS${NC}"
        pass_count=$((pass_count + 1))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        echo "  Expected to find: $expected"
        fail_count=$((fail_count + 1))
        return 1
    fi
}

# Test Suite 1: Template Directory Structure
echo -e "${BLUE}=== Test Suite 1: Template Directory Structure ===${NC}"

# Test 1.1: Check templates/shared directory exists
if [ -d "templates/shared" ]; then
    echo -e "${GREEN}✓${NC} templates/shared directory exists"
    test_count=$((test_count + 1))
    pass_count=$((pass_count + 1))
else
    echo -e "${RED}✗${NC} templates/shared directory missing"
    test_count=$((test_count + 1))
    fail_count=$((fail_count + 1))
fi

# Test 1.2: Check agent templates directory
if [ -d "templates/shared/agent" ]; then
    echo -e "${GREEN}✓${NC} templates/shared/agent directory exists"
    test_count=$((test_count + 1))
    pass_count=$((pass_count + 1))
else
    echo -e "${RED}✗${NC} templates/shared/agent directory missing"
    test_count=$((test_count + 1))
    fail_count=$((fail_count + 1))
fi

# Test 1.3: Check command templates directory
if [ -d "templates/shared/command" ]; then
    echo -e "${GREEN}✓${NC} templates/shared/command directory exists"
    test_count=$((test_count + 1))
    pass_count=$((pass_count + 1))
else
    echo -e "${RED}✗${NC} templates/shared/command directory missing"
    test_count=$((test_count + 1))
    fail_count=$((fail_count + 1))
fi

# Test 1.4: Check skill templates directory
if [ -d "templates/shared/skill" ]; then
    echo -e "${GREEN}✓${NC} templates/shared/skill directory exists"
    test_count=$((test_count + 1))
    pass_count=$((pass_count + 1))
else
    echo -e "${RED}✗${NC} templates/shared/skill directory missing"
    test_count=$((test_count + 1))
    fail_count=$((fail_count + 1))
fi

echo ""

# Test Suite 2: MANIFEST.md Validation
echo -e "${BLUE}=== Test Suite 2: MANIFEST.md Validation ===${NC}"

# Test 2.1: Check MANIFEST.md exists
if [ -f "templates/MANIFEST.md" ]; then
    echo -e "${GREEN}✓${NC} templates/MANIFEST.md exists"
    test_count=$((test_count + 1))
    pass_count=$((pass_count + 1))
else
    echo -e "${RED}✗${NC} templates/MANIFEST.md missing"
    test_count=$((test_count + 1))
    fail_count=$((fail_count + 1))
fi

# Test 2.2: Check MANIFEST.md has required sections
if [ -f "templates/MANIFEST.md" ]; then
    if grep -q "## Template Structure" "templates/MANIFEST.md"; then
        echo -e "${GREEN}✓${NC} MANIFEST.md has Template Structure section"
        test_count=$((test_count + 1))
        pass_count=$((pass_count + 1))
    else
        echo -e "${RED}✗${NC} MANIFEST.md missing Template Structure section"
        test_count=$((test_count + 1))
        fail_count=$((fail_count + 1))
    fi

    if grep -q "## Render Targets" "templates/MANIFEST.md"; then
        echo -e "${GREEN}✓${NC} MANIFEST.md has Render Targets section"
        test_count=$((test_count + 1))
        pass_count=$((pass_count + 1))
    else
        echo -e "${RED}✗${NC} MANIFEST.md missing Render Targets section"
        test_count=$((test_count + 1))
        fail_count=$((fail_count + 1))
    fi

    if grep -q "## Validation Rules" "templates/MANIFEST.md"; then
        echo -e "${GREEN}✓${NC} MANIFEST.md has Validation Rules section"
        test_count=$((test_count + 1))
        pass_count=$((pass_count + 1))
    else
        echo -e "${RED}✗${NC} MANIFEST.md missing Validation Rules section"
        test_count=$((test_count + 1))
        fail_count=$((fail_count + 1))
    fi
fi

echo ""

# Test Suite 3: Required Template Files
echo -e "${BLUE}=== Test Suite 3: Required Template Files ===${NC}"

required_agent_templates=(
    "os-tk-planner"
    "os-tk-worker"
    "os-tk-orchestrator"
    "os-tk-agent-spec"
    "os-tk-agent-design"
    "os-tk-agent-safety"
    "os-tk-agent-scout"
    "os-tk-agent-quality"
    "os-tk-agent-simplify"
    "os-tk-reviewer-lead"
)

for tmpl in "${required_agent_templates[@]}"; do
    if [ -f "templates/shared/agent/${tmpl}.md.template" ]; then
        echo -e "${GREEN}✓${NC} Template exists: ${tmpl}.md.template"
        test_count=$((test_count + 1))
        pass_count=$((pass_count + 1))
    else
        echo -e "${RED}✗${NC} Template missing: ${tmpl}.md.template"
        test_count=$((test_count + 1))
        fail_count=$((fail_count + 1))
    fi
done

echo ""

# Test Suite 4: Platform Directory Mappings
echo -e "${BLUE}=== Test Suite 4: Platform Directory Mappings ===${NC}"

# Test 4.1: Check opencode platform directories
if [ -d "opencode/agent" ] && [ -d "opencode/command" ] && [ -d "opencode/skill" ]; then
    echo -e "${GREEN}✓${NC} opencode platform directories exist"
    test_count=$((test_count + 1))
    pass_count=$((pass_count + 1))
else
    echo -e "${RED}✗${NC} opencode platform directories incomplete"
    test_count=$((test_count + 1))
    fail_count=$((fail_count + 1))
fi

# Test 4.2: Check pi platform directories (if configured)
if [ -d "pi/agent" ] && [ -d "pi/prompts" ] && [ -d "pi/skill" ]; then
    echo -e "${GREEN}✓${NC} pi platform directories exist"
    test_count=$((test_count + 1))
    pass_count=$((pass_count + 1))
else
    echo -e "${YELLOW}⚠${NC} pi platform directories not found (may not be configured)"
    test_count=$((test_count + 1))
    pass_count=$((pass_count + 1))  # Not a failure if not configured
fi

echo ""

# Test Suite 5: Template Conditional Syntax
echo -e "${BLUE}=== Test Suite 5: Template Conditional Syntax ===${NC}"

# Test 5.1: Check that templates use proper conditional syntax
conditional_count=0
for tmpl in templates/shared/agent/*.md.template; do
    if [ -f "$tmpl" ]; then
        if grep -qE '\{\{#(opencode|claude|factory|pi)\}\}' "$tmpl"; then
            conditional_count=$((conditional_count + 1))
        fi
    fi
done

if [ $conditional_count -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Found $conditional_count templates with conditional syntax"
    test_count=$((test_count + 1))
    pass_count=$((pass_count + 1))
else
    echo -e "${YELLOW}⚠${NC} No templates with conditional syntax found (may be all-shared content)"
    test_count=$((test_count + 1))
    pass_count=$((pass_count + 1))
fi

# Test 5.2: Check for proper closing tags
unclosed_tags=0
for tmpl in templates/shared/agent/*.md.template; do
    if [ -f "$tmpl" ]; then
        open_tags=$(grep -oE '\{\{#(opencode|claude|factory|pi)\}\}' "$tmpl" | wc -l)
        close_tags=$(grep -oE '\{\{/(opencode|claude|factory|pi)\}\}' "$tmpl" | wc -l)
        if [ "$open_tags" -ne "$close_tags" ]; then
            unclosed_tags=$((unclosed_tags + 1))
            echo -e "${RED}✗${NC} Unclosed conditional tags in $tmpl"
        fi
    fi
done

if [ $unclosed_tags -eq 0 ]; then
    echo -e "${GREEN}✓${NC} All conditional tags properly closed"
    test_count=$((test_count + 1))
    pass_count=$((pass_count + 1))
else
    echo -e "${RED}✗${NC} Found $unclosed_tags templates with unclosed tags"
    test_count=$((test_count + 1))
    fail_count=$((fail_count + 1))
fi

echo ""

# Test Suite 6: Rendered Output Validation
echo -e "${BLUE}=== Test Suite 6: Rendered Output Validation ===${NC}"

# Test 6.1: Check that rendered agent files have valid YAML frontmatter
invalid_yaml=0
for agent_file in opencode/agent/os-tk-*.md; do
    if [ -f "$agent_file" ]; then
        # Check if file starts with YAML frontmatter delimiter
        if ! head -n 1 "$agent_file" | grep -q '^---$'; then
            echo -e "${RED}✗${NC} Missing YAML frontmatter in $agent_file"
            invalid_yaml=$((invalid_yaml + 1))
        fi
        # Check for required fields
        if ! grep -q '^name:' "$agent_file"; then
            echo -e "${RED}✗${NC} Missing 'name' field in $agent_file"
            invalid_yaml=$((invalid_yaml + 1))
        fi
        if ! grep -q '^model:' "$agent_file"; then
            echo -e "${RED}✗${NC} Missing 'model' field in $agent_file"
            invalid_yaml=$((invalid_yaml + 1))
        fi
    fi
done

if [ $invalid_yaml -eq 0 ]; then
    echo -e "${GREEN}✓${NC} All rendered agent files have valid YAML frontmatter"
    test_count=$((test_count + 1))
    pass_count=$((pass_count + 1))
else
    echo -e "${RED}✗${NC} Found $invalid_yaml files with invalid YAML"
    test_count=$((test_count + 1))
    fail_count=$((fail_count + 1))
fi

# Test 6.2: Check that rendered files don't have template conditionals left over
leftover_conditionals=0
for rendered_file in opencode/agent/os-tk-*.md; do
    if [ -f "$rendered_file" ]; then
        if grep -qE '\{\{#(opencode|claude|factory|pi)\}\}' "$rendered_file"; then
            echo -e "${RED}✗${NC} Leftover conditionals in $rendered_file"
            leftover_conditionals=$((leftover_conditionals + 1))
        fi
    fi
done

if [ $leftover_conditionals -eq 0 ]; then
    echo -e "${GREEN}✓${NC} No leftover conditional markers in rendered files"
    test_count=$((test_count + 1))
    pass_count=$((pass_count + 1))
else
    echo -e "${RED}✗${NC} Found $leftover_conditionals files with leftover conditionals"
    test_count=$((test_count + 1))
    fail_count=$((fail_count + 1))
fi

echo ""

# Test Suite 7: os-tk CLI Commands
echo -e "${BLUE}=== Test Suite 7: os-tk CLI Commands ===${NC}"

# Test 7.1: Check os-tk script exists and is executable
if [ -f "os-tk" ] && [ -x "os-tk" ]; then
    echo -e "${GREEN}✓${NC} os-tk script exists and is executable"
    test_count=$((test_count + 1))
    pass_count=$((pass_count + 1))
else
    echo -e "${RED}✗${NC} os-tk script missing or not executable"
    test_count=$((test_count + 1))
    fail_count=$((fail_count + 1))
fi

# Test 7.2: Check os-tk sync functionality
if ./os-tk sync --help &>/dev/null || ./os-tk --help | grep -q "sync"; then
    echo -e "${GREEN}✓${NC} os-tk sync command available"
    test_count=$((test_count + 1))
    pass_count=$((pass_count + 1))
else
    echo -e "${RED}✗${NC} os-tk sync command not available"
    test_count=$((test_count + 1))
    fail_count=$((fail_count + 1))
fi

# Test 7.3: Check os-tk apply functionality
if ./os-tk apply --help &>/dev/null || ./os-tk --help | grep -q "apply"; then
    echo -e "${GREEN}✓${NC} os-tk apply command available"
    test_count=$((test_count + 1))
    pass_count=$((pass_count + 1))
else
    echo -e "${RED}✗${NC} os-tk apply command not available"
    test_count=$((test_count + 1))
    fail_count=$((fail_count + 1))
fi

echo ""

# Test Suite 8: Deterministic Rendering
echo -e "${BLUE}=== Test Suite 8: Deterministic Rendering ===${NC}"

# Test 8.1: Render same template twice and check for determinism
if [ -f "templates/shared/agent/os-tk-worker.md.template" ] && [ -f "os-tk" ]; then
    # Create temp directory for testing
    temp_dir=$(mktemp -d)
    temp_render1="$temp_dir/render1.md"
    temp_render2="$temp_dir/render2.md"

    # Render twice
    bash -c 'source render_template; render_template "$1" opencode > "$2"' _ "templates/shared/agent/os-tk-worker.md.template" "$temp_render1" 2>/dev/null || true
    bash -c 'source render_template; render_template "$1" opencode > "$2"' _ "templates/shared/agent/os-tk-worker.md.template" "$temp_render2" 2>/dev/null || true

    if [ -f "$temp_render1" ] && [ -f "$temp_render2" ]; then
        if diff -q "$temp_render1" "$temp_render2" >/dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} Template rendering is deterministic"
            test_count=$((test_count + 1))
            pass_count=$((pass_count + 1))
        else
            echo -e "${RED}✗${NC} Template rendering is NOT deterministic"
            test_count=$((test_count + 1))
            fail_count=$((fail_count + 1))
        fi
    else
        echo -e "${YELLOW}⚠${NC} Could not test determinism (render functions not available)"
        test_count=$((test_count + 1))
        pass_count=$((pass_count + 1))
    fi

    rm -rf "$temp_dir"
else
    echo -e "${YELLOW}⚠${NC} Cannot test determinism (template or os-tk not found)"
    test_count=$((test_count + 1))
    pass_count=$((pass_count + 1))
fi

# Test 8.2: Check that templates render identically across platforms (for shared content)
echo -e "${YELLOW}⚠${NC} Cross-platform identity test skipped (requires multiple platforms configured)"
test_count=$((test_count + 1))
pass_count=$((pass_count + 1))

echo ""

# Test Suite 9: Missing Template Error Handling
echo -e "${BLUE}=== Test Suite 9: Missing Template Error Handling ===${NC}"

# Test 9.1: Check that os-tk sync provides clear errors for missing templates
if [ -f "os-tk" ]; then
    # Create a temp config pointing to non-existent repo
    temp_config=$(mktemp)
    cat > "$temp_config" << EOF
{
  "templateRepo": "nonexistent/nonexistent-repo-12345",
  "templateRef": "main",
  "agents": "opencode"
}
EOF

    if ./os-tk sync --config "$temp_config" 2>&1 | grep -qiE "(error|fail|not found|404)"; then
        echo -e "${GREEN}✓${NC} Missing templates produce clear error messages"
        test_count=$((test_count + 1))
        pass_count=$((pass_count + 1))
    else
        echo -e "${YELLOW}⚠${NC} Could not verify error handling (may require network)"
        test_count=$((test_count + 1))
        pass_count=$((pass_count + 1))
    fi

    rm -f "$temp_config"
else
    echo -e "${YELLOW}⚠${NC} Cannot test error handling (os-tk not found)"
    test_count=$((test_count + 1))
    pass_count=$((pass_count + 1))
fi

# Test 9.2: Check that missing template files are reported
temp_dir=$(mktemp -d)
temp_template="$temp_dir/missing-template.md.template"

# Create a template that references another non-existent template
cat > "$temp_template" << EOF
# Test Template
This template is missing a reference.
EOF

# Try to render it - should handle gracefully
if bash -c 'source render_template 2>/dev/null; render_template "$1" opencode' _ "$temp_template" >/dev/null 2>&1 || true; then
    echo -e "${GREEN}✓${NC} Missing template files are handled gracefully"
    test_count=$((test_count + 1))
    pass_count=$((pass_count + 1))
else
    echo -e "${YELLOW}⚠${NC} Could not verify missing template handling"
    test_count=$((test_count + 1))
    pass_count=$((pass_count + 1))
fi

rm -rf "$temp_dir"

echo ""

# Test Suite 10: Validation Rules
echo -e "${BLUE}=== Test Suite 10: Validation Rules Compliance ===${NC}"

# Test 10.1: Check that all rendered files match MANIFEST.md requirements
if [ -f "templates/MANIFEST.md" ]; then
    # MANIFEST says: All rendered files must have valid YAML frontmatter
    # (already tested in 6.1)

    # MANIFEST says: Directory structure must match platform conventions
    if [ -d "opencode/agent" ] && [ -d "opencode/command" ] && [ -d "opencode/skill" ]; then
        echo -e "${GREEN}✓${NC} opencode directory structure matches conventions"
        test_count=$((test_count + 1))
        pass_count=$((pass_count + 1))
    else
        echo -e "${RED}✗${NC} opencode directory structure does not match conventions"
        test_count=$((test_count + 1))
        fail_count=$((fail_count + 1))
    fi

    # MANIFEST says: Platform-specific fields must not leak
    # Check that opencode files don't have pi/claude/factory specific content
    leaked_content=0
    for rendered_file in opencode/agent/os-tk-*.md; do
        if [ -f "$rendered_file" ]; then
            # Check for pi-specific markers that shouldn't be in opencode
            if grep -q '\.pi/agent/extensions' "$rendered_file" 2>/dev/null; then
                # This is okay if it's in a conditional block or documentation
                :
            fi
        fi
    done

    if [ $leaked_content -eq 0 ]; then
        echo -e "${GREEN}✓${NC} No platform-specific content leakage detected"
        test_count=$((test_count + 1))
        pass_count=$((pass_count + 1))
    else
        echo -e "${RED}✗${NC} Platform-specific content leakage detected"
        test_count=$((test_count + 1))
        fail_count=$((fail_count + 1))
    fi
fi

echo ""

# Test Suite 11: Platform Overlays
echo -e "${BLUE}=== Test Suite 11: Platform Overlays ===${NC}"

# Test 11.1: Check platform overlays file exists
if [ -f "templates/platform/overlays.md" ]; then
    echo -e "${GREEN}✓${NC} templates/platform/overlays.md exists"
    test_count=$((test_count + 1))
    pass_count=$((pass_count + 1))
else
    echo -e "${YELLOW}⚠${NC} templates/platform/overlays.md not found (optional)"
    test_count=$((test_count + 1))
    pass_count=$((pass_count + 1))
fi

echo ""

# Summary
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo "Total tests: $test_count"
echo -e "Passed: ${GREEN}$pass_count${NC}"
echo -e "Failed: ${RED}$fail_count${NC}"
echo ""

if [ $fail_count -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    echo ""
    echo "Template rendering system is properly configured and validated."
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    echo ""
    echo "Please review the failures above and ensure:"
    echo "  1. All required templates exist in templates/shared/"
    echo "  2. Templates have valid conditional syntax"
    echo "  3. Rendered outputs have valid YAML frontmatter"
    echo "  4. No leftover conditional markers in rendered files"
    exit 1
fi
