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

  fit '$ bower install bootstrap --save && onefile',(done)->
    summaries= [
      /kB bower_components\/jquery\/dist\/jquery.js/
      /kB bower_components\/bootstrap\/dist\/js\/bootstrap.js/
      /kB pkgs.js/
    ]

    $bowerInstall 'bootstrap',->
      onefile {cwd:__dirname}
      .on 'data',(file)->
        chunk= file.contents.toString().slice(0,200)

        expect(file.contents.length).toBeGreaterThan 200000
        expect(chunk).toMatch summaries[0]
        expect(chunk).toMatch summaries[1]
        expect(chunk).toMatch summaries[2]
        
      .on 'end',done

  it '$ bower install c3-angular --save && onefile',(done)->
    $bowerInstall 'c3-angular',->
      onefile {cwd:__dirname}
      .on 'data',(file)->
        expect(file.contents.length).toBeGreaterThan 1000000

      .on 'end',done

  it '$ bower install slick-carousel --save && onefile',(done)->
    $bowerInstall 'slick-carousel',->
      onefile {cwd:__dirname}
      .on 'data',(file)->
        expect(file.contents.length).toBeGreaterThan 200000

      .on 'end',done
