# Description:
#   This is the main script that Hubot uses to invoke direct CLI commands.


edge = require("edge-js")
executeAzureCli = edge.func('ps', ->###
  .\node_modules\hubot-azurebot\src\azcli.ps1 $inputFromJS.command
###
)
module.exports = (robot) ->
  robot.respond /az (.*)$/i, (res) ->
    command = 'az '.concat res.match[1]
    psObject = {
      command: command
    }
    executeAzureCli psObject, (error, result)->
      if error
        res.reply ":fire: An error was thrown."
        res.reply error
      else
        result = result.join('\n')
        ###
        We are adding triple back-ticks at both the ends of the result to make it performatted.
        We should performat our result because in Slack each character does not have the same width, which may make our output misalign.
        Preformatting makes sure that every character has the same width.
        ###
        result = "```\n" + result + "\n```"
        res.reply "#{result}"