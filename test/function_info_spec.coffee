FunctionInfo = require '../lib/function_info'
describe 'FunctionInfo', ->
  it 'handles functions with no arguments', ->
    new FunctionInfo(->).argumentNames().length.should.equal(0)
  it 'handles functions with arguments', ->
    args = new FunctionInfo((foo, bar)->).argumentNames()
    args.length.should.equal(2)
    args[0].should.equal('foo')
    args[1].should.equal('bar')
