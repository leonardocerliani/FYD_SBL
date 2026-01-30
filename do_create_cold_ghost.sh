#!/usr/bin/env bash
#
# cold_tree.sh
#
# Creates a COLD copy of a directory containing:
#   - a full text snapshot of the directory tree (tree.txt)
#   - only .json files found in the source directory
#   - only the directory structure needed to hold those .json files
#
# The COLD directory is created next to the source directory:
#   /path/to/data      → /path/to/data_COLD
#
# Usage:
#   ./cold_tree.sh <directory>
#
# Example:
#   ./cold_tree.sh /data01/layerfMRI
#

set -e

# --- argument checking -------------------------------------------------------

if [ $# -ne 1 ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

SRC_DIR="$(realpath "$1")"

if [ ! -d "$SRC_DIR" ]; then
  echo "Error: '$SRC_DIR' is not a directory"
  exit 1
fi

# --- path setup --------------------------------------------------------------

PARENT_DIR="$(dirname "$SRC_DIR")"
BASE_NAME="$(basename "$SRC_DIR")"
COLD_DIR="${PARENT_DIR}/${BASE_NAME}_COLD"

# --- create COLD directory ---------------------------------------------------

mkdir -p "$COLD_DIR"

# --- save full directory tree ------------------------------------------------

tree -a "$SRC_DIR" > "${COLD_DIR}/tree.txt"

# --- copy only *_session.json files ----------------------------------------------------

while IFS= read -r json_file
do
  # Path relative to the source directory
  rel_path="${json_file#$SRC_DIR/}"

  # Destination directory inside COLD
  dest_dir="${COLD_DIR}/$(dirname "$rel_path")"

  mkdir -p "$dest_dir"
  cp "$json_file" "$dest_dir/"
done < <(find "$SRC_DIR" -type f -name "*_session.json")



# --- create data structure for FYD and create/copy the readme --------------------
mkdir -p \
  "$COLD_DIR/Data_analysis" \
  "$COLD_DIR/Data_collection" \
  "$COLD_DIR/Methods_and_materials"

# Copy Ethics and Publications content from source (if they exist)
if [ -d "$SRC_DIR/Ethics" ]; then
  cp -a "$SRC_DIR/Ethics" "$COLD_DIR/"
else
  mkdir -p "$COLD_DIR/Ethics"
fi

if [ -d "$SRC_DIR/Publications" ]; then
  cp -a "$SRC_DIR/Publications" "$COLD_DIR/"
else
  mkdir -p "$COLD_DIR/Publications"
fi

# Copy top-level README files
find "$SRC_DIR" -maxdepth 1 -type f -iname "readme.*" -exec cp {} "$COLD_DIR/" \;
