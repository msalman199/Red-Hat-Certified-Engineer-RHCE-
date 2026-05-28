# 🔐 Securing Sensitive Data with Ansible Vault

<p align="center">
  <img src="https://img.shields.io/badge/Automation-Ansible-red?style=for-the-badge&logo=ansible">
  <img src="https://img.shields.io/badge/Security-Ansible_Vault-black?style=for-the-badge&logo=redhat">
  <img src="https://img.shields.io/badge/Linux-RHEL%20%7C%20Ubuntu-blue?style=for-the-badge&logo=linux">
  <img src="https://img.shields.io/badge/Level-RHCE-green?style=for-the-badge">
</p>

---

# 📚 Lab Overview

This lab demonstrates how to secure sensitive data using **Ansible Vault** for enterprise-grade automation environments.

You will learn how to:

- Encrypt secrets and credentials
- Secure playbooks using Vault
- Manage vault passwords
- Use multiple vault IDs
- Rotate credentials securely
- Create vault utility scripts
- Apply security best practices in production

---

# 🎯 Objectives

By the end of this lab, you will be able to:

✅ Create and encrypt sensitive variables using `ansible-vault`  
✅ Use encrypted variables in playbooks  
✅ Implement Vault for secure credential handling  
✅ Configure vault passwords for teams  
✅ Manage multiple vault IDs  
✅ Apply Vault security best practices  

---

# 🧰 Prerequisites

Before starting this lab, you should have:

- Basic Ansible knowledge
- Familiarity with YAML syntax
- Linux command line experience
- Understanding of permissions/security
- Previous Ansible lab experience

---

# 🖥️ Lab Environment

## ☁️ Environment Includes

| Component | Details |
|---|---|
| OS | CentOS/RHEL 8 or Ubuntu 20.04 |
| Automation Tool | Ansible 4.0+ |
| Editors | vim, nano |
| Inventory | Pre-configured |
| Network | Connected nodes |

---

# 🚀 Task 1: Create and Encrypt Sensitive Variables

---

# 📖 Subtask 1.1: Understanding Ansible Vault Basics

## 🔑 Key Concepts

| Concept | Description |
|---|---|
| Vault | Encrypted storage |
| Vault Password | Encryption/decryption key |
| Vault ID | Multiple vault labels |

---

# 📂 Subtask 1.2: Create First Encrypted Variable File

## 📁 Create Working Directory

```bash
cd /home/student/ansible-labs
mkdir lab13-vault
cd lab13-vault
```

---

# 📝 Create Secrets File

```bash
cat > secrets.yml << 'EOF'
# Database credentials
db_username: admin
db_password: SuperSecret123!
db_host: database.example.com
db_port: 5432

# API keys
api_key: abc123def456ghi789
secret_token: xyz987uvw654rst321

# SSH credentials
ssh_private_key_path: /home/admin/.ssh/id_rsa
ssh_passphrase: MySSHPassphrase2023
EOF
```

---

# 🔒 Encrypt Secrets File

```bash
ansible-vault encrypt secrets.yml
```

## Expected Prompt

```bash
New Vault password:
Confirm New Vault password:
```

---

# ✅ Verify Encryption

```bash
cat secrets.yml
```

Expected:

```bash
$ANSIBLE_VAULT;1.1;AES256
```

---

# 📦 Subtask 1.3: Create Production Secrets File

```bash
cat > prod-secrets.yml << 'EOF'
# Production database
prod_db_username: prod_admin
prod_db_password: Pr0d_S3cur3_P@ssw0rd!
prod_db_host: prod-db.company.com

# Production API credentials
prod_api_endpoint: https://api.production.company.com
prod_api_token: prod_abc123xyz789secure

# SSL certificates
ssl_cert_path: /etc/ssl/certs/company.crt
ssl_key_path: /etc/ssl/private/company.key
ssl_passphrase: SSL_Secure_2023!
EOF
```

---

# 🔐 Encrypt Production Secrets

```bash
ansible-vault encrypt prod-secrets.yml
```

---

# 🧪 Subtask 1.4: Encrypt Individual Strings

```bash
ansible-vault encrypt_string 'DatabasePassword123!' --name 'database_password'
```

---

# 📄 Secure Variables Playbook

```yaml
---
- name: Playbook with encrypted variables
  hosts: localhost

  vars:
    username: admin

    password: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          encrypted_data_here

  tasks:

    - name: Display username
      debug:
        msg: "Username: {{ username }}"

    - name: Use password securely
      debug:
        msg: "Password configured successfully"
```

---

# 🚀 Task 2: Use Encrypted Variables in Playbooks

---

# 🗄️ Subtask 2.1: Database Configuration Playbook

