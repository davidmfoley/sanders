module.exports = class Container
  constructor: ->
    @typeMap = {}

  register : (name, constructor, dependencies...) =>
    @typeMap[name.toLowerCase()] =
      ctor: constructor
      dependencies : dependencies ? []

  get : (name)->
    info = @typeMap[name.toLowerCase()]
    unless info.instance
      deps = (@get(dep) for dep in info.dependencies)
      info.instance = new info.ctor(deps...)
    info.instance
