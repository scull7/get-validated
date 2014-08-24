Promise   = require 'bluebird'
message   = require('http').IncomingMessage
getter    = require __dirname + '/../../lib/getter'
handler   = require __dirname + '/../../lib/handler'
renderer  = require __dirname + '/../../lib/renderer'

describe 'get-validated Validate Getter', ->
  mockReq = null
  mockContainer = null

  beforeEach ->
    mockReq = {
      __proto__: message.prototype
      param: sinon.stub()
    }

    mockContainer = {
      validateAction: (val) ->
        return new Promise (resolve) -> resolve({ value: val })
      validations: {}
      renderer: renderer
    }

  it 'should be a function with an arity of 3', ->
    getter.should.be.a 'function'
    getter.length.should.equal 3

  it 'should throw a TypeError if params is not an Array or string', ->
    test   = getter.bind(getter, mockContainer, mockReq)
    testObject  = test.bind(test, {})
    expect(testObject).to.throw TypeError

    testNumber  = test.bind(test, 1234)
    expect(testNumber).to.throw TypeError

    testRegExp  = test.bind(test, /yay!/)
    expect(testRegExp).to.throw TypeError

  it 'should throw a RangeError if an empty string is given', ->
    test    = getter.bind(getter, mockContainer, mockReq, '')
    expect(test).to.throw RangeError
    expect(test).to.throw /Params must not be an empty string/

  it 'should throw a RangeError if an empty array is given', ->
    test    = getter.bind(getter, mockContainer, mockReq, [])
    expect(test).to.throw RangeError
    expect(test).to.throw /Params must not be an empty array/

  it 'should return a promise', ->
    test    = getter(mockContainer, mockReq, ['test'])
    test.should.be.an.instanceOf Promise

  it 'should return the given list of value from the req object', (done) ->
    mockReq.param.withArgs('test').returns('Foo')
    mockReq.param.withArgs('Foo').returns('Bar')

    params = ['Foo', 'test']

    getter(mockContainer, mockReq, params).then (result) ->
      result.Foo.should.equal 'Bar'
      result.test.should.equal 'Foo'
      done()

  it 'should return an error if one of the given validations returns an error', (done) ->
    validations = {
      'test': (value, container, done) ->
        value.should.equal 'test.value.1'
        return done(null, value)

      'test2': (value, container, done) ->
        value.should.equal 'test.value.2'
        return done(':value for :name is not valid')

      'test3': (value, container, done) ->
        value.should.equal 'test.value.3'
        return done(null, value)
    }
    mockContainer.validations = validations
    mockContainer.validateAction = handler(mockReq)

    mockReq.param.withArgs('test').returns('test.value.1')
    mockReq.param.withArgs('test2').returns('test.value.2')
    mockReq.param.withArgs('test3').returns('test.value.3')

    params  = ['test', 'test2', 'test3']

    getter(mockContainer, mockReq, params).catch( (err) ->
      err.status.should.equal 412
      err.message.test2.should.equal "test.value.2 for test2 is not valid"
      done()
    )

  it 'should return the single value if a string is requested', (done) ->
    validations =
      'single': (value, container, done) ->
        value.should.equal 'single.value'
        return done(null, 'sanitized')

      'single_bad': (value, container, done) ->
        throw new Error 'Should not get here.'

    mockReq.param.withArgs('single').returns('single.value')

    mockContainer.validations = validations
    mockContainer.validateAction  = handler(mockReq)

    getter(mockContainer, mockReq, 'single').then (result) ->
      result.single.should.equal 'sanitized'
      done()

  it 'should return an empty object when no parameters are found', (done) ->
    mockReq.param.returns(undefined)
    mockContainer.validateAction  = handler(mockReq)

    getter(mockContainer, mockReq, ['test1', 'test2']).then (result) ->
      result.should.be.empty
      done()