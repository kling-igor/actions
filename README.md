# Actions

Actions is a supplementary Lua library which allows to change object properties over time.
There are limited properties to change but it is sufficient for basic needs. Inspired by [Cocos2d Actions](http://www.cocos2d-x.org/wiki/Actions).
Actions perform **tasks** execution. **Dispatcher** is a base object which manages **tasks**. **Tasks** are added to **dispatcher**. If being added one by one - they will be running simultaneously in one call (but in order they were added). It is possible to make **task sequences** to run them in one queue consecutively.

Actually it uses [tween](https://github.com/kikito/tween.lua) library under hood. All changes **linear** by default, but you can change behaviour on your own accordingly to [Easing Functions](https://github.com/kikito/tween.lua#easing-functions) by setting appropriate value as last parameter in **task** constructor.

Also there is amazing visualisation in [Tweening methods](http://vrld.github.io/hump/#hump.timer) section of another tweeinig Lua library.

## Example

```lua
-- base block for following examples

local Actions = require 'actions'

-- For shorten form if no one conflicts with existing names:
local Dispatcher = Actions.Dispatcher

local Call = Actions.Task.Call
local Wait = Actions.Task.Wait
local ChangeValue = Actions.Task.ChangeValue
local MoveXBy = Actions.Task.MoveXBy
local MoveYBy = Actions.Task.MoveYBy
local MoveXTo = Actions.Task.MoveXTo
local MoveYTo = Actions.Task.MoveYTo
local SpinBy = Actions.Task.SpinBy
local SpinTo = Actions.Task.SpinTo
local RepeatForever = Actions.Task.RepeatForever
local Repeat = Actions.Task.Repeat

-- it's your dummy object
local smartobject = {x = 0, y = 0, angle = 0, dispatcher = Dispatcher()}
```

You have to call `update` to propagate tasks execution in dispatcher queues.

	self.dispatcher:update(dt)

### Move to

```lua
local time = 2
-- change object`s 'x' value from current value to 100 in 2 seconds
smartobject.dispatcher:addTask(MoveXTo(time, 100, smartobject, 'inQuad'))
-- simultaneously change object`s 'y' value from current value to 100 in 2 seconds
smartobject.dispatcher:addTask(MoveYTo(time, 100, smartobject, 'outQuad'))
```

### Move by

```lua
local time = 2
smartobject.dispatcher:addTask(MoveXBy(time, 50, smartobject))
smartobject.dispatcher:addTask(MoveYBy(time, 50, smartobject))
```

### Spin to

```lua
local time = 2
smartobject.dispatcher:addTask(SpinTo(time, 360, smartobject))
```

### Spin by

```lua
local time = 2
smartobject.dispatcher:addTask(SpinBy(time, 180, smartobject))
```

### Wait

```lua
-- delays action execution propagate for 5 seconds (if time is measured in seconds)
-- this example is useless unless `Wait` is used in conjunction with other actions
smartobject.dispatcher:addTask(Wait(5))
```

### Call

```lua
smartobject.dispatcher:addTask(Call(print, "Hello"))
```

### ChangeValue

```lua
local something = 0
-- change `something` from 5 to 10 in 2 seconds (if time is measured in seconds)
smartobject.dispatcher:addTask(ChangeValue(2, 5, 10, function(value) something = value end))
```

### RepeatForever

```lua
smartobject.dispatcher:addTask(RepeatForever(Call(print, "FOREVER")))
```

### Repeat

```lua
local counter = 0
--repeat 2 times
smartobject.dispatcher:addTask(Repeat(Call(function() counter = counter + 1; print(counter); end), 2))
```

### Action sequences

You able to make task chains to perform consecutive execution in one queue

```lua
local sequence = Wait(5) + Call(print, 'Hello') + Wait(2) + Call(print, 'Bye!')
smartobject.dispatcher:addTask(RepeatForever(sequence))
```


## Installation

Just copy the `actions` directory from `src` wherever you want it. Then require it wherever you need it:

    local Actions = require 'actions'

## Specs

This project uses [busted](http://olivinelabs.com/busted/) for its specs. If you want to run the specs, you will have to install it first. Then just execute the following from the root folder:

    busted