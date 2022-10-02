#!/bin/bash

set -e
set -u

echo "Running $0"

if command -v df >/dev/null 2>/dev/null; then
	echo "df -h '${CI_PROJECT_DIR}'"
	df -h "${CI_PROJECT_DIR}"
else
	echo "Missing 'df' command. Skipping..."
fi

