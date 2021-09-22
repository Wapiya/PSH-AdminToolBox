<#
    .SYNOPSIS
    Convert Special characters to underscores and 'non' spaces
    .DESCRIPTION
    Convert Special characters in a string to underscores, e.g. '(' will be convertedt to '_' additional all
    spaces, excalamation and question marks get removed
    .NOTES
    Author:  Steffen Dueppuis created 121.11.2018
    .EXAMPLE
    Convert-SpecialChars -String "Start!$%&/()=?{[]}#<>End" will result a long line :-) like 'Start_______________End'
    .EXAMPLE
    Convert-SpecialChars "This Is: a (very) Special String!" will result in 'ThisIs_a_very_SpecialString'
    #>
function Convert-SpecialChars {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True,
            Position = 0)]
        [string]
        $String
    )
    process {
        $newString = $String
        $ReplaceMap = New-Object -TypeName System.Collections.Hashtable
        $ReplaceMap[':'] = '_'
        $ReplaceMap['!'] = ''
        $ReplaceMap[','] = '_'
        $ReplaceMap['$'] = '_'
        $ReplaceMap['%'] = '_'
        $ReplaceMap['&'] = '_'
        $ReplaceMap['/'] = '_'
        $ReplaceMap['('] = '_'
        $ReplaceMap[')'] = '_'
        $ReplaceMap['='] = '_'
        $ReplaceMap['?'] = ''
        $ReplaceMap['*'] = '_'
        $ReplaceMap['#'] = '_'
        $ReplaceMap['+'] = '_'
        $ReplaceMap['>'] = '_'
        $ReplaceMap['<'] = '_'
        $ReplaceMap['|'] = '_'
        $ReplaceMap['['] = '_'
        $ReplaceMap[']'] = '_'
        $ReplaceMap['{'] = '_'
        $ReplaceMap['}'] = '_'
        $ReplaceMap['.'] = ''
        $ReplaceMap[' '] = ''
        $ReplaceMap.Keys | ForEach-Object {$newString = $newString.Replace($_, $ReplaceMap[$_])}
        $newString
    }

}
