$VaultName = 'test'
$IncludeAllKeyVersions = $true
$IncludeAllSecretVersions = $true
$AlertBefore60Days = 60
$AlertBefore30Days = 30
$AlertBefore7Days = 7

$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}


Function New-KeyVaultObject
{
    param
    (
        [string]$Id,
        [string]$Name,
        [string]$Version,
        [System.Nullable[DateTime]]$Expires
    )

    $server = New-Object -TypeName PSObject
    $server | Add-Member -MemberType NoteProperty -Name Id -Value $Id
    $server | Add-Member -MemberType NoteProperty -Name Name -Value $Name
    $server | Add-Member -MemberType NoteProperty -Name Version -Value $Version
    $server | Add-Member -MemberType NoteProperty -Name Expires -Value $Expires
    
    return $server
}

function Get-AzureKeyVaultObjectKeys
{
  param
  (
   [string]$VaultName,
   [bool]$IncludeAllVersions
  )

  $vaultObjects = [System.Collections.ArrayList]@()
  $allKeys = Get-AzureKeyVaultKey -VaultName $VaultName
  foreach ($key in $allKeys) {
    if($IncludeAllVersions){
     $allSecretVersion = Get-AzureKeyVaultKey -VaultName $VaultName -IncludeVersions -Name $key.Name
     foreach($key in $allSecretVersion){
         $vaultObject = New-KeyVaultObject -Id $key.Id -Name $key.Name -Version $key.Version -Expires $key.Expires
         $vaultObjects.Add($vaultObject)
     }
     
    } else {
      $vaultObject = New-KeyVaultObject -Id $key.Id -Name $key.Name -Version $key.Version -Expires $key.Expires
      $vaultObjects.Add($vaultObject)
    }
  }
  
  return $vaultObjects
}

function Get-AzureKeyVaultObjectSecrets
{
  param
  (
   [string]$VaultName,
   [bool]$IncludeAllVersions
  )

  $vaultObjects = [System.Collections.ArrayList]@()
  $allSecrets = Get-AzureKeyVaultSecret -VaultName $VaultName
  foreach ($secret in $allSecrets) {
    if($IncludeAllVersions){
     $allSecretVersion = Get-AzureKeyVaultSecret -VaultName $VaultName -IncludeVersions -Name $secret.Name
     foreach($secret in $allSecretVersion){
         $vaultObject = New-KeyVaultObject -Id $secret.Id -Name $secret.Name -Version $secret.Version -Expires $secret.Expires
         $vaultObjects.Add($vaultObject)
     }
     
    } else {
      $vaultObject = New-KeyVaultObject -Id $secret.Id -Name $secret.Name -Version $secret.Version -Expires $secret.Expires
      $vaultObjects.Add($vaultObject)
    }
  }
  
  return $vaultObjects
}

$allKeyVaultObjects = [System.Collections.ArrayList]@()
# $allKeyVaultObjects.AddRange((Get-AzureKeyVaultObjectKeys -VaultName $VaultName -IncludeAllVersions $IncludeAllKeyVersions))
$allKeyVaultObjects.AddRange((Get-AzureKeyVaultObjectSecrets -VaultName $VaultName))

# Get expired Objects
$today = (Get-Date).Date
$expiredKeyVaultObjects = [System.Collections.ArrayList]@()
foreach($vaultObject in $allKeyVaultObjects){
if($vaultObject.Expires -and $vaultObject.Expires.AddDays(-$AlertBefore60Days).Date -lt $today)
{
    if($vaultObject.Expires -and $vaultObject.Expires.AddDays(-$AlertBefore30Days).Date -lt $today)
    {
        if($vaultObject.Expires -and $vaultObject.Expires.AddDays(-$AlertBefore7Days).Date -lt $today)
        {
            # add to expiry list
            $expiredKeyVaultObjects.Add($vaultObject) | Out-Null
            Write-Output "Expiring" $vaultObject.Id
            $vaultObjectName = $vaultObject.Name
            $From = "test@test.сom"
            $To = "to@test.com"
            $Cc = "cc@test.com"
            $Subject = "Certificate $vaultObjectName expires in $AlertBeforeDays days"
            $Body = @"
            Hi, 
            Please pay attention that $vaultObjectName certificate in $VaultName expires in less than $AlertBefore7Days days.
  
            Please inform responsible person.
"@
            $SMTPServer = "smtp.sendgrid.net"
            $SMTPPort = "587"
            $SMTPuser = "smtpuser"
            $SMTPpassword = "password"
            $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, $SMTPPort) 
            $SMTPClient.EnableSsl = $true 
            $SMTPClient.Credentials = New-Object System.Net.NetworkCredential("$SMTPuser", "$SMTPpassword"); 
            $SMTPClient.Send($From, $To, $Subject, $Body)
        }
        else
        {
            # add to expiry list
            $expiredKeyVaultObjects.Add($vaultObject) | Out-Null
            Write-Output "Expiring" $vaultObject.Id
            $vaultObjectName = $vaultObject.Name
            $From = "test@test.сom"
            $To = "to@test.com"
            $Cc = "cc@test.com"
            $Subject = "Certificate $vaultObjectName expires in $AlertBeforeDays days"
            $Body = @"
            Hi, 
            Please pay attention that $vaultObjectName certificate in $VaultName expires in less than $AlertBefore30Days days.
  
            Please inform responsible person.
"@
            $SMTPServer = "smtp.sendgrid.net"
            $SMTPPort = "587"
            $SMTPuser = "smtpuser"
            $SMTPpassword = "password"
            $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, $SMTPPort) 
            $SMTPClient.EnableSsl = $true 
            $SMTPClient.Credentials = New-Object System.Net.NetworkCredential("$SMTPuser", "$SMTPpassword"); 
            $SMTPClient.Send($From, $To, $Subject, $Body)
        }

    }
    else
    {
        # add to expiry list
        $expiredKeyVaultObjects.Add($vaultObject) | Out-Null
        Write-Output "Expiring" $vaultObject.Id
        $vaultObjectName = $vaultObject.Name
        $From = "test@test.сom"
        $To = "to@test.com"
        $Cc = "cc@test.com"
        $Subject = "Certificate $vaultObjectName expires in $AlertBeforeDays days"
        $Body = @"
        Hi, 
        Please pay attention that $vaultObjectName certificate in $VaultName expires in less than $AlertBefore60Days days.
  
        Please inform responsible person.
"@
        $SMTPServer = "smtp.sendgrid.net"
        $SMTPPort = "587"
        $SMTPuser = "smtpuser"
        $SMTPpassword = "password"
        $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, $SMTPPort) 
        $SMTPClient.EnableSsl = $true 
        $SMTPClient.Credentials = New-Object System.Net.NetworkCredential("$SMTPuser", "$SMTPpassword"); 
        $SMTPClient.Send($From, $To, $Cc ,$Subject, $Body)
    }
}

}