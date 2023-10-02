$ScriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$ConfPath = $ScriptPath+'\conf\zabbix_agent2.conf'
$LogPath = $ScriptPath+'\log\zabbix_agent2.log'
Function GetPSVersion {
    $PSVersion = $PSVersionTable.PSVersion
    return [int]$PSVersion.Major
}
function GetProductType {
    $PSVersion = GetPSVersion
    if ($PSVersion -gt 2) {
        $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
        #Write-Host "new"
    }
    else {
        $osInfo = Get-WmiObject -Class Win32_OperatingSystem
        #Write-Host "old"
    }
    
    if ($osInfo.ProductType -eq 1) {
        #Write-Host "Workstation"
        return 1
    }    
    elseif ($osInfo.ProductType -eq 2 ) {
        #Write-Host "Domain Controller"
        return 2
    }  
    elseif ($osInfo.ProductType -eq 3 ) {
        #Write-Host "Server"
        return 3
    }  
    else {
        #Write-Host "Unknown"
        return 0
    }
}
Function GetOSVersion {
    $OSVersion = [System.Environment]::OSVersion.Version.ToString()  
    $OSVersion = $OSVersion.Split(".")
    return $OSVersion 
} 

function GetWindowsVersionName {
    $OSVersion = GetOSVersion;    
    switch (GetProductType) {
        1 {
            if (($OSVersion[0] -eq 6) -and ($OSVersion[1] -eq 0)) { return "Windows Vista" }
            if (($OSVersion[0] -eq 6) -and ($OSVersion[1] -eq 1)) { return "Windows 7" }
            if (($OSVersion[0] -eq 6) -and ($OSVersion[1] -eq 2)) { return "Windows 8" }
            if (($OSVersion[0] -eq 6) -and ($OSVersion[1] -eq 3)) { return "Windows 8.1" }
            if (($OSVersion[0] -eq 10) -and ($OSVersion[1] -eq 0) -and (([int]$OSVersion[2] -ge 10200) -and ([int]$OSVersion[2] -le 19999))) { return "Windows 10" }
            if (($OSVersion[0] -eq 10) -and ($OSVersion[1] -eq 0) -and (([int]$OSVersion[2] -ge 22000) -and ([int]$OSVersion[2] -le 24000))) { return "Windows 11" }
        }
        2 {
            if (($OSVersion[0] -eq 6) -and ($OSVersion[1] -eq 0)) { return  "Server 2008" }
            if (($OSVersion[0] -eq 6) -and ($OSVersion[1] -eq 1)) { return  "Server 2008 R2" }
            if (($OSVersion[0] -eq 6) -and ($OSVersion[1] -eq 2)) { return  "Server 2012" }
            if (($OSVersion[0] -eq 6) -and ($OSVersion[1] -eq 3)) { return  "Server 2012 R2" }
            if (($OSVersion[0] -eq 10) -and ($OSVersion[1] -eq 0) -and (([int]$OSVersion[2] -ge 9000) -and ([int]$OSVersion[2] -le 14999))) { return "Server 2016" }
            if (($OSVersion[0] -eq 10) -and ($OSVersion[1] -eq 0) -and (([int]$OSVersion[2] -ge 17000) -and ([int]$OSVersion[2] -le 17999))) { return "Server 2019" }
            if (($OSVersion[0] -eq 10) -and ($OSVersion[1] -eq 0) -and (([int]$OSVersion[2] -ge 20000) -and ([int]$OSVersion[2] -le 21999))) { return "Server 2022" }
        }
        3 { 
            if (($OSVersion[0] -eq 6) -and ($OSVersion[1] -eq 0)) { return  "Server 2008" }
            if (($OSVersion[0] -eq 6) -and ($OSVersion[1] -eq 1)) { return  "Server 2008 R2" }
            if (($OSVersion[0] -eq 6) -and ($OSVersion[1] -eq 2)) { return  "Server 2012" }
            if (($OSVersion[0] -eq 6) -and ($OSVersion[1] -eq 3)) { return  "Server 2012 R2" }
            if (($OSVersion[0] -eq 10) -and ($OSVersion[1] -eq 0) -and (([int]$OSVersion[2] -ge 9000) -and ([int]$OSVersion[2] -le 14999))) { return "Server 2016" }
            if (($OSVersion[0] -eq 10) -and ($OSVersion[1] -eq 0) -and (([int]$OSVersion[2] -ge 17000) -and ([int]$OSVersion[2] -le 17999))) { return "Server 2019" }
            if (($OSVersion[0] -eq 10) -and ($OSVersion[1] -eq 0) -and (([int]$OSVersion[2] -ge 20000) -and ([int]$OSVersion[2] -le 21999))) { return "Server 2022" } 
        } 
        default { return "Unknown" }
    }
}

