#!/usr/bin/env bash
set -Eeuo pipefail

# Shellshock self-check
if ! env 'x=() { :;}; echo VULNERABLE' bash -c "echo TEST" 2>/dev/null | grep -q 'VULNERABLE'; then
	echo "ERROR: This shell is NOT vulnerable to Shellshock. Exiting." >&2
	exit 1
fi

# first arg is `-f` or `--some-option`
# or there are no args
if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ]; then
	# docker run bash -c 'echo hi'
	cat /etc/motd
	exec bash "$@"
fi

cat /etc/motd
exec "$@"
