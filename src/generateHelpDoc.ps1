<#
.DESCRIPTION
This is script is used by Hubot's internal working process.
It is used to the help documentation for all the PowerShell scripts.
Each script "MUST" have a 'help' function, which returns the help for that script.
#>
Param ($botName)

#Initialize a variable to generate the final documentation for the extensions.
$allHelpDoc = ""
#Make a variable to keep a counter of the files.
$count = 0
$directoryName = $pwd."Path"
#Get the list of all the powershell scripts in a variable.
$listOfFiles = Invoke-Expression "cd $directoryName\node_modules\hubot-azurebot\src; ls *.ps1 -Name"
for($i = 0; $i -lt $listOfFiles.length; $i++) {
    $fileName = $listOfFiles[$i]
    if ($fileName -eq "match.ps1" -OR $fileName -eq "azcli.ps1" -OR $fileName -eq "generateHelpDoc.ps1" -OR $fileName -eq "loadAllextensions.ps1") {
        continue
    }
    $dotSource = ". $directoryName\node_modules\hubot-azurebot\src\$($fileName)"
    Invoke-Expression $dotSource
    
    $help = & "help"
    $help = $help | ConvertFrom-Json
    $count++
    $allHelpDoc = $allHelpDoc + $count + ".) " + '`' + "$botName " + $help.output + "`n"
}
$allHelpDoc = "A total of $count extensions found.`n" + $allHelpDoc
return $allHelpDoc