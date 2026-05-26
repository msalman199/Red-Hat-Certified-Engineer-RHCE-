# 🚀 Creating Ansible Roles

<div align="center">

![Ansible](https://img.shields.io/badge/Ansible-Automation-red?style=for-the-badge&logo=ansible)
![Linux](https://img.shields.io/badge/Linux-RHEL%20%7C%20CentOS-blue?style=for-the-badge&logo=linux)
![YAML](https://img.shields.io/badge/YAML-Configuration-orange?style=for-the-badge&logo=yaml)
![DevOps](https://img.shields.io/badge/DevOps-Infrastructure-success?style=for-the-badge&logo=devops)
![Automation](https://img.shields.io/badge/Automation-Enterprise-purple?style=for-the-badge)

### 📚 Complete GitHub README Lab Guide for Creating Ansible Roles

</div>

---

# 📖 Overview

This lab provides a complete hands-on guide for creating, managing, and deploying **Ansible Roles** in enterprise environments.

You will learn how to:

- ✅ Create reusable Ansible roles
- ✅ Organize automation using role structures
- ✅ Build web server and database roles
- ✅ Implement role dependencies
- ✅ Use Ansible Galaxy community roles
- ✅ Create role collections
- ✅ Deploy full-stack applications with Ansible

---

# 🎯 Objectives

By the end of this lab, students will be able to:

- ✅ Understand the concept and benefits of Ansible roles
- ✅ Create a basic Ansible role structure from scratch
- ✅ Develop a reusable web server role
- ✅ Implement role dependencies
- ✅ Use Ansible Galaxy community roles
- ✅ Apply best practices for role management
- ✅ Execute playbooks using custom and community roles

---

# 📋 Prerequisites

Before starting this lab, students should have:

- 🐧 Basic Linux command line knowledge
- 📝 Familiarity with YAML syntax
- ⚙️ Understanding of Ansible playbooks
- 🌐 Knowledge of Apache/Nginx web servers
- 📦 Linux package management experience

---

# 🖥️ Lab Environment

The lab environment includes:

| Component | Description |
|---|---|
| 🖥️ Control Node | CentOS/RHEL with Ansible installed |
| 🌐 Target Nodes | Multiple Linux servers |
| 🌍 Internet Access | For Ansible Galaxy |
| 🛠️ Development Tools | Pre-installed |

---

# 📁 Recommended Project Structure

```bash
ansible-lab/
├── inventory
├── requirements.yml
├── test-webserver.yml
├── test-webapp.yml
├── nginx-deployment.yml
├── final-deployment.yml
├── roles/
│   ├── webserver/
│   ├── database/
│   └── webapp/
└── collections/
    └── ansible_collections/
        └── alnafi/
            └── webstack/
```

---

# 🧩 Task 1: Create a Basic Role to Manage Web Server Installation

## 🔹 Subtask 1.1 — Understanding Role Structure

### 📖 Standard Role Structure

```bash
role_name/
├── tasks/
├── handlers/
├── templates/
├── files/
├── vars/
├── defaults/
├── meta/
└── README.md
```

---

## 🔹 Subtask 1.2 — Create Role Directory Structure

### 📂 Create Roles Directory

```bash
cd ~
mkdir -p ansible-lab/roles
cd ansible-lab/roles
```

### ⚙️ Initialize Role

```bash
ansible-galaxy init webserver
```

### 🌳 Verify Structure

```bash
tree webserver
```

---

## 🔹 Subtask 1.3 — Define Role Variables

### 📝 Edit Default Variables

```bash
nano webserver/defaults/main.yml
```

```yaml
---
webserver_package: httpd
webserver_service: httpd
webserver_port: 80
webserver_document_root: /var/www/html
webserver_index_file: index.html
webserver_user: apache
webserver_group: apache
```

---

### 📝 Edit Role Variables

```bash
nano webserver/vars/main.yml
```

```yaml
---
webserver_config_file: /etc/httpd/conf/httpd.conf
webserver_log_dir: /var/log/httpd
firewall_service: firewalld
```

---

## 🔹 Subtask 1.4 — Create Main Tasks

### 📝 Edit Tasks File

```bash
nano webserver/tasks/main.yml
```

```yaml
---
- name: Install web server package
  package:
    name: "{{ webserver_package }}"
    state: present
  become: yes

- name: Install additional packages
  package:
    name:
      - firewalld
      - curl
    state: present
  become: yes

- name: Create document root directory
  file:
    path: "{{ webserver_document_root }}"
    state: directory
    owner: "{{ webserver_user }}"
    group: "{{ webserver_group }}"
    mode: '0755'
  become: yes

- name: Start and enable web server
  systemd:
    name: "{{ webserver_service }}"
    state: started
    enabled: yes
  become: yes
```

---

## 🔹 Subtask 1.5 — Create Templates

### 📝 Create Template File

```bash
nano webserver/templates/index.html.j2
```

```html
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to {{ ansible_hostname }}</title>
</head>
<body>
    <h1>Web Server Successfully Deployed!</h1>

    <p><strong>Hostname:</strong> {{ ansible_hostname }}</p>
    <p><strong>IP Address:</strong> {{ ansible_default_ipv4.address }}</p>
    <p><strong>Web Server:</strong> {{ webserver_package }}</p>
</body>
</html>
```

---

## 🔹 Subtask 1.6 — Create Handlers

### 📝 Edit Handlers File

```bash
nano webserver/handlers/main.yml
```

```yaml
---
- name: restart webserver
  systemd:
    name: "{{ webserver_service }}"
    state: restarted
  become: yes

- name: reload webserver
  systemd:
    name: "{{ webserver_service }}"
    state: reloaded
  become: yes
```

---

## 🔹 Subtask 1.7 — Create Role Metadata

### 📝 Edit Metadata File

```bash
nano webserver/meta/main.yml
```

```yaml
---
galaxy_info:
  author: Your Name
  description: A role to install and configure a web server
  company: Al Nafi Training
  license: MIT
  min_ansible_version: 2.9

dependencies: []
```

---

## 🔹 Subtask 1.8 — Test Web Server Role

### 📝 Create Inventory File

```bash
cd ~/ansible-lab
nano inventory
```

```ini
[webservers]
target1 ansible_host=<TARGET_IP_1>
target2 ansible_host=<TARGET_IP_2>

[all:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=~/.ssh/id_rsa
```

---

### 📝 Create Test Playbook

```bash
nano test-webserver.yml
```

```yaml
---
- name: Test Web Server Role
  hosts: webservers
  become: yes

  roles:
    - webserver
```

### ▶️ Run Playbook

```bash
ansible-playbook -i inventory test-webserver.yml
```

---

# 🗄️ Task 2: Implement Role Dependencies

## 🔹 Subtask 2.1 — Create Database Role

### ⚙️ Initialize Database Role

```bash
cd ~/ansible-lab/roles
ansible-galaxy init database
```

### 📝 Configure Database Variables

```bash
nano database/defaults/main.yml
```

```yaml
---
db_package: mariadb-server
db_service: mariadb
db_port: 3306
db_name: webapp_db
```

---

### 📝 Create Database Tasks

```bash
nano database/tasks/main.yml
```

```yaml
---
- name: Install database server
  package:
    name:
      - "{{ db_package }}"
      - python3-PyMySQL
    state: present
  become: yes

- name: Start database service
  systemd:
    name: "{{ db_service }}"
    state: started
    enabled: yes
  become: yes
```

---

## 🔹 Subtask 2.2 — Create Full-Stack Application Role

### ⚙️ Initialize WebApp Role

```bash
ansible-galaxy init webapp
```

### 📝 Configure Dependencies

```bash
nano webapp/meta/main.yml
```

```yaml
---
dependencies:
  - role: database
  - role: webserver
```

---

### 📝 Create WebApp Tasks

```bash
nano webapp/tasks/main.yml
```

```yaml
---
- name: Install PHP packages
  package:
    name:
      - php
      - php-mysql
    state: present
  become: yes

- name: Create application directory
  file:
    path: /var/www/html/webapp
    state: directory
    owner: apache
    group: apache
    mode: '0755'
  become: yes
```

---

## 🔹 Subtask 2.3 — Test Role Dependencies

### 📝 Create Playbook

```bash
nano test-webapp.yml
```

```yaml
---
- name: Deploy Full-Stack Web Application
  hosts: webservers
  become: yes

  roles:
    - webapp
```

### ▶️ Run Deployment

```bash
ansible-playbook -i inventory test-webapp.yml
```

---

# 🌍 Task 3: Use Ansible Galaxy

## 🔹 Subtask 3.1 — Explore Galaxy

### 🔍 Search Roles

```bash
ansible-galaxy search nginx
```

### 📄 View Role Information

```bash
ansible-galaxy info geerlingguy.nginx
```

### 📦 List Installed Roles

```bash
ansible-galaxy list
```

---

## 🔹 Subtask 3.2 — Install Community Roles

### 📥 Install Nginx Role

```bash
ansible-galaxy install geerlingguy.nginx
```

### 📥 Install Security Roles

```bash
ansible-galaxy install geerlingguy.firewall
ansible-galaxy install geerlingguy.security
```

### ✅ Verify Installation

```bash
ansible-galaxy list
```

---

## 🔹 Subtask 3.3 — Create Requirements File

### 📝 Create requirements.yml

```bash
nano requirements.yml
```

```yaml
---
- name: geerlingguy.nginx
  version: "3.1.4"

- name: geerlingguy.firewall
  version: "2.5.0"

- name: geerlingguy.security
  version: "2.0.1"
```

### 📥 Install Requirements

```bash
ansible-galaxy install -r requirements.yml
```

---

## 🔹 Subtask 3.4 — Create Playbook Using Community Roles

### 📝 Create Deployment Playbook

```bash
nano nginx-deployment.yml
```

```yaml
---
- name: Deploy Nginx Web Server
  hosts: webservers
  become: yes

  roles:
    - geerlingguy.security
    - geerlingguy.firewall
    - geerlingguy.nginx
```

### ▶️ Run Deployment

```bash
ansible-playbook -i inventory nginx-deployment.yml
```

---

## 🔹 Subtask 3.5 — Create Custom Role Collection

### 📂 Create Collection Structure

```bash
mkdir -p ~/ansible-lab/collections/ansible_collections/alnafi/webstack
```

### ⚙️ Initialize Collection

```bash
ansible-galaxy collection init alnafi.webstack --init-path ~/ansible-lab/collections/ansible_collections/
```

---

### 📝 Configure galaxy.yml

```bash
nano galaxy.yml
```

```yaml
namespace: alnafi
name: webstack
version: 1.0.0
readme: README.md
authors:
  - Al Nafi Training Team
description: Web stack deployment collection
license:
  - MIT
```

---

### 📦 Build Collection

```bash
ansible-galaxy collection build
```

---

# 🚀 Final Deployment

## 📝 Create Final Deployment Playbook

```bash
nano final-deployment.yml
```

```yaml
---
- name: Complete Web Stack Deployment
  hosts: webservers
  become: yes

  roles:
    - geerlingguy.security
    - geerlingguy.firewall
    - database
    - webserver
    - webapp
```

### ▶️ Run Final Deployment

```bash
ansible-playbook -i inventory final-deployment.yml
```

---

# 🛠️ Troubleshooting Tips

## ❌ Role Not Found

```bash
export ANSIBLE_ROLES_PATH=~/ansible-lab/roles:~/.ansible/roles:/etc/ansible/roles
```

---

## ❌ Permission Denied

```bash
chmod 600 ~/.ssh/id_rsa
```

```bash
ansible all -i inventory -m ping --become
```

---

## ❌ Service Startup Failures

```bash
ansible all -i inventory -m shell -a "systemctl status httpd" --become
```

```bash
ansible all -i inventory -m shell -a "journalctl -u httpd -n 20" --become
```

---

## ❌ Firewall Issues

```bash
ansible all -i inventory -m shell -a "firewall-cmd --list-all" --become
```

---

## ❌ Database Connection Problems

```bash
ansible all -i inventory -m shell -a "systemctl status mariadb" --become
```

---

# 📚 What You Learned

- ✅ Role structure and organization
- ✅ Custom role development
- ✅ Role dependencies
- ✅ Community role integration
- ✅ Advanced deployment automation
- ✅ Role collections
- ✅ Production-ready deployments

---

# 🌟 Best Practices

| Best Practice | Benefit |
|---|---|
| 📁 Organize roles properly | Better maintainability |
| 📝 Use defaults and vars | Cleaner configuration |
| 🔄 Use handlers | Efficient service management |
| 🌍 Use Galaxy roles | Faster development |
| 📄 Document metadata | Better collaboration |
| ⚡ Use collections | Enterprise scalability |

---

# 📌 Useful Commands Cheat Sheet

| Command | Description |
|---|---|
| `ansible-galaxy init role` | Create role |
| `ansible-galaxy install` | Install role |
| `ansible-galaxy list` | List roles |
| `ansible-playbook` | Run playbook |
| `ansible-galaxy collection build` | Build collection |
| `tree role_name` | View role structure |

---

# 🏁 Conclusion

Congratulations! 🎉

You have successfully learned how to:

- 🚀 Create reusable Ansible roles
- 🏗️ Build full-stack deployments
- 🌍 Use Ansible Galaxy community roles
- 📦 Create role collections
- ⚡ Deploy production-ready infrastructure

These skills are essential for:

- ☁️ DevOps Engineering
- 🖥️ Linux Administration
- ⚙️ Infrastructure Automation
- 🔐 Enterprise Operations
- 🚀 CI/CD Pipelines

---

<div align="center">

# 🎉 Happy Automating with Ansible Roles 🚀

</div>
