# 🔐 Applying SELinux Policies with Ansible

<div align="center">

![SELinux](https://img.shields.io/badge/SELinux-Security-red?style=for-the-badge&logo=redhat)
![Ansible](https://img.shields.io/badge/Automation-Ansible-black?style=for-the-badge&logo=ansible)
![Linux](https://img.shields.io/badge/Linux-RHEL%208%2F9-yellow?style=for-the-badge&logo=linux)
![RHCE](https://img.shields.io/badge/RHCE-Enterprise-blue?style=for-the-badge&logo=redhat)

# 🛡️ SELinux Automation with Ansible

### Secure Linux Systems Using Enterprise Automation

</div>

---

# 📚 Objectives

By the end of this lab, students will be able to:

✅ Understand SELinux fundamentals and security benefits  
✅ Automate SELinux policy management using Ansible  
✅ Configure SELinux enforcing mode programmatically  
✅ Modify SELinux file contexts using `semanage`  
✅ Implement automated SELinux policies for applications  
✅ Troubleshoot SELinux-related issues  
✅ Apply enterprise security best practices  

---

# 🧰 Prerequisites

Before starting this lab, students should have:

- Basic Linux administration knowledge
- Familiarity with Ansible fundamentals
- YAML syntax understanding
- File permissions knowledge
- Linux command-line experience
- Experience with text editors

---

# 🖥️ Lab Environment Setup

## 🌐 Environment Includes

- CentOS/RHEL 8 or 9 Systems
- SELinux Enabled Machines
- Ansible Pre-Installed
- Root Access
- Security Utilities Configured

---

# 📁 Create Lab Directory Structure

```bash
mkdir -p ~/selinux-lab
cd ~/selinux-lab

mkdir -p playbooks roles inventory
```

---

# 📄 Create Inventory File

```bash
cat > inventory/hosts << EOF
[selinux_servers]
localhost ansible_connection=local

[selinux_servers:vars]
ansible_python_interpreter=/usr/bin/python3
EOF
```

---

# 🔍 Task 1 — Understanding SELinux Basics

---

# 🛡️ Check Current SELinux Status

```bash
sestatus
```

```bash
getenforce
```

```bash
cat /etc/selinux/config
```

---

# ⚙️ Create SELinux Enforcing Playbook

## 📄 File: `playbooks/selinux-enforcing.yml`

```yaml
---
- name: Configure SELinux to Enforcing Mode
  hosts: selinux_servers
  become: yes

  vars:
    selinux_policy: targeted
    selinux_state: enforcing

  tasks:

    - name: Check current SELinux status
      command: sestatus
      register: selinux_status
      changed_when: false

    - name: Display current status
      debug:
        msg: "{{ selinux_status.stdout_lines }}"

    - name: Install SELinux packages
      package:
        name:
          - policycoreutils
          - policycoreutils-python-utils
          - selinux-policy
          - selinux-policy-targeted
          - setroubleshoot-server
          - setools-console
        state: present

    - name: Set SELinux enforcing mode
      selinux:
        policy: "{{ selinux_policy }}"
        state: "{{ selinux_state }}"
      register: selinux_change

    - name: Verify enforcing mode
      command: getenforce
      register: enforce_check
      changed_when: false

    - name: Display mode
      debug:
        msg: "SELinux Mode: {{ enforce_check.stdout }}"
```

---

# ▶️ Run the Playbook

```bash
ansible-playbook -i inventory/hosts playbooks/selinux-enforcing.yml
```

---

# ✅ Verify Changes

```bash
sestatus
```

```bash
getenforce
```

---

# 📂 Task 2 — Managing SELinux File Contexts

---

# 🔎 Check Existing File Contexts

```bash
ls -Z /var/www/html/
```

```bash
ls -Z /home/
```

```bash
semanage fcontext -l | head -20
```

---

# 📁 Create Test Directories

```bash
mkdir -p /opt/webapp

echo "<h1>Test Web Application</h1>" > /opt/webapp/index.html
```

---

# 🔍 Verify Current Context

```bash
ls -Z /opt/webapp/
```

---

# ⚙️ SELinux File Context Playbook

## 📄 File: `playbooks/selinux-file-contexts.yml`

```yaml
---
- name: Manage SELinux File Contexts
  hosts: selinux_servers
  become: yes

  vars:
    webapp_directory: /opt/webapp
    custom_app_directory: /opt/myapp

  tasks:

    - name: Create directories
      file:
        path: "{{ item }}"
        state: directory
        mode: '0755'
      loop:
        - "{{ webapp_directory }}"
        - "{{ custom_app_directory }}"
        - "{{ custom_app_directory }}/logs"
        - "{{ custom_app_directory }}/config"

    - name: Create web file
      copy:
        content: |
          <html>
          <body>
          <h1>Welcome to Web Application</h1>
          </body>
          </html>
        dest: "{{ webapp_directory }}/index.html"

    - name: Set web application context
      sefcontext:
        target: "{{ webapp_directory }}(/.*)?"
        setype: httpd_exec_t
        state: present

    - name: Set custom app context
      sefcontext:
        target: "{{ custom_app_directory }}(/.*)?"
        setype: admin_home_t
        state: present

    - name: Set logs context
      sefcontext:
        target: "{{ custom_app_directory }}/logs(/.*)?"
        setype: var_log_t
        state: present

    - name: Apply contexts
      command: restorecon -R {{ item }}
      loop:
        - "{{ webapp_directory }}"
        - "{{ custom_app_directory }}"

    - name: Verify contexts
      command: ls -Z {{ item }}
      loop:
        - "{{ webapp_directory }}"
        - "{{ custom_app_directory }}"
      register: verify_contexts

    - name: Display contexts
      debug:
        msg: "{{ item.stdout_lines }}"
      loop: "{{ verify_contexts.results }}"
```

---

# ▶️ Execute File Context Playbook

```bash
ansible-playbook -i inventory/hosts playbooks/selinux-file-contexts.yml
```

---

# 🔐 Task 3 — Managing SELinux Booleans

---

# ⚙️ SELinux Boolean Playbook

## 📄 File: `playbooks/selinux-booleans.yml`

```yaml
---
- name: Manage SELinux Booleans
  hosts: selinux_servers
  become: yes

  tasks:

    - name: Enable HTTP network access
      seboolean:
        name: httpd_can_network_connect
        state: yes
        persistent: yes

    - name: Enable HTTP DB access
      seboolean:
        name: httpd_can_network_connect_db
        state: yes
        persistent: yes

    - name: Enable FTP home directories
      seboolean:
        name: ftp_home_dir
        state: yes
        persistent: yes
      ignore_errors: yes

    - name: Verify booleans
      command: getsebool {{ item }}
      loop:
        - httpd_can_network_connect
        - httpd_can_network_connect_db
      register: verify_booleans

    - name: Show results
      debug:
        msg: "{{ item.stdout }}"
      loop: "{{ verify_booleans.results }}"
```

---

# ▶️ Run Boolean Playbook

```bash
ansible-playbook -i inventory/hosts playbooks/selinux-booleans.yml
```

---

# 🌐 Task 4 — Managing SELinux Ports

---

# ⚙️ SELinux Port Management Playbook

## 📄 File: `playbooks/selinux-ports.yml`

```yaml
---
- name: Manage SELinux Ports
  hosts: selinux_servers
  become: yes

  tasks:

    - name: Add HTTP Port 8080
      seport:
        ports: 8080
        proto: tcp
        setype: http_port_t
        state: present

    - name: Add SSH Port 2222
      seport:
        ports: 2222
        proto: tcp
        setype: ssh_port_t
        state: present

    - name: Add Custom Port Range
      seport:
        ports: 9000-9010
        proto: tcp
        setype: http_port_t
        state: present

    - name: Verify Ports
      command: semanage port -l | grep -E "(8080|2222|900)"
      register: port_check
      changed_when: false

    - name: Display Ports
      debug:
        msg: "{{ port_check.stdout_lines }}"
```

---

# ▶️ Execute Port Playbook

```bash
ansible-playbook -i inventory/hosts playbooks/selinux-ports.yml
```

---

# 🚀 Task 5 — Configure Complete Application SELinux Policies

---

# ⚙️ Application SELinux Configuration

## 📄 File: `playbooks/application-selinux-config.yml`

```yaml
---
- name: Complete Application SELinux Configuration
  hosts: selinux_servers
  become: yes

  vars:
    app_name: mywebapp
    app_directory: /opt/mywebapp
    app_port: 8081

  tasks:

    - name: Install Apache
      package:
        name:
          - httpd
          - mod_ssl
        state: present

    - name: Create application directories
      file:
        path: "{{ item }}"
        state: directory
        mode: '0755'
      loop:
        - "{{ app_directory }}"
        - "{{ app_directory }}/htdocs"
        - "{{ app_directory }}/logs"

    - name: Create application page
      copy:
        content: |
          <html>
          <body>
          <h1>Welcome to {{ app_name }}</h1>
          </body>
          </html>
        dest: "{{ app_directory }}/htdocs/index.html"

    - name: Set application contexts
      sefcontext:
        target: "{{ app_directory }}/htdocs(/.*)?"
        setype: httpd_exec_t
        state: present

    - name: Apply contexts
      command: restorecon -R {{ app_directory }}

    - name: Configure application port
      seport:
        ports: "{{ app_port }}"
        proto: tcp
        setype: http_port_t
        state: present

    - name: Enable HTTP network access
      seboolean:
        name: httpd_can_network_connect
        state: yes
        persistent: yes

    - name: Start Apache
      systemd:
        name: httpd
        state: started
        enabled: yes
```

---

# ▶️ Run Application Configuration

```bash
ansible-playbook -i inventory/hosts playbooks/application-selinux-config.yml
```

---

# 🧪 Verification Commands

## 🔍 Check SELinux Status

```bash
sestatus
```

```bash
getenforce
```

---

## 📂 List Custom File Contexts

```bash
semanage fcontext -l -C
```

---

## 🌐 List Custom Ports

```bash
semanage port -l -C
```

---

## ⚙️ List Modified Booleans

```bash
semanage boolean -l -C
```

---

## 🚨 Check SELinux Denials

```bash
ausearch -m avc -ts today
```

---

# 🛠️ Troubleshooting Common Issues

---

# ❌ Issue 1 — SELinux Denials

## 🔍 Check Audit Logs

```bash
ausearch -m avc -ts recent
```

## ⚙️ Generate Policy

```bash
ausearch -m avc -ts recent | audit2allow -M mypolicy
```

## 📦 Install Policy

```bash
semodule -i mypolicy.pp
```

---

# ❌ Issue 2 — File Context Not Applying

## 🔍 Verify Context Rule

```bash
semanage fcontext -l | grep /your/path
```

## 🔄 Restore Context

```bash
restorecon -R /your/path
```

---

# ❌ Issue 3 — Service Fails Due to SELinux

## 🔍 Check Booleans

```bash
getsebool -a | grep servicename
```

## ⚙️ Enable Boolean

```bash
setsebool -P boolean_name on
```

---

# 🔐 Best Practices

✅ Use persistent SELinux booleans  
✅ Test changes in permissive mode first  
✅ Monitor SELinux logs regularly  
✅ Backup configurations before changes  
✅ Use specific file contexts  
✅ Document custom policies  
✅ Apply least privilege principle  

---

# 📘 Key Takeaways

| Feature | Purpose |
|---|---|
| SELinux Enforcing Mode | Maximum system protection |
| File Contexts | Secure file labeling |
| SELinux Booleans | Fine-grained permissions |
| SELinux Ports | Secure network access |
| Ansible Automation | Consistent configuration |
| Troubleshooting Tools | Fast issue resolution |

---

# 🎯 Conclusion

In this comprehensive lab, you successfully learned:

✅ SELinux automation using Ansible  
✅ Enforcing security policies programmatically  
✅ Managing file contexts with `semanage`  
✅ Configuring booleans and custom ports  
✅ Automating application security policies  
✅ Troubleshooting SELinux issues  
✅ Applying enterprise-grade security practices  

SELinux combined with Ansible provides:

- 🔒 Strong security enforcement
- ⚡ Fast automated deployments
- 🛡️ Consistent enterprise compliance
- 🚀 Scalable infrastructure security

These skills are highly valuable for:

- RHCE Certification
- Linux System Administration
- DevOps Engineering
- Cloud Security
- Enterprise Automation

---

<div align="center">

# 🛡️ Secure Linux with SELinux + Ansible 🚀

### 💻 Enterprise Linux Security Automation

</div>
