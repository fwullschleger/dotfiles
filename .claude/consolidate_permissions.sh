#!/bin/bash

# Script to consolidate permission settings from settings.local.json files
# Usage: ./consolidate_permissions.sh [path_to_workspaces]

WORKSPACE_DIR="${1:-$HOME/workspaces}"
TEMP_FILE=$(mktemp)

echo "=========================================="
echo "Permission Settings Consolidation"
echo "=========================================="
echo "Searching in: $WORKSPACE_DIR"
echo ""

# Check if directory exists
if [ ! -d "$WORKSPACE_DIR" ]; then
    echo "Error: Directory '$WORKSPACE_DIR' does not exist"
    exit 1
fi

# Find all settings.local.json files
FILES=$(find "$WORKSPACE_DIR" -name "settings.local.json" -type f 2>/dev/null)

if [ -z "$FILES" ]; then
    echo "No settings.local.json files found in $WORKSPACE_DIR"
    exit 0
fi

# Count files
FILE_COUNT=$(echo "$FILES" | wc -l)
echo "Found $FILE_COUNT settings.local.json file(s)"
echo ""
echo "=========================================="
echo ""

# Process each file
while IFS= read -r file; do
    PROJECT_NAME=$(dirname "$file" | sed "s|$WORKSPACE_DIR/||g")
    
    echo "Project: $PROJECT_NAME"
    echo "File: $file"
    echo ""
    
    # Check if file is valid JSON
    if ! jq empty "$file" 2>/dev/null; then
        echo "  ⚠️  Invalid JSON in this file"
        echo ""
        echo "----------------------------------------"
        echo ""
        continue
    fi
    
    # Extract permission-related keys (common patterns)
    # Adjust these patterns based on your actual JSON structure
    PERMISSIONS=$(jq -r '
        paths(scalars) as $p |
        select($p | tostring | test("permission|Permission|auth|Auth|role|Role|access|Access|grant|Grant"; "i")) |
        {path: $p, value: getpath($p)} |
        "  " + ($path | join(".")) + " = " + ($value | tostring)
    ' "$file" 2>/dev/null)
    
    if [ -z "$PERMISSIONS" ]; then
        echo "  No permission settings found (searched for: permission, auth, role, access, grant)"
    else
        echo "  Permission Settings:"
        echo "$PERMISSIONS"
    fi
    
    echo ""
    echo "  Full content preview:"
    jq '.' "$file" 2>/dev/null | head -20
    
    echo ""
    echo "----------------------------------------"
    echo ""
    
    # Collect all permission settings to temp file for consolidation
    jq -r '
        paths(scalars) as $p |
        select($p | tostring | test("permission|Permission|auth|Auth|role|Role|access|Access|grant|Grant"; "i")) |
        {path: ($p | join(".")), value: getpath($p)} |
        @json
    ' "$file" 2>/dev/null >> "$TEMP_FILE"
    
done <<< "$FILES"

echo ""
echo "=========================================="
echo "ALL UNIQUE PERMISSIONS (Consolidated)"
echo "=========================================="
echo ""

# Create consolidated JSON with all unique permissions
if [ -s "$TEMP_FILE" ]; then
    # First, let's check if we're dealing with array-based permissions
    CONSOLIDATED=$(jq -s '
        # Collect all permission values
        map(select(.path | startswith("permissions.allow"))) |
        map(.value) |
        flatten |
        unique |
        sort |
        {
            "permissions": {
                "allow": .
            }
        }
    ' "$TEMP_FILE" 2>/dev/null)
    
    if [ -n "$CONSOLIDATED" ] && [ "$CONSOLIDATED" != '{"permissions":{"allow":[]}}' ]; then
        echo "Copy the following into your global settings file:"
        echo ""
        echo "╔════════════════════════════════════════╗"
        echo "║    CONSOLIDATED PERMISSIONS            ║"
        echo "╚════════════════════════════════════════╝"
        echo ""
        echo "$CONSOLIDATED" | jq '.'
        echo ""
        echo "=========================================="
        echo ""
        
        # Show count and summary
        PERM_COUNT=$(echo "$CONSOLIDATED" | jq '.permissions.allow | length')
        echo "Total unique permissions: $PERM_COUNT"
        echo ""
        echo "List of permissions:"
        echo "$CONSOLIDATED" | jq -r '.permissions.allow[]' | nl -w3 -s'   │     '
    else
        echo "No permission settings found in 'permissions.allow' arrays."
        echo ""
        echo "Attempting to consolidate all permission-related fields..."
        echo ""
        
        # Fallback: show all permission-related fields
        CONSOLIDATED_ALL=$(jq -s '
            group_by(.path) |
            map({
                path: .[0].path,
                values: map(.value) | unique
            }) |
            reduce .[] as $item (
                {};
                . as $result |
                ($item.path | split(".")) as $keys |
                (if ($item.values | length) == 1 then $item.values[0] else $item.values end) as $value |
                setpath($keys; $value)
            )
        ' "$TEMP_FILE" 2>/dev/null)
        
        echo "$CONSOLIDATED_ALL" | jq '.'
        echo ""
        echo "Flat list of all unique permission paths and values:"
        echo ""
        jq -s '
            group_by(.path) |
            map({
                path: .[0].path,
                values: map(.value) | unique
            }) |
            .[] |
            if (.values | length) == 1 then
                .path + " = " + (.values[0] | tostring)
            else
                .path + " = " + (.values | tostring)
            end
        ' "$TEMP_FILE" 2>/dev/null | jq -r '.'
    fi
else
    echo "No permission settings found across all files."
fi

# Cleanup
rm -f "$TEMP_FILE"

echo ""
echo "=========================================="
echo "Summary Complete"
echo "=========================================="
