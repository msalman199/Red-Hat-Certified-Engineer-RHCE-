# 👥 Automating User and Group Management with Ansible

<p align="center">

![Ansible](https://img.shields.io/badge/Automation-Ansible-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Linux](https://img.shields.io/badge/Platform-Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![YAML](https://img.shields.io/badge/Language-YAML-CB171E?style=for-the-badge&logo=yaml&logoColor=white)
![Security](https://img.shields.io/badge/Security-ACL%20Management-blue?style=for-the-badge)
![DevOps](https://img.shields.io/badge/DevOps-Infrastructure%20Automation-orange?style=for-the-badge)
![RHCE](https://img.shields.io/badge/RHCE-Ansible%20Lab-red?style=for-the-badge)

</p>

---

# 📚 Overview

This lab demonstrates how to automate **Linux user and group management** using **Ansible playbooks**.  
You will learn how to:

- Create users and groups automatically
- Configure password policies
- Implement ACL permissions
- Apply enterprise security practices
- Troubleshoot common automation issues

---

# 🎯 Objectives

By the end of this lab, you will be able to:

✅ Create and execute Ansible playbooks for user management  
✅ Configure multiple users with group assignments  
✅ Set password expiration and password aging policies  
✅ Manage ACL permissions using Ansible ACL module  
✅ Apply enterprise-level security best practices  
✅ Troubleshoot common Ansible user management issues  

---

# 📋 Prerequisites

Before starting this lab, ensure you have:

- Basic Linux command-line knowledge
- Familiarity with YAML syntax
- Understanding of Linux users/groups
- Knowledge of Linux file permissions
- Basic Ansible concepts
- Access to a text editor (`vim` or `nano`)

---

# 🖥️ Lab Environment Setup

## ☁️ Ready-to-Use Cloud Machines

Al Nafi provides pre-configured Linux cloud systems with:

- CentOS/RHEL 8 or Ubuntu 20.04
- Ansible 2.9+
- Python 3.6+
- SSH configured
- Required utilities pre-installed

---

# 📁 Task 1: Automate User and Group Management

---

# 🔹 Subtask 1.1 — Create Project Directory Structure

```bash
mkdir -p ~/ansible-user-management
cd ~/ansible-user-management
mkdir -p group_vars host_vars roles
```

---

# 🔹 Subtask 1.2 — Create Inventory File

```bash
cat > inventory << 'EOF'
[webservers]
localhost ansible_connection=local

[all:vars]
ansible_python_interpreter=/usr/bin/python3
EOF
```

---

# 🔹 Subtask 1.3 — Create Main User Management Playbook

```bash
cat > user-management.yml << 'EOF'
---
- name: Automate User and Group Management
  hosts: webservers
  become: yes

  vars:
    user_groups:
      - name: developers
        gid: 3001

      - name: testers
        gid: 3002

      - name: admins
        gid: 3003

    system_users:
      - username: alice
        full_name: "Alice Johnson"
        primary_group: developers
        secondary_groups:
          - admins
        shell: /bin/bash
        create_home: yes
        password: "$6$rounds=656000$salt$encrypted_password_here"

      - username: bob
        full_name: "Bob Smith"
        primary_group: testers
        secondary_groups:
          - developers
        shell: /bin/bash
        create_home: yes
        password: "$6$rounds=656000$salt$encrypted_password_here"

      - username: charlie
        full_name: "Charlie Brown"
        primary_group: admins
        secondary_groups: []
        shell: /bin/bash
        create_home: yes
        password: "$6$rounds=656000$salt$encrypted_password_here"

  tasks:

    - name: Create system groups
      group:
        name: "{{ item.name }}"
        gid: "{{ item.gid }}"
        state: present
      loop: "{{ user_groups }}"
      tags: groups

    - name: Create system users
      user:
        name: "{{ item.username }}"
        comment: "{{ item.full_name }}"
        group: "{{ item.primary_group }}"
        groups: "{{ item.secondary_groups | join(',') if item.secondary_groups else omit }}"
        shell: "{{ item.shell }}"
        create_home: "{{ item.create_home }}"
        password: "{{ item.password }}"
        state: present
      loop: "{{ system_users }}"
      tags: users

    - name: Display created users information
      debug:
        msg: "User {{ item.username }} created with primary group {{ item.primary_group }}"
      loop: "{{ system_users }}"
      tags: info
EOF
```

---

# 🔹 Subtask 1.4 — Generate Encrypted Passwords

```bash
python3 -c "import crypt; print(crypt.crypt('password123', crypt.mksalt(crypt.METHOD_SHA512)))"
```

Replace encrypted password placeholders in the playbook.

---

# 🔹 Subtask 1.5 — Execute Playbook

```bash
ansible-playbook -i inventory user-management.yml --tags groups,users
```

---

# 🔹 Subtask 1.6 — Verify Users and Groups

## Check Groups

```bash
getent group developers testers admins
```

## Check Users

```bash
getent passwd alice bob charlie
```

## Verify Group Membership

```bash
groups alice bob charlie
```

---

# 🔐 Task 2: Configure Password Policies

---

# 🔹 Subtask 2.1 — Create Password Policy Playbook

```bash
cat > password-policy.yml << 'EOF'
---
- name: Configure User Password Policies
  hosts: webservers
  become: yes

  vars:
    password_policies:

      - username: alice
        max_days: 90
        min_days: 7
        warn_days: 14
        expire_date: "2024-12-31"

      - username: bob
        max_days: 60
        min_days: 5
        warn_days: 10
        expire_date: "2024-11-30"

      - username: charlie
        max_days: 180
        min_days: 14
        warn_days: 21
        expire_date: "2025-06-30"

  tasks:

    - name: Set password aging policies
      shell: |
        chage -M {{ item.max_days }} {{ item.username }}
        chage -m {{ item.min_days }} {{ item.username }}
        chage -W {{ item.warn_days }} {{ item.username }}
      loop: "{{ password_policies }}"

    - name: Set account expiration dates
      user:
        name: "{{ item.username }}"
        expires: "{{ (item.expire_date + ' 00:00:00') | to_datetime('%Y-%m-%d %H:%M:%S') | int }}"
      loop: "{{ password_policies }}"
EOF
```

---

# 🔹 Subtask 2.2 — Execute Password Policy Playbook

```bash
ansible-playbook -i inventory password-policy.yml
```

---

# 🔹 Subtask 2.3 — Verify Password Policies

```bash
for user in alice bob charlie; do
    echo "Password policy for $user:"
    chage -l $user
    echo "---"
done
```

---

# 🛡️ Task 3: Configure ACL Permissions

---

# 🔹 Subtask 3.1 — Create ACL Setup Playbook

```bash
cat > acl-setup.yml << 'EOF'
---
- name: Setup ACL Testing Environment
  hosts: webservers
  become: yes

  tasks:

    - name: Install ACL package
      package:
        name: acl
        state: present

    - name: Create project directories
      file:
        path: "{{ item }}"
        state: directory
        mode: '0775'
      loop:
        - /opt/projects
        - /opt/projects/web-app
        - /opt/projects/testing
        - /opt/projects/admin
EOF
```

---

# 🔹 Subtask 3.2 — Create ACL Permissions Playbook

```bash
cat > acl-permissions.yml << 'EOF'
---
- name: Configure ACL Permissions
  hosts: webservers
  become: yes

  tasks:

    - name: Configure ACL for developers
      acl:
        path: /opt/projects/web-app
        entity: developers
        etype: group
        permissions: rwx
        state: present

    - name: Configure ACL for testers
      acl:
        path: /opt/projects/testing
        entity: testers
        etype: group
        permissions: rwx
        state: present

    - name: Configure ACL for admins
      acl:
        path: /opt/projects/admin
        entity: admins
        etype: group
        permissions: rwx
        state: present
EOF
```

---

# 🔹 Subtask 3.3 — Execute ACL Playbooks

```bash
ansible-playbook -i inventory acl-setup.yml
```

```bash
ansible-playbook -i inventory acl-permissions.yml
```

---

# 🔹 Subtask 3.4 — Verify ACLs

```bash
getfacl /opt/projects/web-app
```

```bash
getfacl /opt/projects/testing
```

```bash
getfacl /opt/projects/admin
```

---

# 🧪 Manual ACL Testing

## Test Alice Access

```bash
sudo -u alice ls -la /opt/projects/web-app/
```

## Test Bob Access

```bash
sudo -u bob ls -la /opt/projects/testing/
```

---

# ⚠️ Troubleshooting Common Issues

---

# ❌ Issue 1 — Permission Denied

## Solution

```bash
mount | grep acl
```

Enable ACL support:

```bash
sudo mount -o remount,acl /
```

---

# ❌ Issue 2 — Password Not Working

## Generate New Password Hash

```bash
python3 -c "import crypt; print(crypt.crypt('newpassword', crypt.mksalt(crypt.METHOD_SHA512)))"
```

---

# ❌ Issue 3 — Group Membership Missing

## Verify Membership

```bash
groups username
```

## Add User to Group

```bash
sudo usermod -a -G groupname username
```

---

# ❌ Issue 4 — ACL Module Missing

## Install ACL Package

### RHEL/CentOS

```bash
sudo yum install acl -y
```

### Ubuntu/Debian

```bash
sudo apt-get install acl -y
```

---

# 🔒 Security Best Practices

## Password Security

✅ Use encrypted passwords  
✅ Apply password aging policies  
✅ Force password changes  
✅ Use strong password complexity  

---

## ACL Best Practices

✅ Follow least privilege principle  
✅ Audit ACL permissions regularly  
✅ Use groups instead of individual ACLs  
✅ Document permission assignments  

---

## Playbook Best Practices

✅ Use Ansible Vault for secrets  
✅ Use variables for reusable configurations  
✅ Tag tasks for selective execution  
✅ Implement error handling  

---

# ⚡ Performance Optimization Playbook

```bash
cat > optimized-user-management.yml << 'EOF'
---
- name: Optimized User Management
  hosts: webservers
  become: yes

  tasks:

    - name: Install required packages
      package:
        name:
          - shadow-utils
          - acl
          - passwd
        state: present

    - name: Create groups
      group:
        name: "{{ item }}"
        state: present
      loop:
        - developers
        - testers
        - admins

    - name: Create users
      user:
        name: "{{ item }}"
        shell: /bin/bash
        create_home: yes
        state: present
      loop:
        - alice
        - bob
        - charlie
EOF
```

---

# 📊 Verification Commands

## Verify Groups

```bash
getent group developers testers admins
```

## Verify Users

```bash
getent passwd alice bob charlie
```

## Verify ACLs

```bash
getfacl /opt/projects/web-app
```

## Verify Password Policies

```bash
chage -l alice
```

---

# 🎓 Key Concepts Learned

- Linux User Automation
- Linux Group Automation
- Password Expiration Policies
- ACL Management
- Enterprise Security Practices
- Infrastructure as Code
- Ansible Playbook Development
- System Administration Automation

---

# 🚀 Why This Lab Matters

This lab provides real-world skills required for:

- Enterprise Linux Administration
- DevOps Automation
- Infrastructure as Code
- Security Compliance
- RHCE Certification Preparation

---

# 📈 Next Steps

After completing this lab, continue learning:

- 🔐 Ansible Vault
- 🌐 LDAP / Active Directory Integration
- ⚙️ Advanced RBAC Systems
- 📦 Ansible Roles
- ☁️ Cloud Automation
- 🔄 CI/CD Pipelines

---

# 🏆 Conclusion

In this lab, you successfully:

✅ Automated Linux user management  
✅ Configured groups and permissions  
✅ Implemented password security policies  
✅ Managed ACL permissions  
✅ Applied enterprise security practices  
✅ Built reusable Infrastructure as Code solutions  

These automation skills are essential for:

- Linux System Administrators
- DevOps Engineers
- Cloud Engineers
- RHCE Candidates
- Security Engineers

---

# ❤️ Happy Automating with Ansible

<p align="center">

🚀 Linux • 🔥 Ansible • ⚙️ Automation • 🔐 Security • ☁️ DevOps

</p>
