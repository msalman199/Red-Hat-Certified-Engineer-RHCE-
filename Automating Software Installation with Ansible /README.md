# 🚀 Automating Software Installation with Ansible

<div align="center">

![Ansible](https://img.shields.io/badge/Automation-Ansible-red?style=for-the-badge&logo=ansible)
![Linux](https://img.shields.io/badge/Platform-Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![RHEL](https://img.shields.io/badge/RHEL-8%2F9-red?style=for-the-badge&logo=redhat)
![YAML](https://img.shields.io/badge/Language-YAML-black?style=for-the-badge&logo=yaml)
![DevOps](https://img.shields.io/badge/DevOps-Automation-blue?style=for-the-badge&logo=azuredevops)
![SSH](https://img.shields.io/badge/Access-SSH-green?style=for-the-badge&logo=gnu-bash)
![Apache](https://img.shields.io/badge/WebServer-Apache-D22128?style=for-the-badge&logo=apache)
![MariaDB](https://img.shields.io/badge/Database-MariaDB-003545?style=for-the-badge&logo=mariadb)

</div>

---

# 📚 Lab Overview

This lab demonstrates how to automate software installation and infrastructure management using **Ansible** on Red Hat-based Linux systems.

---

# 🎯 Objectives

By the end of this lab, students will be able to:

- ✅ Create and execute Ansible playbooks
- ✅ Automate package installation using `dnf/yum`
- ✅ Configure Apache and MariaDB servers
- ✅ Implement package version control
- ✅ Configure automated updates
- ✅ Apply DevOps automation best practices

---

# 🧰 Prerequisites

Before starting this lab, students should have:

| 🔹 Requirement | 📖 Description |
|---|---|
| 🐧 Linux Basics | Basic Linux command-line knowledge |
| 📝 YAML | Understanding of YAML syntax |
| 🖥️ Red Hat Systems | Familiarity with CentOS/RHEL/Fedora |
| 🔐 SSH | SSH key authentication knowledge |
| 🌐 Networking | Basic networking concepts |

> 💡 **Note:** Al Nafi provides pre-configured cloud machines for this lab.

---

# 🖥️ Lab Environment

| 🖧 Component | 📋 Description |
|---|---|
| 🎛️ Control Node | CentOS/RHEL with Ansible installed |
| 🖥️ Managed Nodes | Multiple Linux target systems |
| 🔗 SSH Access | Secure SSH communication |
| 👑 User Access | Root or sudo privileges |

---

# 📁 Project Directory Structure

```text
ansible-lab7/
├── ansible.cfg
├── inventory/
│   └── hosts.yml
├── playbooks/
├── group_vars/
├── host_vars/
├── roles/
└── templates/
```

---

# ⚙️ Task 1 — Setting Up Ansible Environment

---

## 🔹 Subtask 1.1 — Verify Ansible Installation

<div align="left">

![Ansible](https://img.shields.io/badge/Tool-Ansible-red?style=flat-square&logo=ansible)

</div>

```bash
# Check Ansible version
ansible --version

# Verify Ansible configuration
ansible-config view
```

---

## 🔹 Subtask 1.2 — Create Project Structure

<div align="left">

![Linux](https://img.shields.io/badge/OS-Linux-FCC624?style=flat-square&logo=linux&logoColor=black)

</div>

```bash
# Create project directory
mkdir -p ~/ansible-lab7
cd ~/ansible-lab7

# Create folders
mkdir -p {playbooks,inventory,group_vars,host_vars,roles}

# Create files
touch inventory/hosts.yml
touch ansible.cfg
```

---

## 🔹 Subtask 1.3 — Configure Ansible Settings

<div align="left">

![YAML](https://img.shields.io/badge/Config-ansible.cfg-black?style=flat-square&logo=yaml)

</div>

```ini
[defaults]
inventory = inventory/hosts.yml
remote_user = root
host_key_checking = False
retry_files_enabled = False
gathering = smart
fact_caching = memory

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
pipelining = True
```

---

## 🔹 Subtask 1.4 — Create Inventory File

<div align="left">

![Inventory](https://img.shields.io/badge/Inventory-Hosts-blue?style=flat-square&logo=serverfault)

</div>

```yaml
all:
  children:

    webservers:
      hosts:
        web1:
          ansible_host: 192.168.1.10
        web2:
          ansible_host: 192.168.1.11

    databases:
      hosts:
        db1:
          ansible_host: 192.168.1.20

    development:
      hosts:
        dev1:
          ansible_host: 192.168.1.30

  vars:
    ansible_user: root
    ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

> ⚠️ Replace IP addresses with actual lab IPs.

---

## 🔹 Subtask 1.5 — Test Connectivity

<div align="left">

![SSH](https://img.shields.io/badge/Protocol-SSH-green?style=flat-square&logo=gnu-bash)

</div>

```bash
# Test connectivity
ansible all -m ping

# Gather system facts
ansible all -m setup --tree /tmp/facts
```

---

# 📦 Task 2 — Package Installation Playbooks

---

## 🔹 Subtask 2.1 — Basic Package Installation

<div align="left">

![DNF](https://img.shields.io/badge/PackageManager-DNF-blue?style=flat-square&logo=fedora)

</div>

```yaml
---
- name: Install Essential Packages
  hosts: all
  become: yes

  vars:
    common_packages:
      - vim
      - curl
      - wget
      - git
      - htop

  tasks:

    - name: Update package cache
      dnf:
        update_cache: yes

    - name: Install packages
      dnf:
        name: "{{ common_packages }}"
        state: present
```

---

## 🔹 Subtask 2.2 — Web Server Setup

<div align="left">

![Apache](https://img.shields.io/badge/WebServer-Apache-D22128?style=flat-square&logo=apache)

![PHP](https://img.shields.io/badge/Backend-PHP-777BB4?style=flat-square&logo=php)

</div>

```yaml
---
- name: Configure Web Servers
  hosts: webservers
  become: yes

  vars:
    web_packages:
      - httpd
      - php
      - php-mysql
      - php-fpm
      - mod_ssl

  tasks:

    - name: Install Apache & PHP
      dnf:
        name: "{{ web_packages }}"
        state: present

    - name: Start Apache
      systemd:
        name: httpd
        state: started
        enabled: yes
```

---

## 🔹 Subtask 2.3 — Database Server Setup

<div align="left">

![MariaDB](https://img.shields.io/badge/Database-MariaDB-003545?style=flat-square&logo=mariadb)

</div>

```yaml
---
- name: Configure Database Servers
  hosts: databases
  become: yes

  vars:
    db_packages:
      - mariadb-server
      - mariadb

  tasks:

    - name: Install MariaDB
      dnf:
        name: "{{ db_packages }}"
        state: present

    - name: Start MariaDB
      systemd:
        name: mariadb
        state: started
        enabled: yes
```

---

# ⚡ Task 3 — Advanced Package Management

---

## 🔹 Features Included

<div align="left">

![Automation](https://img.shields.io/badge/Automation-Advanced-blueviolet?style=flat-square&logo=ansible)

![Security](https://img.shields.io/badge/Security-Updates-red?style=flat-square&logo=securityscorecard)

![VersionControl](https://img.shields.io/badge/Version-Control-orange?style=flat-square&logo=git)

</div>

### ✨ Advanced Features

- 📦 Package Groups
- 🔄 Version Management
- 🧹 Cache Cleanup
- ❌ Remove Unwanted Packages
- 📋 Update Reports
- 🔒 Security Updates

---

## 🛠️ Example Advanced DNF Usage

```yaml
- name: Install EPEL repository
  dnf:
    name: epel-release
    state: present
```

---

# 🔄 Task 4 — Automated Updates & Maintenance

---

## 🔹 Automated Updates Features

<div align="left">

![Updates](https://img.shields.io/badge/System-Updates-success?style=flat-square&logo=linux)

![Monitoring](https://img.shields.io/badge/Monitoring-Reports-blue?style=flat-square&logo=grafana)

![Maintenance](https://img.shields.io/badge/Maintenance-Automation-purple?style=flat-square&logo=probot)

</div>

### ✔️ Includes

- 🔒 Security updates
- 🐞 Bugfix updates
- 🔁 Controlled rebooting
- 📸 System snapshots
- 📋 Detailed reporting
- 🛡️ Maintenance windows

---

# ▶️ Execute Playbooks

---

## 🚀 Run All Playbooks

```bash
# Install common packages
ansible-playbook playbooks/install-packages.yml -v

# Configure web servers
ansible-playbook playbooks/webserver-setup.yml -v

# Configure database servers
ansible-playbook playbooks/database-setup.yml -v

# Advanced package management
ansible-playbook playbooks/advanced-package-management.yml -v

# Version control
ansible-playbook playbooks/version-control.yml -v

# Dry-run updates
ansible-playbook playbooks/automated-updates.yml --check -v
```

---

# ✅ Verification & Testing

<div align="left">

![Testing](https://img.shields.io/badge/Testing-Verification-green?style=flat-square&logo=checkmarx)

</div>

```bash
ansible-playbook playbooks/verify-installation.yml -v
```

---

# 🛠️ Troubleshooting Guide

---

## ❌ SSH Problems

```bash
ssh -i ~/.ssh/id_rsa root@target_host
```

```bash
chmod 600 ~/.ssh/id_rsa
```

```bash
ssh-add ~/.ssh/id_rsa
```

---

## ❌ Package Installation Issues

```bash
ansible all -m shell -a "dnf repolist"
```

```bash
ansible all -m shell -a "dnf clean all"
```

```bash
ansible all -m shell -a "df -h"
```

---

## ❌ Service Failures

```bash
ansible all -m shell -a "systemctl status httpd"
```

```bash
ansible all -m shell -a "journalctl -u httpd -n 20"
```

```bash
ansible all -m shell -a "firewall-cmd --list-all"
```

---

# 🔐 Best Practices

---

## 🛡️ Security

- Use `become: yes`
- Use SSH key authentication
- Store secrets in Ansible Vault
- Apply least privilege access

---

## ⚡ Performance Optimization

- Use fact caching
- Enable SSH pipelining
- Use serial execution
- Group tasks logically

---

## 📋 Maintenance

- Maintain version control
- Use dry-run testing
- Implement rollback plans
- Enable detailed logging

---

# 🎓 Skills You Will Learn

<div align="left">

![DevOps](https://img.shields.io/badge/Skill-DevOps-blue?style=flat-square&logo=azuredevops)

![RHCE](https://img.shields.io/badge/Certification-RHCE-red?style=flat-square&logo=redhat)

![Cloud](https://img.shields.io/badge/Cloud-Automation-4285F4?style=flat-square&logo=googlecloud)

</div>

| 💼 Skill | 📖 Description |
|---|---|
| ⚙️ Automation | Infrastructure automation |
| 📦 Package Management | DNF/YUM administration |
| 🌐 Web Services | Apache deployment |
| 🗄️ Databases | MariaDB management |
| 🔄 Maintenance | Automated updates |
| 📋 Reporting | Monitoring & verification |

---

# 💼 Career Relevance

This lab prepares you for:

- 🧑‍💻 DevOps Engineering
- ☁️ Cloud Operations
- 🛠️ Linux System Administration
- 📈 Site Reliability Engineering (SRE)
- 🎯 RHCE Certification

---

# 🏁 Conclusion

In this lab, you successfully learned how to automate software installation and infrastructure management using **Ansible**.

You now understand how to:

- ✅ Create professional Ansible playbooks
- ✅ Automate package management
- ✅ Configure Apache & MariaDB servers
- ✅ Perform automated updates
- ✅ Apply DevOps best practices

These skills are highly valuable in modern enterprise environments and cloud infrastructure management.

