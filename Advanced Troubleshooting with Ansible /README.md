# 🚀 Advanced Troubleshooting with Ansible

<p align="center">
  <img src="https://img.shields.io/badge/Automation-Ansible-red?style=for-the-badge&logo=ansible">
  <img src="https://img.shields.io/badge/Linux-RHEL%208-blue?style=for-the-badge&logo=redhat">
  <img src="https://img.shields.io/badge/Scripting-Bash-black?style=for-the-badge&logo=gnubash">
  <img src="https://img.shields.io/badge/Infrastructure-DevOps-green?style=for-the-badge&logo=linux">
  <img src="https://img.shields.io/badge/Debugging-Troubleshooting-orange?style=for-the-badge&logo=bugatti">
  <img src="https://img.shields.io/badge/YAML-Playbooks-yellow?style=for-the-badge&logo=yaml">
</p>

---

# 📘 Overview

This lab provides hands-on experience with **Advanced Troubleshooting in Ansible**.  
You will learn enterprise-level debugging strategies, dry-run analysis, service troubleshooting, log monitoring, and systematic debugging methodologies for large-scale automation deployments.

---

# 🎯 Objectives

By the end of this lab, you will be able to:

✅ Master advanced debugging techniques using Ansible troubleshooting tools  
✅ Implement step-by-step execution for complex playbooks  
✅ Perform differential analysis using `--diff`  
✅ Run safe dry-run deployments using `--check`  
✅ Troubleshoot services using system logs  
✅ Analyze failures in enterprise environments  
✅ Apply systematic debugging methodologies  

---

# 🧰 Prerequisites

Before starting this lab, ensure you have:

- Basic knowledge of Ansible Playbooks
- Understanding of YAML syntax
- Linux command-line experience
- Familiarity with systemd services
- Knowledge of logs and troubleshooting
- Experience with Ansible inventory/configuration files

---

# ☁️ Lab Environment Setup

## 🖥️ Environment Includes

| Component | Description |
|----------|-------------|
| 🎛️ Control Node | CentOS/RHEL 8 with Ansible installed |
| 🌐 Managed Nodes | web1, web2, db1 |
| 🔐 Authentication | Pre-configured SSH Keys |
| 📂 Practice Files | Broken playbooks for troubleshooting |

---

# 📁 Setup Working Directory

## ✨ Verify Installation

```bash
ansible --version
```

## 📂 Create Lab Directory

```bash
mkdir -p ~/ansible-troubleshooting-lab
cd ~/ansible-troubleshooting-lab
```

## 🔗 Verify Connectivity

```bash
ansible all -m ping
```

---

# 🧪 Task 1 — Advanced Debugging with Step-by-Step Execution

# 🔹 Subtask 1.1 — Create Complex Deployment Playbook

## 📄 Create Playbook

```bash
cat > complex-deployment.yml << 'EOF'
---
- name: Complex Web Application Deployment
  hosts: web_servers
  become: yes

  vars:
    app_name: "mywebapp"
    app_version: "2.1.0"
    web_port: 8080

  tasks:

    - name: Install required packages
      yum:
        name:
          - httpd
          - php
          - php-mysql
          - wget
          - unzip
        state: present

    - name: Create application directory
      file:
        path: "/opt/{{ app_name }}"
        state: directory
        owner: apache
        group: apache
        mode: '0755'

    - name: Start Apache
      systemd:
        name: httpd
        state: started
        enabled: yes
EOF
```

---

# 🔹 Subtask 1.2 — Create Template Directory

```bash
mkdir -p templates
```

## 📄 Create Virtual Host Template

```bash
cat > templates/vhost.conf.j2 << 'EOF'
<VirtualHost *:8080>
    ServerName localhost
    DocumentRoot /opt/mywebapp/public
</VirtualHost>
EOF
```

---

# 🔹 Subtask 1.3 — Step-by-Step Debugging

## 🛠️ Run Playbook with Step Mode

```bash
ansible-playbook complex-deployment.yml --step
```

### 📌 Options

| Option | Description |
|-------|-------------|
| y | Execute task |
| n | Skip task |
| c | Continue all tasks |

---

# 🔹 Subtask 1.4 — Debug Using Tags

## 📦 Execute Package Tasks Only

```bash
ansible-playbook complex-deployment.yml --step --tags packages
```

## ⚙️ Execute Configuration Tasks

```bash
ansible-playbook complex-deployment.yml --step --tags configuration
```

---

# 🔍 Task 2 — Differential Analysis & Change Detection

# 🔹 Subtask 2.1 — Using `--diff`

## 📄 View File Changes

```bash
ansible-playbook complex-deployment.yml --diff
```

## 🛡️ Safe Analysis

```bash
ansible-playbook complex-deployment.yml --diff --check
```

---

# 🔹 Subtask 2.2 — Modify Template for Diff Testing

## ✏️ Update Template

```bash
cat > templates/vhost.conf.j2 << 'EOF'
<VirtualHost *:8080>

    ServerName localhost
    DocumentRoot /opt/mywebapp/public

    <Directory /opt/mywebapp/public>
        AllowOverride All
        Require all granted
        Options -Indexes +FollowSymLinks
    </Directory>

    LogLevel warn

</VirtualHost>
EOF
```

---

# 🔹 Subtask 2.3 — Analyze Diff Output

## 📜 Create Diff Analysis Script

```bash
cat > analyze-changes.sh << 'EOF'
#!/bin/bash

PLAYBOOK="$1"

echo "=== Running Diff Analysis ==="

ansible-playbook "$PLAYBOOK" --diff --check

echo "=== Analysis Complete ==="
EOF
```

## 🔐 Make Executable

```bash
chmod +x analyze-changes.sh
```

