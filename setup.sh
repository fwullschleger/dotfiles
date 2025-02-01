#!/usr/bin/env bash
set -e

# -----------------------------------------------------------------------------
# Setup Script
#
# This script performs the following steps:
# 1. Use stow with the --no-folding option to link only the 'leaves'
#    (without linking whole directories).
# 2. Create a virtual environment in ~/scripts/ (if it doesn't exist).
# 3. Activate the virtual environment.
# 4. Install dependencies from the scripts/requirements.txt file.
#
# Usage:
#   ./setup.sh
# -----------------------------------------------------------------------------

# Step 1: Run stow with --no-folding to symlink configuration files.
echo "Running stow with --no-folding..."
stow . --no-folding

# Location to create the virtual environment.
VENV_DIR="${HOME}/scripts/venv"

# Step 2: Create a virtual environment if it doesn't exist.
if [ ! -d "$VENV_DIR" ]; then
  echo "Creating virtual environment in ${VENV_DIR}..."
  python3 -m venv "$VENV_DIR"
else
  echo "Virtual environment already exists in ${VENV_DIR}."
fi

# Step 3: Activate the virtual environment.
echo "Activating virtual environment..."
# shellcheck source=/dev/null
source "$VENV_DIR/bin/activate"

# Step 4: Install dependencies from the scripts/requirements.txt file.
REQ_FILE="scripts/requirements.txt"
if [ -f "$REQ_FILE" ]; then
  echo "Installing dependencies from $REQ_FILE..."
  pip install -r "$REQ_FILE"
else
  echo "Error: Requirements file not found at $REQ_FILE"
  exit 1
fi

echo "Setup complete!"
