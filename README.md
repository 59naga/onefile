# ![onefile](.png) Onefile [![NPM version][npm-image]][npm] [![Build Status][travis-image]][travis] [![Coverage Status][coveralls-image]][coveralls]

> Concat js and css by bower.json

## Installation
```bash
$ npm install onefile -g
```

## CLI
```bash
$ cd /path/to/bower-json-directory
$ bower install
$ onefile packages
# = packages.js
```

## CLI Options
`onefile name[.js] [options...]` Export `name.js`

* -u, --uglifyjs
  * Use [UglifyJS2][1], Export `name.min.js`
* -s, --sourcemap
  * Use [UglifyJS2][1], sourcemap, Export `name.min.js.map` 
* -m, --mangle
  * Use [UglifyJS2][1], Mangle names/pass
* -v, --verbose
  * Output filenames & bytes into onefile
* [main-bower-files][2] options
  * -j, --json &lt;path&gt;
    * Use &lt;bower.json&gt;
  * -d, --directory &lt;path&gt;
    * Use &lt;bower_components&gt;
  * -r, --rc &lt;path&gt;
    * Use &lt;.bowerrc&gt;
  * -D, --includeDev
    * Use devDependencies

## Support extension
* js
* css
  * Use [gulp-jsfy][3], Convert to standalone-css

### Example
bower.json
```json
{
  "name": "animate2js",
  "dependencies": {
    "animate.css": "~3.2.0"
  }
}
```

```bash
$ bower install
$ tree 
.
├── bower.json
└── bower_components
    └── animate.css
$ onefile packages -v
# + bower_components/animate.css/animate.css.js 97.48 kB
# = packages.js 97.48 kB
```

```
$ tree 
.
├── packages.js
├── bower.json
└── bower_components
    └── animate.css
```

packages.js
```js
(function(){
  var link=document.createElement('link');
  link.setAttribute('data-name','animate');
  link.setAttribute('rel','stylesheet');
  link.setAttribute('href',"data:text/css;charset=utf8;base64,QGNoYXJzZXQgIlVU..."
  document.head.appendChild(link);
})();
```

use packages.js
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <script src="packages.js"></script>
</head>
<body>
  <h1 class="animated bounce">Hi</h1>
</body>
</html>
```

## TODO
* API without CLI

# License
MIT by [@59naga](https://twitter.com/horse_n_deer)

[1]: https://github.com/mishoo/UglifyJS2
[2]: https://github.com/ck86/main-bower-files
[3]: https://github.com/59naga/gulp-jsfy

[npm-image]: https://badge.fury.io/js/onefile.svg
[npm]: https://npmjs.org/package/onefile
[travis-image]: https://travis-ci.org/59naga/onefile.svg?branch=master
[travis]: https://travis-ci.org/59naga/onefile
[coveralls-image]: https://coveralls.io/repos/59naga/jasminetea/badge.svg?branch=master
[coveralls]: https://coveralls.io/r/59naga/jasminetea?branch=master