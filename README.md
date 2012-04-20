# Sanders

A simple [Inversion of Control](http://en.wikipedia.org/wiki/Inversion_of_control) container for node.js.

## What does it do?

Sanders builds object graphs that have dependencies, while hopefully staying out of your way as much as possible.

### Why would I want that?

Maybe you don't. If you are happy using ```require``` with file paths, feel free to keep doing that.

In working test-first on a socket application written in coffeescript for node, I have found that I prefer to invert the dependencies, so that each class takes everything it needs in its constructor, like so:

```coffee
class UserSocket
  constructor: (@websocketConnection, @userRegistry) ->

class UserRegistry
  constructor: (@database, @emailer): ->

class UserReport
  constructor: (@database): ->

class Database
  constructor: (@logger, @databaseConfig): ->

class Emailer
  constructor: (@logger, @emailConfig): ->

class ConsoleLogger

```

This makes it easy to test each component in isolation

Using a container  makes it easy to:
- construct this graph of objects at runtime
- plug in different implementations for different environments

For example, we probably only want to send actual email in production, so we would plug in a fake emailer that logs sent emails someplace so we could verify them.

The database configuration also would likely change depending on the environment.

This is how you might configure the above system in Sanders:
```coffee

container = new Container()

# you can register constructors
# by convention, the names of the argumentis to the constructor
# are used to determine the object to pass
container.register(Database)
container.register(UserRegistry)
container.register(UserSocket)

# you can register by name.
# these will be matched with constructor arguments with the same name
# (case-insensitive)
container.register('logger', ConsoleLogger)
container.register('websocketconnection', DebugWebSocketConnection)

# Perhaps you don't want to rely on the argument names,
# For example, you want to use a different connection for reports:
replicatedDatabaseConnection = new Database({server : 'some-other-server'})

# register the databse with a name
container.register('replicatedDatabase', replicatedDatabaseConnection)

# override the default, just for the user report
container.register(UserReport, 'replicatedDatabase')

# can also register objects directly
container.register('databaseConfig',{server: 'FOO", user: 'BAR', password : 'BAZ'})
container.register('emailConfig', {server: 'localhost", fromEmail: 'bar@example.com'})


```




## OK, I come from (Java/.NET) so I know what an IOC container is, how does Sanders compare to $OTHERCONTAINER?

Sanders builds only a single instance of each object. (There is no "lifetime" concept).
Each instance is cached for the lifetime of the container.

## Code, pleashe
```coffee
class CashRegister
  constructor: (
```
