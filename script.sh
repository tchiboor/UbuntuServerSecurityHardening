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

# Function to log messages to both stdout and the log file
log() {
    local message="$1"
    echo -e "$message" | tee -a "$LOG_FILE"
    echo | tee -a "$LOG_FILE"
}


# Log file
create_log_file() {
    echo -e "${BLUE}Creating text file for the logs. ${NC}"
    touch harden.log
    LOG_FILE="harden.log"
    echo -e "${BLUE}Creating text file for the logs: ${GREEN}DONE${NC} File name: $LOG_FILE"
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

# Function to set the hostname
set_hostname() {
    log "${BLUE}Configuring hostname. ${NC}"
    hostnamectl set-hostname "$HOSTNAME" >> "$LOG_FILE" 2>&1
    log "Hostname set to $HOSTNAME"
    log "${BLUE}Configuring hostname: ${GREEN}DONE${NC}"
    echo -e "${BLUE}Configuring hostname: ${GREEN}DONE${NC}" >> report.txt
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

# Function to add a weekly cron job for system and packages updates..
system_update_weekly_cron_job() {
    log "${BLUE}Configuring weekly cron job to update system and packages added.${NC}"
    # Cron job command
    local cron_command="apt update && apt upgrade -y && apt autoremove -y && apt autoclean" >> "$LOG_FILE" 2>&1

    # Add the cron job to run weekly
    (crontab -l 2>/dev/null; echo "0 0 * * 0 $cron_command") | crontab - >> "$LOG_FILE" 2>&1

    # Notify user
    log "${BLUE}Weekly cron job to update system and packages added:${GREEN}DONE${NC}"
    echo -e "${BLUE}Weekly cron job to update system and packages added:${GREEN}DONE${NC}" >> report.txt
}

# Function to secure /tmp and /var/tmp folders
secure_tmp_folders() {
    log "${BLUE}Securing /tmp folder ${NC}"

    dd if=/dev/zero of=/usr/tmpDSK bs=1024 count=1024000 >> "$LOG_FILE" 2>&1
    cp -Rpf /tmp /tmpbackup >> "$LOG_FILE" 2>&1

    # Mount the new /tmp partition and set the right permissions
    mount -t tmpfs -o loop,noexec,nosuid,rw /usr/tmpDSK /tmp >> "$LOG_FILE" 2>&1
    chmod 1777 /tmp >> "$LOG_FILE" 2>&1

    cp -Rpf /tmpbackup/* /tmp/ >> "$LOG_FILE" 2>&1
    rm -rf /tmpbackup/* >> "$LOG_FILE" 2>&1

    echo "/usr/tmpDSK /tmp tmpfs loop,nosuid,noexec,rw 0 0" >> /etc/fstab >> "$LOG_FILE" 2>&1
    mount -o remount /tmp >> "$LOG_FILE" 2>&1

    log "${BLUE}Securing /var/tmp folder ${NC}"

    # Securing the /var/tmp
    mv /var/tmp /var/tmpold >> "$LOG_FILE" 2>&1
    ln -s /tmp /var/tmp >> "$LOG_FILE" 2>&1
    cp -prf /var/tmpold/* /tmp/ >> "$LOG_FILE" 2>&1

    log "${BLUE}Securing /tmp and /var/tmp folders: ${GREEN}DONE${NC}"
    echo -e "${BLUE}Securing /tmp and /var/tmp folders: ${GREEN}DONE${NC}" >> report.txt
}

# Function to configure IP tables firewall

configure_iptables_firewall() {
    # Port 80 (HTTP) and Port 22 (SSH)
    log "${BLUE}Configuring iptables firewall${NC}"

    iptables -A INPUT -p tcp -m tcp --dport $HTTP_PORT -m state --state NEW,ESTABLISHED -j ACCEPT >> "$LOG_FILE" 2>&1
    iptables -A INPUT -p tcp -m tcp --dport $SSH_PORT -m state --state NEW,ESTABLISHED -j ACCEPT >> "$LOG_FILE" 2>&1
    iptables -A INPUT -p tcp -m tcp --dport $HTTPS_PORT -m state --state NEW,ESTABLISHED -j ACCEPT >> "$LOG_FILE" 2>&1

    iptables -A INPUT -i lo -j ACCEPT >> "$LOG_FILE" 2>&1
    iptables -A INPUT -j DROP >> "$LOG_FILE" 2>&1
    log "${BLUE}Configuring iptables firewall$: ${GREEN}DONE${NC}"
    echo -e "${BLUE}Configuring iptables firewall$: ${GREEN}DONE${NC}" >> report.txt
}

# Function to disable telnet
disable_telnet() {
    log "${BLUE}Disabling Telnet Service${NC}"
    apt purge telnet telnetd inetutils-telnetd telnetd-ssl -y >> "$LOG_FILE" 2>&1
    log "${BLUE}Disabling Telnet Service: ${GREEN}DONE${NC}"
    echo -e "${BLUE}Disabling Telnet Service: ${GREEN}DONE${NC}" >> report.txt
}

# Function to configure fail2ban
configure_fail2ban() {

    # Create a new configuration file for fail2ban
    log -e "${BLUE}Configuring fail2ban.${NC}"
    tee /etc/fail2ban/jail.local >> "$LOG_FILE" 2>&1 <<EOF
    [sshd]
    enabled = true
    port = 22
    filter = sshd
    logpath = /var/log/auth.log
    maxretry = 10
    bantime = 6000
EOF

    # Restart fail2ban
    log "Restarting fail2ban..."
    systemctl restart fail2ban >> "$LOG_FILE" 2>&1

    log "${BLUE}Fail2ban configuration: ${GREEN}DONE${NC}"
    echo -e "${BLUE}Fail2ban configuration: ${GREEN}DONE${NC}" >> report.txt
}

# Function to set ownership and permissions for cron-related files and directories
set_file_dir_permissions() {
    echo -e "${BLUE}Configuring files and directory permissions.${NC}"
    
    # Set ownership and permissions for /etc/crontab
    chown root:root /etc/crontab >> "$LOG_FILE" 2>&1
    chmod og-rwx /etc/crontab >> "$LOG_FILE" 2>&1

    # Set ownership and permissions for /etc/cron.hourly
    chown root:root /etc/cron.hourly >> "$LOG_FILE" 2>&1
    chmod og-rwx /etc/cron.hourly >> "$LOG_FILE" 2>&1

    # Set ownership and permissions for /etc/cron.daily
    chown root:root /etc/cron.daily >> "$LOG_FILE" 2>&1
    chmod og-rwx /etc/cron.daily >> "$LOG_FILE" 2>&1

    # Set ownership and permissions for /etc/cron.weekly
    chown root:root /etc/cron.weekly >> "$LOG_FILE" 2>&1
    chmod og-rwx /etc/cron.weekly >> "$LOG_FILE" 2>&1

    # Set ownership and permissions for /etc/cron.monthly
    chown root:root /etc/cron.monthly >> "$LOG_FILE" 2>&1
    chmod og-rwx /etc/cron.monthly >> "$LOG_FILE" 2>&1

    # Set ownership and permissions for /etc/cron.d
    log "`chown root:root /etc/cron.d`"
    log "`chmod og-rwx /etc/cron.d`"

    # Set User/Group Owner and Permission on “passwd” file
    log "`chmod 644 /etc/passwd`"
    log "`chown root:root /etc/passwd`"

    # Set User/Group Owner and Permission on the “shadow” file
    log "`chmod 600 /etc/shadow`"
    log "`chown root:root /etc/shadow`"

    log "${BLUE}Configuring files/dir permissions: ${GREEN}DONE${NC}"
    echo -e "${BLUE}Configuring files/dir permissions: ${GREEN}DONE${NC}" >> report.txt
}

# Function to get service statust
get_service_status(){
    echo -e "${BLUE}Get all services status ${NC}"
    log "`service --status-all`" >> all_services_status.txt
    log "${BLUE}Get all services status: ${GREEN}DONE${NC}"
    echo -e "${BLUE}Get all services status: ${GREEN}DONE${NC}" >> report.txt
}

# Function to implement password policy
password_policy() {
    log "${BLUE}Configuring password policy. ${NC}"

    # Configure stron password policy
    local config_line="/lib/security/\$ISA/pam_cracklib.so retry=3 minlen=8 lcredit=-1 ucredit=-2 dcredit=-2 ocredit=-1"
    local SYSTEM_AUTH_FILE="/etc/pam.d/system-auth"

    # Check if the line already exists in the file
    if grep -q "$config_line" "$SYSTEM_AUTH_FILE"; then
        log "Strong password policy config already exists in $SYSTEM_AUTH_FILE. No changes needed."
        return 0
    fi

    # Add configurations to the file
    echo "$config_line" | sudo tee -a "$SYSTEM_AUTH_FILE" >> "$LOG_FILE" 2>&1

    # Configure user to not use the last 3 passwords
    local config_line1="auth        sufficient    pam_unix.so likeauth nullok"
    local config_line2="password    sufficient    pam_unix.so remember=3"

    # Define the file path
    local COMMON_PASSWORD_FILE="/etc/pam.d/common-password"

    # Check if the configuration already exist in the file
    if grep -q "$config_line1" "$COMMON_PASSWORD_FILE" && grep -q "$config_line2" "$COMMON_PASSWORD_FILE"; then
        log "Password reuse configuration already exist in $COMMON_PASSWORD_FILE. No changes needed."
        return 0
    fi

    # Add configurations to the to the file
    echo "$config_line1" | sudo tee -a "$COMMON_PASSWORD_FILE" >> "$LOG_FILE" 2>&1
    echo "$config_line2" | sudo tee -a "$COMMON_PASSWORD_FILE" >> "$LOG_FILE" 2>&1

    log "${BLUE}Configuring password policy: ${GREEN}DONE${NC}"
    echo -e "${BLUE}Configuring password policy: ${GREEN}DONE${NC}" >> report.txt
}

# Function to notify all DONE
finished_execution() {
        log "${GREEN}All configurations DONE${NC}"
        echo -e "${GREEN}All configurations DONE.${NC}" >> report.txt

}

# Function to print the Report
print_report()  {
    cat report.txt
    echo `date`
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

finished_execution
print_report
