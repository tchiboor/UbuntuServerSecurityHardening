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
}

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

    # Add more tasks/functions as needed
}

# Run the main function
main
