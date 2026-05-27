# 🚀 Automating Service Management with Ansible

<p align="center">
  <img src="https://img.shields.io/badge/Automation-Ansible-red?style=for-the-badge&logo=ansible" />
  <img src="https://img.shields.io/badge/Linux-RHEL%20%7C%20CentOS-blue?style=for-the-badge&logo=linux" />
  <img src="https://img.shields.io/badge/Service-Systemd-green?style=for-the-badge&logo=systemd" />
  <img src="https://img.shields.io/badge/Infrastructure-DevOps-orange?style=for-the-badge&logo=devops" />
  <img src="https://img.shields.io/badge/YAML-Playbooks-yellow?style=for-the-badge&logo=yaml" />
</p>

---

# 📘 Automating Service Management with Ansible

## 🎯 Objectives

By the end of this lab, you will be able to:

- ✅ Create Ansible playbooks to automate service management using the `systemd` module
- ✅ Implement handlers to restart services only when configuration changes occur
- ✅ Validate service status and configurations across multiple hosts
- ✅ Apply best practices for service automation in enterprise environments
- ✅ Understand the relationship between configuration changes and service restarts

---

# 🧰 Prerequisites

Before starting this lab, you should have:

- 🐧 Basic understanding of Linux system administration
- ⚙️ Familiarity with `systemd` service management
- 📄 Knowledge of YAML syntax and structure
- 🤖 Previous experience with Ansible basics
- 🔐 Understanding of SSH key-based authentication
- 📝 Basic text editor skills (`vim`, `nano`, etc.)

---

# ☁️Environment Setup

## ✅ Environment Includes

- 1️⃣ Ansible Control Node (CentOS/RHEL 8 or 9)
- 2️⃣ Managed Nodes (CentOS/RHEL 8 or 9)
- 🔗 Pre-configured SSH connectivity
- 📦 Ansible already installed

---

# 📂 Recommended File Structure
---

# 🛠️ Task 1: Setting Up the Lab Environment

## 🔹 Verify Ansible Installation

```bash
ansible --version
```

---

## 🔹 Create Working Directory

```bash
mkdir -p ~/ansible-service-lab
cd ~/ansible-service-lab
```

---

## 🔹 Create Inventory File

### 📄 `inventory.ini`

```ini
[webservers]
node1 ansible_host=10.0.1.10
node2 ansible_host=10.0.1.11

[all:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=~/.ssh/id_rsa
```

---

## 🔹 Test Connectivity

```bash
ansible all -i inventory.ini -m ping
```

Expected Output:

```bash
SUCCESS
```

---

# 📦 Task 2: Install Required Services

## 📄 `setup-services.yml`

```yaml
---
- name: Setup Services for Management Lab
  hosts: webservers
  become: yes

  tasks:

    - name: Install Apache HTTP Server
      yum:
        name: httpd
        state: present
      when: ansible_os_family == "RedHat"

    - name: Install Apache HTTP Server (Ubuntu/Debian)
      apt:
        name: apache2
        state: present
        update_cache: yes
      when: ansible_os_family == "Debian"

    - name: Create custom web content directory
      file:
        path: /var/www/html/custom
        state: directory
        mode: '0755'
```

---

## ▶️ Run Playbook

```bash
ansible-playbook -i inventory.ini setup-services.yml
```

---

# ⚙️ Task 3: Basic Service Management

## 📄 `service-management.yml`

```yaml
---
- name: Comprehensive Service Management with Ansible
  hosts: webservers
  become: yes

  vars:
    web_service_name: "{{ 'httpd' if ansible_os_family == 'RedHat' else 'apache2' }}"
    web_port: 80

  tasks:

    - name: Ensure web service is installed
      package:
        name: "{{ web_service_name }}"
        state: present

    - name: Create custom index.html
      copy:
        content: |
          <h1>Ansible Managed Server</h1>
          <p>Server: {{ inventory_hostname }}</p>
        dest: /var/www/html/index.html
        mode: '0644'
      notify: restart web service

    - name: Ensure web service is started and enabled
      systemd:
        name: "{{ web_service_name }}"
        state: started
        enabled: yes

  handlers:

    - name: restart web service
      systemd:
        name: "{{ web_service_name }}"
        state: restarted
```

---

## ▶️ Run Service Management

```bash
ansible-playbook -i inventory.ini service-management.yml
```

---

# 🔄 Task 4: Advanced Multi-Service Management

## 📄 `advanced-service-management.yml`

```yaml
---
- name: Advanced Multi-Service Management
  hosts: webservers
  become: yes

  vars:
    services_to_manage:
      - name: httpd
        state: started
        enabled: yes

      - name: crond
        state: started
        enabled: yes

  tasks:

    - name: Manage Services
      systemd:
        name: "{{ item.name }}"
        state: "{{ item.state }}"
        enabled: "{{ item.enabled }}"
      loop: "{{ services_to_manage }}"
```

---

## ▶️ Execute Playbook

```bash
ansible-playbook -i inventory.ini advanced-service-management.yml
```

---

# 🔔 Task 5: Understanding Handlers

## 📄 `handler-demo.yml`

```yaml
---
- name: Demonstrating Handlers
  hosts: webservers
  become: yes

  vars:
    web_service: httpd

  tasks:

    - name: Update index page
      copy:
        content: |
          <h1>Handler Demo</h1>
        dest: /var/www/html/index.html
      notify:
        - restart web service

  handlers:

    - name: restart web service
      systemd:
        name: "{{ web_service }}"
        state: restarted
```

