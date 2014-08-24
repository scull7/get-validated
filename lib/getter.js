var Promise         = require('bluebird'),
    isArray         = require('util').isArray,
    ValidationError = require( __dirname + '/error' )
;

// `parseParams`
// -------------
// A function that ensures that the incoming parameters
// are given as an array or string.  If a string is
// given then the string is turned into an array with
// one item.
// @param {Array|string} params
// @return {Array.<string>}
// @api {private}
function parseParams (params) {
  if (typeof params === 'string') {
    if (params.length < 1) {
      throw new RangeError("Params must not be an empty string");
    }
    params  = [params];

  } else if (!isArray(params)) {
    throw new TypeError("Params must be an array or string.");
  }

  if (params.length < 1) {
    throw new RangeError("Params must not be an empty array");
  }

  return params;
}

// `getter`
// --------
// Validate the requested parameters from the given request
// using the settings given within the set dependency container.
// @param {Object} container - a dependency container.
// @param {HTTPRequest} req
// @param {Array|string} params
// @return {Promise}
function getter(container, req, params) {
  var validateAction  = container.validateAction,
      validations     = container.validations,
      renderer        = container.renderer,
      promises        = {}
  ;
  parseParams(params).forEach(function (param) {
    var value       = req.param(param);
    promises[param] = validateAction(value, validations[param]);
  });

  return Promise.props(promises).then(function (results) {
    if(!results) {
      return {};
    }
    var values    = {},
        errors    = {},
        hasError  = false,
        param
    ;
    for (param in results) {
      if (!results.hasOwnProperty(param)) {
        var result = results[param];

        if (result.error) {
          errors[param] = renderer(param, result.value, result.error);
          hasError = true;
        }
        if (typeof result.value !== 'undefined') {
          values[param] = result.value;
        }
      }
    }

    if (hasError) {
      throw new ValidationError(errors);
    }
    return values;
  });
}
module.exports  = getter;