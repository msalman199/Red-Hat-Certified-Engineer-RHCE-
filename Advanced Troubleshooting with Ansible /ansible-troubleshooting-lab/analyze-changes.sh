#!/bin/bash

PLAYBOOK="$1"
LOGFILE="changes-$(date +%Y%m%d-%H%M%S).log"

echo "=== Ansible Diff Analysis ===" | tee "$LOGFILE"
echo "Playbook: $PLAYBOOK" | tee -a "$LOGFILE"
echo "Timestamp: $(date)" | tee -a "$LOGFILE"
echo "================================" | tee -a "$LOGFILE"

# Run with diff and capture output
ansible-playbook "$PLAYBOOK" --diff --check 2>&1 | tee -a "$LOGFILE"

echo "================================" | tee -a "$LOGFILE"
echo "Analysis complete. Log saved to: $LOGFILE" | tee -a "$LOGFILE"

# Extract changed files
echo "Files that would be modified:" | tee -a "$LOGFILE"
grep -E "^\+\+\+|^---" "$LOGFILE" | sort | uniq | tee -a "$LOGFILE"
EOF

chmod +x analyze-changes.sh

# Use the analysis script
./analyze-changes.sh complex-deployment.yml
