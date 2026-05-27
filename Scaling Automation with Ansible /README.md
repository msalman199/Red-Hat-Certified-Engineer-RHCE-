# 🚀 Scaling Automation with Ansible

![Ansible](https://img.shields.io/badge/Ansible-Automation-red?style=for-the-badge&logo=ansible)
![Linux](https://img.shields.io/badge/Linux-CentOS-yellow?style=for-the-badge&logo=linux)
![YAML](https://img.shields.io/badge/YAML-Configuration-blue?style=for-the-badge&logo=yaml)
![DevOps](https://img.shields.io/badge/DevOps-Scaling-orange?style=for-the-badge&logo=devdotto)
![Automation](https://img.shields.io/badge/Automation-Infrastructure-success?style=for-the-badge)

---

# 📘 Scaling Automation with Ansible

## 🎯 Objectives

By the end of this lab, students will be able to:

- Deploy and manage infrastructure at scale using Ansible
- Create and execute Ansible playbooks for multi-host environments
- Configure and manage multiple environments (development, staging, production)
- Implement Ansible best practices for scalable automation
- Test and validate automation performance across multiple machines
- Troubleshoot common issues in large-scale Ansible deployments

---

# 📋 Prerequisites

Before starting this lab, students should have:

- Basic understanding of Linux command line operations
- Familiarity with YAML syntax
- Basic knowledge of SSH and public key authentication
- Understanding of web servers (Apache/Nginx)
- Completion of introductory Ansible labs or equivalent experience

---

# ☁️ Lab Environment Setup

Al Nafi provides Linux-based cloud machines for this lab.

## 🖥️ Environment Includes

| Node Type | Hostname |
|---|---|
| Control Node | ansible-control |
| Web Server | web-01 |
| Web Server | web-02 |
| Database Server | db-01 |
| Database Server | db-02 |

### Environment Details

- CentOS 8 Stream
- SSH keys pre-configured
- Passwordless authentication enabled
- Ansible 4.x installed

---

# 🧪 Task 1 — Setting Up Multi-Host Ansible Environment

## 🔹 Verify Environment

```bash
whoami
hostname
```

```bash
ansible --version
ansible-config dump --only-changed
```

## 🔹 Test SSH Connectivity

```bash
ssh web-01 "hostname && whoami"
ssh web-02 "hostname && whoami"
ssh db-01 "hostname && whoami"
ssh db-02 "hostname && whoami"
```

---

# 📁 Create Project Directory

```bash
mkdir -p ~/ansible-scaling-lab
cd ~/ansible-scaling-lab
```

---

# 📝 Create inventory.ini

```ini
[webservers]
web-01 ansible_host=web-01
web-02 ansible_host=web-02

[databases]
db-01 ansible_host=db-01
db-02 ansible_host=db-02

[development:children]
webservers

[staging:children]
webservers
databases

[production:children]
webservers
databases

[all:vars]
ansible_user=centos
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

---

# ✅ Test Inventory

```bash
ansible all -i inventory.ini --list-hosts
```

```bash
ansible all -i inventory.ini -m ping
```

---

# ⚙️ Create ansible.cfg

```ini
[defaults]
inventory = inventory.ini
remote_user = centos
private_key_file = ~/.ssh/id_rsa
host_key_checking = False
retry_files_enabled = False
gathering = smart
fact_caching = memory
stdout_callback = yaml
forks = 10
timeout = 30

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes
pipelining = True
```

---

# 🔍 Verify Configuration

```bash
ansible-config view
```

```bash
ansible all -m setup --tree /tmp/facts
```

---

# 🌐 Task 2 — Deploy Applications Across Multi-Host Setup

## 📂 Create Directory Structure

```bash
mkdir -p playbooks roles group_vars host_vars
```

---

# 📝 Create Web Deployment Playbook

## 📄 playbooks/deploy-web-app.yml

```yaml
---
- name: Deploy Web Application Across Multiple Hosts
  hosts: webservers
  become: yes

  vars:
    app_name: scalable-web-app
    app_version: "1.0.0"
    web_root: /var/www/html

  tasks:

    - name: Update system packages
      yum:
        name: "*"
        state: latest
        update_cache: yes

    - name: Install required packages
      yum:
        name:
          - httpd
          - php
          - php-mysql
          - git
          - unzip
        state: present

    - name: Start Apache service
      systemd:
        name: httpd
        state: started
        enabled: yes

    - name: Configure firewall
      firewalld:
        service: http
        permanent: yes
        state: enabled
        immediate: yes

    - name: Create application directory
      file:
        path: "{{ web_root }}/{{ app_name }}"
        state: directory
        owner: apache
        group: apache
        mode: '0755'

    - name: Deploy application page
      copy:
        content: |
          <!DOCTYPE html>
          <html>
          <head>
              <title>{{ app_name }}</title>
          </head>
          <body>
              <h1>Welcome to {{ inventory_hostname }}</h1>
              <p>Application Version: {{ app_version }}</p>
          </body>
          </html>
        dest: "{{ web_root }}/{{ app_name }}/index.php"
```

---

# 🚀 Deploy Web Application

```bash
ansible-playbook playbooks/deploy-web-app.yml -v
```

---

# ✅ Verify Web Services

```bash
ansible webservers -m systemd -a "name=httpd state=started"
```

---

# 🗄️ Create Database Deployment Playbook

## 📄 playbooks/deploy-database.yml

```yaml
---
- name: Deploy Database Servers
  hosts: databases
  become: yes

  vars:
    mysql_root_password: "SecurePass123!"

  tasks:

    - name: Install MariaDB
      yum:
        name:
          - mariadb-server
          - mariadb
        state: present

    - name: Start MariaDB
      systemd:
        name: mariadb
        state: started
        enabled: yes

    - name: Configure firewall
      firewalld:
        port: 3306/tcp
        permanent: yes
        state: enabled
        immediate: yes
```

---

# 🚀 Deploy Database Servers

```bash
ansible-playbook playbooks/deploy-database.yml -v
```

---

# ✅ Verify Database Services

```bash
ansible databases -m systemd -a "name=mariadb state=started"
```

---

# 🌍 Task 3 — Environment Configuration Management

## 📂 Create Environment Variables

### 📄 group_vars/development.yml

```yaml
---
environment: development
app_version: "1.0.0-dev"
debug_mode: true
log_level: debug
```

### 📄 group_vars/staging.yml

```yaml
---
environment: staging
app_version: "1.0.0-rc"
debug_mode: false
log_level: info
```

### 📄 group_vars/production.yml

```yaml
---
environment: production
app_version: "1.0.0"
debug_mode: false
log_level: warning
```

---

# 🧩 Host Variables

### 📄 host_vars/web-01.yml

```yaml
---
server_role: primary_web
load_balancer_weight: 100
```

### 📄 host_vars/web-02.yml

```yaml
---
server_role: secondary_web
load_balancer_weight: 80
```

---

# ⚙️ Create Environment Configuration Playbook

## 📄 playbooks/configure-environments.yml

```yaml
---
- name: Configure Applications
  hosts: all
  become: yes

  tasks:

    - name: Create configuration directory
      file:
        path: /etc/scalable-web-app
        state: directory

    - name: Generate application config
      copy:
        content: |
          environment={{ environment }}
          log_level={{ log_level }}
        dest: /etc/scalable-web-app/app.conf
```

---

# 🚀 Deploy Environment Configurations

## Development Environment

```bash
ansible-playbook playbooks/configure-environments.yml --limit development -v
```

## Staging Environment

```bash
ansible-playbook playbooks/configure-environments.yml --limit staging -v
```

---

# 📦 Create Deployment Script

## 📄 deploy-environment.sh

```bash
#!/bin/bash

ENVIRONMENT=${1:-development}

echo "Deploying to $ENVIRONMENT environment..."

ansible-playbook playbooks/configure-environments.yml --limit $ENVIRONMENT -v

echo "Deployment completed!"
```

---

# 🔐 Make Script Executable

```bash
chmod +x deploy-environment.sh
```

---

# ▶️ Execute Deployment Script

```bash
./deploy-environment.sh development
```

```bash
./deploy-environment.sh staging
```

---

# 📊 Task 4 — Performance Testing

## 📄 playbooks/performance-test.yml

```yaml
---
- name: Performance Testing
  hosts: all

  tasks:

    - name: Gather facts
      setup:

    - name: Ping test
      ping:

    - name: CPU stress test
      shell: |
        timeout 10s yes > /dev/null
```

---

# 🚀 Run Performance Tests

```bash
time ansible-playbook playbooks/performance-test.yml -f 10 -v
```

---

# 📈 Performance Analysis Script

## 📄 analyze-performance.py

```python
#!/usr/bin/env python3

print("Analyzing Ansible Performance...")
```

---

# ▶️ Execute Analysis Script

```bash
python3 analyze-performance.py
```

---

# ⚡ Optimize Ansible Performance

## Optimized ansible.cfg

```ini
[defaults]
forks = 20
fact_caching = jsonfile
timeout = 30

[ssh_connection]
pipelining = True
```

---

# 🚀 Execute Optimization Test

```bash
time ansible-playbook playbooks/optimize-performance.yml
```

---

# 🛠️ Troubleshooting Tips

| Issue | Solution |
|---|---|
| SSH Connectivity Failure | Verify SSH keys |
| Slow Performance | Increase forks |
| YAML Errors | Validate indentation |
| Permission Issues | Use become: yes |
| Playbook Failure | Use verbose mode (-vvv) |

---

# 🔍 Useful Debugging Commands

## Ping All Hosts

```bash
ansible all -m ping
```

## Verbose Playbook Output

```bash
ansible-playbook playbook.yml -vvv
```

## View Inventory

```bash
ansible-inventory --list
```

## View Ansible Configuration

```bash
ansible-config view
```

---

# 📚 Best Practices

✅ Use group_vars and host_vars  
✅ Organize playbooks into roles  
✅ Enable SSH pipelining  
✅ Use fact caching for performance  
✅ Use templates for configuration management  
✅ Use tags for selective execution  
✅ Separate environments properly  
✅ Optimize forks for large-scale deployments  

---

# 🎓 Conclusion

In this lab, you successfully learned how to scale automation using Ansible across multiple hosts and environments.

You practiced:

- Multi-host infrastructure automation
- Web and database deployment
- Environment management
- Performance testing
- Infrastructure optimization
- Troubleshooting large-scale deployments

These skills are essential for modern DevOps and Cloud Engineering environments.

---

# 🏆 Skills Gained

✅ Infrastructure Automation  
✅ Multi-Host Deployment  
✅ Configuration Management  
✅ Environment Management  
✅ Performance Optimization  
✅ DevOps Troubleshooting  

---

# 📖 Next Steps

- Learn Ansible Roles
- Explore Ansible Galaxy
- Study Ansible Vault
- Integrate Ansible with CI/CD
- Explore AWX / Ansible Tower
- Automate Kubernetes deployments


