#!/bin/bash

WARNING="\e[31m"
SUCCESS="\e[32m"
CLEAR="\e[1;33m"

echo "Welcome to Laurels High School!"
echo "Kindly create your account"

read -p "Enter a username: " username
# Check if the username is already taken
function check_username {
  useradd -n $1 >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo "Username '$1' is already taken. Please choose a different username."
    return 1
  fi
}
check_username $username


# prompt for password
echo "Password must be at least 8 characters long and include an uppercase, lowercase, number and special characters): "
echo "Enter a strong password(hidden):"
read -s password

echo "Confirm your password match: "
read -s password2

# Define and ensure password condtions are met 

# Check password match
if [[ $password != $password2 ]]; then
  echo -e $WARNING"Password does not match."$CLEAR
else
  echo -e $SUCCESS"Password matches."$CLEAR
fi 

# check for length
if [[ ${#password} -ge 8 ]]; then
  echo -e $SUCCESS"+Password length is good."$CLEAR
else
  echo -e $WARNING"-Password must be at least 8 characters long."$CLEAR
fi

#check for special characters
if [[ $password =~ [[:punct:]] ]]; then
  echo -e $SUCCESS"+Password has a special character."$CLEAR
else
  echo -e $WARNING"-Password must include at least one special character (!@#$%^&*()+)."$CLEAR
fi

#check for upper and lower case letters
if [[ $password =~ [[:upper:]] && $password =~ [[:lower:]] ]]; then
  echo -e $SUCCESS"+Password contains both uppercase and lowercase letters."$CLEAR
else
  echo -e $WARNING"-Password should contain both uppercase and lowercase letters."$CLEAR
fi

# check for digits
if [[ $password =~ [[:digit:]] ]]; then
  echo -e $SUCCESS"+Password contains at least one digit."$CLEAR
else
  echo -e $WARNING"-Password should contain at least one digit."$CLEAR
fi

# Final check to ensure all requirements are met
function validate_password {
  if [[ ${#password} -ge 8 && "$password" =~ [[:punct:]] && $password =~ [[:upper:]] && $password =~ [[:lower:]] && $password =~ [[:digit:]] && $password == $password2 ]]; then
    echo -e "$SUCCESS Password is strong!"$CLEAR
    echo "Account created successfully!"
    sudo useradd -m -p $username "$password"
    echo -e "Username: $username"
    echo -e "User ID: $(id -u "$username")"
  else
    echo -e "$WARNING Error creating password. kindly comply with the requirements"$CLEAR
  fi
}
validate_password $password


