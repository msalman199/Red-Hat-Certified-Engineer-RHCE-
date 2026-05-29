# 🚀 Scaling Ansible Automation in Production

<p align="center">
  <img src="https://img.shields.io/badge/Ansible-Automation-red?style=for-the-badge&logo=ansible">
  <img src="https://img.shields.io/badge/Linux-Administration-black?style=for-the-badge&logo=linux">
  <img src="https://img.shields.io/badge/DevOps-Production-blue?style=for-the-badge&logo=azuredevops">
  <img src="https://img.shields.io/badge/Cloud-Infrastructure-orange?style=for-the-badge&logo=amazonaws">
</p>

---

# 📘 Overview

## 🎯 Objectives

By the end of this lab, students will be able to:

✅ Implement dynamic inventories to manage large-scale infrastructure across multiple regions  
✅ Optimize Ansible playbooks for performance in large deployments  
✅ Configure and utilize Ansible strategies for parallel execution  
✅ Implement caching mechanisms to improve playbook performance  
✅ Troubleshoot common issues in large-scale Ansible deployments  
✅ Apply performance tuning techniques for production environments  
✅ Monitor and analyze Ansible execution metrics  

---

# 🛠️ Prerequisites

Before starting this lab, students should have:

🔹 Basic understanding of Ansible concepts  
🔹 Familiarity with YAML syntax and Jinja2 templating  
🔹 Knowledge of Linux command line operations  
🔹 Understanding of Apache/Nginx  
🔹 Basic networking knowledge  
🔹 Experience with SSH key management  

---

# 💻 Lab Environment

## 🌐 Environment Includes

✅ Ansible Control Node with Ansible 2.15+  
✅ Multiple Target Nodes  
✅ SSH Keys Configured  
✅ Sample Web Applications  

---

# 🏗️ Task 1 — Automate Scaling Using Dynamic Inventories

---

# 🔹 Subtask 1.1 — Create Project Structure

## 📂 Create Working Directory

```bash
cd /home/ansible

mkdir -p scaling-lab/{inventories,playbooks,roles,group_vars,host_vars}

cd scaling-lab
```

---

# ⚡ Create Dynamic Inventory Script

```bash
cat > inventories/dynamic_inventory.py << 'EOF'
#!/usr/bin/env python3

import json
import sys

def get_inventory():
    inventory = {
        '_meta': {
            'hostvars': {}
        },

        'webservers': {
            'hosts': [],
            'vars': {
                'ansible_user': 'ansible',
                'http_port': 80,
                'max_clients': 200
            }
        },

        'us_east': {
            'hosts': [],
            'vars': {
                'region': 'us-east-1',
                'datacenter': 'virginia'
            }
        },

        'us_west': {
            'hosts': [],
            'vars': {
                'region': 'us-west-2',
                'datacenter': 'oregon'
            }
        },

        'europe': {
            'hosts': [],
            'vars': {
                'region': 'eu-west-1',
                'datacenter': 'ireland'
            }
        }
    }

    hosts = [
        {'name': 'web-us-east-01', 'ip': '10.0.1.10', 'region': 'us_east'},
        {'name': 'web-us-east-02', 'ip': '10.0.1.11', 'region': 'us_east'},
        {'name': 'web-us-west-01', 'ip': '10.0.2.10', 'region': 'us_west'},
        {'name': 'web-us-west-02', 'ip': '10.0.2.11', 'region': 'us_west'},
        {'name': 'web-eu-west-01', 'ip': '10.0.3.10', 'region': 'europe'},
        {'name': 'web-eu-west-02', 'ip': '10.0.3.11', 'region': 'europe'}
    ]

    for host in hosts:

        inventory['webservers']['hosts'].append(host['name'])

        inventory[host['region']]['hosts'].append(host['name'])

        inventory['_meta']['hostvars'][host['name']] = {
            'ansible_host': host['ip'],
            'region_name': host['region'],
            'server_id': host['name']
        }

    return inventory

if __name__ == '__main__':

    if len(sys.argv) == 2 and sys.argv[1] == '--list':
        print(json.dumps(get_inventory(), indent=2))

    elif len(sys.argv) == 3 and sys.argv[1] == '--host':
        print(json.dumps({}))

    else:
        print("Usage Error")
        sys.exit(1)
EOF
```

