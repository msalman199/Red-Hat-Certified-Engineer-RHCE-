
# 📜 Automating System Logging Configuration with Ansible 🚀

<div align="center">

![Linux](https://img.shields.io/badge/Linux-System_Administration-yellow?style=for-the-badge&logo=linux)
![Ansible](https://img.shields.io/badge/Automation-Ansible-red?style=for-the-badge&logo=ansible)
![Rsyslog](https://img.shields.io/badge/Logging-rsyslog-blue?style=for-the-badge)
![Logrotate](https://img.shields.io/badge/Logrotate-Management-green?style=for-the-badge)
![Security](https://img.shields.io/badge/Security-Monitoring-orange?style=for-the-badge)
![RHCE](https://img.shields.io/badge/RHCE-Preparation-success?style=for-the-badge&logo=redhat)

# ⚡ Enterprise Logging Automation Lab

### 🔥 Automating System Logging Configuration using Ansible

</div>

---

# 📚 Objectives

## 🎯 By the end of this lab, students will be able to:

✅ Understand system logging fundamentals  
✅ Configure rsyslog service using Ansible  
✅ Automate log rotation with logrotate  
✅ Set up centralized logging infrastructure  
✅ Create retention policies for log management  
✅ Build advanced logging playbooks  
✅ Troubleshoot logging issues efficiently  

---

# 🛠️ Prerequisites

- 🐧 Basic Linux Administration
- ⚙️ Ansible Fundamentals
- 📄 YAML Syntax Knowledge
- 🌐 Networking & SSH Basics
- 🔐 File Permissions Understanding
- ✍️ Experience with Vim/Nano
- ⚡ systemd Service Knowledge

---

# ☁️ Lab Environment Setup

| System | Role | IP Address |
|--------|------|------------|
| 🎛️ Control Node | Ansible Controller | 192.168.1.10 |
| 🖥️ node1 | Logging Server | 192.168.1.10 |
| 🖥️ node2 | Logging Server | 192.168.1.11 |
| 🖥️ node3 | Log Client | 192.168.1.12 |

---

# 📂 Task 1 — Configure Basic System Logging

## 🚀 Create Project Directory

```bash
mkdir -p ~/ansible-logging-lab
cd ~/ansible-logging-lab
mkdir -p {playbooks,roles,inventory,templates,files}
```

---

## 📝 Create Inventory File

```bash
cat > inventory/hosts << EOF
[logging_servers]
node1 ansible_host=192.168.1.10
node2 ansible_host=192.168.1.11

[log_clients]
node3 ansible_host=192.168.1.12

[all:vars]
ansible_user=ansible
ansible_ssh_private_key_file=~/.ssh/id_rsa
EOF
```

---

## 🔍 Test Ansible Connectivity

```bash
ansible all -i inventory/hosts -m ping
```

---

## 🔎 Verify rsyslog Installation

```bash
ansible all -i inventory/hosts -m shell -a "rpm -q rsyslog"
```

---

# ⚙️ Configure Rsyslog Playbook

```yaml
---
- name: Configure System Logging with Rsyslog
  hosts: all
  become: yes

  vars:
    rsyslog_conf_dir: /etc/rsyslog.d
    log_dir: /var/log
    rsyslog_port: 514

  tasks:

    - name: Install rsyslog package
      package:
        name: rsyslog
        state: present

    - name: Create rsyslog configuration directory
      file:
        path: "{{ rsyslog_conf_dir }}"
        state: directory
        owner: root
        group: root
        mode: '0755'

    - name: Configure rsyslog
      template:
        src: rsyslog.conf.j2
        dest: /etc/rsyslog.conf
      notify: restart rsyslog

    - name: Enable and start rsyslog
      systemd:
        name: rsyslog
        enabled: yes
        state: started

  handlers:
    - name: restart rsyslog
      systemd:
        name: rsyslog
        state: restarted
```

---

# 📝 Rsyslog Template

```jinja
module(load="imuxsock")
module(load="imjournal")

{% if inventory_hostname in groups['logging_servers'] %}
module(load="imudp")
module(load="imtcp")
{% endif %}

global(workDirectory="/var/lib/rsyslog")

include(file="/etc/rsyslog.d/*.conf" mode="optional")

*.info;mail.none;authpriv.none;cron.none /var/log/messages
authpriv.*                               /var/log/secure

{% if inventory_hostname in groups['log_clients'] %}
*.* @@{{ hostvars[groups['logging_servers'][0]]['ansible_host'] }}:514
{% endif %}
```

---

# ▶️ Execute Playbook

```bash
ansible-playbook -i inventory/hosts playbooks/configure-rsyslog.yml
```

---

# 🌐 Configure Centralized Logging

## ⚙️ Central Logging Playbook

```yaml
---
- name: Configure Central Logging Server
  hosts: logging_servers
  become: yes

  vars:
    remote_log_dir: /var/log/remote
    rsyslog_port: 514

  tasks:

    - name: Create remote log directory
      file:
        path: "{{ remote_log_dir }}"
        state: directory
        owner: root
        group: root
        mode: '0755'

    - name: Open syslog UDP port
      firewalld:
        port: "{{ rsyslog_port }}/udp"
        permanent: yes
        state: enabled
        immediate: yes

    - name: Open syslog TCP port
      firewalld:
        port: "{{ rsyslog_port }}/tcp"
        permanent: yes
        state: enabled
        immediate: yes
```

---

# 📤 Configure Log Clients

```yaml
---
- name: Configure Log Clients
  hosts: log_clients
  become: yes

  vars:
    central_server: "{{ hostvars[groups['logging_servers'][0]]['ansible_host'] }}"

  tasks:

    - name: Forward logs to central server
      copy:
        content: |
          *.* @@{{ central_server }}:514
        dest: /etc/rsyslog.d/20-forward.conf
      notify: restart rsyslog

  handlers:
    - name: restart rsyslog
      systemd:
        name: rsyslog
        state: restarted
```

---

# ▶️ Run Centralized Logging Setup

```bash
ansible-playbook -i inventory/hosts playbooks/setup-central-logging.yml
ansible-playbook -i inventory/hosts playbooks/configure-log-clients.yml
```

---

# 🧪 Test Centralized Logging

```bash
ansible log_clients -i inventory/hosts -m shell -a \
"logger -p local0.info 'Centralized logging test'"
```

---

# 🔄 Configure Log Rotation

## ⚙️ Logrotate Playbook

```yaml
---
- name: Configure Log Rotation
  hosts: all
  become: yes

  tasks:

    - name: Install logrotate
      package:
        name: logrotate
        state: present

    - name: Configure system log rotation
      copy:
        content: |
          /var/log/messages
          /var/log/secure
          /var/log/cron {
              daily
              rotate 30
              compress
              missingok
              notifempty
          }
        dest: /etc/logrotate.d/syslog
```

---

# 📊 Advanced Log Monitoring

```yaml
---
- name: Advanced Log Management
  hosts: all
  become: yes

  tasks:

    - name: Install monitoring tools
      package:
        name: "{{ item }}"
        state: present
      loop:
        - logwatch
        - mailx

    - name: Create monitoring script
      copy:
        dest: /usr/local/bin/log-space-monitor.sh
        mode: '0755'
        content: |
          #!/bin/bash
          echo "Checking log usage..."
          df -h /var/log
```

---

# ▶️ Execute Logrotate Playbook

```bash
ansible-playbook -i inventory/hosts playbooks/configure-logrotate.yml
```

---

# 🔍 Verify Logrotate

```bash
ansible all -i inventory/hosts -m shell -a \
"logrotate -d /etc/logrotate.conf"
```

---

# 🧪 Verification & Testing

## 🔎 Verify Logs Received

```bash
ansible logging_servers -i inventory/hosts -m shell -a \
"grep 'Test message' /var/log/remote/*/*.log"
```

---

## 🔄 Force Log Rotation

```bash
ansible all -i inventory/hosts -m shell -a \
"logrotate -f /etc/logrotate.conf"
```

---

# 🚨 Troubleshooting

## ❌ rsyslog Service Not Starting

```bash
rsyslogd -N1
journalctl -u rsyslog -n 20
```

---

## ❌ Central Server Not Receiving Logs

```bash
firewall-cmd --list-ports
netstat -tulpn | grep 514
```

---

## ❌ Log Rotation Not Working

```bash
logrotate -d /etc/logrotate.conf
cat /var/lib/logrotate/logrotate.status
```

---

# 🏆 Conclusion

## 🎉 Lab Achievements

✅ Automated rsyslog Configuration  
✅ Implemented Centralized Logging  
✅ Configured Log Rotation Policies  
✅ Created Monitoring & Alerting Scripts  
✅ Applied Enterprise Logging Best Practices  

---

# 🌟 Real-World Applications

- 🔐 Security Monitoring
- 📊 Compliance & Auditing
- ☁️ Cloud Logging Infrastructure
- 🚀 DevOps & SRE Operations
- 🏢 Enterprise System Administration

---

# 🎯 RHCE Exam Preparation

This lab prepares you for:

✅ Ansible Automation  
✅ Linux Administration  
✅ Centralized Logging  
✅ Monitoring & Troubleshooting  
✅ Enterprise Infrastructure Management  

---

# 👨‍💻 Author

## Hafiz Muhammad Salman

### ☁️ Cloud DevOps Engineer | Linux Administrator | Automation Enthusiast

📧 Email: hafizmuhammadsalman13@gmail.com  
📱 Mobile: +923143563640  
🌐 GitHub: https://github.com/msalman199  

---

<div align="center">

# ⭐ THANK YOU FOR VISITING ⭐

### 🚀 Happy Automating with Ansible 🚀

</div>
