<#
.DESCRIPTION
This is script is used to get the workItems (all the work items assigned to the user), and the pull requests to be reviewed.
Project and organisation name are taken from the channel settings, and email is taken form the user settings.
.EXAMPLE
@azuredevopsbot give my to-dos
#>
function keywords {
  $keys = @{}
  [string[]]$keys.verbs = @("get", "fetch", "workItems", "list")
  [string[]]$keys.nouns = @("to-do", "to-dos")
  return $keys
}
function help {
  $result = @{}
  $result.success = $false
  $result.output = 
  #When the help commands ends, put a back tick '`'
  'give my to-dos` - To get your to-dos (work-items assigned to you and pending pull requests).'
  $result.success = $true
  return $result | ConvertTo-Json
}

function to-dos
{
  [CmdletBinding()]
  Param
  (
      $userContextJSONStr, $channelContextJSONStr, $project, $org
  )
  <#
  Create an empty hash-table to send back to the bot.
  The user is supposed to fill this hash-table accordingly considering every scenario,
  such as whether script ran successfully or not, error handling etc.
  #>
  $result = @{}
  $result.success = $false
  # convert userContextJSONStr to a JSON object
  $userContextJSONObj = $userContextJSONStr | ConvertFrom-Json
  #if channelContextJSONStr is not passed it must be null
  # convert channelContextJSONStr to a JSON object
  $channelContextJSONObj = $channelContextJSONStr | ConvertFrom-Json

  if ($null -eq $project) {
      $project = $channelContextJSONObj.project
  }
  if ($null -eq $org) {
      $org = $channelContextJSONObj.org
  }
  $workItems = az boards query --wiql "select [System.Id], [System.Title] from workitems where [System.TeamProject] = '$project' and [System.AssignedTo] = '$($userContextJSONObj.email)' and ([System.State] = 'Active' OR [System.State] = 'Proposed' OR [System.State] = 'In Progress')" --org $org  -o table
  
  for($i = 0; $i -lt $workItems.length; $i++) {
    $str = $workItems[$i]
    if ($str.length -gt 55) {
      $workItems[$i] = $str.substring(0,52) + '...'
    } 
  }
  $workItems = $workItems -join "`n"
  $workItems = "`n" + '*Assigned work-items to you:*' + "`n" + '```' + "`n" + $workItems + "`n" + '```'

  $pullRequests = az repos pr list --reviewer "$($userContextJSONObj.email)" --org $org --project $project --query "[].{ID:codeReviewId, Title:title}" -o table
  for($i = 0; $i -lt $pullRequests.length; $i++) {
    $str = $pullRequests[$i]
    if ($str.length -gt 55) {
      $pullRequests[$i] = $str.substring(0,52) + '...'
    } 
  }
  $pullRequests = $pullRequests -join "`n"
  $pullRequests = '*Pull requests to be reviewed:*' + "`n" + '```' + "`n" + $pullRequests + "`n" + '```'
  $result.output = $workItems + "`n`n" + $pullRequests
  #If you do not want to return thread context just return an empty string.
  $result.threadContextStr = ""
  $result.success = $true
  return $result | ConvertTo-Json
}

function reply
{
  [CmdletBinding()]
  Param
  (
      $userContextJSONStr, $channelContextJSONStr, $threadContextJSONStr, $command
  )
  #if one or more of channelContextJSONStr, threadContextJONStr, or command are not passed they must be null
  # convert channelContextJSONStr to a JSON object
  $channelContextJSONObj = $channelContextJSONStr | ConvertFrom-Json
  # convert threadContextJSONStr to a JSON object
  $threadContextJSONObj = $threadContextJSONStr | ConvertFrom-Json
  # convert userContextJSONStr to a JSON object
  $userContextJSONObj = $userContextJSONStr | ConvertFrom-Json
  $result = @{}
  $result.success = $false
  <#
  Enter your code here
  #>
  $result.output = "Back from reply message."
  $result.success = $true
  return $result | ConvertTo-Json
}