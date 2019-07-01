# Description:
#   This is the script that Hubot runs at the time of start, it loads all other scripts and loads all the extensions presesnt.
fs = require 'fs'
path = require 'path'
edge = require("edge-js")


loadAllextensions = edge.func('ps', ->###
  iex ".\node_modules\hubot-azurebot\src\loadAllextensions.ps1"
###
)

module.exports = (robot, scripts) ->
  psObject = {}
  loadAllextensions psObject, (error, result) ->
    robot.brain.set "extensions", result[0]
  scriptsPath = path.resolve(__dirname, 'src')
  fs.exists scriptsPath, (exists) ->
    if exists
      for script in fs.readdirSync(scriptsPath)
        if scripts? and '*' not in scripts
          robot.loadFile(scriptsPath, script) if script in scripts
        else
          robot.loadFile(scriptsPath, script)