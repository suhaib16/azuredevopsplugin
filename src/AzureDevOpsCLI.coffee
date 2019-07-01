# Description:
#   This is the main script that Hubot uses to process all the commands.
#   1.) Finds the most appropriate powershell script to call, and calls it.
#   2.) Handles if the message is a primary/parent message or reply message accordingly.

edge = require("edge-js")
update = require(__dirname + "\\updateBrainWithParamString.coffee")

getMatchingScript = edge.func('ps', ->###
  #call match.ps1 from here to get the most appropriate powershell script
  .\node_modules\hubot-azurebot\src\match.ps1 $inputFromJS.words $inputFromJS.extensions
###
)
# Build the PowerShell that will execute
executePowerShell = edge.func('ps', ->###
  $dotSourceScript = ". .\node_modules\hubot-azurebot\src\$($inputFromJS.script).ps1"
  iex $dotSourceScript
  if ($inputFromJS.help -eq $true) {iex "help"}
  #the call is from a primary (parent) message
  elseif ($inputFromJS.isParentMsg -eq $true) {
    if ($inputFromJS.paramExist -eq $true) {
        $parameterTable = $($inputFromJS.params) | ConvertFrom-StringData
        $paramString = ""
        #generate the parameter string in the following manner: -param1 value1 -param2 value2
        foreach($key in $parameterTable.Keys) {
          $paramString = $paramString + "-" + "$($key) " + '$($parameterTable[' + '"' + "$($key)" + '"' + ']) '
        }
        iex ($($inputFromJS.script) + " " + $paramString + " -userContextJSONStr " + '$inputFromJS.userContextJSONStr' + " -channelContextJSONStr " + '$inputFromJS.channelContextJSONStr')
    }
    #this will get executed when the user has not provided any parameters
    else {
      iex ("$($inputFromJS.script)" + " -userContextJSONStr " + '$inputFromJS.userContextJSONStr' + " -channelContextJSONStr " + '$inputFromJS.channelContextJSONStr')
    }
  }
  #the call is from a reply message
  else {
    #call reply function
    iex ("reply" + " -userContextJSONStr " + '$inputFromJS.userContextJSONStr' + " -channelContextJSONStr " + '$inputFromJS.channelContextJSONStr' + " -threadContextJSONStr " + '$inputFromJS.threadContextJSONStr' + " -command " + '$inputFromJS.command')
  }
###
)
formatParamString = (parameters) ->
  ###
  This function takes a string as "param1 =val ue1 param2= value2 param3 = value3"
  to "param1=val ue1\nparam2=value2\nparam3=value3"
  '\n' is the new line character in CoffeeScript
  ###
  ans = ''
  eqFound = false
  mark2 = parameters.length
  i = parameters.length - 1
  while i >= 0
    if parameters.charAt(i) == '='
      eqFound = true
    else if parameters.charAt(i) == ' '
      if eqFound
        tempStr = '\n' + parameters.slice(i + 1, mark2)
        mark2 = i
        ans = tempStr + ans
        eqFound = false
    i--
  tempStr = parameters.slice(0, mark2)
  ans = tempStr + ans
  return ans

