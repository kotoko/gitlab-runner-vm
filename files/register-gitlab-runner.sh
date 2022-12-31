#!/bin/sh

NAME='gitlab-runner-vm'
REGISTRATION_TOKEN=''
URL='https://gitlab.com'
BUILDS_DIR='/gitlab-runner/builds'
CACHE_DIR='/gitlab-runner/cache'

FF_ENABLE_JOB_CLEANUP='FF_ENABLE_JOB_CLEANUP=1'
FF_USE_NEW_BASH_EVAL_STRATEGY='FF_USE_NEW_BASH_EVAL_STRATEGY=1'
FF_USE_NEW_SHELL_ESCAPE='FF_USE_NEW_SHELL_ESCAPE=1'
FF_SCRIPT_SECTIONS='FF_SCRIPT_SECTIONS=1'
FF_USE_FASTZIP='FF_USE_FASTZIP=1'
FF_NETWORK_PER_BUILD='FF_NETWORK_PER_BUILD=1'
FF_USE_IMPROVED_URL_MASKING='FF_USE_IMPROVED_URL_MASKING=1'
TRANSFER_METER_FREQUENCY='TRANSFER_METER_FREQUENCY=4s'


if [ "$#" -ne 1 ] && [ "$#" -ne 2 ]; then
	echo "usage: $0 REGISTRATION_TOKEN"
	echo "usage: $0 NAME REGISTRATION_TOKEN"
	exit 1
fi

if [ "$#" -eq 1 ]; then
	REGISTRATION_TOKEN="$1"
fi

if [ "$#" -eq 2 ]; then
	NAME="$1"
	REGISTRATION_TOKEN="$2"
fi

if [ "$USER" != 'root' ]; then
	echo 'Error! Script must be run as root. Aborting...' >&2
	exit 1
fi

set -eux

# shell
gitlab-runner register \
	--non-interactive \
	--name "$NAME" \
	--url "$URL" \
	--registration-token "$REGISTRATION_TOKEN" \
	--tag-list 'linux,amd64,shell' \
	--executor 'shell' \
	--shell 'bash' \
	--builds-dir "$BUILDS_DIR" \
	--cache-dir "$CACHE_DIR" \
	--pre-clone-script '/usr/bin/bash-static -c "/usr/bin/bash-static /root/ci/reset-home-directory.sh ; /usr/bin/bash-static /root/ci/fix-git-dubious-ownership.sh"' \
	--pre-build-script '/usr/bin/bash-static -c "/usr/bin/bash-static /root/ci/reset-home-directory.sh ; /usr/bin/bash-static /usr/bin/neofetch --backend off ; /usr/bin/bash-static /root/ci/print-free-space.sh"' \
	--env "$FF_ENABLE_JOB_CLEANUP" \
	--env "$FF_USE_FASTZIP" \
	--env "$FF_USE_NEW_BASH_EVAL_STRATEGY" \
	--env "$FF_USE_NEW_SHELL_ESCAPE" \
	--env "$FF_SCRIPT_SECTIONS" \
	--env "$FF_USE_IMPROVED_URL_MASKING" \
	--env "$TRANSFER_METER_FREQUENCY"

# docker
gitlab-runner register \
	--non-interactive \
	--name "$NAME" \
	--url "$URL" \
	--registration-token "$REGISTRATION_TOKEN" \
	--tag-list 'linux,amd64,docker' \
	--executor 'docker' \
	--docker-image 'hello-world:latest' \
	--docker-pull-policy 'always' \
	--docker-volumes '/etc/timezone:/etc/timezone:ro' \
	--docker-volumes '/etc/localtime:/etc/localtime:ro' \
	--docker-volumes '/usr/bin/bash-static:/host/bash-static:ro' \
	--docker-volumes '/usr/bin/neofetch:/host/neofetch:ro' \
	--docker-volumes '/root/ci/fix-git-dubious-ownership.sh:/host/fix-git-dubious-ownership.sh:ro' \
	--docker-volumes '/root/ci/print-free-space.sh:/host/print-free-space.sh:ro' \
	--pre-clone-script '/host/bash-static /host/fix-git-dubious-ownership.sh' \
	--pre-build-script '/host/bash-static -c "/host/bash-static /host/neofetch --backend off ; /host/bash-static /host/fix-git-dubious-ownership.sh ; /host/bash-static /host/print-free-space.sh"' \
	--env "$FF_NETWORK_PER_BUILD" \
	--env "$FF_ENABLE_JOB_CLEANUP" \
	--env "$FF_USE_FASTZIP" \
	--env "$FF_USE_NEW_BASH_EVAL_STRATEGY" \
	--env "$FF_USE_NEW_SHELL_ESCAPE" \
	--env "$FF_SCRIPT_SECTIONS" \
	--env "$FF_USE_IMPROVED_URL_MASKING" \
	--env "$TRANSFER_METER_FREQUENCY"

# docker privileged
gitlab-runner register \
	--non-interactive \
	--name "$NAME" \
	--url "$URL" \
	--registration-token "$REGISTRATION_TOKEN" \
	--tag-list 'linux,amd64,docker-privileged' \
	--executor 'docker' \
	--docker-privileged \
	--docker-image 'hello-world:latest' \
	--docker-pull-policy 'always' \
	--docker-volumes '/etc/timezone:/etc/timezone:ro' \
	--docker-volumes '/etc/localtime:/etc/localtime:ro' \
	--docker-volumes '/usr/bin/bash-static:/host/bash-static:ro' \
	--docker-volumes '/usr/bin/neofetch:/host/neofetch:ro' \
	--docker-volumes '/root/ci/fix-git-dubious-ownership.sh:/host/fix-git-dubious-ownership.sh:ro' \
	--docker-volumes '/root/ci/print-free-space.sh:/host/print-free-space.sh:ro' \
	--docker-volumes '/var/run/docker.sock:/var/run/docker.sock:rw' \
	--pre-clone-script '/host/bash-static /host/fix-git-dubious-ownership.sh' \
	--pre-build-script '/host/bash-static -c "/host/bash-static /host/neofetch --backend off ; /host/bash-static /host/fix-git-dubious-ownership.sh ; /host/bash-static /host/print-free-space.sh"' \
	--env "$FF_NETWORK_PER_BUILD" \
	--env "$FF_ENABLE_JOB_CLEANUP" \
	--env "$FF_USE_FASTZIP" \
	--env "$FF_USE_NEW_BASH_EVAL_STRATEGY" \
	--env "$FF_USE_NEW_SHELL_ESCAPE" \
	--env "$FF_SCRIPT_SECTIONS" \
	--env "$FF_USE_IMPROVED_URL_MASKING" \
	--env "$TRANSFER_METER_FREQUENCY"
