<#
.Synopsis
  Checking Masakasri service health
.DESCRIPTION
   This script allows you to check Masakari and hacluter service health by checking their container (service) status.
   .PARAMETER LiteralPath
   OpenStack API,
.EXAMPLE
   i use it on solarwinds.
.LINK
   https://www.linkedin.com/in/soheil-amiri-4bb785218/
.NOTES
version 0.8
   #>
# Define remote server details
$Username = "user" # Replace with your username
$password = "PASSWORD" # Replace with your password 
$remoteHost = "REMOTE_SERVER" # Replace with your remote CONTROLLER OR MASAKARI SERVER
$sshport = "22" # Port for SSH connection
$command = "sudo docker ps -a" # Command to list all Docker containers

# Convert password to a secure string
$Password = "PointofView" | ConvertTo-SecureString -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ($Username, $Password)

# Establish SSH session
$session = New-SSHSession -ComputerName $remoteHost -Port $sshport -Credential $Credential -AcceptKey

# Execute the command on the remote server
$temp_output = Invoke-SSHCommand -SessionId $session.SessionId -Command $command
$output = $temp_output.output 

# Process the output to extract container information
$container_info = $output | ForEach-Object {
    $columns = $_ -split '\s{2,}'  # Split columns by two or more whitespace characters
    [PSCustomObject]@{
        ContainerID = $columns[0]
        Image       = $columns[1]
        Created     = $columns[3]
        Status      = $columns[4]
        Names       = $columns[5]
    }
}

# Filter containers related to Masakari and hacluter services
$Masakari_Services = $container_info | where-object {$_.Names -like "masakari*" -or $_.Names -like "hacluster*"} 

# Check the status of all Masakari containers
$allContainersUp = $Masakari_Services | Where-Object { $_.Status -notmatch 'Up' -and $_.Status -notmatch "seconds"}
$containername = $allContainersUp.Names

#################################
##  Custom Solarwinds output  ##
#################################

# Check the health status based on the number of running containers
if ($allContainersUp.Count -eq 0) {
    Write-Output "Message.Status: Healthy"
    Write-Output "Statistic.Status: 0"
    write-output "Message.Services:$containername"
    write-output "Statistic.Services:15"
    exit 0
} else {
    Write-Output "Message.Status: Critical"
    Write-Output "Statistic.Status: 10"
    write-output "Message.Services:$containername"
    write-output "Statistic.Services:15"
    Exit 3  
}

# Close SSH session
Remove-SSHSession -SessionId $session.SessionId
