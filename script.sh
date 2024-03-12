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
    echo -e "${BLUE}Disabling Telnet Service: ${GREEN}DONE${NC}" >> Report.txt
}

# Function to configure fail2ban
configure_fail2ban() {

    # Create a new configuration file for fail2ban
    log "Configuring fail2ban"
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
    echo -e "${BLUE}Fail2ban configuration: ${GREEN}DONE${NC}" >> Report.txt
}



# Function to notify all DONE
finished_execution (){
        log "${GREEN}All configurations DONE${NC}"
        echo -e "${GREEN}All configurations DONE.${NC}" >> report.txt

}

# Function to print the Report
print_report()  {
    cat report.txt
}

# Execute functions
install_dependencies
create_report_file
configure_timezone
update_system
secure_tmp_folders
configure_iptables_firewall
disable_telnet
configure_fail2ban

finished_execution
print_report