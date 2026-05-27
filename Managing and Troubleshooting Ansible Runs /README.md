# 🚀 Managing and Troubleshooting Ansible Runs

<p align="center">
  <img src="https://img.shields.io/badge/Automation-Ansible-red?style=for-the-badge&logo=ansible" />
  <img src="https://img.shields.io/badge/Linux-RHEL%20%7C%20CentOS-blue?style=for-the-badge&logo=linux" />
  <img src="https://img.shields.io/badge/Debugging-Troubleshooting-orange?style=for-the-badge&logo=bugatti" />
  <img src="https://img.shields.io/badge/DevOps-Automation-green?style=for-the-badge&logo=devops" />
  <img src="https://img.shields.io/badge/YAML-Playbooks-yellow?style=for-the-badge&logo=yaml" />
</p>

---

# 📘 Lab: Managing and Troubleshooting Ansible Runs

---

# 🎯 Objectives

By the end of this lab, you will be able to:

- ✅ Use `ansible-console` interactively
- ✅ Diagnose failed Ansible playbook runs
- ✅ Analyze logs and error messages
- ✅ Use `ansible-playbook --check`
- ✅ Apply troubleshooting methodologies
- ✅ Debug Ansible configurations effectively

---

# 🧰 Prerequisites

Before starting this lab, you should have:

- 🐧 Basic Linux command line knowledge
- ⚙️ Understanding of Ansible playbooks and inventory
- 📄 YAML syntax familiarity
- 🔐 SSH key-based authentication knowledge
- 🤖 Experience running Ansible commands

---

# ☁️ Lab Environment

## ✅ Environment Includes

- 🖥️ Control Node (CentOS/RHEL 8)
- 🖥️ Managed Nodes (node1 & node2)
- 🔗 Pre-configured SSH Keys
- 📦 Ansible Installed

---

# 📂 Recommended File Structure

```bash
ansible-troubleshooting/
├── broken-playbook.yml
├── tagged-playbook.yml
├── check-mode-demo.yml
├── check-mode-advanced.yml
├── connection-test.yml
├── variable-issues.yml
├── troubleshoot-ansible.sh
├── ansible.cfg
├── check-output.txt
├── normal-output.txt
└── README.md
```

---

# 🛠️ Task 1: Using ansible-console

---

# 🔹 Verify Ansible Installation

```bash
ansible --version
```

---

# 🔹 Check Inventory File

```bash
cat /etc/ansible/hosts
```

### Example Output

```ini
[webservers]
node1 ansible_host=192.168.1.10
node2 ansible_host=192.168.1.11

[all:vars]
ansible_user=ansible
ansible_ssh_private_key_file=/home/ansible/.ssh/id_rsa
```

---

# 🔹 Launch ansible-console

```bash
ansible-console all
```

Expected Prompt:

```bash
Welcome to the ansible console.
Type help or ? to list commands.

ansible@all (2)[f:5]$
```

---

# 🔹 Basic ansible-console Commands

## ✅ Test Connectivity

```bash
ping
```

---

## ✅ Gather Facts

```bash
setup
```

---

## ✅ Check Disk Usage

```bash
shell df -h
```

---

## ✅ List Processes

```bash
shell ps aux | head -10
```

---

## ✅ Target Specific Hosts

```bash
cd webservers
```

---

## ✅ Install Package

```bash
yum name=htop state=present
```

---

## ✅ Exit Console

```bash
exit
```

---

# 🔹 Advanced ansible-console Operations

## Launch with Become

```bash
ansible-console -i /etc/ansible/hosts --become all
```

---

## Use Variables

```bash
shell echo "Current user: {{ ansible_user }}"
```

---

## Privilege Escalation

```bash
become_user=root shell whoami
```

---

## Check Service Status

```bash
systemd name=sshd state=started
```

---

# 🧪 Task 2: Troubleshooting Failed Playbooks

---

# 🔹 Create Working Directory

```bash
mkdir -p ~/ansible-troubleshooting
cd ~/ansible-troubleshooting
```

---

# 📄 Create Problematic Playbook

## `broken-playbook.yml`

