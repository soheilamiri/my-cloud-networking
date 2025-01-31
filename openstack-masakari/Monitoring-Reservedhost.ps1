<#
.Synopsis
  Checking Masakasri Reserved host Health status
.DESCRIPTION
   This script allows you to check Masakari reserved host status by fetching data from OpenStack API
   and checking host Reserved and Maintenance Attributes
.PARAMETER LiteralPath
   OpenStack API,
.EXAMPLE
   i use it on solarwinds.
.LINK
   https://www.linkedin.com/in/soheil-amiri-4bb785218/
#>

# Define the authentication URL
$AuthUrl = "http://<OPENSTACK_API_ADDRESS>:5000/v3/auth/tokens" # Replace with your OpenStack URL
$Username = "USERNAME"         # Replace with your username
$Password = "PASSWORD" # Replace with your password
$ProjectName = "admin"      # Replace with your project name
$DomainID = "default"       # Replace with your domain ID

# Body for the authentication request
$AuthBody = @{
    auth = @{
        identity = @{
            methods = @("password")
            password = @{
                user = @{
                    name = $Username
                    domain = @{ id = $DomainID }
                    password = $Password
                }
            }
        }
        scope = @{
            project = @{
                name = $ProjectName
                domain = @{ id = $DomainID }
            }
        }
    }
} | ConvertTo-Json -Depth 10

# Send the authentication request and store the response
$AuthResponse = Invoke-RestMethod -Uri $AuthUrl -Method Post -ContentType "application/json" -Body $AuthBody -ResponseHeadersVariable Headers

# Get Token ID for future authentication 
$TokenID = $Headers["X-Subject-Token"]

######################
##  Masakari Query  ##
######################

$reservedhostnum = "2"      # How many hosts are reserved for Masakari

# Define the Masakari API URL for hosts
$masakariURL_hosts = "http://<OPENSTACK_API_ADDRESS>:15868/v1/segments/<SEGMENT_ID>/hosts"

# Send the request to get host status
$masakariResponse_host = Invoke-RestMethod -Uri $masakariURL_hosts -Method Get -Headers @{ "X-Auth-Token" = "$tokenID" }

# Process the response to get host details
$iaas_masakari_host = $masakariResponse_host.hosts | ForEach-Object {
    [PSCustomObject]@{
        ID = $_.id
        Hostname = $_.name
        host_UUID = $_.uuid
        Resevred = $_.reserved
        Maintenance_Mode = $_.on_maintenance
        Join_at = $_.created_at
    }
}

# Filter the hosts that are reserved and not in maintenance mode
$uphost = $iaas_masakari_host | where-object {$_.Resevred -eq "True" -and $_.Maintenance_Mode -like "false"}

# Get the list and count of running hosts
$uphosts = $uphost.Hostname
$uphostsnum = $uphost.count

# Filter the hosts that are in maintenance mode
$temp_downhost = $iaas_masakari_host | where-object {$_.Maintenance_Mode -like "true"}

# Get the list and count of down hosts
$downhost = $temp_downhost.Hostname
$downhostnum = $temp_downhost.count


#################################
##  custome Solarwinds output  ##
#################################

# Check the health status based on the number of running and reserved hosts
if ($uphost.count -eq $reservedhostnum) {
    Write-Output "Message.Status: Healthy"
    Write-Output "Statistic.Status: 0"
    write-output "Message.RunningHosts:$uphosts"
    write-output "Statistic.RunningHosts:$uphostsnum"
    write-output "Message.FailedHosts:$downhost"
    write-output "Statistic.FailedHosts:$downhostnum"
    exit 0
} else {
    Write-Output "Message.Status: Warning"
    Write-Output "Statistic.Status: 2"
    write-output "Message.RunningHosts:$uphosts"
    write-output "Statistic.RunningHosts:$uphostsnum"
    write-output "Message.FailedHosts:$downhost"
    write-output "Statistic.FailedHosts:$downhostnum"
    Exit 2
}
