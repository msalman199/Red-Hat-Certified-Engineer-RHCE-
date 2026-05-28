# 🚀 Using Ansible Roles for System Automation

<div align="center">

![Ansible](https://img.shields.io/badge/Automation-Ansible-red?style=for-the-badge&logo=ansible)
![Linux](https://img.shields.io/badge/Platform-Linux-black?style=for-the-badge&logo=linux)
![DevOps](https://img.shields.io/badge/DevOps-Engineering-blue?style=for-the-badge)
![RHCE](https://img.shields.io/badge/RHCE-Ready-red?style=for-the-badge)
![Automation](https://img.shields.io/badge/System-Automation-green?style=for-the-badge)

# ⚙️ Ansible Roles for Enterprise Automation

### 📘 Reusable • Modular • Scalable • Production Ready

</div>

---

# 📌 Objectives

By the end of this lab, students will be able to:

- ✅ Understand the concept and benefits of Ansible roles
- ✅ Create reusable roles for user management, service configuration, and file management
- ✅ Structure roles following Ansible best practices
- ✅ Implement roles in playbooks effectively
- ✅ Share roles via Ansible Galaxy for community reuse
- ✅ Apply role-based automation to real-world system administration scenarios

---

# 🧰 Prerequisites

Before starting this lab, students should have:

- 🐧 Basic understanding of Linux command line operations
- 📄 Familiarity with YAML syntax and structure
- ⚙️ Previous experience with Ansible playbooks and modules
- 🔐 Knowledge of SSH key-based authentication
- 🖥️ Understanding of system administration concepts
- 📚 Completion of previous Ansible labs or equivalent experience

---

# ☁️ Lab Environment Setup

## 🖥️ Ready-to-Use Cloud Machines

Al Nafi provides pre-configured Linux cloud machines.

### 📦 Environment Includes

| Component | Description |
|---|---|
| 🎛️ Control Node | CentOS/RHEL 8 with Ansible |
| 🖧 Managed Nodes | node1 and node2 |
| 🔑 SSH Access | Passwordless authentication |
| 🛠️ Tools | All dependencies pre-installed |

---

# 🧩 Task 1: Understanding Ansible Roles

# 📂 Subtask 1.1 — Understanding Roles Concept

Ansible roles help organize automation into reusable components.

## 🌟 Benefits of Roles

- ♻️ Reusability
- 📁 Better Organization
- 🤝 Easy Sharing
- 🛠️ Easier Maintenance

---

# 📁 Subtask 1.2 — Create Role Structure

```bash
cd ~

mkdir -p ansible-lab/roles

cd ansible-lab/roles

ansible-galaxy init user_management
```

---

# 🌳 Role Structure

```bash
tree user_management/
```

```text
user_management/
├── defaults/
│   └── main.yml
├── files/
├── handlers/
│   └── main.yml
├── meta/
│   └── main.yml
├── README.md
├── tasks/
│   └── main.yml
├── templates/
├── tests/
│   ├── inventory
│   └── test.yml
└── vars/
    └── main.yml
```

---

# 📖 Directory Explanation

| Directory | Purpose |
|---|---|
| tasks/ | Main role logic |
| defaults/ | Default variables |
| vars/ | Role variables |
| files/ | Static files |
| templates/ | Jinja2 templates |
| handlers/ | Event-driven tasks |
| meta/ | Metadata and dependencies |

---

# 👤 Task 2: Creating Reusable Roles

# 🔐 Subtask 2.1 — User Management Role

```bash
cd ~/ansible-lab/roles/user_management
```

---

# ⚙️ defaults/main.yml

```yaml
---
users_to_create: []
users_to_remove: []
default_shell: /bin/bash
default_groups: []
create_home: true

password_policy:
  min_length: 8
  require_special_chars: false
```

---

# 📋 tasks/main.yml

```yaml
---
- name: Ensure required groups exist
  group:
    name: "{{ item }}"
    state: present
  loop: "{{ default_groups }}"

- name: Create users
  user:
    name: "{{ item.name }}"
    password: "{{ item.password | default(omit) }}"
    shell: "{{ item.shell | default(default_shell) }}"
    groups: "{{ item.groups | default(default_groups) | join(',') }}"
    create_home: "{{ item.create_home | default(create_home) }}"
    state: present
  loop: "{{ users_to_create }}"
  no_log: true

- name: Set SSH keys
  authorized_key:
    user: "{{ item.name }}"
    key: "{{ item.ssh_key }}"
    state: present
  loop: "{{ users_to_create }}"
  when: item.ssh_key is defined

- name: Remove users
  user:
    name: "{{ item }}"
    state: absent
    remove: true
  loop: "{{ users_to_remove }}"

- name: Display summary
  debug:
    msg: "User management completed successfully."
```

---

# 🔄 handlers/main.yml

```yaml
---
- name: restart sshd
  service:
    name: sshd
    state: restarted
  become: true
```

---

# 🛠️ Subtask 2.2 — Service Configuration Role

```bash
cd ~/ansible-lab/roles

ansible-galaxy init service_config
```

---

# ⚙️ defaults/main.yml

```yaml
---
services_to_manage: []
default_service_state: started
default_service_enabled: true
service_config_files: []
backup_configs: true
```

---

# 📋 tasks/main.yml

```yaml
---
- name: Install required packages
  package:
    name: "{{ item.package }}"
    state: present
  loop: "{{ services_to_manage }}"

- name: Deploy configuration files
  template:
    src: "{{ item.template }}"
    dest: "{{ item.dest }}"
    owner: "{{ item.owner | default('root') }}"
    group: "{{ item.group | default('root') }}"
    mode: "{{ item.mode | default('0644') }}"
  loop: "{{ service_config_files }}"
  notify:
    - restart service

- name: Ensure services are running
  service:
    name: "{{ item.name }}"
    state: "{{ item.state | default(default_service_state) }}"
    enabled: "{{ item.enabled | default(default_service_enabled) }}"
  loop: "{{ services_to_manage }}"
```

---

# 🔄 handlers/main.yml

```yaml
---
- name: restart service
  service:
    name: "{{ item.name }}"
    state: restarted
  loop: "{{ services_to_manage }}"
```

---

# 📂 Subtask 2.3 — File Management Role

```bash
ansible-galaxy init file_management
```

---

# ⚙️ defaults/main.yml

```yaml
---
directories_to_create: []
files_to_create: []
files_to_remove: []

default_file_owner: root
default_file_group: root

default_file_mode: '0644'
default_dir_mode: '0755'

backup_existing: true
```

---

# 📋 tasks/main.yml

```yaml
---
- name: Create directories
  file:
    path: "{{ item.path }}"
    state: directory
    owner: "{{ item.owner | default(default_file_owner) }}"
    group: "{{ item.group | default(default_file_group) }}"
    mode: "{{ item.mode | default(default_dir_mode) }}"
  loop: "{{ directories_to_create }}"

- name: Create files with content
  copy:
    content: "{{ item.content }}"
    dest: "{{ item.dest }}"
    owner: "{{ item.owner | default(default_file_owner) }}"
    group: "{{ item.group | default(default_file_group) }}"
    mode: "{{ item.mode | default(default_file_mode) }}"
  loop: "{{ files_to_create }}"

- name: Remove files
  file:
    path: "{{ item }}"
    state: absent
  loop: "{{ files_to_remove }}"
```

---

# 🚀 Task 3: Implementing Roles in Playbooks

# 📘 site.yml

```yaml
---
- name: System Configuration with Roles
  hosts: all
  become: true
  gather_facts: true

  vars:

    users_to_create:
      - name: developer
        groups: ['wheel', 'developers']
        shell: /bin/bash

      - name: operator
        groups: ['operators']
        shell: /bin/bash

    default_groups:
      - developers
      - operators

    services_to_manage:
      - name: httpd
        package: httpd
        state: started
        enabled: true

      - name: firewalld
        state: started
        enabled: true

    directories_to_create:
      - path: /var/www/html/app
        owner: apache
        group: apache
        mode: '0755'

    files_to_create:
      - dest: /var/www/html/index.html
        content: |
          <html>
          <head><title>Ansible Managed Server</title></head>
          <body>
            <h1>Welcome to {{ inventory_hostname }}</h1>
          </body>
          </html>
        owner: apache
        group: apache
        mode: '0644'

  roles:
    - user_management
    - service_config
    - file_management

  post_tasks:
    - name: Verify execution
      debug:
        msg: "All roles applied successfully."
```

---

# 🌐 Apache Template

## 📄 httpd.conf.j2

```apache
ServerRoot "/etc/httpd"

Listen 80

User apache
Group apache

ServerAdmin admin@{{ ansible_fqdn }}

DocumentRoot "/var/www/html"

<Directory "/var/www/html">
    AllowOverride None
    Require all granted
</Directory>

ErrorLog "logs/error_log"

LogLevel warn
```

---

# 🖧 Inventory File

```ini
[webservers]
node1 ansible_host=<node1_ip>
node2 ansible_host=<node2_ip>

[all:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

---

# ▶️ Run Playbook

## ✅ Syntax Check

```bash
ansible-playbook -i inventory site.yml --syntax-check
```

## 🔍 Dry Run

```bash
ansible-playbook -i inventory site.yml --check
```

## 🚀 Execute Playbook

```bash
ansible-playbook -i inventory site.yml -v
```

---

# 🌌 Task 4: Sharing Roles via Ansible Galaxy

# 📄 meta/main.yml

```yaml
galaxy_info:
  author: Your Name
  description: User management role
  company: Your Organization
  license: MIT

  min_ansible_version: 2.9

  platforms:
    - name: EL
      versions:
        - 7
        - 8

  galaxy_tags:
    - users
    - automation
    - administration

dependencies: []
```

---

# 📘 README.md Example

```markdown
# User Management Role

This role manages Linux users and groups.

## Features

- Create users
- Remove users
- Configure SSH keys
- Manage groups

## Requirements

- Ansible 2.9+
- Linux systems
```

---

# 🧪 Role Testing

```yaml
---
- hosts: localhost
  remote_user: root

  vars:
    users_to_create:
      - name: testuser
        groups: ['wheel']

  roles:
    - user_management
```

---

# 📦 Create Collection

```bash
mkdir -p collections/ansible_collections/myorg/system_roles

cd collections/ansible_collections/myorg/system_roles
```

---

# 📄 galaxy.yml

```yaml
namespace: myorg
name: system_roles
version: 1.0.0

authors:
  - Your Name

description: Collection of system administration roles

license:
  - MIT

tags:
  - automation
  - configuration
```

---

# 🛠️ Build Collection

```bash
ansible-galaxy collection build
```

---

# 📤 Publish Collection (Simulation)

```bash
mkdir -p ~/ansible-lab/local_galaxy

cp myorg-system_roles-1.0.0.tar.gz ~/ansible-lab/local_galaxy/
```

---

# 🔥 Task 5: Advanced Role Usage

# 🔗 Role Dependencies

```yaml
dependencies:
  - role: user_management

  - role: service_config

  - role: file_management
```

---

# 🎯 Variable Precedence Demo

```yaml
---
- name: Variable Precedence Demo
  hosts: node1
  become: true

  vars:
    default_shell: /bin/zsh

  roles:
    - role: user_management
      vars:
        users_to_create:
          - name: demo_user
            shell: /bin/bash
```

---

# ⚡ Conditional Role Execution

```yaml
---
- name: Conditional Role Execution
  hosts: all

  vars:
    install_web_server: true

  roles:
    - role: service_config
      when: install_web_server | bool
```

---

# ✅ Verification Playbook

```yaml
---
- name: Verify Role Results
  hosts: all
  become: true

  tasks:

    - name: Check users
      getent:
        database: passwd
        key: developer

    - name: Check Apache service
      service_facts:

    - name: Check files
      stat:
        path: /var/www/html/index.html
```

---

# 📊 Performance Testing

```yaml
---
- name: Performance Testing
  hosts: all

  tasks:

    - name: Record start time
      set_fact:
        start_time: "{{ ansible_date_time.epoch }}"
```

---

# 🛑 Troubleshooting Common Issues

# ❌ Problem 1 — Role Not Found

```bash
ansible-config dump | grep ROLES_PATH
```

---

# ❌ Problem 2 — Variable Conflicts

```yaml
- debug:
    var: variable_name
```

---

# ❌ Problem 3 — Handler Not Triggering

```yaml
notify: restart apache
```

---

# ❌ Problem 4 — Permission Issues

```yaml
become: true

mode: '0644'
```

---

# 🧪 Verification Commands

## 📌 Check Roles Directory

```bash
tree roles/
```

## 📌 Check Services

```bash
systemctl status httpd
```

## 📌 Verify Users

```bash
getent passwd developer
```

## 📌 Verify Files

```bash
ls -l /var/www/html/
```

---

# 🎓 Conclusion

In this comprehensive lab, you successfully:

- ✅ Created reusable Ansible roles
- ✅ Implemented enterprise automation best practices
- ✅ Automated user, service, and file management
- ✅ Built Galaxy-compatible collections
- ✅ Applied role-based automation in real-world scenarios
- ✅ Improved maintainability and scalability

---

# 🚀 Key Benefits of Ansible Roles

| Benefit | Description |
|---|---|
| ♻️ Reusability | Write once, use everywhere |
| 📁 Organization | Clean structured automation |
| ⚡ Scalability | Easy enterprise deployments |
| 🔒 Consistency | Standardized configurations |
| 🛠️ Maintainability | Easier troubleshooting |

---

<div align="center">

# 🏆 Lab Completed Successfully

### 💡 Ansible Roles = Scalable Automation + Enterprise Standardization

![Automation](https://img.shields.io/badge/Automation-Success-brightgreen?style=for-the-badge)
![DevOps](https://img.shields.io/badge/DevOps-Engineer-blue?style=for-the-badge)
![Linux](https://img.shields.io/badge/Linux-Admin-black?style=for-the-badge)

</div>
