<#
#   Script Name: Get-AzureADGroupMemberToExcel.ps1
#
#   Author:   Didier Hoen 
#   Version:  1.0
#   Date:     04/12/2019
#
#   Require the installation of the following components:
#     - Powershell 5.0 or higher
#     - Powershell Azure Active Directory Module
#     - Module Import-excel
#
#   Script to get member from Dynamic Azure Group.
# 
#>

<# HOW-TO USE

Get-AzureADGroupMemberToExcel -AzureGoup NOM-Du-Groupe

#>


function Get-AzureADGroupMemberToExcel {

    param ([String]$AzureGoup)

    $AzureAdGroup =@()

    #Connect to AzureAD
    $coneckt = Connect-AzureAD

    # Get array information 
    $id = Get-AzureADGroup -Filter "DisplayName eq '$AzureGoup'"
             
    # Get All User and properties from Objectid
    Get-AzureADGroupMember -ObjectId $id.Objectid -All $true | %{
                 
        # Custom Object for export
        $AzureAdGroup += [PSCustomObject]@{
            'Groupe AzureAD' = $group
            Member = $_.Displayname
            Mail = $_.UserPrincipalName
            Departement = $_.Department
            Status = $_.AccountEnabled
            IGG = $_.ExtensionProperty.employeeId
          
        }
    }
    
    $AzureAdgroup | Export-Excel -Path .\$group-members.xlsx -WorksheetName 'Groupes AzureAD' -AutoSize -TableName table4 -TableStyle Medium6
}

[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
$title = 'Audit Groupe AzureAD'
$msg   = 'Entrer le nom du Groupe a Auditer , ex :"WG-FRTGS-Admin" :'
$group = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)

Get-AzureADGroupMemberToExcel -AzureGoup $group