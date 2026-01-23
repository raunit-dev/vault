#!/bin/bash

set -e

# Script to rename the project from exo-anchor-template to a new name
# Usage: ./scripts/rename-project.sh <new-name-in-kebab-case>
# Example: ./scripts/rename-project.sh my-awesome-program

if [ -z "$1" ]; then
    echo "Usage: $0 <new-name-in-kebab-case>"
    echo "Example: $0 my-awesome-program"
    exit 1
fi

NEW_NAME_KEBAB="$1"

# Validate kebab-case format
if [[ ! "$NEW_NAME_KEBAB" =~ ^[a-z][a-z0-9]*(-[a-z0-9]+)*$ ]]; then
    echo "Error: Name must be in kebab-case (e.g., 'my-awesome-program')"
    exit 1
fi

# Current name variants
OLD_NAME_KEBAB="exo-anchor-template"
OLD_NAME_SNAKE="exo_anchor_template"
OLD_NAME_SCREAMING="EXO_ANCHOR_TEMPLATE"
OLD_NAME_PASCAL="ExoAnchorTemplate"

# Generate new name variants
NEW_NAME_SNAKE=$(echo "$NEW_NAME_KEBAB" | tr '-' '_')
NEW_NAME_SCREAMING=$(echo "$NEW_NAME_SNAKE" | tr '[:lower:]' '[:upper:]')
NEW_NAME_PASCAL=$(echo "$NEW_NAME_KEBAB" | sed -r 's/(^|-)([a-z])/\U\2/g')

echo "Renaming project:"
echo "  kebab-case:    $OLD_NAME_KEBAB -> $NEW_NAME_KEBAB"
echo "  snake_case:    $OLD_NAME_SNAKE -> $NEW_NAME_SNAKE"
echo "  SCREAMING:     $OLD_NAME_SCREAMING -> $NEW_NAME_SCREAMING"
echo "  PascalCase:    $OLD_NAME_PASCAL -> $NEW_NAME_PASCAL"
echo ""

# Get the project root directory (parent of scripts/)
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "Working in: $PROJECT_ROOT"
echo ""

# Function to replace in file if it exists
replace_in_file() {
    local file="$1"
    if [ -f "$file" ]; then
        # Use different sed syntax for macOS vs Linux
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' \
                -e "s/$OLD_NAME_KEBAB/$NEW_NAME_KEBAB/g" \
                -e "s/$OLD_NAME_SNAKE/$NEW_NAME_SNAKE/g" \
                -e "s/$OLD_NAME_SCREAMING/$NEW_NAME_SCREAMING/g" \
                -e "s/$OLD_NAME_PASCAL/$NEW_NAME_PASCAL/g" \
                "$file"
        else
            sed -i \
                -e "s/$OLD_NAME_KEBAB/$NEW_NAME_KEBAB/g" \
                -e "s/$OLD_NAME_SNAKE/$NEW_NAME_SNAKE/g" \
                -e "s/$OLD_NAME_SCREAMING/$NEW_NAME_SCREAMING/g" \
                -e "s/$OLD_NAME_PASCAL/$NEW_NAME_PASCAL/g" \
                "$file"
        fi
        echo "  Updated: $file"
    fi
}

# Step 1: Update Cargo.toml files
echo "Updating Cargo.toml files..."
replace_in_file "Cargo.toml"
replace_in_file "programs/$OLD_NAME_KEBAB/Cargo.toml"
replace_in_file "clients/rust/Cargo.toml"
replace_in_file "integration-tests/Cargo.toml"

# Step 2: Update Anchor.toml
echo "Updating Anchor.toml..."
replace_in_file "Anchor.toml"

# Step 3: Update program source code
echo "Updating program source code..."
replace_in_file "programs/$OLD_NAME_KEBAB/src/lib.rs"

# Step 4: Update client source code (non-generated)
echo "Updating client source code..."
replace_in_file "clients/rust/src/lib.rs"

# Step 5: Update generated client code
echo "Updating generated client code..."
for file in clients/rust/src/generated/*.rs clients/rust/src/generated/**/*.rs; do
    replace_in_file "$file"
done

# Step 6: Update integration tests
echo "Updating integration tests..."
replace_in_file "integration-tests/src/lib.rs"
for file in "integration-tests/src/$OLD_NAME_SNAKE"/*.rs; do
    replace_in_file "$file"
done

# Step 7: Update scripts
echo "Updating scripts..."
replace_in_file "scripts/generate-clients.mjs"

# Step 8: Rename directories
echo ""
echo "Renaming directories..."

# Rename program directory
if [ -d "programs/$OLD_NAME_KEBAB" ]; then
    mv "programs/$OLD_NAME_KEBAB" "programs/$NEW_NAME_KEBAB"
    echo "  Renamed: programs/$OLD_NAME_KEBAB -> programs/$NEW_NAME_KEBAB"
fi

# Rename integration tests module directory
if [ -d "integration-tests/src/$OLD_NAME_SNAKE" ]; then
    mv "integration-tests/src/$OLD_NAME_SNAKE" "integration-tests/src/$NEW_NAME_SNAKE"
    echo "  Renamed: integration-tests/src/$OLD_NAME_SNAKE -> integration-tests/src/$NEW_NAME_SNAKE"
fi

# Step 9: Clean up build artifacts that contain old names
echo ""
echo "Cleaning up old build artifacts..."
rm -rf target/deploy
rm -rf target/idl
rm -rf target/types
echo "  Removed: target/deploy, target/idl, target/types"

# Step 10: Remove the rename script from package.json
echo ""
echo "Removing rename script from package.json..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' '/"rename":/d' package.json
else
    sed -i '/"rename":/d' package.json
fi
echo "  Removed: rename script from package.json"

# Step 11: Delete this script
SCRIPT_PATH="$PROJECT_ROOT/scripts/rename-project.sh"

echo ""
echo "=========================================="
echo "Project renamed successfully!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Review the changes: git diff"
echo "  2. Rebuild the program: anchor build"
echo "  3. Regenerate the client: yarn generate:clients"
echo "  4. Run tests: cargo test"
echo ""

# Self-delete (must be last)
rm -f "$SCRIPT_PATH"
echo "Self-deleted: scripts/rename-project.sh"
