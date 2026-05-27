# 🚀 Writing and Debugging Ansible Playbooks

<p align="center">
  <img src="https://img.shields.io/badge/Automation-Ansible-red?style=for-the-badge&logo=ansible">
  <img src="https://img.shields.io/badge/Linux-RHEL%208-blue?style=for-the-badge&logo=redhat">
  <img src="https://img.shields.io/badge/YAML-Playbooks-yellow?style=for-the-badge&logo=yaml">
  <img src="https://img.shields.io/badge/Debugging-Troubleshooting-orange?style=for-the-badge&logo=bugatti">
  <img src="https://img.shields.io/badge/DevOps-Infrastructure-green?style=for-the-badge&logo=linux">
  <img src="https://img.shields.io/badge/RHCE-Preparation-black?style=for-the-badge&logo=redhat">
</p>

---

# 📘 Overview

This lab focuses on **writing, executing, and debugging Ansible playbooks** using YAML syntax and Ansible automation modules.

You will learn how to:

- Create structured playbooks
- Configure services and packages
- Validate playbooks using syntax checks
- Debug issues using verbosity and check mode
- Handle errors gracefully
- Apply best practices for enterprise automation

This lab provides essential skills for **DevOps engineers** and **RHCE certification preparation**.

---

# 🎯 Objectives

By the end of this lab, you will be able to:

✅ Write structured Ansible playbooks using YAML  
✅ Execute playbooks with `ansible-playbook`  
✅ Debug playbooks using check mode and verbosity  
✅ Configure packages and services automatically  
✅ Troubleshoot syntax and module errors  
✅ Apply best practices for playbook structure  

---

# 🧰 Prerequisites

Before starting this lab, ensure you have:

- Basic Linux command-line knowledge
- Familiarity with YAML syntax
- Basic Ansible fundamentals
- Understanding of package managers
- Knowledge of Linux services and configuration

---

# ☁️ Lab Environment

## 🖥️ Environment Includes

| Component | Description |
|----------|-------------|
| 🎛️ Control Node | Ansible Pre-installed |
| 🌐 Managed Nodes | 2 Linux target servers |
| 🔐 SSH Access | Pre-configured |
| ✏️ Editors | nano & vim |

---

# 📂 Task 1 — Create an Ansible Playbook

# 🔹 Subtask 1.1 — Create Project Directory

## 📁 Create Lab Directory

```bash
mkdir -p ~/ansible-lab2
cd ~/ansible-lab2
```

---

# 🔹 Create Inventory File

## 📄 Inventory Configuration

```bash
cat > inventory << EOF
[webservers]
node1 ansible_host=192.168.1.10
node2 ansible_host=192.168.1.11

[all:vars]
ansible_user=ansible
ansible_ssh_private_key_file=~/.ssh/id_rsa
EOF
```

---

# 🔹 Verify Connectivity

## 🔗 Ping Managed Nodes

```bash
ansible all -i inventory -m ping
```

### ✅ Expected Output

```bash
node1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

---

# 🔹 Subtask 1.2 — Create First Playbook

## 📄 Create Webserver Playbook

```bash
nano webserver-setup.yml
```

## ✨ Add Playbook Content

```yaml
---
- name: Install and Configure Apache Web Server
  hosts: webservers
  become: yes

  vars:
    package_name: httpd
    service_name: httpd
    document_root: /var/www/html

  tasks:

    - name: Install Apache package
      yum:
        name: "{{ package_name }}"
        state: present
      tags: install

    - name: Start Apache service
      systemd:
        name: "{{ service_name }}"
        state: started
        enabled: yes
      tags: service

    - name: Create custom index page
      copy:
        content: |
          <html>
          <body>
            <h1>Welcome to {{ inventory_hostname }}</h1>
          </body>
          </html>
        dest: "{{ document_root }}/index.html"
      tags: content

    - name: Configure firewall
      firewalld:
        service: http
        permanent: yes
        state: enabled
        immediate: yes
      tags: firewall
```

---

# 🔹 Subtask 1.3 — Advanced Configuration Playbook

## 📄 Create Advanced Playbook

```bash
nano advanced-config.yml
```

## ⚙️ Add Advanced Configuration

```yaml
---
- name: Advanced Apache Configuration
  hosts: webservers
  become: yes

  vars:
    apache_port: 8080

  tasks:

    - name: Create custom configuration
      copy:
        content: |
          Listen {{ apache_port }}
        dest: /etc/httpd/conf.d/custom.conf
      notify: restart apache

    - name: Install extra packages
      yum:
        name:
          - mod_ssl
          - httpd-tools
        state: present

  handlers:

    - name: restart apache
      systemd:
        name: httpd
        state: restarted
