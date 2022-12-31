#!/bin/bash

set -e
set -u

echo "Running $0"

HOMEDIR='/home/gitlab-runner'

if [ ! -d "${HOMEDIR}" ]; then
	echo "Directory '${HOMEDIR}' does not exist! Skipping..."
	exit
fi

# Sanity check
user1="$(stat -c '%u' "${HOMEDIR}")"
user2="$(id -u)"
if [ "${user1}" -ne "${user2}" ]; then
	echo "Current user does not own directory '${HOMEDIR}'! Aborting..."
	exit
fi

/usr/bin/env find "${HOMEDIR}" -depth -mindepth 1 -delete || true

echo 'Done!'

