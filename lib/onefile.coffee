fs= require 'fs'
path= require 'path'
exec= require('child_process').exec
EventEmitter= require('events').EventEmitter

Command= (require 'commander').Command
cli= new Command
bower= require 'bower'
rimraf= require 'rimraf'

chalk= require 'chalk'

class Onefile extends require './utility.coffee'
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

      .option '-j, --json',
        'Use ./bower.json.'
      .option '-S, --save',
        'Save dependencies to ./bower.json file.'
      .option '-D, --save-dev',
        'Save devDependencies to ./bower.json file.'

      .option '-p, --production',
        'Ignore devDependencies by Use ./bower.json file.'
    cli
      .command 'clean'
      .description 'Remove onefile cache directory'
      .option '-f --force','Remove bower cache directory'
      .action (args)=> @clean args.force

    options= cli.parse rawArgv

    options.useJson= options.json? or options.save? or options.saveDev? or options.production?

    options.cwd= path.join __dirname,'..'
    options.cwd= process.cwd() if options.useJson
    options.directory= 'bower_components'
    options

  cli: (rawArgv,exit=yes)->
    options= @parse rawArgv
    return @help() if options.args.length is 0 and not options.useJson
    return if 'clean' in rawArgv

    @h1 'Execute: bower install',options.args.join(' '),'...'

    installer= @install options.args,options
    installer.on 'log',(result)=>
      console.log @getBgColor(true)(' > '),chalk.underline(result.id),result.message
    installer.on 'error',(error)-> throw error
    installer.on 'end', (configs=[])=>
      configs.unshift require(path.join options.cwd,'bower.json') if options.useJson
      dependencies= @getConfigsOfDependency configs,options
      resolvedConfigs= dependencies.concat configs

      targets= {}
      targets[config.name]= "#{config.name}##{config.version}" for config in resolvedConfigs when config.main?
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

        console.log @getBgColor(true)(' + '),chalk.underline(bytes),path.join '(cache)/',file
      combine.on 'end',(filename)=>

        @h1 'Result:'
        bytes= @format fs.readFileSync(filename).length
        console.log @getBgColor(true)(' = '),chalk.underline(bytes),filename

        compress= @noop
        compress= @compress if options.compress? or options.mangle?
        compress= compress options.output,options.sourcemap,options.mangle
        compress.on 'data',(filename)=>
          bytes= @format fs.statSync(filename).size

          symbol= ' ≒ '
          symbol= ' ≠ ' if options.mangle?
          console.log @getBgColor(true)(symbol),chalk.underline(bytes),filename

        compress.on 'end',->
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

    configs= []
    bower.commands.install packages,jsonOptions,installOptions
      .on 'log', (result)->
        configs.push result.data.pkgMeta if result.id is 'cached'
        configs.push result.data.pkgMeta if result.id is 'install'

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
      args.push "#{output}.min.js.map"
    
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

    console.log @getBgColor(true)(' > '),chalk.underline('deleted'),cacheDir
    rimraf cacheDir,=>
      clean= @noop
      clean= bower.commands.cache.clean if force?
      clean()
      .on 'log',(result)=>
        symbol= ' > '
        console.log @getBgColor(true)(symbol),chalk.underline(result.id),result.message
      .on 'end',=>
        process.exit 0 if exit
        cleaner.emit 'end'

    cleaner
    
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

module.exports= new Onefile
