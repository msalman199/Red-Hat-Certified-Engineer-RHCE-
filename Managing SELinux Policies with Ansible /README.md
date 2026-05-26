# 🛡️ Managing SELinux Policies with Ansible

<div align="center">

![SELinux](https://img.shields.io/badge/SELinux-Security-red?style=for-the-badge&logo=redhat)
![Ansible](https://img.shields.io/badge/Ansible-Automation-black?style=for-the-badge&logo=ansible)
![Linux](https://img.shields.io/badge/Linux-RHEL%208-blue?style=for-the-badge&logo=linux)
![Status](https://img.shields.io/badge/Status-Complete-success?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

# 🚀 Enterprise SELinux Automation Using Ansible

</div>

---

# 📚 Table of Contents

- [📖 Introduction](#-introduction)
- [🎯 Objectives](#-objectives)
- [🧰 Prerequisites](#-prerequisites)
- [☁️ Lab Environment Setup](#️-lab-environment-setup)
- [🛠️ Task 1: Enforce SELinux Mode](#️-task-1-write-a-playbook-to-enforce-selinux-in-enforcing-mode)
- [📂 Task 2: Manage File Contexts](#-task-2-manage-selinux-file-contexts-using-semanage-module)
- [🔍 Task 3: Troubleshoot SELinux](#-task-3-troubleshoot-selinux-issues-using-ansible-commands)
- [⚡ Advanced SELinux Techniques](#-advanced-selinux-management-techniques)
- [✅ Best Practices](#-best-practices-for-selinux-management)
- [🧪 Verification & Testing](#-verification-and-testing)
- [🏁 Conclusion](#-conclusion)

---

# 📖 Introduction

SELinux (Security-Enhanced Linux) provides Mandatory Access Control (MAC) security for Linux systems.  
Managing SELinux manually across multiple systems can be complex, which is why automation with Ansible is essential for enterprise environments.

This lab demonstrates how to automate SELinux configuration, file contexts, troubleshooting, policy management, and monitoring using Ansible playbooks.

---

# 🎯 Objectives

By the end of this lab, you will be able to:

✅ Understand SELinux fundamentals and security contexts  
✅ Automate SELinux policy management using Ansible playbooks  
✅ Configure SELinux in enforcing mode  
✅ Manage SELinux file contexts using semanage module  
✅ Troubleshoot SELinux-related issues  
✅ Implement enterprise-grade SELinux best practices  

---

# 🧰 Prerequisites

Before starting this lab, you should have:

- 🐧 Basic Linux administration knowledge
- ⚙️ Familiarity with Ansible fundamentals
- 📝 Knowledge of YAML syntax
- 🔐 Understanding of Linux file permissions
- 💻 Experience with command-line interfaces
- 🖥️ Basic understanding of RHEL/CentOS systems

---

# ☁️ Lab Environment Setup

## 🖥️ Environment Details

| Component | Description |
|----------|-------------|
| 🎛️ Control Node | RHEL/CentOS 8 with Ansible installed |
| 🖧 Managed Nodes | Two Linux systems |
| 📦 Dependencies | Pre-installed SELinux packages |
| 🔗 Networking | Fully configured connectivity |

---

# 🛠️ Task 1: Write a Playbook to Enforce SELinux in Enforcing Mode

---

# 📌 Subtask 1.1: Understanding SELinux Modes

| Mode | Description |
|------|-------------|
| 🔒 Enforcing | Policies are enforced and violations blocked |
| 📝 Permissive | Violations logged but not blocked |
| ❌ Disabled | SELinux completely disabled |

---

# 📌 Subtask 1.2: Create SELinux Enforcement Playbook

## 📄 `selinux_enforce.yml`

```yaml
---
- name: Manage SELinux Enforcement Mode
  hosts: managed_nodes
  become: yes
  vars:
    selinux_mode: enforcing
    selinux_policy: targeted

  tasks:
    - name: Check current SELinux status
      command: getenforce
      register: current_selinux_status
      changed_when: false

    - name: Display current SELinux status
      debug:
        msg: "Current SELinux status: {{ current_selinux_status.stdout }}"

    - name: Install SELinux management packages
      yum:
        name:
          - policycoreutils
          - policycoreutils-python-utils
          - selinux-policy
          - selinux-policy-targeted
          - setroubleshoot-server
          - setools-console
        state: present

    - name: Configure SELinux to enforcing mode
      selinux:
        policy: "{{ selinux_policy }}"
        state: "{{ selinux_mode }}"
      register: selinux_change
      notify: reboot_system

    - name: Verify SELinux configuration file
      lineinfile:
        path: /etc/selinux/config
        regexp: '^SELINUX='
        line: "SELINUX={{ selinux_mode }}"
        backup: yes

    - name: Check if reboot is required
      debug:
        msg: "System reboot required: {{ selinux_change.reboot_required | default(false) }}"

    - name: Wait for system to come back online
      wait_for_connection:
        connect_timeout: 20
        sleep: 5
        delay: 5
        timeout: 300
      when: selinux_change.reboot_required | default(false)

  handlers:
    - name: reboot_system
      reboot:
        msg: "Rebooting system to apply SELinux changes"
        connect_timeout: 5
        reboot_timeout: 300
        pre_reboot_delay: 0
        post_reboot_delay: 30
      when: selinux_change.reboot_required | default(false)
```

---

# ▶️ Subtask 1.3: Execute the Playbook

```bash
# Navigate to playbook directory
cd /home/ansible/playbooks

# Create playbook file
nano selinux_enforce.yml

# Run playbook
ansible-playbook -i inventory selinux_enforce.yml

# Verify SELinux status
ansible managed_nodes -i inventory -m command -a "sestatus" --become
```

---

# 📌 Subtask 1.4: SELinux Status Check Playbook

## 📄 `selinux_status.yml`

```yaml
---
- name: Comprehensive SELinux Status Check
  hosts: managed_nodes
  become: yes

  tasks:
    - name: Get detailed SELinux status
      command: sestatus
      register: selinux_detailed_status
      changed_when: false

    - name: Display detailed SELinux information
      debug:
        var: selinux_detailed_status.stdout_lines

    - name: Check SELinux booleans status
      command: getsebool -a
      register: selinux_booleans
      changed_when: false

    - name: Count active SELinux booleans
      debug:
        msg: "Total SELinux booleans: {{ selinux_booleans.stdout_lines | length }}"
```

---

# 📂 Task 2: Manage SELinux File Contexts Using Semanage Module

---

# 📌 Subtask 2.1: Understanding File Contexts

SELinux file context format:

```text
user:role:type:level
```

---

# 📋 Common Context Types

| Context Type | Purpose |
|--------------|----------|
| 🌐 httpd_exec_t | Web executables |
| ⚙️ httpd_config_t | Apache configs |
| 🏠 user_home_t | User home directories |
| 👑 admin_home_t | Administrator directories |

---

# 📌 Subtask 2.2: File Context Management Playbook

## 📄 `selinux_file_contexts.yml`

```yaml
---
- name: Manage SELinux File Contexts
  hosts: managed_nodes
  become: yes

  vars:
    custom_web_dir: /opt/webapp
    log_directory: /var/log/webapp

  tasks:
    - name: Create custom web application directory
      file:
        path: "{{ custom_web_dir }}"
        state: directory
        owner: apache
        group: apache
        mode: '0755'

    - name: Create custom log directory
      file:
        path: "{{ log_directory }}"
        state: directory
        owner: apache
        group: apache
        mode: '0755'

    - name: Set SELinux file context for custom web directory
      sefcontext:
        target: "{{ custom_web_dir }}(/.*)?"
        setype: httpd_exec_t
        state: present
      notify: restore_selinux_contexts

    - name: Set SELinux file context for log directory
      sefcontext:
        target: "{{ log_directory }}(/.*)?"
        setype: httpd_log_t
        state: present
      notify: restore_selinux_contexts

  handlers:
    - name: restore_selinux_contexts
      command: restorecon -R {{ item }}
      loop:
        - "{{ custom_web_dir }}"
        - "{{ log_directory }}"
```

---

# ▶️ Execute File Context Playbook

```bash
ansible-playbook -i inventory selinux_file_contexts.yml

ansible managed_nodes -i inventory -m shell -a "semanage fcontext -l -C" --become

ansible managed_nodes -i inventory -m shell -a "ls -laZ /opt/myapp" --become
```

---

# 🔍 Task 3: Troubleshoot SELinux Issues Using Ansible Commands

---

# 📌 SELinux Troubleshooting Playbook

## 📄 `selinux_troubleshooting.yml`

```yaml
---
- name: SELinux Troubleshooting and Diagnostics
  hosts: managed_nodes
  become: yes

  tasks:
    - name: Install troubleshooting tools
      yum:
        name:
          - setroubleshoot-server
          - setroubleshoot
          - policycoreutils-python-utils
          - setools-console
        state: present

    - name: Check SELinux denials
      shell: ausearch -m avc -ts today
      register: selinux_denials
      changed_when: false
      failed_when: false

    - name: Display denial summary
      debug:
        msg: "Found {{ selinux_denials.stdout_lines | length }} SELinux denials today"
```

---

# 📌 Automated SELinux Issue Resolution

## 📄 `selinux_issue_resolution.yml`

```yaml
---
- name: Automated SELinux Issue Resolution
  hosts: managed_nodes
  become: yes

  tasks:
    - name: Fix SELinux file context
      command: restorecon -v /var/test_web/index.html

    - name: Configure SELinux booleans
      seboolean:
        name: httpd_can_network_connect_db
        state: yes
        persistent: yes
```

---

# 📌 SELinux Policy Module Management

## 📄 `selinux_policy_modules.yml`

```yaml
---
- name: SELinux Policy Module Management
  hosts: managed_nodes
  become: yes

  tasks:
    - name: List SELinux modules
      command: semodule -l
      register: loaded_modules
      changed_when: false

    - name: Display module count
      debug:
        msg: "Loaded modules: {{ loaded_modules.stdout_lines | length }}"
```

---

# ▶️ Execute Troubleshooting Playbooks

```bash
ansible-playbook -i inventory selinux_troubleshooting.yml

ansible-playbook -i inventory selinux_issue_resolution.yml

ansible-playbook -i inventory selinux_policy_modules.yml
```

---

# ⚡ Advanced SELinux Management Techniques

---

# 🏗️ Create Reusable Ansible Role

```bash
mkdir -p roles/selinux_management/{tasks,handlers,vars,templates,files}
```

---

# 📄 `roles/selinux_management/tasks/main.yml`

```yaml
---
- name: Include SELinux enforcement tasks
  include_tasks: enforce.yml
  tags: enforce

- name: Include file context tasks
  include_tasks: contexts.yml
  tags: contexts

- name: Include troubleshooting tasks
  include_tasks: troubleshoot.yml
  tags: troubleshoot
```

---

# 📄 `roles/selinux_management/vars/main.yml`

```yaml
---
selinux_packages:
  - policycoreutils
  - policycoreutils-python-utils
  - selinux-policy
  - selinux-policy-targeted
  - setroubleshoot-server
  - setools-console
```

---

# 🚨 Common SELinux Issues & Solutions

---

# 🌐 Issue 1: Apache Cannot Access Files

```yaml
- name: Fix web server access
  sefcontext:
    target: "/custom/web/path(/.*)?"
    setype: httpd_exec_t
    state: present
```

---

# 🗄️ Issue 2: Database Connection Denied

```yaml
- name: Allow database connections
  seboolean:
    name: httpd_can_network_connect_db
    state: yes
    persistent: yes
```

---

# 🏠 Issue 3: Home Directory Access

```yaml
- name: Enable home directory access
  seboolean:
    name: httpd_enable_homedirs
    state: yes
    persistent: yes
```

---

# ✅ Best Practices for SELinux Management

---

## 🔒 Always Use Persistent Booleans

```yaml
- name: Persistent SELinux boolean
  seboolean:
    name: "{{ boolean_name }}"
    state: "{{ boolean_state }}"
    persistent: yes
```

---

## 💾 Backup Before Changes

```yaml
- name: Backup SELinux config
  copy:
    src: /etc/selinux/config
    dest: "/etc/selinux/config.backup"
    remote_src: yes
```

---

## 🧪 Test in Permissive Mode First

```yaml
- name: Test SELinux changes
  selinux:
    policy: targeted
    state: permissive
```

---

## 📜 Log SELinux Changes

```yaml
- name: Log SELinux changes
  lineinfile:
    path: /var/log/selinux_changes.log
    line: "{{ ansible_date_time.iso8601 }} - SELinux updated"
    create: yes
```

---

# 🧪 Verification and Testing

## 📄 Final Verification Playbook

```yaml
---
- name: Final SELinux Verification
  hosts: managed_nodes
  become: yes

  tasks:
    - name: SELinux status
      shell: |
        echo "=== SELinux Status ==="
        sestatus
      register: final_status
      changed_when: false

    - name: Display results
      debug:
        var: final_status.stdout_lines
```

---

# 🏁 Conclusion

## 🎉 Key Accomplishments

✅ Automated SELinux enforcement  
✅ Managed SELinux file contexts  
✅ Troubleshot SELinux issues  
✅ Applied enterprise security best practices  
✅ Created reusable Ansible roles  

---

# 🌍 Why SELinux Automation Matters

By automating SELinux using Ansible, organizations achieve:

- 🔄 Consistency
- 📈 Scalability
- 🛡️ Improved Security
- ⚡ Faster Deployments
- 📋 Compliance Readiness

---

# 💼 Real-World Applications

These skills are useful for:

- 🏢 Enterprise Security Hardening
- 🔐 Compliance Auditing
- 🚀 DevOps Security Automation
- ☁️ Linux Infrastructure Management
- 🎓 RHCE Certification Preparation

---

# 📚 Next Steps

Continue learning:

- Custom SELinux Policies
- CI/CD Security Integration
- Automated Security Monitoring
- Advanced Compliance Automation

---

<div align="center">

# ⭐ Happy Learning & Secure Automation! ⭐

### 🚀 Master Linux Security with Ansible

</div>
