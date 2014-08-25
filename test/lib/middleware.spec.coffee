http        = require('http')
middleware  = require __dirname + '/../../lib/middleware'

describe 'get-validated middleware', ->
  mockReq = null
  testMw  = null
  testValidations = null

  beforeEach ->
    mockReq = {
      __proto__: http.IncomingMessage.prototype
      param: sinon.stub()
    }

    testValidations =
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

    testMw  = middleware(testValidations)

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

  it 'should have a validate property that is a function with an arity of 1', ->
    testMw.validate.should.be.a 'function'
    testMw.validate.length.should.equal 1

  it 'should validate the requested params', (done) ->
    mockReq.param.withArgs('test').returns ' this should pass '

    test = testMw.validate('test')

    test(mockReq, {}, () ->
      mockReq.validated.test.should.equal 'this should pass'
      done()
    )

  it 'should validate all parameters if a "*" is passed', (done) ->
    mockReq.param.withArgs('test').returns ' you passed '
    mockReq.param.withArgs('notRun').returns '456'

    test = testMw.validate('*')

    test(mockReq, {}, () ->
      mockReq.validated.test.should.equal 'you passed'
      mockReq.validated.notRun.should.equal 456
      done()
    )

  it 'should send errors to next if exceptions are thrown', (done) ->
    validations =
      'test1': () -> throw new Error(":value for :name is not valid")
      'test2': () -> throw new Error("I am just picky")
      'test3': (a, b, cb) ->
          return cb ":name is a regular error for :value"

    mockReq.param.withArgs('test1').returns('123')
    mockReq.param.withArgs('test2').returns('456')
    mockReq.param.withArgs('test3').returns(undefined)

    test_mw = middleware(validations)
    test    = test_mw.validate(['test1','test2','test3'])

    test(mockReq, {}, (err) ->
      err.status.should.equal 412
      err.message.test1.should.equal '123 for test1 is not valid'
      err.message.test2.should.equal 'I am just picky'
      err.message.test3.should.equal 'test3 is a regular error for undefined'
      done()
    )
