#!/bin/bash

ENVIRONMENT=${1:-development}
PLAYBOOK=${2:-playbooks/configure-environments.yml}

echo "Deploying to $ENVIRONMENT environment..."

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(development|staging|production)$ ]]; then
    echo "Error: Invalid environment. Use: development, staging, or production"
    exit 1
fi

# Run deployment
ansible-playbook $PLAYBOOK --limit $ENVIRONMENT -v

# Verify deployment
echo "Verifying deployment..."
ansible $ENVIRONMENT -m shell -a "cat /etc/scalable-web-app/monitoring.conf | grep environment"

echo "Deployment to $ENVIRONMENT completed!"
EOF
