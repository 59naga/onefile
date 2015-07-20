# Dependencies
# onefile= require '../src'

path= require 'path'
fs= require 'fs'
exec= (require 'child_process').exec

# Environment
jasmine.DEFAULT_TIMEOUT_INTERVAL= 100000
testDir= __dirname+path.sep

# execute onefile after bower install
$onefile= (packages='',argv=[],callback)->
  fs.writeFileSync testDir+'bower.json',JSON.stringify {
    name: 'onefile_fixture'
  }
  script= 'bower install '+packages+' --save && coffee ../onefile '+argv.join(' ')

  exec script,{cwd:__dirname},callback

# Specs
describe 'onefile',->
  afterAll (done)->
    exec 'rm *.js *.map *.json',{cwd:__dirname},done

  it '$ bower install jquery --save && onefile',(done)->
    $onefile 'jquery',[],(error,stdout,stderr)->
      output= 'pkgs'
      js= fs.readFileSync (testDir+output+'.js'),'utf8'
      map= fs.readFileSync (testDir+output+'.js.map'),'utf8'

      expect(js.length).toBeGreaterThan   200000
      expect(map.length).toBeGreaterThan  200000
      done()

  it '$ bower install c3-angular --save && onefile',(done)->
    $onefile 'c3-angular',[],(error,stdout,stderr)->
      output= 'pkgs'
      js= fs.readFileSync (testDir+output+'.js'),'utf8'
      map= fs.readFileSync (testDir+output+'.js.map'),'utf8'

      expect(js.length).toBeGreaterThan  1000000
      expect(map.length).toBeGreaterThan  200000
      done()

  it '$ bower install slick-carousel --save && onefile --output slick',(done)->
    $onefile 'slick-carousel',['--output','slick.js'],(error,stdout,stderr)->
      output= 'slick'
      js= fs.readFileSync (testDir+output+'.js'),'utf8'
      map= fs.readFileSync (testDir+output+'.js.map'),'utf8'

      expect(js.length).toBeGreaterThan   200000
      expect(map.length).toBeGreaterThan  200000
      done()