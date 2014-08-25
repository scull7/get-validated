http      = require 'http'
Promise   = require 'bluebird'
handler   = require __dirname + '/../../lib/handler'

describe 'get-validated Validate Handler', ->
  mockContainer = null
  mockReq       = null

  beforeEach ->
    mockContainer =
      test: sinon.stub()

    mockReq = {
      __proto__: http.IncomingMessage.prototype
    }
    mockReq.param = sinon.stub()

  it 'should be a function', ->
    handler.should.be.a 'function'

  it 'should throw a TypeError when the request object is invalid.', ->
    expect(handler).to.throw TypeError
    expect(handler).to.throw /`req` must be an instance of http.IncomingMessage/

    test = handler.bind(handler, {})
    expect(test).to.throw TypeError
    expect(test).to.throw /`req` must be an instance of http.IncomingMessage/

  it 'should return a function with an airity of 2', ->
    handler(mockReq).length.should.equal 2

  it 'should return a function that returns a promise', ->
    test = handler(mockReq)
    test('test').should.be.an.instanceOf Promise

  it 'should resolve with the given value if a handler is not provided', (done) ->
    test  = handler(mockReq, mockContainer)
    test('test').then (result) ->
      result.value.should.equal 'test'
      done()

  it 'should call the given handler with the parameter value', (done) ->
    test  = handler(mockReq, mockContainer)

    testHandler = (val, container, cb) ->
      val.should.equal 'testHandlerCall'
      container.req.should.equal mockReq
      container.test.should.be.a 'function'
      cb()

    test('testHandlerCall', testHandler).then (result) ->
      result.value.should.equal 'testHandlerCall'
      done()

  it 'should set the value to a sanitized value if passed', (done) ->
    test = handler(mockReq, mockContainer)

    testHandler = (val, lib, cb) ->
      cb(null, 'sanitized')

    test('testSanitized', testHandler).then (result) ->
      result.value.should.equal 'sanitized'
      done()

  it 'should set an error if an error is thrown in the handler', (done) ->
    test  = handler(mockReq, mockContainer)

    testHandler = (val, container, cb) ->
      throw new Error("Bad Things")

    test('testException', testHandler).then (result) ->
      result.value.should.equal 'testException'
      result.error.should.equal 'Bad Things'
      done()

  it 'should call toString on an error object that does not have a message property', (done) ->
    test = handler(mockReq, mockContainer)

    testHandler = (val, container, cb) ->
      throw new Error()

    test('testExceptionNoMessage', testHandler).then (result) ->
      result.value.should.equal 'testExceptionNoMessage'
      result.error.should.equal 'Error'
      done()