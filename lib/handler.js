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

      var handlerAsync  = Promise.promisify(handler);

      handlerAsync(value, container).then(function (sanitized) {
        if (typeof sanitized !== 'undefined') {
          value = sanitized;
        }
        return resolve({ value: value });

      }).catch(function (err) {
        return resolve({ value: value, error: err.message || err.toString() });
      });
    });

    return promise;
  }
  return validate;
};