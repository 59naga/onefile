onefile= require './onefile'
cli= require './cli'

module.exports= onefile
module.exports.parse= ->
  cli.parse arguments...
