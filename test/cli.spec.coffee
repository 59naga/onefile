# Dependencies
onefile= require '../src'

path= require 'path'
fs= require 'fs'
exec= (require 'child_process').exec

# Environment
jasmine.DEFAULT_TIMEOUT_INTERVAL= 100000
$onefile= (packages='',argv=[],callback)->
  fs.writeFileSync testDir+'bower.json',JSON.stringify {
    name: 'onefile_fixture'
  }
  script= 'bower install '+packages+' --save && coffee ../onefile '+argv.join(' ')

  exec script,{cwd:__dirname},callback

testDir= __dirname+path.sep

# Specs
describe 'onefile',->
  afterAll (done)->
    exec 'rm *.js *.map *.json',{cwd:__dirname},done

  it '$ bower install jquery --save && onefile',(done)->
    $onefile 'jquery',[],->
      output= 'pkgs'
      js= fs.readFileSync (testDir+output+'.js'),'utf8'

      expect(js.length).toBeGreaterThan  200000
      done()

  it '$ bower install c3-angular --save && onefile',(done)->
    $onefile 'c3-angular',[],->
      output= 'pkgs'
      js= fs.readFileSync (testDir+output+'.js'),'utf8'

      expect(js.length).toBeGreaterThan 1000000
      done()

  it '$ bower install c3-angular --save && onefile --mangle --soucemap',(done)->
    $onefile 'c3-angular',['--mangle','--soucemap'],->
      output= 'pkgs'
      js= fs.readFileSync (testDir+output+'.js'),'utf8'
      min= fs.readFileSync (testDir+output+'.min.js'),'utf8'
      map= fs.readFileSync (testDir+output+'.min.js.map'),'utf8'

      expect(js.length).toBeGreaterThan  1000000
      expect(min.length).toBeGreaterThan  400000
      expect(map.length).toBeGreaterThan  600000
      done()

  it '$ bower install slick-carousel --save && onefile --mangle --soucemap --output slick',(done)->
    $onefile 'slick-carousel',['--mangle','--soucemap','--output','slick'],->
      output= 'slick'
      js= fs.readFileSync (testDir+output+'.js'),'utf8'
      min= fs.readFileSync (testDir+output+'.min.js'),'utf8'
      map= fs.readFileSync (testDir+output+'.min.js.map'),'utf8'

      expect(js.length).toBeGreaterThan   200000
      expect(min.length).toBeGreaterThan  100000
      expect(map.length).toBeGreaterThan  150000
      done()

  fit '$ bower install bootstrap bootstrap-material-design --save && onefile',(done)->
    $onefile 'bootstrap bootstrap-material-design',[],(error,stdout)->
      output= 'pkgs'
      js= fs.readFileSync (testDir+output+'.js'),'utf8'

      expect(js.length).toBeGreaterThan  200000

      parentOffset= stdout.indexOf 'bower_components/bootstrap/'
      childOffset= stdout.indexOf 'bower_components/bootstrap-material-design/'
      expect(parentOffset).toBeGreaterThan childOffset

      done()
