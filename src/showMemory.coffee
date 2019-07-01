# Description:
#   This is the script that is used to show the entire memory.
module.exports = (robot) ->
  robot.respond /show memory$/i, (res) ->
    printThis = "```\n" + JSON.stringify(robot.brain.data._private, null, 2) + "\n```"
    res.reply ":heavy_check_mark:\n#{printThis}"