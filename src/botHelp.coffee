edge = require("edge-js")
getHelpDocumentation = edge.func('ps', ->###
  #call generateHelpDoc.ps1 from here to get the help documentation for all the PowerShell scripts
  .\node_modules\hubot-azurebot\src\generateHelpDoc.ps1 $inputFromJS.botName
###
)

module.exports = (robot) ->
  robot.respond /help$/i, (res) ->
    #Make a string to help the user on how to get the help documentation.
    botHelp = "`#{robot.name} help` - To get the help documentation."
    #Make a string to help the user on how to invoke Azure CLI commands directly.
    directCLIHelp = "`#{robot.name} az repos create --name newRepo --project AzureDevOps --org https://dev.azure.com/mseng` - To invoke Azure CLI commands directly from slack."
    #Make a string to help the user on how to manage channel settings/configurations.
    channelConfigHelp =
    """
    `#{robot.name} set config project = AzureDevOps org = https://dev.azure.com/mseng` - To save channel specific settings.
    `#{robot.name} get config` - To get/show a specific channel's settings.
    """
    #Make a string to help the user on how to manage user settings/configurations.
    userConfigHelp =
    """
    `#{robot.name} my defaults email = t-sushak@microsoft.com` - To save user specific settings.
    `#{robot.name} get my defaults` - To get/show the saved user specific settings.
    """
    
    psObject = {botName: robot.name}
    #Give the help documentaion for the installed extensions/skills.
    getHelpDocumentation psObject, (error, result) ->
      finalHelpDoc = 
      """
      >*Help for the basic functionality:*
      #{botHelp}
      #{directCLIHelp}
      >*Help for the installed extensions:*
      #{result[0]}
      >*Help to mantain settings/cofigurations:*
      #{channelConfigHelp}
      #{userConfigHelp}
      """
      res.send finalHelpDoc