path= require 'path'
EventEmitter= require('events').EventEmitter

chalk= require 'chalk'
prettyBytes= require 'pretty-bytes'

class Utility
  constructor: ->
    @i= 0

  getConfigsOfDependency: (configs,options)->
    dependencies= []

    cacheDir= path.join options.cwd,options.directory
    for config in configs
      for name,version of config.dependencies
        dependencies.push require path.join cacheDir,name,'bower.json'

    dependencies

  getMainFiles: (configs,options)->
    files= []
    for config in configs
      config.main= [config.main] if not (config.main instanceof Array)
      for file in config.main
        if file is undefined
          if not options.useJson
            @log "\"main\" is undefined to the #{path.join options.cwd,options.directory,config.name}/bower.json"
          continue;
          
        files.push path.join options.cwd,options.directory,config.name,file

    files

  noop: (name='end')->
    noop= new EventEmitter
    process.nextTick -> noop.emit 'end'
    noop

  logColors: ['red','green','yellow','cyan']
  logBgColors: ['bgRed','bgGreen','bgYellow','bgCyan']

  h1: (args...)->
    console.log ''
    console.log chalk.bold args...
  log: (args...)->
    [...,changeColor]= args
    args= args[...-1] if changeColor is yes

    console.log @getColor(changeColor) args...
  getColor: (changeColor=no)->
    @i= 0 if @logColors[@i] is undefined
    color= chalk[@logColors[@i]]
    @i++ if changeColor is yes

    color
  getBgColor: (changeColor=no)->
    @i= 0 if @logBgColors[@i] is undefined
    color= chalk[@logBgColors[@i]]
    @i++ if changeColor is yes

    color

  format: (bytes)->
    ('      '+prettyBytes bytes).slice -10

module.exports= Utility