#
# File:     thoth-client
# Title:    Windows Backup Routine
# Author:	  Zyradyl
# License:	MIT
# Version:	0.1
#
# Description:  This is the script for a client side backup on Windows. This
#               script should remain as free from hardcoded variables as
#               possible.
#

#
# Example of a file download
#
$url = "http://mirror.internode.on.net/pub/test/10meg.test"
$output = "$PSScriptRoot\10meg.test"
$start_time = Get-Date

$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $output)
#OR
(New-Object System.Net.WebClient).DownloadFile($url, $output)

Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"

#
# Unzip a file
#
expand-archive -path 'c:\users\john\desktop\iislogs.zip' -destinationpath '.\unzipped'
