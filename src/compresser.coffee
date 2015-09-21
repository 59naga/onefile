# Dependencies
bytes= require './bytes'

through2= require 'through2'
uglifyjs= require 'uglify-js'
plugins= (require 'gulp-load-plugins')()

# Public
compresser= ({cwd,mangle,detachSourcemap,outputBytes}={})->
  # Defaults
  cwd?= process.cwd()
  outputBytes?= no

  mangle?= false
  detachSourcemap?= false

  # Pulgin
  through2.obj (file,enc,next)->
    if mangle
      source= file.contents.toString()
      mangleOptions=
        mangle: yes
        compress: yes
        fromString: yes

      if detachSourcemap
        sourceMapRegexp= /\/\/# sourceMappingURL=data:application\/json;base64,.+$/g
        sourceMapInline= (source.match sourceMapRegexp)?[0].split(',')[1]
        sourceMap= JSON.parse (new Buffer(sourceMapInline,'base64')).toString()
        mangleOptions.inSourceMap= sourceMap
        mangleOptions.outSourceMap= file.path+'.map'

    if mangle
      mangled= uglifyjs.minify source,mangleOptions

      file.contents= new Buffer mangled.code
      if mangled.map
        map= new plugins.util.File
          path: file.path+'.map'
          contents: new Buffer mangled.map

    @push file
    @push map if map

    if outputBytes
      console.log 'Yield:'
      console.log '  ',bytes file,process.cwd()
      console.log '  ',bytes map,process.cwd() if map

    next()

module.exports= compresser
