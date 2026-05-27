# 🚀 Ansible Architecture and Components

<p align="center">
  <img src="https://img.shields.io/badge/Automation-Ansible-red?style=for-the-badge&logo=ansible">
  <img src="https://img.shields.io/badge/Linux-RHEL%208-blue?style=for-the-badge&logo=redhat">
  <img src="https://img.shields.io/badge/Infrastructure-DevOps-green?style=for-the-badge&logo=linux">
  <img src="https://img.shields.io/badge/Configuration-Management-orange?style=for-the-badge&logo=serverfault">
  <img src="https://img.shields.io/badge/YAML-Playbooks-yellow?style=for-the-badge&logo=yaml">
  <img src="https://img.shields.io/badge/RHCE-Ansible-black?style=for-the-badge&logo=redhat">
</p>

---

# 📘 Overview

This lab introduces the **core architecture and components of Ansible**.  
You will learn how to install Ansible, configure inventory files, execute ad-hoc commands, and understand the relationship between control nodes, managed nodes, modules, playbooks, and roles.

This lab builds the foundational knowledge required for **DevOps automation** and **RHCE certification preparation**.

---

# 🎯 Objectives

By the end of this lab, you will be able to:

✅ Understand Ansible architecture and components  
✅ Install and configure Ansible on Linux  
✅ Create and manage inventory files  
✅ Execute ad-hoc administration commands  
✅ Manage remote Linux systems using Ansible  
✅ Understand playbooks, modules, and roles  
✅ Gain practical RHCE-level Ansible fundamentals  

---

# 🧰 Prerequisites

Before starting this lab, ensure you have:

- Basic Linux command-line knowledge
- Understanding of SSH authentication
- Familiarity with YAML basics
- Knowledge of Linux administration concepts
- Access to multiple Linux systems

---

# ☁️ Lab Environment Setup

## 🖥️ Environment Includes

| Component | Description |
|----------|-------------|
| 🎛️ Control Node | CentOS/RHEL 8 |
| 🌐 Managed Nodes | 2–3 Linux systems |
| 🔐 Connectivity | SSH Key Authentication |
| ⚙️ Automation Tool | Ansible |

---

# 🏗️ Understanding Ansible Architecture

## 📌 Core Components

| Component | Purpose |
|-----------|----------|
| 📂 Inventory | Defines managed hosts |
| ⚙️ Modules | Perform automation tasks |
| 📜 Playbooks | YAML automation instructions |
| 🎭 Roles | Organize reusable automation |
| 🎛️ Control Node | Machine running Ansible |
| 🌐 Managed Nodes | Target systems being managed |

---

# 📦 Task 1 — Install Ansible on Linux

# 🔹 Subtask 1.1 — Prepare the System

## 🔄 Update System Packages

```bash
sudo dnf update -y
```

## 📥 Install Required Dependencies

```bash
sudo dnf install -y python3 python3-pip curl wget
```

---

# 🔹 Subtask 1.2 — Install Ansible Using Package Manager

## 📦 Install EPEL Repository

```bash
sudo dnf install -y epel-release
```

## 🚀 Install Ansible

```bash
sudo dnf install -y ansible
```

## ✅ Verify Installation

```bash
ansible --version
```

### 📌 Expected Output

```bash
ansible [core 2.14.x]
config file = /etc/ansible/ansible.cfg
python version = 3.9.x
```

---

# 🔹 Subtask 1.3 — Install Ansible Using pip

## 📥 Install Using pip3

```bash
pip3 install --user ansible
```

## ⚙️ Add PATH Variable

```bash
echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.bashrc
source ~/.bashrc
```

## ✅ Verify Installation

```bash
ansible --version
```

---

# 🔹 Subtask 1.4 — Configure Ansible

## 📂 Create Configuration Directory

```bash
mkdir -p ~/.ansible
```

## 📄 Create ansible.cfg

```bash
cat > ~/.ansible.cfg << 'EOF'
[defaults]
inventory = ~/ansible/inventory
host_key_checking = False
remote_user = ansible
private_key_file = ~/.ssh/id_rsa

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False
EOF
```

---

# 📂 Task 2 — Set Up Inventory Files

# 🔹 Subtask 2.1 — Create Working Directory

## 📁 Create Directory Structure

```bash
mkdir -p ~/ansible/{inventories,playbooks,roles,group_vars,host_vars}
```

