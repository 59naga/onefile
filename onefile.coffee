mainBowerOnefile=
  cli: ->
    commander= require 'commander'
    commander
      .version require('./package.json').version
      .usage 'name[.js] [options...]'
      .option '-u, --uglifyjs         ','Use UglifyJS2'
      .option '-s, --sourcemap        ','Use UglifyJS2 sourcemap'
      .option '-m, --mangle           ','Use UglifyJS2 Mangle names/pass'
      .option '-v, --verbose          ','Output filenames'

      .option '-j, --json       <path>','Use <bower.json>'      ,'bower.json'
      .option '-d, --directory  <path>','Use <bower_components>','bower_components'
      .option '-r, --rc         <path>','Use <.bowerrc>'        ,'.bowerrc'
      .option '-D, --includeDev       ','Use devDependencies   '
      .parse process.argv
    commander.help() if commander.args.length is 0

    fs    = require 'fs'
    pb    = require 'pretty-bytes'
    path  = require 'path'
    Gulp  = require 'gulp'
    mbf   = require 'main-bower-files'
    jsfy  = require 'gulp-jsfy'
    concat= require 'gulp-concat'

    filename= commander.args[0]
    filename+= '.js' if filename.match(/.js$/) is null
    filenameMin= filename.replace /.js$/,'.min.js'
    
    basename= path.basename filename
    dirname= path.dirname path.resolve process.cwd(),filename
    mbfOptions= 
      paths:
        bowerJson     : path.resolve process.cwd(),commander.json
        bowerDirectory: path.resolve process.cwd(),commander.directory
        bowerrc       : path.resolve process.cwd(),commander.rc
      includeDev      : commander.includeDev
    
    gulp= Gulp.src (mbf mbfOptions).concat ['!**/*.!(*js|*css)']# Ignore unsupport extension
    gulp= gulp.pipe jsfy dataurl:true
    gulp.on 'data',(file)-> console.log '+',path.relative(process.cwd(),file.path),pb(file.contents.length) if commander.verbose
    gulp= gulp.pipe concat basename
    gulp= gulp.pipe Gulp.dest dirname
    gulp.on 'end',->
      console.log '' if commander.verbose
      console.log '=',filename,pb(fs.statSync(filename).size)
      process.exit() if commander.uglifyjs is undefined

      exec= require('child_process').exec
      execName= "node "+ path.resolve require.resolve('uglify-js'),'../../bin/uglifyjs'
      execFilename= path.resolve process.cwd(),filename
      execFilenameMin= path.resolve process.cwd(),filenameMin
      
      execScript= "#{execName} #{execFilename}"
      execScript+= " -o #{execFilenameMin}"
      execScript+= " -m" if commander.mangle
      execScript+= " --source-map #{execFilenameMin}.map" if commander.sourcemap
      execScript+= " --source-map-url #{path.basename execFilenameMin}.map" if commander.sourcemap
      exec execScript,(stderr)->
        throw stderr if stderr?

        to= '='
        to= '≒' if commander.mangle
        console.log to,filenameMin,pb(fs.statSync(filenameMin).size)
        console.log to,filenameMin+'.map',pb(fs.statSync(filenameMin+'.map').size) if commander.sourcemap
        process.exit()

module.exports= mainBowerOnefile