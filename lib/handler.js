var Promise = require('bluebird');

// `ValidateFactory
// ================
// A factory function that generates the validation handler
// method that is used to validate each parameter.
// @param {Object} container - a dependency container object.
// @param {HTTPRequest} req
// @return {function}
// @api {public}
module.exports  = function ValidateFactory(container, req) {

  function validate (value, handler) {

    var promise = new Promise(function (resolve) {
      if(typeof handler !== 'function') {
        return resolve({ value: value });
      }

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
}