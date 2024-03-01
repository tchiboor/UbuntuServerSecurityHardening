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

# Environment viriables
source .env

# Log file
LOG_FILE="script.log"

# Function to log messages to both stdout and the log file
log() {
    local message="$1"
    echo -e "$message" | tee -a "$LOG_FILE"
    echo | tee -a "$LOG_FILE"
}

# Function to install dependencies
install_dependencies() {
    log "${BLUE}Installing dependencies${NC}"
    apt install -y figlet >> "$LOG_FILE" 2>&1
    apt install -y fail2ban >> "$LOG_FILE" 2>&1
    log "${BLUE}Installing dependencies: ${GREEN}DONE${NC}"
}

# Function to create report file
create_report_file() {
    log "${BLUE}Creating text file for the report${NC}"
    touch report.txt
    REPORT="report.txt"
    figlet "Security Hardening Report" >> report.txt
    log "${BLUE}Reporting file created: ${GREEN}DONE${NC}. File name: $REPORT"
}

# Function to configure timezone
configure_timezone() {
    log "${BLUE}Configuring timezone${NC}"
    timedatectl set-timezone "$Time_Zone" >> "$LOG_FILE" 2>&1
    log "`date`"
    log "${BLUE}Configure timezone: ${GREEN}DONE${NC}"
    echo -e "${BLUE}Configure timezone: ${GREEN}DONE${NC}" >> report.txt

}
# Function to update the system
update_system() {
    log "${BLUE}Updating the package lists and upgrading the installed packages${NC}"
    apt update >> "$LOG_FILE" 2>&1
    apt upgrade -y >> "$LOG_FILE" 2>&1
    apt autoremove >> "$LOG_FILE" 2>&1
    apt autoclean >> "$LOG_FILE" 2>&1
    log "${BLUE}System update and upgrade: ${GREEN}DONE${NC}"
    echo -e "${BLUE}System update and upgrade: ${GREEN}DONE${NC}" >> report.txt

}

# Execute functions
install_dependencies
create_report_file
configure_timezone
update_system
