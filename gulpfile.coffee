gulp= require 'gulp'
gulp.task 'default',->
  gulp.watch '*.coffee',['bin']
  gulp.start 'bin'

spawn= null
gulp.task 'bin',->
  Spawn= require('child_process').spawn
  spawn.kill() if spawn isnt null

  npm= 'build-min'
  scripts= require('./package.json').scripts
  [command,args...]= scripts[npm].split /\s+/
  spawn= Spawn command,args,stdio:'inherit'