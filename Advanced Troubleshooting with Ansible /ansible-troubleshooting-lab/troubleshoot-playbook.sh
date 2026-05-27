#!/bin/bash

PLAYBOOK="$1"
if [ -z "$PLAYBOOK" ]; then
    echo "Usage: $0 <playbook.yml>"
    exit 1
fi

echo "=== ANSIBLE TROUBLESHOOTING METHODOLOGY ==="
echo "Playbook: $PLAYBOOK"
echo "Timestamp: $(date)"
echo "============================================"

# Step 1: Syntax Check
echo "Step 1: Checking playbook syntax..."
ansible-playbook "$PLAYBOOK" --syntax-check
if [ $? -ne 0 ]; then
    echo "❌ Syntax errors found. Fix syntax before proceeding."
    exit 1
else
    echo "✅ Syntax check passed."
fi

# Step 2: Dry Run
echo -e "\nStep 2: Performing dry run..."
ansible
