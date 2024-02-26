#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root.${NC}" 
   exit 1
fi

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
# Banner


# Function to create report file
create_report_file() {
    echo -e "${BLUE}Creating text file for the report${NC}"
    touch Report.txt
    figlet "Security Hardening Report" >> Report.txt
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
    apt autoremove
    apt autoclean
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

# Function to disable root login
disable_root_login() {
    echo -e "${BLUE}Disabling root login via SSH ${NC}"

    # Open the SSH configuration file for editing
    sshd_config="/etc/ssh/sshd_config"

    # Check if the SSH configuration file exists
    if [ ! -f "$sshd_config" ]; then
        echo "SSH configuration file not found: $sshd_config"
        return 1
    fi

    # Backup the original SSH configuration file
    echo -e "Backing up original SSH configuration file$"
    backup_file="$sshd_config.bak"
    cp "$sshd_config" "$backup_file"
    echo -e "Backup of SSH configuration file created: $backup_file"

    # Modify the SSH configuration to disable root login
    echo -e "Modifying configurations to disable root login"
    sed -i 's/PermitRootLogin yes/PermitRootLogin no/' "$sshd_config"
    
    # Restart SSH service to apply changes
    systemctl restart sshd
    echo -e "SSH service restarted"

    echo -e "${BLUE}Root login disabled in SSH configuration: ${GREEN}DONE${NC}"
    echo -e "${BLUE}Root login disabled in SSH configuration: ${GREEN}DONE${NC}. You can now only log in as a regular user" >> Report.txt
    echo
}

# Function to secure /tmp and /var/tmp folders
secure_tmp_folders() {
    echo -e "${BLUE}Securing /tmp folder ${NC}"

    # Create a 1 GB filesystem file for the /tmp partition
    dd if=/dev/zero of=/usr/tmpDSK bs=1024 count=1024000

    # Create a backup of the current /tmp folder
    cp -Rpf /tmp /tmpbackup

    # Mount the new /tmp partition and set the right permissions
    mount -t tmpfs -o loop,noexec,nosuid,rw /usr/tmpDSK /tmp
    chmod 1777 /tmp

    # Copy the data from the backup folder and remove the backup folder
    cp -Rpf /tmpbackup/* /tmp/
    rm -rf /tmpbackup/*

    # Set the /tmp in the fbtab
    echo "/usr/tmpDSK /tmp tmpfs loop,nosuid,noexec,rw 0 0" >> /etc/fstab

    # Test the fstab entry
    mount -o remount /tmp

    echo -e "${BLUE}Securing /var/tmp folder ${NC}"

    # Securing the /var/tmp by creating a symbolic link to the /tmp folder we just created
    mv /var/tmp /var/tmpold
    ln -s /tmp /var/tmp
    cp -prf /var/tmpold/* /tmp/

    echo -e "${BLUE}Securing /tmp and /var/tmp folders: ${GREEN}DONE${NC}"
    echo -e "${BLUE}Securing /tmp and /var/tmp folders: ${GREEN}DONE${NC}" >> Report.txt
    echo
}

# IP TABLE
# PORT SECURITY
# Function to disable telnet
disable_telnet() {
    echo -e "${BLUE}Disabling Telnet Service${NC}"
    echo
    apt purge telnet telnetd inetutils-telnetd telnetd-ssl -y
    echo -e "${BLUE}Disabling Telnet Service: ${GREEN}DONE${NC}"
    echo -e "${BLUE}Disabling Telnet Service: ${GREEN}DONE${NC}" >> Report.txt
    echo
}


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

    # Disable root user
    disable_root_login

    # Secure tmp folders
    secure_tmp_folders

    # Disable Telnet
    disable_telnet


    # Add more tasks/functions as needed
}

# Run the main function
main
