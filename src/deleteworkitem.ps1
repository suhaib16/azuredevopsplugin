<#
.DESCRIPTION
This is script is used to delete a work-item in some project and organisation.
.EXAMPLE
@azuredevopsbot delete a work-item id = 212
#>
function keywords {
    $keys = @{}
    [string[]]$keys.verbs = @("delete", "remove")
    [string[]]$keys.nouns = @("work-item")
    return $keys
}
function help {
    $result = @{}
    $result.success = $false
    $result.output = 
    #When the help commands ends, put a back tick '`'
    'delete a work-item id = 212` - To delete a work-item.'
    $result.success = $true
    return $result | ConvertTo-Json
}

function deleteworkitem
{
    [CmdletBinding()]
    Param
    (
        $userContextJSONStr, $channelContextJSONStr, $project, $org, $id
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
    if ($null -eq $id) {
        $result.output = "One or more parameters were not passed."
    } else {
        #if channelContextJSONStr is not passed it must be null
        # convert channelContextJSONStr to a JSON object
        $channelContextJSONObj = $channelContextJSONStr | ConvertFrom-Json
        if ($null -eq $project) {
            $project = $channelContextJSONObj.project
        }
        if ($null -eq $org) {
            $org = $channelContextJSONObj.org
        }
        $dump = az boards work-item delete --id $id --project $project --org $org --yes --output none
        $result.output = "Work item has been deleted."
    }
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