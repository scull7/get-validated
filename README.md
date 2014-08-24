[![Build Status](https://travis-ci.org/scull7/get-validated.svg)](https://travis-ci.org/scull7/get-validated)
[![Coverage Status](https://coveralls.io/repos/scull7/get-validated/badge.png)](https://coveralls.io/r/scull7/get-validated)
[![Code Climate](https://codeclimate.com/github/scull7/get-validated/badges/gpa.svg)](https://codeclimate.com/github/scull7/get-validated)

get-validated
=============

A simple, flexible validation middleware to make validation less painful

What is it?
-----------
get-validated is not a validation framework. Rather, it is a simple express
middleware that allows you to integrate many validation frameworks into your
express app in a consistent manner.

It comes with the [validator](https://github.com/chriso/validator.js) framework
built in.

Usage
-----

```javascript
var express = require('express'),
    router  = express.Router(),
    get_validated = require('get-validated')
;

router.use(get_validated({
  'param1': function (value, container, done) {
      // perform validation here.
      // `value` will be the return from req.param('param1')
      // `container` will be whatever is passed to `get_validated`
      //          `options` parameter as the `options.container` object
      //          It will also have a `helpers` object that will have
      //          the [`validator`](https://github.com/chriso/validator.js)
      //          framework attached.
      if (!container.helpers.isInt(value)) {
        return done(":name must be an integer, ':value' given");
      }
      if (value < 123) {
        return done(":name must be greater than 123, ':value' given");
      }
      
      return done(null, container.helpers.toInt(value));
  },
  'param2': function (value, container, done) {
      // you will have access to the current request via
      // `container.req`
      // You can do async things!
      req.db.query('SELECT * FROM something where id = ?', [value],
        function (err, rows) {
          // ... do some validation here...
          return done(':name value of :value could not be found!');
      }
  }
});

router.route('/').post(function (req, res, next) {
  req.getValidated(['param1','param2']).then(function (validated) {
      //do something with the parameters.
      console.log("Param1 = %s", validated.param1);
      console.log("Param2 = %s", validated.param2);
  // if you catch the error in this way a 412 error will be propagated
  // to the client.
  }).catch(next);
});

```

options
-------

* `container` - This is your integration point.  Anything you attach here will be
            sent along to your validation functions as the `container` object. 
* `validateAction` - Don't like my validation handling function? Then write your own.
            Debugging is your responsibility.
* `renderer` - `get-validate` comes with a very simple message renderer that recognizes
            two tags (':name' and ':value'), provide your own function if you like.

todo
----
* Make the handler catch errors from those frameworks that throw errors.
* route specific middleware
* more usage examples showing how to use the joi and composed-validations
