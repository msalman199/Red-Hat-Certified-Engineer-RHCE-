# 🚀 Troubleshooting Automation Runs with Ansible

<p align="center">

![Ansible](https://img.shields.io/badge/Ansible-Automation-red?style=for-the-badge\&logo=ansible)
![Linux](https://img.shields.io/badge/Linux-System%20Administration-yellow?style=for-the-badge\&logo=linux)
![RHCE](https://img.shields.io/badge/RHCE-Preparation-blue?style=for-the-badge)
![DevOps](https://img.shields.io/badge/DevOps-Automation-green?style=for-the-badge)
![YAML](https://img.shields.io/badge/YAML-Configuration-black?style=for-the-badge\&logo=yaml)
![Automation](https://img.shields.io/badge/Infrastructure-Automation-orange?style=for-the-badge)

</p>

---

# 📘 Objectives

By the end of this lab, you will be able to:

✅ Perform dry runs using `ansible-playbook --check`
✅ Implement debugging techniques using Ansible debug module
✅ Use `ansible-playbook --step` for interactive execution
✅ Troubleshoot common automation issues
✅ Apply production troubleshooting best practices

---

# 🛠️ Prerequisites

Before starting this lab, you should have:

✔️ Basic Linux command line knowledge
✔️ YAML syntax understanding
✔️ Familiarity with Ansible playbooks and modules
✔️ SSH key authentication knowledge
✔️ Experience using editors like vim or nano

---

# ☁️ Lab Environment Setup

## 🌐 Ready-to-Use Cloud Machines

Al Nafi provides pre-configured cloud machines for this lab.

### 🔹 Environment Includes

| 💻 Component     | 📄 Description              |
| ---------------- | --------------------------- |
| 🖥️ Control Node | CentOS/RHEL 8 with Ansible  |
| 🧩 Managed Nodes | node1 and node2             |
| 🔐 SSH Access    | Passwordless authentication |
| 📂 Sample Files  | Pre-configured directories  |

---

# 🧪 Task 1: Using ansible-playbook --check for Dry Runs

---

# 🔹 Subtask 1.1: Understanding Check Mode

## ✅ Step 1: Navigate to Working Directory

```bash
cd /home/ansible
ls -la
```

---

## ✅ Step 2: Create Lab Directory

```bash
mkdir troubleshooting-lab
cd troubleshooting-lab
```

---

## ✅ Step 3: Create Inventory File

```bash
cat > inventory << EOF
[webservers]
node1 ansible_host=192.168.1.10
node2 ansible_host=192.168.1.11

[all:vars]
ansible_user=ansible
ansible_ssh_private_key_file=/home/ansible/.ssh/id_rsa
EOF
```

---

# 🔹 Subtask 1.2: Creating a Test Playbook

## ✅ Step 4: Create Web Server Setup Playbook

```bash
cat > webserver-setup.yml << 'EOF'
---
- name: Web Server Setup and Configuration
  hosts: webservers
  become: yes

  vars:
    web_package: httpd
    web_service: httpd
    document_root: /var/www/html

  tasks:

    - name: Install web server package
      yum:
        name: "{{ web_package }}"
        state: present

    - name: Start and enable web service
      systemd:
        name: "{{ web_service }}"
        state: started
        enabled: yes

    - name: Create custom index page
      copy:
        content: |
          <html>
          <head><title>{{ inventory_hostname }}</title></head>
          <body>
          <h1>Managed by Ansible</h1>
          </body>
          </html>
        dest: "{{ document_root }}/index.html"

    - name: Open firewall for HTTP
      firewalld:
        service: http
        permanent: yes
        state: enabled
        immediate: yes
EOF
```

---

# 🔹 Subtask 1.3: Performing Dry Runs

## ✅ Step 5: Run Playbook in Check Mode

```bash
ansible-playbook -i inventory webserver-setup.yml --check
```

---

## ✅ Step 6: Run Check Mode with Verbose Output

```bash
ansible-playbook -i inventory webserver-setup.yml --check -v
```

---

## ✅ Step 7: Run Check Mode with Diff

```bash
ansible-playbook -i inventory webserver-setup.yml --check --diff
```

---

# 🔹 Subtask 1.4: Analyze Check Mode Results

## ✅ Step 8: Create Problematic Playbook

```bash
cat > problematic-playbook.yml << 'EOF'
---
- name: Problematic Playbook
  hosts: webservers
  become: yes

  tasks:

    - name: Install invalid package
      yum:
        name: non-existent-package
        state: present

    - name: Copy invalid file
      copy:
        src: /tmp/missing-file.txt
        dest: /invalid/location/file.txt

    - name: Start invalid service
      systemd:
        name: wrong-service-name
        state: started
EOF
```

---

## ✅ Step 9: Run Problematic Playbook

```bash
ansible-playbook -i inventory problematic-playbook.yml --check -v
```

---

# 🐞 Task 2: Implementing Debugging with the Debug Module

---

# 🔹 Subtask 2.1: Basic Debug Module Usage

## ✅ Step 10: Create Debug Examples Playbook

```bash
cat > debug-examples.yml << 'EOF'
---
- name: Debug Examples
  hosts: webservers
  gather_facts: yes

  vars:
    app_name: MyWebApp
    app_version: 1.2.3

  tasks:

    - name: Display message
      debug:
        msg: "Deploying {{ app_name }} version {{ app_version }}"

    - name: Show hostname
      debug:
        var: ansible_hostname

    - name: Show system information
      debug:
        msg: |
          Hostname: {{ ansible_hostname }}
          IP: {{ ansible_default_ipv4.address }}
          OS: {{ ansible_os_family }}
EOF
```

---

## ✅ Step 11: Run Debug Playbook

```bash
ansible-playbook -i inventory debug-examples.yml
```

---

# 🔹 Subtask 2.2: Advanced Debugging Techniques

## ✅ Step 12: Create Advanced Debug Playbook

```bash
cat > advanced-debug.yml << 'EOF'
---
- name: Advanced Debugging
  hosts: webservers
  gather_facts: yes

  vars:
    users:
      - name: alice
        uid: 1001

      - name: bob
        uid: 1002

  tasks:

    - name: Display users
      debug:
        var: users

    - name: Show disk usage
      command: df -h
      register: disk_usage

    - name: Display disk usage
      debug:
        var: disk_usage.stdout_lines
EOF
```

---

## ✅ Step 13: Execute Advanced Debugging Playbook

```bash
ansible-playbook -i inventory advanced-debug.yml
```

---

# 🔹 Subtask 2.3: Debugging Failed Tasks

## ✅ Step 14: Create Failure Debugging Playbook

```bash
cat > debug-failures.yml << 'EOF'
---
- name: Debugging Failures
  hosts: webservers
  become: yes

  tasks:

    - name: Install package
      yum:
        name: httpd
        state: present
      register: package_result

    - name: Show package result
      debug:
        var: package_result
EOF
```

---

## ✅ Step 15: Run Failure Debugging Playbook

```bash
ansible-playbook -i inventory debug-failures.yml
```

---

# ⚙️ Task 3: Using ansible-playbook --step

---

# 🔹 Subtask 3.1: Understanding Step Mode

## ✅ Step 16: Create Step-by-Step Playbook

```bash
cat > step-by-step.yml << 'EOF'
---
- name: Step Mode Example
  hosts: webservers
  become: yes

  tasks:

    - name: Install packages
      yum:
        name:
          - vim
          - wget
          - curl
        state: present

    - name: Create app directory
      file:
        path: /opt/myapp
        state: directory

    - name: Create config file
      copy:
        content: "Application Configuration"
        dest: /opt/myapp/config.conf
EOF
```

---

# 🔹 Subtask 3.2: Execute in Step Mode

## ✅ Step 17: Run Step Mode

```bash
ansible-playbook -i inventory step-by-step.yml --step
```

### 🎯 Step Mode Options

| 🔘 Option | 📄 Description           |
| --------- | ------------------------ |
| y         | Execute task             |
| n         | Skip task                |
| c         | Continue remaining tasks |

---

## ✅ Step 18: Combine Step Mode with Check Mode

```bash
ansible-playbook -i inventory step-by-step.yml --step --check
```

---

## ✅ Step 19: Limit to Single Host

```bash
ansible-playbook -i inventory step-by-step.yml --step --limit node1
```

---

# 🧩 Task 4: Comprehensive Troubleshooting Scenario

---

# 🔹 Subtask 4.1: Create Complex Scenario

## ✅ Step 20: Create Troubleshooting Playbook

```bash
cat > comprehensive-troubleshooting.yml << 'EOF'
---
- name: Comprehensive Troubleshooting
  hosts: webservers
  become: yes

  vars:
    web_user: webadmin
    app_port: 8080

  tasks:

    - name: Create web user
      user:
        name: "{{ web_user }}"
        state: present

    - name: Install web server
      yum:
        name: httpd
        state: present

    - name: Start service
      systemd:
        name: httpd
        state: started
        enabled: yes

    - name: Verify service
      command: systemctl status httpd
      register: service_status

    - name: Show service output
      debug:
        var: service_status.stdout_lines
EOF
```

---

## ✅ Step 21: Run in Check Mode

```bash
ansible-playbook -i inventory comprehensive-troubleshooting.yml --check --diff
```

---

## ✅ Step 22: Run in Step Mode

```bash
ansible-playbook -i inventory comprehensive-troubleshooting.yml --step
```

---

## ✅ Step 23: Run with Verbose Output

```bash
ansible-playbook -i inventory comprehensive-troubleshooting.yml -v
```

---

# 🧰 Task 5: Best Practices and Common Issues

---

# 🔹 Subtask 5.1: Common Troubleshooting Commands

## ✅ Step 24: Create Troubleshooting Reference Playbook

```bash
cat > troubleshooting-reference.yml << 'EOF'
---
- name: Troubleshooting Reference
  hosts: webservers
  gather_facts: yes

  tasks:

    - name: Connection test
      ping:

    - name: Display system facts
      debug:
        msg: |
          OS: {{ ansible_distribution }}
          Kernel: {{ ansible_kernel }}
EOF
```

---

## ✅ Step 25: Run Syntax Check

```bash
ansible-playbook troubleshooting-reference.yml --syntax-check
```

---

## ✅ Step 26: Run Reference Playbook

```bash
ansible-playbook -i inventory troubleshooting-reference.yml
```

---

# 🔹 Subtask 5.2: Troubleshooting Checklist

## ✅ Step 27: Create Troubleshooting Checklist Script

```bash
cat > troubleshooting-checklist.sh << 'EOF'
#!/bin/bash

echo "=== ANSIBLE TROUBLESHOOTING CHECKLIST ==="

echo "1. Syntax Check"
echo "ansible-playbook playbook.yml --syntax-check"

echo "2. Dry Run"
echo "ansible-playbook -i inventory playbook.yml --check"

echo "3. Dry Run with Diff"
echo "ansible-playbook -i inventory playbook.yml --check --diff"

echo "4. Step Mode"
echo "ansible-playbook -i inventory playbook.yml --step"

echo "5. Verbose Output"
echo "ansible-playbook -i inventory playbook.yml -v"
EOF
```

---

## ✅ Step 28: Make Script Executable

```bash
chmod +x troubleshooting-checklist.sh
```

---

## ✅ Step 29: Run Troubleshooting Checklist

```bash
./troubleshooting-checklist.sh
```

---

# 🎉 Conclusion

Congratulations!

You have successfully completed:

# 🚀 Lab 17: Troubleshooting Automation Runs with Ansible

---

# 📚 What You Learned

✅ Dry run validation using `--check`
✅ Interactive execution using `--step`
✅ Debugging with Ansible debug module
✅ Troubleshooting failed tasks
✅ Verbose logging and analysis
✅ Syntax validation
✅ Production troubleshooting workflows

---

# 💡 Why These Skills Matter

| 🚀 Skill        | 🎯 Benefit                  |
| --------------- | --------------------------- |
| Dry Runs        | Prevent production failures |
| Debugging       | Faster issue resolution     |
| Step Execution  | Better task control         |
| Verbose Logging | Deep troubleshooting        |
| Validation      | Reliable automation         |

---

# 🏆 RHCE Exam Relevance

These troubleshooting skills are essential for:

* RHCE Certification
* Linux Administration
* DevOps Engineering
* Automation Reliability
* Infrastructure Management

---

# 📌 Useful Commands Summary

```bash
ansible-playbook playbook.yml --syntax-check
ansible-playbook playbook.yml --check
ansible-playbook playbook.yml --check --diff
ansible-playbook playbook.yml --step
ansible-playbook playbook.yml -v
ansible-playbook playbook.yml -vvv
ansible all -m ping
ansible all -m setup
```

