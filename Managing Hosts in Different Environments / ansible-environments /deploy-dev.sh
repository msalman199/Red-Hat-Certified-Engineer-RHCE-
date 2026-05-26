#!/bin/bash

echo "=== Deploying to Development Environment ==="
echo "Environment: Development"
echo "Inventory: inventories/dev/hosts"
echo "=========================================="

# Deploy application to development
ansible-playbook -i inventories/dev/hosts playbooks/deploy-app.yml \
  --tags "setup,deploy,config" \
  --extra-vars "target_env=dev"

# Configure database for development
ansible-playbook -i inventories/dev/hosts playbooks/configure-database.yml \
  --tags "database,setup" \
  --extra-vars "target_env=dev"

echo "=== Development deployment completed ==="
EOF
