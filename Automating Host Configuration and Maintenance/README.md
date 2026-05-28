# 🚀 Automating Host Configuration and Maintenance with Ansible

<p align="center">

![Ansible](https://img.shields.io/badge/Ansible-Automation-red?style=for-the-badge&logo=ansible)
![Linux](https://img.shields.io/badge/Linux-System_Administration-black?style=for-the-badge&logo=linux)
![YAML](https://img.shields.io/badge/YAML-Configuration-blue?style=for-the-badge&logo=yaml)
![RHCE](https://img.shields.io/badge/RHCE-Enterprise-red?style=for-the-badge&logo=redhat)
![CentOS](https://img.shields.io/badge/CentOS-RHEL_Stream-purple?style=for-the-badge&logo=centos)
![Automation](https://img.shields.io/badge/Infrastructure-Automation-success?style=for-the-badge)

</p>

---

# 📘 Lab: Automating Host Configuration and Maintenance

## 🎯 Objectives

By the end of this lab, students will be able to:

✅ Create and execute Ansible playbooks to automate system package and service management  
✅ Configure automated maintenance tasks including log rotation and package updates  
✅ Implement automated system reboot procedures with health checks  
✅ Understand best practices for configuration management in enterprise environments  
✅ Develop skills essential for the RHCE certification  

---

# 🧰 Technologies Used

| Technology | Purpose |
|---|---|
| 🟥 Ansible | Automation Engine |
| 🐧 Linux | System Administration |
| 📄 YAML | Configuration Language |
| 🔐 SSH | Secure Remote Access |
| 🔥 Firewalld | Firewall Management |
| 🧾 Logrotate | Log Management |
| ⚙️ Systemd | Service Management |
| 🟥 RHCE Concepts | Enterprise Automation |

---

# 📋 Prerequisites

Before starting this lab, students should have:

✅ Basic Linux command knowledge  
✅ YAML syntax familiarity  
✅ Knowledge of packages & services  
✅ SSH authentication understanding  
✅ Basic Ansible fundamentals  

---

# ☁️ Lab Environment Setup

## 🖥️ Environment Includes

| Node Type | Description |
|---|---|
| 🎛️ Control Node | CentOS/RHEL 8 with Ansible |
| 🖥️ Managed Nodes | node1 & node2 |
| 🔧 Tools | Pre-configured Dependencies |

---

# 📁 Directory Structure

```bash
mkdir -p ~/lab16-automation/{playbooks,inventory,roles,group_vars}
cd ~/lab16-automation
```

---

# ⚡ Verify Ansible Installation

```bash
ansible --version
```

---

# 🗂️ Create Inventory File

## 📄 inventory/hosts.yml

```yaml
all:
  children:
    webservers:
      hosts:
        node1:
          ansible_host: 192.168.1.10
        node2:
          ansible_host: 192.168.1.11
  vars:
    ansible_user: ansible
    ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

---

# ⚙️ Configure Ansible

## 📄 ansible.cfg

```ini
[defaults]
inventory = inventory/hosts.yml
remote_user = ansible
private_key_file = ~/.ssh/id_rsa
host_key_checking = False
retry_files_enabled = False
gathering = smart
fact_caching = memory

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False
```

---

# 🔗 Test Connectivity

```bash
ansible all -m ping
```

---

# 🚀 Task 1: Package & Service Management

# 🧩 Create Package Management Playbook

## 📄 playbooks/package-service-management.yml

```yaml
---
- name: System Package and Service Management
  hosts: all
  become: yes

  vars:
    required_packages:
      - htop
      - vim
      - curl
      - wget
      - git
      - rsync
      - logrotate
      - chrony

    required_services:
      - chronyd
      - sshd

    packages_to_remove:
      - telnet
      - rsh

  tasks:

    - name: Update package cache (RHEL/CentOS)
      yum:
        update_cache: yes
      when: ansible_os_family == "RedHat"

    - name: Install required packages
      yum:
        name: "{{ required_packages }}"
        state: present
      when: ansible_os_family == "RedHat"

    - name: Remove unwanted packages
      yum:
        name: "{{ packages_to_remove }}"
        state: absent
      when: ansible_os_family == "RedHat"

    - name: Ensure services are running
      systemd:
        name: "{{ item }}"
        state: started
        enabled: yes
      loop: "{{ required_services }}"
```

---

# ▶️ Run Playbook

```bash
ansible-playbook playbooks/package-service-management.yml
```

---

# ✅ Verify Installed Packages

```bash
ansible all -m shell -a "rpm -qa | grep -E 'htop|vim|curl'"
```

---

# 🌐 Task 2: Advanced Service Management

## 📄 playbooks/advanced-service-management.yml

```yaml
---
- name: Advanced Service Configuration Management
  hosts: all
  become: yes

  vars:
    web_services:
      - name: httpd
        package: httpd
        port: 80

  tasks:

    - name: Install Apache
      yum:
        name: httpd
        state: present

    - name: Create custom web page
      copy:
        content: |
          <html>
          <body>
          <h1>Configured with Ansible</h1>
          <p>Server: {{ ansible_hostname }}</p>
          </body>
          </html>
        dest: /var/www/html/index.html

    - name: Enable Firewall Port
      firewalld:
        port: 80/tcp
        permanent: yes
        state: enabled
        immediate: yes

    - name: Start Apache Service
      systemd:
        name: httpd
        state: started
        enabled: yes
```

---

# ▶️ Execute Service Playbook

```bash
ansible-playbook playbooks/advanced-service-management.yml
```

---

# 🧾 Task 3: Configure Log Rotation

## 📄 playbooks/log-rotation-setup.yml

```yaml
---
- name: Configure Log Rotation
  hosts: all
  become: yes

  tasks:

    - name: Install logrotate
      yum:
        name: logrotate
        state: present

    - name: Create log directory
      file:
        path: /var/log/myapp
        state: directory
        mode: '0755'

    - name: Configure logrotate
      template:
        src: logrotate.j2
        dest: /etc/logrotate.d/application-logs
```

---

# 📄 templates/logrotate.j2

```jinja
/var/log/myapp/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 0644 root root
}
```

---

# ▶️ Run Log Rotation Setup

```bash
ansible-playbook playbooks/log-rotation-setup.yml
```

---

# 🔄 Task 4: Automated Package Updates

## 📄 playbooks/automated-updates.yml

```yaml
---
- name: Automated Package Updates
  hosts: all
  become: yes

  tasks:

    - name: Backup package list
      shell: |
        rpm -qa > /backup/packages-before-update.txt

    - name: Apply Updates
      yum:
        name: "*"
        state: latest
        update_only: yes

    - name: Check kernel updates
      shell: |
        rpm -q kernel --last | head -n1
      register: kernel_check
```

---

# ▶️ Execute Update Playbook

```bash
ansible-playbook playbooks/automated-updates.yml
```

---

# 📊 Task 5: System Health Monitoring

## 📄 playbooks/system-health-check.yml

```yaml
---
- name: System Health Monitoring
  hosts: all
  become: yes

  tasks:

    - name: Check disk usage
      shell: df -h
      register: disk_usage

    - name: Check memory usage
      shell: free -m
      register: memory_usage

    - name: Check load average
      shell: uptime
      register: load_average

    - name: Display Report
      debug:
        msg:
          - "{{ disk_usage.stdout }}"
          - "{{ memory_usage.stdout }}"
          - "{{ load_average.stdout }}"
```

---

# ▶️ Run Health Monitoring

```bash
ansible-playbook playbooks/system-health-check.yml
```

---

# 🔁 Task 6: Automated Safe Reboot

## 📄 playbooks/automated-reboot.yml

```yaml
---
- name: Automated Reboot
  hosts: all
  become: yes
  serial: 1

  tasks:

    - name: Check reboot requirement
      stat:
        path: /var/run/reboot-required
      register: reboot_needed

    - name: Perform reboot
      reboot:
        reboot_timeout: 600
      when: reboot_needed.stat.exists

    - name: Wait for system
      wait_for_connection:
        timeout: 300
```

---

# ▶️ Execute Reboot Workflow

```bash
ansible-playbook playbooks/automated-reboot.yml
```

---

# 🛠️ Task 7: Comprehensive Maintenance Workflow

## 📄 playbooks/comprehensive-maintenance.yml

```yaml
---
- name: Comprehensive Maintenance Workflow
  hosts: all
  become: yes

  tasks:

    - name: Run Health Checks
      include_tasks: tasks/health-check.yml

    - name: Update Packages
      include_tasks: tasks/package-updates.yml

    - name: Configure Log Rotation
      include_tasks: tasks/log-rotation.yml

    - name: Service Management
      include_tasks: tasks/service-management.yml

    - name: Conditional Reboot
      include_tasks: tasks/conditional-reboot.yml
```

---

# ▶️ Run Complete Maintenance Workflow

```bash
ansible-playbook playbooks/comprehensive-maintenance.yml
```

---

# 📈 Verification Commands

## 🔍 Verify Services

```bash
systemctl status httpd
```

## 🔍 Verify Firewall

```bash
firewall-cmd --list-all
```

## 🔍 Verify Logs

```bash
ls -lh /var/log/myapp/
```

## 🔍 Verify Updates

```bash
yum check-update
```

---

# 🏆 Best Practices

✅ Use Idempotent Playbooks  
✅ Maintain Modular Structure  
✅ Use Variables for Reusability  
✅ Implement Health Checks  
✅ Backup Before Updates  
✅ Automate Monitoring  
✅ Use Secure SSH Authentication  
✅ Test Before Production Deployment  

---

# 🎓 RHCE Skills Covered

| RHCE Topic | Covered |
|---|---|
| Ansible Automation | ✅ |
| Package Management | ✅ |
| Service Management | ✅ |
| System Reboots | ✅ |
| Log Rotation | ✅ |
| Monitoring | ✅ |
| YAML Playbooks | ✅ |
| Inventory Management | ✅ |

---

# 📚 Learning Outcomes

After completing this lab, students can:

🚀 Automate Linux Administration  
⚙️ Manage Services Efficiently  
🔄 Perform Safe Automated Reboots  
📊 Monitor System Health  
🧾 Configure Enterprise Log Rotation  
🛡️ Maintain Secure Infrastructure  
🏢 Apply Enterprise Automation Practices  

---

# 🎉 Conclusion

This lab demonstrates how Ansible can automate enterprise Linux administration tasks including:

✅ Package Management  
✅ Service Configuration  
✅ Log Rotation  
✅ Automated Updates  
✅ System Monitoring  
✅ Safe Reboot Workflows  
✅ Maintenance Automation  

---

# 👨‍💻 Author

## Hafiz Muhammad Salman

📧 hafizmuhammadsalman13@gmail.com  
📱 +92 314 3563640  
🌐 GitHub: https://github.com/msalman199  

---

# ⭐ Happy Automating with Ansible & Linux 🚀
