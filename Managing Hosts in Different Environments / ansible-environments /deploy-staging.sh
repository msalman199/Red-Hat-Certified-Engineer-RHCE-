#!/bin/bash

echo "=== Deploying to Staging Environment ==="
echo "Environment: Staging"
echo "Inventory: inventories/staging/hosts"
echo "======================================="

# Deploy application to staging
ansible-playbook -i inventories/staging/hosts playbooks/deploy-app.yml \
  --tags "setup,deploy,config,security" \
  --extra-vars "target_env=staging"

# Configure database for staging
ansible-playbook -i inventories/staging/hosts playbooks/configure-database.yml \
  --tags "database,setup,backup" \
  --extra-vars "target_env=staging"

echo "=== Staging deployment completed ==="
EOF
