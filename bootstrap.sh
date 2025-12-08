#!/usr/bin/env bash
# bootstrap.sh - Install Ansible and apply unix-baseline via ansible-pull
# Keeps a permanent .credentials file for cron use

set -euo pipefail

# -----------------------------
# Helper functions
# -----------------------------
die() {
    echo "ERROR: $*" >&2
    exit 1
}

# -----------------------------
# Detect platform
# -----------------------------
case "$(uname -s)" in
    Linux)   PLATFORM="linux"   ;;
    FreeBSD) PLATFORM="freebsd" ;;
    OpenBSD) PLATFORM="openbsd" ;;
    *)
        die "Unsupported operating system: $(uname -s)"
        ;;
esac

echo "Detected platform: $PLATFORM"

# -----------------------------
# Ensure required directories and files exist
# -----------------------------
mkdir -p /var/db/baseline /usr/local/etc/baseline
touch /usr/local/etc/baseline/config.yaml

# Permanent credentials file (required for cron jobs)
CREDS_FILE="/var/db/baseline/.credentials"

# -----------------------------
# Prompt for Vault password securely
# -----------------------------
if [[ -t 0 ]]; then
    # Interactive terminal
    read -rsp "Vault Password: " VAULT_PASSWORD
    echo
else
    # Non-interactive (e.g., piped input or cron) – read from stdin
    read -r VAULT_PASSWORD
fi

# Write/update the permanent credentials file
printf '%s\n' "$VAULT_PASSWORD" > "$CREDS_FILE"
chmod 600 "$CREDS_FILE"

# -----------------------------
# Install Ansible based on platform
# -----------------------------
echo "Installing Ansible..."

case "$PLATFORM" in
    linux)
        if command -v dnf >/dev/null; then
            dnf install -y ansible-core
        elif command -v yum >/dev/null; then
            yum install -y ansible-core
        elif command -v apt-get >/dev/null; then
            apt-get update && apt-get install -y ansible-core
        else
            die "No supported package manager found (dnf/yum/apt)"
        fi
        ;;
    freebsd)
        pkg install -y py311-ansible-core
        ;;
    openbsd)
        pkg_add -z ansible git wget
        ;;
esac

# Verify Ansible is installed
command -v ansible-pull >/dev/null || die "Ansible installation failed"

# -----------------------------
# Run ansible-pull using the permanent credentials file
# -----------------------------
echo "Applying unix-baseline configuration..."
ansible-pull -U https://github.com/mhahl/unix-baseline \
    baseline.yaml \
    --clean \
    --vault-password-file "$CREDS_FILE"

echo "Baseline applied successfully!"