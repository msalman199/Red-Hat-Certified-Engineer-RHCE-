#!/bin/bash

# Script to safely view vault files
if [ $# -eq 0 ]; then
    echo "Usage: $0 <vault-file>"
    echo "Example: $0 secrets.yml"
    exit 1
fi

VAULT_FILE=$1

if [ ! -f "$VAULT_FILE" ]; then
    echo "Error: File $VAULT_FILE not found"
    exit 1
fi

echo "Viewing contents of encrypted file: $VAULT_FILE"
echo "================================================"
ansible-vault view "$VAULT_FILE" --vault-password-file ~/.ansible/vault/lab13_pass
