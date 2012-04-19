module.exports = class Container
  constructor: ->
    @typeMap = {}

  register : (args...) =>
    if typeof args[1] is 'object'
      @addRegistration(args[0], {instance : args[1]})
    else if typeof args[0] is 'function'
      @addConstructorRegistration(args[0].name, args[0], args[1..])
    else
      @addConstructorRegistration(args[0], args[1], args[2..])


  addConstructorRegistration: (name, constructor, dependencies) ->
    unless dependencies && (dependencies.length > 0)
      dependencies = @determineDependencies(constructor)

    @addRegistration name,
      ctor: constructor
      dependencies : dependencies ? []

  determineDependencies: (constructor) ->
    firstLine = constructor.toString().split("\n")[0]
    argFinder= /(?:\(|\, )(\w+)/g
    args = []
    while (arg = argFinder.exec(firstLine))
      args.push(arg[1])
    args

  addRegistration: (name, props) ->
    @typeMap[name.toLowerCase()] = props

  getRegistration: (name) ->
    @typeMap[name.toLowerCase()]

  get : (name, chain = [])->
    if typeof name is 'function'
      unless @typeMap[name.name.toLowerCase()]
        @register(name)
      name = name.name

    info = @getRegistration(name)
    @checkForMissingRegistration(name, info, chain)

    unless info.instance
      @checkForCircularDependency(name, chain)
      deps = (@get(dep, chain.concat([name])) for dep in info.dependencies)
      info.instance = new info.ctor(deps...)
    info.instance

  checkForMissingRegistration: (name, info, chain) ->
    unless info
      message = @printChain(chain.concat([name]))
      throw "No registration for '#{name}'\n#{message}"

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