```

---

# 🚀 Task 2 — Execute Playbooks

# 🔹 Subtask 2.1 — Run Basic Playbook

## ▶️ Execute Playbook

```bash
ansible-playbook -i inventory webserver-setup.yml
```

---

# 🔹 Demonstrate Idempotency

## 🔁 Run Again

```bash
ansible-playbook -i inventory webserver-setup.yml
```

### 📌 Observe

- `changed` on first run
- `ok` on second run

This demonstrates **Ansible idempotency**.

---

# 🔹 Subtask 2.2 — Run Specific Tags

## 📦 Run Install Tasks Only

```bash
ansible-playbook -i inventory webserver-setup.yml --tags "install"
```

## ⚙️ Run Multiple Tags

```bash
ansible-playbook -i inventory webserver-setup.yml --tags "service,content"
```

## ⏭️ Skip Firewall Tasks

```bash
ansible-playbook -i inventory webserver-setup.yml --skip-tags "firewall"
```

---

# 🔹 Subtask 2.3 — Use Verbosity Levels

## 🔍 Increased Verbosity

```bash
ansible-playbook -i inventory webserver-setup.yml -v
```

## 🧠 Maximum Debugging Output

```bash
ansible-playbook -i inventory webserver-setup.yml -vvv
```

## 🚀 Run Advanced Playbook

```bash
ansible-playbook -i inventory advanced-config.yml -v
```

---

# 🛡️ Task 3 — Debug Playbooks

# 🔹 Subtask 3.1 — Use Check Mode

## 🧪 Dry Run

```bash
ansible-playbook -i inventory webserver-setup.yml --check
```

## 🔍 Dry Run with Verbose Output

```bash
ansible-playbook -i inventory webserver-setup.yml --check -v
```

---

# 🔹 Subtask 3.2 — Create Problematic Playbook

## 📄 Create Broken Playbook

```bash
nano debug-practice.yml
```

## ❌ Add Intentional Errors

```yaml
---
- name: Debugging Practice
  hosts: webservers

  tasks:

  - name: Wrong indentation
    yum:
      name: htop
      state: present

    - name: Missing path parameter
      file:
        state: directory
```

---

# 🔹 Subtask 3.3 — Debug Errors

## 🧪 Run in Check Mode

```bash
ansible-playbook -i inventory debug-practice.yml --check
```

### 🚨 Common Errors

| Error Type | Cause |
|------------|-------|
| YAML Errors | Wrong indentation |
| Module Errors | Invalid parameters |
| Template Errors | Broken variables |
| Missing Values | Required fields absent |

---

# 🔹 Create Fixed Playbook

## 📄 Corrected Version

```bash
nano debug-practice-fixed.yml
```

## ✅ Fixed YAML

```yaml
---
- name: Fixed Debugging Playbook
  hosts: webservers
  become: yes

  tasks:

    - name: Install package
      yum:
        name: htop
        state: present

    - name: Create directory
      file:
        path: /tmp/ansible-test
        state: directory
        mode: '0755'
```

---

# 🔹 Test Fixed Playbook

## ✅ Run Dry Run

```bash
ansible-playbook -i inventory debug-practice-fixed.yml --check
```

---

# 🔹 Subtask 3.4 — Variable Debugging

## 📄 Create Variable Debugging Playbook

```bash
nano variable-debug.yml
```

## 🧠 Add Debug Tasks

```yaml
---
- name: Variable Debugging
  hosts: webservers
  gather_facts: yes

  vars:
    custom_message: "Hello from Ansible"

  tasks:

    - name: Debug variable
      debug:
        msg: "{{ custom_message }}"

    - name: Debug hostname
      debug:
        var: ansible_hostname

    - name: Debug OS info
      debug:
        var: ansible_distribution
