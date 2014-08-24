Promise   = require 'bluebird'
handler   = require __dirname + '/../../lib/handler'

describe 'G4 Validate Handler', ->
  mockContainer = null
  mockReq       = null

  beforeEach ->
    mockContainer =
      test: sinon.stub()

    mockReq =
      param: sinon.stub()

  it 'should be a function', ->
    handler.should.be.a 'function'