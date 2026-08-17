#!/bin/bash

# Locate project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$PROJECT_ROOT/.env"

echo "Loading global variables..."

# Load the .env file (If exists)
if [ ! -f "$ENV_FILE" ]; then
    echo "Error: .env file not found at $ENV_FILE"
    echo "This is required to run the environment."
    exit 1
fi

source "$ENV_FILE"

# Export the root path so the calling script can use it without recalculating
export PROJECT_ROOT 

echo "Loaded global variables successfully"
    