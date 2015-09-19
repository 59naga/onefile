# Dependencies
prettyBytes= require 'pretty-bytes'

fs= require 'fs'
path= require 'path'

module.exports= (file,cwd)->
  byte= ('       '+(prettyBytes file.contents.length)).slice(-10)
  filename= (path.relative cwd,file.path)

  '   '+byte+' '+filename
