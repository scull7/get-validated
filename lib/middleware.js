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

  container.validations = validations;
  container.renderer    = message_renderer;

  function getterFactory (req) {
    container.validateAction  = action(req, action_container);
    return getter.bind(getter, container, req);
  }

  function validate(params) {
    if (params === '*') {
      params = Object.keys(validations);
    }

    return function (req, res, next) {
      getterFactory(req)(params).then(function (validated) {
        req.validated = validated;
        return next();
      }).catch(next);

    };
  }

  function Middleware(req, res, next) {
    req.getValidated  = getterFactory(req);
    return next();
  }
  Middleware.validate = validate;

  return Middleware;
};