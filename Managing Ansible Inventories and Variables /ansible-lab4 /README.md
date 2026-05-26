# 🚀 Managing Ansible Inventories and Variables

<div align="center">

![Ansible](https://img.shields.io/badge/Ansible-Automation-red?style=for-the-badge&logo=ansible)
![Linux](https://img.shields.io/badge/Linux-RHEL%20%7C%20CentOS-blue?style=for-the-badge&logo=linux)
![YAML](https://img.shields.io/badge/YAML-Configuration-orange?style=for-the-badge&logo=yaml)
![DevOps](https://img.shields.io/badge/DevOps-Infrastructure-success?style=for-the-badge&logo=devops)
![Automation](https://img.shields.io/badge/Automation-Enterprise-purple?style=for-the-badge)

### 📚 Complete GitHub README Lab Guide for Managing Ansible Inventories and Variables

</div>

---

# 📖 Overview

This lab provides a complete hands-on guide to understanding and managing **Ansible inventories and variables** in enterprise environments.

You will learn how to:

- ✅ Create static inventories
- ✅ Organize hosts into logical groups
- ✅ Use host variables and group variables
- ✅ Apply variable precedence
- ✅ Implement dynamic targeting
- ✅ Structure enterprise inventory layouts
- ✅ Troubleshoot inventory-related issues

---

# 🎯 Objectives

By the end of this lab, you will be able to:

- ✅ Understand the difference between static and dynamic inventories in Ansible
- ✅ Create and manage static inventory files with proper formatting
- ✅ Configure host variables for different environments
- ✅ Implement group variables to target specific sets of machines
- ✅ Use variable precedence to control configuration inheritance
- ✅ Apply best practices for organizing inventory structures in enterprise environments

---

# 📋 Prerequisites

Before starting this lab, you should have:

- 🐧 Basic understanding of Linux command line operations
- 📝 Familiarity with YAML syntax and formatting
- ⚙️ Basic Ansible knowledge
- 🔐 Understanding of SSH key-based authentication
- ✏️ Familiarity with nano/vim text editors

---

# 🖥️ Lab Environment Setup

## ☁️ Ready-to-Use Cloud Machines

The lab environment includes:

| Component | Description |
|---|---|
| 🖥️ Control Node | CentOS/RHEL 8 with Ansible installed |
| 🌐 Managed Nodes | 3 Target Servers |
| 🔑 SSH Connectivity | Pre-configured between nodes |
| 🛠️ Dependencies | All required packages installed |

---

# 📁 Recommended Project Structure

```bash
ansible-lab4/
├── inventory.ini
├── inventory-dev.ini
├── inventory-prod.ini
├── host_vars/
│   ├── dev-web1.yml
│   └── prod-web1.yml
├── group_vars/
│   ├── webservers.yml
│   ├── databases.yml
│   └── production.yml
├── test-host-vars.yml
├── group-targeting-demo.yml
├── variable-precedence-test.yml
├── dynamic-targeting.yml
└── inventories/
    ├── development/
    ├── staging/
    └── production/
```

---

# 🧩 Task 1: Understanding and Creating Static Inventories

## 🔹 Subtask 1.1 — Explore Default Inventory Structure

### 📂 Navigate to Ansible Directory

```bash
cd /etc/ansible
ls -la
```

### 📄 View Default Hosts File

```bash
cat hosts
```

### 🏗️ Create Working Directory

```bash
mkdir -p ~/ansible-lab4
cd ~/ansible-lab4
```

---

## 🔹 Subtask 1.2 — Create a Basic Static Inventory

### 📝 Create Inventory File

```bash
nano inventory.ini
```

### 📄 Add Inventory Configuration

```ini
# Basic Static Inventory for Lab 4

# Web Servers Group
[webservers]
web1 ansible_host=192.168.1.10 ansible_user=centos
web2 ansible_host=192.168.1.11 ansible_user=centos

# Database Servers Group
[databases]
db1 ansible_host=192.168.1.20 ansible_user=centos
db2 ansible_host=192.168.1.21 ansible_user=centos

# Load Balancer Group
[loadbalancers]
lb1 ansible_host=192.168.1.30 ansible_user=centos

# Parent Groups
[frontend:children]
webservers
loadbalancers

[backend:children]
databases

# All Production Servers
[production:children]
frontend
backend
```

### 💾 Save File

```text
CTRL + X → Y → ENTER
```

---

## 🔹 Subtask 1.3 — Test Static Inventory

### ✅ Verify Inventory Syntax

```bash
ansible-inventory -i inventory.ini --list
```

### 🌐 Ping All Hosts

```bash
ansible -i inventory.ini all -m ping
```

### 🖥️ Ping Web Servers

```bash
ansible -i inventory.ini webservers -m ping
```

### 🗄️ Ping Database Servers

```bash
ansible -i inventory.ini databases -m ping
```

---

# 🌍 Task 2: Setting Up Host Variables for Different Environments

## 🔹 Subtask 2.1 — Create Environment-Specific Inventories

### 🧪 Development Environment Inventory

```bash
nano inventory-dev.ini
```

```ini
# Development Environment Inventory

[webservers]
dev-web1 ansible_host=192.168.1.100 ansible_user=centos environment=development
dev-web2 ansible_host=192.168.1.101 ansible_user=centos environment=development

[databases]
dev-db1 ansible_host=192.168.1.110 ansible_user=centos environment=development

[loadbalancers]
dev-lb1 ansible_host=192.168.1.120 ansible_user=centos environment=development

[webservers:vars]
http_port=8080
max_connections=50
debug_mode=true

[databases:vars]
db_port=3306
max_connections=100
backup_enabled=false

[all:vars]
ansible_ssh_private_key_file=~/.ssh/dev_key
log_level=debug
```

---

### 🏭 Production Environment Inventory

```bash
nano inventory-prod.ini
```

```ini
# Production Environment Inventory

[webservers]
prod-web1 ansible_host=10.0.1.10 ansible_user=centos environment=production
prod-web2 ansible_host=10.0.1.11 ansible_user=centos environment=production
prod-web3 ansible_host=10.0.1.12 ansible_user=centos environment=production

[databases]
prod-db1 ansible_host=10.0.1.20 ansible_user=centos environment=production
prod-db2 ansible_host=10.0.1.21 ansible_user=centos environment=production

[loadbalancers]
prod-lb1 ansible_host=10.0.1.30 ansible_user=centos environment=production
prod-lb2 ansible_host=10.0.1.31 ansible_user=centos environment=production

[webservers:vars]
http_port=80
max_connections=1000
debug_mode=false

[databases:vars]
db_port=3306
max_connections=500
backup_enabled=true

[all:vars]
ansible_ssh_private_key_file=~/.ssh/prod_key
log_level=info
```

---

## 🔹 Subtask 2.2 — Create Host-Specific Variable Files

### 📁 Create host_vars Directory

```bash
mkdir -p host_vars
```

### 🖥️ Create Variables for dev-web1

```bash
nano host_vars/dev-web1.yml
```

```yaml
---
server_role: primary_web
cpu_cores: 2
memory_gb: 4
disk_space_gb: 50

app_version: "2.1.0-dev"
ssl_enabled: false
monitoring_enabled: true

custom_config:
  cache_size: "128M"
  session_timeout: 1800
  upload_max_size: "10M"
```

---

### 🏭 Create Variables for prod-web1

```bash
nano host_vars/prod-web1.yml
```

```yaml
---
server_role: primary_web
cpu_cores: 8
memory_gb: 16
disk_space_gb: 200

app_version: "2.0.5"
ssl_enabled: true
monitoring_enabled: true

custom_config:
  cache_size: "512M"
  session_timeout: 3600
  upload_max_size: "50M"

firewall_rules:
  - port: 80
    protocol: tcp
    source: "0.0.0.0/0"

  - port: 443
    protocol: tcp
    source: "0.0.0.0/0"
```

---

# 🏷️ Task 3: Using Group Variables

## 🔹 Create group_vars Directory

```bash
mkdir -p group_vars
```

### 🌐 Create Variables for Web Servers

```bash
nano group_vars/webservers.yml
```

```yaml
---
service_name: "apache"
document_root: "/var/www/html"
log_directory: "/var/log/httpd"

required_packages:
  - httpd
  - mod_ssl
  - php
  - php-mysql
```

---

### 🗄️ Create Variables for Databases

```bash
nano group_vars/databases.yml
```

```yaml
---
service_name: "mysqld"
data_directory: "/var/lib/mysql"
config_file: "/etc/my.cnf"

required_packages:
  - mysql-server
  - mysql-client
  - python3-PyMySQL
```

---

# ⚡ Variable Precedence Test

### 📝 Create Playbook

```bash
nano variable-precedence-test.yml
```

```yaml
---
- name: Variable Precedence Demonstration
  hosts: all

  vars:
    test_variable: "playbook_value"

  tasks:
    - name: Show variable precedence
      debug:
        msg: |
          Host: {{ inventory_hostname }}
          Test Variable: {{ test_variable }}
```

### ▶️ Run Test

```bash
ansible-playbook -i inventory-dev.ini variable-precedence-test.yml -e "test_variable=extra_var_value"
```

---

# 🔄 Dynamic Group Targeting

### 📝 Create Playbook

```bash
nano dynamic-targeting.yml
```

```yaml
---
- name: Dynamic Group Targeting Based on Facts
  hosts: all
  gather_facts: yes

  tasks:
    - name: Create dynamic groups based on OS
      group_by:
        key: "os_{{ ansible_distribution | lower }}"
```

### ▶️ Execute Playbook

```bash
ansible-playbook -i inventory-prod.ini dynamic-targeting.yml
```

---

# 🛠️ Troubleshooting Common Issues

## ❌ Variable Not Found

```bash
ansible-inventory -i inventory.ini --host hostname --vars
```

```bash
ansible-inventory -i inventory.ini --graph
```

---

## ❌ Group Variables Not Applied

```bash
ls -la group_vars/
ls -la host_vars/
```

```bash
ansible-playbook --syntax-check playbook.yml
```

---

## ❌ Inventory Parsing Errors

```bash
ansible-inventory -i inventory.ini --list --yaml
```

```bash
ansible-inventory -i inventory.ini --graph
```

---

# 📚 Key Takeaways

- 📦 Static inventory management
- 🌍 Multi-environment inventory design
- 🏷️ Host and group variables
- ⚡ Variable precedence handling
- 🔄 Dynamic group creation
- 🏢 Enterprise inventory structure

---

# 🏁 Conclusion

In this lab, you learned how to:

- ✅ Build and manage static inventories
- ✅ Configure host and group variables
- ✅ Apply variable precedence
- ✅ Use dynamic targeting
- ✅ Organize enterprise inventory structures

These skills are essential for:

- 🚀 DevOps Engineers
- 🖥️ Linux Administrators
- ☁️ Cloud Engineers
- ⚙️ Automation Engineers

---

# 🌟 Best Practices

| Best Practice | Benefit |
|---|---|
| 📁 Organize inventories by environment | Better maintainability |
| 🏷️ Use group_vars and host_vars | Cleaner configuration |
| 🔐 Use Ansible Vault | Secure secrets |
| 📄 Use YAML inventories | Better readability |
| ⚡ Version control inventories | Team collaboration |

---

# 📌 Useful Commands Cheat Sheet

| Command | Description |
|---|---|
| `ansible-inventory --list` | Show inventory details |
| `ansible-inventory --graph` | Display inventory graph |
| `ansible all -m ping` | Ping all hosts |
| `ansible-playbook playbook.yml` | Run playbook |
| `ansible-playbook --syntax-check` | Validate syntax |
| `ansible-playbook -e` | Pass extra variables |

---

<div align="center">

# 🎉 Happy Automating with Ansible 🚀

</div>
