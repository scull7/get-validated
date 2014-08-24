/*global require,module*/
var getter      = require( __dirname + '/getter' ),
    handler     = require( __dirname + '/handler'),
    renderer    = require( __dirname + '/renderer'),
    validator   = require( 'validator' )
;
module.exports  = function (validations, options) {
  options = options || {};

  var container         = options.container || {},
      message_renderer  = options.renderer || renderer,
      action            = options.validateAction || handler,
      action_container  = container
  ;
  action_container.helpers  = container.helpers || validator;

  function Middleware(req, res, next) {
    container.validations     = validations;
    container.validateAction  = action(req, action_container);
    container.renderer        = message_renderer;

    req.getValidated  = getter.bind(getter, container, req);

    return next();
  }
  return Middleware;
};