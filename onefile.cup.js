var onefile;
// Avoid conflicts with another version
if(typeof require('module')._extensions['.coffee']==='undefined'){
  require('coffee-script/register');
}
onefile= require('./onefile.coffee');

// d_| dripped

module.exports= onefile;