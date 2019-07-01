###
Description:
This script is used to update an attribute in the Hubot's brain.
It accepts a parameter string in this format: "key1 = value1 key2 = value2 key3 = value3"
Keys aren't allowed to contain spaces but values are allowed to contain spaces.
Commands:
This script is for internal use only.
###
module.exports = {}
updateJSON = (param, attributeName, robot) ->
  ###
  Make an object and put all 'key: value' pairs in it 
  ###
  obj = new Object
  #eliminate all the surrounding spaces of the equal sign '='
  #Example: convert " prop1= value1 prop2 = va lu e2 prop3 = value4 "
  #to " prop1=value1 prop2=va lu e2 prop3=value4 "
  param = param.replace(/\s*[=]\s*/g, '=')
  #eliminate all the starting spaces
  #convert " prop1=value1 prop2=va lu e2 prop3=value4 "
  #to "prop1=value1 prop2=va lu e2 prop3=value4 "
  param = param.replace(/^\s*/g, '')
  #eliminate all the trailing spaces
  #convert "prop1=value1 prop2=va lu e2 prop3=value4 "
  #to "prop1=value1 prop2=va lu e2 prop3=value4"
  param = param.replace(/\s*$/g, '')
  key = undefined
  value = undefined
  i = param.length - 1
  eqFound = false
  eqMark = undefined
  markEnd = param.length
  i = param.length - 1
  while i >= 0
    if param.charAt(i) == '='
      eqFound = true
      eqMark = i
    else if param.charAt(i) == ' '
      if eqFound
        key = param.slice(i + 1, eqMark)
        value = param.slice(eqMark + 1, markEnd)
        obj[key] = value
        markEnd = i
        eqFound = false
    i--
  key = param.slice(0, eqMark)
  value = param.slice(eqMark + 1, markEnd)
  obj[key] = value

  #Get the brain object if it exists if not initialise it
  if (robot.brain.get(attributeName)) is null
    robotBrainObj = {}
  else
    robotBrainObj = robot.brain.get(attributeName)

  #Update the values
  for key,value of obj
    robotBrainObj[key] = value
  ###
  To overwrite or to put a new property
  jsonObj.NewPropertyName = "Value of New Property"
  To create a new empty property
  jsonObj.NewPropertyName = {}
  To access a property/attribute
  jsonObj[Property1][Property2][Property3]
  jsonObj.Property1.Property2.Property3
  ###

  #Write changes to the brain
  robot.brain.set attributeName, robotBrainObj

module.exports.updateJSON = updateJSON