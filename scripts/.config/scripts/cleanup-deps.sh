#!/bin/bash

# Ensure 'fd' is installed
if ! command -v fd &> /dev/null; then
    echo "Error: 'fd' is not installed."
    exit 1
fi

echo "Scanning $PWD for 'node_modules' and 'vendor'..."

# Search for directories (non-recursively inside the current directory)
mapfile -t FOUND_DIRS < <(fd -H -I -t d --max-depth 1 --color=never '^(node_modules|vendor)$' . 2>/dev/null)

# Exit if nothing is found
if [[ ${#FOUND_DIRS[@]} -eq 0 ]]; then
    echo "---------------------------------------------------------"
    echo "✓ Clean! No 'node_modules' or 'vendor' folders found."
    echo "---------------------------------------------------------"
    exit 0
fi

# Display results
echo "---------------------------------------------------------"
echo "Found ${#FOUND_DIRS[@]} directories:"
for i in "${!FOUND_DIRS[@]}"; do
    echo "  [$((i+1))] ${FOUND_DIRS[$i]}"
done
echo "---------------------------------------------------------"

# Prompt user for action
read -p "Enter numbers to delete (comma-separated), 0 for all, or C to cancel [0]: " choice
choice=${choice:-0}

if [[ "$choice" =~ ^[Cc]$ ]]; then
    echo "Operation cancelled."
    exit 0
fi

echo "" # Empty line for readability

if [[ "$choice" == "0" ]]; then
    echo "Deleting all found directories..."
    for dir in "${FOUND_DIRS[@]}"; do
        rm -rf "$dir"
        echo "  - Removed $dir"
    done
else
    IFS=',' read -r -a selections <<< "$choice"
    for sel in "${selections[@]}"; do
        sel=${sel//[[:blank:]]/} # Trim whitespace
        if [[ "$sel" =~ ^[0-9]+$ ]] && [ "$sel" -gt 0 ] && [ "$sel" -le "${#FOUND_DIRS[@]}" ]; then
            index=$((sel-1))
            rm -rf "${FOUND_DIRS[$index]}"
            echo "  - Removed ${FOUND_DIRS[$index]}"
        else
            [[ -n "$sel" ]] && echo "  ! Invalid selection: $sel"
        fi
    done
fi

echo "Cleanup complete."
