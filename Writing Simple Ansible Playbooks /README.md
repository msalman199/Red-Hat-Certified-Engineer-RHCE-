# 📜 Writing Simple Ansible Playbooks 

<div align="center">

![Ansible](https://img.shields.io/badge/Ansible-Playbooks-red?style=for-the-badge&logo=ansible)
![Automation](https://img.shields.io/badge/Infrastructure-Automation-green?style=for-the-badge)
![DevOps](https://img.shields.io/badge/DevOps-IaC-blue?style=for-the-badge)
![RHCE](https://img.shields.io/badge/RHCE-Preparation-orange?style=for-the-badge)

# 🚀 Complete Ansible Playbooks Automation 

</div>

---

# 📘 Overview

This lab introduces the fundamentals of writing and executing **Ansible Playbooks** for infrastructure automation.

You will learn how to:

- 📜 Write structured Ansible playbooks
- ⚙️ Automate package installation and configuration
- 🖥️ Configure web and database servers
- 🔁 Verify playbook idempotency
- 🛠️ Troubleshoot execution issues
- 📂 Apply best practices for automation projects

This lab builds the foundation for:

- ☁️ Infrastructure as Code (IaC)
- 🚀 DevOps automation
- 🏢 Enterprise configuration management
- 🎯 RHCE certification preparation

---

# 🎯 Objectives

By the end of this lab, students will be able to:

| ✅ Skills | 📘 Description |
|---|---|
| 📜 Understand Playbooks | Learn YAML playbook syntax and structure |
| ⚙️ Automate Systems | Install and configure packages automatically |
| ▶️ Execute Playbooks | Use `ansible-playbook` effectively |
| 🔁 Verify Idempotency | Ensure safe repeated executions |
| 🛠️ Troubleshoot Issues | Diagnose common automation failures |
| 📂 Organize Projects | Follow playbook best practices |

---

# 📋 Prerequisites

Before starting this lab, students should have:

- 🛠️ Basic Linux command line skills
- 🛠️ Familiarity with YAML formatting
- 🛠️ Completion of previous Ansible labs
- 🛠️ Understanding of packages and services
- 🛠️ SSH key-based authentication knowledge

---

# 📚 Required Knowledge Areas

| 📘 Topic | 🔍 Description |
|---|---|
| 🐧 Linux File System | File navigation and management |
| ✏️ Text Editors | `vim`, `nano`, or similar |
| 🌐 Networking | IP addressing and connectivity |
| 📦 Package Management | `yum`, `dnf`, and `apt` |
| 🔐 SSH Authentication | Secure remote access |

---

# ☁️ Lab Environment

## 🖥️ Al Nafi Cloud Machines

| 🖥️ Component | 📘 Description |
|---|---|
| 🤖 Control Node | RHEL/CentOS with Ansible installed |
| 🖧 Managed Nodes | 2–3 target systems |
| 🔐 SSH Access | Pre-configured connectivity |
| 📂 Sample Files | Inventory and directory structures |

---

# 🚀 Task 1: Create an Ansible Playbook

---

# 🔹 Subtask 1.1: Set Up Directory Structure

## 🛠️ Tool: Create Project Structure

```bash
cd ~
mkdir ansible-lab3
cd ansible-lab3
mkdir playbooks group_vars host_vars
```

---

## 🛠️ Tool: Create Inventory File

```bash
cat > inventory << 'EOF'
[webservers]
node1 ansible_host=192.168.1.10
node2 ansible_host=192.168.1.11

[dbservers]
node3 ansible_host=192.168.1.12

[all:vars]
ansible_user=ansible
ansible_ssh_private_key_file=~/.ssh/id_rsa
EOF
```

---

## 🛠️ Tool: Verify Connectivity

```bash
ansible all -i inventory -m ping
```

---

## 📖 Expected Output

```bash
node1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

---

# 🔹 Subtask 1.2: Write Your First Playbook

## 🛠️ Tool: Create Webserver Playbook

```bash
cat > playbooks/webserver-setup.yml << 'EOF'
---
- name: Install and Configure Apache Web Server
  hosts: webservers
  become: yes

  vars:
    http_port: 80
    max_clients: 200
    document_root: /var/www/html

  tasks:

    - name: Install Apache HTTP Server
      package:
        name: httpd
        state: present
      tags:
        - packages
        - apache

    - name: Install additional packages
      package:
        name:
          - wget
          - curl
          - vim
        state: present
      tags:
        - packages

    - name: Create custom index.html
      copy:
        content: |
          <!DOCTYPE html>
          <html>
          <head>
              <title>Welcome to {{ inventory_hostname }}</title>
          </head>
          <body>
              <h1>Hello from {{ inventory_hostname }}</h1>
              <p>This server was configured by Ansible!</p>
              <p>Server IP: {{ ansible_default_ipv4.address }}</p>
              <p>Configured on: {{ ansible_date_time.date }}</p>
          </body>
          </html>
        dest: "{{ document_root }}/index.html"
        owner: apache
        group: apache
        mode: '0644'
      tags:
        - content

    - name: Configure Apache main configuration
      lineinfile:
        path: /etc/httpd/conf/httpd.conf
        regexp: '^Listen '
        line: "Listen {{ http_port }}"
        backup: yes
      notify:
        - restart apache
      tags:
        - configuration

    - name: Configure MaxRequestWorkers
      lineinfile:
        path: /etc/httpd/conf/httpd.conf
        regexp: '^#?MaxRequestWorkers'
        line: "MaxRequestWorkers {{ max_clients }}"
        backup: yes
      notify:
        - restart apache
      tags:
        - configuration

    - name: Ensure Apache is started and enabled
      service:
        name: httpd
        state: started
        enabled: yes
      tags:
        - services

    - name: Open firewall for HTTP
      firewalld:
        service: http
        permanent: yes
        state: enabled
        immediate: yes
      tags:
        - firewall
      ignore_errors: yes

  handlers:
    - name: restart apache
      service:
        name: httpd
        state: restarted
EOF
```

---

# 🔹 Subtask 1.3: Understanding Playbook Components

## 📖 Playbook Structure

| 🧩 Component | 📘 Purpose |
|---|---|
| `name` | Descriptive playbook/task title |
| `hosts` | Inventory group to target |
| `become` | Use sudo privileges |
| `vars` | Store reusable variables |
| `tasks` | Actions performed on hosts |
| `handlers` | Triggered after changes |

---

## 📖 Common Ansible Modules

| 🧩 Module | 📘 Purpose |
|---|---|
| `package` | Install software packages |
| `copy` | Copy files/content |
| `lineinfile` | Modify configuration files |
| `service` | Manage system services |
| `firewalld` | Configure firewall rules |

---

# 🔹 Subtask 1.4: Create Database Playbook

## 🛠️ Tool: Create Database Playbook

```bash
cat > playbooks/database-setup.yml << 'EOF'
---
- name: Install and Configure MariaDB Database Server
  hosts: dbservers
  become: yes

  vars:
    mysql_root_password: "SecurePassword123!"
    mysql_port: 3306

  tasks:

    - name: Install MariaDB server and client
      package:
        name:
          - mariadb-server
          - mariadb
          - python3-PyMySQL
        state: present
      tags:
        - packages
        - database

    - name: Start and enable MariaDB service
      service:
        name: mariadb
        state: started
        enabled: yes
      tags:
        - services

    - name: Set MariaDB root password
      mysql_user:
        name: root
        password: "{{ mysql_root_password }}"
        login_unix_socket: /var/lib/mysql/mysql.sock
        state: present
      tags:
        - security

    - name: Create database configuration file
      copy:
        content: |
          [mysql]
          port={{ mysql_port }}

          [mysqld]
          port={{ mysql_port }}
        dest: /etc/my.cnf.d/custom.cnf
        owner: root
        group: root
        mode: '0644'
      notify:
        - restart mariadb
      tags:
        - configuration

    - name: Open firewall for MySQL
      firewalld:
        port: "{{ mysql_port }}/tcp"
        permanent: yes
        state: enabled
        immediate: yes
      tags:
        - firewall
      ignore_errors: yes

  handlers:
    - name: restart mariadb
      service:
        name: mariadb
        state: restarted
EOF
```

---

# 🚀 Task 2: Execute Playbooks

---

# 🔹 Subtask 2.1: Syntax Check and Dry Run

## 🛠️ Tool: Validate Playbook Syntax

```bash
ansible-playbook -i inventory playbooks/webserver-setup.yml --syntax-check
```

---

## 🛠️ Tool: Perform Dry Run

```bash
ansible-playbook -i inventory playbooks/webserver-setup.yml --check
```

---

## 🛠️ Tool: Run with Verbose Output

```bash
ansible-playbook -i inventory playbooks/webserver-setup.yml --check -v
```

---

# 🔹 Subtask 2.2: Execute Webserver Playbook

## 🛠️ Tool: Run Webserver Playbook

```bash
ansible-playbook -i inventory playbooks/webserver-setup.yml
```

---

## 🛠️ Tool: Verify Web Server Access

```bash
curl http://node1
curl http://node2
```

---

## 🛠️ Tool: Verify Apache Service

```bash
ansible webservers -i inventory -m service -a "name=httpd state=started" --become
```

---

# 🔹 Subtask 2.3: Execute Database Playbook

## 🛠️ Tool: Run Database Playbook

```bash
ansible-playbook -i inventory playbooks/database-setup.yml
```

---

## 🛠️ Tool: Verify Database Service

```bash
ansible dbservers -i inventory -m service -a "name=mariadb state=started" --become
```

---

# 🔹 Subtask 2.4: Using Tags

## 🛠️ Tool: Run Only Package Tasks

```bash
ansible-playbook -i inventory playbooks/webserver-setup.yml --tags "packages"
```

---

## 🛠️ Tool: Run Only Configuration Tasks

```bash
ansible-playbook -i inventory playbooks/webserver-setup.yml --tags "configuration"
```

---

## 🛠️ Tool: Skip Firewall Tasks

```bash
ansible-playbook -i inventory playbooks/webserver-setup.yml --skip-tags "firewall"
```

---

## 🛠️ Tool: List Available Tags

```bash
ansible-playbook -i inventory playbooks/webserver-setup.yml --list-tags
```

---

# 🚀 Task 3: Test Playbook Idempotency

---

# 🔹 Subtask 3.1: Understanding Idempotency

## 📖 What is Idempotency?

Idempotency means:

> Running the same playbook multiple times produces the same result without unnecessary changes.

---

## 🛠️ Tool: Re-run Playbook

```bash
ansible-playbook -i inventory playbooks/webserver-setup.yml
```

---

## 📖 Expected Result

```bash
changed=0
```

### ✅ Meaning:

- No unnecessary changes were made
- System already matches desired configuration
- Automation is safe and predictable

---

# 🔹 Subtask 3.2: Test Configuration Drift

## 🛠️ Tool: Modify File Manually

```bash
ansible node1 -i inventory -m shell -a "echo 'Modified manually' > /var/www/html/index.html" --become
```

---

## 🛠️ Tool: Re-run Playbook

```bash
ansible-playbook -i inventory playbooks/webserver-setup.yml
```

---

## 📖 Expected Result

| 🖥️ Host | 📘 Result |
|---|---|
| node1 | File corrected (`changed`) |
| node2 | No change (`ok`) |

---

# 🔹 Subtask 3.3: Idempotency Examples

## 🛠️ Tool: Create Idempotency Test Playbook

```bash
cat > playbooks/idempotency-test.yml << 'EOF'
---
- name: Idempotency Testing Examples
  hosts: webservers
  become: yes

  tasks:

    - name: Bad example - always runs
      shell: echo "Current time: $(date)" >> /tmp/timestamps.log
      tags:
        - bad-example

    - name: Good example - managed file
      copy:
        content: "This file was created by Ansible\n"
        dest: /tmp/ansible-managed.txt
        owner: root
        group: root
        mode: '0644'
      tags:
        - good-example

    - name: Good example - ensure directory exists
      file:
        path: /opt/myapp
        state: directory
        owner: root
        group: root
        mode: '0755'
      tags:
        - good-example

    - name: Good example - conditional execution
      shell: echo "First run" > /tmp/first-run.txt
      args:
        creates: /tmp/first-run.txt
      tags:
        - good-example
EOF
```

---

## 🛠️ Tool: Run Good Example

```bash
ansible-playbook -i inventory playbooks/idempotency-test.yml --tags "good-example"
```

---

## 🛠️ Tool: Run Non-idempotent Example

```bash
ansible-playbook -i inventory playbooks/idempotency-test.yml --tags "bad-example"
```

---

# 🔹 Subtask 3.4: Automated Idempotency Test Script

## 🛠️ Tool: Create Test Script

```bash
cat > test-idempotency.sh << 'EOF'
#!/bin/bash

echo "=== Testing Playbook Idempotency ==="

ansible-playbook -i inventory playbooks/webserver-setup.yml > first-run.log 2>&1

ansible-playbook -i inventory playbooks/webserver-setup.yml > second-run.log 2>&1

if grep -q "changed=0" second-run.log; then
    echo "✓ PASS: Playbook is idempotent"
else
    echo "✗ FAIL: Unexpected changes detected"
fi
EOF
```

---

## 🛠️ Tool: Make Script Executable

```bash
chmod +x test-idempotency.sh
```

---

## 🛠️ Tool: Run Idempotency Test

```bash
./test-idempotency.sh
```

---

# 🚨 Troubleshooting Common Issues

---

# 🔹 Issue 1: SSH Connection Problems

## 📌 Symptoms

```bash
UNREACHABLE! => Failed to connect via ssh
```

---

## 🛠️ Solutions

```bash
ssh -i ~/.ssh/id_rsa ansible@node1
```

```bash
ansible all -i inventory -m ping -vvv
```

---

# 🔹 Issue 2: Permission Denied Errors

## 📌 Symptoms

```bash
FAILED! => Could not create file
```

---

## 🛠️ Solution

```bash
ansible-playbook -i inventory playbooks/webserver-setup.yml --become
```

---

# 🔹 Issue 3: Package Installation Failures

## 📌 Symptoms

```bash
No package matching 'httpd' found
```

---

## 🛠️ Solution

```bash
ansible all -i inventory -m setup -a "filter=ansible_os_family"
```

---

## 📖 Package Differences

| 🖥️ OS Family | 📦 Package |
|---|---|
| Ubuntu/Debian | apache2 |
| RHEL/CentOS | httpd |

---

# 🔹 Issue 4: Handlers Not Triggering

## 🛠️ Solution

```bash
ansible-playbook -i inventory playbooks/webserver-setup.yml --force-handlers
```

---

# 📚 Best Practices Summary

---

# 🔹 Playbook Organization

| ✅ Best Practice | 📘 Benefit |
|---|---|
| Use descriptive task names | Easier troubleshooting |
| Organize directories logically | Better maintainability |
| Use tags | Selective execution |
| Use variables | Reusability |

---

# 🔹 Idempotency Guidelines

| ✅ Recommendation | 📘 Reason |
|---|---|
| Use native modules | Safer automation |
| Avoid unnecessary shell commands | Prevent repeated changes |
| Test playbooks multiple times | Ensure consistency |
| Use `creates` and `when` | Conditional execution |

---

# 🔹 Security Best Practices

| 🔐 Practice | 📘 Purpose |
|---|---|
| Use Ansible Vault | Protect secrets |
| Apply least privilege | Reduce risk |
| Validate inputs | Prevent failures |
| Set proper permissions | Secure infrastructure |

---

# 🧪 Verification Commands

## 🛠️ Tool: Verify Inventory Connectivity

```bash
ansible all -i inventory -m ping
```

---

## 🛠️ Tool: Run Syntax Check

```bash
ansible-playbook -i inventory playbooks/webserver-setup.yml --syntax-check
```

---

## 🛠️ Tool: Verify Web Services

```bash
curl http://node1
curl http://node2
```

---

## 🛠️ Tool: Verify Idempotency

```bash
ansible-playbook -i inventory playbooks/webserver-setup.yml
```

---

# 📚 Useful Commands Reference

| 💻 Command | 📘 Description |
|---|---|
| `ansible-playbook` | Execute playbooks |
| `--syntax-check` | Validate YAML syntax |
| `--check` | Perform dry-run |
| `--tags` | Execute selected tasks |
| `--skip-tags` | Skip selected tasks |
| `--list-tags` | Show available tags |
| `--become` | Run with sudo privileges |

---

# 🏁 Conclusion

In this lab, you successfully:

- ✅ Created Ansible playbooks for web and database servers
- ✅ Automated package installation and configuration
- ✅ Executed playbooks with multiple execution modes
- ✅ Verified idempotency and configuration consistency
- ✅ Learned troubleshooting techniques for automation failures
- ✅ Applied best practices for scalable automation projects

These foundational automation skills are essential for:

- ☁️ Infrastructure as Code (IaC)
- 🚀 DevOps engineering
- 🏢 Enterprise Linux administration
- 🎯 RHCE certification preparation

---

# 🔑 Key Takeaways

| 💡 Concept | 📘 Importance |
|---|---|
| Playbooks | Automate repeatable tasks |
| Idempotency | Safe repeated execution |
| Tags | Flexible automation control |
| Handlers | Efficient service management |
| Variables | Reusable configurations |
| Automation | Improves consistency and scalability |


## 🚀 You are now ready to build advanced Ansible automation workflows and enterprise playbooks.

</div>
