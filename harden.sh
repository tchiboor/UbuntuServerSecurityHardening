#!/bin/bash

# Define ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color


# CONFIGURE THE TIME ZONE
# Prompt the user to select a timezone
echo -e "${BLUE}Please select your timezone:${NC}"
sleep 5
dpkg-reconfigure tzdata

# Optional: Print out the current date/time to verify the setting
date
echo
echo

# UPDATE THE SYSTEM
echo -e "${BLUE}Updating the package lists and upgrading the installed packages${NC}"

sleep 5
apt update
apt upgrade -y

# ENSURE ONLY ROOT HAS UID of 0
# SHH
# IP TABLE
# PORT SECURITY
# FAIL2BAN
# ROOTKITHUNTER
# DISABLE COMPILERS
# FILE PERMISSIONS
# SECURE SHARED MEMORY
# DISABLE ROOT LOGIN
