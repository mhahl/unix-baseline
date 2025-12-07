# unix-baseline

A system baseline configuration for Linux (Fedora/RHEL/CentOS, Debian/Ubuntu), FreeBSD, and OpenBSD using Ansible.
The playbook applies common hardening and configuration tasks (DNS, NTP, SSH, sudo, auditing, etc.) and supports Ansible Vault for secrets.

```
# One-time initial bootstrap (as root)
curl -fsSL https://raw.githubusercontent.com/mhahl/unix-baseline/main/bootstrap.sh | bash
# You will be prompted for the Ansible Vault password
```

Alternatively, clone the repository first:

```
git clone https://github.com/mhahl/unix-baseline.git
cd unix-baseline
sudo bash bootstrap.sh
```

## Installation

Run the bootstrap.sh script as root and enter your Ansible Vault password when prompted.

```bash
Vault Password: ************
```

The script will:

* Detect the operating system
* Install Ansible (and required dependencies)
* Store the vault password securely in /var/db/baseline/.credentials (mode 0600)
* Pull the latest playbook from the repository
* Apply the full baseline configuration

After the initial run, a systemd timer or cronjob is deployed (via the baseline task) that periodically runs ansible-pull to keep the system up-to-date and in compliance.
Check your fleet management or `Moonlight` dashboard to confirm the host has checked in successfully.

## Ongoing Updates

The baseline code is self-updating:

* A cron job runs ansible-pull regularly using the stored vault password file.
* No manual intervention is required unless you change the vault password (in which case re-run bootstrap.sh).

## Configuration

Most features are controlled by boolean variables that can be set in /usr/local/etc/baseline/config.yaml (created if it does not exist).

The default for every toggle is true (enabled).

| Value               | Description                                              |
|---------------------|----------------------------------------------------------|
| configure_cacert    | Install and trust custom CA certificates                 |
| configure_repos     | Install and trust custom CA certificates                 |
| configure_dns       | Set DNS servers and search domains                       |
| configure_motd      | Display a custom Message of the Day                      |
| configure_timezone  | Set system timezone                                      |
| configure_ntp       | Configure NTP/chrony time synchronization                |
| configure_skel      | Install skeleton files for new users                     |
| configure_sssd      | Configure SSSD for LDAP/AD authentication                |
| configure_sudoers   | Harden and configure sudo rules                          |
| configure_sshd      | Harden SSH server configuration                          |
| configure_baseline  | Deploy the ansible-pull cron job for ongoing enforcement |
| configure_syslog    | Configure rsyslog/syslog-ng                              |
| configure_profile   | Install shell profile customizations                     |
| configure_auditd    | Configure auditd rules                                   |
| configure_netgroups | Manage netgroups                                         |
| configure_fleet     | Configure fleet/osquery enrollment                       |
| moonlight           | Moonlight agent check-in (always runs)                   |

Example `/usr/local/etc/baseline/config.yaml` to disable some features:

```
configure_motd: false
configure_sssd: false
configure_auditd: false
```

Additional variables (DNS servers, timezones, secrets, etc.) are defined in `config/defaults.yaml`, 
per-OS files, and `config/secrets.yaml` (vault-encrypted). Refer to the repository for the full list of available options.