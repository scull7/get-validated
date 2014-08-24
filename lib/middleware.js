/*global require,module*/
var getter      = require( __dirname + '/getter' ),
    handler     = require( __dirname + '/handler'),
    validator   = require( 'validator' )
;
module.exports  = function (validations, options) {
  options = options || {};

  var container = options.container || {},
      handler   = options.validationAction || handler
  ;
  options.container.helpers = options.containers.helpers || validator;

  function Middleware(req, res, next) {
    container.validations       = validations;
    container.validationAction  = handler(options.container, req);

    req.getValidated  = getter.bind(getter, container, req);

    return next();
  }
  return Middleware;
};