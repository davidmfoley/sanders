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

  it 'throws a descriptive error when asked for an unknown type by name', ->
    container.register('DeepThought', DeepThought)
    try
      container.get('Zaphod')
    catch error
      caught = error

    caught.should.match(/No registration for \'Zaphod\'/)

  it 'only creates a single instance of each class', ->
    container.register('DeepThought', DeepThought)
    container.register('Arthur', Arthur, 'DeepThought')
    deepThought = container.get('DeepThought')
    container.get('Arthur').deepThought.should.equal(deepThought)


class DeepThought
  answer: 42

class Arthur
  constructor : (@deepThought) ->