```bash
cat > database-setup.yml << 'EOF'
---
- name: Configure Database Connection
  hosts: localhost

  vars_files:
    - secrets.yml

  tasks:

    - name: Create database config
      copy:
        content: |
          [database]
          host={{ db_host }}
          port={{ db_port }}
          username={{ db_username }}
          password={{ db_password }}

          [api]
          key={{ api_key }}
          token={{ secret_token }}

        dest: /tmp/app-config.ini
        mode: '0600'

    - name: Verify permissions
      stat:
        path: /tmp/app-config.ini
      register: config_file

    - name: Show permissions
      debug:
        msg: "Permissions: {{ config_file.stat.mode }}"
EOF
```

---

# ▶️ Run Playbook

```bash
ansible-playbook database-setup.yml --ask-vault-pass
```

---

# 🌍 Subtask 2.2: Multi-Environment Deployment

---

# 📄 Create Inventory

```ini
[development]
dev-server ansible_host=localhost

[production]
prod-server ansible_host=localhost

[all:vars]
ansible_connection=local
```

---

# 🚀 Deployment Playbook

```yaml
---
- name: Deploy Secure Application
  hosts: all

  vars_files:
    - secrets.yml
    - "{{ environment }}-secrets.yml"

  vars:
    app_name: "MySecureApp"
    app_version: "1.0.0"

  tasks:

    - name: Create app directory
      file:
        path: "/opt/{{ app_name }}"
        state: directory
        mode: '0755'

    - name: Deploy config
      template:
        src: app-config.j2
        dest: "/opt/{{ app_name }}/config.yml"
        mode: '0600'

    - name: Display deployment summary
      debug:
        msg: |
          Application deployed successfully
          Environment: {{ environment }}
```

---

# 🧩 Jinja2 Template

```jinja2
# {{ app_name }} Configuration

application:
  name: {{ app_name }}
  version: {{ app_version }}
  environment: {{ environment }}

security:
  encryption_enabled: true
  vault_managed: true
```

---

# ▶️ Run Development Deployment

```bash
ansible-playbook deploy-app.yml \
-i inventory.ini \
--limit development \
--ask-vault-pass \
-e environment=dev
```

---

# ▶️ Run Production Deployment

```bash
ansible-playbook deploy-app.yml \
-i inventory.ini \
--limit production \
--ask-vault-pass \
-e environment=prod
```

---

# 👥 Subtask 2.3: User Management with Vault

---

# 🔐 User Secrets File

```bash
cat > user-secrets.yml << 'EOF'
users:
  - name: alice
    password: Alice_Secure_2023!
    groups: ['developers', 'sudo']

  - name: bob
    password: Bob_Admin_Pass_2023!
    groups: ['admins', 'sudo']
EOF
```

---

# 🔒 Encrypt User Secrets

```bash
ansible-vault encrypt user-secrets.yml
```

---

# 👨‍💻 User Management Playbook

```yaml
---
- name: Manage Users Securely
  hosts: localhost
  become: yes

  vars_files:
    - user-secrets.yml

  tasks:

    - name: Create users
      user:
        name: "{{ item.name }}"
        password: "{{ item.password | password_hash('sha512') }}"
        groups: "{{ item.groups }}"
        shell: /bin/bash
        create_home: yes
        state: present

      loop: "{{ users }}"
      no_log: true
```

---

# ▶️ Execute Playbook

```bash
ansible-playbook user-management.yml \
--ask-vault-pass \
--ask-become-pass
```

---

# 🚀 Task 3: Vault Password Management

---

# 🔑 Subtask 3.1: Vault Password File

## Create Secure Directory

```bash
mkdir -p ~/.ansible/vault
chmod 700 ~/.ansible/vault
```

---

# 📝 Create Vault Password File

```bash
echo "MyVaultPassword2023!" > ~/.ansible/vault/lab13_pass
chmod 600 ~/.ansible/vault/lab13_pass
```

---

# ⚙️ Configure ansible.cfg

```ini
[defaults]
host_key_checking = False
inventory = inventory.ini
vault_password_file = ~/.ansible/vault/lab13_pass

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False
```

---

# ▶️ Run Without Prompt

```bash
ansible-playbook database-setup.yml
```

---

# 🆔 Subtask 3.2: Multiple Vault IDs

---

# 🔐 Create Dev Vault Password

```bash
echo "DevVaultPass2023!" > ~/.ansible/vault/dev_pass
chmod 600 ~/.ansible/vault/dev_pass
```

---

# 🔐 Create Prod Vault Password

```bash
echo "ProdVaultPass2023!" > ~/.ansible/vault/prod_pass
chmod 600 ~/.ansible/vault/prod_pass
```

---

# 📄 Dev Secrets

```yaml
dev_database_url: "postgresql://dev:devpass@dev-db:5432/myapp"
dev_api_key: "dev_api_key_12345"
```

---

# 🔒 Encrypt Dev Secrets

```bash
ansible-vault encrypt dev-secrets.yml \
--vault-id dev@~/.ansible/vault/dev_pass
```

---

# 📄 Prod Secrets

```yaml
prod_database_url: "postgresql://prod:prodpass@prod-db:5432/myapp"
prod_api_key: "prod_api_key_abcdef"
```

---

# 🔒 Encrypt Prod Secrets

