module.exports = class FunctionInfo
  constructor: (@fn) ->

  argumentNames : =>
    firstLine = @fn.toString().split("\n")[0]
    argFinder= /(?:\(|\, )(\w+)/g
    args = []
    while (arg = argFinder.exec(firstLine))
      args.push(arg[1])
    args

