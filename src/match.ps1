<#
.DESCRIPTION
This is script is used by hubot's internal working process.
It is used to find which is the most appropriate powershell script to call.
The scripts "MUST" have a keywords function.
#>
Param (
    $words, $extensions
)
#create two hashsets to contain the files matched from any nouns and from any verb.
$FilesMatchedfromNouns = [System.Collections.Generic.HashSet[string]]::new()
$FilesMatchedfromVerbs = [System.Collections.Generic.HashSet[string]]::new()

for ($i = 0; $i -lt $words.length; $i++) {
  $word = $words[$i]
  #If the word is a noun
  if ($extensions.nounTable.ContainsKey($word)) {
    if ($FilesMatchedfromNouns.Count -eq 0) {
      #Initialise a new hashset
      ([System.Collections.Generic.HashSet[string]] $FilesMatchedfromNouns = $extensions.nounTable.$word.Keys)  > $null
    }
    else {
      ([System.Collections.Generic.HashSet[string]] $temp = $extensions.nounTable.$word.Keys) > $null
      $FilesMatchedfromNouns.IntersectWith($temp)
    }
  }
  #If the word is a verb
  if ($extensions.verbTable.ContainsKey($word)) {
    if ($FilesMatchedfromVerbs.Count -eq 0) {
      #Initialise a new hashset
      ([System.Collections.Generic.HashSet[string]] $FilesMatchedfromVerbs = $extensions.verbTable.$word.Keys)  > $null
    }
    else {
      ([System.Collections.Generic.HashSet[string]] $temp = $extensions.verbTable.$word.Keys) > $null
      $FilesMatchedfromVerbs.IntersectWith($temp)
    }
  }
}
if (($FilesMatchedfromVerbs.Count -eq 0) -OR ($FilesMatchedfromNouns.Count -eq 0)) {
  return 'I am sorry, I could not understand what you meant by that, please try again.'
}
else {
  $FilesMatchedfromVerbs.IntersectWith($FilesMatchedfromNouns)
  $filesMatched = New-Object System.Collections.ArrayList
  foreach($file in $FilesMatchedfromVerbs) {
    $filesMatched.Add($file) > $null
  }
  if ($filesMatched.Count -eq 0) {
    return 'I am sorry, I could not understand what you meant by that, please try again.'
  }
  return $filesMatched
}