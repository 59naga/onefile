# Dependencies
onefile= require '../src'

path= require 'path'
fs= require 'fs'
exec= (require 'child_process').exec

# Environment
jasmine.DEFAULT_TIMEOUT_INTERVAL= 100000
bowerJson= path.join __dirname,'bower.json'
execOptions= {cwd:__dirname}

# execute onefile after bower install
$bowerInstall= (packages='',callback)->
  fs.writeFileSync bowerJson,JSON.stringify {name:'onefile_fixture'}
  script= 'bower install '+packages+' --save'

  exec script,execOptions,callback

# Specs
describe 'onefile',->
  afterAll (done)->
    exec 'rm *.js *.map *.json',execOptions,done

  describe 'options',(done)->
    beforeAll (done)->
      $bowerInstall 'bootstrap#3.3.5',done

    assumedMaximam= 861809
    summaries= [
      /kB bower_components\/jquery\/dist\/jquery.js/
      /kB bower_components\/bootstrap\/dist\/js\/bootstrap.js/
      /kB pkgs.js/
    ]
    sourcemap= /# sourceMappingURL=data:application\/json;base64/

    describe 'default',->
      it 'packages + summary + sourcemap',(done)->
        options=
          cwd: __dirname

        files= []
        onefile options
        .on 'data',(file)-> files.push file
        .on 'end',->
          file= files[0]
          expect(files.length).toBe 1
          expect(file.path).toBe 'pkgs.js'
          expect(file.contents.length).toBe assumedMaximam

          chunk= file.contents.toString().slice(0,200)
          expect(chunk).toMatch summaries[0]
          expect(chunk).toMatch summaries[1]
          expect(chunk).toMatch summaries[2]

          chunk= file.contents.toString().slice(150000)
          expect(chunk).toMatch sourcemap
          
          done()

      it 'without summary + sourcemap',(done)->
        options=
          cwd: __dirname
          summary: no
          sourcemap: no

        files= []
        onefile options
        .on 'data',(file)-> files.push file
        .on 'end',->
          file= files[0]
          expect(files.length).toBe 1
          expect(file.path).toBe 'pkgs.js'
          expect(file.contents.length).toBeLessThan assumedMaximam/2

          chunk= file.contents.toString().slice(0,200)
          expect(chunk).not.toMatch summaries[0]
          expect(chunk).not.toMatch summaries[1]
          expect(chunk).not.toMatch summaries[2]
          
          chunk= file.contents.toString().slice(150000)
          expect(chunk).not.toMatch sourcemap

          done()

    it 'rename to foo',(done)->
      options=
        cwd: __dirname
        outputName: 'foo'

      files= []
      onefile options
      .on 'data',(file)-> files.push file
      .on 'end',->
        file= files[0]
        expect(files.length).toBe 1
        expect(file.path).toBe 'foo.js'
        expect(file.contents.length).toBeLessThan assumedMaximam

        done()

    it 'mangle',(done)->
      options=
        cwd: __dirname
        mangle: yes

      files= []
      onefile options
      .on 'data',(file)-> files.push file
      .on 'end',->
        file= files[0]
        expect(files.length).toBe 1
        expect(file.path).toBe 'pkgs.js'
        expect(file.contents.length).toBeLessThan assumedMaximam/5

        done()

    it 'mangle after sourcemap detaching',(done)->
      options=
        cwd: __dirname
        mangle: yes
        detachSourcemap: yes

      files= []
      onefile options
      .on 'data',(file)-> files.push file
      .on 'end',->
        file= files[0]
        expect(files.length).toBe 2
        expect(file.path).toBe 'pkgs.js'
        expect(file.contents.length).toBeLessThan assumedMaximam/5

        file= files[1]
        expect(file.path).toBe 'pkgs.js.map'

        map= JSON.parse file.contents.toString()
        expect(map.version).toBe 3
        expect(map.file).toBe 'pkgs.js'
        # expect(map.sources).toEqual ['experimental']

        done()

  describe 'Transfrom error check',->
    it '$ bower install c3-angular --save && onefile',(done)->
      $bowerInstall 'c3-angular',->
        onefile {cwd:__dirname}
        .on 'data',(file)->
          expect(file.contents.length).toBeGreaterThan 1000000

        .on 'end',done

    it '$ bower install slick-carousel --save && onefile',(done)->
      $bowerInstall 'slick-carousel',->
        onefile {cwd:__dirname}
        .on 'data',(file)->
          expect(file.contents.length).toBeGreaterThan 200000

        .on 'end',done