---

# 🔐 Make Inventory Executable

```bash
chmod +x inventories/dynamic_inventory.py
```

---

# 🧪 Test Inventory

```bash
./inventories/dynamic_inventory.py --list
```

---

# 🔹 Subtask 1.2 — Create Webserver Role

## 🧱 Initialize Role

```bash
ansible-galaxy init roles/webserver
```

---

# ⚙️ Create Role Tasks

```bash
cat > roles/webserver/tasks/main.yml << 'EOF'
---
- name: Install Web Packages
  package:
    name: "{{ web_packages }}"
    state: present
  become: yes

- name: Create Web Root
  file:
    path: "{{ web_root }}"
    state: directory
    owner: "{{ web_user }}"
    group: "{{ web_group }}"
    mode: '0755'
  become: yes

- name: Deploy Index File
  template:
    src: index.html.j2
    dest: "{{ web_root }}/index.html"
  become: yes

- name: Start HTTPD Service
  service:
    name: "{{ web_service }}"
    state: started
    enabled: yes
  become: yes
EOF
```

---

# 📦 Create Default Variables

```bash
cat > roles/webserver/defaults/main.yml << 'EOF'
---
web_packages:
  - httpd
  - firewalld

web_service: httpd
web_user: apache
web_group: apache
web_root: /var/www/html

max_clients: 200
server_limit: 20
EOF
```

---

# 🌐 Create HTML Template

```bash
cat > roles/webserver/templates/index.html.j2 << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Production Web Server</title>
</head>

<body>

<h1>🚀 Production Web Server</h1>

<p>Hostname: {{ ansible_hostname }}</p>
<p>Region: {{ region_name }}</p>
<p>Server ID: {{ server_id }}</p>

</body>
</html>
EOF
```

---

# 🔄 Create Handlers

```bash
cat > roles/webserver/handlers/main.yml << 'EOF'
---
- name: restart webserver
  service:
    name: "{{ web_service }}"
    state: restarted
  become: yes
EOF
```

---

# 🔹 Subtask 1.3 — Create Scaling Playbook

## 🚀 Main Deployment Playbook

```bash
cat > playbooks/scale-webservers.yml << 'EOF'
---
- name: Scale Web Servers Across Regions
  hosts: webservers
  gather_facts: yes
  become: yes
  strategy: free
  serial: "30%"

  vars:
    http_port: 80

  pre_tasks:

    - name: Check Connectivity
      wait_for_connection:
        timeout: 30

  roles:
    - role: webserver

  post_tasks:

    - name: Perform Health Check
      uri:
        url: "http://{{ ansible_default_ipv4.address }}"
        method: GET
        status_code: 200
EOF
```

---

# ⚡ Task 2 — Performance Optimization

---

# ⚙️ Create ansible.cfg

```bash
cat > ansible.cfg << 'EOF'
[defaults]

inventory = inventories/dynamic_inventory.py

host_key_checking = False

remote_user = ansible

forks = 20

timeout = 30

gathering = smart

fact_caching = jsonfile

fact_caching_connection = /tmp/ansible_fact_cache

fact_caching_timeout = 3600

stdout_callback = yaml

callbacks_enabled = timer, profile_tasks

roles_path = roles

[ssh_connection]

pipelining = True

retries = 3
EOF
```

---

# 🚀 Optimized Deployment Playbook

```bash
cat > playbooks/optimized-deployment.yml << 'EOF'
---
- name: High Performance Deployment
  hosts: webservers
  gather_facts: yes
  become: yes
  strategy: free
  serial: "25%"

  tasks:

    - name: Install Packages
      package:
        name: httpd
        state: present

    - name: Deploy Web Role
      include_role:
        name: webserver

    - name: Health Check
      uri:
        url: "http://{{ ansible_default_ipv4.address }}"
        method: GET
        status_code: 200
EOF
```

