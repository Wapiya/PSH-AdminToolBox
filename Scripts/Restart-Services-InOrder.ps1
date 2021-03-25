<#
    .SYNOPSIS
    Restart services based on config file
    .DESCRIPTION
    Restart services in priority of a config file - default config file is named like the script ending with .csv isntead of .ps1
    and in the following file format SvcName;Priority;Description. The file has to be stored in the same location as the *.ps1
    file. You can also specify a path to a csv file with the parameter '-config'. The logfile will be created in the same folder
    as the config file if specified. Instead a user context there is also an unatended option alvailable to e.g. schedule restarts
    With the switch '-reverse' it is possible to stop the services like specified and afterwards start them in reverse order
    .NOTES
    Author:  Steffen Dueppuis created 02.11.2020
    Command need RSAT tools for Active Directory or must be executed on a domain controller
    to grant non-admin users right to restart services take a look at
    >> http://woshub.com/set-permissions-on-windows-service/
    >> https://www.microsoft.com/en-us/download/details.aspx?id=23510
    Examle: subinacl.exe /service "name of the sercvice" /grant=domain\group
    Chnagelog:
    .PARAMETER Reverse
    stop services based on CSV file and start them in reverse order, instead of restarting services in order (one after the other)
    .PARAMETER Logging
    adds a logfile with name of user who executed the script and also log the status of the executed actions
    .PARAMETER Config
    specify a configfile location, e.g. if automated setting of path fails or confiig and logfile should not be in same folder than
    the script itself
    .PARAMETER Unatended
    skip user selcetion menu and execute directly! Options are 1=restart, 2=stop or 3=start, combination with -reverse is also possible
    .EXAMPLE
    Restart-Serice-InOrder
    Option 1/R: resatrt named services in order one after another. If service is already stopped it´ll be started
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
#$ErrorActionPreference="SilentlyContinue"
$usr = $env:username  
Write-Verbose ("read configuration from: " + $filepath)
if($Logging){ Write-Verbose ("write lgofile to: " + $LogFile) }
#### End define variables

