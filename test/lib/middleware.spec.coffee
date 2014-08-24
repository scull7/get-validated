http        = require('http')
middleware  = require __dirname + '/../../lib/middleware'

describe 'get-validated middleware', ->
  mockReq = null

  beforeEach ->
    mockReq = {
      __proto__: http.IncomingMessage.prototype
      param: sinon.stub()
    }

  it 'should return a function with an arity of 3', ->
    test  = middleware({})
    test.should.be.a 'function'
    test.length.should.equal 3

  it 'should set the given config as the parameter validations', (done) ->
    validations = { 'test': 'test' }
    helpers     = {}
    options     = {
      validationAction: sinon.stub()
      container: {
        helpers: helpers
      }
    }
    test  = middleware(validations, options)

    test(mockReq, {}, ()->
      options.container.validations.should.equal validations
      done()
    )

  it 'should validate the requested parameters', (done) ->
    validations =
      'test': (value, container, done) ->
        v = container.helpers

        if not v.matches value, /[A-Za-z\s]*/
          return done ":name must only contain alpha characters"

        if not v.isLowercase value
          return done ":name must only contain lower case characters"

        return done null, v.trim(value)

      'notRun': (value, container, done) ->
        if not container.helpers.isNumeric value
          return done ":name must be a numeric value"

        return done null, container.helpers.toInt value

    test  = middleware(validations)

    mockReq.param.withArgs('test').returns ' this should pass '

    test(mockReq, {}, () ->
      mockReq.getValidated('test').then( (results) ->
        results.test.should.equal 'this should pass'
        done()
      ).catch (err) ->
        console.log err
        throw new Error 'should not get here'
    )

  it 'should throw an error when a parameter does not validate', (done) ->
    validations =
      'test': (value, container, done) ->
        v = container.helpers

        if not v.isAlpha value
          return done ":name must only contain alpha characters"

        if not v.isLowercase value
          return done ":name must only contain lower case characters"

        return done null, v.trim(value)

      'notRun': (value, container, done) ->
        if not container.helpers.isNumeric value
          return done ":name must be a numeric value"

        return done null, container.helpers.toInt value

    test  = middleware(validations)

    mockReq.param.withArgs('test').returns ' this should pass '

    test(mockReq, {}, () ->
      mockReq.getValidated('test').then( (results) ->
        console.log results
        throw new Error 'MW-test-invalid: should not get here'
      ).catch (err) ->
        err.message.test.should.equal "test must only contain alpha characters"
        err.status.should.equal 412
        done()
    )