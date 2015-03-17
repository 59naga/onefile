path= require 'path'
EventEmitter= require('events').EventEmitter

chalk= require 'chalk'
prettyBytes= require 'pretty-bytes'

class Utility
  constructor: ->
    @i= 0

  getConfigsOfDependency: (configs,options)->
    dependencies= {}

    cacheDir= path.join options.cwd,options.directory
    for name,config of configs
      for name,version of config.dependencies
        dependencies[name]= require path.join cacheDir,name,'bower.json'

    dependencies

  merge: (obj,overrides)->
    obj
    obj[key]= value for key,value of overrides
    obj

  override: (configs,overrides) ->
    for name,config of overrides
      if config.ignore
        delete configs[name]
        continue
      configs[name]= @merge configs[name],config if configs[name]?

    configs

  getMainFiles: (configs,options)->
    files= []
    for name,config of configs
      config.main= [config.main] if not (config.main instanceof Array)
      for file in config.main
        if file is undefined
          if not options.useJson
            @log "Warn: \"main\" is undefined to the #{path.join options.cwd,options.directory,config.name}/bower.json"
          continue;
          
        files.push path.join options.cwd,options.directory,name,file

    files

  noop: (name='end')->
    noop= new EventEmitter
    process.nextTick -> noop.emit 'end'
    noop

  logColors: ['red','green','yellow','cyan']
  logBgColors: ['bgRed','bgGreen','bgYellow','bgCyan']

  h1: (args...)->
    return if require('../').silent
    console.log ''
    console.log chalk.bold args...
  log: (args...)->
    return if require('../').silent
    console.log args...
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