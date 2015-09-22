# ![onefile][.svg] Onefile [![NPM version][npm-image]][npm] [![Build Status][travis-image]][travis]

> bower_components compressor

## Installation
```bash
$ npm install onefile --global
```

# Usage

## `onefile --output pkgs`

Combile the [main property file of dependencies](https://github.com/ck86/main-bower-files#usage) to `pkgs.js` using `./bower.json`

```bash
$ bower init
# ...
$ bower install c3-angular --save
# ...
$ onefile --output pkgs
# Found:
#    966.35 kB bower_components/angular/angular.js
#    334.22 kB bower_components/d3/d3.js
#      3.94 kB bower_components/c3/c3.css.js
#    296.62 kB bower_components/c3/c3.js
#     40.85 kB bower_components/c3-angular/c3js-directive.js
# Yield:
#      1.64 MB pkgs.js
```

Can use dependency files quickly.

## Other options
See also `onefile --help`

## Support

Ignore except for the following files

* `.js`
* `.css` [(convert url() to datauri, and convert it to js.)](https://github.com/59naga/gulp-jsfy#how-do-transform-to-js-)

# API

## onefile(options) -> gulpTask

```bash
npm install bower --global # optional

npm init --yes
npm install onefile --save

node task.js
# !function(e,t){"object"==typeof module&&"object"==typeof module.exports?module.exports=e.document?t(e,!0):function(e){if(!e.document)throw new Error("jQuery requires a window with a document");return ...
```

`task.js`

```js
// Dependencies
var onefile= require('onefile');

var fs= require('fs');
var childProcess= require('child_process');

// Onefile settings
var options= {
  // in-out directory
  cwd: process.cwd(),

  // add summry comment
  summary: true,

  // write inline-sourcemap
  sourcemap: true,
  
  // compress output
  mangle: true,

  // export inline-sourcemap to `outputName.map`
  detachSourcemap: false,

  // output Found / Yield to console.log
  outputBytes: false,

  // rename for file(gulp-util.File instance)
  outputName: 'pkgs.js',
  };

// Install bower_components
fs.writeFileSync('bower.json',JSON.stringify({name:'pkgs'}));
childProcess.spawnSync('bower',['install','jquery','--save']);

// Execute gulp task
var task= onefile(options);
task.on('data',function(file){
  console.log(file.contents.toString());
});
task.on('end',function(){
  process.exit(0);
});
```

# Related projects
* __onefile__
* [express-onefile](https://github.com/59naga/express-onefile/)
* [difficult-http-server](https://github.com/59naga/difficult-http-server)

License
=========================
[MIT][license]

[.svg]: https://cdn.rawgit.com/59naga/onefile/master/.svg

[license]: http://59naga.mit-license.org/
[npm-image]: https://badge.fury.io/js/onefile.svg
[npm]: https://npmjs.org/package/onefile
[travis-image]: https://travis-ci.org/59naga/onefile.svg?branch=master
[travis]: https://travis-ci.org/59naga/onefile
[coveralls-image]: https://coveralls.io/repos/59naga/onefile/badge.svg?branch=master
[coveralls]: https://coveralls.io/r/59naga/onefile?branch=master
