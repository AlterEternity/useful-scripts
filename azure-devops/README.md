# Azure DevOps
Contatins scripts for Azure DevOps and connected resources  
  
# configure-private-agent-for-azure-devops
Powershell script for configuring private agent for Azure DevOps.  
Used with Azure Release pipeline in task 'Azure PowerShell'.  
## Pre-requsites:   
* ARM template for Windows VM deployed with step ARM Deployment (needs to be the output for public IP).
* Task 'Replace tokens' to replace all tokens with pipeline/global variables in script.
* To convert public IP from JSON format:
`$jsonDeploymentOutput = ConvertFrom-Json -InputObject '$(DeploymentOutput)'`
* Start script  
  
    
**BUG TO FIX:** incorrect value of password coming in variable.
