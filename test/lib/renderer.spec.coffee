renderer  = require __dirname + '/../../lib/renderer'

describe 'get-validated Renderer', ->

  it 'should be a function an arity of 3', ->
    renderer.should.be.a 'function'
    renderer.length.should.equal 3

  it 'should replace any :name tag', ->
    test = renderer('test.name', 'test.value', 'This :name is a :name')
    test.should.equal 'This test.name is a test.name'

  it 'should replace any :value tag with the given value', ->
    test  = renderer('test.name', 'test.value', 'This :value is a :value')
    test.should.equal 'This test.value is a test.value'

  it 'should replace appropriately', ->
    test  = renderer('test.name', 'test.value', 'This :name is equal :value')
    test.should.equal 'This test.name is equal test.value'
