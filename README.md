# ![onefile][.svg] Onefile [![NPM version][npm-image]][npm] [![Build Status][travis-image]][travis] [![Coverage Status][coveralls-image]][coveralls]

> Quick browser package installer using bower.

## Installation
```bash
$ npm install onefile --global
```

# Usage

## `onefile pkg[, pkg...] --save`

Install and Combile the entry points to `pkgs.js` And write to `bower.json`

```bash
$ onefile c3 lodash --save

# Execute: bower install c3 lodash ...
#  >  cached git://github.com/masayuki0812/c3.git#0.4.10
#  >  validate 0.4.10 against git://github.com/masayuki0812/c3.git#*
#  >  cached git://github.com/lodash/lodash.git#3.9.3
#  >  validate 3.9.3 against git://github.com/lodash/lodash.git#*
#
# Combile: d3#3.5.0 c3#0.4.10 lodash#3.9.3 ...
#  +   334.22 kB (cache)/bower_components/d3/d3.js
#  +     3.94 kB (cache)/bower_components/c3/c3.css.js
#  +   296.62 kB (cache)/bower_components/c3/c3.js
#  +   408.14 kB (cache)/bower_components/lodash/lodash.js
#
# Result:
#  =     1.04 MB pkgs.js
# 
# Save:
# <  dependencies d3#3.5.0
# <  dependencies c3#0.4.10
# <  dependencies lodash#3.9.3
```

## `onefile -j`

Combine packages using `bower.json`

```bash
$ onefile -j
# Execute: bower install  ...
#
# Combile: d3#3.5.0 c3#0.4.10 lodash#3.9.3 ...
#  +   334.22 kB (cache)/bower_components/d3/d3.js
#  +     3.94 kB (cache)/bower_components/c3/c3.css.js
#  +   296.62 kB (cache)/bower_components/c3/c3.js
#  +   408.14 kB (cache)/bower_components/lodash/lodash.js
#
# Result:
#  =     1.04 MB pkgs.js
```

## `onefile -j -cms`

Compess and Mangle the packages using [UglifyJS2](https://github.com/mishoo/UglifyJS2) after combine.
and Generate a source map of the previous compression js using the `-s` option.

```bash
# > onefile -j -cms
# 
# Execute: bower install  ...
# 
# Combile: d3#3.5.0 c3#0.4.10 lodash#3.9.3 ...
#  +   334.22 kB (cache)/bower_components/d3/d3.js
#  +     3.94 kB (cache)/bower_components/c3/c3.css.js
#  +   296.62 kB (cache)/bower_components/c3/c3.js
#  +   408.14 kB (cache)/bower_components/lodash/lodash.js
# 
# Result:
#  =     1.04 MB pkgs.js
#  ≠      353 kB pkgs.min.js
#  ≠   592.94 kB pkgs.min.js.map
```

## Other options

```bash
# $ onefile --help
#
#   Usage: onefile [options] [command]
# 
# 
#   Commands:
# 
#     clean [options]   Remove onefile cache directory
# 
#   Options:
# 
#     -h, --help             output usage information
#     -V, --version          output the version number
#     -c, --compress         Use UglifyJS2, <pkgs>.js compression ≒ <pkgs>.min.js
#     -m, --mangle           Use UglifyJS2, <pkgs>.js mangling ≠ <pkgs>.min.js
#     -s, --sourcemap        Use UglifyJS2, Output sourcemap ≒ <pkgs>.min.js.map
#     -o, --output <name>    Output endpoints = <pkgs>.js
#     -j, --json [filename]  Use [./bower.json].
#     -S, --save             Save dependencies to ./bower.json file.
#     -D, --save-dev         Save devDependencies to ./bower.json file.
#     -d, --development      Include devDependencies by Use ./bower.json file.
```

## Support

Ignore except for the following files

* `.js`
* `.css`

# Note

## `Unable to find suitable version`
Try: Cleaning cache `onefile clean` command.

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