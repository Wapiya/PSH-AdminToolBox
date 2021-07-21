<#
    .SYNOPSIS
    Restart services based on config file
    .DESCRIPTION
    restart service in priority of a config file - default config file has to be the name of the script ending with csv
    and with the following file format SvcName;Priority;Description, location in the same path than the *.ps1 file. 
    You can also specify a path to a csv file with the parameter '-config'. The logfile will be created in the same folder
    as the config file if specified. Instead a user context there is also an unatended option alvailable to e.g. schedule restarts
    With the switch '-reverse' it is possible to stop the services like specified and afterwards start them in reverse order
    .NOTES
    Author:  Steffen Dueppuis created 23.03.2018
    Command need RSAT tools for Active Directory or must be executed on a domain controller
    to grant non-admin users right to restart services take a look at
    >> http://woshub.com/set-permissions-on-windows-service/
    >> https://www.microsoft.com/en-us/download/details.aspx?id=23510
    Examle: subinacl.exe /service "DOKuStar License Observer" /grant=schoeck\app_AFI_users=PTO
    Chnagelog:
    01.04.2020: added "stop services and start in reverse order" instead of using restart-service CMDlet and added error handling
    02.11.2020: added 'unatended' and 'Config'
    19.07.2021: added 'skipping' of disabled servvices
    .PARAMETER Reverse
    stop services based on CSV file and start them in reverse order, instead of restarting services in order (one after the other)
    .PARAMETER Logging
    adds a logfile with name of user who executed the script and status of actions
    .PARAMETER Config
    specify a configfile location, e.g. if automated setting of path fails or confiig and logfile should not be in same folder than
    the script itself
    .PARAMETER Unatended
    skip user selection menu and execute directly! Options are 1=restart, 2=stop or 3=start, combination with -reverse is also possible
    .EXAMPLE
    Restart-Serice-InOrder
    Option 1/R: restart named services in order one after another. If service is already stopped it´ll be started
    Option 2/O: stop services, prompt if already stopped
    Option 3/A: start service, prompt if already startet
    .EXAMPLE
    Restart-Serice-Inorder -reverse
    Option 1/R: first stop services and then start them in reverse order
    Option 2/O: stop services, prompt if already stopped
    Option 3/A: start service in reverse order, prompt if already startet
#>

### BEGIN of Function Restart-Service-InOrder
[CmdletBinding()]
param
(
    [Parameter(Mandatory = $false)]
        [Switch]$Reverse,
    [Parameter(Mandatory = $false)]
        [Switch]$Logging,
    [Parameter(Mandatory = $false)]
        [String]$Config,
    [Parameter(Mandatory = $false)]
        [Int]$Unatended    
)

### BEGIN define variables
if($config){
    $filepath = $Config
    $LogFile = $Config -replace (".csv",".log")
}
else{
    $filepath = $MyInvocation.MyCommand.Source -replace (".ps1",".csv")
    $LogFile = $MyInvocation.MyCommand.Source -replace (".ps1",".log")
}
$services = Import-CSV $filepath -delimiter ";"
$services = $services | Sort-Object Priority
$services_reverse = $services | Sort-Object Priority -Descending
$Errors = 0
$usr = $env:username  
Write-Verbose ("read configuration from: " + $filepath)
if($Logging){ Write-Verbose ("write logfile to: " + $LogFile) }
#### End define variables

### BEGIN logfile creation
# creates logfile if not existing and adds content to the end when existing #
function write_log ($Inhalt)
{
$FileExists = Test-Path $LogFile
    $DateNow = Get-Date -Format "dd.MM.yyyy HH:mm"
    $FileInp = $DateNow + ' | ' + $Inhalt
    If($FileExists -eq $True){ Add-Content $LogFile -value $FileInp }
    else {
       New-Item $Logfile -type file
       Add-Content $LogFile -value $FileInp
    }
}
### END logfile creation ##

# Usermneu if not unatended specified
if(!$Unatended){
    $title = 'Service Control Wizard'
    $prompt = 'Restart, stop or start services in order or cancel the script?'
    $Cancel = New-Object System.Management.Automation.Host.ChoiceDescription '&Cancel','Aborts the operation'
    $Restart = New-Object System.Management.Automation.Host.ChoiceDescription '&Restart','restart services'
    $Stop = New-Object System.Management.Automation.Host.ChoiceDescription 'St&op','stop services'
    $Start = New-Object System.Management.Automation.Host.ChoiceDescription 'St&art','start services'
    $options = [System.Management.Automation.Host.ChoiceDescription[]] ($Cancel,$Restart,$Stop,$Start)
    $choice = $host.ui.PromptForChoice($title,$prompt,$options,0)
    Write-verbose ("Selection was: " + $choice)
}else{$choice = $Unatended}

# start lgging actions....
if($Logging){ write_log ("executed by " + $usr + " (Reverse=" + $Reverse +")") }

