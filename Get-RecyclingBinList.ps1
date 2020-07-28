<#
#   Script Name: Get-RecyclingBinList.ps1
#
#   Author:   Didier Hoen 
#   Version:  1.0
#   Date:     28/07/2020
#
#   Require the installation of the following components:
#     - Module Import-excel (ImportExcel )
#     - Powershell 5.0 or higher
#     - Powershell PNP Module (SharePointPnPPowerShellOnline)
#
#   Script to List RecyclingBin of website.
#>




    <# Déclaration du form  #>
    [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    $title = 'Audit SharePoint Online'
    $msg   = 'Entrer le nom du Site , ex :"TGS-TLS" pour l URL "https://totalworkplace.sharepoint.com/sites/TGS-TLS":'
    $site = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)

    $siteUrl = "https://totalworkplace.sharepoint.com/sites/$site"

    $OutputReport = ".\$site-Corbeille.xlsx"
    
    $Array = @()

    <# output file name and location #>
    if (Test-Path $OutputReport)
    {
        Write-Host -ForegroundColor Yellow "Suppression de l'ancien fichier XLSX"
        try{
            Remove-Item $OutputReport -ErrorAction Stop
        }
        catch{
            Write-Host "Fichier XLSX avec le meme Nom est ouvert"
            Start-Sleep -Seconds 10
        }
    }

    Write-Host "Start Script" -ForegroundColor Green

    # connect to SP online site collection
    Connect-PnPOnline -Url $siteUrl -UseWebLogin

    Get-PnPRecycleBinItem | foreach {
        $Title = $_.Title
        $ItemType = $_.ItemType
        $Size = $_.Size
        $ItemState = $_.ItemState
        $DirName = $_.DirName
        $DeletedByName = $_.DeletedByName
        $DeletedByMail = $_.DeletedByEmail
        $DeletedDate = $_.DeletedDate
        $ID = $_.id
        $Guid = $ID.Guid
        $AuthorName = $_.AuthorName

        $Array += [PSCustomObject]@{
            'Nom' = $Title
            'Type' = $ItemType
            'Taille' = $Size
            'Corbeille' = $ItemState
            'Repertoire' = $DirName
            'Auteur' = $AuthorName
            'Supprimé Par Nom' = $DeletedByName
            'Supprimé Par Mail' = $DeletedByMail
            'Date de Suppression' = $DeletedDate
            # State = $State
            'Id' = $id
        }

    }

    $Array | Export-Excel -Path $OutputReport -AutoSize -TableName table01 -TableStyle Medium6