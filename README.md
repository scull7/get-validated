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

All validation errors are combined and put into a single `ValidationError` object
with a status|code of 412.  And the `messages` property is set to an object keyed
by parameter name of the current errors.

Basic Usage
-----------
Initial set up for a our little example express app.

```javascript
var express = require('express'),
    router  = express.Router(),
    get_validated = require('get-validated'),
    validations
;
```

Once we have our express app all set then we create our 
validations object.

```javascript

validations = get_validated({
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
```

Now that we have our `validations` object we can use it in a few different
ways.  

1. Apply it to the route and then use `req.getValidated` within individual 
  route handlers.

```javascript
router.use(validations);

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

2. Use it as route specific middleware to validate parameters used by
  that route. ***Note:*** If you use this method then all errors are sent
  to `next(err)` to be handled by your app's current error handler.
  
```javascript

router.route('/').post([
  validations.validate(['param1', 'param2']),
  function (req, res) {
    //do something with the parameters.
    console.log("Param1 = %s", req.validated.param1);
    console.log("Param2 = %s", req.validated.param2);
  }
]);
```

Advanced Usage
--------------
Now one of the fun parts of this module is that you can integrate pretty much any validations framework that you want
with it.  Here is a list of some:

* [Composed Validations] (https://github.com/composed-validations/composed-validations)
* [Joi] (https://github.com/hapijs/joi)
* [validate-it] (https://github.com/vlkosinov/validate-it)

I'm going to use [Composed Validations] (https://github.com/composed-validations/composed-validations) here to show
how you integrate a validation libray, at least one way to do it.

In Composed Validations examples they show an address validator, so let's work with that.  

```javascript

var cv = require('composed-validations');

var addressValidator = cv.struct()
    .validate('street', cv.presence())
    .validate('zip', cv.format(/\d{5}/) // silly zip format
    .validate('city', cv.presence()
    .validate('state', cv.presence();
```

So now that we have our address validator we can integrate it directly into our validations object like so

```javascript
var options = {
    container: {
        'cv': cv,  // we don't have to integrate but just for fun we will.
        'addressValidator': addressValidator
    }
};

var validations = get_validated({
    'address': function (value, container, done) {
        // we're going to ignore the value here because we have a complex type,
        // but we'll get our reference to request to pull the values from there.
        var req = container.req;
        
        var address = {
            street: req.param('street'),
            zip: req.param('zip'),
            city: req.param('city'),
            state: req.param('state')
        };
        // and there we go, we don't have to worry about the error at this point
        // because the validation handler will receive the thrown execption and 
        // turn it into a ValidationError appropriately.
        container.addressValidator.test(address);
        
        //but we do have to send our fancy validated address down to the user function.
        return done(null, address);
    }
}, options);
```

After we have our validations object we can use it just like any other one.

```javascript
router.route('/').post([
    validations.validate('address'),
    function (req, res, next) {
        // And our address information will be conveniently placed into the validated object.
        console.log ("Address: %j", req.validated.address);
        // do other stuff...
    }
]);
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
* route specific middleware
* more usage examples showing how to use the joi and composed-validations
