#!/bin/bash

set -e
set -u

echo "$0"

if command -v git >/dev/null 2>/dev/null; then
	echo 'git config --global safe.directory "*"'
	git config --global safe.directory '*'
else
	echo "Missing 'git' command. Skipping..."
fi
