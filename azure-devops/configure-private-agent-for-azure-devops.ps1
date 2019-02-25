# VM variables
$ip_addr =$jsonDeploymentOutput.output.value
$VMName = "#{PrivateAgent.Name}#"
$vmuser = "#{PrivateAgent.UserName}#"
$wpassword = "#{PrivateAgent.Password}#"
$wpassword.GetType()
$vmpword = ConvertTo-SecureString -String $wpassword -AsPlainText -Force 
$vmcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $vmuser, $vmpword

# VSTS variables
$VSTSAccount = "#{AzDevOps.Account}#"
$PAT = "#{Agent.PAT}#"
$VSTSAgentUrl = "https://vstsagentpackage.azureedge.net/agent/2.127.0/vsts-agent-win-x64-2.127.0.zip"
$AgentPool = 'default'

# connecting to VM
echo $vmcred
Enable-PSRemoting -Force
$option = New-PSSessionOption -SkipCACheck -IdleTimeout 7200000 -OperationTimeout 0 -OutputBufferingMode Block
Enter-PSSession -ComputerName $ip_addr -UseSSL -Credential $vmcred -SessionOption $option # $ip_addr.VM_IP.value
Write-Output "Connecting to VM $ip_addr"

# PS Session
$sessionOption = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
$session = New-PSSession -ComputerName $ip_addr -UseSSL -Credential $vmcred -SessionOption $sessionOption
$remoteArgs = @($VSTSAgentUrl, $VSTSAccount, $PAT, $VMName, $AgentPool, $vmuser, $wpassword)
Invoke-Command -Session $session -ArgumentList $remoteArgs -ScriptBlock {
    param
    (
        [string] $VSTSAgentUrl,
        [string] $VSTSAccount,
        [string] $PAT,
        [string] $VMName,
        [string] $AgentPool,
        [string] $vmuser,
        [string] $wpassword
    )


    Set-Location 'C:\'
    # Download VSTS Agent
    $vstsAgentZipPath = "vsts-agent.zip"
    Invoke-WebRequest -Uri $VSTSAgentUrl -UseBasicParsing -OutFile $vstsAgentZipPath
    Write-Output 'Downloaded vsts-agent.zip'
    $buildFolder = 'C:\Build'
    if (-not (test-path $buildFolder))
    {
        # Unzip VSTS Agent
        $buildFolder = New-Item -Path 'Build' -ItemType Directory
        Expand-Archive -Path $vstsAgentZipPath -DestinationPath $buildFolder.FullName -Force
        Set-Location $buildFolder.FullName
        Write-Output 'Extracted vsts-agent.zip'
    } else{
        Expand-Archive -Path $vstsAgentZipPath -DestinationPath $buildFolder -Force
        Set-Location $buildFolder
        Write-Output 'Extracted vsts-agent.zip'
    }
    # Write-Output ".\config.cmd --unattended --url $VSTSAccount --auth pat --token $PAT --pool $AgentPool --agent $VMName --runAsService --windowsLogonAccount $vmuser --windowsLogonPassword $wpassword"
    .\config.cmd --unattended --url '$VSTSAccount' --auth pat --token '$PAT' --pool '$AgentPool' --agent '$VMName' --runAsService --windowsLogonAccount '$vmuser' --windowsLogonPassword '$pword'
    # Write-Output 'VSTS Build Agent configured.'
    Exit-PSSession
}
Remove-PSSession -Session $session



# .\InstallAgent.ps1 -rgName $rgName -location $location -VMName $VMName -cred $cred -VSTSAccount $VSTSAccount -PAT $PAT -VSTSAgentUrl $VSTSAgentUrl