```yaml
---
- name: Problematic Web Server Setup
  hosts: webservers
  become: yes

  vars:
    web_package: httpd
    web_service: httpd
    document_root: /var/www/html

  tasks:

    - name: Install web server
      yum:
        name: "{{ web_package }}"
        state: present

    - name: Start and enable web service
      systemd:
        name: "{{ wrong_service_name }}"
        state: started
        enabled: yes

    - name: Create index.html
      copy:
        content: "<h1>Welcome to {{ ansible_hostname }}</h1>"
        dest: "{{ document_root }}/index.html"
        owner: apache
        group: apache
        mode: '0644'
```

---

# ▶️ Run Playbook with Verbose Output

```bash
ansible-playbook -i /etc/ansible/hosts broken-playbook.yml -v
```

---

# ▶️ Run with Maximum Verbosity

```bash
ansible-playbook -i /etc/ansible/hosts broken-playbook.yml -vvv
```

---

# 🔹 Fix Undefined Variable

```bash
sed -i 's/wrong_service_name/web_service/g' broken-playbook.yml
```

---

# ▶️ Run Again

```bash
ansible-playbook -i /etc/ansible/hosts broken-playbook.yml -v
```

---

# 🔹 Comment Problematic Tasks

```bash
sed -i '/Copy configuration file/,/notify: restart web service/s/^/# /' broken-playbook.yml
```

---

# 🔹 Execute Step-by-Step

```bash
ansible-playbook -i /etc/ansible/hosts broken-playbook.yml --step
```

---

# 🔹 Start at Specific Task

```bash
ansible-playbook -i /etc/ansible/hosts broken-playbook.yml --start-at-task="Configure firewall"
```

---

# 🏷️ Tagged Playbook Example

## 📄 `tagged-playbook.yml`

```yaml
---
- name: Web Server Setup with Tags
  hosts: webservers
  become: yes

  tasks:

    - name: Install web server
      yum:
        name: httpd
        state: present
      tags: install

    - name: Start service
      systemd:
        name: httpd
        state: started
      tags: service
```

---

# ▶️ Run Specific Tags

```bash
ansible-playbook -i /etc/ansible/hosts tagged-playbook.yml --tags="install,service"
```

---

# 🧪 Task 3: Using Check Mode

---

# 📄 `check-mode-demo.yml`

```yaml
---
- name: System Configuration Demo
  hosts: all
  become: yes

  vars:
    packages_to_install:
      - vim
      - git
      - curl

  tasks:

    - name: Install packages
      yum:
        name: "{{ packages_to_install }}"
        state: present

    - name: Create directory
      file:
        path: /opt/myapp
        state: directory
        mode: '0755'
```

---

# ▶️ Run in Check Mode

```bash
ansible-playbook -i /etc/ansible/hosts check-mode-demo.yml --check
```

---

# ▶️ Run with Diff Output

```bash
ansible-playbook -i /etc/ansible/hosts check-mode-demo.yml --check --diff
```

---

# ▶️ Run Specific Tags

```bash
ansible-playbook -i /etc/ansible/hosts check-mode-demo.yml --check --tags="packages"
```

---

# 🔍 Compare Check Mode vs Actual Execution

```bash
ansible-playbook -i /etc/ansible/hosts check-mode-demo.yml --check > check-output.txt

ansible-playbook -i /etc/ansible/hosts check-mode-demo.yml > normal-output.txt

diff check-output.txt normal-output.txt
```

---

# 🧠 Advanced Check Mode

## 📄 `check-mode-advanced.yml`

```yaml
---
- name: Advanced Check Mode Demo
  hosts: webservers
  become: yes

  tasks:

    - name: Install Apache
      yum:
        name: httpd
        state: present
      check_mode: no

    - name: Check if Apache installed
      command: rpm -q httpd
      register: apache_check
      failed_when: false
      changed_when: false
```

---

# ▶️ Execute Advanced Check Mode

```bash
ansible-playbook -i /etc/ansible/hosts check-mode-advanced.yml --check --diff
```

---

# 🔍 Syntax Validation

## ✅ Syntax Check

```bash
ansible-playbook --syntax-check check-mode-advanced.yml
```

---

## ✅ List Tasks

