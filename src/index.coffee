# Dependencies
Command= (require 'commander').Command
mainBowerFiles= require 'main-bower-files'
gulp= require 'gulp'
jsfy= require 'gulp-jsfy'
order= require 'gulp-order'
concat= require 'gulp-concat'
prettyBytes= require 'pretty-bytes'

spawn= (require 'child_process').spawn
path= require 'path'
fs= require 'fs'

# Environment
version= (require '../package').version

# Public
class Onefile extends Command
  constructor: ->
    super

    @cwd= process.cwd()

    @option '-o, --output <pkgs>.js','Change the output filename','pkgs'
    @option '-m, --mangle','Mangle <pkgs>.js to <pkgs>.min.js'
    @option '-s, --soucemap','Create soucemap to <pkgs>.min.js.map'
    @version version

  parse: ->
    super
    
    files= mainBowerFiles()
    if files.length is 0
      console.error 'Missing dependencies of bower.json'
      process.exit 1

    # gulp-order doesn't work at absolute path
    files= (path.relative process.cwd(),file for file in files)

    console.log 'Found:'
    gulp.src (files.concat ['!**/*.!(*js|*css)']),{base:'.'}
      .pipe order files
      .on 'data',(file)=>
        @stats file.path
      .pipe jsfy datauri:yes
      .pipe concat @output+'.js'
      .pipe gulp.dest @cwd
      .on 'data',(file)=>
        console.log 'Yield:'
        @stats file.path
      .on 'end',=>
        @uglify() if @mangle

  uglify: ->
    args= []
    args.push 'node'
    args.push require.resolve 'uglify-js/bin/uglifyjs'
    args.push path.resolve @cwd,"#{@output}.js"
    args.push '-o'
    args.push path.resolve @cwd,"#{@output}.min.js"
    args.push '-m'
    if @soucemap
      args.push '--source-map'
      args.push path.resolve @cwd,"#{@output}.min.js.map"
      args.push '--source-map-url'
      args.push path.basename "#{@output}.min.js.map"
      args.push '--prefix'
      args.push (path.dirname path.resolve @cwd,"#{@output}.js").split(path.sep).length-1

    [bin,args...]= args
    child= spawn bin,args,{stdio:'inherit'}
    child.on 'exit',=>
      @stats "#{@output}.min.js"

      if @soucemap
        @stats "#{@output}.min.js.map"

  stats: (file)->
    byte= ('    '+(prettyBytes fs.statSync(file).size)).slice(-8)
    console.log '  ',byte,(path.relative @cwd,file)

module.exports= new Onefile
module.exports.Onefile= Onefile