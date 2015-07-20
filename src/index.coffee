# Dependencies
Command= (require 'commander').Command

mainBowerFiles= require 'main-bower-files'
gulp= require 'gulp'
jsfy= require 'gulp-jsfy'
order= require 'gulp-order'
concat= require 'gulp-concat'
sourcemaps= require 'gulp-sourcemaps'
prettyBytes= require 'pretty-bytes'

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
    @version version

  parse: ->
    super

    @output+= '.js' if @output.slice(-3) isnt '.js'
    
    files= mainBowerFiles()
    if files.length is 0
      console.error 'Missing dependencies of bower.json'
      process.exit 1

    # gulp-order doesn't work at absolute path
    files= (path.relative process.cwd(),file for file in files)

    console.log 'Found:'
    bundle= []

    gulp.src (files.concat ['!**/*.!(*js|*css)']),{base:'.'}
      .pipe order files
      .pipe jsfy dataurl:yes
      .on 'data',(file)=>
        @stats file
      .pipe sourcemaps.init()
      .pipe concat @output
      .pipe sourcemaps.write './'
      .pipe gulp.dest @cwd
      .on 'data',(file)->
        bundle.unshift file
      .on 'end',=>

        console.log 'Yield:'
        @stats file.path for file in bundle

  stats: (file)->
    filePath= file?.path or file
    fileSize= file.contents?.length or fs.statSync(filePath).size

    byte= ('    '+(prettyBytes fileSize)).slice(-9)
    console.log '  ',byte,(path.relative @cwd,filePath)

module.exports= new Onefile
module.exports.Onefile= Onefile