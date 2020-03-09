<#
#   Script Name: Get-AzureADUserByDepartment.ps1
#
#   Author:   Didier Hoen 
#   Version:  1.0
#   Date:     09/03/2020
#
#   Require the installation of the following components:
#     - Powershell 5.0 or higher
#     - Powershell Azure Active Directory Module
#     - Module Import-excel
#
#   Script to get users by department from Dynamic Azure Group.
# 
#>

<# HOW-TO USE

Get-AzureADUserByDepartmentToExcel -AzureGoup NOM-Du-Groupe

#>


function Get-AzureADUserByDepartmentToExcel {

    param ([String]$AzureGoup)

    $AzureAdGroupExport =@()

    #Connect to AzureAD
    $coneckt = Connect-AzureAD

             
    # Get All User and properties from Objectid
    Get-AzureADUser -Filter "startswith(Department,'$AzureGoup')" |  %{
                 
        # Custom Object for export
        $AzureAdGroupExport += [PSCustomObject]@{
            'Recherche' = $AzureGoup
            Member = $_.Displayname
            Prenom = $_.givenName
            Nom = $_.surname
            Mail = $_.UserPrincipalName
            Departement = $_.Department
            Status = $_.AccountEnabled
            IGG = $_.ExtensionProperty.employeeId
          
        }
    }
    $AzureGoup = $AzureGoup -replace "/","-"
    $AzureAdGroupExport | Export-Excel -Path .\$AzureGoup-membersByDepartment.xlsx -WorksheetName 'Groupes AzureAD' -AutoSize -TableName table4 -TableStyle Medium6
}

<# Déclaration du form  #>
[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
$title = 'Audit User By Department'
$msg   = 'Entrer le nom du departement , ex :"XXX/YYY/ZZZ":'
$GroupAAD = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)

$GroupAAD

if ($GroupAAD -eq $null){
    Write-Host "Pas d'utilisateur" 
    }else{

    Get-AzureADUserByDepartmentToExcel -AzureGoup "$GroupAAD"
    Write-Host "Job Done for " $GroupAAD -ForegroundColor Green
}
