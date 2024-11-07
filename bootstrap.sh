#!/bin/sh

pkg install py311-ansible-core 

cat > /etc/cron.d/baseline <<EOF
*/30 * * * * root /usr/local/bin/ansible-pull https://git.sr.ht/~mhahl/sigaint-freebsd-baseline baseline.yaml --clean
EOF
