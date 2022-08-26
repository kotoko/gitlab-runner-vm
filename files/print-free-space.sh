#!/bin/bash

set -e

if command -v df >/dev/null 2>/dev/null; then
	echo "df -h '${CI_PROJECT_DIR}'"
	df -h "${CI_PROJECT_DIR}"
fi

