module.exports = class Container
  constructor: ->
    @typeMap = {}

  register : (name, constructor, dependencies...) =>
    @typeMap[name.toLowerCase()] =
      ctor: constructor
      dependencies : dependencies ? []

  get : (name, chain = [])->
    info = @typeMap[name.toLowerCase()]
    unless info
      throw "No registration for '#{name}'"

    unless info.instance
      @checkForCircularDependency(name, chain)
      deps = (@get(dep, chain.concat([name])) for dep in info.dependencies)
      info.instance = new info.ctor(deps...)
    info.instance

  checkForCircularDependency: (name, chain) ->
    chainLower = (c.toLowerCase() for c in chain)

    if chainLower.indexOf(name.toLowerCase()) != -1
      chain.push(name)
      message = @printChain(name, chain)
      throw "Circular dependency detected:\n#{message}"

  printChain: (name, chain) ->
    message = name
    for step in chain
      message = message + " -> #{step}"
    message
