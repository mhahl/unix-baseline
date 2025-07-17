#!/bin/sh

platform='unknown'
unamestr=$(uname)
if [ "$unamestr" = 'Linux' ]; then
   platform='linux'
elif [ "$unamestr" = 'FreeBSD' ]; then
   platform='freebsd'
fi

echo -n "Vault Password: "
read password

mkdir -p /var/db/baseline
mkdir -p /usr/local/etc/baseline

touch /usr/local/etc/baseline/config.yaml

echo "$password" > /var/db/baseline/.credentials
chmod 0600 /var/db/baseline/.credentials

if [ "$platform" = 'linux' ]; then
  dnf install -y ansible-core

elif [ "$platform" = 'freebsd' ]; then
  pkg install py311-ansible py311-ansible-core
fi

echo "Applying baseline"
ansible-pull -U https://github.com/mhahl/freebsd-baseline baseline.yaml --clean --vault-pass-file /var/db/baseline/.credentials


