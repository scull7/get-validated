var AssertionError  = require('assertion-error')
;
function ValidationError () {

  // Using status code of 412 here to indicate that a request (header)
  // precondition has failed.  I feel this is the most appropriate
  // status code when referring to request parameter validation.
  // @see http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
  this.status = 412;

  var args = Array.prototype.slice.call(arguments, 0);
  AssertionError.apply(this, args);
}
// Inherit prototype
ValidationError.prototype = Object.create(AssertionError.prototype);

// Set the proper name.
ValidationError.prototype.name  = 'ValidationError';

// Ensure we have our proper constructor
ValidationError.prototype.constructor = ValidationError;

module.exports  = ValidationError;