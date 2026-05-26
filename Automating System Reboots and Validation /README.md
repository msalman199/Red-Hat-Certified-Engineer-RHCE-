# 🔄 Automating System Reboots and Validation

<div align="center">

![Ansible](https://img.shields.io/badge/Ansible-Automation-black?style=for-the-badge&logo=ansible)
![Linux](https://img.shields.io/badge/Linux-System%20Administration-blue?style=for-the-badge&logo=linux)
![Automation](https://img.shields.io/badge/Automation-System%20Reboots-success?style=for-the-badge)
![Validation](https://img.shields.io/badge/Validation-Post%20Reboot-orange?style=for-the-badge)
![Status](https://img.shields.io/badge/Lab-Complete-brightgreen?style=for-the-badge)

# 🚀 Enterprise Reboot Automation with Ansible

</div>

---

# 📚 Table of Contents

- [📖 Introduction](#-introduction)
- [🎯 Objectives](#-objectives)
- [🧰 Prerequisites](#-prerequisites)
- [☁️ Lab Environment Setup](#️-lab-environment-setup)
- [🛠️ Task 1: Basic Reboot Playbook](#️-task-1-creating-a-basic-system-reboot-playbook)
- [✅ Task 2: Service Validation](#-task-2-implementing-service-validation-after-reboot)
- [🚨 Task 3: Error Handling](#-task-3-implementing-error-handling-for-failed-reboots)
- [⚡ Task 4: Advanced Reboot Scenarios](#-task-4-advanced-reboot-scenarios-and-best-practices)
- [🔍 Troubleshooting](#-troubleshooting-common-issues)
- [🏆 Best Practices](#-best-practices-summary)
- [🏁 Conclusion](#-conclusion)

---

# 📖 Introduction

Automating system reboots is an essential part of enterprise infrastructure management.  
Manual reboot procedures are time-consuming, error-prone, and difficult to scale.

Using **Ansible**, administrators can safely automate:

- 🔄 System reboots
- ⏳ Wait conditions
- 🧪 Validation procedures
- 🚨 Error handling
- 📊 Service monitoring
- ⚡ Rolling maintenance operations

This lab demonstrates enterprise-grade reboot automation workflows using Ansible.

---

# 🎯 Objectives

By the end of this lab, you will be able to:

✅ Create Ansible reboot playbooks  
✅ Implement reboot wait conditions and timeout handling  
✅ Validate services after reboot using Ansible facts  
✅ Implement robust error handling mechanisms  
✅ Use system state verification modules  
✅ Apply enterprise maintenance automation best practices  

---

# 🧰 Prerequisites

Before starting this lab, ensure you have:

- 🐧 Linux administration knowledge
- 📝 Familiarity with YAML syntax
- ⚙️ Understanding of Ansible playbooks/modules
- 🔧 Knowledge of Linux services and systemd
- 🌐 Basic networking and SSH concepts
- 💻 Experience with Linux text editors

---

# ☁️ Lab Environment Setup

## 🖥️ Environment Overview

| Component | Description |
|-----------|-------------|
| 🎛️ Control Node | RHEL/CentOS 8 with Ansible installed |
| 🖧 Managed Nodes | node1 and node2 |
| 🔑 SSH Authentication | Pre-configured SSH keys |
| ⚙️ Validation Services | Sample services installed |

---

# 🛠️ Task 1: Creating a Basic System Reboot Playbook

---

# 📌 Subtask 1.1: Understanding the Reboot Module

The `reboot` module provides safe automated reboots with built-in validation.

## 🔑 Important Parameters

| Parameter | Description |
|-----------|-------------|
| ⏳ reboot_timeout | Maximum reboot wait time |
| 🔌 connect_timeout | SSH reconnect timeout |
| 🧪 test_command | Command used for validation |
| ⏱️ pre_reboot_delay | Delay before reboot |
| ⌛ post_reboot_delay | Delay after reboot |

---

# 📌 Subtask 1.2: Create Project Structure

```bash
mkdir -p ~/ansible-reboot-lab
cd ~/ansible-reboot-lab
mkdir playbooks group_vars host_vars
```

---

# 📌 Create Basic Reboot Playbook

## 📄 `playbooks/system-reboot.yml`

```yaml
---
- name: System Reboot and Validation Playbook
  hosts: managed_nodes
  become: yes
  gather_facts: yes

  vars:
    reboot_timeout: 300
    connect_timeout: 10
    services_to_check:
      - sshd
      - NetworkManager
      - chronyd

  tasks:
    - name: Display current system uptime before reboot
      command: uptime
      register: uptime_before

    - name: Show uptime before reboot
      debug:
        msg: "System uptime before reboot: {{ uptime_before.stdout }}"

    - name: Check if reboot is required
      stat:
        path: /var/run/reboot-required
      register: reboot_required_file

    - name: Force reboot requirement for demonstration
      file:
        path: /var/run/reboot-required
        state: touch
      when: not reboot_required_file.stat.exists

    - name: Perform system reboot
      reboot:
        reboot_timeout: "{{ reboot_timeout }}"
        connect_timeout: "{{ connect_timeout }}"
        test_command: whoami
        msg: "Reboot initiated by Ansible automation"
      register: reboot_result

    - name: Display reboot completion message
      debug:
        msg: "System successfully rebooted. Elapsed time: {{ reboot_result.elapsed }} seconds"
```

---

# 📌 Subtask 1.3: Create Inventory File

## 📄 `inventory.ini`

```ini
[managed_nodes]
node1 ansible_host=192.168.1.10
node2 ansible_host=192.168.1.11

[managed_nodes:vars]
ansible_user=ansible
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

---

# ▶️ Subtask 1.4: Execute Playbook

```bash
ansible-playbook -i inventory.ini playbooks/system-reboot.yml
```

---

# ✅ Task 2: Implementing Service Validation After Reboot

---

# 📌 Subtask 2.1: Create Validation Playbook

## 📄 `playbooks/reboot-with-validation.yml`

```yaml
---
- name: System Reboot with Comprehensive Validation
  hosts: managed_nodes
  become: yes
  gather_facts: yes

  vars:
    reboot_timeout: 600
    connect_timeout: 15
    post_reboot_delay: 30

    critical_services:
      - name: sshd
        description: "SSH Daemon"

      - name: NetworkManager
        description: "Network Manager"

      - name: chronyd
        description: "Time Synchronization"

  tasks:
    - name: Create reboot log directory
      file:
        path: /var/log/ansible-reboot
        state: directory
        mode: '0755'

    - name: Perform controlled system reboot
      reboot:
        reboot_timeout: "{{ reboot_timeout }}"
        connect_timeout: "{{ connect_timeout }}"
        post_reboot_delay: "{{ post_reboot_delay }}"
        test_command: "systemctl is-system-running --wait"
        msg: "Ansible-controlled reboot"
      register: reboot_result

    - name: Validate critical services
      systemd:
        name: "{{ item.name }}"
        state: started
        enabled: yes
      loop: "{{ critical_services }}"
```

---

# 📌 Subtask 2.2: Service-Specific Validation

## 📄 `playbooks/service-validation.yml`

```yaml
---
- name: Detailed Service Validation After Reboot
  hosts: managed_nodes
  become: yes
  gather_facts: yes

  vars:
    service_checks:
      sshd:
        port: 22
        process_name: sshd

      chronyd:
        port: 123
        process_name: chronyd

  tasks:
    - name: Validate service processes
      command: pgrep -f "{{ item.value.process_name }}"
      register: process_check
      loop: "{{ service_checks | dict2items }}"

    - name: Check service listening ports
      wait_for:
        port: "{{ item.value.port }}"
        host: "{{ ansible_default_ipv4.address }}"
        timeout: 10
      loop: "{{ service_checks | dict2items }}"
```

---

# ▶️ Run Validation Playbooks

```bash
ansible-playbook -i inventory.ini playbooks/reboot-with-validation.yml

ansible-playbook -i inventory.ini playbooks/service-validation.yml
```

---

# 🚨 Task 3: Implementing Error Handling for Failed Reboots

---

# 📌 Subtask 3.1: Error Handling Playbook

## 📄 `playbooks/reboot-with-error-handling.yml`

```yaml
---
- name: Robust System Reboot with Error Handling
  hosts: managed_nodes
  become: yes
  gather_facts: yes
  serial: 1

  vars:
    reboot_timeout: 300
    connect_timeout: 10
    max_reboot_attempts: 3

  tasks:
    - name: Verify system accessibility
      ping:

    - name: Perform reboot
      reboot:
        reboot_timeout: "{{ reboot_timeout }}"
        connect_timeout: "{{ connect_timeout }}"
        test_command: "systemctl is-system-running --wait"
      register: reboot_result
      retries: "{{ max_reboot_attempts }}"
      delay: 60

    - name: Display reboot success
      debug:
        msg: "Reboot completed in {{ reboot_result.elapsed }} seconds"
```

---

# 📌 Subtask 3.2: Emergency Recovery Tasks

## 📄 `playbooks/emergency-recovery.yml`

```yaml
---
- name: Check connectivity
  ping:
  register: ping_result
  ignore_errors: yes

- name: Attempt longer reconnect
  wait_for_connection:
    timeout: 120
    delay: 10
```

---

# 📌 Subtask 3.3: Health Check Tasks

## 📄 `playbooks/health-check.yml`

```yaml
---
- name: System Health Check
  block:
    - name: Check uptime
      command: uptime
      register: uptime_check

    - name: Check memory usage
      command: free -m
      register: memory_check

    - name: Check disk usage
      command: df -h
      register: disk_check

    - name: Verify network interfaces
      command: ip addr show
      register: network_check
```

---

# 📌 Subtask 3.4: Reboot Report Template

## 📄 `templates/reboot-report.j2`

```jinja2
SYSTEM REBOOT REPORT
===================

System: {{ inventory_hostname }}

{% if reboot_result is defined %}
- Status: SUCCESS
- Duration: {{ reboot_result.elapsed }} seconds
{% else %}
- Status: FAILED
{% endif %}
```

---

# ▶️ Run Error Handling Playbook

```bash
ansible-playbook -i inventory.ini playbooks/reboot-with-error-handling.yml
```

---

# ⚡ Task 4: Advanced Reboot Scenarios and Best Practices

---

# 📌 Subtask 4.1: Rolling Reboot Playbook

## 📄 `playbooks/rolling-reboot.yml`

```yaml
---
- name: Rolling System Reboot
  hosts: web_servers
  become: yes
  gather_facts: yes
  serial: 1

  vars:
    reboot_timeout: 300

  tasks:
    - name: Perform rolling reboot
      reboot:
        reboot_timeout: "{{ reboot_timeout }}"
        pre_reboot_delay: 10
        post_reboot_delay: 30
      register: reboot_result
```

---

# 📌 Subtask 4.2: Scheduled Maintenance Reboot

## 📄 `playbooks/scheduled-reboot.yml`

```yaml
---
- name: Scheduled Maintenance Reboot
  hosts: managed_nodes
  become: yes
  gather_facts: yes

  vars:
    maintenance_start: "02:00"
    maintenance_end: "04:00"

  tasks:
    - name: Notify users
      command: wall "System reboot in 2 minutes"

    - name: Perform maintenance reboot
      reboot:
        reboot_timeout: 600
        msg: "Scheduled maintenance reboot"
```

---

# 📌 Subtask 4.3: Advanced Inventory

## 📄 `advanced-inventory.ini`

```ini
[web_servers]
web1 ansible_host=192.168.1.20
web2 ansible_host=192.168.1.21

[database_servers]
db1 ansible_host=192.168.1.30

[all:vars]
ansible_user=ansible
ansible_ssh_private_key_file=~/.ssh/id_rsa
```

---

# ▶️ Run Advanced Playbooks

```bash
ansible-playbook -i advanced-inventory.ini playbooks/rolling-reboot.yml

ansible-playbook -i advanced-inventory.ini playbooks/scheduled-reboot.yml
```

---

# 🔍 Troubleshooting Common Issues

---

# 🚨 Issue 1: Reboot Timeout Errors

## ✅ Solution

```yaml
- name: Increase reboot timeout
  reboot:
    reboot_timeout: 900
    connect_timeout: 20
    post_reboot_delay: 60
```

---

# 🚨 Issue 2: Service Validation Failures

## ✅ Solution

```yaml
- name: Restart failed services
  systemd:
    name: "{{ item }}"
    state: restarted
    enabled: yes
  loop: "{{ critical_services }}"
```

---

# 🚨 Issue 3: Network Connectivity Problems

## ✅ Solution

```yaml
- name: Wait for network
  wait_for:
    host: "8.8.8.8"
    port: 53
    timeout: 120
```

---

# 🚨 Issue 4: SSH Connection Problems

## ✅ Solution

```yaml
- name: Custom SSH test
  reboot:
    test_command: "ssh {{ ansible_user }}@{{ ansible_host }} 'echo SSH_OK'"
    connect_timeout: 30
```

---

# 🏆 Best Practices Summary

✅ Use serial execution for critical systems  
✅ Implement retry logic and fallback procedures  
✅ Validate services before and after reboot  
✅ Maintain detailed logs  
✅ Test automation in staging first  
✅ Use maintenance windows  
✅ Implement health checks  
✅ Prepare rollback procedures  

---

# 🏁 Conclusion

In this lab, you successfully learned how to:

✅ Automate Linux system reboots with Ansible  
✅ Implement comprehensive validation workflows  
✅ Create advanced reboot error handling procedures  
✅ Perform rolling and scheduled maintenance reboots  
✅ Validate services and infrastructure health post-reboot  

These techniques are essential for maintaining enterprise infrastructure where manual reboot procedures are not scalable.

The automation strategies demonstrated here provide a strong foundation for:

- 🏢 Enterprise Infrastructure Maintenance
- 🔐 Security Patch Management
- ⚡ Operational Continuity
- 🚀 DevOps Automation Pipelines
- ☁️ Large-Scale Linux Administration

---

<div align="center">

# ⭐ Happy Automating & System Maintenance! ⭐

### 🚀 Master Enterprise Reboot Automation with Ansible

</div>
