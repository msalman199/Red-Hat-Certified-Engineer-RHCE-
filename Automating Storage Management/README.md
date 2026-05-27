# 🚀 Automating Storage Management with Ansible

![Ansible](https://img.shields.io/badge/Automation-Ansible-red?style=for-the-badge&logo=ansible)
![Linux](https://img.shields.io/badge/Platform-Linux-yellow?style=for-the-badge&logo=linux)
![LVM](https://img.shields.io/badge/Storage-LVM-blue?style=for-the-badge)
![Filesystem](https://img.shields.io/badge/FileSystem-ext4%20%7C%20xfs-green?style=for-the-badge)
![RHCE](https://img.shields.io/badge/Certification-RHCE-black?style=for-the-badge&logo=redhat)
![YAML](https://img.shields.io/badge/Language-YAML-purple?style=for-the-badge)

---

# 📘 Overview

This lab demonstrates how to automate Linux storage management using **Ansible**.  
You will learn how to:

- Automate disk partitioning
- Create Logical Volumes (LVM)
- Format and mount filesystems
- Configure persistent mounts
- Apply enterprise storage automation best practices

---

# 🎯 Objectives

By the end of this lab, you will be able to:

✅ Automate disk partitioning using Ansible playbooks  
✅ Create and manage logical volumes using the `lvol` module  
✅ Format and mount file systems automatically  
✅ Ensure persistent mounting across system reboots  
✅ Implement storage automation best practices for enterprise environments  

---

# 📋 Prerequisites

Before starting this lab, you should have:

- Basic understanding of Linux file systems and storage concepts
- Familiarity with Ansible playbooks and YAML syntax
- Knowledge of LVM fundamentals
- Experience with Linux command-line operations
- Understanding of mount points and `/etc/fstab`

---

# 🖥️ Lab Environment Setup

Al Nafi provides pre-configured Linux cloud machines for this lab.

### Environment Includes

| Component | Description |
|---|---|
| Operating System | CentOS/RHEL 8 or 9 |
| Automation Tool | Ansible |
| Extra Disk | `/dev/sdb` |
| Privileges | Root/Sudo Access |
| Packages | Pre-installed |

---

# 📁 Task 1: Write a Playbook to Partition a Disk and Create Logical Volumes

## 📂 Subtask 1.1: Create the Directory Structure

```bash
mkdir -p ~/storage-automation/{playbooks,inventory,group_vars}
cd ~/storage-automation
```

---

## 🧾 Subtask 1.2: Create Inventory File

```bash
cat > inventory/hosts << EOF
[storage_servers]
localhost ansible_connection=local
EOF
```

---

## ⚙️ Subtask 1.3: Create Main Storage Automation Playbook

```yaml
cat > playbooks/storage-management.yml << 'EOF'
---
- name: Automate Storage Management
  hosts: storage_servers
  become: yes

  vars:
    target_disk: /dev/sdb
    volume_group_name: vg_data

    logical_volumes:
      - name: lv_web
        size: 2G
        mount_point: /var/www
        filesystem: ext4

      - name: lv_logs
        size: 1G
        mount_point: /var/log/apps
        filesystem: xfs

      - name: lv_backup
        size: 1G
        mount_point: /backup
        filesystem: ext4

  tasks:

    - name: Install required packages
      package:
        name:
          - lvm2
          - parted
          - xfsprogs
        state: present

    - name: Check if disk exists
      stat:
        path: "{{ target_disk }}"
      register: disk_check

    - name: Fail if disk doesn't exist
      fail:
        msg: "Target disk {{ target_disk }} does not exist"
      when: not disk_check.stat.exists

    - name: Create partition on target disk
      parted:
        device: "{{ target_disk }}"
        number: 1
        state: present
        part_type: primary
        part_start: 0%
        part_end: 100%
        flags: [lvm]

    - name: Create volume group
      lvg:
        vg: "{{ volume_group_name }}"
        pvs: "{{ target_disk }}1"
        state: present

    - name: Create logical volumes
      lvol:
        vg: "{{ volume_group_name }}"
        lv: "{{ item.name }}"
        size: "{{ item.size }}"
        state: present
      loop: "{{ logical_volumes }}"

    - name: Display created logical volumes
      command: lvdisplay
      register: lv_display
      changed_when: false

    - name: Show logical volume information
      debug:
        msg: "{{ lv_display.stdout_lines }}"
EOF
```

---

## ▶️ Subtask 1.4: Run the Playbook

```bash
ansible-playbook -i inventory/hosts playbooks/storage-management.yml
```

---

## ✅ Subtask 1.5: Verify the Logical Volumes

```bash
sudo vgdisplay
sudo lvdisplay
sudo pvdisplay
```

---

# 💽 Task 2: Format the Logical Volumes and Mount Them

## ⚙️ Subtask 2.1: Create Formatting & Mounting Playbook

```yaml
cat > playbooks/format-and-mount.yml << 'EOF'
---
- name: Format and Mount Logical Volumes
  hosts: storage_servers
  become: yes

  vars:
    volume_group_name: vg_data

    logical_volumes:
      - name: lv_web
        size: 2G
        mount_point: /var/www
        filesystem: ext4
        mount_options: defaults

      - name: lv_logs
        size: 1G
        mount_point: /var/log/apps
        filesystem: xfs
        mount_options: defaults,noatime

      - name: lv_backup
        size: 1G
        mount_point: /backup
        filesystem: ext4
        mount_options: defaults

  tasks:

    - name: Create mount point directories
      file:
        path: "{{ item.mount_point }}"
        state: directory
        mode: '0755'
      loop: "{{ logical_volumes }}"

    - name: Format logical volumes
      filesystem:
        fstype: "{{ item.filesystem }}"
        dev: "/dev/{{ volume_group_name }}/{{ item.name }}"
        force: no
      loop: "{{ logical_volumes }}"

    - name: Mount logical volumes
      mount:
        path: "{{ item.mount_point }}"
        src: "/dev/{{ volume_group_name }}/{{ item.name }}"
        fstype: "{{ item.filesystem }}"
        opts: "{{ item.mount_options }}"
        state: mounted
      loop: "{{ logical_volumes }}"

    - name: Verify mounted filesystems
      command: df -h
      register: df_output
      changed_when: false

    - name: Display mounted filesystems
      debug:
        msg: "{{ df_output.stdout_lines }}"
EOF
```

---

## ▶️ Subtask 2.2: Execute Formatting & Mounting Playbook

```bash
ansible-playbook -i inventory/hosts playbooks/format-and-mount.yml
```

---

## ✅ Subtask 2.3: Verify Mounted Filesystems

```bash
df -h
mount | grep vg_data
lsblk -f
```

---

# 🔄 Task 3: Ensure Mounted Volumes are Persistent

## ⚙️ Subtask 3.1: Create Persistent Mounting Playbook

```yaml
cat > playbooks/persistent-mounts.yml << 'EOF'
---
- name: Configure Persistent Mounts
  hosts: storage_servers
  become: yes

  vars:
    volume_group_name: vg_data

    logical_volumes:
      - name: lv_web
        mount_point: /var/www
        filesystem: ext4
        mount_options: defaults
        dump: 1
        passno: 2

      - name: lv_logs
        mount_point: /var/log/apps
        filesystem: xfs
        mount_options: defaults,noatime
        dump: 1
        passno: 2

      - name: lv_backup
        mount_point: /backup
        filesystem: ext4
        mount_options: defaults
        dump: 1
        passno: 2

  tasks:

    - name: Backup original fstab
      copy:
        src: /etc/fstab
        dest: /etc/fstab.backup.{{ ansible_date_time.epoch }}
        remote_src: yes

    - name: Add logical volumes to fstab
      mount:
        path: "{{ item.mount_point }}"
        src: "/dev/{{ volume_group_name }}/{{ item.name }}"
        fstype: "{{ item.filesystem }}"
        opts: "{{ item.mount_options }}"
        dump: "{{ item.dump }}"
        passno: "{{ item.passno }}"
        state: present
      loop: "{{ logical_volumes }}"

    - name: Test fstab configuration
      command: mount -a
      register: mount_test
      changed_when: false

    - name: Verify fstab entries
      command: grep vg_data /etc/fstab
      register: fstab_entries
      changed_when: false

    - name: Display fstab entries
      debug:
        msg: "{{ fstab_entries.stdout_lines }}"
EOF
```

---

## ▶️ Subtask 3.2: Execute Persistent Mount Playbook

```bash
ansible-playbook -i inventory/hosts playbooks/persistent-mounts.yml
```

---

# 🏗️ Subtask 3.3: Complete Storage Automation Playbook

```yaml
cat > playbooks/complete-storage-automation.yml << 'EOF'
---
- name: Complete Storage Management Automation
  hosts: storage_servers
  become: yes

  vars:
    target_disk: /dev/sdb
    volume_group_name: vg_data

    logical_volumes:
      - name: lv_web
        size: 2G
        mount_point: /var/www
        filesystem: ext4
        mount_options: defaults
        dump: 1
        passno: 2

      - name: lv_logs
        size: 1G
        mount_point: /var/log/apps
        filesystem: xfs
        mount_options: defaults,noatime
        dump: 1
        passno: 2

      - name: lv_backup
        size: 1G
        mount_point: /backup
        filesystem: ext4
        mount_options: defaults
        dump: 1
        passno: 2

  tasks:

    - name: Install required packages
      package:
        name:
          - lvm2
          - parted
          - xfsprogs
        state: present

    - name: Create partition
      parted:
        device: "{{ target_disk }}"
        number: 1
        state: present
        part_type: primary
        part_start: 0%
        part_end: 100%
        flags: [lvm]

    - name: Create volume group
      lvg:
        vg: "{{ volume_group_name }}"
        pvs: "{{ target_disk }}1"

    - name: Create logical volumes
      lvol:
        vg: "{{ volume_group_name }}"
        lv: "{{ item.name }}"
        size: "{{ item.size }}"
      loop: "{{ logical_volumes }}"

    - name: Create mount directories
      file:
        path: "{{ item.mount_point }}"
        state: directory
        mode: '0755'
      loop: "{{ logical_volumes }}"

    - name: Format filesystems
      filesystem:
        fstype: "{{ item.filesystem }}"
        dev: "/dev/{{ volume_group_name }}/{{ item.name }}"
      loop: "{{ logical_volumes }}"

    - name: Mount logical volumes
      mount:
        path: "{{ item.mount_point }}"
        src: "/dev/{{ volume_group_name }}/{{ item.name }}"
        fstype: "{{ item.filesystem }}"
        opts: "{{ item.mount_options }}"
        dump: "{{ item.dump }}"
        passno: "{{ item.passno }}"
        state: mounted
      loop: "{{ logical_volumes }}"

    - name: Create test files
      copy:
        content: |
          Storage automation successful!
          Volume: {{ item.name }}
        dest: "{{ item.mount_point }}/storage_test.txt"
      loop: "{{ logical_volumes }}"
EOF
```

---

## ▶️ Subtask 3.4: Run Complete Storage Automation

```bash
ansible-playbook -i inventory/hosts playbooks/complete-storage-automation.yml
```

---

## ✅ Subtask 3.5: Verify Persistent Mounting

```bash
sudo umount /var/www /var/log/apps /backup

df -h | grep vg_data

sudo mount -a

df -h | grep vg_data

ls -la /var/www/storage_test.txt
ls -la /var/log/apps/storage_test.txt
ls -la /backup/storage_test.txt
```

---

# 🛠️ Troubleshooting Tips

## ❌ Disk Not Found

```bash
lsblk
```

Update the `target_disk` variable if necessary.

---

## ❌ Volume Group Already Exists

```bash
sudo vgremove vg_data
sudo pvremove /dev/sdb1
```

---

## ❌ Mount Point Already In Use

```bash
sudo lsof /var/www
sudo umount /var/www
```

---

## ❌ Filesystem Already Exists

```bash
sudo blkid /dev/vg_data/lv_web
```

Use:

```yaml
force: yes
```

inside the filesystem module if required.

---

# 🔍 Verification Commands

## Check Physical Volumes

```bash
sudo pvs
```

## Check Volume Groups

```bash
sudo vgs
```

## Check Logical Volumes

```bash
sudo lvs
```

## Check Mounted Filesystems

```bash
mount | grep vg_data
```

## Check fstab Entries

```bash
grep vg_data /etc/fstab
```

## Test Write Access

```bash
echo "test" | sudo tee /var/www/write_test.txt
```

---

# 📈 Storage Monitoring Script

```bash
cat > ~/check-storage.sh << 'EOF'
#!/bin/bash

echo "=== Storage Health Check ==="
echo "Date: $(date)"

echo
echo "=== Disk Usage ==="
df -h | grep -E "(Filesystem|vg_data)"

echo
echo "=== LVM Status ==="
sudo vgs
sudo lvs

echo
echo "=== Mount Status ==="
mount | grep vg_data
EOF

chmod +x ~/check-storage.sh
```

---

# 🔐 Best Practices for Storage Automation

## 🛡️ Security Considerations

- Always backup `/etc/fstab`
- Use proper filesystem permissions
- Implement secure access controls
- Monitor disk usage regularly

---

## ⚡ Performance Optimization

- Use `ext4` for general workloads
- Use `xfs` for large files
- Use `noatime` for log directories
- Plan logical volume sizes carefully

---

# 🎉 Conclusion

In this lab, you successfully learned how to:

✅ Automate disk partitioning with Ansible  
✅ Create and manage logical volumes using LVM  
✅ Format filesystems automatically  
✅ Configure persistent mounting via `/etc/fstab`  
✅ Build reusable enterprise-grade storage automation  

---

# 🌟 Why This Matters

Storage automation is essential because it:

✔️ Reduces human error  
✔️ Ensures consistent configurations  
✔️ Speeds up deployments  
✔️ Enables Infrastructure as Code (IaC)  
✔️ Simplifies enterprise scaling  

---

# 🚀 Next Steps

Continue learning:

- LVM snapshots
- Storage encryption
- Disaster recovery automation
- AWS EBS automation
- Azure Disk automation
- Storage monitoring solutions

---

# 🏆 RHCE Exam Relevance

This lab supports:

- RHCE Storage Management Objectives
- Linux System Administration
- Enterprise Automation
- Infrastructure as Code

---

# 📚 Technologies Used

| Technology | Purpose |
|---|---|
| Ansible | Automation |
| Linux | Operating System |
| LVM | Logical Volume Management |
| ext4/xfs | Filesystems |
| YAML | Configuration |
