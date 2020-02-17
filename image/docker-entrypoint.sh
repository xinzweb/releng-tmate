#!/bin/sh
set -e

if [ "${USE_PROXY_PROTOCOL}" == "1" ]; then
  set -- -x "$@"
fi

if [ "${HAS_WEBSOCKET}" == "1" ]; then
  set -- -w localhost "$@"
fi

if [ ! -z "${SSH_HOSTNAME}" ]; then
  set -- -h "${SSH_HOSTNAME}" "$@"
fi

SSH_PORT_LISTEN=${SSH_PORT_LISTEN:-2222}
SSH_PORT_ADVERTIZE=${SSH_PORT_ADVERTIZE:-${SSH_PORT_LISTEN}}
SSH_PORT_ADVERTISE=${SSH_PORT_ADVERTISE:-${SSH_PORT_ADVERTIZE}}

/etc/tmate/create_keys.sh
exec tmate-ssh-server -p ${SSH_PORT_LISTEN} -q ${SSH_PORT_ADVERTISE} -k /etc/tmate/keys "$@"
