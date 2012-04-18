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

class DeepThought
  answer: 42

class Arthur
  constructor : (@deepThought) ->
