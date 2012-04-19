DependencyChain = require '../lib/dependency_chain'
describe 'DependencyChain', ->
  chain = null
  beforeEach ->
    chain = new DependencyChain()
  describe 'with one item', ->
    beforeEach ->
      chain = chain.concat('foo')

    it 'is printable', ->
      chain.printable().should == 'foo'

    it 'is not circular', ->
      chain.circular().should == false

  describe 'with two items', ->
    beforeEach ->
      chain = chain.concat('foo').concat('bar')

    it 'is printable', ->
      chain.printable().should == 'foo -> bar'

    it 'is not circular', ->
      chain.circular().should == false

  describe 'with a circular dependency', ->
    beforeEach ->
      chain = chain.concat('foo').concat('bar').concat('baz').concat('foo')

    it 'is printable', ->
      chain.printable().should == 'foo -> bar -> baz -> foo'

    it 'is circular', ->
      chain.circular().should == true
