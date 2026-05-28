# 🚀 Deploying Systems at Scale with Ansible

<p align="center">

![Ansible](https://img.shields.io/badge/Ansible-Automation-red?style=for-the-badge\&logo=ansible)
![Linux](https://img.shields.io/badge/Linux-Administration-black?style=for-the-badge\&logo=linux)
![Apache](https://img.shields.io/badge/Apache-Web%20Server-orange?style=for-the-badge\&logo=apache)
![YAML](https://img.shields.io/badge/YAML-Configuration-red?style=for-the-badge\&logo=yaml)
![SSH](https://img.shields.io/badge/SSH-Secure%20Access-green?style=for-the-badge\&logo=gnubash)
![DevOps](https://img.shields.io/badge/DevOps-Automation-blue?style=for-the-badge\&logo=azuredevops)
![Ubuntu](https://img.shields.io/badge/Ubuntu-Linux-E95420?style=for-the-badge\&logo=ubuntu)
![CentOS](https://img.shields.io/badge/CentOS-Server-262577?style=for-the-badge\&logo=centos)
![RHEL](https://img.shields.io/badge/RHEL-Enterprise%20Linux-EE0000?style=for-the-badge\&logo=redhat)
![Jinja2](https://img.shields.io/badge/Jinja2-Templating-B41717?style=for-the-badge)
![Firewall](https://img.shields.io/badge/Firewall-UFW%20%7C%20Firewalld-yellow?style=for-the-badge)
![Automation](https://img.shields.io/badge/Infrastructure-Automation-purple?style=for-the-badge)
![Cloud](https://img.shields.io/badge/Cloud-DevOps-00ADEF?style=for-the-badge\&logo=icloud)
![GitHub](https://img.shields.io/badge/GitHub-msalman199-181717?style=for-the-badge\&logo=github)
![AWS](https://img.shields.io/badge/AWS-Cloud-orange?style=for-the-badge\&logo=amazonaws)
![Monitoring](https://img.shields.io/badge/Monitoring-System%20Health-success?style=for-the-badge)
![Apache2](https://img.shields.io/badge/Apache2-Web%20Deployment-D22128?style=for-the-badge\&logo=apache)
![Bash](https://img.shields.io/badge/Bash-Scripting-4EAA25?style=for-the-badge\&logo=gnubash)
![Security](https://img.shields.io/badge/Security-Hardening-darkgreen?style=for-the-badge)
![Scalability](https://img.shields.io/badge/Scalable-Infrastructure-blueviolet?style=for-the-badge)

</p>

---

# 📘 Lab Overview

This lab demonstrates scalable infrastructure deployment using **Ansible Automation** across multiple Linux servers.

You will learn how to:

✅ Deploy Apache Web Servers
✅ Configure Multi-Environment Infrastructure
✅ Automate Infrastructure at Scale
✅ Use Templates and Variables
✅ Configure Monitoring and Logging
✅ Implement Idempotent Deployments

---

# 🎯 Objectives

By the end of this lab, you will be able to:

✔️ Create Ansible Playbooks
✔️ Configure Inventories
✔️ Deploy Web Servers Automatically
✔️ Manage Development, Staging & Production Environments
✔️ Scale Infrastructure Efficiently
✔️ Troubleshoot Deployment Issues

---

# 🛠️ Technologies Used

| Technology            | Purpose                   |
| --------------------- | ------------------------- |
| 🔴 Ansible            | Automation                |
| 🐧 Linux              | Operating System          |
| 🌐 Apache HTTP Server | Web Hosting               |
| 📄 YAML               | Configuration             |
| 🔐 SSH                | Secure Access             |
| 🧩 Jinja2             | Templates                 |
| 🔥 UFW / Firewalld    | Firewall                  |
| 📦 APT / YUM          | Package Management        |
| ☁️ DevOps             | Infrastructure Automation |

---

# 🖥️ Lab Environment

| Hostname        | Role         |
| --------------- | ------------ |
| ansible-control | Control Node |
| web-01          | Web Server   |
| web-02          | Web Server   |
| web-03          | Web Server   |

---

# 🚀 Task 1 — Deploy Web Servers

---

# ✅ Verify Connectivity

```bash
whoami
hostname
ansible --version
```

---

# 🔐 Test SSH Access

```bash
ssh web-01 "hostname && whoami"
ssh web-02 "hostname && whoami"
ssh web-03 "hostname && whoami"
```

---

# 📁 Create Working Directory

```bash
mkdir -p ~/ansible-lab15
cd ~/ansible-lab15
```

---

# 📄 Create Inventory File

## inventory.ini

```ini
[webservers]
web-01 ansible_host=web-01
web-02 ansible_host=web-02
web-03 ansible_host=web-03

[webservers:vars]
ansible_user=student
ansible_ssh_private_key_file=~/.ssh/id_rsa
```

---

# 🔍 Test Inventory

```bash
ansible -i inventory.ini webservers -m ping
```

---

# 📄 Create Deployment Playbook

## deploy-webserver.yml

```yaml
---
- name: Deploy and Configure Web Servers at Scale
  hosts: webservers
  become: yes

  vars:
    web_server_port: 80
    document_root: /var/www/html
    server_name: "{{ inventory_hostname }}"

  tasks:

    - name: Update Package Cache
      apt:
        update_cache: yes
      when: ansible_os_family == "Debian"

    - name: Install Apache
      apt:
        name: apache2
        state: present
      when: ansible_os_family == "Debian"

    - name: Install Utility Packages
      package:
        name:
          - curl
          - wget
          - unzip
        state: present

    - name: Create Document Root
      file:
        path: "{{ document_root }}"
        state: directory
        owner: www-data
        group: www-data
        mode: '0755'

    - name: Deploy Web Page
      template:
        src: index.html.j2
        dest: "{{ document_root }}/index.html"

    - name: Start Apache
      systemd:
        name: apache2
        state: started
        enabled: yes

    - name: Configure Firewall
      ufw:
        rule: allow
        port: "{{ web_server_port }}"
        proto: tcp
```

---

# 📁 Create Templates Directory

```bash
mkdir -p templates
```

---

# 🌐 HTML Template

## templates/index.html.j2

```html
<!DOCTYPE html>
<html>
<head>
    <title>{{ server_name }}</title>
</head>
<body>

<h1>🚀 Web Server Successfully Deployed!</h1>

<p>Hostname: {{ inventory_hostname }}</p>
<p>IP Address: {{ ansible_default_ipv4.address }}</p>
<p>Operating System: {{ ansible_distribution }}</p>

</body>
</html>
```

---

# 🌐 Apache Virtual Host Template

## templates/vhost.conf.j2

```apache
<VirtualHost *:{{ web_server_port }}>

    ServerName {{ server_name }}
    DocumentRoot {{ document_root }}

    <Directory {{ document_root }}>
        AllowOverride All
        Require all granted
    </Directory>

</VirtualHost>
```

---

# 🚀 Execute Deployment

```bash
ansible-playbook -i inventory.ini deploy-webserver.yml -v
```

---

# 🔍 Verify Apache Service

```bash
ansible -i inventory.ini webservers -m shell -a "systemctl status apache2"
```

---

# 🌐 Test Web Servers

```bash
curl http://web-01
curl http://web-02
curl http://web-03
```

---

# 🚀 Task 2 — Environment-Based Scaling

---

# 📁 Create Environment Directories

```bash
mkdir -p environments/{development,staging,production}
```

---

# 🧪 Development Inventory

```ini
[webservers]
web-01 ansible_host=web-01

[webservers:vars]
environment=development
web_server_port=8080
max_connections=50
```

---

# 🛠️ Staging Inventory

```ini
[webservers]
web-01 ansible_host=web-01
web-02 ansible_host=web-02

[webservers:vars]
environment=staging
web_server_port=80
max_connections=100
```

---

# 🏭 Production Inventory

```ini
[webservers]
web-01 ansible_host=web-01
web-02 ansible_host=web-02
web-03 ansible_host=web-03

[webservers:vars]
environment=production
web_server_port=80
max_connections=200
```

---

# 📄 Development Variables

```yaml
---
environment_name: "Development"
debug_mode: true
log_level: "debug"
backup_enabled: false
```

---

# 📄 Staging Variables

```yaml
---
environment_name: "Staging"
debug_mode: false
log_level: "info"
backup_enabled: true
```

---

# 📄 Production Variables

```yaml
---
environment_name: "Production"
debug_mode: false
log_level: "warn"
backup_enabled: true
monitoring_enabled: true
ssl_enabled: true
```

---

# 🚀 Enhanced Deployment Playbook

## deploy-webserver-enhanced.yml

```yaml
---
- name: Deploy Web Servers with Environment-Specific Configuration
  hosts: webservers
  become: yes

  vars:
    document_root: /var/www/html

  tasks:

    - name: Display Deployment Info
      debug:
        msg: |
          Environment: {{ environment_name }}
          Port: {{ web_server_port }}

    - name: Install Apache
      apt:
        name: apache2
        state: present

    - name: Enable Apache Modules
      apache2_module:
        name: rewrite
        state: present

    - name: Configure Apache
      template:
        src: apache-enhanced.conf.j2
        dest: "/etc/apache2/sites-available/{{ inventory_hostname }}.conf"

    - name: Enable Site
      command: a2ensite "{{ inventory_hostname }}.conf"

    - name: Restart Apache
      systemd:
        name: apache2
        state: restarted
```

---

# 🌐 Enhanced Apache Template

```apache
<VirtualHost *:{{ web_server_port }}>

    ServerName {{ inventory_hostname }}
    DocumentRoot {{ document_root }}

    MaxRequestWorkers {{ max_connections }}

</VirtualHost>
```

---

# 📊 Monitoring Script

```bash
#!/bin/bash

echo "Monitoring Apache Server"

systemctl status apache2
```

---

# 📄 Logrotate Configuration

```bash
/var/log/apache2/*.log {

    daily
    rotate 7
    compress
    missingok

}
```

---

# 🚀 Deploy to Development

```bash
ansible-playbook -i environments/development/inventory.ini deploy-webserver-enhanced.yml -v
```

---

# 🚀 Deploy to Staging

```bash
ansible-playbook -i environments/staging/inventory.ini deploy-webserver-enhanced.yml -v
```

---

# 🚀 Deploy to Production

```bash
ansible-playbook -i environments/production/inventory.ini deploy-webserver-enhanced.yml -v
```

---

# 🔍 Verify Deployments

## Development

```bash
curl http://web-01:8080
```

---

## Staging

```bash
curl http://web-01
curl http://web-02
```

---

## Production

```bash
curl http://web-01
curl http://web-02
curl http://web-03
```

---

# 📚 Key Concepts Learned

| Concept                   | Description                    |
| ------------------------- | ------------------------------ |
| 🔁 Idempotency            | Same result every execution    |
| 🌍 Environment Management | Different configurations       |
| 🧩 Templates              | Dynamic configuration          |
| 🔄 Automation             | Eliminate manual tasks         |
| 📈 Scalability            | Deploy across multiple systems |
| 🔐 Security               | Firewall and secure access     |

---

# 🛑 Troubleshooting

| Problem            | Solution            |
| ------------------ | ------------------- |
| SSH Failure        | Verify SSH Keys     |
| Apache Not Running | Check Service Logs  |
| Firewall Blocked   | Verify Port Access  |
| YAML Errors        | Validate Syntax     |
| Template Errors    | Check Jinja2 Syntax |

---

# 📌 Useful Commands

## Inventory List

```bash
ansible-inventory -i inventory.ini --list
```

---

## Gather Facts

```bash
ansible webservers -m setup
```

---

## Syntax Check

```bash
ansible-playbook deploy-webserver.yml --syntax-check
```

---

## Dry Run

```bash
ansible-playbook deploy-webserver.yml --check
```

---

# 🎉 Conclusion

In this lab you learned how to:

✅ Deploy scalable web infrastructure
✅ Automate Linux servers using Ansible
✅ Configure multiple environments
✅ Use templates and inventories
✅ Implement scalable automation workflows

---

# 👨‍💻 Author

## Hafiz Muhammad Salman

### ☁️ Cloud DevOps Engineer | Linux Administrator

📧 Email: [hafizmuhammadsalman13@gmail.com](mailto:hafizmuhammadsalman13@gmail.com)

📱 Mobile: +92 314 3563640

💻 GitHub: https://github.com/msalman199

🔗 LinkedIn: https://www.linkedin.com/in/muhammad-salman-519359350/
