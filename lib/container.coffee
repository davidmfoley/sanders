module.exports = class Container
  constructor: ->
    @typeMap = {}

  register : (name, constructor, dependencies...) =>
    if typeof name is 'function'
      if constructor
        dependencies = [constructor].concat(dependencies ? [])
      else
        dependencies = []
      constructor = name
      name = constructor.name

    @typeMap[name.toLowerCase()] =
      ctor: constructor
      dependencies : dependencies ? []

  get : (name, chain = [])->
    info = @typeMap[name.toLowerCase()]
    unless info
      message = @printChain(chain.concat([name]))
      throw "No registration for '#{name}'\n#{message}"

    unless info.instance
      @checkForCircularDependency(name, chain)
      deps = (@get(dep, chain.concat([name])) for dep in info.dependencies)
      info.instance = new info.ctor(deps...)
    info.instance

  checkForCircularDependency: (name, chain) ->
    chainLower = (c.toLowerCase() for c in chain)

    if chainLower.indexOf(name.toLowerCase()) != -1
      chain.push(name)
      message = @printChain([name].concat(chain))
      throw "Circular dependency detected:\n#{message}"

  printChain: (chain) ->
    ch = chain.slice()
    message = ch.shift()
    for step in ch
      message = message + " -> #{step}"
    message
