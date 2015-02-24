# mainBowerOnefile [![NPM version][npm-image]][npm] [![Build Status][travis-image]][travis]

## Installation
```bash
$ npm install main-bower-onefile -g
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
* -v, --verbose
  * Output filenames into onefile
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

[1]: https://github.com/mishoo/UglifyJS2
[2]: https://github.com/ck86/main-bower-files
[3]: https://github.com/59naga/gulp-jsfy

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
# + bower_components/animate.css/animate.css
# = packages.js
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

# License
MIT by [@59naga](https://twitter.com/horse_n_deer)

[npm-image]: https://badge.fury.io/js/main-bower-onefile.svg
[npm]: https://npmjs.org/package/main-bower-onefile
[travis-image]: https://travis-ci.org/59naga/main-bower-onefile.svg?branch=master
[travis]: https://travis-ci.org/59naga/main-bower-onefile
[depstat-image]: https://gemnasium.com/59naga/main-bower-onefile.svg
[depstat]: https://gemnasium.com/59naga/main-bower-onefile
