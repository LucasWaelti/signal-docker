#!/bin/sh
# wrapper to enforce container OS identity and launch Signal
# (keeps arguments as-is)

# Ensure environment variables that Signal/Electron might consult
export UBUNTU_CODENAME=noble
export DISTRIB_CODENAME=noble
export VERSION_CODENAME=noble

# Unset any host-specific envvars that may leak host info
unset HOSTNAME
unset HOSTTYPE

# Start Signal with recommended flags (accepts extra args forwarded)
exec signal-desktop "$@"