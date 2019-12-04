####################################################################################################
#	
#	Script Name: AuditPermissions-dh.ps1
#
#   Author:   Didier Hoen
#   Version:  1.0
#   Date:     11/07/2019 
#
#   Require the installation of the following components:
#     - Export-Excel Module
#     - ActiveDirectory Module
#     - Powershell 5.0 or higher
#
#
#   Revision history
#   +--------+---------------+-----------------------+-------------------------------------+
#   |1.0     |11/07/2019     | Didier Hoen   | Creation of the script              |
#   +--------+---------------+-----------------------+-------------------------------------+
#
#
####################################################################################################


Import-Module .\ImportExcel
Import-Module ActiveDirectory

function Get-ADNestedGroupMembers { 
<#  
.SYNOPSIS
Author: Piotr Lewandowski
Version: 1.01

.DESCRIPTION
Get nested group membership from a given group or a number of groups.

Function enumerates members of a given AD group recursively along with nesting level and parent group information. 
It also displays if each user account is enabled. 
When used with an -indent switch, it will display only names, but in a more user-friendly way (sort of a tree view) 
   
.EXAMPLE   
Get-ADNestedGroupMembers "MyGroup" | Export-CSV .\NedstedMembers.csv -NoTypeInformation

.EXAMPLE  
Get-ADGroup "MyGroup" | Get-ADNestedGroupMembers | ft -autosize
            
.EXAMPLE             
Get-ADNestedGroupMembers "MyGroup" -indent
 
#>

param ( 
[Parameter(ValuefromPipeline=$true,mandatory=$true)][String] $GroupName, 
[int] $nesting = -1, 
[int]$circular = $null, 
[switch]$indent 
) 
    function indent  
    { 
    Param($list) 
        foreach($line in $list) 
        { 
        $space = $null 
         
            for ($i=0;$i -lt $line.nesting;$i++) 
            { 
            $space += "    " 
            } 
            $line.name = "$space" + "$($line.name)"
        } 
      return $List 
    } 
     
$modules = get-module | select -expand name
    if ($modules -contains "ActiveDirectory") 
    { 
        $table = $null 
        $nestedmembers = $null 
        $adgroupname = $null     
        $nesting++   
        $ADGroupname = get-adgroup $groupname -properties memberof,members,description 
        $memberof = $adgroupname | select -expand memberof 
        write-verbose "Checking group: $($adgroupname.name)" 
        if ($adgroupname) 
        {  
            if ($circular) 
            { 
                $nestedMembers = Get-ADGroupMember -Identity $GroupName -recursive 
                $circular = $null 
            } 
            else 
            { 
                $nestedMembers = Get-ADGroupMember -Identity $GroupName | sort objectclass -Descending
                if (!($nestedmembers))
                {
                    $unknown = $ADGroupname | select -expand members
                    if ($unknown)
                    {
                        $nestedmembers=@()
                        foreach ($member in $unknown)
                        {
                        $nestedmembers += get-adobject $member
                        }
                    }

                }
            } 
 
            foreach ($nestedmember in $nestedmembers) 
            { 
                $Props = @{Type=$nestedmember.objectclass;Name=$nestedmember.name;DisplayName="";ParentGroup=$ADgroupname.name;Enabled="";Nesting=$nesting;DN=$nestedmember.distinguishedname;Description=$ADgroupname.description;Comment="";EmailAddress=$nestedadmember.EmailAddress} 
                 
                if ($nestedmember.objectclass -eq "user") 
                { 
                    $nestedADMember = get-aduser $nestedmember -properties enabled,displayname,description,EmailAddress 
                    $table = new-object psobject -property $props 
                    $table.enabled = $nestedadmember.enabled
                    $table.name = $nestedadmember.samaccountname
                    $table.displayname = $nestedadmember.displayname
                    $table.description = $nestedadmember.description
                    $table.EmailAddress = $nestedadmember.EmailAddress
                    if ($indent) 
                    { 
                    indent $table | select @{N="Name";E={"$($_.name)  ($($_.displayname))"}}
                    } 
                    else 
                    { 
                    # $table | select type,name,displayname,parentgroup,nesting,enabled,dn,comment 
                    $table | select parentgroup, displayname, name, description, type,nesting,enabled,dn,comment,EmailAddress 
                    } 
                } 
                elseif ($nestedmember.objectclass -eq "group") 
                {  
                    $table = new-object psobject -Property $props 
                     
                    if ($memberof -contains $nestedmember.distinguishedname) 
                    { 
                        $table.comment ="Circular membership" 
                        $circular = 1 
                    } 
                    if ($indent) 
                    { 
                    indent $table | select name,comment | %{
						
						if ($_.comment -ne "")
						{
						[console]::foregroundcolor = "red"
						write-output "$($_.name) (Circular Membership)"
						[console]::ResetColor()
						}
						else
						{
						[console]::foregroundcolor = "yellow"
						write-output "$($_.name)"
						[console]::ResetColor()
						}
                    }
					}
                    else 
                    { 
                    # $table | select type,name,displayname,parentgroup,nesting,enabled,dn,comment 
                    $table | select parentgroup, displayname, name, description, type,nesting,enabled,dn,comment,EmailAddress 
                    } 
                    if ($indent) 
                    { 
                       Get-ADNestedGroupMembers -GroupName $nestedmember.distinguishedName -nesting $nesting -circular $circular -indent 
                    } 
                    else  
                    { 
                       Get-ADNestedGroupMembers -GroupName $nestedmember.distinguishedName -nesting $nesting -circular $circular 
                    } 
              	                  
               } 
                else 
                { 
                    
                    if ($nestedmember)
                    {
                        $table = new-object psobject -property $props
                        if ($indent) 
                        { 
    	                    indent $table | select name 
                        } 
                        else 
                        { 
                        # $table | select type,name,displayname,parentgroup,nesting,enabled,dn,comment    
                        $table | select parentgroup, displayname, name, description, type,nesting,enabled,dn,comment,EmailAddress     
                        } 
                     }
                } 
              
            } 
         } 
    } 
    else {Write-Warning "Active Directory module is not loaded"}        
}

