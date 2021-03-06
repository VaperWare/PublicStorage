<#
 * Copyright Microsoft Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
#>

[CmdletBinding()]
Param(
    [parameter(Mandatory=$true)][string]$SubName
)

if((Get-AzureSubscription -SubscriptionName $SubName) -eq $null){
Write-Host "Invaild Subscription name";exit}

try {
Select-AzureSubscription -SubscriptionName $SubName -ErrorAction Stop
}catch{"$($SubName) is a valid Subscription, but remember subscription names are case sensitive";exit}


##Start overall stop watch
$oa_stopWatch = New-Object System.Diagnostics.Stopwatch;$oa_stopWatch.Start()

$TotalCt = 0 ; $TotalPubCt = 0
$tab = "   "
$ProgressPreference = "SilentlyContinue"
Write-Host "`nRetreiving Storage account(s)" -NoNewline
$StorageAccounts = Get-AzureStorageAccount -WarningAction SilentlyContinue
Write-Host " $($StorageAccounts.count) found`n"
foreach ($StorageAccount in $StorageAccounts) {
   Write-Host "$($StorageAccount.Label)" -NoNewline
   Set-AzureSubscription -SubscriptionName (Get-AzureSubscription -Default).SubscriptionName -CurrentStorageAccountName $StorageAccount.Label 
   $Containers = Get-AzureStorageContainer 
   $pubContainers = $Containers | ?{$_.PublicAccess -ne "off"}
   Write-Host (" {0} Container(s) - {1} Public Container(s)" -f $Containers.count,$pubContainers.count)
   $TotalCt += $Containers.count
   if ($pubContainers.count -gt 0){ $TotalPubCt += $pubContainers.count }
}
Write-Host ("`n{0} Container(s) - {1} Public Container(s)" -f $TotalCt,$TotalPubCt)
$oa_stopWatch.Stop();$ts = $oa_stopWatch.Elapsed
write-host ("`nTotal process completed in {0} hours {1} minutes, {2} seconds`n" -f $ts.Hours, $ts.Minutes, $ts.Seconds)

#End of script