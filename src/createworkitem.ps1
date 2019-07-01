<#
.DESCRIPTION
This is script is used to create a work-item in some project and organisation.
.EXAMPLE
@azuredevopsbot create a work-item title = myFirstWorkItem type = Issue
#>

function keywords {
    $keys = @{}
    [string[]]$keys.verbs = @("create", "develop", "make", "initialise", "initialize")
    [string[]]$keys.nouns = @("work-item")
    return $keys
}
function help {
    $result = @{}
    $result.success = $false
    $result.output = 
    #When the help commands ends, put a back tick '`'
    'create a work-item title = myFirstWorkItem type = Issue` - To create a work-item.'
    $result.success = $true
    return $result | ConvertTo-Json
}

function createworkitem
{
    [CmdletBinding()]
    Param
    (
        $userContextJSONStr, $channelContextJSONStr, $project, $org, $title, $type
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
    if ($null -eq $title -OR $null -eq $type) {
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
        $id = (az boards work-item create --title $title --type $type --project $project --org $org | ConvertFrom-Json).id
        
        $result.output = "Work item created.
    Id: $($id)
    $($org)/$($project)/_workitems/edit/$($id)/"
    }
    #An example of how to return thread context. Values are allowed to contain spaces but keys are not.
    #If you do not want to return thread context just return an empty string.
    $result.threadContextStr = "id = $($id)"
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
    $comment = $userContextJSONObj.email + ': ' + $command
    az boards work-item update --id $($threadContextJSONObj.id) --discussion $comment --output none
    $result.output = "Discussion updated."
    $result.success = $true
    return $result | ConvertTo-Json
}