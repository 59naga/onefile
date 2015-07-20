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
      .pipe jsfy dataurl:yes
      .on 'data',(file)=>
        @stats file
      .pipe concat @output+'.js'
      .pipe gulp.dest @cwd
      .on 'data',(file)=>
        console.log 'Yield:'
        @stats file.path

  stats: (file)->
    filePath= file?.path or file
    fileSize= file.contents?.length or fs.statSync(filePath).size

    byte= ('    '+(prettyBytes fileSize)).slice(-9)
    console.log '  ',byte,(path.relative @cwd,filePath)

module.exports= new Onefile
module.exports.Onefile= Onefile