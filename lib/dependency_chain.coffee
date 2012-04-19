
module.exports = class DependencyChain
  constructor: (@items =[]) ->

  concat: (item) =>
    chain = new DependencyChain(@items.concat([item]))
    chainLower = (c.toLowerCase() for c in @items)

    for name in chainLower
      if chainLower.indexOf(item.toLowerCase()) != -1
        chain.isCircular = true
    chain

  circular:  =>
    !!@isCircular

  printable: =>
    message = @items[0] || ''
    for step in @items[1..]
      message = message + " -> #{step}"
    message

