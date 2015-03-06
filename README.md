# ![onefile][.svg] Onefile [![NPM version][npm-image]][npm] [![Build Status][travis-image]][travis] [![Coverage Status][coveralls-image]][coveralls]

> Quick browser package installer.

# Requirement
 * [node.js][1]
 * Terminal / [cmder][2]

## Installation
```bash
$ npm install onefile --global
```

# Usage
`$ onefile <endpoint>` by [`bower packages`][3]

* bootstrap
  ```bash
  onefile bootstrap

  #Execute: bower install bootstrap ...
  # >  not-cached git://github.com/twbs/bootstrap.git#*
  # >  resolve git://github.com/twbs/bootstrap.git#*
  # >  download https://github.com/twbs/bootstrap/archive/v3.3.2.tar.gz
  # >  extract archive.tar.gz
  # >  resolved git://github.com/twbs/bootstrap.git#3.3.2
  # >  install bootstrap#3.3.2
  #
  #Combile: jquery#2.1.3 bootstrap#3.3.2 ...
  # +   247.39 kB (cache)/bower_components/jquery/dist/jquery.js
  # +    66.73 kB (cache)/bower_components/bootstrap/dist/js/bootstrap.js
  # +   607.99 kB (cache)/bower_components/bootstrap/dist/css/bootstrap.css.js
  #
  #Result:
  # =   922.11 kB pkgs.js
  ```

* angular
  ```bash
  onefile angular angular-ui-router angular-animate animate.css

  # Execute: bower install angular angular-ui-router angular-animate animate.css ...
  #  >  not-cached git://github.com/daneden/animate.css.git#*
  #  >  resolve git://github.com/daneden/animate.css.git#*
  # ...
  #
  # Combile: angular#1.3.14 animate.css#3.2.3 angular-animate#1.3.14 angular-ui-router#0.2.13 ...
  #  +   954.54 kB (cache)/bower_components/angular/angular.js
  #  +   104.24 kB (cache)/bower_components/angular-animate/angular-animate.js
  #  +   156.74 kB (cache)/bower_components/angular-ui-router/release/angular-ui-router.js
  #  +   104.25 kB (cache)/bower_components/animate.css/animate.css.js
  #
  # Result:
  #  =     1.32 MB pkgs.js
  ```

Finally, Will read from the html.
```html
<script src="pkgs.js"></script>
```

## Options
### `-o`, `--output`
Set output `filename`. default: pkgs
### `-u`, `--uglifyjs`
Use [UglifyJS2][5], Export `name.min.js`
### `-s`, `--sourcemap`
Use [UglifyJS2][5], sourcemap, Export `name.min.js.map` 
### `-m`, `--mangle`
Use [UglifyJS2][5], Mangle names/pass

## Support extension
* js
* css
  * Use [gulp-jsfy][4], Convert to standalone-css

## `Unable to find suitable version`
Try: Cleaning cache `onefile clean` command.

## TODO
* __TEST__

License
=========================
MIT by 59naga

[.svg]: https://cdn.rawgit.com/59naga/onefile/master/.svg

[npm-image]: https://badge.fury.io/js/onefile.svg
[npm]: https://npmjs.org/package/onefile
[travis-image]: https://travis-ci.org/59naga/onefile.svg?branch=master
[travis]: https://travis-ci.org/59naga/onefile
[coveralls-image]: https://coveralls.io/repos/59naga/onefile/badge.svg?branch=master
[coveralls]: https://coveralls.io/r/59naga/onefile?branch=master

[1]: http://nodejs.org/
[2]: http://bliker.github.io/cmder/

[3]: http://bower.io/search/

[4]: https://github.com/59naga/gulp-jsfy
[5]: https://github.com/mishoo/UglifyJS2#usage
