# 👥 Automating User Management with Ansible

<div align="center">

![Ansible](https://img.shields.io/badge/Automation-Ansible-red?style=for-the-badge&logo=ansible)
![Linux](https://img.shields.io/badge/Platform-Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![RHEL](https://img.shields.io/badge/RHEL-8-red?style=for-the-badge&logo=redhat)
![YAML](https://img.shields.io/badge/Language-YAML-black?style=for-the-badge&logo=yaml)
![SSH](https://img.shields.io/badge/Access-SSH-green?style=for-the-badge&logo=gnu-bash)
![Security](https://img.shields.io/badge/Security-User%20Management-blue?style=for-the-badge&logo=securityscorecard)
![DevOps](https://img.shields.io/badge/DevOps-Automation-blueviolet?style=for-the-badge&logo=azuredevops)

</div>

---

# 📚 Lab Overview

This lab demonstrates how to automate Linux user management using **Ansible** in enterprise environments.

You will learn how to:

- 👤 Create and remove users
- 🔐 Configure passwords and expiration policies
- 👥 Manage groups and memberships
- 🔑 Configure SSH key authentication
- 🛡️ Implement RBAC (Role-Based Access Control)
- 📋 Generate audit and compliance reports

---

# 🎯 Objectives

By the end of this lab, students will be able to:

- ✅ Create Ansible playbooks for user provisioning
- ✅ Automate user creation and removal
- ✅ Configure account expiration policies
- ✅ Implement automated group management
- ✅ Apply enterprise security best practices
- ✅ Generate audit and compliance reports

---

# 🧰 Prerequisites

Before starting this lab, students should have:

| 🔹 Requirement | 📖 Description |
|---|---|
| 🐧 Linux Basics | Understanding Linux users & permissions |
| 📝 YAML | Familiarity with YAML syntax |
| ⚙️ Ansible | Basic knowledge of playbooks and modules |
| 🔐 SSH | SSH key authentication knowledge |
| 💻 CLI Experience | Comfort using terminal commands |

---

# 🖥️ Lab Environment

<div align="center">

![Cloud](https://img.shields.io/badge/Environment-Al%20Nafi%20Cloud-blue?style=for-the-badge&logo=icloud)

</div>

| 🖧 Component | 📋 Description |
|---|---|
| 🎛️ Control Node | CentOS/RHEL 8 with Ansible installed |
| 🖥️ Managed Nodes | node1 & node2 |
| 🔗 Connectivity | Pre-configured SSH access |
| 👑 Permissions | Sudo privileges enabled |

---

# 📁 Project Structure

```text
ansible-user-lab/
├── inventory/
│   └── hosts
├── playbooks/
├── group_vars/
├── host_vars/
└── audit_reports/
```

---

# ⚙️ Task 1 — Creating Basic User Management Playbooks

---

## 🔹 Subtask 1.1 — Create Directory Structure & Inventory

<div align="left">

![Directory](https://img.shields.io/badge/Setup-Directories-orange?style=flat-square&logo=gnubash)

</div>

### 🛠️ Create Project Structure

```bash
mkdir -p ~/ansible-user-lab/{playbooks,inventory,group_vars,host_vars}

cd ~/ansible-user-lab
```

---

### 🛠️ Create Inventory File

```bash
cat > inventory/hosts << EOF
[webservers]
node1 ansible_host=192.168.1.10
node2 ansible_host=192.168.1.11

[all:vars]
ansible_user=ansible
ansible_ssh_private_key_file=~/.ssh/id_rsa
EOF
```

---

### 🛠️ Test Connectivity

<div align="left">

![SSH](https://img.shields.io/badge/Protocol-SSH-green?style=flat-square&logo=gnu-bash)

</div>

```bash
ansible -i inventory/hosts all -m ping
```

---

# 👤 Subtask 1.2 — Create User Addition Playbook

<div align="left">

![Users](https://img.shields.io/badge/User-Management-blue?style=flat-square&logo=linux)

</div>

---

## 🛠️ Create `add_users.yml`

```yaml
---
- name: Add Users to Managed Systems
  hosts: all
  become: yes

  vars:
    users_to_add:

      - username: john_doe
        full_name: "John Doe"
        shell: /bin/bash
        groups: ["users", "developers"]

      - username: jane_smith
        full_name: "Jane Smith"
        shell: /bin/bash
        groups: ["users", "admins"]

  tasks:

    - name: Ensure required groups exist
      group:
        name: "{{ item }}"
        state: present
      loop:
        - users
        - developers
        - admins

    - name: Create users
      user:
        name: "{{ item.username }}"
        comment: "{{ item.full_name }}"
        shell: "{{ item.shell }}"
        groups: "{{ item.groups | join(',') }}"
        state: present

      loop: "{{ users_to_add }}"
```

---

## 🔐 Generate Password Hashes

<div align="left">

![Security](https://img.shields.io/badge/Security-Password%20Hashing-red?style=flat-square&logo=securityscorecard)

</div>

```bash
python3 -c "import crypt; print(crypt.crypt('johnpass123', crypt.mksalt(crypt.METHOD_SHA512)))"
```

```bash
python3 -c "import crypt; print(crypt.crypt('janepass456', crypt.mksalt(crypt.METHOD_SHA512)))"
```

---

## ▶️ Execute Playbook

```bash
ansible-playbook -i inventory/hosts playbooks/add_users.yml
```

---

# ❌ Subtask 1.3 — Create User Removal Playbook

<div align="left">

![Delete](https://img.shields.io/badge/User-Removal-critical?style=flat-square&logo=trash)

</div>

---

## 🛠️ Create `remove_users.yml`

```yaml
---
- name: Remove Users from Managed Systems
  hosts: all
  become: yes

  vars:
    users_to_remove:
      - username: temp_user
        remove_home: yes

  tasks:

    - name: Remove users
      user:
        name: "{{ item.username }}"
        state: absent
        remove: "{{ item.remove_home }}"

      loop: "{{ users_to_remove }}"
```

---

## ▶️ Execute Playbook

```bash
ansible-playbook -i inventory/hosts playbooks/remove_users.yml
```

---

# 🔐 Task 2 — Password Policies & Expiration

---

## 🔹 Subtask 2.1 — Password Policy Management

<div align="left">

![Policy](https://img.shields.io/badge/Policy-Password-blue?style=flat-square&logo=1password)

</div>

---

## 🛠️ Create `password_policy.yml`

```yaml
---
- name: Configure Password Policies
  hosts: all
  become: yes

  vars:
    password_policy_users:

      - username: security_admin
        password_max_age: 90
        password_warn_age: 7

      - username: contractor
        password_max_age: 30
        password_warn_age: 5

  tasks:

    - name: Create users
      user:
        name: "{{ item.username }}"
        state: present

      loop: "{{ password_policy_users }}"

    - name: Configure password aging
      shell: |
        chage -M {{ item.password_max_age }} {{ item.username }}
        chage -W {{ item.password_warn_age }} {{ item.username }}

      loop: "{{ password_policy_users }}"
```

---

## ▶️ Execute Playbook

```bash
ansible-playbook -i inventory/hosts playbooks/password_policy.yml
```

---

# 🔑 Subtask 2.2 — SSH Key Management

<div align="left">

![SSH Keys](https://img.shields.io/badge/SSH-Key%20Management-green?style=flat-square&logo=openssh)

</div>

---

## 🛠️ Create `ssh_key_management.yml`

```yaml
---
- name: Manage SSH Keys
  hosts: all
  become: yes

  vars:
    ssh_key_users:

      - username: john_doe
        ssh_keys:
          - "ssh-rsa AAAAB3..."

  tasks:

    - name: Create .ssh directory
      file:
        path: "/home/{{ item.username }}/.ssh"
        state: directory
        mode: '0700'

      loop: "{{ ssh_key_users }}"

    - name: Add authorized keys
      authorized_key:
        user: "{{ item.0.username }}"
        key: "{{ item.1 }}"
        state: present

      with_subelements:
        - "{{ ssh_key_users }}"
        - ssh_keys
```

---

## ▶️ Execute Playbook

```bash
ansible-playbook -i inventory/hosts playbooks/ssh_key_management.yml
```

---

# 👥 Task 3 — Group Membership Management

---

## 🔹 Subtask 3.1 — Dynamic Group Management

<div align="left">

![Groups](https://img.shields.io/badge/Groups-Management-purple?style=flat-square&logo=googleclassroom)

</div>

---

## 🛠️ Create `group_management.yml`

```yaml
---
- name: Group Management
  hosts: all
  become: yes

  vars:
    organizational_groups:

      - name: developers
        gid: 3001

      - name: sysadmins
        gid: 3002

  tasks:

    - name: Create groups
      group:
        name: "{{ item.name }}"
        gid: "{{ item.gid }}"
        state: present

      loop: "{{ organizational_groups }}"
```

---

## ▶️ Execute Playbook

```bash
ansible-playbook -i inventory/hosts playbooks/group_management.yml
```

---

# 🛡️ Subtask 3.2 — RBAC Implementation

<div align="left">

![RBAC](https://img.shields.io/badge/Security-RBAC-red?style=flat-square&logo=auth0)

</div>

---

## 🛠️ Create `rbac_implementation.yml`

```yaml
---
- name: Implement RBAC
  hosts: all
  become: yes

  vars:
    rbac_roles:

      - role_name: web_developers
        members:
          - john_doe
          - alice_dev

  tasks:

    - name: Create RBAC groups
      group:
        name: "{{ item.role_name }}"
        state: present

      loop: "{{ rbac_roles }}"
```

---

## ▶️ Execute Playbook

```bash
ansible-playbook -i inventory/hosts playbooks/rbac_implementation.yml
```

---

# 📋 Subtask 3.3 — User Audit & Compliance Reporting

<div align="left">

![Audit](https://img.shields.io/badge/Audit-Compliance-blue?style=flat-square&logo=datadog)

</div>

---

## 🛠️ Create `user_audit.yml`

```yaml
---
- name: Generate User Audit Reports
  hosts: all
  become: yes

  tasks:

    - name: Generate audit report
      shell: |
        getent passwd > /tmp/user_audit.txt
```

---

## ▶️ Execute Playbook

```bash
ansible-playbook -i inventory/hosts playbooks/user_audit.yml
```

---

## 📄 Review Audit Reports

```bash
ls -la audit_reports/
```

```bash
cat audit_reports/user_audit_node1_*.txt
```

---

# 🛠️ Troubleshooting Guide

---

# ❌ Issue 1 — Permission Denied Errors

```bash
sudo visudo
```

```bash
ansible ALL=(ALL) NOPASSWD: ALL
```

---

# ❌ Issue 2 — Password Hash Failures

```bash
python3 -c "import crypt; print(crypt.crypt('testpass', crypt.mksalt(crypt.METHOD_SHA512)))"
```

---

# ❌ Issue 3 — Group Membership Problems

```bash
ansible -i inventory/hosts all -m shell -a "groups username"
```

---

# ❌ Issue 4 — SSH Key Authentication Problems

```bash
ansible -i inventory/hosts all -m shell -a "ls -la /home/username/.ssh/"
```

---

# 🔐 Security Best Practices

<div align="left">

![Security](https://img.shields.io/badge/BestPractices-Security-success?style=flat-square&logo=securityscorecard)

</div>

---

## 🔒 Password Security

- Use strong password hashes
- Enforce password expiration
- Force password changes for new users

---

## 🔑 SSH Security

- Use RSA 2048+ or Ed25519 keys
- Rotate SSH keys regularly
- Prefer key authentication over passwords

---

## 👥 Group Management

- Apply least privilege principle
- Audit memberships regularly
- Implement RBAC models

---

# ⚡ Ansible Best Practices

---

## 📋 Playbook Organization

- Use descriptive task names
- Use variables for flexibility
- Implement proper error handling

---

## 🛡️ Security

- Store secrets in Ansible Vault
- Validate sudo configurations
- Use `become` carefully

---

## 🧪 Testing

- Use check mode
- Test in development environments
- Implement rollback procedures

---

# 🎓 Skills Developed

<div align="center">

![DevOps](https://img.shields.io/badge/Skill-DevOps-blue?style=for-the-badge&logo=azuredevops)

![RHCE](https://img.shields.io/badge/Certification-RHCE-red?style=for-the-badge&logo=redhat)

</div>

| 💼 Skill | 📖 Description |
|---|---|
| 👤 User Provisioning | Automated account creation |
| 🔐 Password Policies | Secure account management |
| 👥 Group Management | Membership automation |
| 🛡️ RBAC | Role-based access control |
| 📋 Auditing | Compliance reporting |
| ⚙️ Automation | Enterprise user management |

---

# 🌍 Real-World Applications

This lab prepares you for:

- 🧑‍💻 DevOps Engineering
- ☁️ Cloud Administration
- 🛠️ Linux System Administration
- 🔐 Security Operations
- 🎯 RHCE Certification

---

# 🏁 Conclusion

In this lab, you successfully learned how to automate Linux user management using **Ansible**.

You now understand how to:

- ✅ Automate user provisioning
- ✅ Configure password policies
- ✅ Manage SSH authentication
- ✅ Implement RBAC
- ✅ Generate audit reports
- ✅ Apply enterprise security standards

These skills are essential for modern enterprise infrastructure and DevOps operations.

---

# 👨‍💻 Author

<div align="center">

![GitHub](https://img.shields.io/badge/GitHub-README-black?style=for-the-badge&logo=github)

### ⭐ If this repository helped you, consider giving it a star!

</div>

---
