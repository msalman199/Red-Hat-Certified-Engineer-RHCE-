#!/bin/bash

echo "=== Ansible Troubleshooting Checklist ==="
echo

echo "1. Checking Ansible version:"
ansible --version
echo

echo "2. Checking inventory:"
ansible-inventory --list -i /etc/ansible/hosts
echo

echo "3. Testing connectivity:"
ansible all -i /etc/ansible/hosts -m ping
echo

echo "4. Checking SSH connectivity:"
ansible all -i /etc/ansible/hosts -m command -a "whoami"
echo

echo "5. Testing privilege escalation:"
ansible all -i /etc/ansible/hosts -m command -a "whoami" --become
echo

echo "6. Checking disk space on control node:"
df -h
echo

echo "7. Checking memory usage:"
free -h
echo

echo "=== Troubleshooting complete ==="
EOF
