#!/bin/bash

echo "=== Deploying to Production Environment ==="
echo "Environment: Production"
echo "Inventory: inventories/prod/hosts"
echo "WARNING: This will deploy to PRODUCTION!"
echo "=========================================="

read -p "Are you sure you want to deploy to production? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Production deployment cancelled."
    exit 1
fi

# Deploy application to production
ansible-playbook -i inventories/prod/hosts playbooks/deploy-app.yml \
  --tags "setup,deploy,config,security,webserver" \
  --extra-vars "target_env=prod" \
  --check

read -p "Dry run completed. Proceed with actual deployment? (yes/no): " proceed
if [ "$proceed" != "yes" ]; then
    echo "Production deployment cancelled."
    exit 1
fi

# Actual deployment
ansible-playbook -i inventories/prod/hosts playbooks/deploy-app.yml \
  --tags "setup,deploy,config,security,webserver" \
  --extra-vars "target_env=prod"

# Configure database for production
ansible-playbook -i inventories/prod/hosts playbooks/configure-database.yml \
  --tags "database,setup,backup" \
  --extra-vars "target_env=prod"

echo "=== Production deployment completed ==="
EOF

chmod +x deploy-prod.sh
