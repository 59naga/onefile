# Dependencies
onefile= require './onefile'

Command= (require 'commander').Command
gulp= require 'gulp'

packageVersion= (require '../package').version

# Public
class CLI extends Command
  constructor: ->
    super

    @version packageVersion
    @option '-m, --mangle','compress output'
    @option '-d, --detach','export inline-sourcemap to `<file>.js.map` via `--output`'
    @option '-o, --output <file>','output to <file>.js'
    @option '-S, --no-sourcemap','remove inline-sourcemap'
    @option '-H, --no-summary','remove summary comment'

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
      sourcemap: @sourcemap
      summary: @summary
      mangle: @mangle

    if @output
      options.outputBytes= yes
      options.detachSourcemap= @detach
      
      bundle= []
      onefile options
      .pipe gulp.dest process.cwd()

    # use stdout
    else
      onefile options
      .on 'data',(file)->
        process.stdout.write file.contents

module.exports= new CLI
