<#
    .SYNOPSIS
    convert special localized characters to normalized characters
    .DESCRIPTION
    convert special localized characters to normalized characters
    .NOTES
    Author:  Steffen Dueppuis created 26.07.2017
    21.10.2020: enhanced with more chars, thanks to https://powershell24.de/2017/04/22/rewrite-specialcharacters/
    
	IMPORTANT INFO:
	Don´t edit in normal editor, file has to be stored with Encoding in 'ANSI'
	
    .EXAMPLE
    Convert-Umlaut Äpfel
	will be transformed to Aepfel
#>
### BEGIN of Function

function Convert-Umlaut($inputstring){

	$Sonderzeichen = @(
		'Á',
		'À',
		'Â',
		'Ä',
		'É',
		'È',
		'Ê',
		'Ë',
		'Í',
		'Ì',
		'Î',
		'Ï',
		'Ó',
		'Ò',
		'Ô',
		'Ö',
		'Ú',
		'Ù',
		'Û',
		'Ü',
		'á',
		'à',
		'â',
		'ä',
		'é',
		'è',
		'ê',
		'ë',
		'í',
		'ì',
		'î',
		'ï',
		'ó',
		'ò',
		'ô',
		'ö',
		'ú',
		'ù',
		'û',
		'ü',
		'ß'#,
	#	'-',
	#	' '
	)

	$Umschrieb = @(
		'A',
		'A',
		'A',
		'Ae',
		'E',
		'E',
		'E',
		'E',
		'I',
		'I',
		'I',
		'I',
		'O',
		'O',
		'O',
		'Oe',
		'U',
		'U',
		'U',
		'Ue',
		'a',
		'a',
		'a',
		'ae',
		'e',
		'e',
		'e',
		'e',
		'i',
		'i',
		'i',
		'i',
		'o',
		'o',
		'o',
		'oe',
		'u',
		'u',
		'u',
		'ue',
		'ss'#,
		#'',
		#''
	)


	for ($i = 0; $i -lt $Sonderzeichen.Length; $i++){
		$inputstring = $inputstring.replace($Sonderzeichen[$i],$Umschrieb[$i])
	} 

	return $inputstring

}
