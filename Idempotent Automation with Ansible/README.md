# 🚀 Idempotent Automation with Ansible

<div align="center">

![Ansible](https://img.shields.io/badge/Ansible-Automation-red?style=for-the-badge&logo=ansible)
![Linux](https://img.shields.io/badge/Linux-RHEL%20%7C%20CentOS-black?style=for-the-badge&logo=linux)
![YAML](https://img.shields.io/badge/YAML-Configuration-orange?style=for-the-badge&logo=yaml)
![Automation](https://img.shields.io/badge/Infrastructure-Automation-blue?style=for-the-badge)
![DevOps](https://img.shields.io/badge/DevOps-Engineering-green?style=for-the-badge)
![RHCE](https://img.shields.io/badge/RHCE-Ready-important?style=for-the-badge)

</div>

---

# 📘 Overview

This lab demonstrates how to build **idempotent automation** using Ansible.  
Idempotency ensures that running the same automation multiple times always results in the same system state without unwanted changes.

---

# 🎯 Objectives

By the end of this lab, students will be able to:

✅ Understand the concept of idempotency in automation  
✅ Modify Ansible playbooks for idempotent behavior  
✅ Implement handlers and conditional statements  
✅ Test playbook idempotency by repeated execution  
✅ Use Ansible modules that support idempotency naturally  
✅ Troubleshoot common idempotency issues  

---

# 📚 Prerequisites

Before starting this lab, students should have:

- 🐧 Basic Linux command line knowledge
- 📄 YAML syntax understanding
- ⚙️ Basic Ansible experience
- 🔐 SSH key authentication knowledge
- 🖥️ Basic system administration concepts

---

# ☁️ Lab Environment Setup

## 🖥️ Ready-to-Use Cloud Machines

Your environment includes:

| Component | Description |
|---|---|
| 🎛️ Control Node | CentOS/RHEL 8 with Ansible installed |
| 🖧 Managed Nodes | node1 and node2 |
| 🔑 SSH Keys | Pre-configured passwordless authentication |
| 📂 Sample Files | Configurations and directories included |

---

# 🧪 Task 1 — Understanding Idempotency

---

## 🔹 Subtask 1.1 — Connect to Lab Environment

### Check Ansible Version

```bash
ansible --version
```

### Check Inventory

```bash
cat /etc/ansible/hosts
```

### Test Connectivity

```bash
ansible all -m ping
```

---

## 🔹 Subtask 1.2 — Create Non-Idempotent Playbook

### Create Working Directory

```bash
mkdir ~/ansible-idempotency-lab
cd ~/ansible-idempotency-lab
```

### Create Playbook

```bash
nano non-idempotent-playbook.yml
```

### Add Content

```yaml
---
- name: Non-Idempotent Configuration Example
  hosts: all
  become: yes

  tasks:
    - name: Add line to hosts file
      shell: echo "192.168.1.100 custom-server" >> /etc/hosts

    - name: Create user
      shell: useradd -m testuser

    - name: Install wget
      shell: yum install -y wget

    - name: Start Apache
      shell: systemctl start httpd
```

### Run Playbook

```bash
ansible-playbook non-idempotent-playbook.yml
```

### Run Again

```bash
ansible-playbook non-idempotent-playbook.yml
```

---

## ⚠️ Problems with Non-Idempotent Automation

❌ Duplicate entries  
❌ User creation errors  
❌ Unnecessary changes  
❌ Unpredictable server state  

---

# 🛠️ Task 2 — Converting to Idempotent Operations

---

## 🔹 Subtask 2.1 — Create Idempotent Playbook

```bash
nano idempotent-playbook.yml
```

```yaml
---
- name: Idempotent Configuration Example
  hosts: all
  become: yes

  tasks:
    - name: Ensure hosts entry exists
      lineinfile:
        path: /etc/hosts
        line: "192.168.1.100 custom-server"
        state: present
        backup: yes

    - name: Ensure testuser exists
      user:
        name: testuser
        state: present
        create_home: yes
        shell: /bin/bash

    - name: Ensure wget installed
      package:
        name: wget
        state: present

    - name: Ensure httpd installed
      package:
        name: httpd
        state: present

    - name: Ensure httpd running
      service:
        name: httpd
        state: started
        enabled: yes
```

---

## 🔹 Subtask 2.2 — Cleanup Previous Changes

```bash
ansible all -m shell -a "userdel -r testuser" --ignore-errors

ansible all -m shell -a "sed -i '/custom-server/d' /etc/hosts"

ansible all -m package -a "name=httpd state=absent" --become
```

---

## ▶️ Run Playbook

```bash
ansible-playbook idempotent-playbook.yml
```

### Run Again

```bash
ansible-playbook idempotent-playbook.yml
```

✅ Second run should show mostly `ok` instead of `changed`

---

# 🔍 Verify Idempotency

### Check Duplicate Entries

```bash
ansible all -m shell -a "grep -c custom-server /etc/hosts"
```

### Verify User

```bash
ansible all -m shell -a "id testuser"
```

### Verify Service

```bash
ansible all -m shell -a "systemctl is-active httpd"
```

---

# ⚡ Task 3 — Advanced Idempotency

---

## 🔹 Advanced Playbook

```bash
nano advanced-idempotent-playbook.yml
```

```yaml
---
- name: Advanced Idempotent Web Server Configuration
  hosts: all
  become: yes

  vars:
    web_port: 8080
    document_root: /var/www/html

  tasks:

    - name: Ensure httpd installed
      package:
        name: httpd
        state: present
      notify: restart httpd

    - name: Ensure directory exists
      file:
        path: "{{ document_root }}/custom"
        state: directory
        owner: apache
        group: apache
        mode: '0755'

    - name: Deploy configuration
      template:
        src: httpd-custom.conf.j2
        dest: /etc/httpd/conf.d/custom.conf
      notify: restart httpd

    - name: Deploy index page
      copy:
        content: |
          <html>
          <body>
          <h1>Idempotent Configuration</h1>
          </body>
          </html>
        dest: "{{ document_root }}/index.html"

    - name: Ensure firewall configured
      firewalld:
        service: http
        permanent: yes
        state: enabled
        immediate: yes

    - name: Ensure service running
      service:
        name: httpd
        state: started
        enabled: yes

  handlers:
    - name: restart httpd
      service:
        name: httpd
        state: restarted
```

---

# 📂 Template File

```bash
mkdir templates
nano templates/httpd-custom.conf.j2
```

```jinja
Listen {{ web_port }}

<VirtualHost *:{{ web_port }}>
    DocumentRoot {{ document_root }}
</VirtualHost>
```

---

# 🚦 Test Advanced Idempotency

```bash
ansible-playbook advanced-idempotent-playbook.yml
```

### Run Again

```bash
ansible-playbook advanced-idempotent-playbook.yml
```

✅ Handlers should not trigger on second run

---

# 🔄 Task 4 — Conditional Idempotency

---

## 📄 Conditional Playbook

```yaml
---
- name: Conditional Idempotent Operations
  hosts: all
  become: yes

  tasks:

    - name: Check config existence
      stat:
        path: /etc/custom-app.conf
      register: custom_config

    - name: Create config if missing
      copy:
        content: |
          app_name=MyApp
          version=1.0
        dest: /etc/custom-app.conf
      when: not custom_config.stat.exists

    - name: Ensure config line exists
      lineinfile:
        path: /etc/custom-app.conf
        regexp: '^log_level='
        line: 'log_level=info'
```

---

# 🧪 Task 5 — Validation Script

---

## 📜 Create Validation Script

```bash
nano validate-idempotency.sh
```

```bash
#!/bin/bash

echo "=== Idempotency Validation ==="

PLAYBOOK=$1

ansible-playbook $PLAYBOOK > run1.log
ansible-playbook $PLAYBOOK > run2.log

CHANGED=$(grep -c "changed:" run2.log)

if [ $CHANGED -eq 0 ]; then
    echo "✅ IDEMPOTENT"
else
    echo "❌ NOT IDEMPOTENT"
fi
```

---

## 🔓 Make Executable

```bash
chmod +x validate-idempotency.sh
```

---

## ▶️ Run Validation

```bash
./validate-idempotency.sh idempotent-playbook.yml
```

---

# 🏆 Idempotency Best Practices

| ✅ Best Practice | 💡 Description |
|---|---|
| Use native modules | Avoid shell commands |
| Use `lineinfile` | Prevent duplicate lines |
| Use handlers | Restart services only when needed |
| Use conditions | Prevent unnecessary execution |
| Use templates | Dynamic configuration management |
| Use `creates` | Avoid repeated extraction |
| Use `changed_when` | Control change reporting |

---

# ⚠️ Common Idempotency Problems

---

## ❌ Wrong File Permission Format

```yaml
mode: 0644
```

✅ Correct

```yaml
mode: '0644'
```

---

## ❌ Non-Idempotent Shell Command

```yaml
shell: echo "config=value" >> /etc/app.conf
```

✅ Correct

```yaml
lineinfile:
  path: /etc/app.conf
  line: "config=value"
```

---

# 🎉 Conclusion

In this lab you learned:

✅ Idempotent automation concepts  
✅ Reliable Ansible playbook design  
✅ Proper use of handlers and conditions  
✅ Validation and testing strategies  
✅ Industry-standard automation practices  

---

# 🚀 Why Idempotency Matters

## 👨‍💻 For System Administrators

- Reliable infrastructure
- Consistent server state
- Reduced operational errors

## ⚙️ For DevOps Engineers

- Stable CI/CD pipelines
- Safe production deployments
- Better Infrastructure as Code

## 🎓 For Career Growth

These skills are essential for:

- RHCE Certification
- DevOps Engineering
- Automation Engineering
- Cloud Infrastructure Roles

---

# 📈 Next Steps

✅ Practice more Ansible automation  
✅ Explore Ansible Galaxy roles  
✅ Learn custom modules and plugins  
✅ Build enterprise automation projects  

---

# 💡 Final Note

Idempotency is the foundation of professional automation.  
Mastering it ensures your infrastructure remains:

✅ Predictable  
✅ Reliable  
✅ Repeatable  
✅ Scalable  

---

<div align="center">

# ⭐ Happy Automating with Ansible ⭐

![Automation](https://img.shields.io/badge/Automation-Professional-success?style=for-the-badge)
![DevOps](https://img.shields.io/badge/DevOps-Engineer-blue?style=for-the-badge)
![Ansible](https://img.shields.io/badge/Ansible-Expert-red?style=for-the-badge)

</div>
