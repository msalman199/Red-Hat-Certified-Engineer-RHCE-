# 🔐 Secure Management with Ansible Vault

<div align="center">

![Ansible](https://img.shields.io/badge/Ansible-Automation-red?style=for-the-badge&logo=ansible)
![Vault](https://img.shields.io/badge/Ansible-Vault-important?style=for-the-badge)
![Security](https://img.shields.io/badge/Security-Encryption-success?style=for-the-badge)
![Linux](https://img.shields.io/badge/Linux-RHEL%20%7C%20CentOS-black?style=for-the-badge&logo=linux)
![DevOps](https://img.shields.io/badge/DevOps-Secure%20Automation-blue?style=for-the-badge)

# 🛡️ Protect Sensitive Data with Ansible Vault

</div>

---

# 📘 Overview

This lab demonstrates how to securely manage sensitive data using **Ansible Vault**.

You will learn how to:

✅ Encrypt secrets  
✅ Manage credentials securely  
✅ Use encrypted variables in playbooks  
✅ Implement production-ready security practices  

---

# 🎯 Objectives

By the end of this lab, students will be able to:

- 🔐 Understand secure automation practices
- 📂 Create encrypted files using Ansible Vault
- ⚙️ Use encrypted variables inside playbooks
- 🛡️ Manage credentials securely
- 🚀 Apply production-ready encryption techniques

---

# 📚 Prerequisites

Before starting this lab:

- 🐧 Basic Linux knowledge
- 📄 YAML syntax understanding
- ⚙️ Familiarity with Ansible fundamentals
- 🔑 Basic security concepts
- 🖥️ Previous Ansible lab experience

---

# ☁️ Lab Environment

## 🖥️ Included Environment

| Component | Description |
|---|---|
| 🎛️ Control Node | CentOS/RHEL with Ansible |
| 🔐 SSH Access | Pre-configured authentication |
| ⚙️ Dependencies | All required tools installed |

---

# 📁 Project Structure

```bash
vault-lab/
├── 📄 README.md
├── 📄 db_secrets.yml
├── 📄 dev_secrets.yml
├── 📄 staging_secrets.yml
├── 📄 secure_deployment.yml
├── 📄 mixed_vars_playbook.yml
├── 📄 environment_deployment.yml
├── 📄 vault_id_playbook.yml
├── 📄 vault_manager.sh
│
├── 📂 templates/
│   ├── 📄 app_config.j2
│   └── 📄 secure_service.j2
│
├── 📂 vault_passwords/
│   ├── 📄 .vault_password
│   ├── 📄 .vault_dev
│   └── 📄 .vault_prod
│
├── 📂 configs/
│   ├── 📄 dev_config.ini
│   ├── 📄 staging_config.ini
│   └── 📄 production_config.ini
│
├── 📂 logs/
│   ├── 📄 deployment.log
│   └── 📄 vault_operations.log
│
└── 📂 screenshots/
    ├── 📷 vault-create.png
    ├── 📷 encrypted-file.png
    └── 📷 deployment-success.png
```

---

# 🧪 Task 1 — Create Encrypted Files

---

# 🔹 Understanding Ansible Vault

Ansible Vault allows you to encrypt:

- 🔑 Passwords
- 🔐 API Keys
- 📜 Certificates
- 🛡️ Sensitive Variables

---

# ✅ Key Benefits

| Benefit | Description |
|---|---|
| 🔒 Security | Protect sensitive data |
| 📂 Version Control Safety | Safe Git storage |
| 👥 Team Collaboration | Secure credential sharing |

---

# 🔹 Create Working Directory

```bash
cd /home/student/ansible-lab

mkdir vault-lab

cd vault-lab
```

---

# 🔹 Create Encrypted File

```bash
ansible-vault create db_secrets.yml
```

### Enter Vault Password

```text
New Vault password: SecurePass123!
Confirm New Vault password: SecurePass123!
```

---

# 📄 Encrypted Secrets File

## `db_secrets.yml`

```yaml
---
# Database Configuration Secrets

db_host: "production-db.company.com"
db_username: "app_user"
db_password: "MySecureDBPassword2024!"
db_port: 5432
db_name: "production_app"

# API Keys

api_key: "sk-1234567890abcdef"
secret_token: "token_abc123xyz789"

# SSL Paths

ssl_cert_path: "/etc/ssl/certs/app.crt"
ssl_key_path: "/etc/ssl/private/app.key"
```

---

# 🔍 Verify Encrypted File

```bash
cat db_secrets.yml
```

Expected encrypted output:

```text
$ANSIBLE_VAULT;1.1;AES256
663864396537653864643234646638...
```

---

# 👀 View Decrypted Content

```bash
ansible-vault view db_secrets.yml
```

---

# 🚀 Task 2 — Use Encrypted Variables

---

# 📄 Create Secure Deployment Playbook

```bash
nano secure_deployment.yml
```

---

## `secure_deployment.yml`

```yaml
---
- name: Secure Application Deployment
  hosts: localhost

  vars_files:
    - db_secrets.yml

  vars:
    app_name: "secure-web-app"
    deployment_env: "production"

  tasks:

    - name: Display deployment info
      debug:
        msg: |
          Deploying {{ app_name }}
          Database Host: {{ db_host }}

    - name: Create secure config file
      copy:
        content: |
          [database]
          host={{ db_host }}
          username={{ db_username }}
          password={{ db_password }}

          [api]
          key={{ api_key }}

        dest: /tmp/app_config.ini
        mode: '0600'
```

---

# ▶️ Run Playbook

```bash
ansible-playbook secure_deployment.yml --ask-vault-pass
```

---

# 🔍 Verify Configuration File

```bash
ls -la /tmp/app_config.ini
```

```bash
cat /tmp/app_config.ini
```

---

# ⚡ Task 3 — Mixed Variables

---

## `mixed_vars_playbook.yml`

```yaml
---
- name: Mixed Variables Demo
  hosts: localhost

  vars_files:
    - db_secrets.yml

  vars:
    app_version: "2.1.0"
    environment: "production"

  tasks:

    - name: Show public info
      debug:
        msg: |
          Version: {{ app_version }}
          Environment: {{ environment }}

    - name: Test DB Connection
      shell: |
        echo "Testing {{ db_host }}"
```

---

# ▶️ Run Mixed Variables Playbook

```bash
ansible-playbook mixed_vars_playbook.yml --ask-vault-pass
```

---

# 🔐 Task 4 — Advanced Vault Management

---

# 🔹 Create Vault Password File

```bash
echo "SecurePass123!" > .vault_password

chmod 600 .vault_password
```

---

# 🔹 Edit Encrypted File

```bash
ansible-vault edit db_secrets.yml --vault-password-file .vault_password
```

---

# ➕ Add More Secrets

```yaml
ldap_server: "ldap.company.com"

smtp_server: "smtp.company.com"

smtp_password: "EmailSecurePass2024!"
```

---

# 🌍 Task 5 — Environment Specific Secrets

---

# 🔹 Development Secrets

```bash
ansible-vault create dev_secrets.yml --vault-password-file .vault_password
```

---

## `dev_secrets.yml`

```yaml
---
db_host: "dev-db.company.com"
db_username: "dev_user"
db_password: "DevPassword123!"
db_name: "development_app"
```

---

# 🔹 Staging Secrets

```bash
ansible-vault create staging_secrets.yml --vault-password-file .vault_password
```

---

## `staging_secrets.yml`

```yaml
---
db_host: "staging-db.company.com"
db_username: "staging_user"
db_password: "StagingPassword123!"
db_name: "staging_app"
```

---

# 🚀 Environment Deployment Playbook

## `environment_deployment.yml`

```yaml
---
- name: Environment Deployment
  hosts: localhost

  vars:
    target_env: "{{ env | default('dev') }}"

  vars_files:
    - "{{ target_env }}_secrets.yml"

  tasks:

    - name: Show environment
      debug:
        msg: "Deploying to {{ target_env }}"

    - name: Create environment config
      copy:
        content: |
          [database]
          host={{ db_host }}
          username={{ db_username }}
          password={{ db_password }}

        dest: "/tmp/{{ target_env }}_config.ini"
        mode: '0600'
```

---

# ▶️ Deploy to Development

```bash
ansible-playbook environment_deployment.yml \
--vault-password-file .vault_password \
-e env=dev
```

---

# ▶️ Deploy to Staging

```bash
ansible-playbook environment_deployment.yml \
--vault-password-file .vault_password \
-e env=staging
```

---

# 🛠️ Task 6 — Vault Management Script

---

## `vault_manager.sh`

```bash
#!/bin/bash

VAULT_PASSWORD_FILE=".vault_password"

ACTION=$1
FILENAME=$2

case $ACTION in

create)
    ansible-vault create "$FILENAME" \
    --vault-password-file "$VAULT_PASSWORD_FILE"
    ;;

edit)
    ansible-vault edit "$FILENAME" \
    --vault-password-file "$VAULT_PASSWORD_FILE"
    ;;

view)
    ansible-vault view "$FILENAME" \
    --vault-password-file "$VAULT_PASSWORD_FILE"
    ;;

encrypt)
    ansible-vault encrypt "$FILENAME" \
    --vault-password-file "$VAULT_PASSWORD_FILE"
    ;;

decrypt)
    ansible-vault decrypt "$FILENAME" \
    --vault-password-file "$VAULT_PASSWORD_FILE"
    ;;

*)
    echo "Invalid option"
    ;;
esac
```

---

# 🔓 Make Script Executable

```bash
chmod +x vault_manager.sh
```

---

# ▶️ Test Vault Manager

```bash
./vault_manager.sh view db_secrets.yml
```

---

# 🔑 Task 7 — Vault IDs

---

# 🔹 Create Vault Password Files

```bash
echo "DevTeamPassword123!" > .vault_dev

echo "ProdTeamPassword456!" > .vault_prod

chmod 600 .vault_dev .vault_prod
```

---

# 🔹 Create Vault ID File

```bash
ansible-vault create \
--vault-id dev@.vault_dev \
team_dev_secrets.yml
```

---

# 📄 `team_dev_secrets.yml`

```yaml
---
team_lead_email: "dev-lead@company.com"

team_slack_webhook: "https://hooks.slack.com/dev-team-webhook"
```

---

# 📄 Vault ID Playbook

## `vault_id_playbook.yml`

```yaml
---
- name: Multi Vault ID Demo
  hosts: localhost

  vars_files:
    - team_dev_secrets.yml
    - db_secrets.yml

  tasks:

    - name: Show team info
      debug:
        msg: |
          Team Lead: {{ team_lead_email }}

    - name: Show DB info
      debug:
        msg: |
          Database Host: {{ db_host }}
```

---

# ▶️ Run with Multiple Vault IDs

```bash
ansible-playbook vault_id_playbook.yml \
--vault-id dev@.vault_dev \
--vault-id prod@.vault_password
```

---

# ⚠️ Troubleshooting

---

# ❌ Issue: Decryption Failed

## ✅ Solution

```bash
ansible-vault view db_secrets.yml \
--vault-password-file .vault_password
```

---

# ❌ Issue: Permission Denied

## ✅ Fix Permissions

```bash
chmod 600 .vault_password
```

---

# ❌ Issue: Variables Not Loading

## ✅ Verify File

```bash
ls -la db_secrets.yml
```

---

# 🏆 Security Best Practices

| ✅ Best Practice | 🔐 Description |
|---|---|
| Use restrictive permissions | chmod 600 |
| Never commit passwords | Keep out of Git |
| Use different vault passwords | Separate environments |
| Rotate passwords regularly | Improve security |
| Avoid debug secrets | Protect credentials |
| Use `no_log: true` | Hide sensitive output |

---

# 🎉 Conclusion

In this lab you learned:

✅ How to encrypt sensitive data  
✅ Secure credential management  
✅ Environment-specific secret handling  
✅ Vault IDs and password files  
✅ Production-ready automation security  

---

# 🚀 Why Ansible Vault Matters

## 🔐 Security

Protects sensitive automation data.

## 👥 Collaboration

Teams can safely share playbooks.

## ☁️ Enterprise Ready

Supports production-grade security practices.

## 🎓 Career Growth

Essential for:

- RHCE Certification
- DevOps Engineering
- Cloud Security
- Automation Engineering

---

# 📈 Next Steps

✅ Practice secure automation  
✅ Explore advanced vault integrations  
✅ Learn Ansible roles and collections  
✅ Build enterprise-grade secure playbooks  

---

<div align="center">

# ⭐ Secure Automation Starts Here ⭐

![Vault](https://img.shields.io/badge/Vault-Security-important?style=for-the-badge)
![Ansible](https://img.shields.io/badge/Ansible-Automation-red?style=for-the-badge&logo=ansible)
![DevOps](https://img.shields.io/badge/DevOps-Engineer-blue?style=for-the-badge)

</div>
