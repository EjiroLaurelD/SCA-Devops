#!/bin/bash

# Prompt the user for a username
read -p "Enter a username: " username

# Check if the username is already taken
function check_username {
  useradd -n $1 >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo "Username '$1' is already taken. Please choose a different username."
    exit 1
  fi
}

check_username $username

# Prompt the user for a strong password

function validate_password {
  if [ ${#password} -lt 8 ]; then
    echo "Password must be at least 8 characters long."
    exit 1
  fi

  if ! [[ $password =~ ^[a-zA-Z0-9!@#$%^&*()-_+={}[]:\;"/?.>,<]+$ ]]; then
    echo "Password must contain at least one uppercase letter, one lowercase letter, one number, and one symbol."
    exit 1
  fi
}

read -p "Enter a strong password: " password

validate_password $password

# Create the user account securely
useradd -m -p $(openssl passwd -1 $password) $username

# Inform the user that the account has been created successfully
echo "Account created successfully for user '$username'."
