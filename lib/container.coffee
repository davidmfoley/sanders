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

    if (dependencies.length == 0)
      dependencies = @determineDependencies(constructor)

    @typeMap[name.toLowerCase()] =
      ctor: constructor
      dependencies : dependencies ? []

  determineDependencies: (constructor) ->
    firstLine = constructor.toString().split("\n")[0]
    argFinder= /(?:\(|\, )(\w+)/g
    args = []
    while (arg = argFinder.exec(firstLine))
      args.push(arg[1])
    args

  get : (name, chain = [])->
    if typeof name is 'function'
      unless @typeMap[name.name.toLowerCase()]
        @register(name)
      name = name.name

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
