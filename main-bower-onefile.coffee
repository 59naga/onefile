mainBowerOnefile=
  bin: ->
    commander= require 'commander'
    commander
      .usage 'name[.js] [options...]'
      .option '-j, --json'      ,'Use [./bower.json]'      ,'./bower.json'
      .option '-d, --directory' ,'Use [./bower_components]','./bower_components'
      .option '-r, --rc'        ,'Use [./.bowerrc]'        ,'./.bowerrc'

      .option '-u, --uglifyjs'  ,'Use UglifyJS2 (Experimental)'
      .parse process.argv
    commander.help() if commander.args.length is 0

    path= require 'path'
    filename= commander.args[0]
    filename+= '.js' if filename.match(/.js$/) is null
    dirname= path.dirname filename

    Gulp= require 'gulp'
    mainBowerFiles= require 'main-bower-files'
    jsfy= require 'gulp-jsfy'
    concat= require 'gulp-concat'

    gulp= Gulp.src mainBowerFiles
      paths:
        bowerJson: commander.json
        bowerDirectory: commander.directory
        bowerrc: commander.rc
    gulp= gulp.pipe jsfy dataurl:true
    gulp= gulp.pipe concat filename
    gulp= gulp.pipe Gulp.dest dirname
    gulp.on 'end',->
      if commander.uglifyjs
        filenameMin= filename.replace /.js$/,'.min.js'

        uglifyjs= path.resolve __dirname,'node_modules/.bin/uglifyjs'
        shell= "node #{uglifyjs} #{filename} > #{filenameMin}"

        exec= require('child_process').exec
        exec shell,(stderr)->
          throw stderr if stderr?
          
          console.log 'compiled',filenameMin
          process.exit()
        return

      console.log 'compiled',filename
      process.exit()

module.exports= mainBowerOnefile

###
                                  _____  _____
                                 /      /    /
                                /____  /____/
                                    /      /
                              _____/ _____/
                               
###