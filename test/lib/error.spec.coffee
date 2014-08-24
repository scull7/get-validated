AssertionError  = require 'assertion-error'
ValidationError = require process.env.PWD + '/lib/error'

describe 'Validation Error', ->

  it 'should be a function', ->
    ValidationError.should.be.a 'function'

  it 'should be an instance of AssertionError', ->
    test  = new ValidationError 'test'
    test.should.be.an.instanceOf AssertionError

  it 'should have a status code of 412', ->
    test  = new ValidationError 'test'
    test.status.should.equal 412