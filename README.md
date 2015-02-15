# mainBowerOnefile [![NPM version][npm-image]][npm]
## Install
```bash
$ npm install main-bower-onefile -g
```

## onefile
```bash
$ cd /path/to/bower-json-directory
$ bower install
$ onefile bower_components.js
# compiled bower_components.js
```

## help
```bash
$ onefile

  Usage: onefile name[.js] [options...]

  Options:

    -h, --help       output usage information
    -j, --json       Use [./bower.json]
    -d, --directory  Use [./bower_components]
    -r, --rc         Use [./.bowerrc]
    -u, --uglifyjs   Use UglifyJS2 (Experimental)
```

# License
MIT by [@59naga](https://twitter.com/horse_n_deer)

[npm-image]: https://badge.fury.io/js/main-bower-onefile.svg
[npm]: https://npmjs.org/package/main-bower-onefile
[travis-image]: https://travis-ci.org/59naga/main-bower-onefile.svg?branch=master
[travis]: https://travis-ci.org/59naga/main-bower-onefile
[depstat-image]: https://gemnasium.com/59naga/main-bower-onefile.svg
[depstat]: https://gemnasium.com/59naga/main-bower-onefile