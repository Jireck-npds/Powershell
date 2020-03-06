function Connect-NPDSUser {

$urlsite ="" A Remplir
    $cred = Get-Credential

    $R=Invoke-WebRequest http://$urlsite/user.php -SessionVariable user
    $Form1 = $R.Forms[0]
    $Form1.Fields["uname"]=$cred.UserName
    $Form1.Fields["pass"]=$cred.GetNetworkCredential().Password
    $Req=Invoke-WebRequest -Uri ("http://$urlsite/" + $Form1.Action) -WebSession $user -Method POST -Body $Form1.Fields

    if ($user.Credentials -eq $false){
        Write-Host -ForegroundColor Green "USER Acces Granded"
    }else{
        Write-Host -ForegroundColor Red "USER Acces Denied"
    }
}
