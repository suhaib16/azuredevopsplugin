# Description:
#   This script is used to save, show and delete channel specific configurations/settings.


update = require(__dirname + "\\updateBrainWithParamString.coffee")
module.exports = (robot) ->
  robot.respond /set config (.*)$/i, (res) ->
    param = res.match[1]
    channelId = res.message.rawMessage.channel
    update.updateJSON param, channelId, robot
    # If the incoming message was inside a thread, responding normally will continue the thread
    if not res.message.thread_ts?
      # The incoming message was not inside a thread, so lets respond by creating a new thread
      res.message.thread_ts = res.message.rawMessage.ts
    res.reply ":heavy_check_mark: Configuration saved."

  robot.respond /delete config$/i, (res) ->
    channelId = res.message.rawMessage.channel
    # If the incoming message was inside a thread, responding normally will continue the thread
    if not res.message.thread_ts?
      # The incoming message was not inside a thread, so lets respond by creating a new thread
      res.message.thread_ts = res.message.rawMessage.ts
    #read the configurations (settings) file
    delete robot.brain.data._private[channelId]
    res.reply ":heavy_check_mark: Channel configurations deleted."

  robot.respond /get config$/i, (res) ->
    channelId = res.message.rawMessage.channel
    # If the incoming message was inside a thread, responding normally will continue the thread
    if not res.message.thread_ts?
      # The incoming message was not inside a thread, so lets respond by creating a new thread
      res.message.thread_ts = res.message.rawMessage.ts
    #read the configurations (settings) file
    channelContextJSONObj = robot.brain.get(channelId)
    #convert channelContext from an object to a JSON formatted string
    channelContextJSONStr = JSON.stringify(channelContextJSONObj, null, 2)
    #Preformat to align the string properly
    channelContextJSONStr = '```' + "\n" + channelContextJSONStr + "\n" + '```'
    res.reply ":heavy_check_mark:\n#{channelContextJSONStr}"