$XPath = Read-Host -Prompt 'Input your Directory Path'
$Xdeep = Read-Host -Prompt 'Input your depth'
$Xdate = get-date -format yyyy-MM-dd 

$ErrorActionPreference = "silentlycontinue"

$GroupGroup = @()
$hash = @()
$MyObject = @()

$MyObject = gci -Depth $Xdeep -Directory -Path "$XPath"
$MyObject += Get-Item -Path "$XPath"
$count = $MyObject.count
$j = 1
$MyObject |  Get-Acl | ForEach-Object{
        $fullPathName = ($_.Path).Replace('Microsoft.PowerShell.Core\FileSystem::','')
        $pathOwner = $_.Owner
        $_.Access|
        ForEach-Object{
          Write-Progress -Activity "Collecting Tree" -status "Finding all Path $j" ` -percentComplete ($j / $count.count*100)
          $j++
          $hash +=   [PSCustomObject]@{
                Path = $fullPathName
                Owner = $pathOwner
                IdentityReference = $_.IdentityReference
                FileSystemRights = $_.FileSystemRights
                AccessControlType = $_.AccessControlType
                IsInherited = $_.IsInherited
                InheritanceFlags = $_.InheritanceFlags
                PropagationFlags = $_.PropagationFlags
            }
            $grp = [string]$_.IdentityReference
            $grp = $grp.Split('\')
            
            
            if ( ($grp[1] -eq "Authenticated Users") -or ($grp -eq "Domain Users") -or ($grp -eq "Domain Admins") -or ($test -Contains $grp ) -or ($grp -contains "BUILTIN") -or ( [string]::IsNullOrWhitespace($grp[1]) ) ) {
                Write-debug "PATH $fullPathName | SPECIAL GROUP $grp "
              

             }else{
               Write-Debug -ForegroundColor Green "groupe $grp"

               $t = $grp[1]
               $ObjectClass = (Get-ADObject -Filter { SamAccountName -like $t } ).ObjectClass
               
               If ($ObjectClass -eq "Group"){
                    $GroupGroup += $grp[1]
                }
                
            }
         $test += [string]$_.IdentityReference
        }
    }

$hash | Export-Excel .\Rapport_$Xdate.xlsx -WorksheetName 'Extract' -AutoSize -TableName table -TableStyle Medium6 

$Groupes = $GroupGroup | select -Unique

$i = 1
$Groupes.count
$TGroup = @()

ForEach($o in $Groupes){
$TGroup += Get-ADGroup $o | Get-ADNestedGroupMembers -ErrorAction SilentlyContinue

Write-Progress -Activity "Collecting Group" -status "Finding all groups and users $i" ` -percentComplete ($i / $Groupes.count*100)
$i++
}
$TGroup | select parentgroup, displayname, name, description, type,nesting,enabled,dn,comment,EmailAddress  -Unique | Export-Excel .\Rapport_$Xdate.xlsx -WorksheetName 'groupmembers' -AutoSize -TableName table1 -TableStyle Medium6 
