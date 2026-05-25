# 🐧 Review of RHCSA Core Concepts 

<div align="center">

![RHCSA](https://img.shields.io/badge/RHCSA-Core_Concepts-red?style=for-the-badge&logo=redhat)
![Linux](https://img.shields.io/badge/Linux-System_Administration-blue?style=for-the-badge&logo=linux)
![Security](https://img.shields.io/badge/Linux-Security-green?style=for-the-badge&logo=gnuprivacyguard)
![Systemctl](https://img.shields.io/badge/Systemctl-Service_Management-orange?style=for-the-badge)

# 📚 Complete RHCSA Core Concepts Practice 

</div>

---

# 📘 Overview

This lab provides hands-on practice for essential RHCSA core concepts including:

- 👤 User management
- ⚙️ Service management
- 🔐 File permissions
- 🛡️ Ownership management
- 🐧 Linux security fundamentals

Students will gain practical experience with real-world Linux administration tasks commonly used in enterprise environments.

---

# 🎯 Objectives

By the end of this lab, students will be able to:

| ✅ Skills | 📘 Description |
|---|---|
| 👤 User Management | Create and manage Linux user accounts |
| ⚙️ Service Management | Configure and control services using `systemctl` |
| 🔐 File Permissions | Modify permissions using `chmod` |
| 🛡️ Ownership Management | Change ownership using `chown` |
| 🔒 Linux Security | Understand Linux security relationships |
| 🧪 Practical Administration | Apply RHCSA concepts in real-world scenarios |

---

# 📋 Prerequisites

Before starting this lab, students should have:

- 🛠️ Basic Linux command line knowledge
- 🛠️ Familiarity with terminal navigation commands
- 🛠️ Basic text editor knowledge (`nano` or `vi`)
- 🛠️ Understanding of Linux file system hierarchy
- 🛠️ Access to a Linux machine with sudo privileges

---

# ☁️ Lab Environment Setup

## 🖥️ Ready-to-Use Cloud Machines

| 🖥️ Component | 📘 Description |
|---|---|
| 🐧 Operating System | RHEL 9 or CentOS Stream 9 |
| 🔑 Access | Root privileges available |
| ⚙️ Tools | Pre-installed system utilities |
| 🌐 Connectivity | Internet access enabled |

---

# 🚀 Task 1: User Management with useradd and passwd

---

# 🔹 Subtask 1.1: Creating Basic User Accounts

## 🛠️ Tool: View Existing Users

```bash
cat /etc/passwd | tail -5
```

---

## 🛠️ Tool: Create a Basic User

```bash
sudo useradd student1
```

---

## 🛠️ Tool: Verify User Creation

```bash
id student1
```

---

## 🛠️ Tool: Check User Home Directory

```bash
ls -la /home/student1
```

---

# 🔹 Subtask 1.2: Setting User Passwords

## 🛠️ Tool: Set User Password

```bash
sudo passwd student1
```

> ⚠️ Use a secure password with at least 8 characters.

---

## 🛠️ Tool: Switch to the User

```bash
su - student1
```

---

## 🛠️ Tool: Return to Previous User

```bash
exit
```

---

# 🔹 Subtask 1.3: Creating Users with Custom Options

## 🛠️ Tool: Create User with Custom Home Directory

```bash
sudo useradd -d /home/custom_user -m developer1
```

---

## 🛠️ Tool: Create User with Specific Shell

```bash
sudo useradd -s /bin/bash -m analyst1
```

---

## 🛠️ Tool: Create Group and Add User

```bash
sudo groupadd projectteam
sudo useradd -G projectteam -m manager1
```

---

## 🛠️ Tool: Set Passwords for New Users

```bash
sudo passwd developer1
sudo passwd analyst1
sudo passwd manager1
```

---

## 🛠️ Tool: Verify User Configurations

```bash
grep -E "(developer1|analyst1|manager1)" /etc/passwd
```

---

# 🔹 Subtask 1.4: User Account Modification

## 🛠️ Tool: Change User Shell

```bash
sudo usermod -s /bin/zsh student1
```

---

## 🛠️ Tool: Add User to Additional Group

```bash
sudo usermod -aG projectteam student1
```

---

## 🛠️ Tool: Lock User Account

```bash
sudo usermod -L developer1
```

---

## 🛠️ Tool: Unlock User Account

```bash
sudo usermod -U developer1
```

---

## 🛠️ Tool: Verify Modifications

```bash
grep student1 /etc/passwd
groups student1
```

---

# 🚀 Task 2: System Service Management with systemctl

---

# 🔹 Subtask 2.1: Checking Service Status

## 🛠️ Tool: Check SSH Service Status

```bash
sudo systemctl status sshd
```

---

## 🛠️ Tool: List Active Services

```bash
sudo systemctl list-units --type=service --state=active
```

---

## 🛠️ Tool: Check if Service is Enabled

```bash
sudo systemctl is-enabled sshd
```

---

## 🛠️ Tool: Check if Service is Running

```bash
sudo systemctl is-active sshd
```

---

# 🔹 Subtask 2.2: Starting and Stopping Services

## 🛠️ Tool: Install Apache HTTP Server

```bash
sudo dnf install -y httpd
```

---

## 🛠️ Tool: Check httpd Status

```bash
sudo systemctl status httpd
```

---

## 🛠️ Tool: Start httpd Service

```bash
sudo systemctl start httpd
```

---

## 🛠️ Tool: Verify Service Running State

```bash
sudo systemctl is-active httpd
```

---

## 🛠️ Tool: Stop httpd Service

```bash
sudo systemctl stop httpd
```

---

## 🛠️ Tool: Restart httpd Service

```bash
sudo systemctl restart httpd
```

---

# 🔹 Subtask 2.3: Enabling and Disabling Services

## 🛠️ Tool: Enable Service at Boot

```bash
sudo systemctl enable httpd
```

---

## 🛠️ Tool: Verify Service Enablement

```bash
sudo systemctl is-enabled httpd
```

---

## 🛠️ Tool: Enable and Start Service

```bash
sudo systemctl enable --now httpd
```

---

## 🛠️ Tool: Disable Service

```bash
sudo systemctl disable httpd
```

---

## 🛠️ Tool: View Service Dependencies

```bash
sudo systemctl list-dependencies httpd
```

---

# 🔹 Subtask 2.4: Service Logs and Configuration

## 🛠️ Tool: View Service Logs

```bash
sudo journalctl -u httpd
```

---

## 🛠️ Tool: View Recent Logs

```bash
sudo journalctl -u httpd --since "1 hour ago"
```

---

## 🛠️ Tool: Follow Logs in Real-Time

```bash
sudo journalctl -u httpd -f
```

> ⚠️ Press `Ctrl + C` to stop following logs.

---

## 🛠️ Tool: View Service Configuration

```bash
sudo systemctl cat httpd
```

---

# 🚀 Task 3: File Permissions and Ownership Management

---

# 🔹 Subtask 3.1: Understanding Current Permissions

## 🛠️ Tool: Create Test Directory Structure

```bash
mkdir -p /tmp/lab_files
cd /tmp/lab_files
```

---

## 🛠️ Tool: Create Test Files and Directories

```bash
touch file1.txt file2.txt file3.txt
mkdir dir1 dir2
```

---

## 🛠️ Tool: Check Current Permissions

```bash
ls -la
```

---

## 🛠️ Tool: Understand Permission Format

```bash
ls -l file1.txt
```

### 📖 Permission Format

| Symbol | Meaning |
|---|---|
| `-` | Regular file |
| `d` | Directory |
| `r` | Read permission |
| `w` | Write permission |
| `x` | Execute permission |

---

# 🔹 Subtask 3.2: Modifying Permissions with chmod

## 🛠️ Tool: Set Permissions Using Octal Notation

```bash
chmod 755 file1.txt
ls -l file1.txt
```

---

## 🛠️ Tool: Add Execute Permission

```bash
chmod u+x file2.txt
ls -l file2.txt
```

---

## 🛠️ Tool: Remove Group Write Permission

```bash
chmod g-w file2.txt
ls -l file2.txt
```

---

## 🛠️ Tool: Set Multiple Permissions

```bash
chmod u+rw,g+r,o-rwx file3.txt
ls -l file3.txt
```

---

## 🛠️ Tool: Apply Recursive Permissions

```bash
chmod -R 644 dir1/
ls -la dir1/
```

---

# 🔹 Subtask 3.3: Advanced Permission Scenarios

## 🛠️ Tool: Create Shared Directory

```bash
mkdir /tmp/shared_project
chmod 775 /tmp/shared_project
```

---

## 🛠️ Tool: Set Sticky Bit

```bash
chmod +t /tmp/shared_project
ls -ld /tmp/shared_project
```

---

## 🛠️ Tool: Set SGID Permission

```bash
chmod g+s /tmp/shared_project
ls -ld /tmp/shared_project
```

---

## 🛠️ Tool: Create Public File

```bash
touch /tmp/shared_project/public_file.txt
chmod 644 /tmp/shared_project/public_file.txt
```

---

## 🛠️ Tool: Create Private File

```bash
touch /tmp/shared_project/private_file.txt
chmod 600 /tmp/shared_project/private_file.txt
```

---

## 🛠️ Tool: Create Executable Script

```bash
touch /tmp/shared_project/executable_script.sh
chmod 755 /tmp/shared_project/executable_script.sh
```

---

# 🔹 Subtask 3.4: Changing Ownership with chown

## 🛠️ Tool: Check Current Ownership

```bash
ls -la /tmp/lab_files/
```

---

## 🛠️ Tool: Change File Owner

```bash
sudo chown student1 /tmp/lab_files/file1.txt
ls -l /tmp/lab_files/file1.txt
```

---

## 🛠️ Tool: Change Owner and Group

```bash
sudo chown student1:projectteam /tmp/lab_files/file2.txt
ls -l /tmp/lab_files/file2.txt
```

---

## 🛠️ Tool: Change Ownership Recursively

```bash
sudo chown -R manager1:projectteam /tmp/lab_files/dir1/
ls -la /tmp/lab_files/dir1/
```

---

## 🛠️ Tool: Change Group Ownership

```bash
sudo chgrp projectteam /tmp/lab_files/file3.txt
ls -l /tmp/lab_files/file3.txt
```

---

# 🔹 Subtask 3.5: Practical Security Scenarios

## 🛠️ Tool: Create Secure Log Directory

```bash
sudo mkdir /var/log/myapp
sudo chown manager1:projectteam /var/log/myapp
sudo chmod 775 /var/log/myapp
```

---

## 🛠️ Tool: Create Restricted Configuration File

```bash
sudo touch /etc/myapp.conf
sudo chown root:projectteam /etc/myapp.conf
sudo chmod 640 /etc/myapp.conf
```

---

## 🛠️ Tool: Create Shared Workspace

```bash
sudo mkdir /opt/workspace
sudo chown :projectteam /opt/workspace
sudo chmod 2775 /opt/workspace
```

---

## 🛠️ Tool: Verify Security Configurations

```bash
ls -ld /var/log/myapp /etc/myapp.conf /opt/workspace
```

---

# 🚨 Troubleshooting Tips

---

# 🔹 Common User Management Issues

| ⚠️ Issue | 🛠️ Solution |
|---|---|
| Permission denied | Use `sudo` or root account |
| User already exists | Check `/etc/passwd` |
| Weak password error | Use strong passwords |

---

# 🔹 Common Service Management Issues

| ⚠️ Issue | 🛠️ Solution |
|---|---|
| Service won't start | Check logs with `journalctl` |
| Port already in use | Use `netstat -tulpn` |
| Service not found | Verify package installation |

---

# 🔹 Common Permission Issues

| ⚠️ Issue | 🛠️ Solution |
|---|---|
| Permission denied | Verify permissions using `ls -l` |
| Cannot change ownership | Use `sudo` |
| Recursive change failed | Use `-R` option |

---

# 🧪 Verification Commands

## 🛠️ Tool: Verify Created Users

```bash
cut -d: -f1 /etc/passwd | grep -E "(student1|developer1|analyst1|manager1)"
```

---

## 🛠️ Tool: Verify Service Status

```bash
sudo systemctl is-active httpd
sudo systemctl is-enabled httpd
```

---

## 🛠️ Tool: Verify File Permissions and Ownership

```bash
ls -la /tmp/lab_files/
ls -ld /var/log/myapp /etc/myapp.conf /opt/workspace
```

---

# 📚 Useful Commands Reference

| 💻 Command | 📘 Description |
|---|---|
| `useradd` | Create new user |
| `passwd` | Set user password |
| `usermod` | Modify user account |
| `systemctl` | Manage services |
| `journalctl` | View service logs |
| `chmod` | Change permissions |
| `chown` | Change ownership |
| `chgrp` | Change group ownership |

---

# 🏁 Conclusion

In this lab, you successfully reviewed and practiced:

- ✅ User management with `useradd`, `passwd`, and `usermod`
- ✅ Service management with `systemctl`
- ✅ File permissions using `chmod`
- ✅ Ownership management with `chown`
- ✅ Linux security best practices

These RHCSA core concepts form the foundation of enterprise Linux system administration and are essential for real-world production environments.

---

# 🔑 Key Takeaways

| 💡 Concept | 📘 Importance |
|---|---|
| User Management | Controls system access and security |
| Service Management | Maintains system reliability |
| File Permissions | Protects sensitive data |
| Ownership Management | Controls access rights |
| Linux Security | Ensures system integrity |


## 🚀 You are now ready to apply RHCSA core Linux administration concepts in enterprise environments.

</div>
