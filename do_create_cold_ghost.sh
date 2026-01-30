#!/usr/bin/env bash
#
# do_create_cold_ghost.sh
#
# Creates a COLD copy of a directory containing:
#   - a full text snapshot of the directory tree (tree.txt)
#   - only *_session.json files found in the source directory
#   - only the directory structure needed to hold those files
#
# The COLD directory is created next to the source directory:
#   /path/to/data → /path/to/data_COLD
#

set -e

# ------------------------------------------------------------------------------
# Help
# ------------------------------------------------------------------------------

help() {
  cat <<'EOF'
do_create_cold_ghost.sh

Creates a COLD copy of a directory containing:
  - the readme file with project name and researchers contacts
  - documents in Ethics and Publications (if present)
  - a full text snapshot of the directory tree (tree.txt)
  - only *_session.json files
  - only the directory structure required to hold those files

The COLD directory is created next to the source directory:
  /path/to/data → /path/to/data_COLD

Usage:
  do_create_cold_ghost.sh <directory>

Example: calling

  do_create_cold_ghost.sh /data01/myPreciousData

will create the folder    /data01/myPreciousData_COLD

EOF
}

# ------------------------------------------------------------------------------
# Argument checking
# ------------------------------------------------------------------------------

if [[ $# -ne 1 || "$1" == "-h" || "$1" == "--help" ]]; then
  help
  exit 1
fi

SRC_DIR="$(realpath "$1")"

if [ ! -d "$SRC_DIR" ]; then
  echo "Error: '$SRC_DIR' is not a directory" >&2
  exit 1
fi

# ------------------------------------------------------------------------------
# Path setup
# ------------------------------------------------------------------------------

PARENT_DIR="$(dirname "$SRC_DIR")"
BASE_NAME="$(basename "$SRC_DIR")"
COLD_DIR="${PARENT_DIR}/${BASE_NAME}_COLD"

# ------------------------------------------------------------------------------
# Create COLD directory
# ------------------------------------------------------------------------------

mkdir -p "$COLD_DIR"

# ------------------------------------------------------------------------------
# Save full directory tree
# ------------------------------------------------------------------------------

tree -a "$SRC_DIR" > "${COLD_DIR}/tree.txt"

# ------------------------------------------------------------------------------
# Copy only *_session.json files, preserving structure
# ------------------------------------------------------------------------------

while IFS= read -r json_file; do
  rel_path="${json_file#$SRC_DIR/}"
  dest_dir="${COLD_DIR}/$(dirname "$rel_path")"

  mkdir -p "$dest_dir"
  cp "$json_file" "$dest_dir/"
done < <(find "$SRC_DIR" -type f -name "*_session.json")

# ------------------------------------------------------------------------------
# Create FYD structure and copy optional content
# ------------------------------------------------------------------------------

mkdir -p \
  "$COLD_DIR/Data_analysis" \
  "$COLD_DIR/Data_collection" \
  "$COLD_DIR/Methods_and_materials"

# Ethics
if [ -d "$SRC_DIR/Ethics" ]; then
  cp -a "$SRC_DIR/Ethics" "$COLD_DIR/"
else
  mkdir -p "$COLD_DIR/Ethics"
fi

# Publications
if [ -d "$SRC_DIR/Publications" ]; then
  cp -a "$SRC_DIR/Publications" "$COLD_DIR/"
else
  mkdir -p "$COLD_DIR/Publications"
fi

# Copy top-level README files
find "$SRC_DIR" -maxdepth 1 -type f -iname "readme.*" -exec cp {} "$COLD_DIR/" \;

# ------------------------------------------------------------------------------
# Final message
# ------------------------------------------------------------------------------

echo "A folder was created in ${COLD_DIR}"