---

## ▶️ Execute Handler Demo

```bash
ansible-playbook -i inventory.ini handler-demo.yml
```

Run again to verify handlers trigger only on changes:

```bash
ansible-playbook -i inventory.ini handler-demo.yml
```

---

# 🧠 Task 6: Complex Handler Scenarios

## 📄 `complex-handlers.yml`

```yaml
---
- name: Complex Handler Scenarios
  hosts: webservers
  become: yes

  vars:
    web_service: httpd

  tasks:

    - name: Update configuration
      lineinfile:
        path: /etc/httpd/conf/httpd.conf
        regexp: '^#?ServerTokens'
        line: 'ServerTokens Prod'
      notify:
        - restart web service
        - validate configuration

  handlers:

    - name: restart web service
      systemd:
        name: "{{ web_service }}"
        state: restarted

    - name: validate configuration
      command: httpd -t
```

---

## ▶️ Run Complex Handlers

```bash
ansible-playbook -i inventory.ini complex-handlers.yml
```

---

# 🔍 Task 7: Service Validation

## 📄 `service-validation.yml`

```yaml
---
- name: Service Validation
  hosts: webservers
  become: yes

  tasks:

    - name: Gather service facts
      service_facts:

    - name: Check Apache status
      systemd:
        name: httpd
      register: apache_status

    - name: Show Service Status
      debug:
        msg: "Apache is {{ apache_status.status.ActiveState }}"
```

---

## ▶️ Run Validation

```bash
ansible-playbook -i inventory.ini service-validation.yml
```

---

# ❤️ Task 8: Health Check and Configuration Validation

## 📄 `health-check.yml`

```yaml
---
- name: Service Health Check
  hosts: webservers
  become: yes

  tasks:

    - name: Test Apache Configuration
      command: httpd -t
      register: config_test

    - name: Display Result
      debug:
        msg: "Configuration Test Passed"
      when: config_test.rc == 0
```

---

## ▶️ Run Health Check

```bash
ansible-playbook -i inventory.ini health-check.yml
```

---

# 🛡️ Task 9: Automated Service Recovery

## 📄 `service-recovery.yml`

```yaml
---
- name: Automated Service Recovery
  hosts: webservers
  become: yes

  vars:
    web_service: httpd

  tasks:

    - name: Check service status
      systemd:
        name: "{{ web_service }}"
      register: service_status

    - name: Restart service if stopped
      systemd:
        name: "{{ web_service }}"
        state: restarted
      when: service_status.status.ActiveState != "active"
```

---

## ▶️ Run Recovery Playbook

```bash
ansible-playbook -i inventory.ini service-recovery.yml
```

---

# ✅ Task 10: Final Verification

## 📄 `final-verification.yml`

```yaml
---
- name: Final Verification
  hosts: webservers
  become: yes

  tasks:

    - name: Verify Apache Service
      systemd:
        name: httpd
      register: apache_verify

    - name: Display Verification
      debug:
        msg: "Apache status: {{ apache_verify.status.ActiveState }}"
```

---

## ▶️ Run Final Verification

```bash
ansible-playbook -i inventory.ini final-verification.yml
```

---

# 🧪 Troubleshooting Common Issues

## ❌ Service Won’t Start

```bash
systemctl status httpd
journalctl -u httpd
httpd -t
```

---

## ❌ Handlers Not Triggering

### ✔️ Solution

- Ensure task actually changes content
- Verify `notify` matches handler name exactly
- Use `--check` mode

---

## ❌ Port Connectivity Issues

```bash
netstat -tlnp | grep :80
firewall-cmd --list-all
```

---

# 📊 Best Practices

- ✅ Use handlers for efficient service restarts
- ✅ Validate configurations before restart
- ✅ Use `systemd` module instead of shell commands
- ✅ Implement health checks
- ✅ Keep playbooks idempotent
- ✅ Use variables for reusable automation

---

# 🎓 Conclusion

Congratulations! 🎉

You have successfully learned:

- ✅ Service automation using Ansible
- ✅ Managing services with `systemd`
- ✅ Using handlers effectively
- ✅ Performing health checks
- ✅ Implementing automated recovery
- ✅ Validating configurations across multiple systems

---

# 🌍 Real-World Applications

- 🌐 Web Server Automation
- 🗄️ Database Service Management
- 🔒 Security Compliance
- 📈 Infrastructure Monitoring
- 🚀 DevOps Automation
- ☁️ Enterprise Configuration Management

---

# 📚 Next Steps

- 🔐 Learn Ansible Vault
- 🏢 Explore AWX / Ansible Tower
- 📦 Automate Container Services
- 📊 Integrate Monitoring Tools
- 🧪 Practice RHCE-Level Labs

---

# 👨‍💻 Author

## Hafiz Muhammad Salman

### ☁️ Cloud & DevOps Engineer

<p align="left">
  <img src="https://img.shields.io/badge/Linux-Expert-blue?style=flat-square&logo=linux" />
  <img src="https://img.shields.io/badge/Ansible-Automation-red?style=flat-square&logo=ansible" />
  <img src="https://img.shields.io/badge/DevOps-Engineer-orange?style=flat-square&logo=devops" />
  <img src="https://img.shields.io/badge/YAML-Playbooks-yellow?style=flat-square&logo=yaml" />
</p>

---
