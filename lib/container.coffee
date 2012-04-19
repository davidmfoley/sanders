DependencyChain = require './dependency_chain'

module.exports = class Container
  constructor: ->
    @map = new TypeMap

  register : (args...) =>
    if typeof args[1] is 'object'
      @map.addRegistration(args[0], {instance : args[1]})
    else if typeof args[0] is 'function'
      @addConstructorRegistration(args[0].name, args[0], args[1..])
    else
      @addConstructorRegistration(args[0], args[1], args[2..])

  get : (thingToGet, chain = new DependencyChain()) ->
    if typeof thingToGet is 'function'
      unless @map.hasRegistration(thingToGet.name)
        @register(thingToGet)
      name = thingToGet.name
    else
      name = thingToGet

    info = @map.getRegistration(name)
    @checkForMissingRegistration(name, info, chain)

    info.instance ?= @buildInstance(name, info, chain)

  buildInstance: (name, info, chain) ->
    @checkForCircularDependency(name, chain)
    deps = (@get(dep, chain.concat(name)) for dep in info.dependencies)

    new info.ctor(deps...)

  addConstructorRegistration: (name, constructor, dependencies) ->
    unless dependencies && (dependencies.length > 0)
      dependencies = new FunctionInfo(constructor).argumentNames()

    @map.addRegistration name,
      ctor: constructor
      dependencies : dependencies ? []

  checkForMissingRegistration: (name, info, chain) ->
    unless info
      @throwWithDependencyChain "No registration for '#{name}'", chain.concat(name)

  checkForCircularDependency: (name, chain) ->
    chain = chain.concat name

    return unless chain.circular()

    @throwWithDependencyChain "Circular dependency detected", chain

  throwWithDependencyChain: (error, chain) ->
    message = chain.printable()
    throw "#{error}:\n#{message}"

  printChain: (chain) ->
    message = chain[0]
    for step in chain[1..]
      message = message + " -> #{step}"
    message

class FunctionInfo
  constructor: (@fn) ->

  argumentNames : =>
    firstLine = @fn.toString().split("\n")[0]
    argFinder= /(?:\(|\, )(\w+)/g
    args = []
    while (arg = argFinder.exec(firstLine))
      args.push(arg[1])
    args

class TypeMap
  constructor: ->
    @typeMap = {}

  hasRegistration: (name) ->
    !!@typeMap[name.toLowerCase()]

  getRegistration: (name) ->
    @typeMap[name.toLowerCase()]

  addRegistration: (name, props) ->
    @typeMap[name.toLowerCase()] = props