```bash
ansible-playbook -i /etc/ansible/hosts check-mode-advanced.yml --list-tasks
```

---

## ✅ List Hosts

```bash
ansible-playbook -i /etc/ansible/hosts check-mode-advanced.yml --list-hosts
```

---

## ✅ List Tags

```bash
ansible-playbook -i /etc/ansible/hosts check-mode-advanced.yml --list-tags
```

---

# 🌐 Advanced Troubleshooting Scenarios

---

# 🔹 Scenario 1: Connection Issues

## 📄 `connection-test.yml`

```yaml
---
- name: Connection Troubleshooting
  hosts: all
  gather_facts: no

  tasks:

    - name: Test Connectivity
      ping:

    - name: Test Privilege Escalation
      command: whoami
      become: yes
```

---

# ▶️ Run with Debugging

```bash
ansible-playbook -i /etc/ansible/hosts connection-test.yml -vvvv
```

---

# 🔹 Scenario 2: Variable Issues

## 📄 `variable-issues.yml`

```yaml
---
- name: Variable Troubleshooting Demo
  hosts: webservers

  vars:
    app_name: myapp
    app_version: "1.0"

  tasks:

    - name: Debug Variables
      debug:
        msg: |
          App: {{ app_name }}
          Version: {{ app_version }}
          Undefined: {{ undefined_var | default('Not defined') }}
```

---

# ▶️ Run Variable Troubleshooting

```bash
ansible-playbook -i /etc/ansible/hosts variable-issues.yml -v
```

---

# 📋 Troubleshooting Checklist Script

## 📄 `troubleshoot-ansible.sh`

```bash
#!/bin/bash

echo "=== Ansible Troubleshooting Checklist ==="

echo "1. Checking Ansible version:"
ansible --version

echo "2. Checking inventory:"
ansible-inventory --list -i /etc/ansible/hosts

echo "3. Testing connectivity:"
ansible all -i /etc/ansible/hosts -m ping

echo "4. Testing SSH:"
ansible all -i /etc/ansible/hosts -m command -a "whoami"

echo "5. Testing privilege escalation:"
ansible all -i /etc/ansible/hosts -m command -a "whoami" --become

echo "=== Troubleshooting complete ==="
```

---

# 🔓 Make Script Executable

```bash
chmod +x troubleshoot-ansible.sh
```

---

# ▶️ Run Troubleshooting Script

```bash
./troubleshoot-ansible.sh
```

---

# 📄 Configure Logging

## 📄 `ansible.cfg`

```ini
[defaults]
log_path = /tmp/ansible.log
host_key_checking = False
retry_files_enabled = False

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
pipelining = True
```

---

# ▶️ Analyze Logs

```bash
ansible-playbook -i /etc/ansible/hosts check-mode-demo.yml

tail -f /tmp/ansible.log
```

---

# 🛡️ Best Practices for Troubleshooting

- ✅ Use `--check` before production changes
- ✅ Use `-vvv` for detailed debugging
- ✅ Validate syntax before execution
- ✅ Use tags for selective task execution
- ✅ Test SSH connectivity first
- ✅ Use handlers for controlled service restarts
- ✅ Enable logging in `ansible.cfg`
- ✅ Use step-by-step execution for complex issues

---

# 🎓 Conclusion

Congratulations! 🎉

You have successfully learned how to:

- ✅ Use `ansible-console`
- ✅ Troubleshoot failed playbooks
- ✅ Analyze logs and error messages
- ✅ Use check mode effectively
- ✅ Debug variables and templates
- ✅ Apply systematic troubleshooting techniques

---

# 🌍 Real-World Applications

- 🚀 Production Playbook Validation
- 🔒 Infrastructure Troubleshooting
- 📊 Configuration Auditing
- ⚙️ CI/CD Automation Debugging
- ☁️ Enterprise DevOps Operations
- 🛡️ Infrastructure Compliance

---

# 📚 Next Steps

- 🔐 Learn Ansible Vault
- 🧠 Explore Advanced Debugging Modules
- ⚙️ Practice with Complex Playbooks
- 📦 Learn Custom Modules & Plugins
- ☁️ Explore AWX / Ansible Tower

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
