#!/bin/bash

# Script to safely edit vault files
if [ $# -eq 0 ]; then
    echo "Usage: $0 <vault-file>"
    echo "Example: $0 secrets.yml"
    exit 1
fi

VAULT_FILE=$1

echo "Editing encrypted file: $VAULT_FILE"
echo "===================================="
ansible-vault edit "$VAULT_FILE" --vault-password-file ~/.ansible/vault/lab13_pass
