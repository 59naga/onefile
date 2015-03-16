onefile= require '../'
onefile.silent= yes

fs= require 'fs'
getRawArgv= (argv)->
  process.argv[...2].concat argv

describe 'Usage',->
  beforeEach ->
    try
      fs.unlinkSync 'bower.json'
    catch

  it '$ onefile riot',(done)->
    argv= [
      'riot'

      '--compress'
      '--mangle'
      '--sourcemap'
    ]
    exit= no

    installer= onefile.cli getRawArgv(argv),exit
    installer.on 'done',(files)->
      file= "pkgs.js"
      fileMin= "pkgs.min.js"
      fileMinMap= "pkgs.min.js.map"

      expect(fs.statSync(file).size).toBeGreaterThan       15000
      expect(fs.statSync(fileMin).size).toBeGreaterThan     5000
      expect(fs.statSync(fileMinMap).size).toBeGreaterThan  5000
      done()

  it '$ onefile slick-carousel (Requirement margin greater than 30px)',(done)->
    argv= [
      'slick-carousel'
      
      '--compress'
      '--mangle'
      '--sourcemap'
    ]
    exit= no

    installer= onefile.cli getRawArgv(argv),exit
    installer.on 'done',(files)->
      file= "pkgs.js"
      fileMin= "pkgs.min.js"
      fileMinMap= "pkgs.min.js.map"

      expect(fs.statSync(file).size).toBeGreaterThan       200000
      expect(fs.statSync(fileMin).size).toBeGreaterThan    150000
      expect(fs.statSync(fileMinMap).size).toBeGreaterThan 100000
      done()

  it '$ onefile --save angular angular-ui-router angular-animate animate.css',(done)->
    argv= [
      'angular#1.3.14'
      'angular-ui-router#0.2.13'
      'angular-animate#1.3.14'
      'animate.css#3.2.3'
      
      '--compress'
      '--mangle'
      '--sourcemap'

      '--save'
    ]
    exit= no

    installer= onefile.cli getRawArgv(argv),exit
    installer.on 'done',(files)->
      file= "pkgs.js"
      fileMin= "pkgs.min.js"
      fileMinMap= "pkgs.min.js.map"

      expect(fs.statSync(file).size).toBeGreaterThan      1000000
      expect(fs.statSync(fileMin).size).toBeGreaterThan    200000
      expect(fs.statSync(fileMinMap).size).toBeGreaterThan 200000
      expect(JSON.parse fs.readFileSync('./bower.json').toString()).toEqual
        name: "undefined"
        dependencies:
          angular: "1.3.14"
          "angular-ui-router": "0.2.13"
          "angular-animate": "1.3.14"
          "animate.css": "3.2.3"
      done()

  xit '$ onefile jasmine(Can not combine since main is undefined)',(done)->
    argv= [
      'jasmine#2.2.1'
      
      '--compress'
      '--mangle'
      '--sourcemap'
    ]
    exit= no

    try
      onefile.cli getRawArgv(argv),exit
    catch error
      expect(error).toEqual new Error '"main" is undefined to the ...'