---

# 🔹 Fact Caching Playbook

```bash
cat > playbooks/cache-facts.yml << 'EOF'
---
- name: Cache Facts
  hosts: all
  gather_facts: yes

  tasks:

    - name: Gather Facts
      setup:

    - name: Display Facts
      debug:
        msg: |
          Host: {{ inventory_hostname }}
          Memory: {{ ansible_memtotal_mb }}
          CPU: {{ ansible_processor_vcpus }}
EOF
```

---

# 🔥 Task 3 — Monitoring & Troubleshooting

---

# 📊 Monitoring Playbook

```bash
cat > playbooks/monitor-performance.yml << 'EOF'
---
- name: Monitor Performance
  hosts: webservers
  gather_facts: yes
  become: yes

  tasks:

    - name: Install Monitoring Tools
      package:
        name:
          - htop
          - iotop
          - sysstat
        state: present

    - name: Check Memory Usage
      shell: free -m
      register: memory_output

    - name: Show Output
      debug:
        var: memory_output.stdout
EOF
```

---

# 🛠️ Troubleshooting Playbook

```bash
cat > playbooks/troubleshoot-deployment.yml << 'EOF'
---
- name: Troubleshoot Deployment
  hosts: webservers
  gather_facts: yes
  become: yes
  ignore_errors: yes

  tasks:

    - name: Ping Servers
      ping:

    - name: Check SSH Access
      shell: whoami

    - name: Check Disk Usage
      shell: df -h

    - name: Check HTTPD Service
      shell: systemctl status httpd
EOF
```

---

# 🚀 Run Playbooks

## ▶️ Run Main Deployment

```bash
ansible-playbook playbooks/scale-webservers.yml
```

---

## ▶️ Run Optimized Deployment

```bash
ansible-playbook playbooks/optimized-deployment.yml
```

---

## ▶️ Run Monitoring

```bash
ansible-playbook playbooks/monitor-performance.yml
```

---

## ▶️ Run Troubleshooting

```bash
ansible-playbook playbooks/troubleshoot-deployment.yml
```

---

# 📈 Performance Optimization Techniques

✅ Dynamic Inventory  
✅ SSH Pipelining  
✅ Increased Forks  
✅ Fact Caching  
✅ Parallel Deployment  
✅ Async Tasks  
✅ Reduced Gather Facts  
✅ Serial Deployment  

---

# 🧰 Technologies Used

<p align="center">

<img src="https://img.shields.io/badge/Ansible-Automation-red?style=for-the-badge&logo=ansible">

<img src="https://img.shields.io/badge/Linux-Administration-black?style=for-the-badge&logo=linux">

<img src="https://img.shields.io/badge/YAML-Configuration-red?style=for-the-badge&logo=yaml">

<img src="https://img.shields.io/badge/Python-Scripting-blue?style=for-the-badge&logo=python">

<img src="https://img.shields.io/badge/Apache-Web_Server-orange?style=for-the-badge&logo=apache">

<img src="https://img.shields.io/badge/DevOps-Engineering-blueviolet?style=for-the-badge&logo=azuredevops">

<img src="https://img.shields.io/badge/AWS-Cloud-orange?style=for-the-badge&logo=amazonaws">

</p>

---

# 🎓 Skills Learned

✅ Dynamic Inventory Management  
✅ Production Scaling  
✅ Playbook Optimization  
✅ Fact Caching  
✅ Monitoring & Troubleshooting  
✅ Performance Tuning  
✅ Web Server Automation  

---

# 👨‍💻 Author

## Hafiz Muhammad Salman

📧 hafizmuhammadsalman13@gmail.com  
🌐 GitHub: https://github.com/msalman199  
📱 +92 314 3563640  

---

# ⭐ Happy Learning DevOps & Cloud Automation ⭐
