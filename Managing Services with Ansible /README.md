# 🚀 Managing Services with Ansible

![Ansible](https://img.shields.io/badge/Automation-Ansible-red?style=for-the-badge&logo=ansible)
![Linux](https://img.shields.io/badge/Platform-Linux-FCC624?style=for-the-badge&logo=linux)
![YAML](https://img.shields.io/badge/Language-YAML-CB171E?style=for-the-badge&logo=yaml)
![Apache](https://img.shields.io/badge/WebServer-Apache-D22128?style=for-the-badge&logo=apache)
![Systemd](https://img.shields.io/badge/Service-Systemd-000000?style=for-the-badge&logo=linux)
![RHCE](https://img.shields.io/badge/Certification-RHCE-red?style=for-the-badge)

---

# 📘 Overview

This lab demonstrates how to automate Linux service management using **Ansible** and the **systemd module**. You will learn how to deploy and manage services such as Apache HTTP Server across multiple machines while implementing handlers, configuration management, troubleshooting, and verification techniques.

---

# 🎯 Objectives

By the end of this lab, you will be able to:

✅ Understand the fundamentals of service management using Ansible  
✅ Write playbooks to automate service management tasks using the `systemd` module  
✅ Enable and start the `httpd` service on multiple remote machines  
✅ Create and implement handlers to restart services when configuration files change  
✅ Apply best practices for service management automation in enterprise environments  
✅ Troubleshoot common service management issues using Ansible  

---

# 📚 Prerequisites

Before starting this lab, you should have:

- Basic understanding of Linux command line operations
- Familiarity with YAML syntax and structure
- Knowledge of Ansible fundamentals
- Understanding of systemd service management concepts
- Experience with SSH key-based authentication
- Basic knowledge of Apache HTTP Server

---

# 🖥️ Lab Environment Setup

## Ready-to-Use Cloud Machines

Al Nafi provides pre-configured Linux-based cloud machines.

### Environment Includes

| Component | Details |
|---|---|
| Control Node | CentOS/RHEL 8 or 9 |
| Managed Nodes | 3 Managed Nodes |
| Automation Tool | Ansible Pre-installed |
| Authentication | SSH Key-Based |
| Dependencies | All Packages Installed |

---

# 📂 Create Working Directory

```bash
mkdir -p ~/ansible-labs/lab4-services
cd ~/ansible-labs/lab4-services
```

---

# 🧾 Inventory Configuration

Create inventory file:

```bash
cat > inventory.ini << 'EOF'
[webservers]
node1 ansible_host=10.0.1.10
node2 ansible_host=10.0.1.11
node3 ansible_host=10.0.1.12

[all:vars]
ansible_user=ansible
ansible_ssh_private_key_file=~/.ssh/id_rsa
EOF
```

---

# 🔍 Verify Connectivity

```bash
ansible all -i inventory.ini -m ping
```

Expected Result:

```text
SUCCESS => pong
```

---

# 📖 Explore systemd Module

View Ansible documentation:

```bash
ansible-doc systemd
```

## Important Parameters

| Parameter | Description |
|---|---|
| name | Service Name |
| state | started/stopped/restarted |
| enabled | Start on Boot |
| daemon_reload | Reload systemd daemon |

---

# ⚙️ Basic Service Management Playbook

Create playbook:

```bash
cat > service-management.yml << 'EOF'
---
- name: Service Management with Ansible
  hosts: webservers
  become: yes

  vars:
    services_to_manage:
      - name: httpd
        state: started
        enabled: yes

      - name: firewalld
        state: started
        enabled: yes

  tasks:

    - name: Install required packages
      yum:
        name:
          - httpd
          - firewalld
        state: present

    - name: Manage services
      systemd:
        name: "{{ item.name }}"
        state: "{{ item.state }}"
        enabled: "{{ item.enabled }}"
      loop: "{{ services_to_manage }}"
EOF
```

---

# ▶️ Execute Playbook

```bash
ansible-playbook -i inventory.ini service-management.yml
```

---

# ✅ Verify Services

Create verification playbook:

```bash
cat > verify-services.yml << 'EOF'
---
- name: Verify Service Status
  hosts: webservers
  become: yes

  tasks:

    - name: Check httpd status
      systemd:
        name: httpd
      register: httpd_status

    - name: Show service details
      debug:
        msg: |
          Active State: {{ httpd_status.status.ActiveState }}
          Enabled: {{ httpd_status.status.UnitFileState }}
EOF
```

Run verification:

```bash
ansible-playbook -i inventory.ini verify-services.yml
```

---

# 🌐 Apache Web Server Deployment

Create deployment playbook:

```bash
cat > webserver-setup.yml << 'EOF'
---
- name: Deploy Apache Web Server
  hosts: webservers
  become: yes

  vars:
    web_service: httpd
    document_root: /var/www/html

  tasks:

    - name: Install Apache
      yum:
        name: "{{ web_service }}"
        state: present

    - name: Create custom webpage
      copy:
        content: |
          <html>
          <body>
            <h1>Apache Web Server</h1>
            <p>Managed by Ansible</p>
            <p>Hostname: {{ inventory_hostname }}</p>
          </body>
          </html>
        dest: "{{ document_root }}/index.html"

    - name: Start Apache Service
      systemd:
        name: "{{ web_service }}"
        state: started
        enabled: yes

    - name: Allow HTTP in firewall
      firewalld:
        service: http
        permanent: yes
        state: enabled
        immediate: yes
EOF
```

---

# 🚀 Run Apache Deployment

```bash
ansible-playbook -i inventory.ini webserver-setup.yml
```

---

# 🧪 Test Web Servers

Create testing playbook:

```bash
cat > test-webservers.yml << 'EOF'
---
- name: Test Apache Servers
  hosts: webservers
  become: yes

  tasks:

    - name: Gather service facts
      service_facts:

    - name: Verify Apache is running
      assert:
        that:
          - ansible_facts.services['httpd.service'].state == 'running'

    - name: Test localhost response
      uri:
        url: "http://localhost"
        return_content: yes
      register: web_response

    - name: Display response
      debug:
        var: web_response.content
EOF
```

Execute:

```bash
ansible-playbook -i inventory.ini test-webservers.yml
```

---

# 🔄 Handlers in Ansible

Handlers run only when notified by tasks that change something.

---

# 🛠️ Configuration Management with Handlers

Create playbook:

```bash
cat > config-with-handlers.yml << 'EOF'
---
- name: Apache Config with Handlers
  hosts: webservers
  become: yes

  handlers:

    - name: restart apache
      systemd:
        name: httpd
        state: restarted

  tasks:

    - name: Install Apache
      yum:
        name: httpd
        state: present

    - name: Create custom config
      copy:
        content: |
          ServerTokens Prod
          ServerSignature Off
        dest: /etc/httpd/conf.d/custom.conf
      notify:
        - restart apache

    - name: Ensure Apache running
      systemd:
        name: httpd
        state: started
        enabled: yes
EOF
```

---

# ▶️ Execute Handler Playbook

```bash
ansible-playbook -i inventory.ini config-with-handlers.yml
```

---

# ⚡ Advanced Handler Example

```bash
cat > advanced-handlers.yml << 'EOF'
---
- name: Advanced Handlers Demo
  hosts: webservers
  become: yes

  handlers:

    - name: restart apache service
      systemd:
        name: httpd
        state: restarted

    - name: reload apache configuration
      systemd:
        name: httpd
        state: reloaded

  tasks:

    - name: Configure Apache Security
      blockinfile:
        path: /etc/httpd/conf/httpd.conf
        block: |
          ServerTokens Prod
          ServerSignature Off
      notify:
        - restart apache service

    - name: Configure custom error page
      copy:
        content: |
          <h1>404 - Page Not Found</h1>
        dest: /var/www/html/404.html
      notify:
        - reload apache configuration
EOF
```

Run playbook:

```bash
ansible-playbook -i inventory.ini advanced-handlers.yml
```

---

# 🧪 Test Handler Functionality

```bash
cat > test-handlers.yml << 'EOF'
---
- name: Test Handlers
  hosts: webservers
  become: yes

  handlers:

    - name: test restart handler
      debug:
        msg: "Handler Triggered Successfully"

  tasks:

    - name: Make config change
      lineinfile:
        path: /etc/httpd/conf/httpd.conf
        regexp: '^#ServerName'
        line: 'ServerName {{ inventory_hostname }}'
      notify:
        - test restart handler
EOF
```

Execute:

```bash
ansible-playbook -i inventory.ini test-handlers.yml
```

---

# 🐞 Troubleshooting Common Issues

---

## ❌ Service Fails to Start

Check service status:

```bash
ansible webservers -i inventory.ini -m systemd -a "name=httpd" -b
```

View logs:

```bash
ansible webservers -i inventory.ini -m shell -a "journalctl -u httpd --no-pager -n 20" -b
```

---

## ❌ Apache Configuration Errors

Test configuration:

```bash
ansible webservers -i inventory.ini -m shell -a "httpd -t" -b
```

---

## ❌ Firewall Blocking HTTP

Check firewall:

```bash
ansible webservers -i inventory.ini -m shell -a "firewall-cmd --list-all" -b
```

---

# 🧹 Force Handler Execution

```yaml
- name: Force handlers immediately
  meta: flush_handlers
```

---

# ✅ Final Verification Playbook

```bash
cat > final-verification.yml << 'EOF'
---
- name: Final Verification
  hosts: webservers
  become: yes

  tasks:

    - name: Gather service facts
      service_facts:

    - name: Verify Apache
      assert:
        that:
          - ansible_facts.services['httpd.service'].state == 'running'

    - name: Test web server
      uri:
        url: "http://{{ ansible_default_ipv4.address }}"
        status_code: 200
EOF
```

Run verification:

```bash
ansible-playbook -i inventory.ini final-verification.yml
```

---

# 📊 Key Skills Learned

✅ Service Management with Ansible  
✅ systemd Module Usage  
✅ Apache Deployment Automation  
✅ Multi-Host Management  
✅ Handlers and Notifications  
✅ Configuration Management  
✅ Service Verification and Testing  
✅ Troubleshooting Techniques  

---

# 🏆 RHCE Exam Relevance

This lab directly supports RHCE objectives:

- Managing Linux services using Ansible
- Writing reusable playbooks
- Implementing handlers
- Troubleshooting automation issues
- Automating Apache deployment

---

# 🔐 Best Practices

| Best Practice | Description |
|---|---|
| Use Handlers | Restart services only when needed |
| Use Tags | Execute specific tasks easily |
| Validate Configurations | Always test configs before restart |
| Use Idempotency | Ensure safe multiple executions |
| Automate Verification | Confirm service functionality |

---

# 🌍 Real World Use Cases

- Web Server Farms
- Load Balancers
- Database Services
- Security Patch Management
- Microservices Deployment
- Configuration Drift Prevention

---

# 🚀 Next Steps

✅ Practice with Nginx and MariaDB  
✅ Learn Rolling Updates  
✅ Implement Monitoring Playbooks  
✅ Explore Advanced Handler Patterns  
✅ Automate Security Hardening  

---

# 🎉 Conclusion

In this lab, you successfully automated Linux service management using Ansible. You deployed Apache web servers, managed services using the `systemd` module, implemented handlers for automatic service restarts, and learned enterprise-level automation practices.

These skills are essential for:

- Linux System Administration
- DevOps Engineering
- Infrastructure Automation
- RHCE Certification Preparation
- Enterprise Configuration Management

You now have a strong foundation for managing services at scale using Ansible automation.




Automation • Linux • Ansible • RHCE • Infrastructure as Code

---
