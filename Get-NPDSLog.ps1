function Get-NPDSLog{
$urlsite = "" # a remplir
$securelog = Invoke-WebRequest -Uri ("http://$urlsite/admin.php?op=Extend-Admin-SubModule&ModPath=session-log&ModStart=session-log&subop=session") -WebSession $admin
#$table = $securelog.ParsedHTML.getElementsByTagName("table")

$tables = @($securelog.ParsedHtml.getElementsByTagName("TABLE"))
$TableNumber = 0
$table = $tables[$TableNumber]

$titles = @()

$rows = @($table.Rows)

foreach($row in $rows)
{

    $cells = @($row.Cells)

    if($cells[0].tagName -eq "TH")

    {
        $titles = @($cells | % { ("" + $_.InnerText).Trim() })
        continue
    }

    $resultObject = [Ordered] @{}

    for($counter = 0; $counter -lt $cells.Count; $counter++)
    {

        $title = $titles[$counter]
        if(-not $title) { continue }
        $resultObject[$title] = ("" + $cells[$counter].InnerText).Trim()
    }

    [PSCustomObject] $resultObject | Format-Table -Auto
    }
}