wordsFromMsg = (msg) ->
  #This function will give an array of words from a sentence
  #Remove all the punctuations except '-', because we don't need punctuations to match words to find the PS script
  msg = msg.replace(/[.,\/#!$%\^&\*;:{}=\_`~()]/g,"").replace(/\s+/g, " ")
  #get all the individual words in an array
  words = msg.split " "
  return words


module.exports = (robot) ->
  # Capture the user message using a regex capture
  robot.respond /(.*)$/i, (res) ->
    if (res.match[1]) is "help"
      return
    if (res.match[1]).startsWith "show memory"
      return
    if (res.match[1]).startsWith "set config"
      return
    if (res.match[1]).startsWith "get config"
      return
    if (res.match[1]).startsWith "delete config"
      return
    if (res.match[1]).startsWith "my defaults"
      return
    if (res.match[1]).startsWith "get my defaults"
      return
    if (res.match[1]).startsWith "delete my defaults"
      return
    if (res.match[1]).startsWith "az"
      return
    isParent = false
    channelId = res.message.rawMessage.channel
    ###
    Combine teamId and userId to create a unique ID for the user in slack
    ###
    uniqueUserID = res.message.rawMessage.team + "-" + res.message.user.id
    # If the incoming message was inside a thread, responding normally will continue the thread
    if not res.message.thread_ts?
      ###
      The incoming message was not inside a thread, so lets respond by creating a new thread.
      This can happen whenever someone creates (posts) a parent/primary message, which may have zero or more replies.
      ###
      isParent = true
      #To send a reply message make thread_ts = ts
      res.message.thread_ts = res.message.rawMessage.ts
    # res.reply "Working on it, wait a minute."
    #generate a thread unique ID
    threadUniqueId = channelId + "-" + res.message.thread_ts
    
    #extract the string that follows "@<bot's name on slack>"
    #this entire string is the command that comprises of a message and parameters (may or may not be present)
    command = res.match[1]
    #Convert multiple spaces and tabs into a single space, and eliminate starting and ending spaces.
    command = command.replace(/\s+/g, " ").replace(/\s*[=]\s*/g, '=').replace(/^\s*/g, '').replace(/\s*$/g, '')
    #read the channel configurations (settings) from the brain
    channelContextJSONObj = robot.brain.get(channelId)
    #convert channelContext from an object to a JSON formatted string
    channelContextJSONStr = JSON.stringify(channelContextJSONObj, null, 2)
    
    #read the user configurations (settings) from the brain
    userContextJSONObj = robot.brain.get(uniqueUserID)
    #convert userContext from an object to a JSON formatted string
    userContextJSONStr = JSON.stringify(userContextJSONObj, null, 2)

    paramExist = false
    #location of the first equal '='
    firstEq = command.indexOf "="
    
    if firstEq == -1
      #the user has not provided the parameters so the entire command is the message now
      msg = command
      words = wordsFromMsg msg
    else
      #the user has provided the parameters
      paramExist = true
      temp = command.slice 0, firstEq
      lastSpaceIndex = temp.lastIndexOf " "
      msg = temp.slice 0, lastSpaceIndex

      words = wordsFromMsg msg
      ###
      Following part of the else code converts the format of the 'parameters' string
      from " param1 =value1 param2= value2 param3 = value3"
      to "param1=value1\nparam2=value2\nparam3=value3"
      '\n' is the new line character in CoffeeScript
      ###
      parameters = command.slice lastSpaceIndex + 1
      parameters = formatParamString parameters

    help = false
    #check if the user is asking for help
    for w in words when w is "help" || w is "how" || w is "assist" || w is "assistance" || w is "aid" 
      help = true
    if isParent
    #this must be a parent message
      psObjectFindScript = {
        words: words
        extensions: robot.brain.data._private.extensions
      }
      script = "NULL"
      getMatchingScript psObjectFindScript, (error, result) ->
        ###
        if result is a string this means that whether we found the appropriate script or the bot doesn't understand the command
        if the result is an array, the bot found a few matching scripts now we should ask the user which one to call
        ###
        if result.length == 1
          if (result[0].substr -3) is "ps1"
            script = result[0]
            # res.reply "Calling #{script}"
          else
            res.reply result[0]
            script = "NULL"
        else
          # "Ask the user which script would he like to call?"
          files = "Multiple files matched, please try again.\n"
          for file, index in result
            files = files + index + ".) " + file + "\n"
          res.reply files
          script = "NULL"
        
        #Script should contain the name of the powershell script to call
        script = script.slice 0, -4
        psObjectParentMsg = {
          script: script
          help: help
        }
        if not help
          psObjectParentMsg.paramExist = paramExist
          psObjectParentMsg.channelContextJSONStr = channelContextJSONStr
          psObjectParentMsg.userContextJSONStr = userContextJSONStr
          psObjectParentMsg.isParentMsg = true
          if paramExist
            psObjectParentMsg.params = parameters
        
        # res.reply script
        # res.reply help
        # res.reply parameters
        if script isnt ""
          executePowerShell psObjectParentMsg, (error, result)->
            if error
              res.reply ":fire: An error was thrown."
              res.reply error
            else
              result = JSON.parse result[0]
              #Check if the script ran successfully or not
              if result.success is true
                #Get the brain object if it exists if not initialise it
                if (robot.brain.get(threadUniqueId)) is null 
                  threadContextInBrain = {}
                else
                  threadContextInBrain = robot.brain.get(threadUniqueId)
                #add the name of the script that is called by this parent message
                threadContextInBrain["script"] = (script.concat ".ps1")

                #write changes to the brain
                robot.brain.set threadUniqueId, threadContextInBrain
                
                #Write thread level context from the parent message in brain file if main function was called.
                if help
                  res.reply '`' + "#{robot.name} " + result.output
                else
                  res.reply ":heavy_check_mark: #{result.output}"
                  if result.threadContextStr isnt ""
                    update.updateJSON result.threadContextStr, threadUniqueId, robot
              else
                res.reply ":warning: The script did not run successfully."
    else
      #this must be a reply message
      #get the thread context as an object from the brain
      threadContextJSONObj = robot.brain.get(threadUniqueId)
      #convert threadContext from an object to a JSON formatted string
      threadContextJSONStr = JSON.stringify(threadContextJSONObj, null, 2)
      #get the name of the script to be called
      script = threadContextJSONObj["script"]
      #eliminate '.ps1' from the string
      script = script.slice 0, -4
      psObjectReplyMsg = {
        script: script
        help: help
      }
      
      if not help
        psObjectReplyMsg.userContextJSONStr = userContextJSONStr
        psObjectReplyMsg.channelContextJSONStr = channelContextJSONStr
        psObjectReplyMsg.threadContextJSONStr = threadContextJSONStr
        psObjectReplyMsg.command = command
        psObjectReplyMsg.isParentMsg = false
      executePowerShell psObjectReplyMsg, (error, result)->
        if error
          res.reply ":fire: An error was thrown."
          res.reply error
        else
          result = JSON.parse result[0]
          #Check if the script ran successfully or not
          if result.success is true
            if help
              res.reply '`' + "#{robot.name} " + result.output
            else
              res.reply ":heavy_check_mark: #{result.output}"
          else
            res.reply ":warning: The script did not run successfully."