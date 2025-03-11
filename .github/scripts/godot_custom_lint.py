#!/usr/bin/env python3
"""
Custom linting script for ForageWithMe Godot project.
Checks for adherence to project coding standards beyond what gdlint provides.
"""

import os
import re
import sys
from pathlib import Path

SCRIPT_STRUCTURE_ORDER = [
    r"(class_name|tool)",                       # Class/tool declarations
    r"(enum|const)",                            # Enums and constants
    r"export",                                  # Exported variables
    r"var [a-z][a-z0-9_]* = ",                 # Public variables
    r"var _[a-z][a-z0-9_]* = ",                # Private variables
    r"@onready var|onready var",                # Onready variables
    r"func (_ready|_process|_physics_process)", # Built-in virtual methods
    r"func [a-z][a-z0-9_]*\(",                 # Public methods
    r"func _[a-z][a-z0-9_]*\(",                # Private methods
    r"func _on_[a-z][a-z0-9_]*\("              # Signal callbacks
]

def check_naming_conventions(file_path, content):
    """Check if the file adheres to naming conventions."""
    issues = []
    
    # Check class names (PascalCase)
    class_matches = re.finditer(r"class_name\s+([A-Za-z0-9_]+)", content)
    for match in class_matches:
        class_name = match.group(1)
        if not re.match(r"^[A-Z][a-zA-Z0-9]*$", class_name):
            issues.append(f"Class name '{class_name}' should be in PascalCase")
    
    # Check variable names (snake_case)
    var_matches = re.finditer(r"var\s+([A-Za-z0-9_]+)", content)
    for match in var_matches:
        var_name = match.group(1)
        if var_name.startswith("_"):  # Private variable
            var_name = var_name[1:]  # Remove leading underscore for checking
        
        # Skip if it's a constant (checked separately)
        if re.match(r"^[A-Z][A-Z0-9_]*$", var_name):
            continue
            
        if not re.match(r"^[a-z][a-z0-9_]*$", var_name):
            issues.append(f"Variable name '{var_name}' should be in snake_case")
    
    # Check constants (UPPER_SNAKE_CASE)
    const_matches = re.finditer(r"const\s+([A-Za-z0-9_]+)", content)
    for match in const_matches:
        const_name = match.group(1)
        if not re.match(r"^[A-Z][A-Z0-9_]*$", const_name):
            issues.append(f"Constant '{const_name}' should be in UPPER_SNAKE_CASE")
    
    # Check function names (snake_case)
    func_matches = re.finditer(r"func\s+([A-Za-z0-9_]+)", content)
    for match in func_matches:
        func_name = match.group(1)
        if func_name.startswith("_"):  # Private or built-in function
            func_name = func_name[1:]  # Remove leading underscore for checking
        
        if not re.match(r"^[a-z][a-z0-9_]*$", func_name):
            issues.append(f"Function name '{func_name}' should be in snake_case")
    
    # Check signal names (snake_case)
    signal_matches = re.finditer(r"signal\s+([A-Za-z0-9_]+)", content)
    for match in signal_matches:
        signal_name = match.group(1)
        if not re.match(r"^[a-z][a-z0-9_]*$", signal_name):
            issues.append(f"Signal name '{signal_name}' should be in snake_case")
    
    # Check enum values (UPPER_SNAKE_CASE)
    enum_blocks = re.finditer(r"enum\s+[A-Za-z0-9_]*\s*{([^}]*)}", content)
    for block in enum_blocks:
        enum_content = block.group(1)
        enum_values = re.finditer(r"([A-Za-z0-9_]+)", enum_content)
        for value in enum_values:
            enum_value = value.group(1)
            if not re.match(r"^[A-Z][A-Z0-9_]*$", enum_value):
                issues.append(f"Enum value '{enum_value}' should be in UPPER_SNAKE_CASE")
    
    return issues

def check_code_formatting(file_path, content):
    """Check if the file adheres to code formatting standards."""
    issues = []
    
    # Check line length
    lines = content.split("\n")
    for i, line in enumerate(lines):
        if len(line) > 100:
            issues.append(f"Line {i+1} exceeds 100 characters (length: {len(line)})")
    
    # Check indentation (4 spaces)
    indent_pattern = re.compile(r"^(\t+)")
    for i, line in enumerate(lines):
        if indent_pattern.match(line):
            issues.append(f"Line {i+1} uses tabs instead of 4 spaces for indentation")
    
    # Check empty lines between functions
    func_pattern = re.compile(r"^func\s+")
    for i in range(len(lines) - 1):
        if func_pattern.match(lines[i]) and i > 0:
            if lines[i-1].strip() != "":
                issues.append(f"Missing empty line before function definition at line {i+1}")
    
    return issues

def check_script_structure(file_path, content):
    """
    Check if the script follows the required structure order:
    1. Class/tool declarations
    2. Enums and constants
    3. Exported variables
    4. Public variables
    5. Private variables
    6. Onready variables
    7. Built-in virtual methods
    8. Public methods
    9. Private methods
    10. Signal callbacks
    """
    issues = []
    
    # This is a simplified approach - a more robust implementation would
    # build a complete structure map of the file and verify ordering
    
    lines = content.split("\n")
    section_positions = {}
    
    for i, line in enumerate(lines):
        for section_idx, pattern in enumerate(SCRIPT_STRUCTURE_ORDER):
            if re.search(pattern, line):
                if section_idx not in section_positions:
                    section_positions[section_idx] = i
    
    # Check if sections appear in the wrong order
    for i in range(len(SCRIPT_STRUCTURE_ORDER) - 1):
        if i in section_positions and i + 1 in section_positions:
            if section_positions[i] > section_positions[i + 1]:
                issues.append(f"Improper script structure: {SCRIPT_STRUCTURE_ORDER[i+1]} appears before {SCRIPT_STRUCTURE_ORDER[i]}")
    
    return issues

def check_file(file_path):
    """Run all checks on a single file."""
    if not os.path.exists(file_path):
        print(f"Error: File {file_path} not found")
        return 1
    
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()
    
    issues = []
    issues.extend(check_naming_conventions(file_path, content))
    issues.extend(check_code_formatting(file_path, content))
    issues.extend(check_script_structure(file_path, content))
    
    if issues:
        print(f"\nIssues in {file_path}:")
        for issue in issues:
            print(f"  - {issue}")
        return 1
    
    return 0

def scan_directory(directory):
    """Scan a directory for GDScript files and check them."""
    error_count = 0
    gd_files = list(Path(directory).rglob("*.gd"))
    
    print(f"Scanning {len(gd_files)} GDScript files in {directory}")
    
    for file_path in gd_files:
        error_count += check_file(str(file_path))
    
    return error_count

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python godot_custom_lint.py <directory_or_file>")
        sys.exit(1)
    
    target = sys.argv[1]
    errors = 0
    
    if os.path.isdir(target):
        errors = scan_directory(target)
    else:
        errors = check_file(target)
    
    if errors:
        print(f"\nFound {errors} linting issues")
        sys.exit(1)
    else:
        print("No linting issues found")
        sys.exit(0)
