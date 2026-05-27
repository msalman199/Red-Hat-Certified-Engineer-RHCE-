# 🚀 Software Package Management with Ansible

![Ansible](https://img.shields.io/badge/Automation-Ansible-red?style=for-the-badge&logo=ansible)
![Linux](https://img.shields.io/badge/Platform-Linux-yellow?style=for-the-badge&logo=linux)
![RHEL](https://img.shields.io/badge/OS-RHEL%208+-blue?style=for-the-badge&logo=redhat)
![YAML](https://img.shields.io/badge/Language-YAML-orange?style=for-the-badge&logo=yaml)
![DNF](https://img.shields.io/badge/Package_Manager-DNF-green?style=for-the-badge)
![Automation](https://img.shields.io/badge/Infrastructure-Automation-purple?style=for-the-badge)

---

# 📘 Software Package Management with Ansible

## 🎯 Objectives

By the end of this lab, you will be able to:

- ✅ Automate software installation using Ansible playbooks and package management modules
- ✅ Remove packages systematically through Ansible automation
- ✅ Configure package repositories and manage GPG keys securely
- ✅ Handle software dependencies automatically during installation
- ✅ Write reusable playbooks for enterprise package management
- ✅ Implement best practices for package management automation

---

# 📚 Prerequisites

Before starting this lab, you should have:

- Basic Linux command line knowledge
- Familiarity with YAML syntax
- Understanding of Ansible fundamentals
- Knowledge of package management in RHEL-based systems
- Access to a text editor (vim/nano/VS Code)

---

# 🛠 Required Knowledge Areas

| Technology | Description |
|---|---|
| `yum/dnf` | Package management |
| `Repositories` | Software sources |
| `GPG Keys` | Package verification |
| `SSH` | Secure remote access |
| `YAML` | Playbook configuration |

---

# ☁️ Lab Environment Setup

Al Nafi provides pre-configured Linux cloud machines.

## 🖥 Environment Includes

| Component | Details |
|---|---|
| Control Node | CentOS/RHEL 8+ with Ansible |
| Managed Nodes | 2-3 Linux target systems |
| SSH Access | Passwordless authentication |
| Permissions | Sudo privileges enabled |

---

# 🧩 Task 1 — Basic Package Installation and Removal

---

## 🔹 Subtask 1.1 — Create Basic Package Management Playbook

### 📁 Step 1 — Create Lab Directory

```bash
mkdir -p ~/ansible-lab6/playbooks
cd ~/ansible-lab6
```

---

### 📄 Step 2 — Create Inventory File

```bash
cat > inventory << EOF
[webservers]
node1 ansible_host=192.168.1.10
node2 ansible_host=192.168.1.11

[databases]
node3 ansible_host=192.168.1.12

[all:vars]
ansible_user=ansible
ansible_ssh_private_key_file=~/.ssh/id_rsa
EOF
```

---

### ⚙️ Step 3 — Create Package Management Playbook

```yaml
---
- name: Basic Package Management with Ansible
  hosts: all
  become: yes

  vars:
    packages_to_install:
      - git
      - wget
      - curl
      - vim

    packages_to_remove:
      - telnet
      - rsh

  tasks:

    - name: Update package cache
      dnf:
        update_cache: yes

    - name: Install packages
      dnf:
        name: "{{ packages_to_install }}"
        state: present

    - name: Remove unwanted packages
      dnf:
        name: "{{ packages_to_remove }}"
        state: absent

    - name: Verify installed packages
      command: rpm -q {{ item }}
      loop: "{{ packages_to_install }}"
      changed_when: false
```

---

### ▶️ Step 4 — Run the Playbook

```bash
ansible-playbook -i inventory playbooks/package-management.yml
```

---

# 🚀 Subtask 1.2 — Advanced Package Management

## 📄 Advanced Package Management Playbook

```yaml
---
- name: Advanced Package Management
  hosts: all
  become: yes

  vars:
    web_packages:
      - httpd
      - mod_ssl
      - php

    db_packages:
      - mariadb-server
      - mariadb

  tasks:

    - name: Install web packages
      dnf:
        name: "{{ web_packages }}"
        state: present
      when: inventory_hostname in groups['webservers']

    - name: Install database packages
      dnf:
        name: "{{ db_packages }}"
        state: present
      when: inventory_hostname in groups['databases']

    - name: Remove sendmail package
      dnf:
        name: sendmail
        state: absent
        autoremove: yes
```

---

### ▶️ Execute Advanced Playbook

```bash
ansible-playbook -i inventory playbooks/advanced-package-management.yml
```

---

# 🗂 Task 2 — Repository Management & GPG Configuration

---

## 🔐 Subtask 2.1 — Configure Repositories

### 📄 Repository Management Playbook

```yaml
---
- name: Repository and GPG Key Management
  hosts: all
  become: yes

  vars:
    epel_gpg_key: "https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-8"

  tasks:

    - name: Import EPEL GPG key
      rpm_key:
        key: "{{ epel_gpg_key }}"
        state: present

    - name: Install EPEL repository
      dnf:
        name: epel-release
        state: present

    - name: Add custom repository
      yum_repository:
        name: custom-repo
        description: Custom Repository
        baseurl: https://example.com/repo/
        gpgcheck: yes
        enabled: yes
```

---

### ▶️ Run Repository Playbook

```bash
ansible-playbook -i inventory playbooks/repository-management.yml
```

---

# 🧾 Subtask 2.2 — Repository Templates

---

## 📄 Repository Template

```jinja2
[{{ repo_name }}]
name={{ repo_description }}
baseurl={{ repo_baseurl }}
enabled={{ repo_enabled }}
gpgcheck={{ repo_gpgcheck }}
```

---

## ⚙️ Template-Based Repository Playbook

```yaml
---
- name: Configure Repositories Using Templates
  hosts: all
  become: yes

  tasks:

    - name: Create repository file
      template:
        src: custom.repo.j2
        dest: "/etc/yum.repos.d/custom.repo"
        mode: '0644'
```

---

### ▶️ Execute Template Playbook

```bash
ansible-playbook -i inventory playbooks/template-repository.yml
```

---

# 📦 Task 3 — Software Dependency Management

---

## 🔧 Subtask 3.1 — Install Dependencies

### 📄 Dependency Management Playbook

```yaml
---
- name: Software Dependencies Management
  hosts: all
  become: yes

  vars:
    lamp_stack:
      - httpd
      - mariadb-server
      - php
      - php-mysqlnd

  tasks:

    - name: Install LAMP stack
      dnf:
        name: "{{ lamp_stack }}"
        state: present

    - name: Install Python packages
      dnf:
        name:
          - python3
          - python3-pip
        state: present

    - name: Install Flask using pip
      pip:
        name: flask
        executable: pip3
```

---

### ▶️ Run Dependency Playbook

```bash
ansible-playbook -i inventory playbooks/dependency-management.yml
```

---

# 🏗 Subtask 3.2 — Create Reusable Ansible Role

---

## 📁 Create Role Structure

```bash
mkdir -p roles/package-manager/{tasks,defaults,handlers}
```

---

## ⚙️ Default Variables

```yaml
---
default_packages:
  - curl
  - wget
  - git
  - vim
```

---

## 📄 Role Tasks

```yaml
---
- name: Install packages
  dnf:
    name: "{{ default_packages }}"
    state: present
```

---

## 📄 Role-Based Playbook

```yaml
---
- name: Package Management Using Roles
  hosts: webservers
  become: yes

  roles:
    - package-manager
```

---

### ▶️ Execute Role Playbook

```bash
ansible-playbook -i inventory playbooks/role-based-package-management.yml
```

---

# 🛡 Task 4 — Best Practices & Troubleshooting

---

## ✅ Subtask 4.1 — Best Practices

### 📄 Best Practices Playbook

```yaml
---
- name: Package Management Best Practices
  hosts: all
  become: yes

  vars:
    security_packages:
      - aide
      - fail2ban
      - firewalld

  tasks:

    - name: Install security packages
      dnf:
        name: "{{ security_packages }}"
        state: present

    - name: Verify installed packages
      command: rpm -V {{ item }}
      loop: "{{ security_packages }}"
      changed_when: false
```

---

### ▶️ Run Best Practices Playbook

```bash
ansible-playbook -i inventory playbooks/package-best-practices.yml
```

---

# 🧰 Subtask 4.2 — Troubleshooting & Recovery

---

## 📄 Troubleshooting Playbook

```yaml
---
- name: Package Troubleshooting
  hosts: all
  become: yes

  tasks:

    - name: Check RPM lock
      stat:
        path: /var/lib/rpm/.rpm.lock
      register: rpm_lock

    - name: Rebuild RPM database
      command: rpm --rebuilddb

    - name: Clean package cache
      command: dnf clean all
```

---

### ▶️ Execute Troubleshooting Playbook

```bash
ansible-playbook -i inventory playbooks/package-troubleshooting.yml
```

---

# ✅ Final Verification

---

## 📄 Verification Playbook

```yaml
---
- name: Final Verification
  hosts: all
  become: yes

  tasks:

    - name: Gather package facts
      package_facts:
        manager: auto

    - name: Verify packages
      assert:
        that:
          - "'git' in ansible_facts.packages"
          - "'wget' in ansible_facts.packages"
```

---

### ▶️ Run Verification

```bash
ansible-playbook -i inventory playbooks/final-verification.yml
```

---

# 🎉 Conclusion

Congratulations! You have successfully completed:

# 🚀 Lab 6 — Software Package Management with Ansible

---

## 🏆 Skills You Learned

✅ Automated software installation  
✅ Removed packages using Ansible  
✅ Managed repositories and GPG keys  
✅ Installed dependency-based applications  
✅ Built reusable Ansible roles  
✅ Implemented enterprise package management best practices  
✅ Performed troubleshooting and recovery operations  

---

# 💡 Why Package Automation Matters

| Benefit | Description |
|---|---|
| ⚡ Speed | Install packages on multiple systems quickly |
| 🔒 Security | GPG verification ensures package integrity |
| 📦 Consistency | Same software across all servers |
| 🤖 Automation | Eliminates repetitive manual work |
| 📈 Scalability | Manage thousands of systems efficiently |

---

# 🎯 RHCE Relevance

This lab directly supports:

- RHCE package management objectives
- Enterprise Linux administration
- Infrastructure as Code (IaC)
- DevOps automation workflows

---

# 📚 Useful Ansible Modules Used

| Module | Purpose |
|---|---|
| `dnf` | Package management |
| `yum_repository` | Repository configuration |
| `rpm_key` | GPG key management |
| `package_facts` | Package information gathering |
| `template` | Dynamic file generation |
| `pip` | Python package management |
| `npm` | Node.js package management |

![Automation](https://img.shields.io/badge/Automation-Enterprise-success?style=for-the-badge)
![RHCE](https://img.shields.io/badge/RHCE-Ready-red?style=for-the-badge)
![DevOps](https://img.shields.io/badge/DevOps-Ansible-blueviolet?style=for-the-badge)

---
