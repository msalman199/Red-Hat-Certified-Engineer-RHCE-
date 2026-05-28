# Validating System Configurations with Ansible

---

## 🎯 Objectives

By the end of this lab, you will be able to:

✨ Use Ansible facts to gather and validate system information  
✨ Implement assertions to check configuration consistency across multiple hosts  
✨ Create playbooks that validate disk usage and system configurations  
✨ Implement proper error handling for configuration discrepancies  
✨ Generate reports for configuration validation results  
✨ Apply best practices for infrastructure validation using Ansible  

---

## 📌 Prerequisites

Before starting this lab, you should have:

🧠 Basic understanding of Linux command line operations  
🧠 Familiarity with YAML syntax and structure  
🧠 Previous experience with Ansible playbooks and modules  
🧠 Understanding of system administration concepts (disk usage, services, configurations)  
🧠 Knowledge of Jinja2 templating basics  

---

## 🏗️ Lab Environment Setup

### ☁️ Ready-to-Use Cloud Machines
Al Nafi provides pre-configured Linux-based cloud machines for this lab. Simply click **Start Lab** to access your environment — no need to build your own VM or install software.

### 💻 Your lab environment includes:
- 🖥️ Control Node: CentOS/RHEL 8 with Ansible pre-installed  
- 🖧 Managed Nodes: 3 target servers (node1, node2, node3)  
- ⚙️ All necessary tools and dependencies pre-configured  

---

# 📘 Task 1: Validate Disk Usage with Ansible Facts

---

## 🔍 Subtask 1.1: Understanding Ansible Facts

