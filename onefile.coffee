onefile=
  cwd: __dirname
  directory: 'bower_components'
  cli: ->
    cli
      .version require('./package').version
      .option '-c, --compress' ,'Use UglifyJS2, <pkgs>.js compression ≒ <pkgs>.min.js'
      .option '-m, --mangle'   ,'Use UglifyJS2, <pkgs>.js mangling ≠ <pkgs>.min.js'
      .option '-s, --sourcemap','Use UglifyJS2, Output sourcemap ≒ <pkgs>.min.js.map'
      .option '-o, --output <name>','Output endpoints = <pkgs>.js','pkgs'
    cli
      .command 'clean'
      .description 'Remove onefile cache directory'
      .option '-f --force','Remove bower cache directory'
      .action (args)=> @clean args.force
    cli
      .parse process.argv

    return @help() if cli.args.length is 0
    return if 'clean' in process.argv

    @h1 'Execute: bower install',cli.args.join(' '),'...'

    install= @install cli.args
    install.on 'log',(result)=>
      console.log @getBgColor(true)(' > '),chalk.underline(result.id),result.message
    install.on 'error',(error)-> throw error
    install.on 'end', (configs=[])=>
      dependencies= @getConfigsOfDependency configs
      resolvedConfigs= dependencies.concat configs

      targets= {}
      targets[config.name]= "#{config.name}##{config.version}" for config in resolvedConfigs
      versions= (version for target,version of targets).join(' ')
      @h1 "Combile:",versions,'...'

      files= @getMainFiles resolvedConfigs
      throw new Error('Invalid configuration packages: '+versions) if Object.keys(targets).length is 0 or files.length is 0

      combine= @combine files,cli.output
      combine.on 'data',(gutilFile)=>
        file= path.relative process.cwd(),gutilFile.path
        bytes= @format gutilFile.contents.length

        console.log @getBgColor(true)(' + '),chalk.underline(bytes),path.join '(cache)/',file
      combine.on 'end',(filename)=>

        @h1 'Result:'
        bytes= @format fs.readFileSync(filename).length
        console.log @getBgColor(true)(' = '),chalk.underline(bytes),filename

        compress= @noop
        compress= @compress if cli.compress? or cli.mangle?
        compress= compress cli.output,cli.sourcemap,cli.mangle
        compress.on 'data',(filename)=>
          bytes= @format fs.statSync(filename).size

          symbol= ' ≒ '
          symbol= ' ≠ ' if cli.mangle?
          console.log @getBgColor(true)(symbol),chalk.underline(bytes),filename

        compress.on 'end',-> process.exit 0
        compress
      combine
    install

  install: (packages=[])->
    EventEmitter= new events.EventEmitter

    configs= []
    bower.commands.install packages,[],{cwd:@cwd,directory:@directory}
      .on 'log', (result)->
        configs.push result.data.pkgMeta if result.id is 'cached'
        configs.push result.data.pkgMeta if result.id is 'install'

        EventEmitter.emit 'log',result

      .on 'error', (error)-> EventEmitter.emit 'error',error
      .on 'end',->
        EventEmitter.emit 'end',configs

    EventEmitter

  combine: (files,output)->
    EventEmitter= new events.EventEmitter

    filename= "#{output}.js"
    dirname= process.cwd()

    through2= gulp.src files.concat ['!**/*.!(*js|*css)']
    through2= through2.pipe jsfy dataurl:true
    through2.on 'data', -> EventEmitter.emit 'data',arguments...
    through2= through2.pipe concat filename
    through2= through2.pipe gulp.dest dirname
    through2.on 'end', -> EventEmitter.emit 'end',filename

    EventEmitter

  compress: (output,sourcemap=null,mangle=null)->
    EventEmitter= new events.EventEmitter

    args= []
    args.push 'node'
    args.push require.resolve 'uglify-js/bin/uglifyjs'
    args.push path.resolve process.cwd(),"#{output}.js"
    args.push '-o' 
    args.push path.resolve process.cwd(),"#{output}.min.js"
    args.push '-m' if mangle?
    if sourcemap?
      args.push '--source-map'
      args.push path.resolve process.cwd(),"#{output}.min.js.map"
      args.push '--source-map-url'
      args.push "#{output}.min.js.map"
    
    exec= childProcess.exec
    exec args.join(' '),(stderr)->
      throw stderr if stderr?

      EventEmitter.emit 'data',"#{output}.min.js"
      EventEmitter.emit 'data',"#{output}.min.js.map" if sourcemap?
      process.nextTick ->
        EventEmitter.emit 'end'

    EventEmitter

  clean: (force=null)->
    cacheDir= path.join @cwd,@directory

    console.log @getBgColor(true)(' > '),chalk.underline('deleted'),cacheDir
    rimraf cacheDir,=>
      clean= @noop
      clean= bower.commands.cache.clean if force?
      clean()
      .on 'log',(result)=>
        symbol= ' > '
        console.log @getBgColor(true)(symbol),chalk.underline(result.id),result.message
      .on 'end',=>
        process.exit 0

  getConfigsOfDependency: (configs)->
    dependencies= []

    cacheDir= path.join @cwd,@directory
    for config in configs
      for name,version of config.dependencies
        dependencies.push require path.join cacheDir,name,'bower.json'

    dependencies

  getMainFiles: (configs)->
    files= []
    for config in configs
      config.main= [config.main] if not (config.main instanceof Array)
      for file in config.main
        if file is undefined
          @log "Warn: \"main\" is undefined to the #{path.join @cwd,@directory,config.name}/bower.json"
          continue;

        files.push path.join @cwd,@directory,config.name,file

    files

  noop: (name='end')->
    noop= new events.EventEmitter
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
    @log.i= 0 if @logColors[@log.i] is undefined
    color= chalk[@logColors[@log.i]]
    @log.i++ if changeColor is yes

    color
  getBgColor: (changeColor=no)->
    @log.i= 0 if @logBgColors[@log.i] is undefined
    color= chalk[@logBgColors[@log.i]]
    @log.i++ if changeColor is yes

    color

  format: (bytes)->
    ('      '+prettyBytes bytes).slice -10

  help: ->
    console.log chalk.styles.red.open

    cli
      .usage """
          <endpoint> [<endpoint> ..] [<options>]
        """+chalk.styles.red.close+chalk.styles.green.open
      .on '--help',->
        console.log chalk.styles.green.close,chalk.styles.yellow.open
        console.log ("  Description(Quote bower install --help):\n\n"+require('bower/templates/json/help-install').description+"\n").replace /\n/g,"\n    "
        console.log chalk.styles.yellow.close

    cli.help()

# Rename dependencies
{
  fs,path,childProcess,events

  cli,bower,rimraf,
  gulp,sort,jsfy,concat,
  chalk,prettyBytes
}= require('node-module-all')
  builtinLibs: true
  change: 'camelCase'
  rename: commander: 'cli'
  replace: (changedName,originalName)->
    changedName= originalName.replace /^gulp-/,'' if originalName.match /^gulp-/
    changedName

module.exports= onefile