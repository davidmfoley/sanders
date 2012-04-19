module.exports = class TypeMap
  constructor: ->
    @typeMap = {}

  hasRegistration: (name) ->
    !!@typeMap[name.toLowerCase()]

  getRegistration: (name) ->
    @typeMap[name.toLowerCase()]

  addRegistration: (name, props) ->
    @typeMap[name.toLowerCase()] = props

