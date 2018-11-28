#!/usr/bin/env bash

#
# File:     create-new-client.sh
# Title:    Create New Backup Client Bash Script
# Author:   Zyradyl
# License:  MIT
# Version:  0.1
#
# Description:	This script will initialize the required system parameters to
#		create a new backup user. The following steps are required:
#

#
# Locate needed commands
#
# There are bash builtins for some of these, but builtins can change between
# versions. This allows us to stabilize on coreutils.
CHMOD="$(which chmod)"
CHOWN="$(which chown)"
SETFACL="$(which setfacl)"
SUDO="$(which sudo)"

#
# Hardcode commands found in sbin as which will not find them
#
BTRFS="/usr/sbin/btrfs"
USERADD="/usr/sbin/useradd"

#
# Declare Variables
#
BACKUP_GROUP="backupd"
BACKUP_USER="borg"
LIVE_DIR="/srv/LIVE"
RESTRICTED_SHELL="/bin/false"

#
# Stage 1 - Obtain information
#
#		+ Obtain the Username the new client should be registered under
#		+ Obtain the System Name of the new client
#		+ Obtain the Operating System of the new Client
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
printf "required to execute the required system commands.\n\n"
printf "Press CTRL-C to abort.\n\n"

#
# Stage 2 - Add User to the System
#
#		+ Create a new System User named <User>-<System>-<OS>
#		+ Add the new system user to the backup group.
#		+ Set the new user to use a restricted shell.
#		+ Create a home directory for the new user under /home
#
new_client="$client_username-$client_system-$client_os"
$SUDO $USERADD -N -m -d /home/$new_client -g $BACKUP_GROUP -G users -s $RESTRICTED_SHELL $new_client

#
# Stage 3 - Create Storage Directories
#
#		+ Check if the User already has a BTRFS subvolume under live_dir
#		+ If the user does not, create a new BTRFS subvolume for them.
#		+ Check if the System already has a subvolume under the User.
#		+ If the system does not, create a new BTRFS subvolume for it.
#		+ Check if the OS has a subvolume under the System.
#		+ If it does not, create it.
#
# This could be made much smaller, but this layout will make it easier to
# refactor into some type of loop at some point.
#
user_dir="$LIVE_DIR/$client_username"
if [ ! -d "$user_dir" ]; then
	created_user_dir=TRUE
	$SUDO $BTRFS subvolume create $user_dir
fi

system_dir="$user_dir/$client_system"
if [ ! -d "$system_dir" ]; then
	created_system_dir=TRUE
	$SUDO $BTRFS subvolume create $system_dir
fi

os_dir="$system_dir/$client_os"
if [ ! -d "$os_dir" ]; then
	created_os_dir=TRUE
	$SUDO $BTRFS subvolume create $os_dir
fi

#
# Stage 4 - Create Home Directory Location
#
$SUDO ln -sf $os_dir /home/$new_client/BACKUP

#
# Stage 5 - Set Permissions
#

# First we should make sure that the User's home directory
# belongs to them AND the BACKUP_GROUP
$SUDO $CHOWN -R $new_client:$BACKUP_GROUP /home/$new_client

# Now we need to make sure that borg owns all the new
# directories we created. This may seem quirky but we will
# add other permissions via ACLs.
if [ "$created_user_dir" = TRUE ]; then
	$SUDO $CHOWN $BACKUP_USER:$BACKUP_GROUP $user_dir
fi
if [ "$created_system_dir" = TRUE ]; then
	$SUDO $CHOWN $BACKUP_USER:$BACKUP_GROUP $system_dir
fi
if [ "$created_os_dir" = TRUE ]; then
	$SUDO $CHOWN $BACKUP_USER:$BACKUP_GROUP $os_dir
fi

#
# Add the user to the new directories through the use of ACLs
# The x permission bit is needed to be able to view inside directories. Trust me
# I tried to reduce the permission set but it just wasn't happening.
#
$SUDO $SETFACL -m "u:$new_client:rx" $LIVE_DIR
$SUDO $SETFACL -m "u:$new_client:rx" $user_dir
$SUDO $SETFACL -m "u:$new_client:rx" $system_dir
$SUDO $SETFACL -m "u:$new_client:rwx" $os_dir

#
# Stage 6 - Key File
#

#
# As of right now this section is broken. The keygen will work but there are
# errors putting everything where it should go, something to do with permissions
#
# TODO: Fix this mess

# $SUDO ssh-keygen -t ed25519 -f /home/$new_client/private_key
# $SUDO mkdir /home/$new_client/.ssh
# $SUDO cat /home/$new_client/private_key.pub > /home/$new_client/.ssh/authorized_keys
# $SUDO $CHMOD 700 /home/$new_client/.ssh
# $SUDO $CHMOD 600 /home/$new_client/.ssh/authorized_keys
# $SUDO rm /home/$new_client/private_key.pub
