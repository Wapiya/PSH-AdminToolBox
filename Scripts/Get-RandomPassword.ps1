<#
    .SYNOPSIS
    Get random password
    .DESCRIPTION
    create 10 random passwords based on the phrase [']PartnerSince][Month][Year]. Let usr choose password
    or restart randomizing. After user has chosen a password it get copied to clipboard and the script ends 
    .NOTES
    Author:  Steffen Dueppuis created 23.01.2020
    .EXAMPLE
    just execute the script
#>
 
### get 10 random passwords
$PWCube = @()
$l = 0
do{
    $l = $l +1
    $Password = (("PartnerSince" -split '' ) + ((get-date).day) + ((get-date).Month) + ((get-date).year) | Sort-Object {Get-Random}) -join ''
    $row = new-object PSObject -Property @{
        Nr = $l;
        Password = $Password
    }
    $PWCube += $row
}until($l -eq 10)

### BEGIN Call Menu
do{
    cls
    Write-Host -ForegroundColor Yellow ("Magic Password Cube")
    Write-Host ""
    foreach($i in $PWCube){
        Write-Host $i.Nr -NoNewline
        if($i.nr -lt 10){Write-Host "  " -NoNewline}else{Write-Host " " -NoNewline}
        Write-Host $i.Password
    }
    Write-Host ""
    Write-Host -ForegroundColor Green "Please enter a number from the list or hit 'r' to randomize again  " -NoNewline
    $input = Read-Host

    # choose number randomize again or exiting menu
    switch ($input){
        default {
            if($input -like "r"){
                # randomize passwords again
                cls
                $PWCube = @()
                $l = 0
                do{
                    $l = $l +1
                    $Password = (("PartnerSince" -split '' ) + ((get-date).day) + ((get-date).Month) + ((get-date).year) | Sort-Object {Get-Random}) -join ''
                    $row = new-object PSObject -Property @{
                        Nr = $l;
                        Password = $Password
                    }
                    $PWCube += $row
                }until($l -eq 10)
            }
            else{
                # choose password and copy to clipboard
                if($PWCube.Nr -like $input){
                    Set-Clipboard ($PWCube[($input -1)].Password)
                    Write-Host ("your chosen password ") -NoNewline
                    Write-Host -ForegroundColor Yellow ($PWCube[($input -1)].Password) -NoNewline
                    Write-Host (" is copied to the clipboard")
                    sleep 3
                }
                else{
                    write-Host -ForegroundColor Yellow ("are you kidding me? $input wasn't listed....")
                    sleep 3
                }
                Write-Host ""
                exit}
        }
    }
} until ($input -match $l)