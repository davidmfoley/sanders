module.exports = class Container
  constructor: ->
    @typeMap = {}

  register : (args...) =>
    if typeof args[1] is 'object'
      @typeMap[args[0].toLowerCase()] =
        instance : args[1]
      return

    dependencies = []
    if typeof args[0] is 'function'
      constructor = args[0]
      name = constructor.name
      dependencies = args[1..]
    else
      name = args[0]
      constructor = args[1]
      dependencies = args[2..]

    unless dependencies.length > 0
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