```

---

# 🔹 Execute Variable Debugging

## ▶️ Run Playbook

```bash
ansible-playbook -i inventory variable-debug.yml
```

---

# 🔹 Subtask 3.5 — Syntax Validation

## ✅ Validate Syntax

```bash
ansible-playbook -i inventory webserver-setup.yml --syntax-check
```

## ❌ Validate Broken Playbook

```bash
ansible-playbook -i inventory debug-practice.yml --syntax-check
```

## ✅ Validate Fixed Playbook

```bash
ansible-playbook -i inventory debug-practice-fixed.yml --syntax-check
```

---

# 🚨 Advanced Debugging & Error Handling

# 🔹 Error Handling Playbook

## 📄 Create Error Handling Example

```bash
nano error-handling.yml
```

## ⚙️ Add Error Handling Logic

```yaml
---
- name: Error Handling Example
  hosts: webservers

  tasks:

    - name: Task that may fail
      command: /bin/false
      ignore_errors: yes
      register: result

    - name: Display result
      debug:
        var: result
```

---

# 🔹 Block & Rescue Example

## 🛡️ Advanced Error Handling

```yaml
tasks:

  - name: Install package with rescue
    block:

      - name: Install invalid package
        yum:
          name: invalid-package
          state: present

    rescue:

      - name: Install alternative package
        yum:
          name: htop
          state: present

    always:

      - name: Always run cleanup
        debug:
          msg: "Cleanup completed"
```

---

# ⚡ Performance Optimization

# 🔹 Parallel Execution

## 📄 Create Performance Demo

```bash
nano performance-demo.yml
```

## 🚀 Add Performance Features

```yaml
---
- name: Performance Optimization
  hosts: webservers
  strategy: free

  tasks:

    - name: Install packages
      yum:
        name:
          - git
          - wget
          - unzip
        state: present
```

---

# 🔹 Run with Timing

## ⏱️ Measure Performance

```bash
time ansible-playbook -i inventory performance-demo.yml
```

---

# 🚨 Common Troubleshooting Issues

# 🔹 YAML Syntax Errors

## ❌ Problem

- Incorrect indentation
- Using tabs instead of spaces

## ✅ Solution

- Use consistent spacing
- Validate using syntax check

```bash
ansible-playbook playbook.yml --syntax-check
```

---

# 🔹 Module Parameter Errors

## ❌ Problem

- Invalid module options

## ✅ Solution

```bash
ansible-doc yum
```

---

# 🔹 SSH Connection Issues

## 🔗 Test Connectivity

```bash
ansible all -i inventory -m ping
```

---

# 🔹 Permission Errors

## 🛡️ Use become

```yaml
become: yes
```

## 🔍 Debug with Verbosity

```bash
ansible-playbook playbook.yml -vvv
```

---

# ✅ Verification Commands

# 🔹 Check Apache Service

```bash
ansible webservers -i inventory -m command -a "systemctl status httpd" --become
```

---

# 🔹 Verify Web Content

```bash
ansible webservers -i inventory -m uri -a "url=http://{{ inventory_hostname }} method=GET"
```

---

# 🔹 List Installed Packages

```bash
ansible webservers -i inventory -m command -a "rpm -qa | grep httpd" --become
```

---

# 🏆 Skills Gained

✔️ Writing Ansible Playbooks  
✔️ YAML Syntax Mastery  
✔️ Service Automation  
✔️ Debugging Techniques  
✔️ Error Handling  
✔️ Check Mode Validation  
✔️ Performance Optimization  
✔️ RHCE-Level Troubleshooting  

---

# 📂 Project Structure

```bash
ansible-lab2/
├── inventory
├── webserver-setup.yml
├── advanced-config.yml
├── debug-practice.yml
├── debug-practice-fixed.yml
├── variable-debug.yml
├── error-handling.yml
└── performance-demo.yml
```

---

# 🌟 Best Practices

✅ Use `--check` before production deployment  
✅ Validate syntax frequently  
✅ Use tags for modular execution  
✅ Implement proper error handling  
✅ Keep playbooks idempotent  
✅ Use verbosity for troubleshooting  

---

# 🚀 Why This Matters

Ansible playbooks are the foundation of:

- Infrastructure Automation
- Configuration Management
- Application Deployment
- DevOps Pipelines
- Enterprise Linux Administration

These skills are essential for **RHCE certification** and real-world DevOps engineering.

# ⭐ Support

If you found this project useful:

🌟 Star the repository  
🍴 Fork the project  
📘 Share with DevOps learners  
🚀 Practice automation daily  



This project is for educational and learning purposes.

---
