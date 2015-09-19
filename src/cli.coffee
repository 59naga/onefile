# Dependencies
onefile= require './onefile'

Command= (require 'commander').Command
gulp= require 'gulp'

packageVersion= (require '../package').version

# Public
class CLI extends Command
  constructor: ->
    super

    @option '-o, --output <file>.js','output to <file>'
    @option '-H, --no-header','remove summry comment'
    @option '-m, --mangle','mangling output'
    @version packageVersion

  parse: ->
    super

    outputName=
      if @output?
        outputName=
          if @output.slice(-3) isnt '.js'
            @output+'.js'
          else
            @output
      else
        'pkgs.js'

    options=
      outputName: outputName
      header: @header
      mangle: @mangle

    if @output
      options.outputBytes= yes
      
      bundle= []
      onefile options
      .pipe gulp.dest process.cwd()

    else
      onefile options
      .on 'data',(file)->
        process.stdout.write file.contents

module.exports= new CLI
