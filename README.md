# ![onefile][.svg] Onefile [![NPM version][npm-image]][npm] [![Build Status][travis-image]][travis]

> bower main files compressor for js/css

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
