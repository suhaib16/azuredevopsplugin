<#
.DESCRIPTION
This script loads all the extensions present.
#>
Param
()
$directoryName = $pwd."Path"
$scriptsLoaded = @{}
$nounTable = @{}
$verbTable = @{}
$listOfFiles = Invoke-Expression "cd $directoryName\node_modules\hubot-azurebot\src; ls *.ps1 -Name"
for($i = 0; $i -lt $listOfFiles.length; $i++) {
	$fileName = $listOfFiles[$i]
	if ($fileName -eq "match.ps1" -OR $fileName -eq "azcli.ps1" -OR $fileName -eq "generateHelpDoc.ps1" -OR $fileName -eq "loadAllextensions.ps1") {
			continue
	}
	$scriptsLoaded.Add($fileName, $true) > $null
	$dotSource = ". $directoryName\node_modules\hubot-azurebot\src\$($fileName)"
	Invoke-Expression $dotSource
	$keys = & "keywords"
	for($j = 0; $j -lt $keys.Verbs.length; $j++) {
		$verbTable.Add(($keys.Verbs[$j]), @{}) > $null
		($verbTable.($keys.Verbs[$j])).Add($fileName, $true) > $null
	}
	for($j = 0; $j -lt $keys.Nouns.length; $j++) {
		$nounTable.Add(($keys.Nouns[$j]), @{}) > $null
		($nounTable.($keys.Nouns[$j])).Add($fileName, $true) > $null
	}
}

$result = @{}
$result.scriptsLoaded = $scriptsLoaded
$result.nounTable = $nounTable
$result.verbTable = $verbTable
return $result
