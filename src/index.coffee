# Dependencies
Utility= require('./utility').Utility

Command= (require 'commander').Command
cli= new Command
bower= require 'bower'
rimraf= require 'rimraf'

chalk= require 'chalk'

fs= require 'fs'
path= require 'path'
exec= require('child_process').exec
EventEmitter= require('events').EventEmitter

# Public
class Onefile extends Utility
  parse: (rawArgv)->
    cli= new Command # fix Got a contaminated properties by Re-parse
    cli
      .version require('../package').version
      .option '-c, --compress',
        'Use UglifyJS2, <pkgs>.js compression ≒ <pkgs>.min.js'
      .option '-m, --mangle',
        'Use UglifyJS2, <pkgs>.js mangling ≠ <pkgs>.min.js'
      .option '-s, --sourcemap',
        'Use UglifyJS2, Output sourcemap ≒ <pkgs>.min.js.map'
      .option '-o, --output <name>',
        'Output endpoints = <pkgs>.js','pkgs'

      .option '-j, --json [filename]',
        'Use [./bower.json].',undefined
      .option '-S, --save',
        'Save dependencies to ./bower.json file.'
      .option '-D, --save-dev',
        'Save devDependencies to ./bower.json file.'

      .option '-d, --development',
        'Include devDependencies by Use ./bower.json file.'
    cli
      .command 'clean'
      .description 'Remove onefile cache directory'
      .option '-f --force','Remove bower cache directory'
      .action (args)=> @clean args.force

    options= cli.parse rawArgv
    options.output= options.output.replace /.js$/,''

    options.useJson= options.json? or options.development? or options.save? or options.saveDev?
    options.json= 'bower.json' if options.useJson? and not (typeof options.json is 'string')

    options.cwd= path.join __dirname,'..'
    options.cwd= path.dirname path.resolve process.cwd(),options.json if options.useJson
    options.useJsonPath= path.join options.cwd,'bower.json' if options.useJson
    options.directory= 'bower_components'
    options

  cli: (rawArgv,exit=yes)->
    options= @parse rawArgv
    return @help() if options.args.length is 0 and not options.useJson
    return if 'clean' in rawArgv

    skipInit= (options.save? or options.saveDev?) and not fs.existsSync options.useJsonPath
    fs.writeFileSync(options.useJsonPath,JSON.stringify {name:'undefined'}) if skipInit

    @h1 'Execute: bower install',options.args.join(' '),'...'

    installer= @install options.args,options
    installer.on 'log',(result)=>
      @log @getBgColor(on)(' > '),chalk.underline(result.id),result.message
    installer.on 'error',(error)-> throw error
    installer.on 'end', (configs={})=>
      json= require options.useJsonPath if options.useJson
      configs['']= json if json?
      dependencies= @getConfigsOfDependency configs,options
      resolvedConfigs= @merge dependencies,configs
      resolvedConfigs= @override resolvedConfigs,json.overrides if json?.overrides?

      targets= {}
      targets[config.name]= "#{config.name}##{config.version}" for name,config of resolvedConfigs when config.main?
      versions= (version for target,version of targets).join(' ')
      @h1 "Combile:",versions,'...'

      files= @getMainFiles resolvedConfigs,options
      throw new Error('Invalid configuration packages: '+versions) if Object.keys(targets).length is 0 or files.length is 0

      combinedFiles= []      
      combine= @combine files,options.output
      combine.on 'data',(gutilFile)=>
        file= path.relative options.cwd,gutilFile.path
        bytes= @format gutilFile.contents.length

        combinedFiles.push file

        @log @getBgColor(on)(' + '),chalk.underline(bytes),path.join '(cache)/',file
      combine.on 'end',(filename)=>

        @h1 'Result:'
        bytes= @format fs.readFileSync(filename).length
        @log @getBgColor(on)(' = '),chalk.underline(bytes),filename

        compress= @noop
        compress= @compress if options.compress? or options.mangle?
        compress= compress options.output,options.sourcemap,options.mangle
        compress.on 'data',(filename)=>
          bytes= @format fs.statSync(filename).size

          symbol= ' ≒ '
          symbol= ' ≠ ' if options.mangle?
          @log @getBgColor(on)(symbol),chalk.underline(bytes),filename

        compress.on 'end',=>
          if options.save?
            @h1 'Save:'
            for target,version of targets
              @log @getBgColor(on)(' < '),chalk.underline('dependencies'),version

          if options.saveDev?
            @h1 'Save:'
            for target,version of targets
              @log @getBgColor(on)(' < '),chalk.underline('devDependencies'),version

          process.exit 0 if exit
          installer.emit 'done',combinedFiles
        compress
      combine
    installer

  install: (packages=[],options={})->
    installer= new EventEmitter

    jsonOptions= {}
    jsonOptions['save']= yes if options.save?
    jsonOptions['saveDev']= yes if options.saveDev?
    jsonOptions['producion']= yes if options.producion?

    installOptions=
      cwd: options.cwd ? process.cwd()
      directory: 'bower_components'

    configs= {}
    bower.commands.install packages,jsonOptions,installOptions
      .on 'log', (result)->
        configs[result.data.pkgMeta.name]= result.data.pkgMeta if result.id is 'cached'
        configs[result.data.pkgMeta.name]= result.data.pkgMeta if result.id is 'install'

        installer.emit 'log',result

      .on 'error', (error)-> installer.emit 'error',error
      .on 'end',->
        installer.emit 'end',configs

    installer

  combine: (files,output)->
    combiner= new EventEmitter

    filename= "#{output}.js"
    dirname= process.cwd()

    gulp= require 'gulp'
    jsfy= require 'gulp-jsfy'
    concat= require 'gulp-concat'

    through2= gulp.src files.concat ['!**/*.!(*js|*css)']
    through2= through2.pipe jsfy dataurl:true
    through2.on 'data', -> combiner.emit 'data',arguments...
    through2= through2.pipe concat filename
    through2= through2.pipe gulp.dest dirname
    through2.on 'end', -> combiner.emit 'end',filename

    combiner

  compress: (output,sourcemap=null,mangle=null)->
    compresser= new EventEmitter

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
      args.push path.basename "#{output}.min.js.map"
      args.push '--prefix'
      args.push (path.dirname path.resolve process.cwd(),"#{output}.js").split(path.sep).length-1
    
    exec args.join(' '),(stderr)->
      throw stderr if stderr?

      compresser.emit 'data',"#{output}.min.js"
      compresser.emit 'data',"#{output}.min.js.map" if sourcemap?
      process.nextTick ->
        compresser.emit 'end'

    compresser

  clean: (force=null,exit=yes)->
    cleaner= new EventEmitter

    cacheDir= path.join __dirname,'..','bower_components'

    @log @getBgColor(on)(' > '),chalk.underline('deleted'),cacheDir
    rimraf cacheDir,=>
      clean= @noop
      clean= bower.commands.cache.clean if force?
      clean()
      .on 'log',(result)=>
        symbol= ' > '
        @log @getBgColor(on)(symbol),chalk.underline(result.id),result.message
      .on 'end',=>
        process.exit 0 if exit
        cleaner.emit 'end'

    cleaner
    
  help: ->
    @log chalk.styles.red.open

    cli
      .usage """
          <endpoint> [<endpoint> ..] [<options>]
        """+chalk.styles.red.close+chalk.styles.green.open
      .on '--help',=>
        @log chalk.styles.green.close,chalk.styles.yellow.open
        @log ("  Description(Quote bower install --help):\n\n"+require('bower/templates/json/help-install').description+"\n").replace /\n/g,"\n    "
        @log chalk.styles.yellow.close

    cli.help()

module.exports= new Onefile
module.exports.Onefile= Onefile