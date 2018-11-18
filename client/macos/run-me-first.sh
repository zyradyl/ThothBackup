#!/usr/bin/env bash

#
# File:     run-me-first.sh
# Title:    macOS Backup Routine Installation File
# Author:	  Zyradyl
# License:	MIT
# Version:	0.1
#
# Description:  This script handles the first run for the macOS Backup Routine
#

printf "\n\nWelcome to the Thoth Backup System!\n\n"
printf "Thank you for your interest in this backup software. It should be\n"
printf "noted now that this software is PROVIDED WITHOUT ANY WARRANTY. If\n"
printf "you can, you may want to consider another backup client backed by\n"
printf "a large company. This is just a small private project.\n\n"
printf "If you are a friend of mine, Hello! Thanks for trying out my\n"
printf "software!\n\n\n"
printf "This software will perform the required steps to install this backup\n"
printf "as a service that runs on a schedule that you set. However, before\n"
printf "the service is scheduled, it is VITAL that you complete an initial\n"
printf "syncronization. This process can take an extremely long time.\n\n"
printf "Depending on your connection, you may find it easiest to do this\n"
printf "process in parts. You can cancel the script at any time by pressing\n"
printf "CTRL-C. You will NOT LOSE YOUR PROGRESS. The next time you run this\n"
printf "script, it will pick up from where it left off. You are NOT ADDED\n"
printf "to the archive until this process completes. Therefore it is best\n"
printf "to do this as quickly as possible. The more changes you make to your\n"
printf "system during this time, the longer it will take.\n\n"
printf "If you don't mind the slowdown, I recommend leaving this running as\n"
printf "often as possible. Another option is to run it when you go to bed\n"
printf "each night. Whatever works.\n\n"
printf "The \"Archive\" functionality I have discussed previously will be\n"
printf "made available in a future release."
printf "\n\nThe initial syncronization will now start.\n"

./thoth-backup.sh

printf "Test."
