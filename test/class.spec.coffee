onefile= require '../'
onefile.silent= yes

EventEmitter= require('events').EventEmitter
spawn= require('child_process').spawn
path= require 'path'
fs= require 'fs'

chalk= require 'chalk'

fixture= 
  json: path.join __dirname,'bower.json'
  path: "#{process.cwd()}/bower_components/jquery/dist/jquery.js"
  configs:
    jquery:
      name: 'jquery'
      main: 'dist/jquery.js'
      dependencies: {}
getRawArgv= (argv)->
  process.argv[...2].concat argv

describe 'Class',->
  describe 'Onefile',->
    properties= Object.keys onefile.__proto__
    
    it '.parse is commander.parse',->
      instance= new onefile.constructor
      argv= [
        '-c'
        '-m'
        '-s'
      ]

      parsed= instance.parse getRawArgv argv
      expect(parsed.compress).toEqual yes
      expect(parsed.mangle).toEqual yes
      expect(parsed.sourcemap).toEqual yes
      expect(parsed.output).toEqual 'pkgs'
      expect(parsed.json).toEqual 'bower.json'
      expect(parsed.save).toEqual undefined
      expect(parsed.saveDev).toEqual undefined
      expect(parsed.production).toEqual undefined

      instance= new onefile.constructor
      argv= [
        '-c'
        '-m'
        '-s'
        '-o'

        'hogekosan'

        '-j'
        '-S'
        '-D'
        '-p'
      ]

      parsed= instance.parse getRawArgv argv
      expect(parsed.compress).toEqual yes
      expect(parsed.mangle).toEqual yes
      expect(parsed.sourcemap).toEqual yes
      expect(parsed.output).toEqual 'hogekosan'
      expect(parsed.json).toEqual 'bower.json'
      expect(parsed.save).toEqual yes
      expect(parsed.saveDev).toEqual yes
      expect(parsed.production).toEqual yes

    it '.cli is CLI entry point',(done)->
      instance= new onefile.constructor

      argv= [
        fixture.configs.jquery.name
      ]
      exit= no

      cli= instance.cli getRawArgv(argv),exit
      cli.on 'done',(files)->
        expect(cli instanceof EventEmitter).toBe yes
        expect(files.length).toEqual 1

        done()
    
    describe '.install',->
      beforeEach ->
        fs.writeFileSync fixture.json,JSON.stringify {name:'onefile'},null,'  '

        jsonObj= require fixture.json
        expect(jsonObj).toEqual {name:'onefile'}

      it '.install is bower wrapper',(done)->
        instance= new onefile.constructor

        installer= instance.install ['jquery']
        installer.on 'log',(result)->
          expect(typeof result.id).toEqual 'string'

        installer.on 'end',(configs)->
          expect(installer instanceof EventEmitter).toBe yes
          expect((Object.keys configs).length).toEqual 1
          done()

      it '.install --save',(done)->
        instance= new onefile.constructor

        installer= instance.install ['jquery#2.1.3'],{save:yes,cwd:__dirname}
        installer.on 'end',->
          dependencies= (JSON.parse fs.readFileSync(fixture.json).toString()).dependencies

          expect(dependencies.jquery).toEqual "2.1.3"
          done()

      it '.install --save-dev',(done)->
        instance= new onefile.constructor

        installer= instance.install ['jquery#2.1.3'],{saveDev:yes,cwd:__dirname}
        installer.on 'end',->
          devDependencies= (JSON.parse fs.readFileSync(fixture.json).toString()).devDependencies

          expect(devDependencies.jquery).toEqual "2.1.3"
          done()

      it '.install --json',(done)->
        instance= new onefile.constructor

        installer= instance.install [],{json:yes,cwd:__dirname}
        installer.on 'end',(validatedConfigs)->
          expect(installer instanceof EventEmitter).toBe yes
          expect((Object.keys validatedConfigs).length).toEqual 0

          done()

    it '.combine is gulp-concat and gulp-jsfy wrapper',(done)->
      combiner= onefile.combine fixture.path,'pkgs'
      combiner.on 'data',(data)->
        expect(data.path).toEqual fixture.path
      combiner.on 'end',(filename)->
        expect(filename).toEqual 'pkgs.js'

        done()

    it '.compress is UglifyJS2 wrapper via child_process',(done)->
      output= 'pkgs'
      sourcemap= yes
      mangle= yes

      i= 0
      outputs= ['pkgs.min.js','pkgs.min.js.map']
      compresser= onefile.compress output,sourcemap,mangle
      compresser.on 'data',(filename)->
        expect(filename).toEqual outputs[i++]

      compresser.on 'end',->
        done()

    it "... has #{properties.length} properties",->
      expect(properties).toEqual [
        'constructor'
        'parse'
        'cli'
        'install'
        'combine'
        'compress'
        'clean'
        'help'
      ]

  describe 'Utility',->
    Utility= require '../lib/utility'
    utility= new Utility
    properties= Object.keys utility.__proto__

    options=
      cwd: process.cwd()
      directory: 'bower_components'

    it '.constructor is Define working directory',->
      expect(utility.i).toEqual 0

    it '.getConfigsOfDependency is Get absolute dependencies mainfile path. by bower.json',->
      dependencies= utility.getConfigsOfDependency fixture.configs,options

      expect((Object.keys dependencies).length).toEqual 0

    it '.merge is override object properties',->
      merged= utility.merge {foo:1,bar:'baz'},{bar:'hogekosan',wombat:'fishpaste'}

      expect(merged).toEqual foo:1,bar:'hogekosan',wombat:'fishpaste'

    it '.override is main-bower-files friendly configure',->
      overrides=
        jquery:
          ignore: yes
        moment:
          main:[
            'moment.js'
            'locale/ja.js'
          ]
          dependencies:
            'lodash':'*'

      merged= utility.override {'jquery':{},'moment':{}},overrides
      expect(merged).toEqual
        moment:
          main:[
            'moment.js'
            'locale/ja.js'
          ]
          dependencies:
            'lodash':'*'

    it '.getMainFiles is Get absolute mainfile path. by bower.json',->
      mainFiles= utility.getMainFiles fixture.configs,options

      expect(mainFiles.length).toEqual 1
      expect(mainFiles[0]).toEqual fixture.path

    it '.noop is EventEmitter Fake',(done)->
      noop= utility.noop()
      noop.on 'end',->
        done()

    it '.logColors is chalk method names',->
      expect(utility.logColors.length).toEqual 4
      expect(utility.logColors instanceof Array).toBe yes

    it '.logBgColors is chalk method names',->
      expect(utility.logBgColors.length).toEqual 4
      expect(utility.logBgColors instanceof Array).toBe yes

    it '.h1 is console.log wrapper',->
      expect(utility.h1 'guwa-').toEqual undefined

    it '.log is console.log wrapper',->
      expect(utility.h1 'gya-').toEqual undefined

    it '.getColor is chalk method getter',->
      colorName= utility.logColors[utility.i]
      styleName= utility.getColor()._styles[utility.i]

      expect(styleName).toEqual chalk[colorName]._styles[utility.i]

    it '.getBgColor is chalk method getter',->
      bgcolorName= utility.logBgColors[utility.i]
      styleName= utility.getBgColor()._styles[utility.i]

      expect(styleName).toEqual chalk[bgcolorName]._styles[utility.i]

    it '.format is pretty-bytes alias',->
      expect(utility.format(10000)).toEqual '     10 kB'

    xit '.help is Output cli usage before process.exit(0)',->
      utility.help()

    xit '.clean',(done)->
      force= yes
      exit= no

      cleaner= utility.clean null,exit
      cleaner.on 'end',->
        cleaner= utility.clean force,exit
        cleaner.on 'end',->
          done()

    it "...has #{properties.length} properties",->
      expect(properties).toEqual [
        'getConfigsOfDependency'
        'merge'
        'override'
        'getMainFiles'
        'noop'
        'logColors'
        'logBgColors'
        'h1'
        'log'
        'getColor'
        'getBgColor'
        'format'
      ]