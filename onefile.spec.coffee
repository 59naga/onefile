try
  bin= 'node '+require.resolve 'onefile/onefile'
catch notLink
  bin= 'node ./onefile'

gulpSrcFiles= require 'gulp-src-files'
jsons= gulpSrcFiles 'test/example*/bower.json'

path= require 'path'
fs= require 'fs'

bower= require 'gulp-bower'
gulp= require 'gulp'
for json in jsons
  cwd= path.dirname json

  do (bin,cwd)->
    describe bin,->
      describe 'Build',->
        beforeEach (done)->
          bower cwd:cwd,directory:"bower_components"
          .on 'data',-> null
          .on 'end',->

            done()

        it 'Build',(done)->
          execScript= bin
          execScript+= " #{cwd}/packages -usvD"
          execScript+= " -j #{cwd}/bower.json"
          execScript+= " -d #{cwd}/bower_components"
          console.log execScript
          require('child_process').exec execScript,(stderr,stdout)->
            throw stderr if stderr?
            console.log stdout

            sourcemap= fs.readFileSync "#{cwd}/packages.min.js.map"

            expect(sourcemap instanceof Buffer).toEqual(true)
            done()