#!/bin/bash

set -e
set -o pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

if [ "$#" -ge 1 ]; then
	if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
		cat -<<EOF
usage: $0 [-h | --help] [SIZE]

Generate additional disk that is used by gitlab runner virtual machine to store directories:
  /gitlab-runner/builds/
  /gitlab-runner/cache/
  /tmp/
  /var/tmp/
  /var/lib/docker/
Script must be run as root.

optional arguments:
  SIZE - integer; disk size; unit is gigabytes; default is 50
EOF
		exit 1
	fi
fi

if [ "$#" -ge 2 ]; then
	echo "Error! Expected 0 or 1 parameter - size in gigabytes." >&2
	exit 1
fi

if [ "$#" -eq 1 ]; then
	if test -n "$1" -a "$1" -ge 0 2>/dev/null; then
		DISK_SIZE="$1"
	else
		echo "Error! Expected integer! Got: $1"
		exit 1
	fi
else
	DISK_SIZE="50"
fi

if [ "${USER}" != "root" ];then
	echo "Error! Script must be run as root." >&2
	exit 1
fi

TEMP="$(mktemp -d)"

DISK_NAME="gr-disk-builds-${DISK_SIZE}G.qcow2"
DISK_PATH="${TEMP}/${DISK_NAME}"
DISK_LABEL='GR-BUILDS'
MOUNT_DIR="${TEMP}/mount"

set -ux

echo "${TEMP}" >&2

# Create disk with ext4 partition
qemu-img create -f qcow2 "${DISK_PATH}" "${DISK_SIZE}"G
virt-format --format='qcow2' -a "${DISK_PATH}" --partition='gpt' --label="${DISK_LABEL}" --filesystem='ext4'

# Create directories
mkdir -p "${MOUNT_DIR}"
guestmount --format='qcow2' -a "${DISK_PATH}" -m '/dev/sda1' "${MOUNT_DIR}"
for d in 'gitlab-runner-builds' 'gitlab-runner-cache' 'tmp' 'var-tmp' 'docker'; do
	mkdir -p -m 777 "${MOUNT_DIR}/${d}"
done
sync ; sync ; sleep 2
guestunmount "${MOUNT_DIR}"

# Save artifact
mkdir -p "${SCRIPT_DIR}/out"
mv -f "${DISK_PATH}" "${SCRIPT_DIR}/out/${DISK_NAME}"
chmod 777 "${SCRIPT_DIR}/out/${DISK_NAME}"

# Clean up
rm -fr "${TEMP}"

echo "Done! Generated file is:"
echo "  '${SCRIPT_DIR}/out/${DISK_NAME}'"
