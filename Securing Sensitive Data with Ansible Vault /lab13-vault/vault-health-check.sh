#!/bin/bash

echo "Ansible Vault Health Check"
echo "=========================="

# Check if vault password file exists
if [ -f ~/.ansible/vault/lab13_pass ]; then
    echo "✓ Vault password file exists"
else
    echo "✗ Vault password file missing"
fi

# Check vault files
VAULT_FILES=("secrets.yml" "prod-secrets.yml" "user-secrets.yml" "dev-secrets.yml" "prod-secrets-multi.yml")

for file in "${VAULT_FILES[@]}"; do
    if [ -f "$file" ]; then
        if ansible-vault view "$file" --vault-password-file ~/.ansible/vault/lab13_pass > /dev/null 2>&1; then
            echo "✓ $file - encrypted and accessible"
        else
            echo "✗ $file - encryption issue or wrong password"
        fi
    else
        echo "- $file - not found (may be optional)"
    fi
done

# Check ansible.cfg
if [ -f "ansible.cfg" ]; then
    echo "✓ ansible.cfg exists"
else
    echo "✗ ansible.cfg missing"
fi

echo ""
echo "Health check completed"
