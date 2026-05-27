#!/bin/bash

# Ansible Vault Management Script
# Usage: ./vault_manager.sh [create|edit|view|encrypt|decrypt] [filename]

VAULT_PASSWORD_FILE=".vault_password"

function show_usage() {
    echo "Usage: $0 [create|edit|view|encrypt|decrypt|rekey] [filename]"
    echo "Examples:"
    echo "  $0 create new_secrets.yml"
    echo "  $0 edit db_secrets.yml"
    echo "  $0 view staging_secrets.yml"
    echo "  $0 encrypt plain_file.yml"
    echo "  $0 decrypt encrypted_file.yml"
    echo "  $0 rekey old_secrets.yml"
}

if [ $# -lt 2 ]; then
    show_usage
    exit 1
fi

ACTION=$1
FILENAME=$2

case $ACTION in
    create)
        echo "Creating new encrypted file: $FILENAME"
        ansible-vault create "$FILENAME" --vault-password-file "$VAULT_PASSWORD_FILE"
        ;;
    edit)
        echo "Editing encrypted file: $FILENAME"
        ansible-vault edit "$FILENAME" --vault-password-file "$VAULT_PASSWORD_FILE"
        ;;
    view)
        echo "Viewing encrypted file: $FILENAME"
        ansible-vault view "$FILENAME" --vault-password-file "$VAULT_PASSWORD_FILE"
        ;;
    encrypt)
        echo "Encrypting plain file: $FILENAME"
        ansible-vault encrypt "$FILENAME" --vault-password-file "$VAULT_PASSWORD_FILE"
        ;;
    decrypt)
        echo "Decrypting file: $FILENAME"
        ansible-vault decrypt "$FILENAME" --vault-password-file "$VAULT_PASSWORD_FILE"
        ;;
    rekey)
        echo "Changing password for: $FILENAME"
        ansible-vault rekey "$FILENAME" --vault-password-file "$VAULT_PASSWORD_FILE"
        ;;
    *)
        echo "Unknown action: $ACTION"
        show_usage
        exit 1
        ;;
esac
