# 🚀 Configuring Firewalls Using Ansible

<div align="center">

![Ansible](https://img.shields.io/badge/Automation-Ansible-red?style=for-the-badge&logo=ansible)
![Firewalld](https://img.shields.io/badge/Firewall-Firewalld-orange?style=for-the-badge&logo=firefoxbrowser)
![Linux](https://img.shields.io/badge/Platform-Linux-yellow?style=for-the-badge&logo=linux)
![RHCE](https://img.shields.io/badge/RHCE-Lab-blue?style=for-the-badge&logo=redhat)
![Security](https://img.shields.io/badge/Security-Automation-green?style=for-the-badge&logo=securityscorecard)

# 🔥 Enterprise Firewall Automation with Ansible 🔥

</div>

---

# 📚 Lab Overview

This lab demonstrates how to automate Linux firewall management using **Ansible** and **firewalld** in enterprise environments.

You will learn how to:

- 🔥 Configure firewalld services automatically
- 🌐 Manage firewall zones dynamically
- ⚙️ Use Ansible handlers efficiently
- 🛡️ Implement enterprise firewall automation
- 📊 Validate and troubleshoot firewall configurations

---

# 🎯 Objectives

By the end of this lab, you will be able to:

✅ Understand the fundamentals of firewall automation using Ansible  
✅ Write Ansible playbooks to configure firewalld services  
✅ Implement dynamic firewall zone and rule management using variables  
✅ Use Ansible handlers to manage firewall service reloads efficiently  
✅ Apply best practices for firewall configuration management in enterprise environments  

---

# 🧠 Prerequisites

Before starting this lab, you should have:

- 🐧 Basic understanding of Linux command line operations
- 📄 Familiarity with YAML syntax and structure
- ⚡ Knowledge of Ansible fundamentals
- 🔒 Understanding of firewall concepts and network security basics
- 🌍 Experience with SSH and remote system administration

---

# 📖 Required Knowledge Areas

| 🛠️ Technology | 📋 Description |
|---|---|
| ⚙️ Ansible | Playbooks, tasks, handlers, variables |
| 🐧 Linux Administration | Services, permissions, networking |
| 🔥 Firewalls | Ports, protocols, network zones |
| 📄 YAML | Syntax and formatting |
| 🌐 Networking | SSH and remote access |

---

# ☁️ Lab Environment Setup

## 🖥️ Al Nafi Cloud Environment

Good News! Al Nafi provides ready-to-use Linux-based cloud machines for this lab.

Simply click **Start Lab** to access your pre-configured environment.

No need to create virtual machines manually.

---

# 📦 What's Included in the Environment

| 💻 Resource | 📋 Description |
|---|---|
| 🖥️ Control Node | CentOS/RHEL 8+ with Ansible installed |
| 🌐 Managed Nodes | Two target systems |
| 🔗 Network Access | Full connectivity |
| 🔑 Root Access | Administrative privileges |

---

# 🧩 Task 1 — Configure Firewalld for HTTP and HTTPS

---

# 📁 Subtask 1.1 — Create Project Structure

## 🛠️ Create Main Project Directory

```bash
mkdir -p ~/firewall-ansible-lab
cd ~/firewall-ansible-lab
```

## 🛠️ Create Project Subdirectories

```bash
mkdir -p {playbooks,inventory,group_vars,host_vars}
```

## 🛠️ Create Inventory File

```bash
touch inventory/hosts.yml
```

---

# 🌐 Subtask 1.2 — Configure Inventory File

## 🛠️ Edit Inventory File

```bash
nano inventory/hosts.yml
```

## 📄 Add Inventory Configuration

```yaml
all:
  children:
    webservers:
      hosts:
        web1:
          ansible_host: 192.168.1.10
          ansible_user: root

        web2:
          ansible_host: 192.168.1.11
          ansible_user: root

    firewalls:
      hosts:
        firewall1:
          ansible_host: 192.168.1.20
          ansible_user: root
```

> ⚠️ Replace the IP addresses with the actual IPs provided in your environment.

---

# 🔥 Subtask 1.3 — Create Basic Firewall Playbook

## 🛠️ Create Main Playbook

```bash
nano playbooks/configure-basic-firewall.yml
```

## 📄 Add Playbook Content

```yaml
---
- name: Configure Firewalld for Web Services
  hosts: webservers
  become: yes

  vars:
    web_services:
      - http
      - https

    firewall_zone: public

  tasks:

    - name: Ensure firewalld is installed
      package:
        name: firewalld
        state: present

    - name: Ensure firewalld service is running and enabled
      systemd:
        name: firewalld
        state: started
        enabled: yes

    - name: Allow web services through firewall
      firewalld:
        service: "{{ item }}"
        zone: "{{ firewall_zone }}"
        permanent: yes
        state: enabled
        immediate: yes
      loop: "{{ web_services }}"
      notify: reload firewalld

    - name: Verify firewall rules are active
      command: firewall-cmd --list-services --zone={{ firewall_zone }}
      register: active_services
      changed_when: false

    - name: Display active services
      debug:
        msg: "Active services in {{ firewall_zone }} zone: {{ active_services.stdout }}"

  handlers:

    - name: reload firewalld
      systemd:
        name: firewalld
        state: reloaded
```

---

# ▶️ Subtask 1.4 — Execute Basic Playbook

## 🛠️ Run the Playbook

```bash
ansible-playbook -i inventory/hosts.yml playbooks/configure-basic-firewall.yml
```

## 🛠️ Verify Firewall Rules

```bash
ansible webservers -i inventory/hosts.yml -m command -a "firewall-cmd --list-all"
```

---

# 🧩 Task 2 — Dynamic Firewall Zone Management

---

# 📄 Subtask 2.1 — Create Dynamic Variables

## 🛠️ Create Group Variables File

```bash
nano group_vars/webservers.yml
```

## 📄 Add Variable Configuration

```yaml
---
firewall_zones:

  - name: public
    target: default

    services:
      - http
      - https
      - ssh

    ports:
      - "8080/tcp"
      - "8443/tcp"

    rich_rules:
      - 'rule family="ipv4" source address="10.0.0.0/8" service name="ssh" accept'

  - name: internal
    target: default

    services:
      - ssh
      - dhcpv6-client

    ports:
      - "3306/tcp"
      - "5432/tcp"

    sources:
      - "192.168.1.0/24"
      - "10.0.0.0/8"

default_zone: public
```

---

# ⚙️ Subtask 2.2 — Create Advanced Dynamic Playbook

## 🛠️ Create Playbook

```bash
nano playbooks/configure-dynamic-firewall.yml
```

## 📄 Add Dynamic Firewall Playbook

```yaml
---
- name: Configure Dynamic Firewalld Zones and Rules
  hosts: webservers
  become: yes

  tasks:

    - name: Ensure firewalld is installed
      package:
        name: firewalld
        state: latest

    - name: Ensure firewalld is running
      systemd:
        name: firewalld
        state: started
        enabled: yes

    - name: Configure firewall zones
      firewalld:
        zone: "{{ item.name }}"
        state: present
        permanent: yes
      loop: "{{ firewall_zones }}"
      notify: reload firewalld

    - name: Configure services for zones
      firewalld:
        zone: "{{ item.0.name }}"
        service: "{{ item.1 }}"
        permanent: yes
        state: enabled
        immediate: yes

      with_subelements:
        - "{{ firewall_zones }}"
        - services

    - name: Configure ports
      firewalld:
        zone: "{{ item.0.name }}"
        port: "{{ item.1 }}"
        permanent: yes
        state: enabled
        immediate: yes

      with_subelements:
        - "{{ firewall_zones }}"
        - ports

  handlers:

    - name: reload firewalld
      systemd:
        name: firewalld
        state: reloaded
```

---

# 🌐 Subtask 2.3 — Host-Specific Variables

---

# 🖥️ Configure web1 Variables

## 🛠️ Create Host Variables File

```bash
nano host_vars/web1.yml
```

## 📄 Add Configuration

```yaml
---
firewall_zones:

  - name: public
    target: default

    services:
      - http
      - https
      - ssh

    ports:
      - "80/tcp"
      - "443/tcp"
      - "8080/tcp"

default_zone: public

server_role: "public_web"
```

---

# 🖥️ Configure web2 Variables

## 🛠️ Create Host Variables File

```bash
nano host_vars/web2.yml
```

## 📄 Add Configuration

```yaml
---
firewall_zones:

  - name: internal
    target: default

    services:
      - ssh
      - http

    ports:
      - "8080/tcp"
      - "3306/tcp"

    sources:
      - "192.168.1.0/24"
      - "10.0.0.0/8"

default_zone: internal

server_role: "internal_app"
```

---

# ▶️ Subtask 2.4 — Execute Dynamic Configuration

## 🛠️ Run Advanced Playbook

```bash
ansible-playbook -i inventory/hosts.yml playbooks/configure-dynamic-firewall.yml -v
```

## 🛠️ Verify Default Zone

```bash
ansible web1 -i inventory/hosts.yml -m command -a "firewall-cmd --get-default-zone"
```

## 🛠️ Verify All Zones

```bash
ansible web2 -i inventory/hosts.yml -m command -a "firewall-cmd --list-all-zones"
```

---

# 🧩 Task 3 — Use Handlers to Reload Firewalld

---

# ⚙️ Subtask 3.1 — Create Handler-Based Playbook

## 🛠️ Create Playbook

```bash
nano playbooks/firewall-with-handlers.yml
```

## 📄 Add Handler Playbook Content

```yaml
---
- name: Advanced Firewall Configuration with Handlers
  hosts: webservers
  become: yes

  tasks:

    - name: Install firewalld
      package:
        name: firewalld
        state: present

      notify:
        - start firewalld
        - enable firewalld

    - name: Configure firewall services
      firewalld:
        service: "{{ item }}"
        zone: public
        permanent: yes
        state: enabled
        immediate: yes

      loop:
        - http
        - https
        - ssh

      notify:
        - reload firewalld

  handlers:

    - name: start firewalld
      systemd:
        name: firewalld
        state: started

    - name: enable firewalld
      systemd:
        name: firewalld
        enabled: yes

    - name: reload firewalld
      systemd:
        name: firewalld
        state: reloaded
```

---

# ▶️ Subtask 3.2 — Test Handler Functionality

## 🛠️ Run Handler Playbook

```bash
ansible-playbook -i inventory/hosts.yml playbooks/firewall-with-handlers.yml -v
```

## 🛠️ Verify Logs

```bash
ansible webservers -i inventory/hosts.yml -m command -a "cat /var/log/firewall-changes.log"
```

---

# 🧪 Subtask 3.3 — Create Validation Playbook

## 🛠️ Create Validation File

```bash
nano playbooks/validate-firewall-config.yml
```

## 📄 Add Validation Playbook

```yaml
---
- name: Validate Firewall Configuration
  hosts: webservers
  become: yes

  tasks:

    - name: Check firewalld service
      command: systemctl is-active firewalld
      register: firewall_status

    - name: Display firewall status
      debug:
        var: firewall_status.stdout

    - name: Verify services
      command: firewall-cmd --list-services
      register: firewall_services

    - name: Display active services
      debug:
        var: firewall_services.stdout
```

---

# 🧪 Validation Commands

## ✅ Verify Firewalld Status

```bash
ansible webservers -i inventory/hosts.yml -m command -a "systemctl is-active firewalld"
```

## ✅ Verify Services

```bash
ansible webservers -i inventory/hosts.yml -m command -a "firewall-cmd --list-services --zone=public"
```

## ✅ Verify Ports

```bash
ansible webservers -i inventory/hosts.yml -m command -a "firewall-cmd --list-ports --zone=public"
```

---

# 🐞 Troubleshooting Common Issues

---

# ❌ Issue 1 — Firewalld Not Starting

## 🛠️ Check Status

```bash
systemctl status firewalld
```

## 🛠️ Stop Conflicting iptables

```bash
systemctl stop iptables
systemctl disable iptables
```

## 🛠️ Restart firewalld

```bash
systemctl restart firewalld
```

---

# ❌ Issue 2 — Rules Not Persisting

## ✅ Correct Persistent Rule Example

```yaml
firewalld:
  service: http
  zone: public
  permanent: yes
  immediate: yes
  state: enabled
```

---

# ❌ Issue 3 — Handler Not Triggering

## ✅ Proper Handler Notification

```yaml
notify: reload firewalld
```

## ✅ Matching Handler Name

```yaml
handlers:
  - name: reload firewalld
```

---

# 🔒 Security Best Practices

| 🔐 Practice | 📋 Description |
|---|---|
| 🔥 Permanent Rules | Persist after reboot |
| 🌐 Zone Separation | Public vs Internal |
| 📊 Logging | Track changes |
| 🔑 Restrict SSH | Trusted IP ranges |
| ⚙️ Handlers | Efficient reloads |

---

# 🌍 Real-World Applications

## 🏢 Enterprise Security

Automate consistent firewall rules across infrastructure.

## ⚡ DevOps Integration

Include firewall automation inside CI/CD workflows.

## 📋 Compliance

Maintain security standards and auditing.

## 🚑 Disaster Recovery

Restore firewall configurations rapidly.

---

# 📈 Skills You Learned

✅ Automated firewall configuration  
✅ Dynamic firewall zone management  
✅ Ansible handler implementation  
✅ Security automation techniques  
✅ Firewall validation and testing  
✅ Enterprise infrastructure automation  

---

# 🎓 Conclusion

Congratulations! 🎉

You successfully completed the **Configuring Firewalls Using Ansible** lab.

You now understand how to:

- 🔥 Automate firewall management
- ⚙️ Build scalable Ansible playbooks
- 🌐 Manage dynamic firewall zones
- 🛡️ Implement enterprise security automation
- 📊 Validate and troubleshoot configurations

These are production-level skills used in:

- 🏢 Enterprise Linux Administration
- ☁️ Cloud Infrastructure Automation
- 🔒 Cybersecurity Operations
- 🚀 DevOps Engineering
- 🎓 RHCE Certification Preparation

---

# 👨‍💻 Technology Stack

| 🛠️ Technology | 📋 Purpose |
|---|---|
| ⚙️ Ansible | Automation |
| 🔥 Firewalld | Firewall Management |
| 🐧 Linux | Operating System |
| ☁️ Al Nafi Cloud | Lab Infrastructure |
| 🔐 Network Security | Enterprise Protection |

---

<div align="center">

# ⭐ Happy Automating with Ansible! ⭐

</div>
