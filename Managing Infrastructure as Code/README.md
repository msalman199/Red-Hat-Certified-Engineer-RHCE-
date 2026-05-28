# 🚀 Managing Infrastructure as Code (IaC) with Ansible

# 🏷️ Technology Badges

| Category              | Badge                        |
| --------------------- | ---------------------------- |
| 🐧 Operating System   | Linux                        |
| ⚙️ Automation         | Ansible                      |
| 📄 Configuration      | YAML                         |
| 🔧 Version Control    | Git                          |
| ☁️ Cloud Concept      | Infrastructure as Code (IaC) |
| 🧩 Templating         | Jinja2                       |
| 🌐 Web Server         | Apache                       |
| 🚀 Proxy Server       | Nginx                        |
| 🗄️ Database          | MySQL                        |
| 🔐 Security           | SSH / Firewall               |
| 🧪 Testing            | Ansible Check Mode           |
| 📦 Package Management | apt / yum                    |
| 🧰 DevOps             | CI/CD Practices              |

---

# 🎯 Lab Objectives

By the end of this lab, you will be able to:

✅ Understand Infrastructure as Code (IaC) principles
✅ Automate cloud resource deployment using Ansible
✅ Use variables and Jinja2 templates
✅ Apply Git version control for infrastructure
✅ Deploy cloud infrastructure using declarative code
✅ Troubleshoot IaC deployments

---

# 🛠️ Prerequisites

🔹 Linux command line basics
🔹 YAML knowledge
🔹 Cloud computing fundamentals
🔹 SSH authentication
🔹 Git basics
🔹 Text editor experience

---

# ☁️ Lab Environment Setup

## 🖥️ Ready-to-Use Cloud Machines

✔ Control node (Ansible installed)
✔ Target nodes (web, DB, LB)
✔ Git enabled environment
✔ SSH pre-configured

---

# 📘 Task 1: Infrastructure as Code Deployment

## 🔹 Subtask 1.1: IaC Concept Understanding

Infrastructure as Code (IaC) enables infrastructure provisioning using code instead of manual configuration.

---

## 🌟 Key Benefits

✔ Consistency
✔ Repeatability
✔ Version Control
✔ Automation

---

## 🧪 Subtask 1.2: Setup Environment

```bash
ansible --version
```

```bash
mkdir -p ~/iac-lab/{playbooks,inventory,group_vars,templates}
cd ~/iac-lab
```

---

## 📁 Inventory Setup

```yaml
all:
  children:
    webservers:
      hosts:
        web1:
          ansible_host: 192.168.1.10
```

---

## 🚀 Subtask 1.3: Infrastructure Playbook

```yaml
- name: Deploy Web Infrastructure
  hosts: all
  become: yes
```

---

## ☁️ Subtask 1.4: Cloud Simulation

```yaml
- name: Provision Cloud Infrastructure
  hosts: localhost
```

---

## 🧪 Testing Commands

```bash
ansible-playbook --syntax-check
ansible-playbook --check
ansible-playbook -v
```

---

# 📘 Task 2: Variables & Templates

---

## 🧩 Subtask 2.1: Group Variables

```yaml
project_name: "iac-demo"
environment: "production"
```

---

## 🧱 Subtask 2.2: Jinja2 Templates

### 🌐 Apache Template

```jinja2
<VirtualHost *:{{ web_server_port }}>
```

### 🚀 Nginx Template

```jinja2
upstream backend {
```

### 🗄️ MySQL Template

```jinja2
port = {{ db_port }}
```

---

## ⚙️ Subtask 2.3: Deployment Playbook

```yaml
- name: Deploy Infrastructure with Templates
  hosts: all
```

---

## 📄 Subtask 2.4: Server Info Template

```jinja2
Server Information Report
Project: {{ project_name }}
```

---

## 🌍 Application Template

```html
<h1>{{ app_name }} Running Successfully!</h1>
```

---

## 🧪 Testing

```bash
ansible-playbook -v
```

---

# 📘 Task 3: Version Control (Git)

---

## 🔧 Subtask 3.1: Initialize Git

```bash
git init
git add .
git commit -m "IaC setup"
```

---

## 🌿 Branching Strategy

✔ development
✔ feature branch
✔ hotfix branch

---

## 🏷️ Versioning

```bash
VERSION=1.0.0
```

---

## 🚀 Release Script

```bash
#!/bin/bash
echo "Release preparation"
```

---

# 🎉 Conclusion

## 🏆 Skills Gained

✔ IaC fundamentals
✔ Ansible automation
✔ YAML & Jinja2
✔ Git version control
✔ Cloud deployment concepts

---

# 🌟 Final DevOps Stack

🚀 Ansible + Git + Linux + YAML + Jinja2 + Cloud + CI/CD

---

# 👨‍💻 Lab Completed Successfully

🔥 Keep learning DevOps
⚙️ Keep automating infrastructure
☁️ Keep building cloud systems
