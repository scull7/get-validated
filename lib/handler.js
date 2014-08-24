var Promise = require('bluebird'),
    message = require('http').IncomingMessage
;

// `ValidateFactory
// ================
// A factory function that generates the validation handler
// method that is used to validate each parameter.
// @param {Object} container - a dependency container object.
// @param {HTTPRequest} req
// @return {function}
// @api {public}
module.exports  = function ValidateFactory(req, container) {
  if(! (req instanceof message) ) {
    throw new TypeError("`req` must be an instance of http.IncomingMessage");
  }
  container = container || {};

  function validate (value, handler) {

    var promise = new Promise(function (resolve) {
      if(typeof handler !== 'function') {
        return resolve({ value: value });
      }

      // Set the request as a container item so that we
      // have access to it for multi parameter requests and
      // validations that require comparison with other request
      // parameters.
      container.req = req;

      handler(value, container, function (err, sanitized) {
        if (typeof sanitized !== 'undefined') {
          value = sanitized;
        }
        // We send the errors here because we want to make sure
        // that all validations are run.
        return resolve({ value: value, error: err });
      });
    });

    return promise;
  }
  return validate;
};