
# 🌐 Networking Automation with Ansible 🚀

<div align="center">

![Ansible](https://img.shields.io/badge/Automation-Ansible-red?style=for-the-badge&logo=ansible)
![Linux](https://img.shields.io/badge/Platform-Linux-yellow?style=for-the-badge&logo=linux)
![Networking](https://img.shields.io/badge/Networking-Automation-blue?style=for-the-badge&logo=cisco)
![Firewall](https://img.shields.io/badge/Firewall-firewalld-orange?style=for-the-badge&logo=firefox)
![YAML](https://img.shields.io/badge/Language-YAML-purple?style=for-the-badge&logo=yaml)
![RHCE](https://img.shields.io/badge/Certification-RHCE-success?style=for-the-badge&logo=redhat)

# ⚡ Networking Automation with Ansible Lab

### 🔥 Enterprise Network Automation using Ansible & Linux

</div>

---

# 📚 Lab Objectives

## 🎯 By the end of this lab, you will be able to:

✅ Understand the fundamentals of network automation using Ansible  
✅ Configure network interfaces using the `nmcli` module  
✅ Automate firewall configurations using the `firewalld` module  
✅ Validate network connectivity and configurations  
✅ Apply enterprise-level automation best practices  
✅ Prepare for RHCE networking automation scenarios  

---

# 🛠️ Prerequisites

## 📌 Required Skills

- 🐧 Basic Linux command line knowledge
- 📄 YAML syntax understanding
- 🌐 Networking fundamentals
- ⚙️ Ansible basics
- ✍️ Experience with Vim/Nano editors

---

# 💻 Lab Environment Setup

## ☁️ Cloud Machines

| System | Hostname | IP Address |
|--------|-----------|------------|
| 🎛️ Control Node | ansible-control | 192.168.1.10 |
| 🌍 Web Server | web-server | 192.168.1.20 |
| 🗄️ Database Server | db-server | 192.168.1.30 |

---

# 📂 Create Working Directory

## 🚀 Step 1

```bash
cd /home/student/ansible-labs
mkdir lab8-networking
cd lab8-networking
````

---

# 🧾 Task 1: Configure Network Interfaces with nmcli

# 📌 Subtask 1.1 — Create Inventory File

## ✨ Create inventory.ini

```bash
vim inventory.ini
```

## 📄 Add Configuration

```ini
[webservers]
web-server ansible_host=192.168.1.20

[databases]
db-server ansible_host=192.168.1.30

[all:vars]
ansible_user=student
ansible_ssh_private_key_file=/home/student/.ssh/id_rsa
```

---

# 🔍 Test Connectivity

```bash
ansible all -i inventory.ini -m ping
```

---

# 📌 Subtask 1.2 — Create Network Configuration Playbook

## ✨ Create Playbook

```bash
vim network-config.yml
```

## ⚙️ Network Configuration Playbook

```yaml
---
- name: Configure Network Interfaces and Hostnames
  hosts: all
  become: yes

  vars:
    dns_servers:
      - 8.8.8.8
      - 8.8.4.4

  tasks:

    - name: Set hostname for web server
      hostname:
        name: web-server.lab.local
      when: inventory_hostname == 'web-server'

    - name: Set hostname for database server
      hostname:
        name: db-server.lab.local
      when: inventory_hostname == 'db-server'

    - name: Configure static IP for web server
      nmcli:
        conn_name: "System eth0"
        ifname: eth0
        type: ethernet
        ip4: 192.168.1.20/24
        gw4: 192.168.1.1
        dns4: "{{ dns_servers }}"
        state: present
      when: inventory_hostname == 'web-server'
      notify: restart network

    - name: Configure static IP for database server
      nmcli:
        conn_name: "System eth0"
        ifname: eth0
        type: ethernet
        ip4: 192.168.1.30/24
        gw4: 192.168.1.1
        dns4: "{{ dns_servers }}"
        state: present
      when: inventory_hostname == 'db-server'
      notify: restart network

    - name: Add secondary IP to web server
      nmcli:
        conn_name: "System eth0"
        ifname: eth0
        type: ethernet
        ip4: 192.168.1.21/24
        state: present
      when: inventory_hostname == 'web-server'
      notify: restart network

    - name: Ensure network connection is up
      nmcli:
        conn_name: "System eth0"
        state: up

  handlers:
    - name: restart network
      systemd:
        name: NetworkManager
        state: restarted
```

---

# ▶️ Execute Playbook

```bash
ansible-playbook -i inventory.ini network-config.yml
```

---

# 📌 Subtask 1.3 — Verify Network Configuration

## ✨ Create Verification Playbook

```bash
vim verify-network.yml
```

## 📄 Verification Playbook

```yaml
---
- name: Verify Network Configuration
  hosts: all
  become: yes

  tasks:

    - name: Check hostname configuration
      command: hostname
      register: current_hostname

    - name: Display current hostname
      debug:
        msg: "Current hostname: {{ current_hostname.stdout }}"

    - name: Get network interface information
      command: nmcli connection show
      register: nmcli_connections

    - name: Display network connections
      debug:
        msg: "{{ nmcli_connections.stdout_lines }}"

    - name: Check IP address assignment
      command: ip addr show eth0
      register: ip_info

    - name: Display IP configuration
      debug:
        msg: "{{ ip_info.stdout_lines }}"
```

---

# ▶️ Run Verification

```bash
ansible-playbook -i inventory.ini verify-network.yml
```

---

# 🔥 Task 2: Firewall Automation with firewalld

# 📌 Subtask 2.1 — Configure Firewall Rules

## ✨ Create Firewall Playbook

```bash
vim firewall-config.yml
```

## 🔐 Firewall Configuration

```yaml
---
- name: Configure Firewall Rules with firewalld
  hosts: all
  become: yes

  tasks:

    - name: Ensure firewalld is installed
      package:
        name: firewalld
        state: present

    - name: Start and enable firewalld service
      systemd:
        name: firewalld
        state: started
        enabled: yes

    - name: Allow HTTP traffic
      firewalld:
        service: http
        permanent: yes
        state: enabled
        immediate: yes

    - name: Allow HTTPS traffic
      firewalld:
        service: https
        permanent: yes
        state: enabled
        immediate: yes

    - name: Allow SSH
      firewalld:
        service: ssh
        permanent: yes
        state: enabled
        immediate: yes

    - name: Allow MySQL
      firewalld:
        service: mysql
        permanent: yes
        state: enabled
        immediate: yes
```

---

# ▶️ Execute Firewall Playbook

```bash
ansible-playbook -i inventory.ini firewall-config.yml
```

---

# 📌 Subtask 2.2 — Advanced Firewall Rules

## ✨ Create Advanced Firewall Playbook

```bash
vim advanced-firewall.yml
```

## 🚀 Advanced Firewall Configuration

```yaml
---
- name: Advanced Firewall Configuration
  hosts: all
  become: yes

  tasks:

    - name: Create custom firewall zone
      firewalld:
        zone: dmz
        permanent: yes
        state: present
        immediate: yes

    - name: Configure SSH rate limiting
      firewalld:
        rich_rule: 'rule service name="ssh" accept limit value="3/m"'
        permanent: yes
        state: enabled
        immediate: yes
        zone: public

    - name: Block suspicious network range
      firewalld:
        rich_rule: 'rule family="ipv4" source address="10.0.0.0/8" drop'
        permanent: yes
        state: enabled
        immediate: yes
        zone: public
```

---

# ▶️ Execute Advanced Firewall Rules

```bash
ansible-playbook -i inventory.ini advanced-firewall.yml
```

---

# 🌍 Task 3: Network Validation & Testing

# 📌 Subtask 3.1 — Validation Playbook

## ✨ Create Validation Playbook

```bash
vim network-validation.yml
```

## 🔍 Validation Configuration

```yaml
---
- name: Comprehensive Network Validation
  hosts: all
  become: yes

  tasks:

    - name: Check firewall status
      command: firewall-cmd --state
      register: firewall_status

    - name: Display firewall status
      debug:
        msg: "Firewall Status: {{ firewall_status.stdout }}"

    - name: Check active zones
      command: firewall-cmd --get-active-zones
      register: active_zones

    - name: Display active zones
      debug:
        msg: "{{ active_zones.stdout_lines }}"
```

---

# ▶️ Run Validation

```bash
ansible-playbook -i inventory.ini network-validation.yml
```

---

# 🧪 Subtask 3.2 — Automated Network Testing Suite

## ✨ Create Testing Suite

```bash
vim network-testing-suite.yml
```

## ⚡ Testing Playbook

```yaml
---
- name: Automated Network Testing Suite
  hosts: all
  become: yes

  tasks:

    - name: Test localhost connectivity
      ping:
        data: 127.0.0.1

    - name: Test DNS resolution
      command: nslookup redhat.com

    - name: Check interface configuration
      command: ip addr show eth0

    - name: Check firewall service
      systemd:
        name: firewalld
```

---

# ▶️ Execute Testing Suite

```bash
ansible-playbook -i inventory.ini network-testing-suite.yml
```

---

# 🛠️ Subtask 3.3 — Network Troubleshooting

## ✨ Create Troubleshooting Playbook

```bash
vim network-troubleshooting.yml
```

## 🔧 Troubleshooting Playbook

```yaml
---
- name: Network Troubleshooting and Diagnostics
  hosts: all
  become: yes

  tasks:

    - name: Check routing table
      command: ip route show
      register: routing_table

    - name: Display routes
      debug:
        msg: "{{ routing_table.stdout_lines }}"

    - name: Check listening ports
      command: ss -tuln
      register: network_stats

    - name: Display ports
      debug:
        msg: "{{ network_stats.stdout_lines }}"
```

---

# ▶️ Execute Troubleshooting Playbook

```bash
ansible-playbook -i inventory.ini network-troubleshooting.yml
```

---

# 📊 View Generated Reports

```bash
ls -la reports/
cat reports/network-report-web-server.txt
cat reports/network-report-db-server.txt
```

---

# 🚨 Common Troubleshooting Tips

## ❌ nmcli Permission Errors

✅ Ensure:

```yaml
become: yes
```

---

## ❌ DNS Resolution Fails

✅ Verify:

* Correct DNS Servers
* Internet Connectivity
* Gateway Configuration

---

## ❌ Firewall Blocking Services

✅ Check:

```bash
firewall-cmd --list-all
```

---

## ❌ Firewalld Fails to Start

✅ Troubleshoot with:

```bash
journalctl -u firewalld
```

---

# 🏆 Conclusion

## 🎉 Lab Achievements

✅ Automated Network Interface Configuration
✅ Configured Enterprise Firewall Rules
✅ Implemented Validation & Troubleshooting
✅ Applied RHCE-Level Automation Skills
✅ Improved Infrastructure Security

---

# 🌟 Real World Applications

* ☁️ Cloud Infrastructure Automation
* 🏢 Enterprise Network Management
* 🔐 Security Compliance
* 🚀 DevOps CI/CD Integration
* 💾 Disaster Recovery Automation

---

# 🎯 RHCE Exam Preparation

This lab helps you prepare for:

✅ Network Automation
✅ Ansible Playbook Development
✅ Firewall Automation
✅ Enterprise Linux Administration
✅ Troubleshooting Skills

---

# 📈 Next Steps

## 🚀 Continue Learning

* Learn Ansible Roles
* Explore Jinja2 Templates
* Integrate Monitoring Tools
* Practice Molecule Testing
* Build CI/CD Pipelines

---

# 👨‍💻 Author

## Hafiz Muhammad Salman

### ☁️ Cloud DevOps Engineer | Linux Administrator | Automation Enthusiast

📧 Email: [hafizmuhammadsalman13@gmail.com](mailto:hafizmuhammadsalman13@gmail.com)
📱 Mobile: +923143563640
🌐 GitHub: https://github.com/msalman199

---

<div align="center">

# ⭐ THANK YOU FOR VISITING ⭐

### 🚀 Happy Automating with Ansible 🚀

</div>
```
