<#
.DESCRIPTION
This is script is used to get the list of all the repositories, present in some project and organisation.
.EXAMPLE
@azuredevopsbot give a list of repos
#>
function keywords {
    $keys = @{}
    [string[]]$keys.verbs = @("get", "fetch", "list")
    [string[]]$keys.nouns = @("repos", "repo", "repositories", "repository")
    return $keys
}
function help {
    $result = @{}
    $result.success = $false
    $result.output = 
    #When the help commands ends, put a back tick '`'
    'give a list of repos` - To get the list of all the repositories.'
    $result.success = $true
    return $result | ConvertTo-Json
}

function repolist
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
    
    #if channelContextJSONStr is not passed it must be null
    # convert channelContextJSONStr to a JSON object
    $channelContextJSONObj = $channelContextJSONStr | ConvertFrom-Json
    # convert userContextJSONStr to a JSON object
    $userContextJSONObj = $userContextJSONStr | ConvertFrom-Json
    if ($null -eq $project) {
        $project = $channelContextJSONObj.project
    }
    if ($null -eq $org) {
        $org = $channelContextJSONObj.org
    }
    $list = az repos list --project $project --org $org | ConvertFrom-Json
    $names = $list.name
    $ids = $list.id
    $ans = ""
    For ($i=0; $i -lt $names.Length; $i++) {
        $ans = $ans + $names[$i] + "`n" + $ids[$i] + "`n"
        }
    $result.output = "Format is:`nRepository's name`nID of the repository`n" + '```' + "`n" + "$($ans)" + '```'
    #An example of how to return thread context. Values are allowed to contain spaces but keys are not.
    #If you do not want to return thread context just return an empty string.
    $result.threadContextStr = "key1 = value1 key2 = value2 key3 = value3"
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