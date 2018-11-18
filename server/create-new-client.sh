#!/bin/bash

#
# File:		create-new-client.sh
# Title:	Create New Backup Client Bash Script
# Author:	Zyradyl
# License:	ISC
# Version:	0.1
# Description:	This script will initialize the required system parameters to
#		create a new backup user. The following steps are required:
#
#	Stage 1:
#		+ Obtain the Username the new client should be registered under
#		+ Obtain the System Name of the new client
#		+ Obtain the Operating System of the new Client
#
#	Stage 2:
#		+ Create a new System User named <User>-<System>-<OS>
#		+ Add the new system user to the backup group.
#		+ Set the new user to use a restricted shell.
#		+ Create a home directory for the new user under /home
#
#	Stage 3:
#		+ Check if the User already has a BTRFS subvolume under live_dir
#		+ If the user does not, create a new BTRFS subvolume for them.
#		+ Check if the System already has a subvolume under the User.
#		+ If the system does not, create a new BTRFS subvolume for it.
#		+ Check if the OS has a subvolume under the System.
#		+ If it does not, create it.
#
#	Stage 4:
#		+ Link the new BTRFS Directory into the users home directory
#		  following a similar layout.
#
#	Stage 5:
#		+ Set up permissions so backup service can iterate correctly
#
#	Stage 6:
#		+ Generate a new SSH key for the user and add it to their
#		  authorized keys.
#		+ Set up permissions correctly so SSH will function.
#

#
# Declare Variables
#
BACKUP_GROUP="backupd"
BACKUP_USER="borg"
BTRFS="/usr/sbin/btrfs"
LIVE_DIR="/srv/LIVE"
RESTRICTED_SHELL="/bin/false"
SUDO="$(which sudo)"
USERADD="/usr/sbin/useradd"

#
# Stage 1 - Obtain Required Information
#
printf "\n\ncreate-new-client.sh\n\n"
printf "This script will request information needed to create a new\n"
printf "backup client.\n\n"
printf "When prompted for the Operating System Name, please keep it\n"
printf "within five characters. For example: win10, macos, linux\n\n"

read -p 'Username: ' client_username
read -p 'System: ' client_system
read -p 'Operating System: ' client_os

printf "\n\nYou will now be prompted for your password. This is\n"
printf "required to execute the required system commands. You will\n"
printf "see which commands will be ran before they are executed.\n\n"
printf "Press CTRL-C to abort.\n\n"

#
# Stage 2 - Add User to the System
#
new_client="$client_username-$client_system-$client_os"

#echo "$SUDO $USERADD -N -m -d /home/$new_client -g $BACKUP_GROUP -G users -s $RESTRICTED_SHELL $new_client"
$SUDO $USERADD -N -m -d /home/$new_client -g $BACKUP_GROUP -G users -s $RESTRICTED_SHELL $new_client

#
# Stage 3 - Create Storage Directories
#

# Check for User Directory
check_dir="$LIVE_DIR/$client_username"

if [ ! -d "$check_dir" ]; then
	#echo "$SUDO $BTRFS subvolume create $check_dir"
	created_user_dir=TRUE
	#echo "$created_user_dir"
	$SUDO $BTRFS subvolume create $check_dir
fi


check_dir="$check_dir/$client_system"

if [ ! -d "$check_dir" ]; then
	#echo "$SUDO $BTRFS subvolume create $check_dir"
	created_system_dir=TRUE
	#echo "$created_system_dir"
	$SUDO $BTRFS subvolume create $check_dir
fi


check_dir="$check_dir/$client_os"

if [ ! -d "$check_dir" ]; then
	#echo "$SUDO $BTRFS subvolume create $check_dir"
	created_os_dir=TRUE
	#echo "$created_os_dir"
	$SUDO $BTRFS subvolume create $check_dir
fi

#
# Stage 4 - Create Home Directory Location
#

target_dir=$check_dir

#echo "$SUDO ln -sf $target_dir /home/$new_client/BACKUP"
$SUDO ln -sf $target_dir /home/$new_client/BACKUP

#
# Stage 5 - Set Permissions
#

# First we should make sure that the User's home directory
# belongs to them AND the BACKUP_GROUP
$SUDO chown -R $new_client:$BACKUP_GROUP /home/$new_client

# Now we need to make sure that borg owns all the new
# directories we created. This may seem quirky but we will
# add other permissions via ACLs.

if [ "$created_user_dir" = TRUE ]; then
	$SUDO chown $BACKUP_USER:$BACKUP_GROUP $LIVE_DIR/$client_username
fi

if [ "$created_system_dir" = TRUE ]; then
	$SUDO chown $BACKUP_USER:$BACKUP_GROUP $LIVE_DIR/$client_username/$client_system
fi

if [ "$created_os_dir" = TRUE ]; then
	$SUDO chown $BACKUP_USER:$BACKUP_GROUP $LIVE_DIR/$client_username/$client_system/$client_os
fi

#
# Add the user to the new directories through the use of ACLs
#
$SUDO setfacl -m "u:$new_client:rx" $LIVE_DIR
$SUDO setfacl -m "u:$new_client:rx" $LIVE_DIR/$client_username
$SUDO setfacl -m "u:$new_client:rx" $LIVE_DIR/$client_username/$client_system
$SUDO setfacl -m "u:$new_client:rwx" $LIVE_DIR/$client_username/$client_system/$client_os

#
# Stage 6 - Key File
#

$SUDO ssh-keygen -t ed25519 -f /home/$new_client/private_key
$SUDO mkdir /home/$new_client/.ssh
$SUDO cat /home/$new_client/private_key.pub > /home/$new_client/.ssh/authorized_keys
$SUDO chmod 700 /home/$new_client/.ssh
$SUDO chmod 600 /home/$new_client/.ssh/authorized_keys
$SUDO rm /home/$new_client/private_key.pub
