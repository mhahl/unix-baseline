#!/bin/sh

echo -n "Vault Password: "
read -s password

mkdir -p /var/db/baseline

echo "$password" > /var/db/baseline/.credentials
chmod 0600 /var/db/baseline/.credentials

pkg install py311-ansible py311-ansible-core 

cat > /etc/cron.d/baseline <<EOF
*/30 * * * * root /usr/local/bin/ansible-pull -U https://git.sr.ht/~mhahl/sigaint-freebsd-baseline baseline.yaml --clean --vault-pass-file /var/db/baseline/.credentials
EOF
