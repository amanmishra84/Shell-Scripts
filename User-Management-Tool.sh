#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
    exit 1
fi

# Function to add a new user
add_user() {
    echo "Enter username to add:"
    read username
    if id "$username" &>/dev/null; then
        echo "User $username already exists."
    else
        useradd "$username"
        if [ $? -eq 0 ]; then
            echo "User $username added successfully."
            passwd "$username"
        else
            echo "Failed to add user $username."
        fi
    fi
}

# Function to modify an existing user
modify_user() {
    echo "Enter username to modify:"
    read username
    if id "$username" &>/dev/null; then
        echo "Enter new username:"
        read new_username
        usermod -l "$new_username" "$username"
        if [ $? -eq 0 ]; then
            echo "User $username modified to $new_username successfully."
        else
            echo "Failed to modify user $username."
        fi
    else
        echo "User $username does not exist."
    fi
}

# Function to delete a user
delete_user() {
    echo "Enter username to delete:"
    read username
    if id "$username" &>/dev/null; then
        userdel "$username"
        if [ $? -eq 0 ]; then
            echo "User $username deleted successfully."
        else
            echo "Failed to delete user $username."
        fi
    else
        echo "User $username does not exist."
    fi
}

# Function to set password policies
set_password_policy() {
    echo "Setting password policy..."
    echo "Enter minimum password length (e.g., 8):"
    read min_length
    echo "Enter password expiration days (e.g., 90):"
    read expiration_days

    sed -i "s/^PASS_MIN_LEN.*/PASS_MIN_LEN $min_length/" /etc/login.defs
    sed -i "s/^PASS_MAX_DAYS.*/PASS_MAX_DAYS $expiration_days/" /etc/login.defs

    echo "Password policies updated:"
    echo "Minimum password length: $min_length"
    echo "Password expiration days: $expiration_days"
}

# Function to manage user permissions
manage_permissions() {
    echo "Enter username to manage permissions for:"
    read username
    if id "$username" &>/dev/null; then
        echo "Enter directory to change ownership:"
        read directory
        echo "Enter ownership (e.g., username:group):"
        read ownership
        chown "$ownership" "$directory"
        if [ $? -eq 0 ]; then
            echo "Ownership of $directory changed to $ownership."
        else
            echo "Failed to change ownership of $directory."
        fi
    else
        echo "User $username does not exist."
    fi
}

# Main menu
while true; do
    echo
    echo "User Account Management Tool"
    echo "1. Add User"
    echo "2. Modify User"
    echo "3. Delete User"
    echo "4. Set Password Policies"
    echo "5. Manage User Permissions"
    echo "6. Exit"
    echo "Enter your choice:"
    read choice

    case $choice in
        1) add_user ;;
        2) modify_user ;;
        3) delete_user ;;
        4) set_password_policy ;;
        5) manage_permissions ;;
        6) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid choice. Please try again." ;;
    esac
done

