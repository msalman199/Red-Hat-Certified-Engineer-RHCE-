# 🚀 Managing Hosts in Different Environments with Ansible

<div align="center">

![Ansible](https://img.shields.io/badge/Ansible-Automation-red?style=for-the-badge&logo=ansible)
![Linux](https://img.shields.io/badge/Linux-Administration-yellow?style=for-the-badge&logo=linux)
![YAML](https://img.shields.io/badge/YAML-Configuration-black?style=for-the-badge&logo=yaml)
![DevOps](https://img.shields.io/badge/DevOps-Infrastructure-blue?style=for-the-badge&logo=azuredevops)
![Automation](https://img.shields.io/badge/Automation-Deployment-green?style=for-the-badge&logo=githubactions)
![SSH](https://img.shields.io/badge/SSH-Secure_Access-darkgreen?style=for-the-badge&logo=gnu-bash)
![Nginx](https://img.shields.io/badge/Nginx-Web_Server-009639?style=for-the-badge&logo=nginx)
![MariaDB](https://img.shields.io/badge/MariaDB-Database-brown?style=for-the-badge&logo=mariadb)
![Security](https://img.shields.io/badge/Security-Hardening-important?style=for-the-badge&logo=securityscorecard)

</div>

---

# 📘 Lab Overview

This lab demonstrates how to manage multiple environments using **Ansible** by organizing inventories, variables, templates, and deployment playbooks for:

- 🧪 Development
- 🛠️ Staging
- 🚀 Production

You will also learn:

✅ Inventory management  
✅ Environment-specific variables  
✅ Tag-based deployments  
✅ Secure infrastructure automation  
✅ Multi-environment best practices  

---

# 🎯 Objectives

By the end of this lab, you will be able to:

- 📂 Organize Ansible inventory files for multiple environments
- ⚙️ Create environment-specific playbooks
- 🏷️ Use tags to target specific deployments
- 🚀 Execute deployments using `ansible-playbook`
- 🔐 Implement secure multi-environment workflows
- 🧩 Maintain infrastructure separation between environments

---

# 🧰 Prerequisites

Before starting this lab, ensure you have:

| Requirement | Description |
|---|---|
| 🐧 Linux Knowledge | Basic Linux command-line operations |
| 📄 YAML | Familiarity with YAML syntax |
| ⚡ Ansible Basics | Playbooks, inventories, modules |
| 🔑 SSH | Key-based authentication |
| ✍️ Text Editor | Vim or Nano |

---

# ☁️ Lab Environment Setup

## 🖥️ Provided Infrastructure

| Host | Purpose |
|---|---|
| ansible-control | Ansible Control Node |
| dev-server | Development Environment |
| staging-server | Staging Environment |
| prod-server | Production Environment |

---

# 📁 Task 1 — Organize Inventory for Different Environments

---

# 🏗️ Subtask 1.1 — Create Directory Structure

```bash
# Navigate to home directory
cd ~

# Create project directory
mkdir ansible-environments
cd ansible-environments

# Create directory structure
mkdir -p inventories/{dev,staging,prod}
mkdir -p group_vars/{dev,staging,prod}
mkdir -p host_vars
mkdir playbooks
mkdir roles

# Verify structure
tree .
```

---

# 📂 Recommended Project Structure

```text
ansible-environments/
├── inventories/
│   ├── dev/
│   ├── staging/
│   └── prod/
├── group_vars/
├── host_vars/
├── playbooks/
├── templates/
└── roles/
```

---

# 🧪 Subtask 1.2 — Create Development Inventory

```ini
[webservers]
dev-server ansible_host=192.168.1.10 ansible_user=ec2-user

[databases]
dev-server

[dev:children]
webservers
databases

[dev:vars]
environment=development
app_port=8080
debug_mode=true
```

---

# 🛠️ Create Staging Inventory

```ini
[webservers]
staging-server ansible_host=192.168.1.20 ansible_user=ec2-user

[databases]
staging-server

[loadbalancers]
staging-server

[staging:children]
webservers
databases
loadbalancers

[staging:vars]
environment=staging
app_port=8080
debug_mode=false
```

---

# 🚀 Create Production Inventory

```ini
[webservers]
prod-server ansible_host=192.168.1.30 ansible_user=ec2-user

[databases]
prod-server

[loadbalancers]
prod-server

[monitoring]
prod-server

[prod:children]
webservers
databases
loadbalancers
monitoring

[prod:vars]
environment=production
app_port=80
debug_mode=false
ssl_enabled=true
```

---

# ✅ Subtask 1.3 — Verify Inventory Configuration

```bash
ansible-inventory -i inventories/dev/hosts --list
ansible-inventory -i inventories/staging/hosts --list
ansible-inventory -i inventories/prod/hosts --list
```

---

# 🔌 Test Connectivity

```bash
ansible all -i inventories/dev/hosts -m ping
ansible all -i inventories/staging/hosts -m ping
ansible all -i inventories/prod/hosts -m ping
```

---

# ⚙️ Task 2 — Environment-Specific Variables

---

# 🧪 Development Variables

```yaml
---
environment_name: "development"
app_version: "latest"
database_name: "myapp_dev"
database_user: "dev_user"
database_password: "dev_password"

log_level: "debug"
backup_enabled: false
monitoring_enabled: false
```

---

# 🛠️ Staging Variables

```yaml
---
environment_name: "staging"
app_version: "v1.2.0"
database_name: "myapp_staging"

backup_enabled: true
monitoring_enabled: true
```

---

# 🚀 Production Variables

```yaml
---
environment_name: "production"
app_version: "v1.1.5"
database_name: "myapp_prod"

backup_enabled: true
monitoring_enabled: true

ssl_config:
  cert_path: "/etc/ssl/certs/myapp.crt"
  key_path: "/etc/ssl/private/myapp.key"
```

---

# 📜 Task 3 — Main Deployment Playbook

```yaml
---
- name: Deploy Application Across Environments
  hosts: webservers
  become: yes

  tasks:

    - name: Display Environment Information
      debug:
        msg: "Deploying to {{ environment_name }}"
      tags:
        - info
        - deploy

    - name: Install Packages
      package:
        name:
          - nginx
          - python3
        state: present
      tags:
        - packages

    - name: Start nginx
      systemd:
        name: nginx
        state: started
        enabled: yes
      tags:
        - services
```

---

# 🧩 Create Templates

## 📄 app_config.j2

```jinja2
app:
  version: {{ app_version }}
  environment: {{ environment_name }}
```

---

## 🌐 nginx_app.j2

```jinja2
server {
    listen {{ app_port }};
    server_name {{ ansible_hostname }};
}
```

---

# 🏷️ Tag-Based Deployment

---

# 🧪 Development Deployment

```bash
ansible-playbook -i inventories/dev/hosts \
playbooks/deploy-app.yml \
--tags "setup,deploy,config"
```

---

# 🛠️ Staging Deployment

```bash
ansible-playbook -i inventories/staging/hosts \
playbooks/deploy-app.yml \
--tags "config,security"
```

---

# 🚀 Production Deployment

```bash
ansible-playbook -i inventories/prod/hosts \
playbooks/deploy-app.yml \
--check \
--tags "all"
```

---

# 🔐 Security Hardening Playbook

```yaml
---
- name: Security Hardening
  hosts: all
  become: yes

  tasks:

    - name: Disable Root Login
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^#?PermitRootLogin'
        line: 'PermitRootLogin no'

    - name: Install fail2ban
      package:
        name: fail2ban
        state: present
```

---

# 📊 Monitoring Setup

```yaml
---
- name: Setup Monitoring
  hosts: monitoring
  become: yes

  tasks:

    - name: Install Monitoring Tools
      package:
        name:
          - htop
          - sysstat
        state: present
```

---

# 🧪 Verification Commands

## 📋 Verify Inventories

```bash
ansible-inventory -i inventories/dev/hosts --graph
ansible-inventory -i inventories/staging/hosts --graph
ansible-inventory -i inventories/prod/hosts --graph
```

---

# 🔍 Gather Facts

```bash
ansible all -i inventories/dev/hosts -m setup
ansible all -i inventories/staging/hosts -m setup
ansible all -i inventories/prod/hosts -m setup
```

---

# 🛠️ Troubleshooting

| ❌ Issue | ✅ Solution |
|---|---|
| Inventory not found | Verify paths and permissions |
| Variables missing | Use `-vv` for debugging |
| Tags not working | Run `--list-tags` |
| Template errors | Check Jinja2 syntax |

---

# 💡 Useful Commands

## 📌 List Available Tags

```bash
ansible-playbook playbooks/deploy-app.yml --list-tags
```

---

## 🧪 Dry Run Mode

```bash
ansible-playbook playbooks/deploy-app.yml --check
```

---

## 🔍 Verbose Debugging

```bash
ansible-playbook playbooks/deploy-app.yml -vv
```

---

# 🏆 Best Practices

✅ Separate inventories per environment  
✅ Store variables in `group_vars`  
✅ Use tags for granular deployments  
✅ Always use `--check` in production  
✅ Secure SSH configurations  
✅ Keep templates reusable  
✅ Use role-based architecture for scaling  

---

# 🎓 What You Learned

✔️ Multi-environment infrastructure management  
✔️ Inventory organization strategies  
✔️ Environment-specific variable management  
✔️ Tag-based deployments  
✔️ Secure automation workflows  
✔️ Production deployment safety checks  

---

# 🚀 Real-World Benefits

| Benefit | Description |
|---|---|
| 🔒 Risk Reduction | Prevent accidental production changes |
| ⚡ Faster Deployments | Reusable automation workflows |
| 📈 Scalability | Easy to add more environments |
| 🧩 Consistency | Same deployment standards everywhere |
| 💼 Career Growth | Essential RHCE + DevOps skill |

---

# 🧠 Conclusion

You have successfully built a complete multi-environment infrastructure automation workflow using Ansible.

This project demonstrated:

- 🧪 Development environment management
- 🛠️ Staging workflows
- 🚀 Production deployment safety
- 🔐 Security hardening
- 📊 Monitoring automation
- 🏷️ Tag-based operations

These skills are highly valuable for:

- DevOps Engineers
- Linux System Administrators
- Cloud Engineers
- RHCE Certification Preparation

---

# 🙌 Author

## 👨‍💻 Created for Ansible Multi-Environment Infrastructure Management Lab

⭐ Don't forget to star your repository if you found this helpful!

---

<div align="center">

# 🚀 Happy Automating with Ansible 🚀

</div>
