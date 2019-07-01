# Description:
#   This script is used by hubot to save, get/show and delete user specific settings.
#   It shows the saved settings in JSON format.


update = require(__dirname + "\\updateBrainWithParamString.coffee")
module.exports = (robot) ->
  robot.respond /my defaults (.*)$/i, (res) ->
    #extract the string in which key value pairs are present as "key1 = value1 key2 = value2"
    param = res.match[1]
    ###
    Combine teamId and userId to create a unique ID for the user in slack
    ###
    uniqueUserID = res.message.rawMessage.team + "-" + res.message.user.id
    update.updateJSON param, uniqueUserID, robot
    # If the incoming message was inside a thread, responding normally will continue the thread
    if not res.message.thread_ts?
      # The incoming message was not inside a thread, so lets respond by creating a new thread
      res.message.thread_ts = res.message.rawMessage.ts
    res.reply ":heavy_check_mark: User defaults saved."
  
  robot.respond /delete my defaults$/i, (res) ->
    ###
    Combine teamId and userId to create a unique ID for the user in slack
    ###
    uniqueUserID = res.message.rawMessage.team + "-" + res.message.user.id
    delete robot.brain.data._private[uniqueUserID]
    # If the incoming message was inside a thread, responding normally will continue the thread
    if not res.message.thread_ts?
      # The incoming message was not inside a thread, so lets respond by creating a new thread
      res.message.thread_ts = res.message.rawMessage.ts
    res.reply ":heavy_check_mark: User defaults deleted."
  
  robot.respond /get my defaults$/i, (res) ->
    ###
    Combine teamId and userId to create a unique ID for the user in slack
    ###
    uniqueUserID = res.message.rawMessage.team + "-" + res.message.user.id
    # If the incoming message was inside a thread, responding normally will continue the thread
    if not res.message.thread_ts?
      # The incoming message was not inside a thread, so lets respond by creating a new thread
      res.message.thread_ts = res.message.rawMessage.ts
    #Get a JSON string from the saved JSON object in the Hubot's brain.
    userSettingsJSONStr = "```\n" + JSON.stringify(robot.brain.data._private[uniqueUserID], null, 2) + "\n```"
    res.reply ":heavy_check_mark: Your default settings are shown below.\n#{userSettingsJSONStr}"
    
