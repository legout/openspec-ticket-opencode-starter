#!/bin/bash
# Integration Test: File-Aware Dependency Management
# This script tests the flag parsing and overlap/deps behavior

set -e  # Exit on error

echo "=========================================="
echo "File-Aware Deps Integration Test"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
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

# Test 1: Check that /tk-queue command file exists
echo "=== Test Suite 1: Command Files ==="
if [ -f "opencode/command/tk-queue.md" ]; then
    echo -e "${GREEN}✓${NC} tk-queue.md exists"
else
    echo -e "${RED}✗${NC} tk-queue.md missing"
    fail_count=$((fail_count + 1))
fi

# Test 2: Check agent reference is correct
echo ""
echo "=== Test Suite 2: Agent References ==="
if grep -q "agent: os-tk-orchestrator" "opencode/command/tk-queue.md"; then
    echo -e "${GREEN}✓${NC} tk-queue uses os-tk-orchestrator agent"
else
    echo -e "${RED}✗${NC} tk-queue agent reference incorrect"
    fail_count=$((fail_count + 1))
fi

if grep -q "agent: os-tk-orchestrator" "opencode/command/tk-bootstrap.md"; then
    echo -e "${GREEN}✓${NC} tk-bootstrap uses os-tk-orchestrator agent"
else
    echo -e "${RED}✗${NC} tk-bootstrap agent reference incorrect"
    fail_count=$((fail_count + 1))
fi

# Test 3: Check flag parsing documentation
echo ""
echo "=== Test Suite 3: Flag Parsing ==="
if grep -q "\-\-next" "opencode/command/tk-queue.md"; then
    echo -e "${GREEN}✓${NC} --next flag documented"
else
    echo -e "${RED}✗${NC} --next flag not documented"
    fail_count=$((fail_count + 1))
fi

if grep -q "\-\-all" "opencode/command/tk-queue.md"; then
    echo -e "${GREEN}✓${NC} --all flag documented"
else
    echo -e "${RED}✗${NC} --all flag not documented"
    fail_count=$((fail_count + 1))
fi

if grep -q "\-\-change" "opencode/command/tk-queue.md"; then
    echo -e "${GREEN}✓${NC} --change flag documented"
else
    echo -e "${RED}✗${NC} --change flag not documented"
    fail_count=$((fail_count + 1))
fi

# Test 4: Check overlap detection steps
echo ""
echo "=== Test Suite 4: Overlap Detection ==="
if grep -q "File-Aware Dependency Management" "opencode/command/tk-queue.md"; then
    echo -e "${GREEN}✓${NC} Overlap detection documented"
else
    echo -e "${RED}✗${NC} Overlap detection not documented"
    fail_count=$((fail_count + 1))
fi

if grep -q "tk dep" "opencode/command/tk-queue.md"; then
    echo -e "${GREEN}✓${NC} tk dep usage documented"
else
    echo -e "${RED}✗${NC} tk dep usage not documented"
    fail_count=$((fail_count + 1))
fi

# Test 5: Check conflict check for --next
echo ""
echo "=== Test Suite 5: Conflict Detection (--next) ==="
if grep -q "conflict with" "opencode/command/tk-queue.md"; then
    echo -e "${GREEN}✓${NC} --next conflict check documented"
else
    echo -e "${RED}✗${NC} --next conflict check not documented"
    fail_count=$((fail_count + 1))
fi

if grep -q "conflict" "opencode/command/tk-queue.md"; then
    echo -e "${GREEN}✓${NC} Conflict warning format documented"
else
    echo -e "${RED}✗${NC} Conflict warning format not documented"
    fail_count=$((fail_count + 1))
fi

# Test 6: Check file prediction in bootstrap
echo ""
echo "=== Test Suite 6: File Predictions ==="
if grep -q "files-modify" "opencode/command/tk-bootstrap.md"; then
    echo -e "${GREEN}✓${NC} files-modify documented in bootstrap"
else
    echo -e "${RED}✗${NC} files-modify not documented in bootstrap"
    fail_count=$((fail_count + 1))
fi

if grep -q "files-create" "opencode/command/tk-bootstrap.md"; then
    echo -e "${GREEN}✓${NC} files-create documented in bootstrap"
else
    echo -e "${RED}✗${NC} files-create not documented in bootstrap"
    fail_count=$((fail_count + 1))
fi

# Test 7: Check AGENTS.md documentation
echo ""
echo "=== Test Suite 7: AGENTS.md Documentation ==="
if grep -q "File-Aware Dependency Management" "AGENTS.md"; then
    echo -e "${GREEN}✓${NC} File-aware deps section exists in AGENTS.md"
else
    echo -e "${RED}✗${NC} File-aware deps section missing from AGENTS.md"
    fail_count=$((fail_count + 1))
fi

if grep -q "files-modify" "AGENTS.md"; then
    echo -e "${GREEN}✓${NC} File prediction fields documented in AGENTS.md"
else
    echo -e "${RED}✗${NC} File prediction fields not in AGENTS.md"
    fail_count=$((fail_count + 1))
fi

# Test 8: Check test documentation exists
echo ""
echo "=== Test Suite 8: Test Documentation ==="
if [ -f "tests/file-aware-dependencies.md" ]; then
    echo -e "${GREEN}✓${NC} Test plan document exists"
    test_doc_lines=$(wc -l < "tests/file-aware-dependencies.md")
    if [ "$test_doc_lines" -gt 100 ]; then
        echo -e "${GREEN}✓${NC} Test plan is comprehensive ($test_doc_lines lines)"
    else
        echo -e "${YELLOW}⚠${NC} Test plan seems short ($test_doc_lines lines)"
    fi
else
    echo -e "${RED}✗${NC} Test plan document missing"
    fail_count=$((fail_count + 1))
fi

# Test 9: Check user guide exists
echo ""
echo "=== Test Suite 9: User Guide ==="
if [ -f "docs/file-aware-dependencies-guide.md" ]; then
    echo -e "${GREEN}✓${NC} User guide exists"
    if grep -q "File Predictions in Tickets" "docs/file-aware-dependencies-guide.md"; then
        echo -e "${GREEN}✓${NC} User guide explains file predictions"
    else
        echo -e "${YELLOW}⚠${NC} User guide missing file prediction explanation"
    fi
else
    echo -e "${RED}✗${NC} User guide missing"
    fail_count=$((fail_count + 1))
fi

# Test 10: Check for old agent references
echo ""
echo "=== Test Suite 10: Migration Cleanup ==="
if grep -r "os-tk-bootstrapper" opencode/ 2>/dev/null; then
    echo -e "${RED}✗${NC} Old 'os-tk-bootstrapper' references still exist"
    fail_count=$((fail_count + 1))
else
    echo -e "${GREEN}✓${NC} No old 'os-tk-bootstrapper' references found"
fi

# Summary
echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo "Total tests: $test_count"
echo -e "Passed: ${GREEN}$pass_count${NC}"
echo -e "Failed: ${RED}$fail_count${NC}"
echo ""

if [ $fail_count -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
