 #producttype
 $ptype = Get-WmiObject win32_operatingSystem | select producttype |Out-String
 $ptype = $ptype.Replace("producttype","")
 $ptype = $ptype.Replace("-","")
 $ptype = $ptype.trim()
 #проверка. удалить
 #Write-Host "продукттип - $ptype"
 #версия винды
 $vs =  [system.environment]::osversion.version.ToString()
 #разделяем на массив строк между точками
 $vs =  $vs.Split(".")
 #Строковые элементы $vs в integer и в новый массив 
 $vint =@()
 foreach ($x in $vs)
    {
    $x = [int]$x
    $vint += $x 
    }
 #проверка (потом удалить)
 #$vint[1].gettype()
 
 #выясняем версию винды
 $pin = $false
 while ($pin -eq $false) {
 if ($ptype -ne 1) 
    {
    if (($vint[0] -eq 6) -and ($vint[1] -eq 0)) {$vinda = "2008"; $pin = $true; break}
    if (($vint[0] -eq 6) -and ($vint[1] -eq 1)) {$vinda = "2008R2"; $pin = $true; break}
    if (($vint[0] -eq 6) -and ($vint[1] -eq 2)) {$vinda = "2012"; $pin = $true; break}
    if (($vint[0] -eq 6) -and ($vint[1] -eq 3)) {$vinda = "2012R2"; $pin = $true; break}
    if (($vint[0] -eq 10) -and ($vint[1] -eq 0) -and ($vint[2] -in 9000..14999)) {$vinda = "2016"; $pin = $true; break}
    if (($vint[0] -eq 10) -and ($vint[1] -eq 0) -and ($vint[2] -in 17000..17999)) {$vinda = "2019"; $pin = $true; break}
    if (($vint[0] -eq 10) -and ($vint[1] -eq 0) -and ($vint[2] -in 20000..21999)) {$vinda = "2022"; $pin = $true; break}
    if (($vint[0] -eq 10) -and ($vint[1] -eq 0) -and (20005 -in 20000..21000)) {$vinda = 5}
    }
if ($ptype -eq 1) 
    {
    if (($vint[0] -eq 6) -and ($vint[1] -eq 0)) {$vinda = "vista"; $pin = $true; break}
    if (($vint[0] -eq 6) -and ($vint[1] -eq 1)) {$vinda = "win7"; $pin = $true; break}
    if (($vint[0] -eq 6) -and ($vint[1] -eq 2)) {$vinda = "win8"; $pin = $true; break}
    if (($vint[0] -eq 6) -and ($vint[1] -eq 3)) {$vinda = "win8.1"; $pin = $true; break}
    if (($vint[0] -eq 10) -and ($vint[1] -eq 0) -and ($vint[2] -in 10200..19999)) {$vinda = "win10"; $pin = $true; break}
    if (($vint[0] -eq 10) -and ($vint[1] -eq 0) -and ($vint[2] -in 22000..24000)) {$vinda = "win11"; $pin = $true; break}
    }}

#Удаляем, вставив переменную $vinda в путь
#Stop-Service "Zabbix Agent 2"
#&$PSScriptRoot\bin\zabbix_agent2.exe --config $PSScriptRoot\conf\$vinda.conf --uninstall
pause
