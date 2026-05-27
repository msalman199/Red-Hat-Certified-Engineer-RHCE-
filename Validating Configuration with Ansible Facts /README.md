# 🔍 Validating Configuration with Ansible Facts

<div align="center">

![Ansible](https://img.shields.io/badge/Ansible-Automation-red?style=for-the-badge&logo=ansible)
![Linux](https://img.shields.io/badge/Linux-RHEL%20%7C%20CentOS-black?style=for-the-badge&logo=linux)
![Validation](https://img.shields.io/badge/Configuration-Validation-success?style=for-the-badge)
![DevOps](https://img.shields.io/badge/DevOps-Infrastructure-blue?style=for-the-badge)
![Security](https://img.shields.io/badge/Security-Compliance-important?style=for-the-badge)

# 🛡️ Validate Infrastructure with Ansible Facts

</div>

---

# 📘 Overview

This lab demonstrates how to use **Ansible Facts** to validate system configurations and ensure infrastructure consistency across environments.

You will learn how to:

✅ Gather system facts  
✅ Validate configurations automatically  
✅ Detect configuration drift  
✅ Generate validation reports  
✅ Implement compliance checks  

---

# 🎯 Objectives

By the end of this lab, you will be able to:

- 🔍 Understand Ansible Facts
- ⚙️ Use the `setup` module
- 🧠 Write conditional validation logic
- 📋 Validate system configurations
- 🛡️ Troubleshoot configuration drift
- 📊 Generate validation reports

---

# 📚 Prerequisites

Before starting this lab:

- 🐧 Linux command line basics
- 📄 YAML syntax understanding
- ⚙️ Basic Ansible knowledge
- 🧠 Understanding of conditions
- 🖥️ System administration concepts

---

# ☁️ Lab Environment Setup

## 🖥️ Environment Includes

| Component | Description |
|---|---|
| 🎛️ Control Node | CentOS/RHEL 8 |
| 🖧 Managed Nodes | 2–3 target systems |
| 🔐 SSH Access | Pre-configured |

# 🚀 Task 1 — Understanding Ansible Facts

---

# 🔹 Create Working Directory

```bash
cd /home/student/ansible-labs

mkdir lab16-facts-validation

cd lab16-facts-validation
```

---

# 📄 Create Inventory File

## `inventory`

```ini
[webservers]
node1 ansible_host=192.168.1.10
node2 ansible_host=192.168.1.11

[databases]
node3 ansible_host=192.168.1.12

[all:vars]
ansible_user=student
ansible_ssh_private_key_file=/home/student/.ssh/id_rsa
```

---

# 🔍 Test Connectivity

```bash
ansible all -i inventory -m ping
```

---

# ⚙️ Gather Facts from Node

```bash
ansible node1 -i inventory -m setup
```

---

# 🔹 Filter Specific Facts

## 🌐 Network Facts

```bash
ansible node1 -i inventory -m setup \
-a "filter=ansible_default_ipv4"
```

---

## 🧠 Memory Facts

```bash
ansible node1 -i inventory -m setup \
-a "filter=ansible_memory_mb"
```

---

## 🖥️ OS Information

```bash
ansible node1 -i inventory -m setup \
-a "filter=ansible_distribution*"
```

---

# 📄 Gather Facts Playbook

## `gather-facts.yml`

```yaml
---
- name: Comprehensive Fact Gathering
  hosts: all
  gather_facts: yes

  tasks:

    - name: Show hostname and IP
      debug:
        msg: "Host {{ ansible_hostname }} has IP {{ ansible_default_ipv4.address }}"

    - name: Show OS details
      debug:
        msg: "Running {{ ansible_distribution }} {{ ansible_distribution_version }}"

    - name: Display memory information
      debug:
        msg: "Total RAM: {{ ansible_memory_mb.real.total }}MB"

    - name: Save facts to file
      copy:
        content: "{{ ansible_facts | to_nice_json }}"
        dest: "/tmp/{{ ansible_hostname }}_facts.json"
```

---

# ▶️ Run Fact Gathering

```bash
ansible-playbook -i inventory gather-facts.yml
```

---

# ⚡ Task 2 — Configuration Validation

---

# 📄 Basic Validation Playbook

## `basic-validation.yml`

```yaml
---
- name: Basic System Validation
  hosts: all
  gather_facts: yes

  tasks:

    - name: Validate memory
      assert:
        that:
          - ansible_memory_mb.real.total >= 1024
        fail_msg: "Insufficient memory"
        success_msg: "Memory requirement satisfied"

    - name: Validate operating system
      assert:
        that:
          - ansible_distribution in ['CentOS', 'RedHat', 'Ubuntu', 'Debian']

    - name: Validate architecture
      assert:
        that:
          - ansible_architecture == "x86_64"

    - name: Validate network configuration
      assert:
        that:
          - ansible_default_ipv4.address is defined
```

---

# ▶️ Run Validation

```bash
ansible-playbook -i inventory basic-validation.yml
```

---

# 🚀 Advanced Validation

## `advanced-validation.yml`

```yaml
---
- name: Advanced Validation
  hosts: all
  gather_facts: yes

  vars:
    required_packages:
      - httpd
      - firewalld

  tasks:

    - name: Gather package facts
      package_facts:
        manager: auto

    - name: Validate packages
      assert:
        that:
          - item in ansible_facts.packages
      loop: "{{ required_packages }}"
```

---

# ▶️ Execute Advanced Validation

```bash
ansible-playbook -i inventory advanced-validation.yml
```

---

# 🌐 Task 3 — Web Server Validation

---

# 📄 Web Server Validation Playbook

## `webserver-validation.yml`

```yaml
---
- name: Web Server Validation
  hosts: webservers
  become: yes
  gather_facts: yes

  vars:
    web_packages:
      - httpd
      - mod_ssl

  tasks:

    - name: Install packages
      package:
        name: "{{ web_packages }}"
        state: present

    - name: Start Apache
      service:
        name: httpd
        state: started
        enabled: yes

    - name: Validate Apache service
      service_facts:

    - name: Check Apache state
      assert:
        that:
          - ansible_facts.services['httpd.service'].state == 'running'
```

---

# ▶️ Run Web Validation

```bash
ansible-playbook -i inventory webserver-validation.yml
```

---

# 🗄️ Task 4 — Database Validation

---

# 📄 Database Validation Playbook

## `database-validation.yml`

```yaml
---
- name: Database Validation
  hosts: databases
  become: yes
  gather_facts: yes

  vars:
    db_packages:
      - mariadb-server
      - mariadb

  tasks:

    - name: Install DB packages
      package:
        name: "{{ db_packages }}"
        state: present

    - name: Start DB service
      service:
        name: mariadb
        state: started
        enabled: yes

    - name: Validate DB service
      service_facts:

    - name: Assert MariaDB is running
      assert:
        that:
          - ansible_facts.services['mariadb.service'].state == 'running'
```

---

# ▶️ Run Database Validation

```bash
ansible-playbook -i inventory database-validation.yml
```

---

# 🛡️ Task 5 — Comprehensive Validation

---

# 📄 Comprehensive Validation Playbook

## `comprehensive-validation.yml`

```yaml
---
- name: Comprehensive System Validation
  hosts: all
  gather_facts: yes
  become: yes

  tasks:

    - name: Gather system facts
      setup:

    - name: Gather package facts
      package_facts:
        manager: auto

    - name: Gather service facts
      service_facts:

    - name: Validate firewall service
      assert:
        that:
          - "'firewalld.service' in ansible_facts.services"

    - name: Check SELinux status
      command: getenforce
      register: selinux_status
      changed_when: false

    - name: Validate SELinux
      assert:
        that:
          - selinux_status.stdout == "Enforcing"
```

---

# 📄 Validation Report Template

## `templates/validation_report.j2`

```jinja
SYSTEM VALIDATION REPORT
========================

Hostname: {{ ansible_hostname }}
IP Address: {{ ansible_default_ipv4.address }}

OS: {{ ansible_distribution }}
Kernel: {{ ansible_kernel }}

Memory: {{ ansible_memory_mb.real.total }}MB

Services Running:
{% for svc in ansible_facts.services %}
- {{ svc }}
{% endfor %}
```

---

# ▶️ Run Comprehensive Validation

```bash
ansible-playbook -i inventory comprehensive-validation.yml
```

---

# 📥 Fetch Reports

```bash
ansible all -i inventory -m fetch \
-a "src=/tmp/validation_reports/{{ ansible_hostname }}_validation_report.txt dest=./reports/ flat=yes"
```

---

# 🔍 View Reports

```bash
ls -la reports/
```

```bash
cat reports/*_validation_report.txt
```

---

# 🐞 Debugging Facts

---

# 📄 Debug Playbook

## `debug-facts.yml`

```yaml
---
- hosts: all
  gather_facts: yes

  tasks:

    - debug:
        var: ansible_memory_mb

    - debug:
        var: ansible_distribution

    - debug:
        var: ansible_default_ipv4
```

---

# ▶️ Run Debug Playbook

```bash
ansible-playbook -i inventory debug-facts.yml
```

---

# ⚠️ Troubleshooting

---

# ❌ Facts Not Gathering

## ✅ Solution

```bash
ansible all -i inventory -m ping
```

```bash
ansible all -i inventory -m setup -v
```

---

# ❌ Assertion Failures

## ✅ Debug Facts

```bash
ansible node1 -i inventory -m setup \
-a "filter=ansible_memory_mb"
```

---

# ❌ Service Facts Missing

## ✅ Verify systemctl

```bash
ansible all -i inventory -m command \
-a "systemctl --version"
```

---

# 🏆 Best Practices

| ✅ Practice | 💡 Description |
|---|---|
| Use Fact Caching | Improve performance |
| Create Custom Facts | Application-specific validation |
| Use Templates | Reusable reports |
| Use Assertions | Automated compliance checks |
| Generate Reports | Audit and documentation |

---

# ⚡ Enable Fact Caching

## `ansible.cfg`

```ini
[defaults]
fact_caching = jsonfile
fact_caching_connection = /tmp/ansible_facts_cache
fact_caching_timeout = 3600
```

---

# 🔧 Custom Facts Example

```bash
sudo mkdir -p /etc/ansible/facts.d
```

```bash
sudo cat > /etc/ansible/facts.d/application.fact << EOF
#!/bin/bash
echo '{"app_version":"2.1.0","config_valid":true}'
EOF
```

---

# 🎉 Conclusion

In this lab you learned:

✅ How to gather Ansible Facts  
✅ Validate configurations automatically  
✅ Build advanced validation playbooks  
✅ Detect configuration drift  
✅ Generate compliance reports  

---

# 🚀 Why Configuration Validation Matters

## 🛡️ Security Compliance

Ensure systems meet security standards.

## 🔄 Prevent Configuration Drift

Maintain consistent infrastructure.

## ⚙️ Infrastructure Automation

Automate validation across environments.

## 📊 Audit Readiness

Generate detailed validation reports.

---

# 🎓 Career Benefits

These skills are essential for:

- RHCE Certification
- DevOps Engineering
- Infrastructure Automation
- Cloud Operations
- Enterprise Compliance

---

# 📈 Next Steps

✅ Build reusable validation roles  
✅ Create custom Ansible facts  
✅ Integrate validation into CI/CD  
✅ Automate enterprise compliance checks  

---

<div align="center">

# ⭐ Infrastructure Validation with Ansible Facts ⭐

![Ansible](https://img.shields.io/badge/Ansible-Automation-red?style=for-the-badge&logo=ansible)
![Validation](https://img.shields.io/badge/Validation-System%20Checks-success?style=for-the-badge)
![DevOps](https://img.shields.io/badge/DevOps-Engineer-blue?style=for-the-badge)

</div>