## ▶️ Run Script

```bash
./analyze-changes.sh complex-deployment.yml
```

---

# 🛡️ Task 3 — Comprehensive Dry-Run Testing

# 🔹 Subtask 3.1 — Basic Check Mode

## 🧪 Dry Run

```bash
ansible-playbook complex-deployment.yml --check
```

## 🔎 Verbose Dry Run

```bash
ansible-playbook complex-deployment.yml --check -vvv
```

---

# 🔹 Subtask 3.2 — Pre-Flight Checks

## 📄 Create Preflight Playbook

```bash
cat > preflight-checks.yml << 'EOF'
---
- name: Pre-flight Checks
  hosts: all

  tasks:

    - name: Check disk space
      shell: df -h /

    - name: Check memory
      shell: free -m

    - name: Display system info
      debug:
        msg: "System checks completed"
EOF
```

## ▶️ Execute Checks

```bash
ansible-playbook preflight-checks.yml
```

---

# 🔹 Subtask 3.3 — Conditional Deployment

## 📄 Conditional Playbook

```bash
cat > conditional-deployment.yml << 'EOF'
---
- name: Conditional Deployment
  hosts: web_servers

  tasks:

    - name: Display deployment mode
      debug:
        msg: "Running in check mode"

EOF
```

## 🧪 Run Check Mode

```bash
ansible-playbook conditional-deployment.yml --check
```

---

# 📊 Task 4 — Service Troubleshooting Using Logs

# 🔹 Subtask 4.1 — Service Monitoring Playbook

## 📄 Create Monitoring Playbook

```bash
cat > service-troubleshooting.yml << 'EOF'
---
- name: Service Troubleshooting
  hosts: all

  tasks:

    - name: Check Apache Service
      systemd:
        name: httpd

    - name: Check MySQL Service
      systemd:
        name: mysqld
EOF
```

## ▶️ Execute Troubleshooting

```bash
ansible-playbook service-troubleshooting.yml
```

---

# 🔹 Subtask 4.2 — Log Analysis

## 📄 Create Log Analysis Playbook

```bash
cat > log-analysis.yml << 'EOF'
---
- name: Log Analysis
  hosts: all

  tasks:

    - name: Check system logs
      shell: tail -50 /var/log/messages
EOF
```

## ▶️ Run Analysis

```bash
ansible-playbook log-analysis.yml
```

---

# 🔹 Subtask 4.3 — Real-Time Monitoring

## 📄 Create Monitoring Playbook

```bash
cat > realtime-monitoring.yml << 'EOF'
---
- name: Real-time Monitoring
  hosts: all

  tasks:

    - name: Install multitail
      yum:
        name: multitail
        state: present
EOF
```

## ▶️ Execute Monitoring Setup

```bash
ansible-playbook realtime-monitoring.yml
```

---

# 🚨 Task 5 — Troubleshooting Practice Scenarios

# 🔹 Subtask 5.1 — Create Problematic Playbook

## 📄 Intentional Errors

```bash
cat > problematic-playbook.yml << 'EOF'
---
- name: Broken Playbook
  hosts: web_servers

  vars:
    app_name: "{{ undefined_variable }}"

  tasks:

    - name: Install invalid package
      yum:
        name: php-mysqll
        state: present
EOF
```

---

# 🔹 Subtask 5.2 — Troubleshooting Methodology Script

## 📄 Create Troubleshooting Script

```bash
cat > troubleshoot-playbook.sh << 'EOF'
#!/bin/bash

PLAYBOOK="$1"

echo "=== TROUBLESHOOTING PLAYBOOK ==="

echo "Step 1: Syntax Check"
ansible-playbook "$PLAYBOOK" --syntax-check

echo "Step 2: Dry Run"
ansible-playbook "$PLAYBOOK" --check

echo "Step 3: Verbose Mode"
ansible-playbook "$PLAYBOOK" -vvv

echo "=== COMPLETE ==="
EOF
```

## 🔐 Make Script Executable

```bash
chmod +x troubleshoot-playbook.sh
```

## ▶️ Run Troubleshooting

```bash
./troubleshoot-playbook.sh problematic-playbook.yml
```

---

# 📚 Important Ansible Debugging Commands

| Command | Purpose |
|---------|----------|
| `--check` | Dry Run |
| `--diff` | Show file changes |
| `--step` | Execute step-by-step |
| `-v` | Verbose |
| `-vvv` | Maximum verbosity |
| `--syntax-check` | Validate playbook syntax |

---

# 🧠 Troubleshooting Best Practices

✅ Always run syntax checks first  
✅ Use `--check` before deployment  
✅ Use tags for targeted debugging  
✅ Enable verbose output for deeper analysis  
✅ Review logs carefully  
✅ Test changes in staging first  
✅ Keep backups before modifications  

---

# 📂 Project Structure

```bash
ansible-troubleshooting-lab/
├── complex-deployment.yml
├── conditional-deployment.yml
├── preflight-checks.yml
├── service-troubleshooting.yml
├── log-analysis.yml
├── realtime-monitoring.yml
├── problematic-playbook.yml
├── troubleshoot-playbook.sh
├── analyze-changes.sh
└── templates/
    └── vhost.conf.j2
```

---

# 🏆 Skills Gained

✔️ Advanced Ansible Debugging  
✔️ Enterprise Troubleshooting  
✔️ Log Analysis  
✔️ Dry-Run Testing  
✔️ Service Diagnostics  
✔️ Configuration Analysis  
✔️ Linux System Administration  

# ⭐ Support

If you found this project useful:

🌟 Star the repository  
🍴 Fork the project  
🛠️ Practice troubleshooting scenarios  
📘 Share with DevOps learners  


This project is for educational and learning purposes.

---
