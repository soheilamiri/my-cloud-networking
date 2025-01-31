<#
.Synopsis
  Checking Masakasri member of segment Health status
.DESCRIPTION
   This script allows you to check Masakari segment member status by checking masakari-hostmonitor logfile.
   .PARAMETER LiteralPath
   OpenStack API,
.EXAMPLE
   i use it on solarwinds.
.LINK
   https://www.linkedin.com/in/soheil-amiri-4bb785218/
#>
# Define remote server details
$Username = "user" # Replace with your username
$password = "PAWWORD" # Replace with your password
$remoteHost = "REMOTE_SERVER" # Replace with your one of instance ha segmnet member 
$sshport = "22" # Port for SSH connection
$command = "sudo tail -n 30 /var/log/kolla/masakari/masakari-hostmonitor.log" # Command to fetch the last 30 lines of the log file

# Convert password to a secure string
$Password = "PointofView" | ConvertTo-SecureString -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ($Username, $Password)

# Establish SSH session
$session = New-SSHSession -ComputerName $remoteHost -Port $sshport -Credential $Credential -AcceptKey

# Execute the command on the remote server
$temp_output = Invoke-SSHCommand -SessionId $session.SessionId -Command $command
$output = $temp_output.output

# Read all lines from the log file
$logLines = $output

# Initialize variables
$startIndex = $null
$extractedSection = @()

# Find the first occurrence and extract only the first section
for ($i = 0; $i -lt $output.Count; $i++) {
    if ($logLines[$i] -match "Works on pacemaker-remote.") {
        $startIndex = $i
        break
    }
}

# If we found the starting point, extract the section until the next "Works on pacemaker-remote." or end of file
if ($startIndex -ne $null) {
    for ($j = $startIndex + 1; $j -lt $output.Count; $j++) {
        if ($output[$j] -match "Works on pacemaker-remote.") {
            break  # Stop extracting at the next occurrence
        }
        $extractedSection += $output[$j]
    }
}

# Process the extracted log section
$offlineComputers = $extractedSection -split "`n" | ForEach-Object {
    if ($_ -match "'(.*?)' is 'offline'") {
        $matches[1]
    }
}

# Process the extracted log section for online computers
$onlineComputers = $extractedSection -split "`n" | ForEach-Object {
    if ($_ -match "'(.*?)' is 'online'") {
        $matches[1]
    }
}

# Count the number of offline and online computers
$offlinenum = $offlineComputers.Count
$onlinenum = $onlineComputers.Count

#################################
##  Custom Solarwinds output  ##
#################################

# Check the health status based on the number of offline computers
if ($offlineComputers.Count -eq 0) {
    Write-Output "Message.Status: Healthy"
    Write-Output "Statistic.Status: 0"
    write-output "Message.Online_Member: $onlineComputers"
    write-output "Statistic.Online_Member: $onlinenum"
    exit 0
} else {
    Write-Output "Message.Status: warning"
    Write-Output "Statistic.Status: 2"
    Write-Output "Message.Offline: $offlineComputers"
    Write-Output "Statistic.offline: $offlinenum"
    write-output "Statistic.Online_Member: $onlinenum"
    exit 2
}
