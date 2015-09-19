# Dependencies
bytes= require './bytes'

mainBowerFiles= require 'main-bower-files'
gulp= require 'gulp'
plugins= (require 'gulp-load-plugins')()

through2= require 'through2'
uglifyjs= require 'uglify-js'

path= require 'path'

# Public
onefile= ({cwd,outputName,outputBytes,mangle}={})->
  cwd?= process.cwd()
  outputName?= 'pkgs.js'
  outputName+= '.js' if outputName.slice(-3) isnt '.js'
  outputBytes?= no
  mangle?= false

  files= mainBowerFiles
    paths:
      bowerJson:
        path.join cwd,'bower.json'
      bowerDirectory:
        path.join cwd,'bower_components'
      bowerrc:
        path.join cwd,'.bowerrc'

  if files.length is 0
    console.error 'Missing dependencies of bower.json'
    process.exit 1

  # gulp-order doesn't work at absolute path
  # plase keep the `{base:'.'}` option
  files= (path.relative process.cwd(),file for file in files)
  available= files.concat ['!**/*.!(*js|*css)']

  if outputBytes
    console.log 'Found:'

  gulp.src available,{base:'.'}
    .pipe plugins.order files
    .pipe plugins.jsfy dataurl:yes
    .on 'data',(file)->
      if outputBytes
        console.log bytes file,cwd

    .pipe plugins.sourcemaps.init()
    .pipe plugins.concat outputName
    .pipe plugins.sourcemaps.write()
    .pipe through2.obj (obj,enc,next)->
      if mangle
        mangled= uglifyjs.minify obj.contents.toString(),{
          mangle: yes
          compress: yes
          fromString: yes
        }
        obj.contents= new Buffer mangled.code

      @push obj

      if outputBytes
        console.log 'Yield:'
        console.log bytes obj,cwd

      next()

module.exports= onefile