GetWindowsVersionName
Function SetZabbixConfigOldReplace
{
    param (        
        [string]$HostMetadata
    ) 
    $ConfPath = $ScriptPath+'\conf\zabbix_agent2.conf'
    $LogPath = $ScriptPath+'\log\zabbix_agent2.log'
    Copy-Item -Path $ConfPath -Destination $ConfPath'.orig' 
    Write-Host $ConfPath
    Write-Host $LogPath
    (Get-Content -Path $ConfPath) -Replace('# LogFile=c:\\zabbix_agent2.log',"LogFile=$LogPath") | Set-Content -Path $ConfPath
    (Get-Content -Path $ConfPath) -Replace('Server=127.0.0.1', 'Server=192.168.77.70') | Set-Content -Path $ConfPath
    (Get-Content -Path $ConfPath) -Replace('ServerActive=127.0.0.1', 'ServerActive=192.168.77.70') | Set-Content -Path $ConfPath
    (Get-Content -Path $ConfPath) -Replace('Hostname=Windows host', '#Hostname=Windows host') | Set-Content -Path $ConfPath
    (Get-Content -Path $ConfPath) -Replace('# HostnameItem=system.hostname', 'HostnameItem=system.hostname') | Set-Content -Path $ConfPath
    (Get-Content -Path $ConfPath) -Replace('# HostMetadata=', "HostMetadata=$HostMetadata") | Set-Content -Path $ConfPath

}
function SetZabbixConfig {
    param (
        [string]$HostMetadata
    )
    
    
    #$name = [System.Environment]::MachineName.ToString()
    Copy-Item -Path $ConfPath -Destination $ConfPath'.orig' 
    Write-Host $ConfPath
    Write-Host $LogPath
    (Get-Content -Path $ConfPath).Replace('# LogFile=c:\zabbix_agent2.log','LogFile='+$LogPath).Replace('Server=127.0.0.1', 'Server=192.168.77.70').Replace('ServerActive=127.0.0.1', 'ServerActive=192.168.77.70').Replace('Hostname=Windows host', '#Hostname=Windows host').Replace('# HostnameItem=system.hostname', 'HostnameItem=system.hostname').Replace('# HostMetadata=', 'HostMetadata='+$HostMetadata) | Set-Content -Path $ConfPath
}
Function Main {
    switch (GetWindowsVersionName) {
        "Server 2008" {Write-Host "Make config for Windows Server 2008" ; SetZabbixConfigOldReplace -HostMetadata 'Windows2008	a4yhhgdsmsdAh2353923jdhfs76Mnd720612073203hdfsdkj'}
        "Server 2008 R2" { Write-Host "Make config for Windows Server 2008 R2" ; SetZabbixConfigOldReplace -HostMetadata 'Windows2008R2	KjiflmHf3jnfklf5yt8dbhf0nfkfToGfibOtleib'  }
        "Server 2012" {Write-Host "Make config for Windows Server 2012" ; SetZabbixConfig -HostMetadata "Windows2012	9umjv78e11vapzmzaqnb42190fgeopkjkjgf"}
        "Server 2012 R2" {Write-Host "Make config for Windows Server 2012 R2" ; SetZabbixConfig -HostMetadata "Windows2012R2	TnfGjvjkj427t08XenjRYjNJjefqfeoomjbngK18"}
        "Server 2016" {Write-Host "Make config for Windows Server 2016" ; SetZabbixConfig -HostMetadata "Windows2016	dfwkfjqod123rfadfad1mGhJ9HfKjksd712jbdnaksud5854ej"}
        "Server 2019" {Write-Host "Make config for Windows Server 2019" ; SetZabbixConfig -HostMetadata "Windows2019	dNc56Bys623h973NKuBNmsdoqdwqu7241bcgtfrsalkzfgkj"}
        "Server 2022" {Write-Host "Make config for Windows Server 2022" ; SetZabbixConfig -HostMetadata "Windows2022	8tewgfzvdqnvpzYJdfzzzaq1ndjfewui56830xgqfnmj"}
        "Windows 7" {Write-Host "Make config for Windows 7" ; SetZabbixConfig -HostMetadata "Windows7	lmmnfeov93jAwfwmCMIwdv81251kdfeqqfpzmnafw1"}
        "Windows 8" {Write-Host "Make config for Windows 8" ; SetZabbixConfig -HostMetadata "Windows8	dbyljdjpybr8ghzvbyeltdtfzhuqyzYe23"}
        "Windows 8.1" {Write-Host "Make config for Windows 8.1" ; SetZabbixConfig -HostMetadata "Windows8.1	     dkjmv13ev10v1scsqjvadawth6kk7777LD"}
        "Windows 10" {Write-Host "Make config for Windows 11" ; SetZabbixConfig -HostMetadata "Windows10	yeDjn5nje6tYjhvnfrYtnjXnjhfymitPaebsd"}
        "Windows 11" { Write-Host "Make config for Windows 11" ; SetZabbixConfig -HostMetadata "Windows11	xtxtetoxeYjdfzdbylfxnjkbLLgjckt10Ye0K" }
        Default { Write-Host "Windows version unknown, service not installed" ; break }
    }
    
}

Main

&$ScriptPath\bin\zabbix_agent2.exe --config $ConfPath --install
Start-Sleep -Seconds 3
Start-Service "Zabbix Agent 2"
start-sleep -Seconds 3
Get-service "Zabbix Agent 2"

