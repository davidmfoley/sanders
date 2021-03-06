DependencyChain = require './dependency_chain'
TypeMap = require './type_map'
FunctionInfo = require './function_info'

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
    return if info
    @throwWithDependencyChain "No registration for '#{name}'", chain.concat(name)

  checkForCircularDependency: (name, chain) ->
    chain = chain.concat name

    return unless chain.circular()

    @throwWithDependencyChain "Circular dependency detected", chain

  throwWithDependencyChain: (error, chain) ->
    message = chain.printable()
    throw "#{error}:\n#{message}"
