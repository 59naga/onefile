onefile= require './'
try
  bin= require.resolve 'onefile/onefile'
catch notLink
  bin= './onefile'

{events,childProcess,fs}= require('node-module-all')
  builtinLibs:true
  change:'camelCase'

describe 'Onefile v0.2.0 API',->
  describe 'onefile.utilities',->
    it '@noop is EventEmitter Fake',(done)->
      noop= onefile.noop()
      noop.on 'end',-> done()
    it

  describe 'onefile by',->
    it 'riot',(done)->
      output= 'pkgs'

      script= [
        'node'
        bin
        '-cs'
        'riot'
      ]
      [script,args...]= script

      child= childProcess.spawn script,args
      child.on 'error',(error)-> throw error
      child.on 'close',->
        file= "#{output}.js"
        fileMin= "#{output}.min.js"
        fileMinMap= "#{output}.min.js.map"

        expect(fs.statSync(file).size).toBeGreaterThan       15000
        expect(fs.statSync(fileMin).size).toBeGreaterThan    10000
        expect(fs.statSync(fileMinMap).size).toBeGreaterThan 10000
        done()

    it 'slick-carousel',(done)->
      output= 'pkgs'

      script= [
        'node'
        bin
        '-cs'
        'slick-carousel'
      ]
      [script,args...]= script

      child= childProcess.spawn script,args
      child.on 'error',(error)-> throw error
      child.on 'close',->
        file= "#{output}.js"
        fileMin= "#{output}.min.js"
        fileMinMap= "#{output}.min.js.map"

        expect(fs.statSync(file).size).toBeGreaterThan       250000
        expect(fs.statSync(fileMin).size).toBeGreaterThan    150000
        expect(fs.statSync(fileMinMap).size).toBeGreaterThan 100000
        done()

    it 'angular angular-ui-router angular-animate animate.css',(done)->
      output= 'pkgs'

      script= [
        'node'
        bin
        '-cs'
        'angular'
        'angular-ui-router'
        'angular-animate'
        'animate.css'
      ]
      [script,args...]= script

      child= childProcess.spawn script,args
      child.on 'error',(error)-> throw error
      child.on 'close',->
        file= "#{output}.js"
        fileMin= "#{output}.min.js"
        fileMinMap= "#{output}.min.js.map"

        expect(fs.statSync(file).size).toBeGreaterThan      1000000
        expect(fs.statSync(fileMin).size).toBeGreaterThan    400000
        expect(fs.statSync(fileMinMap).size).toBeGreaterThan 300000
        done()
