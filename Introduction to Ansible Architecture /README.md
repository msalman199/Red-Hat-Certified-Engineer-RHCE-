# 🤖 Introduction to Ansible Architecture 

<div align="center">

![Ansible](https://img.shields.io/badge/Ansible-Automation-red?style=for-the-badge&logo=ansible)
![Linux](https://img.shields.io/badge/Linux-System_Administration-blue?style=for-the-badge&logo=linux)
![Automation](https://img.shields.io/badge/Infrastructure-Automation-green?style=for-the-badge)
![RHCE](https://img.shields.io/badge/RHCE-Preparation-orange?style=for-the-badge)

# 📚 Complete Introduction to Ansible Architecture 

</div>

---

# 📘 Overview

This lab introduces the core concepts of **Ansible Architecture** and infrastructure automation.

You will learn how to:

- ⚙️ Install Ansible
- 🖥️ Configure inventory files
- 🤖 Execute ad-hoc automation commands
- 🔐 Use SSH-based automation
- 📦 Manage packages and services
- 📂 Perform file operations with Ansible modules

This lab provides foundational skills required for:

- 🏢 Enterprise automation
- ☁️ Cloud infrastructure management
- 🚀 DevOps workflows
- 🎯 RHCE certification preparation

---

# 🎯 Objectives

By the end of this lab, students will be able to:

| ✅ Skills | 📘 Description |
|---|---|
| 🏗️ Understand Architecture | Learn Ansible control nodes, managed nodes, inventory, and modules |
| ⚙️ Install Ansible | Install and verify Ansible on Linux |
| 📂 Configure Inventory | Create INI and YAML inventory files |
| 🤖 Execute Ad-hoc Commands | Run automation tasks on managed nodes |
| 🔐 Understand Agentless Design | Learn Ansible's SSH-based architecture |
| 🚀 Use Push-Based Automation | Execute remote configuration tasks |

---

# 📋 Prerequisites

Before starting this lab, students should have:

- 🛠️ Basic Linux command line skills
- 🛠️ Familiarity with SSH and key-based authentication
- 🛠️ Basic YAML syntax knowledge
- 🛠️ Understanding of networking fundamentals
- 🛠️ Experience with editors like `vim` or `nano`
- 🛠️ Basic system administration knowledge

---

# ☁️ Lab Environment

## 🖥️ Ready-to-Use Cloud Machines

| 🖥️ Component | 📘 Description |
|---|---|
| 🤖 Control Node | System where Ansible is installed |
| 🖧 Managed Nodes | Remote systems managed by Ansible |
| 🔐 SSH Access | Pre-configured secure access |
| 🌐 Networking | All connectivity already configured |

---

# 🧠 Understanding Ansible Architecture

| 🏗️ Component | 📘 Description |
|---|---|
| 🖥️ Control Node | Machine where Ansible runs |
| 🖧 Managed Nodes | Systems controlled by Ansible |
| 📂 Inventory | File containing host definitions |
| 🧩 Modules | Units of work executed remotely |
| 📜 Playbooks | YAML automation scripts |
| 🔐 SSH | Communication method used by Ansible |

---

# 🚀 Task 1: Install Ansible on the System

---

# 🔹 Subtask 1.1: Update System Packages

## 🛠️ Tool: Update Ubuntu/Debian Packages

```bash
sudo apt update
```

---

## 🛠️ Tool: Update RHEL/CentOS Packages

```bash
sudo yum update -y
```

---

# 🔹 Subtask 1.2: Install Ansible

## 🛠️ Tool: Install Ansible on Ubuntu/Debian

```bash
sudo apt install ansible -y
```

---

## 🛠️ Tool: Install Ansible on RHEL/CentOS

```bash
sudo yum install epel-release -y
sudo yum install ansible -y
```

---

# 🔹 Subtask 1.3: Verify Installation

## 🛠️ Tool: Check Ansible Version

```bash
ansible --version
```

---

## 📖 Expected Output Example

```bash
ansible [core 2.12.x]
  config file = /etc/ansible/ansible.cfg
  executable location = /usr/bin/ansible
  python version = 3.x.x
```

---

# 🔹 Subtask 1.4: Understand Core Components

## 🧠 Core Architecture Concepts

| 🔧 Component | 📘 Purpose |
|---|---|
| 🖥️ Control Node | Executes Ansible automation |
| 🖧 Managed Nodes | Receives commands from Ansible |
| 📂 Inventory | Organizes hosts and groups |
| 🧩 Modules | Perform tasks like package installs |
| 📜 Playbooks | Define automation workflows |

---

# 🚀 Task 2: Configure Ansible Inventory File

---

# 🔹 Subtask 2.1: Create Inventory Directory

## 🛠️ Tool: Create Workspace Directory

```bash
mkdir -p ~/ansible-lab
cd ~/ansible-lab
```

---

# 🔹 Subtask 2.2: Create Basic INI Inventory File

## 🛠️ Tool: Create Inventory File

```bash
nano inventory.ini
```

---

## 🛠️ Tool: Add Inventory Configuration

```ini
# Ansible Inventory File

[local]
localhost ansible_connection=local

[webservers]
web1 ansible_host=127.0.0.1 ansible_user=ubuntu
web2 ansible_host=127.0.0.1 ansible_user=ubuntu

[databases]
db1 ansible_host=127.0.0.1 ansible_user=ubuntu

[all_servers:children]
webservers
databases
```

---

# 🔹 Subtask 2.3: Create YAML Inventory File

## 🛠️ Tool: Create YAML Inventory

```bash
nano inventory.yml
```

---

## 🛠️ Tool: Add YAML Inventory Content

```yaml
---
all:
  children:
    local:
      hosts:
        localhost:
          ansible_connection: local

    webservers:
      hosts:
        web1:
          ansible_host: 127.0.0.1
          ansible_user: ubuntu

        web2:
          ansible_host: 127.0.0.1
          ansible_user: ubuntu

    databases:
      hosts:
        db1:
          ansible_host: 127.0.0.1
          ansible_user: ubuntu
```

---

# 🔹 Subtask 2.4: Test Inventory Configuration

## 🛠️ Tool: Display Inventory as JSON

```bash
ansible-inventory -i inventory.ini --list
```

---

## 🛠️ Tool: Display Inventory Graph

```bash
ansible-inventory -i inventory.ini --graph
```

---

## 📖 Expected Output

```bash
@all:
  |--@databases:
  |  |--db1
  |--@local:
  |  |--localhost
  |--@webservers:
  |  |--web1
  |  |--web2
```

---

# 🚀 Task 3: Execute Ansible Ad-hoc Commands

---

# 🔹 Subtask 3.1: Test Basic Connectivity

## 🛠️ Tool: Ping Managed Node

```bash
ansible -i inventory.ini localhost -m ping
```

---

## 📖 Expected Output

```bash
localhost | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

---

# 🔹 Subtask 3.2: Gather System Information

## 🛠️ Tool: Gather Complete System Facts

```bash
ansible -i inventory.ini localhost -m setup
```

---

## 🛠️ Tool: Filter Specific Facts

```bash
ansible -i inventory.ini localhost -m setup -a "filter=ansible_os_family"
```

---

# 🔹 Subtask 3.3: Execute Shell Commands

## 🛠️ Tool: Check System Uptime

```bash
ansible -i inventory.ini localhost -m shell -a "uptime"
```

---

## 🛠️ Tool: Check Disk Usage

```bash
ansible -i inventory.ini localhost -m shell -a "df -h"
```

---

## 🛠️ Tool: List Running Processes

```bash
ansible -i inventory.ini localhost -m shell -a "ps aux | head -10"
```

---

# 🔹 Subtask 3.4: File Operations

## 🛠️ Tool: Create File with file Module

```bash
ansible -i inventory.ini localhost -m file -a "path=/tmp/ansible-test.txt state=touch"
```

---

## 🛠️ Tool: Verify File Creation

```bash
ansible -i inventory.ini localhost -m shell -a "ls -la /tmp/ansible-test.txt"
```

---

## 🛠️ Tool: Create Directory

```bash
ansible -i inventory.ini localhost -m file -a "path=/tmp/ansible-lab-dir state=directory mode=0755"
```

---

# 🔹 Subtask 3.5: Copy Files

## 🛠️ Tool: Create Test File

```bash
echo "This is a test file for Ansible lab" > ~/test-file.txt
```

---

## 🛠️ Tool: Copy File with Ansible

```bash
ansible -i inventory.ini localhost -m copy -a "src=~/test-file.txt dest=/tmp/copied-file.txt"
```

---

## 🛠️ Tool: Verify Copied File

```bash
ansible -i inventory.ini localhost -m shell -a "cat /tmp/copied-file.txt"
```

---

# 🔹 Subtask 3.6: Package Management

## 🛠️ Tool: Install Package with apt Module

```bash
ansible -i inventory.ini localhost -m apt -a "name=curl state=present" --become
```

---

## 🛠️ Tool: Install Package with yum Module

```bash
ansible -i inventory.ini localhost -m yum -a "name=curl state=present" --become
```

---

# 🔹 Subtask 3.7: Service Management

## 🛠️ Tool: Check SSH Service Status

```bash
ansible -i inventory.ini localhost -m service -a "name=ssh" --become
```

---

# 🔹 Subtask 3.8: Work with Multiple Hosts

## 🛠️ Tool: Ping Web Servers Group

```bash
ansible -i inventory.ini webservers -m ping
```

---

## 🛠️ Tool: Run Command on All Hosts

```bash
ansible -i inventory.ini all -m shell -a "hostname"
```

---

# 🔹 Subtask 3.9: Using Variables in Ad-hoc Commands

## 🛠️ Tool: Pass Variables Dynamically

```bash
ansible -i inventory.ini localhost -m shell -a "echo 'Hello {{ username }}'" -e "username=AnsibleUser"
```

---

# 🚀 Advanced Ad-hoc Command Examples

---

# 🔹 Working with JSON Output

## 🛠️ Tool: Format Output as JSON

```bash
ansible -i inventory.ini localhost -m setup -a "filter=ansible_distribution*" | python3 -m json.tool
```

---

# 🔹 Using Different Connection Types

## 🛠️ Tool: Use Local Connection

```bash
ansible -i inventory.ini localhost -m ping -c local
```

---

# 🔹 Limiting Execution

## 🛠️ Tool: Target Specific Hosts

```bash
ansible -i inventory.ini "web*" -m ping
```

---

# 🚨 Troubleshooting Common Issues

---

# 🔹 Issue 1: Permission Denied Errors

## 🛠️ Solution

```bash
ansible -i inventory.ini localhost -m apt -a "name=htop state=present" --become
```

> ⚠️ Use `--become` for elevated privileges.

---

# 🔹 Issue 2: SSH Connection Problems

## 🛠️ Solution: Generate SSH Key

```bash
ssh-keygen -t rsa -b 2048
```

---

## 🛠️ Tool: Copy SSH Key to Remote Host

```bash
ssh-copy-id user@remote-host
```

---

# 🔹 Issue 3: Inventory File Not Found

## 🛠️ Solution

```bash
ansible -i /full/path/to/inventory.ini localhost -m ping
```

---

# 🔹 Issue 4: Module Not Found

## 🛠️ Tool: List Available Modules

```bash
ansible-doc -l | grep -i module_name
```

---

# 📚 Best Practices for Ansible Ad-hoc Commands

| ✅ Best Practice | 📘 Reason |
|---|---|
| Use custom inventory files | Better organization |
| Test connectivity first | Avoid automation failures |
| Use `--check` mode | Perform safe dry-runs |
| Use meaningful host groups | Simplifies automation |
| Use variables | Makes commands reusable |
| Use `--become` carefully | Required for privileged tasks |

---

# 🧪 Verification Commands

## 🛠️ Tool: Verify Ansible Installation

```bash
ansible --version
```

---

## 🛠️ Tool: Verify Inventory

```bash
ansible-inventory -i inventory.ini --graph
```

---

## 🛠️ Tool: Test Connectivity

```bash
ansible -i inventory.ini localhost -m ping
```

---

## 🛠️ Tool: Run Shell Command

```bash
ansible -i inventory.ini localhost -m shell -a "uptime"
```

---

# 📚 Useful Ansible Commands Reference

| 💻 Command | 📘 Description |
|---|---|
| `ansible --version` | Check installed version |
| `ansible-inventory` | View inventory details |
| `ansible -m ping` | Test connectivity |
| `ansible -m shell` | Execute shell commands |
| `ansible -m file` | Manage files and directories |
| `ansible -m copy` | Copy files |
| `ansible -m service` | Manage services |
| `ansible-doc -l` | List available modules |

---

# 🏁 Conclusion

In this lab, you successfully:

- ✅ Installed and verified Ansible
- ✅ Created inventory files in INI and YAML formats
- ✅ Executed ad-hoc automation commands
- ✅ Managed files, services, and packages using Ansible modules
- ✅ Understood Ansible's architecture and automation model
- ✅ Practiced infrastructure automation fundamentals

These foundational skills prepare you for advanced Ansible playbooks, roles, and enterprise automation tasks.

---

# 🔑 Key Takeaways

| 💡 Concept | 📘 Importance |
|---|---|
| Agentless Automation | No software needed on managed nodes |
| SSH-Based Access | Secure remote management |
| Inventory Organization | Simplifies infrastructure management |
| Ad-hoc Commands | Quick automation tasks |
| YAML Syntax | Human-readable automation |
| Push-Based Model | Centralized automation control |



## 🚀 You are now ready to begin advanced Ansible automation and RHCE preparation.

</div>
