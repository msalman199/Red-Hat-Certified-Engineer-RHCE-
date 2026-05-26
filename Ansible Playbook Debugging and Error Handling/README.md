# 🔧 Ansible Playbook Debugging and Error Handling

![Playbook](https://img.shields.io/badge/Playbook-1A1918?style=for-the-badge&logo=ansible&logoColor=white)
![Infrastructure Automation](https://img.shields.io/badge/Infrastructure_Automation-0052CC?style=for-the-badge&logo=ansible&logoColor=white)
![Server Management](https://img.shields.io/badge/Server_Management-1976D2?style=for-the-badge&logo=serverfault&logoColor=white)
![Ansible](https://img.shields.io/badge/Ansible-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Ansible Playbook](https://img.shields.io/badge/Ansible_Playbook-1A1918?style=for-the-badge&logo=ansible&logoColor=white)
![YAML](https://img.shields.io/badge/YAML-CB171E?style=for-the-badge&logo=yaml&logoColor=white)
![Automation](https://img.shields.io/badge/Automation-00C853?style=for-the-badge&logo=githubactions&logoColor=white)
![CI/CD](https://img.shields.io/badge/CI/CD-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)
![DevOps](https://img.shields.io/badge/DevOps-0A0FFF?style=for-the-badge&logo=azuredevops&logoColor=white)
![Debugging](https://img.shields.io/badge/Debugging-FF9800?style=for-the-badge&logo=bugatti&logoColor=white)
![Troubleshooting](https://img.shields.io/badge/Troubleshooting-607D8B?style=for-the-badge&logo=linux&logoColor=white)
![Error Handling](https://img.shields.io/badge/Error_Handling-D32F2F?style=for-the-badge&logo=sentry&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Ansible](https://img.shields.io/badge/Ansible-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
## 📌 Objectives

By the end of this lab, you will be able to:

- ✅ Implement debug and fail modules to capture output and handle errors in Ansible playbooks
- ✅ Use check_mode to perform dry runs and validate playbook execution without making changes
- ✅ Learn how to handle errors gracefully using block and rescue constructs
- ✅ Troubleshoot common Ansible playbook issues using built-in debugging features
- ✅ Apply error handling best practices in production Ansible environments

---

# 🧰 Prerequisites

Before starting this lab, you should have:

- 🐧 Basic understanding of Ansible concepts (playbooks, tasks, modules)
- 📄 Familiarity with YAML syntax
- ⚙️ Experience writing and running simple Ansible playbooks
- 💻 Knowledge of Linux command line operations
- 🔐 Understanding of SSH key-based authentication

---

# ☁️ Lab Environment Setup

## 🖥️ Ready-to-Use Cloud Machines

Al Nafi provides Linux-based cloud machines for this lab. Simply click **Start Lab** to access your pre-configured environment.

### 🏗️ Your lab environment includes:

| Component | Description |
|---|---|
| 🎛️ Control Node | CentOS/RHEL 8 with Ansible pre-installed |
| 🖧 Managed Nodes | Two target servers (node1 and node2) |
| 🔑 SSH Setup | Pre-configured SSH keys and inventory files |

---

# 📘 Task 1: Implement Debug and Fail Modules

---

# 🔹 Subtask 1.1: Understanding the Debug Module

The `debug` module helps troubleshoot playbooks by displaying variable values and messages.

## 📂 Create Working Directory

```bash
cd /home/ansible
mkdir lab12-debugging
cd lab12-debugging
```

---

## 📝 Create Debug Playbook

```bash
cat > debug_basics.yml << 'EOF'
---
- name: Debug Module Basics
  hosts: localhost
  gather_facts: yes
  vars:
    custom_message: "Hello from Ansible debugging lab"
    server_count: 3

  tasks:
    - name: Display a simple debug message
      debug:
        msg: "This is a basic debug message"

    - name: Display variable content
      debug:
        var: custom_message

    - name: Display multiple variables
      debug:
        msg: "Server count is {{ server_count }} and message is {{ custom_message }}"

    - name: Display system facts
      debug:
        var: ansible_hostname

    - name: Display facts with custom formatting
      debug:
        msg: "Running on {{ ansible_hostname }} with {{ ansible_processor_cores }} CPU cores"
EOF
```

---

## ▶️ Run the Playbook

```bash
ansible-playbook debug_basics.yml
```

---

# 🔹 Subtask 1.2: Advanced Debug Techniques

## 📝 Create Advanced Debug Playbook

```bash
cat > advanced_debug.yml << 'EOF'
---
- name: Advanced Debug Techniques
  hosts: localhost
  gather_facts: yes
  vars:
    debug_mode: true
    environment: "development"
    services:
      - name: "web"
        port: 80
        status: "running"
      - name: "database"
        port: 3306
        status: "stopped"

  tasks:
    - name: Debug only when debug_mode is enabled
      debug:
        msg: "Debug mode is active - Environment: {{ environment }}"
      when: debug_mode

    - name: Display complex data structures
      debug:
        var: services

    - name: Loop through services with debug
      debug:
        msg: "Service {{ item.name }} on port {{ item.port }} is {{ item.status }}"
      loop: "{{ services }}"

    - name: Debug with verbosity levels
      debug:
        msg: "This message appears only with -v flag"
        verbosity: 1

    - name: Debug with higher verbosity
      debug:
        msg: "This message appears only with -vv flag"
        verbosity: 2
EOF
```

---

## ▶️ Run with Different Verbosity Levels

### 🔹 Normal Run

```bash
ansible-playbook advanced_debug.yml
```

### 🔹 Verbose Mode

```bash
ansible-playbook advanced_debug.yml -v
```

### 🔹 Higher Verbosity

```bash
ansible-playbook advanced_debug.yml -vv
```

---

# 🔹 Subtask 1.3: Implementing the Fail Module

## 📝 Create Fail Module Playbook

```bash
cat > fail_module.yml << 'EOF'
---
- name: Fail Module Implementation
  hosts: localhost
  gather_facts: yes
  vars:
    required_memory_gb: 4
    max_cpu_usage: 80

  tasks:
    - name: Check if system has enough memory
      fail:
        msg: "System has insufficient memory. Required: {{ required_memory_gb }}GB"
      when: (ansible_memtotal_mb / 1024) < required_memory_gb

    - name: Validate environment variable
      fail:
        msg: "ENVIRONMENT variable must be set to 'production' or 'development'"
      when:
        - ansible_env.ENVIRONMENT is defined
        - ansible_env.ENVIRONMENT not in ['production', 'development']

    - name: Check for required packages (simulation)
      set_fact:
        package_installed: false

    - name: Fail if required package is missing
      fail:
        msg: "Critical package is not installed. Please install before proceeding."
      when: not package_installed

    - name: This task won't execute due to previous failure
      debug:
        msg: "This message should not appear"
EOF
```

---

## ▶️ Execute the Playbook

```bash
ansible-playbook fail_module.yml
```

---

# 🔹 Conditional Fail Example

```bash
cat > conditional_fail.yml << 'EOF'
---
- name: Conditional Fail Examples
  hosts: localhost
  vars:
    app_version: "1.2.3"
    min_version: "1.3.0"
    user_role: "admin"

  tasks:
    - name: Version check with custom failure
      block:
        - name: Compare versions
          set_fact:
            version_check: "{{ app_version is version(min_version, '>=') }}"

        - name: Fail if version is too old
          fail:
            msg: |
              Application version {{ app_version }} is below minimum required version {{ min_version }}.
              Please upgrade before continuing.
          when: not version_check

    - name: Role-based access control
      fail:
        msg: "Access denied. Only admin users can perform this operation."
      when: user_role != "admin"

    - name: Success message
      debug:
        msg: "All validation checks passed successfully!"
EOF
```

---

## ▶️ Test Conditional Fail

```bash
ansible-playbook conditional_fail.yml
```

---

# 📘 Task 2: Use Check Mode for Dry Runs

---

# 🔹 Subtask 2.1: Understanding Check Mode

Check mode lets you preview changes without applying them.

---

## 📝 Create System Changes Playbook

```bash
cat > system_changes.yml << 'EOF'
---
- name: System Configuration Changes
  hosts: node1
  become: yes

  tasks:
    - name: Install a package
      yum:
        name: htop
        state: present

    - name: Create a configuration file
      copy:
        content: |
          # Application Configuration
          debug_mode=true
          log_level=info
          max_connections=100
        dest: /etc/myapp.conf
        mode: '0644'

    - name: Create a system user
      user:
        name: appuser
        system: yes
        shell: /bin/bash
        home: /opt/appuser

    - name: Start and enable a service
      systemd:
        name: chronyd
        state: started
        enabled: yes

    - name: Display completion message
      debug:
        msg: "System configuration completed successfully"
EOF
```

---

## ▶️ Run in Check Mode

```bash
ansible-playbook system_changes.yml --check
```

---

## ▶️ Run with Diff Output

```bash
ansible-playbook system_changes.yml --check --diff
```

---

## ▶️ Execute Normally

```bash
ansible-playbook system_changes.yml
```

---

# 🔹 Subtask 2.2: Check Mode Awareness

## 📝 Create Check Mode Aware Playbook

```bash
cat > check_mode_aware.yml << 'EOF'
---
- name: Check Mode Aware Playbook
  hosts: localhost

  tasks:
    - name: Display mode information
      debug:
        msg: "Running in {{ 'CHECK' if ansible_check_mode else 'NORMAL' }} mode"

    - name: Task that behaves differently in check mode
      debug:
        msg: "This would create a backup file"
      when: ansible_check_mode

    - name: Actual file creation (skipped in check mode)
      copy:
        content: "Production data"
        dest: /tmp/production_file.txt
      when: not ansible_check_mode

    - name: Always run this task regardless of mode
      debug:
        msg: "This task always runs"
      check_mode: no

    - name: Never run this task in check mode
      debug:
        msg: "This only runs in normal mode"
      check_mode: no
      when: not ansible_check_mode
EOF
```

---

## ▶️ Test Check Mode

```bash
ansible-playbook check_mode_aware.yml --check
```

```bash
ansible-playbook check_mode_aware.yml
```

---

# 📘 Task 3: Error Handling with Block and Rescue

---

# 🔹 Subtask 3.1: Basic Block and Rescue

## 📝 Create Error Handling Playbook

```bash
cat > basic_error_handling.yml << 'EOF'
---
- name: Basic Error Handling with Block and Rescue
  hosts: localhost

  tasks:
    - name: Error handling example
      block:
        - name: Task that might fail
          command: /bin/false
          register: result

        - name: This won't execute due to previous failure
          debug:
            msg: "This message won't appear"

      rescue:
        - name: Handle the error
          debug:
            msg: "An error occurred, but we're handling it gracefully"

        - name: Log error details
          debug:
            msg: "Error handling activated for failed task"

      always:
        - name: This always runs
          debug:
            msg: "Cleanup or final actions go here"

    - name: Continue with next task
      debug:
        msg: "Playbook continues after error handling"
EOF
```

---

## ▶️ Run the Playbook

```bash
ansible-playbook basic_error_handling.yml
```

---

# 🔹 Subtask 3.2: Advanced Error Handling

## 📝 Create Advanced Error Handling Playbook

```bash
cat > advanced_error_handling.yml << 'EOF'
---
- name: Advanced Error Handling Scenarios
  hosts: localhost
  vars:
    retry_count: 3

  tasks:
    - name: File operations with error handling
      block:
        - name: Attempt to read a non-existent file
          slurp:
            src: /tmp/nonexistent_file.txt
          register: file_content

      rescue:
        - name: Handle file not found error
          debug:
            msg: "File not found, creating default file"

        - name: Create the missing file
          copy:
            content: "Default configuration content"
            dest: /tmp/nonexistent_file.txt

      always:
        - name: Cleanup temporary files
          file:
            path: /tmp/nonexistent_file.txt
            state: absent
EOF
```

---

## ▶️ Execute the Playbook

```bash
ansible-playbook advanced_error_handling.yml
```

---

# 🔹 Subtask 3.3: Nested Error Handling

## 📝 Create Nested Error Handling Playbook

```bash
cat > nested_error_handling.yml << 'EOF'
---
- name: Nested Error Handling and Recovery
  hosts: localhost

  tasks:
    - name: Multi-level error handling
      block:
        - name: Attempt primary method
          command: /usr/bin/nonexistent-command

      rescue:
        - name: Primary method failed
          debug:
            msg: "Primary method failed, attempting fallback"

        - name: Fallback operation
          debug:
            msg: "Executing fallback procedure"

      always:
        - name: Report completion
          debug:
            msg: "Recovery process completed"
EOF
```

---

## ▶️ Execute Nested Error Handling

```bash
ansible-playbook nested_error_handling.yml
```

---

# 🔹 Subtask 3.4: Practical Error Handling Example

## 📝 Create Practical Scenario

```bash
cat > practical_error_handling.yml << 'EOF'
---
- name: Practical Error Handling - Web Server Setup
  hosts: node1
  become: yes

  tasks:
    - name: Web server installation with fallback
      block:
        - name: Install Apache
          yum:
            name: httpd
            state: present

        - name: Start Apache
          systemd:
            name: httpd
            state: started
            enabled: yes

      rescue:
        - name: Apache failed, fallback to Nginx
          debug:
            msg: "Apache installation failed, switching to Nginx"

        - name: Install Nginx
          yum:
            name: nginx
            state: present

        - name: Start Nginx
          systemd:
            name: nginx
            state: started
            enabled: yes

      always:
        - name: Display completion status
          debug:
            msg: "Web server deployment completed"
EOF
```

---

## ▶️ Execute Practical Example

```bash
ansible-playbook practical_error_handling.yml
```

---

# 📘 Troubleshooting Common Issues

---

# 🐞 Variable Undefined Errors

```yaml
- debug:
    msg: "{{ undefined_var | default('Default value used') }}"
```

---

# 🔁 Loop Debugging Example

```yaml
- debug:
    msg: "Processing {{ item.name }}"
  loop: "{{ items_list }}"
```

---

# 📘 Validation Checklist

## 📝 Create Validation Playbook

```bash
cat > lab_validation.yml << 'EOF'
---
- name: Lab 12 Validation Checklist
  hosts: localhost

  tasks:
    - name: Test Debug Module
      debug:
        msg: "✓ Debug module working correctly"

    - name: Test Variable Display
      debug:
        var: ansible_hostname

    - name: Test Conditional Debug
      debug:
        msg: "✓ Conditional debug working"
      when: true

    - name: Test Check Mode Awareness
      debug:
        msg: "Running in {{ 'CHECK' if ansible_check_mode else 'NORMAL' }} mode"

    - name: Test Error Handling
      block:
        - name: Simulated task
          debug:
            msg: "✓ Block executed successfully"

      always:
        - name: Always validation
          debug:
            msg: "✓ Always block executed correctly"

    - name: Final Validation Message
      debug:
        msg: |
          ✓ Lab 12 Validation Complete
          All debugging and error handling features tested successfully!
EOF
```

---

## ▶️ Run Validation

### 🔹 Normal Validation

```bash
ansible-playbook lab_validation.yml
```

### 🔹 Check Mode Validation

```bash
ansible-playbook lab_validation.yml --check
```

---

# ✅ Conclusion

Congratulations! You have successfully completed the lab on:

# 🎯 Ansible Playbook Debugging and Error Handling

## 🏆 Key Achievements

- ✅ Mastered the `debug` module
- ✅ Implemented the `fail` module
- ✅ Learned dry runs with `--check`
- ✅ Used `block`, `rescue`, and `always`
- ✅ Built production-ready error handling workflows
- ✅ Practiced real-world troubleshooting techniques

---

# 🚀 Why These Skills Matter

These techniques are essential for:

- 🔒 Safer automation
- ⚡ Faster troubleshooting
- 🧩 Better reliability
- 🏢 Enterprise-grade Ansible deployments
- 🎓 RHCE certification preparation

---

# 📚 Best Practices Summary

| Best Practice | Purpose |
|---|---|
| ✅ Use debug extensively | Easier troubleshooting |
| ✅ Validate variables early | Prevent unexpected failures |
| ✅ Use check mode | Safe dry runs |
| ✅ Implement rescue blocks | Graceful recovery |
| ✅ Use always blocks | Cleanup and reporting |
| ✅ Test in staging first | Avoid production issues |

---

# 🎉 Lab Complete

You now have a strong foundation in:

- 🛠️ Ansible troubleshooting
- 🚨 Error handling
- 🧪 Dry-run validation
- 🔍 Debugging production playbooks

These are critical skills for modern Infrastructure Automation and DevOps engineering.

---
