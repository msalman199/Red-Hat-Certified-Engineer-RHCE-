#!/bin/bash

echo "=== Testing Playbook Idempotency ==="
echo "Running playbook first time..."
ansible-playbook -i inventory playbooks/webserver-setup.yml > first-run.log 2>&1

echo "Running playbook second time..."
ansible-playbook -i inventory playbooks/webserver-setup.yml > second-run.log 2>&1

echo "Checking for changes in second run..."
if grep -q "changed=0" second-run.log; then
    echo "✓ PASS: Playbook is idempotent"
else
    echo "✗ FAIL: Playbook made unexpected changes"
    echo "Changes detected:"
    grep "changed:" second-run.log
fi

echo "=== Summary ==="
echo "First run:"
grep "PLAY RECAP" -A 10 first-run.log
echo ""
echo "Second run:"
grep "PLAY RECAP" -A 10 second-run.log
EOF
