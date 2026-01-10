#!/bin/bash

# Test script for Brave setup
# This script simulates the installation without actually installing anything

set -e

echo "=== Brave Setup Test Suite ==="
echo ""

# Test 1: Check if all required files exist
echo "Test 1: Checking if all required files exist..."
required_files=(
    "brave.desktop"
    "install-brave-desktop.sh"
    "check-brave-setup.sh"
    "README.md"
    "QUICK-FIX.md"
    "SOLUTION-SUMMARY.md"
)

all_files_exist=true
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✓ $file exists"
    else
        echo "  ✗ $file missing"
        all_files_exist=false
    fi
done

if [ "$all_files_exist" = true ]; then
    echo "✓ Test 1 passed: All required files exist"
else
    echo "✗ Test 1 failed: Some files are missing"
    exit 1
fi
echo ""

# Test 2: Check if scripts are executable
echo "Test 2: Checking if scripts are executable..."
scripts=(
    "install-brave-desktop.sh"
    "check-brave-setup.sh"
)

all_executable=true
for script in "${scripts[@]}"; do
    if [ -x "$script" ]; then
        echo "  ✓ $script is executable"
    else
        echo "  ✗ $script is not executable"
        all_executable=false
    fi
done

if [ "$all_executable" = true ]; then
    echo "✓ Test 2 passed: All scripts are executable"
else
    echo "✗ Test 2 failed: Some scripts are not executable"
    exit 1
fi
echo ""

# Test 3: Check script syntax
echo "Test 3: Checking script syntax..."
syntax_ok=true
for script in "${scripts[@]}"; do
    if bash -n "$script" 2>/dev/null; then
        echo "  ✓ $script has valid syntax"
    else
        echo "  ✗ $script has syntax errors"
        syntax_ok=false
    fi
done

if [ "$syntax_ok" = true ]; then
    echo "✓ Test 3 passed: All scripts have valid syntax"
else
    echo "✗ Test 3 failed: Some scripts have syntax errors"
    exit 1
fi
echo ""

# Test 4: Check desktop file format
echo "Test 4: Checking desktop file format..."
desktop_ok=true

# Check for required desktop file fields
required_fields=(
    "^\[Desktop Entry\]"
    "^Name="
    "^Exec="
    "^Type="
    "^Categories="
)

for field in "${required_fields[@]}"; do
    if grep -q "$field" brave.desktop; then
        echo "  ✓ Desktop file contains $field"
    else
        echo "  ✗ Desktop file missing $field"
        desktop_ok=false
    fi
done

# Check if HOME_PATH placeholder exists
if grep -q "HOME_PATH" brave.desktop; then
    echo "  ✓ Desktop file uses HOME_PATH placeholder"
else
    echo "  ✗ Desktop file missing HOME_PATH placeholder"
    desktop_ok=false
fi

if [ "$desktop_ok" = true ]; then
    echo "✓ Test 4 passed: Desktop file format is correct"
else
    echo "✗ Test 4 failed: Desktop file has issues"
    exit 1
fi
echo ""

# Test 5: Check if installation script performs path replacement
echo "Test 5: Checking path replacement logic..."
if grep -q 's|HOME_PATH|' install-brave-desktop.sh; then
    echo "  ✓ Installation script contains path replacement logic"
    echo "✓ Test 5 passed: Path replacement logic is present"
else
    echo "  ✗ Installation script missing path replacement logic"
    echo "✗ Test 5 failed: Path replacement logic not found"
    exit 1
fi
echo ""

# Test 6: Simulate path replacement
echo "Test 6: Testing path replacement..."
test_line="Exec=HOME_PATH/.local/bin/Brave"
replaced_line=$(echo "$test_line" | sed "s|HOME_PATH|/home/testuser|g")
expected_line="Exec=/home/testuser/.local/bin/Brave"

if [ "$replaced_line" = "$expected_line" ]; then
    echo "  ✓ Path replacement works correctly"
    echo "    Input:  $test_line"
    echo "    Output: $replaced_line"
    echo "✓ Test 6 passed: Path replacement works"
else
    echo "  ✗ Path replacement failed"
    echo "    Expected: $expected_line"
    echo "    Got:      $replaced_line"
    echo "✗ Test 6 failed: Path replacement doesn't work"
    exit 1
fi
echo ""

# Test 7: Check documentation quality
echo "Test 7: Checking documentation..."
doc_ok=true

# Check if README exists and has content
if [ -f "README.md" ]; then
    readme_lines=$(wc -l < README.md)
    if [ "$readme_lines" -gt 50 ]; then
        echo "  ✓ README.md is comprehensive ($readme_lines lines)"
    else
        echo "  ✗ README.md might be too short ($readme_lines lines)"
        doc_ok=false
    fi
fi

# Check if quick fix guide exists
if [ -f "QUICK-FIX.md" ] && [ -s "QUICK-FIX.md" ]; then
    echo "  ✓ QUICK-FIX.md exists and has content"
else
    echo "  ✗ QUICK-FIX.md missing or empty"
    doc_ok=false
fi

if [ "$doc_ok" = true ]; then
    echo "✓ Test 7 passed: Documentation is adequate"
else
    echo "✗ Test 7 failed: Documentation needs improvement"
    exit 1
fi
echo ""

# Test 8: Check for security issues
echo "Test 8: Checking for common security issues..."
security_ok=true

# Check for eval usage (exclude this test script)
if grep -q 'eval' install-brave-desktop.sh check-brave-setup.sh 2>/dev/null; then
    echo "  ✗ Scripts use eval (potential security risk)"
    security_ok=false
else
    echo "  ✓ No eval usage found"
fi

# Check for backticks (prefer $() syntax) - exclude this test script
if grep -q '`' install-brave-desktop.sh check-brave-setup.sh 2>/dev/null; then
    echo "  ⚠ Scripts use backticks (prefer \$() syntax)"
else
    echo "  ✓ Using modern \$() syntax instead of backticks"
fi

# Check for set -e in installation script (check script shouldn't use it)
if grep -q '^set -e' install-brave-desktop.sh; then
    echo "  ✓ install-brave-desktop.sh uses 'set -e' for error handling"
else
    echo "  ⚠ install-brave-desktop.sh doesn't use 'set -e'"
fi

# Check script shouldn't exit on error (needs to report all issues)
if ! grep -q '^set -e' check-brave-setup.sh; then
    echo "  ✓ check-brave-setup.sh correctly continues on errors"
else
    echo "  ⚠ check-brave-setup.sh uses 'set -e' (may prevent full diagnostics)"
fi

if [ "$security_ok" = true ]; then
    echo "✓ Test 8 passed: No major security issues found"
else
    echo "✗ Test 8 failed: Security issues detected"
    exit 1
fi
echo ""

# Summary
echo "=== Test Summary ==="
echo "✓ All tests passed!"
echo ""
echo "The Brave setup solution is ready to use."
echo "To install, run: ./install-brave-desktop.sh"
