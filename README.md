# swift-wren

A Swift package and wrapper for the [wren](https://wren.io) scripting language.
There is a good [QA](https://wren.io/qa.html) on wren. It's a very small embeddable
language similar to Lua, but w/o the weirdness.

This is not complete and we may not finish it. A major thing missing in wren is 
[reentrancy](https://github.com/wren-lang/wren/issues/487)
with the host environment.
Another issue is that host functions do not get any function environment,
i.e. no function specific userdata pointer, or other means which would allow
a trampoline.
PRs are still welcome, and we'll see where wren is going in the future.

This SwiftPM package embeds Wren itself, i.e. it contains the amalgation in a vendored
branch.


### What does it look like?

The example from the [QA](https://wren.io/qa.html):

```wren
class Account {
  construct new(balance) { _balance = balance }
  withdraw(amount) { _balance = _balance - amount }
}

var account = Account.new(1000)
account.withdraw(100)```
```

### What does the Swift Wrapper look like

Hello world:

```swift
let vm = WrenVM()
try vm.interpret(
  """
  System.print("I'm running in a VM!")
  """
)
```


### Links

- [wren](https://wren.io)
  - [QA](https://wren.io/qa.html)

### Who

**swift-wren** is brought to you by
the
[Always Right Institute](https://www.alwaysrightinstitute.com)
and
[ZeeZide](http://zeezide.de).
We like 
[feedback](https://twitter.com/ar_institute), 
GitHub stars, 
cool [contract work](http://zeezide.com/en/services/services.html),
presumably any form of praise you can think of.