## 📂 Navigate to Directory

```bash
cd ~/ansible
```

---

# 🔹 Subtask 2.2 — Create Basic Inventory

## 📄 Basic Inventory File

```bash
cat > ~/ansible/inventory << 'EOF'
[webservers]
web1 ansible_host=192.168.1.10
web2 ansible_host=192.168.1.11

[databases]
db1 ansible_host=192.168.1.20

[all:vars]
ansible_user=ansible
ansible_become=yes
EOF
```

---

# 🔹 Subtask 2.3 — Advanced Inventory Structure

## 📄 Production Inventory

```bash
cat > ~/ansible/inventories/production << 'EOF'

[webservers]
web1 ansible_host=192.168.1.10 http_port=80
web2 ansible_host=192.168.1.11 http_port=8080

[databases]
db1 ansible_host=192.168.1.20 mysql_port=3306

[loadbalancers]
lb1 ansible_host=192.168.1.30

[frontend:children]
webservers
loadbalancers

[backend:children]
databases

[all:vars]
ansible_user=ansible
EOF
```

---

# 🔹 Subtask 2.4 — Verify Inventory

## 📋 List All Hosts

```bash
ansible all --list-hosts -i ~/ansible/inventory
```

## 🌐 List Web Servers

```bash
ansible webservers --list-hosts -i ~/ansible/inventory
```

## 🧾 Display Inventory as JSON

```bash
ansible-inventory --list -i ~/ansible/inventory
```

---

# 🛠️ Task 3 — Run Ad-hoc Commands

# 🔹 Subtask 3.1 — Test Connectivity

## 🔗 Ping All Hosts

```bash
ansible all -m ping -i ~/ansible/inventory
```

## 🌐 Ping Web Servers

```bash
ansible webservers -m ping -i ~/ansible/inventory
```

### ✅ Expected Output

```bash
web1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

---

# 🔹 Subtask 3.2 — Gather System Information

## 📊 Gather Facts

```bash
ansible all -m setup -i ~/ansible/inventory
```

## 🖥️ Get OS Information

```bash
ansible all -m setup -a "filter=ansible_os_family" -i ~/ansible/inventory
```

## 💽 Check Disk Usage

```bash
ansible all -m shell -a "df -h" -i ~/ansible/inventory
```

## ⏱️ Check Uptime

```bash
ansible all -m command -a "uptime" -i ~/ansible/inventory
```

---

# 🔹 Subtask 3.3 — Perform Administration Tasks

## 🔧 Manage Services

```bash
ansible all -m service -a "name=sshd state=started" -i ~/ansible/inventory
```

## 📦 Install Packages

```bash
ansible webservers -m dnf -a "name=httpd state=present" -i ~/ansible/inventory
```

## 👤 Create User

```bash
ansible all -m user -a "name=testuser state=present" -i ~/ansible/inventory
```

## 📄 Copy File

```bash
echo "Hello from Ansible" > /tmp/test.txt

