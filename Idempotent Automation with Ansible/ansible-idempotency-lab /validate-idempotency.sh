#!/bin/bash

# Idempotency Validation Script
echo "=== Ansible Idempotency Validation ==="
echo "Testing playbook: $1"

if [ -z "$1" ]; then
    echo "Usage: $0 <playbook-name.yml>"
    exit 1
fi

PLAYBOOK=$1
TEMP_DIR="/tmp/idempotency-test-$(date +%s)"
mkdir -p $TEMP_DIR

echo "Running playbook first time..."
ansible-playbook $PLAYBOOK > $TEMP_DIR/run1.log 2>&1
FIRST_EXIT_CODE=$?

echo "Running playbook second time..."
ansible-playbook $PLAYBOOK > $TEMP_DIR/run2.log 2>&1
SECOND_EXIT_CODE=$?

echo "Analyzing results..."

# Count changed tasks in each run
CHANGED_RUN1=$(grep -c "changed:" $TEMP_DIR/run1.log || echo "0")
CHANGED_RUN2=$(grep -c "changed:" $TEMP_DIR/run2.log || echo "0")

# Count failed tasks
FAILED_RUN1=$(grep -c "failed:" $TEMP_DIR/run1.log || echo "0")
FAILED_RUN2=$(grep -c "failed:" $TEMP_DIR/run2.log || echo "0")

echo "=== RESULTS ==="
echo "First run - Exit code: $FIRST_EXIT_CODE, Changed tasks: $CHANGED_RUN1, Failed tasks: $FAILED_RUN1"
echo "Second run - Exit code: $SECOND_EXIT_CODE, Changed tasks: $CHANGED_RUN2, Failed tasks: $FAILED_RUN2"

if [ $SECOND_EXIT_CODE -eq 0 ] && [ $CHANGED_RUN2 -eq 0 ] && [ $FAILED_RUN2 -eq 0 ]; then
    echo "✅ IDEMPOTENCY TEST PASSED"
    echo "The playbook is idempotent - no changes on second run"
else
    echo "❌ IDEMPOTENCY TEST FAILED"
    echo "The playbook made changes or had errors on second run"
    echo "Check logs in: $TEMP_DIR"
fi

echo "Detailed logs available in: $TEMP_DIR"
