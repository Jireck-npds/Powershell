function Connect-NPDSAdmin {
$urlsite ="" # A Remplir

$R=Invoke-WebRequest http://$urlsite/admin.php -SessionVariable admin
$Form1 = $R.Forms[1]
$Form1.Fields["aid"]="Root"
$Form1.Fields["pwd"]="Fontaine38600"
$Req=Invoke-WebRequest -Uri ("http://$urlsite/" + $Form1.Action) -WebSession $admin -Method POST -Body $Form1.Fields
$Req.StatusDescription

Write-Host "Acces Granded"
}
