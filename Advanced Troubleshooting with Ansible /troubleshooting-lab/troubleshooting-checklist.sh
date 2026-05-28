#!/bin/bash

echo "=== ANSIBLE TROUBLESHOOTING CHECKLIST ==="
echo ""

echo "1. SYNTAX CHECK:"
echo "   ansible-playbook playbook.yml --syntax-check"
echo ""

echo "2. DRY RUN (CHECK MODE):"
echo "   ansible-playbook -i inventory playbook.yml --check"
echo ""

echo "3. DRY RUN WITH DIFF:"
echo "   ansible-playbook -i inventory playbook.yml --check --diff"
echo ""

echo "4. STEP-BY-STEP EXECUTION:"
echo "   ansible-playbook -i inventory playbook.yml --step"
echo ""

echo "5. VERBOSE OUTPUT:"
echo "   ansible-playbook -i inventory playbook.yml -v"
echo "   (Use -vv, -vvv, or -vvvv for more verbosity)"
echo ""

echo "6. CONNECTION TEST:"
echo "   ansible -i inventory all -m ping"
echo ""

echo "7. FACT GATHERING:"
echo "   ansible -i inventory all -m setup"
echo ""

echo "8. SPECIFIC HOST TARGETING:"
echo "   ansible-playbook -i inventory playbook.yml --limit hostname"
echo ""

echo "9. TAG-BASED EXECUTION:"
echo "   ansible-playbook -i inventory playbook.yml --tags tag_name"
echo ""

echo "10. LIST TASKS:"
echo "    ansible-playbook -i inventory playbook.yml --list-tasks"
echo ""

echo "11. LIST HOSTS:"
echo "    ansible-playbook -i inventory playbook.yml --list-hosts"
echo ""

echo "12. COMMON DEBUG PATTERNS:"
echo "    - Use debug module with 'var:' for variables"
echo "    - Use debug module with 'msg:' for custom messages"
echo "    - Register task results and debug them"
echo "    - Use 'ignore_errors: yes' for non-critical tasks"
echo "    - Use 'failed_when:' for custom failure conditions"
echo ""
