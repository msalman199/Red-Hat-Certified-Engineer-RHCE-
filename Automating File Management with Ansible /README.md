# 🚀 Automating File Management with Ansible

![Ansible](https://img.shields.io/badge/Ansible-Automation-red?style=for-the-badge&logo=ansible)
![Linux](https://img.shields.io/badge/Linux-RHEL%20%7C%20CentOS-yellow?style=for-the-badge&logo=linux)
![YAML](https://img.shields.io/badge/YAML-Configuration-blue?style=for-the-badge&logo=yaml)
![Automation](https://img.shields.io/badge/Automation-DevOps-green?style=for-the-badge)
![RHCE](https://img.shields.io/badge/RHCE-Exam%20Practice-black?style=for-the-badge&logo=redhat)

---

# 📘 Overview

This lab demonstrates how to automate **file management tasks** using **Ansible**.  
You will learn how to:

- 📂 Copy files from the control node to remote systems
- 📝 Create files and directories dynamically
- 🧩 Use Jinja2 templates for configuration generation
- ✏️ Modify existing files using `lineinfile`
- ⚡ Automate enterprise-level file operations
- 🎯 Practice RHCE-related automation tasks

---

# 🎯 Objectives

By the end of this lab, you will be able to:

✅ Automate file management tasks using Ansible playbooks  
✅ Copy files from local control machine to remote target systems  
✅ Create files and directories with specific content  
✅ Use `copy`, `template`, and `lineinfile` modules effectively  
✅ Apply enterprise automation best practices  
✅ Prepare for RHCE exam objectives  

---

# 📚 Prerequisites

Before starting this lab, you should have:

- Basic Linux command line knowledge
- Familiarity with YAML syntax
- Understanding of Ansible fundamentals
- Knowledge of Linux file permissions
- SSH connectivity concepts
- Basic networking knowledge

---

# 🏗️ Lab Environment Setup

## 🖥️ Infrastructure

### Control Node
- CentOS/RHEL 8
- Ansible Installed
- SSH Keys Configured

### Managed Nodes
- node1 → `192.168.1.10`
- node2 → `192.168.1.11`

---

# 📁 Lab Architecture

```text
Control Node (ansible-control)
├── Ansible Engine installed
├── SSH keys configured
└── Connected to managed nodes

Managed Nodes
├── node1 (192.168.1.10)
└── node2 (192.168.1.11)
```

---

# 🧪 Task 1: Copy Files from Local to Remote Machines

---

## 📂 Task 1.1: Create Lab Directory Structure

```bash
mkdir -p ~/ansible-lab5/files
cd ~/ansible-lab5
```

Create sample file:

```bash
echo "Welcome to Ansible File Management Lab
This file was created on the control node
Date: $(date)
Lab: Automating File Management" > files/welcome.txt
```

Verify file:

```bash
cat files/welcome.txt
```

---

## 📋 Task 1.2: Create Inventory File

```bash
cat > inventory << EOF
[webservers]
node1 ansible_host=192.168.1.10
node2 ansible_host=192.168.1.11

[all:vars]
ansible_user=ansible
ansible_ssh_private_key_file=~/.ssh/id_rsa
EOF
```

---

## 🔌 Task 1.3: Test Connectivity

```bash
ansible all -i inventory -m ping
```

Expected Output:

```text
node1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
node2 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

---

## 🛠️ Task 1.4: Create File Copy Playbook

```yaml
---
- name: Copy Files from Local to Remote Machines
  hosts: all
  become: yes

  vars:
    destination_path: /opt/lab-files

  tasks:

    - name: Create destination directory
      file:
        path: "{{ destination_path }}"
        state: directory
        mode: '0755'

    - name: Copy welcome file
      copy:
        src: files/welcome.txt
        dest: "{{ destination_path }}/welcome.txt"
        mode: '0644'
        backup: yes

    - name: Create additional files
      copy:
        content: "{{ item.content }}"
        dest: "{{ destination_path }}/{{ item.filename }}"
      with_items:
        - filename: server-info.txt
          content: |
            Server: {{ inventory_hostname }}
            IP: {{ ansible_default_ipv4.address }}

        - filename: lab-status.txt
          content: |
            Lab 5 File Management
            Status: Running
```

Save as:

```bash
copy-files-playbook.yml
```

---

## ▶️ Task 1.5: Execute Playbook

```bash
ansible-playbook -i inventory copy-files-playbook.yml
```

---

## ✅ Task 1.6: Verify Results

```bash
ansible all -i inventory -m shell -a "ls -la /opt/lab-files/"
```

```bash
ansible all -i inventory -m shell -a "cat /opt/lab-files/welcome.txt"
```

---

# 🧩 Task 2: Create Files and Directories Using Templates

---

## 📁 Create Template Directory

```bash
mkdir -p templates
```

---

## 📝 Create Jinja2 Template

### `templates/system-report.j2`

```jinja2
=== SYSTEM INFORMATION REPORT ===

Hostname: {{ inventory_hostname }}
IP Address: {{ ansible_default_ipv4.address }}
Operating System: {{ ansible_distribution }}

CPU Cores: {{ ansible_processor_vcpus }}
Memory: {{ ansible_memtotal_mb }} MB
```

---

## ⚙️ Create Application Config Template

### `templates/app-config.j2`

```jinja2
[server]
hostname = {{ inventory_hostname }}
ip_address = {{ ansible_default_ipv4.address }}
port = {{ app_port }}

[database]
host = {{ db_host }}

[logging]
level = {{ log_level }}
```

---

## 🛠️ Template Management Playbook

```yaml
---
- name: Template Management
  hosts: all
  become: yes

  vars:
    app_port: 9090
    db_host: db.example.com
    log_level: DEBUG

  tasks:

    - name: Create directories
      file:
        path: "{{ item }}"
        state: directory
        mode: '0755'
      loop:
        - /opt/lab-app
        - /opt/lab-app/config
        - /opt/lab-app/logs

    - name: Generate system report
      template:
        src: templates/system-report.j2
        dest: /opt/lab-app/system-report.txt

    - name: Generate application config
      template:
        src: templates/app-config.j2
        dest: /opt/lab-app/config/app.conf

    - name: Create startup script
      copy:
        content: |
          #!/bin/bash
          echo "Starting Lab Application"
        dest: /opt/lab-app/startup.sh
        mode: '0755'
```

Save as:

```bash
template-management-playbook.yml
```

---

## ▶️ Execute Template Playbook

```bash
ansible-playbook -i inventory template-management-playbook.yml
```

---

## ✅ Verify Generated Files

```bash
ansible all -i inventory -m shell -a "find /opt/lab-app -type f"
```

```bash
ansible all -i inventory -m shell -a "cat /opt/lab-app/system-report.txt"
```

---

# ✏️ Task 3: Modify Files Using lineinfile

---

## 📄 Create Base Configuration File

```yaml
---
- name: Create Base Configurations
  hosts: all
  become: yes

  tasks:

    - name: Create SSH config file
      copy:
        content: |
          Port 22
          PermitRootLogin no
          PasswordAuthentication yes
        dest: /etc/ssh/sshd_config_lab
```

Save as:

```bash
create-base-configs.yml
```

Run:

```bash
ansible-playbook -i inventory create-base-configs.yml
```

---

# 🛠️ Modify Files Playbook

```yaml
---
- name: Modify Files Using lineinfile
  hosts: all
  become: yes

  vars:
    new_ssh_port: 2222

  tasks:

    - name: Change SSH Port
      lineinfile:
        path: /etc/ssh/sshd_config_lab
        regexp: '^Port'
        line: 'Port {{ new_ssh_port }}'

    - name: Disable Password Authentication
      lineinfile:
        path: /etc/ssh/sshd_config_lab
        regexp: '^PasswordAuthentication'
        line: 'PasswordAuthentication no'

    - name: Enable X11 Forwarding
      lineinfile:
        path: /etc/ssh/sshd_config_lab
        regexp: '^X11Forwarding'
        line: 'X11Forwarding yes'
        create: yes
```

Save as:

```bash
modify-files-playbook.yml
```

---

## ▶️ Execute File Modification Playbook

```bash
ansible-playbook -i inventory modify-files-playbook.yml
```

---

## ✅ Verify Modifications

```bash
ansible all -i inventory -m shell -a "cat /etc/ssh/sshd_config_lab"
```

---

# 🚀 Advanced lineinfile Operations

```yaml
---
- name: Advanced Lineinfile Operations
  hosts: all
  become: yes

  tasks:

    - name: Add database server entry
      lineinfile:
        path: /etc/hosts
        line: '192.168.1.20 database.local'

    - name: Change log level
      lineinfile:
        path: /opt/lab-app/config/app.conf
        regexp: '^level'
        line: 'level = DEBUG'

    - name: Add custom setting
      lineinfile:
        path: /opt/lab-app/config/app.conf
        line: 'cache_enabled = true'
```

Save as:

```bash
advanced-lineinfile.yml
```

Execute:

```bash
ansible-playbook -i inventory advanced-lineinfile.yml
```

---

# 🏆 Master File Management Playbook

```yaml
---
- name: Master File Management
  hosts: all
  become: yes

  tasks:

    - name: Create directory structure
      file:
        path: "{{ item }}"
        state: directory
      loop:
        - /opt/lab-final
        - /opt/lab-final/config
        - /opt/lab-final/logs

    - name: Copy welcome file
      copy:
        src: files/welcome.txt
        dest: /opt/lab-final/welcome.txt

    - name: Create configuration file
      copy:
        content: |
          app_name=FinalLab
          app_port=9090
          environment=production
        dest: /opt/lab-final/config/app.properties

    - name: Modify application port
      lineinfile:
        path: /opt/lab-final/config/app.properties
        regexp: '^app_port='
        line: 'app_port=8080'
```

Save as:

```bash
master-file-management.yml
```

Run:

```bash
ansible-playbook -i inventory master-file-management.yml
```

---

# 🔍 Verification Commands

## Check Files

```bash
ansible all -i inventory -m shell -a "find /opt/lab-final"
```

## Verify Configuration

```bash
ansible all -i inventory -m shell -a "cat /opt/lab-final/config/app.properties"
```

---

# ⚠️ Troubleshooting

## Permission Issues

```bash
ansible all -i inventory -m shell -a "ls -la /opt"
```

---

## SSH Connectivity Problems

```bash
ansible all -i inventory -m ping
```

---

## YAML Syntax Check

```bash
ansible-playbook --syntax-check master-file-management.yml
```

---

# 📚 RHCE Exam Relevance

This lab prepares you for RHCE objectives including:

✅ File management automation  
✅ Template management  
✅ Configuration deployment  
✅ `lineinfile` usage  
✅ Linux permissions automation  
✅ Enterprise configuration management  

---

# 🌟 Best Practices

- Use templates for dynamic configurations
- Always create backups before modifications
- Use variables for reusable playbooks
- Organize playbooks into roles
- Follow least privilege permissions
- Validate configuration changes

---

# 🎉 Conclusion

Congratulations! You successfully completed:

✅ File Copy Automation  
✅ Template-Based File Management  
✅ File Modification Using `lineinfile`  
✅ Advanced File Operations  
✅ Enterprise Automation Techniques  

You now have practical skills in:

- 📂 Automated File Management
- 🧩 Jinja2 Templates
- ✏️ File Editing Automation
- ⚡ Configuration Management
- 🚀 Enterprise DevOps Automation
