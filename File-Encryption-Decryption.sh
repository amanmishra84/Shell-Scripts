#!/bin/bash

# File Encryption/Decryption Tool

# Function to encrypt a file
encrypt_file() {
    local input_file=$1
    local output_file="$input_file.enc"

    read -sp "Enter passphrase for encryption: " passphrase
    echo

    openssl enc -aes-256-cbc -salt -in "$input_file" -out "$output_file" -pass pass:"$passphrase"

    if [ $? -eq 0 ]; then
        echo "File successfully encrypted: $output_file"
    else
        echo "Error encrypting file."
    fi
}

# Function to decrypt a file
decrypt_file() {
    local input_file=$1
    local output_file="${input_file%.enc}"

    read -sp "Enter passphrase for decryption: " passphrase
    echo

    openssl enc -d -aes-256-cbc -in "$input_file" -out "$output_file" -pass pass:"$passphrase"

    if [ $? -eq 0 ]; then
        echo "File successfully decrypted: $output_file"
    else
        echo "Error decrypting file. Check your passphrase or input file."
    fi
}

# Main script logic
if [ $# -lt 2 ]; then
    echo "Usage: $0 <encrypt|decrypt> <file>"
    exit 1
fi

operation=$1
file=$2

if [ ! -f "$file" ]; then
    echo "Error: File '$file' does not exist."
    exit 1
fi

case $operation in
    encrypt)
        encrypt_file "$file"
        ;;
    decrypt)
        decrypt_file "$file"
        ;;
    *)
        echo "Invalid operation. Use 'encrypt' or 'decrypt'."
        exit 1
        ;;
esac

