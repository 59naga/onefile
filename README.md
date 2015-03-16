# ![onefile][.svg] Onefile [![NPM version][npm-image]][npm] [![Build Status][travis-image]][travis] [![Coverage Status][coveralls-image]][coveralls]

> Quick browser package installer.

# Requirement
 * [node.js][1]
 * Terminal / [cmder][2]

## Installation
```bash
$ npm install onefile --global
```

## Example
```bash
$ onefile bootstrap --save
# Generated > pkgs.js
# Generated > bower.json
```

### pkgs.js ?

is Concatenated js / css file.

```bash
# +   247.39 kB (cache)/bower_components/jquery/dist/jquery.js
# +    66.73 kB (cache)/bower_components/bootstrap/dist/js/bootstrap.js
# +   607.99 kB (cache)/bower_components/bootstrap/dist/css/bootstrap.css.js
```
#### bootstrap.css.js?

Transformed to datauri by css.

```javascript
(function(){
  var link=document.createElement('link');
  link.setAttribute('data-name','bootstrap');
  link.setAttribute('rel','stylesheet');
  link.setAttribute('href',"data:text/css;charset=utf8;base64,QGNoYXJzZXQgIlVU..."
  document.head.appendChild(link);
})();
```
### bower.json ?

Write to bower.json of current working directory.
If not exists then generate minimal bower.json:

```json
{
  "name": "undefined",
  "dependencies": {
    "bootstrap": "~3.3.2"
  }
}
```

If you want to use an existing bower.json, Execute the `onefile --json`.

# Usage
`$ onefile <endpoint>` by [`bower packages`][3]

## Options
### `-o`, `--output`
Set output `filename`. default: pkgs
### `-u`, `--uglifyjs`
Use [UglifyJS2][5], Export `name.min.js`
### `-s`, `--sourcemap`
Use [UglifyJS2][5], sourcemap, Export `name.min.js.map` 
### `-m`, `--mangle`
Use [UglifyJS2][5], Mangle names/pass

### `-j` `--json`
Use ./bower.json.
### `-S` `--save`
Save dependencies to ./bower.json file.
### `-D` `--save-dev`
Save devDependencies to ./bower.json file.
### `-p` `--production`
Ignore devDependencies by Use ./bower.json file.

## Support extension
* js
* css
  * Use [gulp-jsfy][4], Convert to standalone-css

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

[1]: http://nodejs.org/
[2]: http://bliker.github.io/cmder/

[3]: http://bower.io/search/

[4]: https://github.com/59naga/gulp-jsfy
[5]: https://github.com/mishoo/UglifyJS2#usage
