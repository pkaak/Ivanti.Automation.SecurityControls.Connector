﻿# MachineGroups - Get ID
# for Ivanti Security Controls
# version 2019-08
#
# Changelog: 
# Aug 2019: optimization, better use of API
#
# patrick.kaak@ivanti.com
# @pkaak

#User variables
$username = '^[ISeC Serviceaccount Username]' #ISeC Credential Username
$password = '^[ISeC Serviceaccount Password]' #ISeC Credential password
$servername = '^[ISeC Servername]' #ISeC console servername
$serverport = '^[ISeC REST API portnumber]' #ISeC REST API portnumber

$MachineGroupName = "$[Machinegroup name]"

#System variables
$Url = 'https://'+$servername+':'+$serverport+'/st/console/api/v1.0/machinegroups?name='+ $MachineGroupName
$EncryptPassword = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $EncryptPassword
$output = ''

#Request body


#Connect to ISeC REST API
try 
{
  $result = Invoke-RestMethod -Method Get -Credential $cred -Uri $Url -ContentType 'application/json' | ConvertTo-Json -Depth 99
}
catch 
{
  # Dig into the exception to get the Response details.
  # Note that value__ is not a typo.
  Write-Host -Object 'Error (GetMachinegroupID)'
  Write-Host 'StatusCode:' $_.Exception.Response.StatusCode.value__ 
  Write-Host 'StatusDescription:' $_.Exception.Response.StatusDescription
  Write-Host 'Error Message:' $_.ErrorDetails.Message
  exit(1)
}

#REST API was OK. Go futher
$result = ConvertFrom-Json -InputObject $result

#Results
$found = '0'
for ($count = 0;$count -lt ($result.count); $count++) 
{
  if ($result.value[$count].name -eq $MachineGroupName) 
  {
    #Machinegroup found
    $found = '1'
    $result.value[$count].id
  }
}
if ($found -eq 0) 
{
  #no match found
  Write-Host -Object 'Error: Machinegroup not found'
  exit(1)
}