```bash
ansible-vault encrypt prod-secrets-multi.yml \
--vault-id prod@~/.ansible/vault/prod_pass
```

---

# ▶️ Run Multi Vault Playbook

```bash
ansible-playbook multi-vault-playbook.yml \
--vault-id dev@~/.ansible/vault/dev_pass \
--vault-id prod@~/.ansible/vault/prod_pass
```

---

# 🔄 Subtask 3.3: Credential Rotation

```yaml
---
- name: Rotate Credentials
  hosts: localhost

  vars_files:
    - secrets.yml

  tasks:

    - name: Generate new password
      set_fact:
        generated_password: "{{ lookup('password', '/dev/null chars=ascii_letters,digits length=20') }}"

    - name: Display success
      debug:
        msg: "Password rotated successfully"
```

---

# ▶️ Run Rotation

```bash
ansible-playbook rotate-credentials.yml
```

---

# 🛠️ Subtask 3.4: Vault Utility Scripts

---

# 👀 View Vault Script

```bash
#!/bin/bash

ansible-vault view "$1" \
--vault-password-file ~/.ansible/vault/lab13_pass
```

---

# ✏️ Edit Vault Script

```bash
#!/bin/bash

ansible-vault edit "$1" \
--vault-password-file ~/.ansible/vault/lab13_pass
```

---

# ❤️ Vault Health Check Script

```bash
#!/bin/bash

echo "Vault Health Check"

if [ -f ~/.ansible/vault/lab13_pass ]; then
    echo "Vault password file exists"
fi
```

---

# ▶️ Run Health Check

```bash
./vault-health-check.sh
```

---

# ✅ Verification & Testing

---

# 🔍 Verify Vault File

```bash
ansible-vault view secrets.yml \
--vault-password-file ~/.ansible/vault/lab13_pass
```

---

# ▶️ Test Playbook

```bash
ansible-playbook database-setup.yml
```

---

# 🔐 Verify File Permissions

```bash
ls -la *secrets*.yml
ls -la ~/.ansible/vault/
```

---

# 🧪 Test Vault Editing

```bash
echo "test_var: test_value" > test-vault.yml

ansible-vault encrypt test-vault.yml \
--vault-password-file ~/.ansible/vault/lab13_pass
```

---

# 🛠️ Troubleshooting Common Issues

---

# ❌ Issue 1: Vault Password Errors

## Problem

```bash
ERROR! Attempting to decrypt but no vault secrets found
```

## Solution

```bash
file secrets.yml

cat ~/.ansible/vault/lab13_pass

ansible-vault decrypt secrets.yml \
--vault-password-file ~/.ansible/vault/lab13_pass
```

---

# ❌ Issue 2: Permission Denied

## Solution

```bash
chmod 600 ~/.ansible/vault/lab13_pass
chmod 700 ~/.ansible/vault/
```

---

# ❌ Issue 3: Vault ID Conflict

## Solution

```bash
ansible-vault view secrets.yml \
--vault-id dev@~/.ansible/vault/dev_pass

ansible-vault view secrets.yml \
--vault-id prod@~/.ansible/vault/prod_pass
```

---

# ⭐ Best Practices Summary

---

# 🔑 Password Management

- Use strong passwords
- Rotate vault passwords
- Store passwords securely

---

# 📁 File Organization

- Separate environments
- Use naming standards
- Maintain secure permissions

---

# 🛡️ Security Best Practices

- Never commit passwords to Git
- Use `no_log: true`
- Audit vault access regularly

---

# ⚡ Automation Best Practices

- Use vault password files
- Automate credential rotation
- Create health check scripts

---

# 🎉 Conclusion

Congratulations! 🎊

You have successfully completed the lab:

# 🔐 Securing Sensitive Data with Ansible Vault

---

# 🏆 Skills Gained

✅ Encrypting secrets with Vault  
✅ Using encrypted variables in playbooks  
✅ Managing multiple vault IDs  
✅ Secure credential rotation  
✅ Creating vault utilities  
✅ Implementing enterprise security practices  

---

# 🌍 Real-World Applications

- Securing database credentials
- Protecting API keys
- Managing SSL certificates
- Securing CI/CD pipelines
- Enterprise automation security

---

# 🚀 Career Benefits

These skills are highly valuable for:

- DevOps Engineers
- Linux Administrators
- Cloud Engineers
- RHCE Certification Preparation
- Infrastructure Automation Roles

---

# 💡 Final Note

Ansible Vault is an essential tool for secure automation in modern DevOps environments. Mastering Vault enables you to build enterprise-grade secure infrastructure automation workflows.

---

# 👨‍💻 Author

## Hafiz Muhammad Salman

<p align="center">
  <img src="https://img.shields.io/badge/Cloud-DevOps_Engineer-blue?style=for-the-badge">
  <img src="https://img.shields.io/badge/Linux-Administrator-black?style=for-the-badge&logo=linux">
</p>

### 📧 Email
hafizmuhammadsalman13@gmail.com

### 🌐 GitHub
https://github.com/msalman199

### 📱 Mobile
+923143563640

---
