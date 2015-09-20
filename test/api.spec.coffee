# Dependencies
onefile= require '../src'

path= require 'path'
fs= require 'fs'
exec= (require 'child_process').exec

# Environment
jasmine.DEFAULT_TIMEOUT_INTERVAL= 100000
bowerJson= path.join __dirname,'bower.json'
execOptions= {cwd:__dirname}

# execute onefile after bower install
$bowerInstall= (packages='',callback)->
  fs.writeFileSync bowerJson,JSON.stringify {name:'onefile_fixture'}
  script= 'bower install '+packages+' --save'

  exec script,execOptions,callback

# Specs
describe 'onefile',->
  afterAll (done)->
    exec 'rm *.js *.map *.json',execOptions,done

  it '$ bower install jquery --save && onefile',(done)->
    $bowerInstall 'jquery',->
      onefile {cwd:__dirname}
      .on 'data',(file)->
        expect(file.contents.length).toBeGreaterThan 200000
        
      .on 'end',->
        done()

  it '$ bower install c3-angular --save && onefile',(done)->
    $bowerInstall 'c3-angular',->
      onefile {cwd:__dirname}
      .on 'data',(file)->
        expect(file.contents.length).toBeGreaterThan 1000000

      .on 'end',->
        done()

  it '$ bower install slick-carousel --save && onefile',(done)->
    $bowerInstall 'slick-carousel',->
      onefile {cwd:__dirname}
      .on 'data',(file)->
        expect(file.contents.length).toBeGreaterThan 200000

      .on 'end',->
        done()
