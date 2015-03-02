var main= require('path').basename(__filename,'.pomace.js');

require('coffee-script/register');
module.exports= require('./'+main+'.coffee');