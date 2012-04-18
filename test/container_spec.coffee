Container = require '../lib/container'
describe 'Container', ->
  container = null

  beforeEach ->
    container = new Container

  it 'can construct an object with no dependencies', ->
    container.register('DeepThought', DeepThought)
    container.get('DeepThought').answer.should.equal(42)

  it 'can create an object with a dependency', ->
    container.register('DeepThought', DeepThought)
    container.register('Arthur', Arthur, 'DeepThought')
    container.get('Arthur').deepThought.answer.should.equal(42)

  describe 'detecting unknown types', ->
    it 'throws a descriptive error when asked for an unknown type by name', ->
      container.register('DeepThought', DeepThought)
      try
        container.get('Zaphod')
      catch error
        caught = error

      caught.should.match(/No registration for \'Zaphod\'/)

    it 'detects secondary dependencies and prints an informative message', ->
      container.register('Arthur', Arthur, 'DeepThought')
      try
        container.get('Arthur')
      catch error
        caught = error

      caught.should.match(/No registration for \'DeepThought\'/)
      caught.should.match(/Arthur \-\> DeepThought/i)

  it 'only creates a single instance of each class', ->
    container.register('DeepThought', DeepThought)
    container.register('Arthur', Arthur, 'DeepThought')
    deepThought = container.get('DeepThought')
    container.get('Arthur').deepThought.should.equal(deepThought)

  it 'detects circular dependencies and throws an informative error', ->
    caught = null
    container.register('LeftHead', Head, 'RightHead')
    container.register('RightHead', Head, 'LeftHead')
    container.register('Zaphod', Zaphod, 'LeftHead', 'RightHead')

    try
      container.get('Zaphod')
    catch error
      caught = error

    caught.should.match(/Circular dependency/)
    caught.should.match(/Zaphod \-\> LeftHead \-\> RightHead/i)

  describe 'registering without magic strings', ->
    beforeEach ->
      container.register(DeepThought)
      container.register(Arthur, 'DeepThought')

    it 'can register constructor functions directly (without explicit naming)', ->
      deepThought = container.get('DeepThought')
      arthur = container.get('Arthur')
      arthur.deepThought.should.equal(deepThought)

    it 'can get instances by function', ->
      deepThought = container.get(DeepThought)
      arthur = container.get(Arthur)
      arthur.deepThought.should.equal(deepThought)

  it 'can infer constructor arguments from the argument names', ->
    container.register(Arthur)
    container.register(DeepThought)
    deepThought = container.get(DeepThought)
    arthur = container.get(Arthur)
    arthur.deepThought.should.equal(deepThought)

  it 'can get an instance from an unregistered ctor if dependencies are known', ->
    container.register(DeepThought)
    deepThought = container.get(DeepThought)
    arthur = container.get(Arthur)
    arthur.deepThought.should.equal(deepThought)

  it 'can register an instance', ->
    container.register('DeepThought', {answer : 77})
    arthur = container.get(Arthur)
    arthur.deepThought.answer.should.equal(77)

class Zaphod
  constructor: (@leftHead, @rightHead) ->

class Head
  constructor: (@otherHead) ->

class DeepThought
  answer: 42

class Arthur
  constructor : (@deepThought) ->
