<#
    .SYNOPSIS
    convert special localized characters to normalized characters
    .DESCRIPTION
    convert special localized characters to normalized characters, keep dashes, spaces - signs not included in library
    .NOTES
    Author:  Steffen Dueppuis created 21.10.2020
    Source: https://www.reddit.com/r/PowerShell/comments/a5hfcw/three_ways_in_powershell_to_replace_diacritics_%C3%AB/
    Info: https://de.wikipedia.org/wiki/Diakritisches_Zeichen
    29.11.2020: added switch 'clean'
    .PARAMETER clean
    wipe all characters exept a-z,A-z,0-9
    .EXAMPLE
    Convert-UmlautCyrillic Boręńszó-Czajkówska
    will be transformed to Borejszo-Czajkowska
    .EXAMPLE
    Convert-UmlautCyrillic Boręńszó-Czajkówska -clean
    will be transformed to BorejszoCzajkowska
#>
### BEGIN of Function


function Convert-UmlautCyrillic{
    Param(
        [String]$inputString,
        [Switch]$clean
    )
    #replace diacritics
    $sb = [Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($inputString))

    #remove spaces and anything the above function may have missed, if 'clean' is specified
    if($clean){ return($sb -replace '[^a-zA-Z0-9]', '') }else{ return($sb) }
}