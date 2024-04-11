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

# Funtion modules
for func_file in modules/*; do
    source "$func_file"
done

# Function to log messages to both stdout and the log file
log() {
    local message="$1"
    echo -e "$message" | tee -a "$LOG_FILE"
    echo | tee -a "$LOG_FILE"
}

# Execute functions
create_log_file
install_dependencies
create_report_file
set_hostname
configure_timezone
update_system
system_update_weekly_cron_job
secure_tmp_folders
configure_iptables_firewall
disable_telnet
configure_fail2ban
set_file_dir_permissions
get_service_status
password_policy
disable_sudo_nopasswd
disable_scp
remove_nc
finished_execution
print_report
ifaces
pwd_policy
shared_mem
ssh_noroot
