# ![onefile][.svg] Onefile [![NPM version][npm-image]][npm] [![Build Status][travis-image]][travis]

> Quick browser package installer using bower.

## Installation
```bash
$ npm install onefile --global
```

# Usage

## `onefile`

Combile the [main property file of dependencies](https://github.com/ck86/main-bower-files#usage) to `pkgs.js` using `./bower.json`

```bash
$ bower install c3-angular
# ...
$ onefile
# Found:
#    965.53 kB bower_components/angular/angular.js
#    334.22 kB bower_components/d3/d3.js
#      2.77 kB bower_components/c3/c3.css
#    296.62 kB bower_components/c3/c3.js
#     40.58 kB bower_components/c3-angular/c3js-directive.js
# Yield:
#      1.64 MB pkgs.js
```

## `onefile --mangle --soucemap`

Mangle the pkgs.js using [UglifyJS2](https://github.com/mishoo/UglifyJS2) after combine.
and Generate a source map of the previous compression js using the `-s` option.

```bash
$ onefile --mangle --soucemap
# Found:
#    965.53 kB bower_components/angular/angular.js
#    334.22 kB bower_components/d3/d3.js
#      2.77 kB bower_components/c3/c3.css
#    296.62 kB bower_components/c3/c3.js
#     40.58 kB bower_components/c3-angular/c3js-directive.js
# Yield:
#      1.64 MB pkgs.js
#    455.78 kB pkgs.min.js
#     754.8 kB pkgs.min.js.map
```

## Other options

```bash
$ onefile --help
#
#  Usage: onefile [options]
#
#  Options:
#
#    -h, --help              output usage information
#    -o, --output <pkgs>.js  Change the output filename
#    -m, --mangle            Mangle <pkgs>.js to <pkgs>.min.js
#    -s, --soucemap          Create soucemap to <pkgs>.min.js.map
#    -V, --version           output the version number
```

## Support

Ignore except for the following files

* `.js`
* `.css` [(convert url() to datauri, and convert it to js.)](https://github.com/59naga/gulp-jsfy#how-do-transform-to-js-)

License
=========================
[MIT][license] by 59naga

[.svg]: https://cdn.rawgit.com/59naga/onefile/master/.svg

[license]: http://59naga.mit-license.org/
[npm-image]: https://badge.fury.io/js/onefile.svg
[npm]: https://npmjs.org/package/onefile
[travis-image]: https://travis-ci.org/59naga/onefile.svg?branch=master
[travis]: https://travis-ci.org/59naga/onefile
[coveralls-image]: https://coveralls.io/repos/59naga/onefile/badge.svg?branch=master
[coveralls]: https://coveralls.io/r/59naga/onefile?branch=master