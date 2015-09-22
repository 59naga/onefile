# Dependencies
bytes= require './bytes'
summaries= require './summaries'
compresser= require './compresser'

mainBowerFiles= require 'main-bower-files'
gulp= require 'gulp'
plugins= (require 'gulp-load-plugins')()

path= require 'path'

# Public
onefile= ({cwd,summary,sourcemap,mangle,detachSourcemap,outputName,outputBytes}={})->
  cwd?= process.cwd()
  summary?= yes
  sourcemap?= yes
  mangle?= false
  detachSourcemap?= false

  outputName?= 'pkgs.js'
  outputName+= '.js' if outputName.slice(-3) isnt '.js'
  outputBytes?= no

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
  # plase keep the `{base:'.'}` option at gulp.src
  files= (path.relative process.cwd(),file for file in files)
  available= files.concat ['!**/*.!(*js|*css)']

  if sourcemap
    gulp.src available,{base:'.'}
      .pipe plugins.order files
      .pipe plugins.jsfy dataurl:yes
      .pipe summaries {cwd,summary,outputBytes,outputName}
      .pipe plugins.sourcemaps.init()
      .pipe plugins.concat outputName
      .pipe plugins.sourcemaps.write()
      .pipe compresser {cwd,mangle,detachSourcemap,outputBytes}

  else
    gulp.src available,{base:'.'}
      .pipe plugins.order files
      .pipe plugins.jsfy dataurl:yes
      .pipe summaries {cwd,summary,outputBytes,outputName}
      # .pipe plugins.sourcemaps.init()
      .pipe plugins.concat outputName
      # .pipe plugins.sourcemaps.write()
      .pipe compresser {cwd,mangle,outputBytes}

module.exports= onefile
