var main= require('path').basename(__filename,'.js');

require('coffee-script/register');
module.exports= require('./'+main+'.coffee');