### 📂 Setup working directory
```bash
cd /home/ansible
mkdir lab14-validation
cd lab14-validation
📝 Create fact-gathering playbook
nano gather-facts.yml
---
- name: Gather and Display Disk Facts
  hosts: all
  gather_facts: yes

  tasks:
    - name: Display all disk-related facts
      debug:
        msg: |
          Hostname: {{ ansible_hostname }}
          Total Memory: {{ ansible_memtotal_mb }} MB
          Available Disk Space: {{ ansible_mounts }}
          Architecture: {{ ansible_architecture }}
          OS Family: {{ ansible_os_family }}

    - name: Show specific mount point information
      debug:
        msg: |
          Mount Point: {{ item.mount }}
          Device: {{ item.device }}
          Filesystem: {{ item.fstype }}
          Size: {{ item.size_total | human_readable }}
          Available: {{ item.size_available | human_readable }}
          Used: {{ ((item.size_total - item.size_available) / item.size_total * 100) | round(2) }}%
      loop: "{{ ansible_mounts }}"
      when: item.mount == "/"
▶️ Run playbook
ansible-playbook -i inventory gather-facts.yml
📊 Subtask 1.2: Disk Usage Validation Playbook
📝 Create playbook
nano validate-disk-usage.yml
---
- name: Validate System Disk Usage
  hosts: all
  gather_facts: yes

  vars:
    disk_usage_warning_threshold: 80
    disk_usage_critical_threshold: 90
    minimum_free_space_gb: 2

  tasks:
    - name: Initialize validation results
      set_fact:
        validation_results: []
        failed_validations: []

    - name: Validate root filesystem disk usage
      block:

        - name: Get root mount info
          set_fact:
            root_mount_info: "{{ ansible_mounts | selectattr('mount', 'equalto', '/') | first }}"

        - name: Calculate usage
          set_fact:
            root_usage_percent: "{{ ((root_mount_info.size_total - root_mount_info.size_available) / root_mount_info.size_total * 100) | round(2) }}"
            root_free_gb: "{{ (root_mount_info.size_available / 1024 / 1024 / 1024) | round(2) }}"

        - name: Add validation result
          set_fact:
            validation_results: "{{ validation_results + [validation_item] }}"
          vars:
            validation_item:
              host: "{{ ansible_hostname }}"
              check: "Root Disk Usage"
              status: "{{ 'CRITICAL' if (root_usage_percent|float) > disk_usage_critical_threshold else ('WARNING' if (root_usage_percent|float) > disk_usage_warning_threshold else 'OK') }}"
              value: "{{ root_usage_percent }}%"
              free_space: "{{ root_free_gb }} GB"

        - name: Fail on critical usage
          fail:
            msg: "CRITICAL Disk usage {{ root_usage_percent }}%"
          when: (root_usage_percent|float) > disk_usage_critical_threshold

        - name: Warn on high usage
          debug:
            msg: "WARNING Disk usage {{ root_usage_percent }}%"
          when:
            - (root_usage_percent|float) > disk_usage_warning_threshold
            - (root_usage_percent|float) <= disk_usage_critical_threshold

        - name: Fail if low free space
          fail:
            msg: "Low free space {{ root_free_gb }} GB"
          when: (root_free_gb|float) < minimum_free_space_gb

      rescue:
        - name: Record failure
          set_fact:
            failed_validations: "{{ failed_validations + [ansible_failed_result.msg] }}"
📄 Inventory file
[webservers]
node1 ansible_host=10.0.1.10
node2 ansible_host=10.0.1.11

[databases]
node3 ansible_host=10.0.1.12

[all:vars]
ansible_user=ansible
ansible_ssh_private_key_file=/home/ansible/.ssh/id_rsa
▶️ Run playbook
ansible-playbook -i inventory validate-disk-usage.yml
📘 Task 2: Assertions for Configuration Consistency
🧩 Subtask 2.1: Configuration Consistency
nano validate-config-consistency.yml
---
- name: Validate Configuration Consistency Across Hosts
  hosts: all
  gather_facts: yes

  vars:
    expected_os_family: "RedHat"
    minimum_memory_mb: 1024
    required_services:
      - sshd
      - chronyd
    minimum_cpu_cores: 1

  tasks:
    - name: Initialize results
      set_fact:
        consistency_results: []
        assertion_failures: []

    - name: OS validation
      block:
        - assert:
            that:
              - ansible_os_family == expected_os_family
            fail_msg: "OS mismatch"
            success_msg: "OS OK"

    - name: Memory validation
      block:
        - assert:
            that:
              - ansible_memtotal_mb >= minimum_memory_mb
            fail_msg: "Low memory"
            success_msg: "Memory OK"

    - name: CPU validation
      block:
        - assert:
            that:
              - ansible_processor_vcpus >= minimum_cpu_cores
            fail_msg: "Low CPU"
            success_msg: "CPU OK"
⚙️ Subtask 2.2: Advanced Assertions
nano advanced-assertions.yml
---
- name: Advanced Configuration Assertions
  hosts: all
  gather_facts: yes

  tasks:

    - name: Check SSH config
      stat:
        path: /etc/ssh/sshd_config
      register: ssh_stat

    - name: Assert SSH config exists
      assert:
        that:
          - ssh_stat.stat.exists

    - name: Load SSH config
      slurp:
        src: /etc/ssh/sshd_config
      register: ssh_content

    - name: Parse SSH config
      set_fact:
        ssh_lines: "{{ (ssh_content.content | b64decode).split('\n') }}"

    - name: Validate root login disabled
      assert:
        that:
          - ssh_lines | select('match', '^PermitRootLogin\\s+no') | list | length > 0
📘 Task 3: Error Handling & Reporting
📊 Validation with Reporting
nano validation-with-reporting.yml
---
- name: System Validation with Reporting
  hosts: all
  gather_facts: yes

  vars:
    report_directory: "/tmp/ansible-validation-reports"

  tasks:

    - name: Init counters
      set_fact:
        total_checks: 0
        passed_checks: 0
        failed_checks: 0

    - name: Create report directory
      file:
        path: "{{ report_directory }}"
        state: directory
      delegate_to: localhost
      run_once: true

    - name: Disk check
      block:

        - set_fact:
            total_checks: "{{ total_checks|int + 1 }}"

        - set_fact:
            disk_usage: 75

        - assert:
            that:
              - disk_usage < 90

        - set_fact:
            passed_checks: "{{ passed_checks|int + 1 }}"

      rescue:
        - set_fact:
            failed_checks: "{{ failed_checks|int + 1 }}"

    - name: Final summary
      debug:
        msg: |
          Total: {{ total_checks }}
          Passed: {{ passed_checks }}
          Failed: {{ failed_checks }}
🎉 End of Lab