### BEGIN restarting, starting or stopping services
if($choice){
    if(($Reverse -or $choice -eq 2) -and $choice -ne 3){Write-Host -ForegroundColor Yellow "Stopping service in order of priority..."}
    else{ if(!$Reverse){ Write-Host -ForegroundColor Yellow "(re)starting service in order of priority..." } }
    foreach($Service in $services){
        $Svc = $Service.SvcName
        $Desc = $Service.Description
        if(Get-Service -name $Svc){
            $SvcState = Get-Service -Name $svc | Select-Object Status -ExpandProperty Status
            $SvcStartType = Get-Service -Name $svc | Select-Object StartType -ExpandProperty StartType
            if($SvcStartType -like "*dis*"){
                Write-Host -ForegroundColor Red ("ALERT: " + $Desc + " is disabled! Ongoing maintenance? Suppport technician via remote session active?")
                $Errors = $Errors +1
                if($Logging){ write_log ("Alert! " + $Desc + " is disabled!") }
            }
            if(!$Reverse -or $choice -le 2){ Write-Host -ForegroundColor Gray "- $Desc..." -NoNewline }
            if($SvcState -eq "running"){
                # stop service if 'reverse' or 'stop' is chosen, skip if service is disabled
                if(($Reverse -or $choice -eq 2) -and $choice -ne 3){
                    if($SvcStartType -notlike "*dis*"){
                        Stop-Service -Name $Svc -Force
                        Write-Host -ForegroundColor green ("stopped") 
                        if($Logging){ write_log ($Desc + " stopped") }
                    }else{ write-host -ForegroundColor red ("skipped!") }
                }
                # just restart service, skik if service is disabled
                elseif($choice -eq 1){
                    if($SvcStartType -notlike "*dis*"){
                        restart-Service -Name $Svc -force
                        if($Logging){ write_log ($Desc + " restarting") }
                    }else{ write-host -ForegroundColor ("restart skipped!") }
                }else{ 
                    if(!$Reverse){ 
                        Write-Host -ForegroundColor Green "already running..." 
                        if($Logging){ write_log ($Desc + " already running") }
                    }    
                }
            }else{ 
                if($choice -ne 3){
                    Write-Host -ForegroundColor yellow "already stopped..." 
                    if($Logging){ write_log ($Desc + " already stopped") }
                }
                # start service if stopped and 'restart' or 'start' is chosen, skip if service is disabled
                if($choice -ne 2 -and !$Reverse){
                    if($SvcStartType -notlike "*dis*"){
                        do{
                                start-service -Name $Svc
                                Start-Sleep -Seconds 1
                                $RunSec = $RunSec +1
                                $SvcState = Get-Service -Name $svc | Select-Object Status -ExpandProperty Status
                        }until($SvcState -eq "running" -and $RunSec -lt 30)
                    }
                    if($SvcState -eq "running"){
                        Write-Host -ForegroundColor green ("started")
                        if($Logging){ write_log ($Desc + " started") }
                    }
                    else{
                        $Errors = $Errors +1
                        Write-Host -ForegroundColor Red ("  starting " + $Desc + " failed!")
                        if($Logging){ write_log ("starting " + $Desc + " failed!") }
                    }
                }   
            }
            $SvcState=Get-Service -Name $svc | Select-Object Status -ExpandProperty Status
            if($SvcState -eq "running" -and $choice -ne 3){ 
                if($SvcStartType -notlike "*dis*"){
                    Write-Host -ForegroundColor green ("running (again)!") 
                    if($Logging){ write_log ($Desc + " running (again)") }
                }
            }
        }
        else{Write-host -ForegroundColor DarkRed "No Service called $Desc found on System!"}
    }### END restarting, starting or stopping services

    ### BEGIN starting services in reverse ordeer
    if($Reverse -and $choice -ne 2){
        Write-Host ""
        Write-Host -ForegroundColor Yellow "starting services in reverse order..."
        foreach($Service in $services_reverse){
            $Svc = $Service.SvcName
            $Desc = $Service.Description
            if(Get-Service -name $Svc){
                $RunSec = 0
                $SvcState = Get-Service -Name $svc | Select-Object Status -ExpandProperty Status
                $SvcStartType = Get-Service -Name $svc | Select-Object StartType -ExpandProperty StartType
                Write-Host -ForegroundColor Gray "- $Desc..." -NoNewline
                if($SvcStartType -notlike "*dis*"){
                    if($SvcState -eq "running"){
                        Write-Host -ForegroundColor green ("already running...") 
                        if($Logging){ write_log ($Desc + " already running") } }
                    else{
                        do{
                            start-service -Name $Svc
                            Start-Sleep -Seconds 1
                            $RunSec = $RunSec +1
                            $SvcState = Get-Service -Name $svc | Select-Object Status -ExpandProperty Status

                        }until($SvcState -eq "running" -and $RunSec -lt 30)
                        if($SvcState -eq "running"){ 
                            Write-Host -ForegroundColor green ("running") 
                            if($Logging){ write_log ($Desc + " running") }}
                        else{
                            $Errors = $Errors +1
                            Write-Host -ForegroundColor Red ("starting " + $Desc + " failed!")
                            if($Logging){ write_log ("starting " + $Desc + " failed!") }
                        }
                    }
                }else{
                    Write-Host -ForegroundColor red ("service was not (re)started, because it is disabled!")
                    $Errors = $Errors +1
                    if($Logging){ write_log ($Desc + " not restartet because it is disabled!") }
                }
                
            }
            else{Write-host -ForegroundColor DarkRed "No Service called $Desc found on System!"}
        }
    }### END starting services in reverse order

    ### BEGIN result of service operation
    write-host ""
    if($Errors -eq 0){
        if($choice -eq 1){$Result = "running again"}
        elseif($choice -eq 2){$Result = "stopped"}
        else{$Result = "running"}
        Write-Host -ForegroundColor yellow ("all services are $result, window will close in 10 seconds!")
        Start-Sleep -Seconds 10
    }else{
        Write-Host -ForegroundColor Red ("$Errors occured during (re)starting service, please raise a ticket naming failed services!")
        Write-Host -ForegroundColor gray ("`nyou can close this window now...")
    }
    ### END result of service operation
}### END of function Restart-Service-InOrder