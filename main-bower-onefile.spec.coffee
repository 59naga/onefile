gulpSrcFiles= require 'gulp-src-files'
jsons= gulpSrcFiles 'test/example*/bower.json'

path= require 'path'
fs= require 'fs'

bower= require 'gulp-bower'
gulp= require 'gulp'
for json in jsons
  cwd= path.dirname json

  do (cwd)->
    describe 'Install and Build',->
      it 'Install',(done)->
        bower cwd:cwd,directory:"bower_components"
        .on 'data',-> null
        .on 'end',->

          done()

      it 'Build',(done)->
        execScript= "node ./bin/onefile"
        execScript+= " #{cwd}/bundle -usv"
        execScript+= " -j #{cwd}/bower.json"
        execScript+= " -d #{cwd}/bower_components"
        require('child_process').exec execScript,(stderr)->
          throw stderr if stderr?

          sourcemap= fs.readFileSync "#{cwd}/bundle.min.js.map"

          expect(sourcemap instanceof Buffer).toEqual(true)
          done()