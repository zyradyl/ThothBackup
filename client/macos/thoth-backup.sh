#!/bin/sh

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
CHMOD="$(which chmod)"
DATE="$(which date)"
HOSTNAME="$(which hostname)"
RSYNC="$(which rsync)"
SSH="$(which ssh)"
WHOAMI="$(which whoami)"

#
# Global Variables
#
BACKUP_SERVER="192.168.1.100"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

#
# Compound Variables
#
timestamp=$($DATE +%Y%m%d-%H%M%S%Z)
log_name="thoth-backup-$timestamp"
log_file="$SCRIPT_DIR/logs/$log_name.log"

#
# Stage 1 - Who is doing the backup?
#
username="$($WHOAMI)"


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
backup_key="$SCRIPT_DIR/key/$backup_user"

if [ ! -f $backup_key ]; then
    printf "\n\nFATAL ERROR:\n\n"
    printf "Your backup key is either not present or incorrectly named.\n"
    printf "Please make sure the key directory contains a private key file\n"
    printf "given to you by the server operator. It should have come from\n"
    printf "the operator correctly named. If the file is there, contact the\n"
    printf "operator because your key is not correct and you will need to be\n"
    printf "registered again on the server.\n"
    exit 1
fi

#
# Ensure Private Key has the correct Permissions
#
if [ $(stat -f %A $backup_key) != 600 ]; then
  printf "\n\nINFO:\n\n"
  printf "Your backup key does not have the correct permissions to be used\n"
  printf "with ssh. The permissions will be updated to ensure success.\n"
  $CHMOD 600 $backup_key
fi

#
# Stage 4 - Confirm Exclusions exist, otherwise create them
#
#exclusions="$SCRIPT_DIR/exclusions/exclusions.txt"

#if [ ! -f $exclusions ]; then
#  printf "\n\nINFO:\n\n"
#  printf "You do not currently have an exclusions file. One will be created\n"
#  printf "for you. By default, the exclusions file contains the directory\n"
#  printf "that this client is based in. This means that your private key\n"
#  printf "would be excluded. To prevent loss of your private key, please\n"
#  printf "copy it to a second safe location.\n"
#  base_exclusion=${SCRIPT_DIR#"$user_dir"}
#  echo "${base_exclusion}" > $exclusions
#fi

#
# Stage 5 - Run the Backup
#
ssh="$SSH -i $backup_key"
source="$user_dir"
dest="$backup_user@$BACKUP_SERVER:/home/$backup_user/BACKUP"
rsync_base="$RSYNC -av --exclude-from=$exclusions --ignore-errors --delete -e"

backup_cmd="$rsync_base $ssh $source $dest"

$backup_cmd > $log_file 2>&1
