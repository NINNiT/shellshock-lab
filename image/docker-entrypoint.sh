#!/usr/bin/env bash
set -Eeuo pipefail

if [ ! -d /run/openrc ]; then
	mkdir -p /run/openrc
	touch /run/openrc/softlevel
fi

openrc default
rc-service sshd start
rc-service apache2 start

# Shellshock self-check
if ! env 'x=() { :;}; echo VULNERABLE' bash -c "echo TEST" 2>/dev/null | grep -q 'VULNERABLE'; then
	echo "ERROR: This shell is NOT vulnerable to Shellshock. Exiting." >&2
	exit 1
fi

# Show the MOTD
cat /etc/motd

# Execute the given command or start a bash shell if no command is provided
if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ]; then
	exec bash "$@"
else
	exec "$@"
fi
