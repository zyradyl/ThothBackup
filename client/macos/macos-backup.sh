#!/usr/bin/env bash

#
# File:     macos-backup.sh
# Title:    macOS Backup Routine
# Author:	  Zyradyl
# License:	MIT
# Version:	0.1
#
# Description:  This is the script for a client side backup on macOS. This
#               script should remain as free from hardcoded variables as
#               possible.
#

#
# Locate needed commands
#
HOSTNAME="$(which hostname)"
RSYNC="$(which rsync)"
WHOAMI="$(which whoami)"

#
# Stage 1 - Who is doing the backup? Where are we?
#
username="$($WHOAMI)"
backup_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

#
# Stage 2 - Formulate the backup directory
#
user_dir="/Users/$username"

#
# Stage 3 - Define the backup username for rsync, check that private key exists
#
hostname=$($HOSTNAME)
hostname=$(echo $hostname | tr '[:upper:]' '[:lower:]')
backup_user="$username-$hostname-macos"
backup_key="$backup_dir/key/$backup_user"

if [ ! -f $backup_key ]; then
    printf "\n\nFATAL ERROR:\n\n"
    printf "Your backup key is either not present or incorrectly named.\n"
    printf "Please make sure the key directory contains a private key file\n"
    printf "given to you by the server operator. It should have come from\n"
    printf "the operator correctly named. If the file is there, contact the\n"
    printf "operator because your key is not correct and you will need to be\n"
    printf "registered again on the server.\n\n"
fi

echo $backup_user
echo $backup_key
