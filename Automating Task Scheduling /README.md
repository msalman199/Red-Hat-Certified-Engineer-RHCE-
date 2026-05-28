# ⏰ Automating Task Scheduling with Ansible

<div align="center">

![Ansible](https://img.shields.io/badge/Ansible-Automation-red?style=for-the-badge&logo=ansible)
![Linux](https://img.shields.io/badge/Linux-Administration-yellow?style=for-the-badge&logo=linux)
![RHCE](https://img.shields.io/badge/RHCE-Lab-blue?style=for-the-badge&logo=redhat)
![Cron](https://img.shields.io/badge/Cron-Scheduler-green?style=for-the-badge)
![Systemd](https://img.shields.io/badge/Systemd-Timers-orange?style=for-the-badge)

# 🚀 Automating Task Scheduling Lab
### 🔥 RHCE Automation Practice with Ansible

</div>

---

# 📚 Objectives

By the end of this lab, students will be able to:

- ✅ Understand Linux task scheduling fundamentals
- ✅ Automate cron jobs using Ansible
- ✅ Configure one-time scheduling using `at`
- ✅ Manage advanced automation using systemd timers
- ✅ Apply enterprise scheduling best practices
- ✅ Troubleshoot scheduling issues effectively

---

# 🧰 Prerequisites

Before starting this lab, ensure you have:

| Requirement | Status |
|---|---|
| Linux Command Line Knowledge | ✅ |
| Basic Ansible Knowledge | ✅ |
| YAML Syntax Understanding | ✅ |
| System Administration Basics | ✅ |
| Text Editor Experience | ✅ |

---

# ☁️ Lab Environment

## 🖥️ Environment Includes

- CentOS/RHEL 8 or 9 Systems
- Ansible Pre-installed
- Multiple Target Nodes
- All Required Packages Installed

---

# 📁 Task 1 — Automate Recurring Tasks Using Cron

---

# 📂 Create Project Structure

```bash
mkdir -p ~/ansible-scheduling-lab/{playbooks,inventory,roles}
cd ~/ansible-scheduling-lab
```

---

# 🖥️ Create Inventory File

```bash
cat > inventory/hosts << EOF
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

# ⏲️ Understanding Cron Basics

| Cron Format | Meaning |
|---|---|
| `0 2 * * *` | Run daily at 2 AM |
| `30 14 * * 1` | Run Monday 2:30 PM |
| `*/15 * * * *` | Run every 15 minutes |

## 📝 Cron Syntax

```text
minute hour day month day_of_week
```

---

# ⚙️ Basic Cron Automation Playbook

## 📄 `playbooks/cron-tasks.yml`

```yaml
---
- name: Automate Cron Job Scheduling
  hosts: all
  become: yes

  vars:
    log_directory: /var/log/automated-tasks

  tasks:

    - name: Ensure log directory exists
      file:
        path: "{{ log_directory }}"
        state: directory
        owner: root
        group: root
        mode: '0755'

    - name: Schedule daily system cleanup
      cron:
        name: "Daily system cleanup"
        minute: "0"
        hour: "2"
        job: "find /tmp -type f -mtime +7 -delete >> {{ log_directory }}/cleanup.log 2>&1"
        user: root

    - name: Schedule weekly log rotation check
      cron:
        name: "Weekly log rotation check"
        minute: "30"
        hour: "1"
        weekday: "0"
        job: "logrotate -f /etc/logrotate.conf >> {{ log_directory }}/logrotate.log 2>&1"
        user: root

    - name: Schedule disk usage monitoring
      cron:
        name: "Disk usage monitoring"
        minute: "*/30"
        job: "df -h | grep -E '(8[0-9]|9[0-9])%' >> {{ log_directory }}/disk-usage.log"
        user: root
```

---

# ▶️ Execute Cron Playbook

```bash
ansible-playbook -i inventory/hosts playbooks/cron-tasks.yml
```

---

# 🔍 Verify Cron Jobs

```bash
ansible all -i inventory/hosts -m shell -a "crontab -l" --become
```

---

# 🚀 Advanced Cron Management

## 📄 `playbooks/advanced-cron.yml`

```yaml
---
- name: Advanced Cron Job Management
  hosts: webservers
  become: yes

  vars:
    backup_script: /usr/local/bin/backup.sh

  tasks:

    - name: Create backup script
      copy:
        content: |
          #!/bin/bash
          DATE=$(date +%Y%m%d_%H%M%S)
          BACKUP_DIR="/backup"
          SOURCE_DIR="/var/www/html"

          mkdir -p $BACKUP_DIR

          tar -czf $BACKUP_DIR/website_backup_$DATE.tar.gz $SOURCE_DIR

          find $BACKUP_DIR -name "website_backup_*.tar.gz" -mtime +7 -delete

          echo "Backup completed: $DATE" >> /var/log/backup.log

        dest: "{{ backup_script }}"
        mode: '0755'

    - name: Schedule website backup
      cron:
        name: "Website backup"
        minute: "0"
        hour: "3"
        job: "{{ backup_script }}"
        user: root

    - name: Remove old cron job
      cron:
        name: "Old cleanup job"
        state: absent
```

---

# ▶️ Run Advanced Cron Playbook

```bash
ansible-playbook -i inventory/hosts playbooks/advanced-cron.yml
```

---

# 📌 Task 2 — Automate One-Time Tasks Using AT

---

# 🧠 Understanding AT Command

The `at` command schedules:

- ✅ One-time jobs
- ✅ Delayed execution
- ✅ Temporary maintenance tasks

Unlike cron, AT jobs run only once.

---

# 📦 Install and Configure AT Service

## 📄 `playbooks/setup-at.yml`

```yaml
---
- name: Setup At Service
  hosts: all
  become: yes

  tasks:

    - name: Install at package
      package:
        name: at
        state: present

    - name: Start and enable atd
      systemd:
        name: atd
        state: started
        enabled: yes
```

---

# ▶️ Execute Setup

```bash
ansible-playbook -i inventory/hosts playbooks/setup-at.yml
```

---

# ⚡ Create AT Tasks Playbook

## 📄 `playbooks/at-tasks.yml`

```yaml
---
- name: Schedule One-Time Tasks with At
  hosts: all
  become: yes

  tasks:

    - name: Schedule system update
      at:
        command: "yum update -y >> /var/log/scheduled-update.log 2>&1"
        count: 5
        units: minutes
        unique: yes

    - name: Schedule cleanup tomorrow
      at:
        command: "find /var/log -name '*.log' -mtime +30 -delete"
        count: 1
        units: days
        time: "03:00"

    - name: Restart Apache in 1 hour
      at:
        command: "systemctl restart httpd"
        count: 1
        units: hours
      when: inventory_hostname in groups['webservers']
```

---

# ▶️ Run AT Playbook

```bash
ansible-playbook -i inventory/hosts playbooks/at-tasks.yml
```

---

# 🔍 Verify AT Jobs

```bash
ansible all -i inventory/hosts -m shell -a "atq" --become
```

---

# 🧩 Advanced AT Automation

## 📄 `playbooks/advanced-at.yml`

```yaml
---
- name: Advanced At Scheduling
  hosts: all
  become: yes

  vars:
    maintenance_script: /usr/local/bin/maintenance.sh

  tasks:

    - name: Create maintenance script
      copy:
        content: |
          #!/bin/bash

          echo "Maintenance Started"

          yum clean all

          find /tmp -type f -mtime +1 -delete

          echo "Maintenance Completed"

        dest: "{{ maintenance_script }}"
        mode: '0755'

    - name: Schedule maintenance
      at:
        command: "{{ maintenance_script }}"
        count: 1
        units: weeks
        time: "02:00"
```

---

# 📌 Task 3 — Configure Systemd Timers

---

# 🧠 Why Use Systemd Timers?

| Feature | Benefit |
|---|---|
| Accurate Timing | Better scheduling |
| Logging | Integrated journald |
| Dependencies | Better control |
| Resource Limits | Safer automation |

---

# ⚙️ Configure Systemd Timers

## 📄 `playbooks/systemd-timers.yml`

```yaml
---
- name: Configure Systemd Timers
  hosts: all
  become: yes

  vars:
    timer_directory: /etc/systemd/system
    script_directory: /usr/local/bin

  tasks:

    - name: Create backup script
      copy:
        content: |
          #!/bin/bash

          BACKUP_DIR="/backup/systemd"

          mkdir -p $BACKUP_DIR

          tar -czf $BACKUP_DIR/system_backup_$(date +%F).tar.gz /etc/passwd

          echo "Backup completed"

        dest: "{{ script_directory }}/systemd-backup.sh"
        mode: '0755'

    - name: Create systemd service
      copy:
        content: |
          [Unit]
          Description=System Backup Service

          [Service]
          Type=oneshot
          ExecStart={{ script_directory }}/systemd-backup.sh

        dest: "{{ timer_directory }}/system-backup.service"

    - name: Create systemd timer
      copy:
        content: |
          [Unit]
          Description=Run backup daily

          [Timer]
          OnCalendar=daily
          Persistent=true

          [Install]
          WantedBy=timers.target

        dest: "{{ timer_directory }}/system-backup.timer"

    - name: Reload systemd
      systemd:
        daemon_reload: yes

    - name: Enable timer
      systemd:
        name: system-backup.timer
        enabled: yes
        state: started
```

---

# ▶️ Execute Systemd Timer Playbook

```bash
ansible-playbook -i inventory/hosts playbooks/systemd-timers.yml
```

---

# 🔍 Verify Systemd Timers

```bash
ansible all -i inventory/hosts -m shell -a "systemctl list-timers --all" --become
```

---

# 📊 View Timer Status

```bash
ansible all -i inventory/hosts -m shell -a "systemctl status system-backup.timer"
```

---

# 📜 View Timer Logs

```bash
ansible all -i inventory/hosts -m shell -a "journalctl -u system-backup.timer -n 10"
```

---

# 🛠️ Verification Playbook

## 📄 `playbooks/verify-scheduling.yml`

```yaml
---
- name: Verify Scheduled Tasks
  hosts: all
  become: yes

  tasks:

    - name: Check cron jobs
      shell: crontab -l
      register: cron_jobs
      failed_when: false

    - name: Check at jobs
      shell: atq
      register: at_jobs
      failed_when: false

    - name: Check systemd timers
      shell: systemctl list-timers --no-pager
      register: timers
```

---

# ▶️ Run Verification

```bash
ansible-playbook -i inventory/hosts playbooks/verify-scheduling.yml
```

---

# 🧯 Troubleshooting Common Issues

---

# ❌ Issue 1 — Cron Jobs Not Running

## ✅ Solution

```bash
systemctl status crond
```

```bash
grep CRON /var/log/messages
```

```bash
ls -la /usr/local/bin/backup.sh
```

---

# ❌ Issue 2 — AT Jobs Failing

## ✅ Solution

```bash
systemctl status atd
```

```bash
atq
```

```bash
mail
```

---

# ❌ Issue 3 — Systemd Timers Not Starting

## ✅ Solution

```bash
systemctl daemon-reload
```

```bash
systemctl restart system-backup.timer
```

```bash
systemd-analyze verify /etc/systemd/system/system-backup.timer
```

---

# 🔐 Security Best Practices

## ✅ Use Dedicated Users

```yaml
- name: Create backup user
  user:
    name: backup_user
    system: yes
```

---

## ✅ Secure Script Permissions

```yaml
- name: Secure backup script
  file:
    path: /usr/local/bin/backup.sh
    mode: '0750'
```

---

## ✅ Use Secure PATH Variables

```yaml
- name: Secure cron environment
  cron:
    name: "Secure backup"
    job: "export PATH=/usr/local/bin:/bin:/usr/bin && /usr/local/bin/secure-backup.sh"
```

---

# ⚡ Performance Best Practices

- ✅ Use `RandomizedDelaySec`
- ✅ Schedule during low traffic
- ✅ Set CPU/Memory limits
- ✅ Monitor resource usage

---

# 🎯 Key Takeaways

| Tool | Best Use Case |
|---|---|
| Cron | Recurring simple tasks |
| AT | One-time tasks |
| Systemd Timers | Advanced automation |

---

# 🏆 Conclusion

In this lab, you successfully learned:

## ✅ Cron Automation
- Automated recurring tasks
- Managed backups and monitoring
- Configured enterprise cron jobs

## ✅ AT Scheduling
- Automated one-time jobs
- Managed delayed maintenance
- Scheduled temporary operations

## ✅ Systemd Timers
- Created advanced timers
- Managed dependencies
- Integrated logging and monitoring

---

# 🚀 Why This Lab Matters

These automation skills are essential for:

- 🔥 RHCE Certification
- ☁️ DevOps Engineering
- 🖥️ Linux Administration
- 🏢 Enterprise Automation
- 🔐 System Reliability
- 📈 Infrastructure Scalability

---

<div align="center">

# 💻 Happy Automating with Ansible 🚀

### ⭐ Star Your Repository
### 🍴 Fork & Practice
### 🔥 Keep Learning RHCE Automation

</div>
