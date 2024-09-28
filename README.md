# Sweeper

by dumpstring

## Overview

`Sweeper` is a strictly typed utility class to manage tasks efficiently in Roblox. It supports the management of connections, instances, closures, and threads.

## Features

### Task Management

The `Sweeper` can sweep up to four types of tasks:

- **RBXScriptConnection**: Connections with a `Disconnect` method. At the same time, it provides support for user-defined connections from other modules.
- **Destroyable**: Objects which have a `Destroy` method. Examples include instances.
- **Closure**: Functions that can be called.
- **Thread**: Lua threads which can be closed.

Tasks added to the `Sweeper` are assigned an unique ID. These can be used to remove or sweep the task, or you can sweep all tasks of the `Sweeper`.
Installation
In order to use the `Sweeper` class within your project, require the module within your script, like so:

```lua
local Sweeper = require(path.to.Sweeper)
```

Usage
Creating a Sweeper Instance

You can create an instance of `Sweeper` like so:

```lua
local mySweeper = Sweeper.new()
```

### Adding Tasks

To assign a task, use the `GiveTask` method. It returns an identifier for the task:

```lua
local connection = myEvent:Connect(function() print("Event triggered!") end)
local taskId = mySweeper:GiveTask(connection)
```

### Removing Tasks

To remove a task, you can provide its identifier:

```lua
mySweeper:RemoveTask(taskId)

```

### Sweeping Tasks

You can sweep a provided task or all tasks using the `SweepTask` or `Sweep` respectively:

```lua
-- sweep a task
mySweeper:SweepTask(taskId)

-- sweep all tasks
mySweeper:Sweep()
```

### Destroying the Sweeper

When you're done with the `Sweeper`, you can call the `Destroy` method (which is an alias for `Sweep`) to clean up all tasks:

```lua
mySweeper:Destroy()
```

## Example

Here's a quick example showing the use of `Sweeper`:

```lua
local Sweeper = require(path.to.Sweeper)

local mySweeper = Sweeper.new()

local connection = someEvent:Connect(function() print("Event triggered!") end)
local taskId = mySweeper:GiveTask(connection)

-- later in the code
mySweeper:RemoveTask(taskId)

-- or sweep all tasks
mySweeper:Sweep()
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