ansible all -m copy -a "src=/tmp/test.txt dest=/tmp/ansible-test.txt" -i ~/ansible/inventory
```

## 🔐 Set File Permissions

```bash
ansible all -m file -a "path=/tmp/ansible-test.txt mode=0644 owner=testuser" -i ~/ansible/inventory
```

---

# 🔹 Subtask 3.4 — Advanced Ad-hoc Commands

## 📁 Create Directory

```bash
ansible all -m file -a "path=/opt/myapp state=directory mode=0755" -i ~/ansible/inventory
```

## 🌍 Download File

```bash
ansible webservers -m get_url -a "url=https://httpd.apache.org/download.cgi dest=/tmp/apache-info.html" -i ~/ansible/inventory
```

---

# 🔹 Subtask 3.5 — Working with Variables

## 🧠 Display Variables

```bash
ansible webservers -m debug -a "var=http_port" -i ~/ansible/inventories/production
```

## 🖥️ Show Hostname Facts

```bash
ansible all -m debug -a "var=ansible_hostname" -i ~/ansible/inventory
```

## ⚙️ Set Custom Variables

```bash
ansible all -m set_fact -a "custom_message='Hello from {{ ansible_hostname }}'" -i ~/ansible/inventory
```

## 📢 Display Variables

```bash
ansible all -m debug -a "var=custom_message" -i ~/ansible/inventory
```

---

# 🧠 Understanding Inventory Deep Dive

## 📂 Inventory Types

| Type | Description |
|------|-------------|
| 📄 Static Inventory | Manual host listing |
| ⚡ Dynamic Inventory | Auto-generated hosts |
| 🧩 Host Variables | Per-host configuration |
| 👥 Group Variables | Shared group settings |
| 🌐 Group of Groups | Hierarchical organization |

---

# ⚙️ Understanding Ansible Modules

## 📦 Common Modules

| Module | Purpose |
|--------|----------|
| ping | Connectivity testing |
| setup | Gather system facts |
| command | Execute commands |
| shell | Execute shell scripts |
| copy | Transfer files |
| file | Manage file attributes |
| service | Manage services |
| dnf/yum | Package management |
| user | User administration |

---

# 📜 Understanding Playbooks

## 📘 What Are Playbooks?

Playbooks are YAML files that automate multiple tasks.

### ✅ Benefits

- Repeatable automation
- Organized tasks
- Error handling
- Conditional execution
- Infrastructure consistency

---

# 🎭 Understanding Roles

## 📂 What Are Roles?

Roles organize automation into reusable structures.

### 📌 Benefits

✅ Reusability  
✅ Standardization  
✅ Cleaner project structure  
✅ Easier maintenance  

---

# 🚨 Troubleshooting Common Issues

# 🔹 SSH Connection Problems

## 🔗 Test SSH Connectivity

```bash
ssh ansible@192.168.1.10
```

## 🔐 Fix SSH Permissions

```bash
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
```

## 🔑 Add SSH Key

```bash
ssh-add ~/.ssh/id_rsa
```

---

# 🔹 Permission Denied Errors

## 🛡️ Test sudo Access

```bash
ssh ansible@192.168.1.10 'sudo whoami'
```

## ⚙️ Configure Passwordless sudo

```bash
echo "ansible ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ansible
```

---

# 🔹 Module Not Found Errors

## 📦 List Modules

```bash
ansible-doc -l
```

## 🔄 Update Ansible

```bash
sudo dnf update ansible
```

---

# 🔹 Inventory Parsing Issues

## 🧾 Validate Inventory

```bash
ansible-inventory --list -i ~/ansible/inventory
```

## 🐍 Validate YAML

```bash
python3 -c "import yaml; yaml.safe_load(open('inventory'))"
```

---

# ✅ Verification and Testing

# 🔹 Comprehensive Verification Script

## 📄 Create Verification Script

```bash
cat > verify-lab.sh << 'EOF'
#!/bin/bash

echo "=== Ansible Installation Check ==="
ansible --version

echo "=== Inventory Validation ==="
ansible-inventory --list -i ~/ansible/inventory

echo "=== Connectivity Test ==="
ansible all -m ping -i ~/ansible/inventory

echo "=== System Information ==="
ansible all -m setup -a "filter=ansible_distribution*" -i ~/ansible/inventory

echo "=== Service Management ==="
ansible all -m service -a "name=sshd" -i ~/ansible/inventory

echo "=== Verification Complete ==="
EOF
```

## 🔐 Make Executable

```bash
chmod +x verify-lab.sh
```

## ▶️ Run Script

```bash
./verify-lab.sh
```

---

# 🏆 Skills Gained

✔️ Ansible Installation & Configuration  
✔️ Inventory Management  
✔️ SSH Automation  
✔️ Ad-hoc Command Execution  
✔️ Linux Automation  
✔️ Infrastructure Management  
✔️ RHCE Ansible Fundamentals  

---

# 📂 Project Structure

```bash
ansible/
├── inventories/
│   └── production
├── playbooks/
├── roles/
├── group_vars/
├── host_vars/
├── inventory
├── verify-lab.sh
└── ansible.cfg
```

---

# 🌟 Why Ansible Matters

Ansible is essential for:

✅ Infrastructure Automation  
✅ Configuration Management  
✅ Application Deployment  
✅ Compliance Management  
✅ DevOps Workflows  

---

# 🚀 Next Steps

After completing this lab, you can:

- Create advanced playbooks
- Develop reusable roles
- Implement dynamic inventories
- Explore Ansible Galaxy
- Prepare for RHCE certification
  
# ⭐ Support

If you found this project useful:

🌟 Star the repository  
🍴 Fork the project  
📘 Share with DevOps learners  
🚀 Practice automation daily  

-

This project is for educational and learning purposes.

---
