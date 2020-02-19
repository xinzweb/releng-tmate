#!/bin/sh
set -eu

gen_key() {
  keytype=$1
  ks="${keytype}_"
  key="keys/ssh_host_${ks}key"
  if [ ! -e "${key}" ] ; then
    ssh-keygen -t ${keytype} -f "${key}" -N ''
    echo ""
  fi
  SIG=$(ssh-keygen -l -E SHA256 -f $key.pub | cut -d ' ' -f 2)
}

cd /etc/tmate/
mkdir -p keys
gen_key rsa
RSA_SIG=$SIG
gen_key ed25519
ED25519_SIG=$SIG

cat <<EOF >/etc/tmate/keys/tmate.conf
set -g tmate-server-host localhost
set -g tmate-server-port 2222
set -g tmate-server-rsa-fingerprint "${RSA_SIG}"
set -g tmate-server-ed25519-fingerprint "${ED25519_SIG}"
EOF
