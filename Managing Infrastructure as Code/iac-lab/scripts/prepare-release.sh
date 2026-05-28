#!/bin/bash

# Infrastructure Release Preparation Script
set -e

echo "=== Infrastructure Release Preparation ==="

# Read current version
source VERSION

echo "Current version: $VERSION"

# Validate playbooks
echo "Validating Ansible playbooks..."
for playbook in playbooks/*.yml; do
    echo "Checking $playbook..."
    ansible-playbook "$playbook" --syntax-check
done

# Run tests
echo "Running infrastructure tests..."
ansible-playbook playbooks/test-infrastructure.yml --check

# Generate changelog
echo "Generating changelog..."
git log --oneline --since="$(git describe --tags --abbrev=0 2>/dev/null || echo '1 month ago')" > CHANGELOG.tmp