### BEGIN logfile creation
# creates logfile if not existing and adds content to the end when existing #
function write_log ($Inhalt)
{
$FileExists = Test-Path $LogFile
    $DateNow = Get-Date -Format "dd.MM.yyyy HH:mm"
    $FileInp = $DateNow + ' | ' + $Inhalt
    If ($FileExists -eq $True){
        Add-Content $LogFile -value $FileInp
    } else {
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
    
    $choice1 = $host.ui.PromptForChoice($title,$prompt,$options,0)
    Write-verbose ("Selection was: " + $choice1)
}else{$choice1 = $Unatended}

# start lgging actions....
if($Logging){ write_log ("executed by " + $usr + " (Reverse=" + $Reverse +")") }

### BEGIN restarting, starting or stopping services
if($choice1){
    if(($Reverse -or $choice1 -eq 2) -and $choice1 -ne 3){Write-Host -ForegroundColor Yellow "Stopping service in order of priority..."}
    else{ 
        if(!$Reverse){ Write-Host -ForegroundColor Yellow "(re)starting service in order of priority..." } 
    }
    foreach($Service in $services){
        $Svc = $Service.SvcName
        $Desc = $Service.Description
        if(Get-Service -name $Svc){
            $SvcState = Get-Service -Name $svc | Select-Object Status -ExpandProperty Status
            if($SvcState -eq "running"){
                # stop service if 'reverse' or 'stop' is chosen
                if(($Reverse -or $choice1 -eq 2) -and $choice1 -ne 3){
                    Write-Host -ForegroundColor Gray "- $Desc..."
                    if($Logging){ write_log ($Desc + " stopping") }
                    Stop-Service -Name $Svc -Force
                }
                # just restart service
                elseif($choice1 -eq 1){
                    Write-Host ""
                    Write-Host "$Desc..."
                    if($Logging){ write_log ($Desc + " restarting") }
                    restart-Service -Name $Svc -force
                }else{ 
                    if(!$Reverse){ 
                        Write-Host -ForegroundColor Green "- $Desc already running..." 
                        if($Logging){ write_log ($Desc + " already running") }
                    }    
                }
            }else{ 
                if($choice1 -ne 3){ 
                    Write-Host -ForegroundColor Gray "- $Desc already stopped..." 
                    if($Logging){ write_log ($Desc + " already stopped") }
                }
                # start service if stopped and 'restart' or 'start' is chosen
                if($choice1 -ne 2 -and !$Reverse){
                    do{
                        start-service -Name $Svc -ErrorAction SilentlyContinue
                        Start-Sleep -Seconds 1
                        $RunSec = $RunSec +1
                        $SvcState = Get-Service -Name $svc | Select-Object Status -ExpandProperty Status
                    }
                    until($SvcState -eq "running" -and $RunSec -lt 30)
                    if($SvcState -eq "running"){ 
                        Write-Host -ForegroundColor gray ("- $Desc")
                        if($Logging){ write_log ($Desc + " started") }
                    }
                    else{
                        $Errors = $Errors +1
                        Write-Host -ForegroundColor Red ("- error starting $Desc!")
                        if($Logging){ write_log ("Error starting " + $Desc) }
                    }
                }   

            }
            $SvcState=Get-Service -Name $svc | Select-Object Status -ExpandProperty Status
            if($SvcState -eq "running" -and $choice1 -ne 3){ 
                Write-Host -ForegroundColor green ("running (again)!") 
                if($Logging){ write_log ($Desc + " running (again)") }
            }
        }
        else{Write-host -ForegroundColor DarkRed "No Service called $Desc found on System!"}
    }### END restarting, starting or stopping services

    ### BEGIN starting services in reverse ordeer
    if($Reverse -and $choice1 -ne 2){
        Write-Host ""
        Write-Host -ForegroundColor Yellow "starting services in reverse order..."
        foreach($Service in $services_reverse){
            $Svc = $Service.SvcName
            $Desc = $Service.Description
            if(Get-Service -name $Svc){
                $RunSec = 0
                $SvcState = Get-Service -Name $svc | Select-Object Status -ExpandProperty Status
                if($SvcState -eq "running"){ 
                    Write-Host -ForegroundColor green ("$Desc already running...") 
                    if($Logging){ write_log ($Desc + " already running") }}
                else{
                    do{
                        start-service -Name $Svc
                        Start-Sleep -Seconds 1
                        $RunSec = $RunSec +1
                        $SvcState = Get-Service -Name $svc | Select-Object Status -ExpandProperty Status
                    }
                    until($SvcState -eq "running" -and $RunSec -lt 30)
                    if($SvcState -eq "running"){ 
                        Write-Host -ForegroundColor green ("- $Desc") 
                        if($Logging){ write_log ($Desc + " running") }}
                    else{
                        $Errors = $Errors +1
                        Write-Host -ForegroundColor Red ("- error starting $Desc!")
                        if($Logging){ write_log ("Error starting " + $Desc) }
                    }
                }
            }
            else{Write-host -ForegroundColor DarkRed "No Service called $Desc found on System!"}
        }
    }### END starting services in reverse order

    ### BEGIN result of service operation
    write-host ""
    if($Errors -eq 0){
        if($choice1 -eq 1){$Result = "running again"}
        elseif($choice1 -eq 2){$Result = "stopped"}
        else{$Result = "running"}
        Write-Host -ForegroundColor yellow ("all services are $result, window will close in 10 seconds!")
        Start-Sleep -Seconds 10
    }else{
        Write-Host -ForegroundColor Red ("$Errors occured during (re)starting service, please raise a ticket naming failed services!")
        Write-Host ""
        Write-Host -ForegroundColor grey ("you can close this window now...")
    }
    ### END result of service operation
}### END of function Restart-Service-InOrder