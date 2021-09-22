<#
    .SYNOPSIS
    Convert Distinguishedname of an user, whipe uneeded data like domain itself
    .DESCRIPTION
    convert a Distinguished Name to easyly get the OU in which the user is located, in addition the OU one level above
    which - in most cases is a 'location' - or building, something bigger at last :-) - could be converted
    .NOTES
    Author:  Steffen Dueppuis created 01.09.2021
    Command need Active Directory Module or must be executed on a domain controller
    .EXAMPLE
    Get-ADUser MYUSER | select distinguishedname -ExpandProperty distinguishedname | Convert-DN -RootOU "CompanyUsers" -second
    will return the name of the second OU beneath the specified RootOU 'CompanyUsers' - so if your structure is 
    like 'CompanyUsers>Location-One>Users it will return 'Location-One'
    .EXAMPLE
    Get-ADUser MYUSER | select distinguishedname -ExpandProperty distinguishedname | Convert-DN
    will return a comma separated string with username and all subfolders excluding domain info. In the example above it will 
    result in myuser,Users,location-One,CompanyUsers
    .EXAMPLE
    Get-ADUser MYUSER | select distinguishedname -ExpandProperty distinguishedname | Convert-DN -wipe ",OU=CompanyUsers"
    same like above but also the named one will be removed from the result so it will be
    myuser,Users,location-One
    #>
function Convert-DN {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True,Position = 0,ValueFromPipeline=$true)]
            [string]$String,
        [Parameter()]
            [string]$Wipe,
        [Parameter()]
            [switch]$first,
        [Parameter()]
            [switch]$second,
        [Parameter()]
            [switch]$third
    )
    
    process{
        # convert string
        $Domain = "," + (get-addomain).DistinguishedName
        $newString = $String
        $ReplaceMap = New-Object -TypeName System.Collections.Hashtable
        $ReplaceMap[$Domain] = ''
        $ReplaceMap['CN='] = ''
        $ReplaceMap['OU='] = ''
        if($Wipe){ $ReplaceMap[$Wipe] = '' }
        $ReplaceMap.Keys | ForEach-Object {$newString = $newString -Replace($_, $ReplaceMap[$_])}
        # create result based on switches
        if($third){ $newString.split(",")[3] }
        elseif($second){ $newString.split(",")[2] }
        elseif($first){ $newString.split(",")[1] }
        else{ $newString }  
    }
}