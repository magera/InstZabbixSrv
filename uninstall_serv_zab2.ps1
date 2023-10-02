$ScriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$ConfPath = $ScriptPath+'\conf\zabbix_agent2.conf'
Stop-Service "Zabbix Agent 2"
&$PSScriptRoot\bin\zabbix_agent2.exe --config $PSScriptRoot\conf\$ConfPath --uninstall