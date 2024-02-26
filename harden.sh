#!/bin/bash

# Define ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to install dependencies
install_dependencies() {
    echo -e "${BLUE}Installing dependencies${NC}"
    sleep 3
    apt install figlet -y
    echo
    echo -e "${BLUE}Installing dependencies: ${GREEN}DONE${NC}"
    echo
}

# Function to create report file
create_report_file() {
    echo -e "${BLUE}Creating text file for the report${NC}"
    touch Report.txt
    echo
    echo -e "${BLUE}Reporting file created: ${GREEN}DONE${NC}"
    echo
}

# Function to configure timezone
configure_timezone() {
    echo -e "${BLUE}Configuring timezone${NC}"
    echo -e "${BLUE}Please select your timezone:${NC}"
    sleep 3
    dpkg-reconfigure tzdata
    date
    echo -e "${BLUE}Configure timezone: ${GREEN}DONE${NC}"
    echo -e "${BLUE}Configure timezone: ${GREEN}DONE${NC}" >> Report.txt
    echo
}

# Function to update the system
update_system() {
    echo -e "${BLUE}Updating the package lists and upgrading the installed packages${NC}"
    sleep 3
    apt update
    apt upgrade -y
    echo -e "${BLUE}System update and upgrade: ${GREEN}DONE${NC}"
    echo -e "${BLUE}System update and upgrade: ${GREEN}DONE${NC}" >> Report.txt
    echo
}


# Function to disable non used accounts
list_and_disable_non_used_accounts() {
    echo -e "${BLUE}Making sure non-used accounts are disabled${NC}"
    # List users with UID >= 1000
    echo -e "${ORANGE}Users with accounts on this server: ${NC}"
    awk -F: '$3 >= 1000 {print $1}' /etc/passwd

    # Ask the user which account to keep
    while true; do
        read -p "${ORANGE}Enter the username of the account you want to keep: ${NC}" keep_account

        # Validate if the entered username exists
        if grep -q "^$keep_account:" /etc/passwd; then
            break
        else
            echo "Error: The entered username '$keep_account' does not exist. Please try again."
        fi
    done

    # Disable other accounts
    disabled_users=""
    while IFS= read -r user; do
        if [ "$user" != "$keep_account" ]; then
            if result=$(usermod --expiredate 1 "$user" 2>&1); then
                if [[ "$result" == *"no changes"* ]]; then
                    echo "Account '$user' is already disabled"
                else
                    if [[ "$result" == "" ]]; then
                        echo "Account '$user' has been disabled."
                        disabled_users+="$user "
                    fi
                fi
            else
                echo "Error disabling account '$user': $result"
            fi
        fi
    done < <(awk -F: '$3 >= 1000 && $1 != "'"$keep_account"'" {print $1}' /etc/passwd)

    echo -e "${BLUE}Disabling non-used accounts: ${GREEN}DONE${NC}"
    echo
    
    # Append disabled users to the report
    if [ -n "$disabled_users" ]; then
        echo -e "${BLUE}Disabling non-used accounts: ${GREEN}DONE${NC} Following accounts were disabled: $disabled_users" >> Report.txt
    else
        if [[ "$result" == *"usermod: no changes"* ]]; then
            echo -e "${BLUE}Disabling non-used accounts: ${GREEN}DONE${NC} No non-used accounts to disable." >> Report.txt
        else
            echo -e "${BLUE}Disabling non-used accounts: ${RED}FAILED${NC} $result" >> Report.txt
        fi
    fi
}




# SHH
# IP TABLE
# PORT SECURITY
# FAIL2BAN
# ROOTKITHUNTER
# DISABLE COMPILERS
# FILE PERMISSIONS
# SECURE SHARED MEMORY
# DISABLE ROOT LOGIN

# Main function to run all tasks
main() {
    # Install dependencies
    install_dependencies

    # Create report file
    create_report_file

    # Configure timezone
    configure_timezone

    # Update the system
    update_system

    # Disable non-used accounts
    list_and_disable_non_used_accounts


    # Add more tasks/functions as needed
}

# Run the main function
main
