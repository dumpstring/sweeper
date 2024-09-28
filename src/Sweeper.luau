--!strict

--[=[
	@class Sweeper
	by dumpstring

	Sweeper is a strictly typed utility class designed to manage various types of tasks, including 
	connections, instances, closures, and threads. It provides methods for adding tasks, 
	removing them, and cleaning them when requested.

	### Task Management
	Sweeper can handle four types of tasks:
	- **RBXScriptConnection**: Connections with `Disconnect` methods. Supports custom Connections from other modules.
	- **Destroyable**: Objects with `Destroy` methods. (Instances, etc.)
	- **Closure**: Functions that can be called.
	- **Thread**: Lua threads that can be closed.

	Tasks are assigned unique IDs when added to the Sweeper. These IDs can be used 
	to remove or sweep specific tasks, or you can sweep all tasks at once.
]=]

local SweeperClass = {}
SweeperClass.__index = SweeperClass

type Connection = {
	Disconnect: (self: Connection) -> (),
}

type Closure = () -> ()
type Destroyable = {
	Destroy: (self: Destroyable) -> (),
}
type Task = Connection | Destroyable | Closure | thread

type self = {
	Tasks: { string | number | Task },
	GiveTask: (self: SweeperClass, Task: Task) -> string,
	RemoveTask: (self: SweeperClass, TaskId: string) -> (),
	SweepTask: (self: SweeperClass, TaskId: string) -> (),
	Sweep: (self: SweeperClass) -> (),
	Destroy: (self: SweeperClass) -> (),
}

export type SweeperClass = typeof(setmetatable({} :: self, SweeperClass))

local Sweeper = {}

local taskIdCounter = 0

local function generateTaskId(): string
	taskIdCounter += 1
	local timestamp = os.time()
	return string.format("TASK-%d-%d", timestamp, taskIdCounter)
end

function Sweeper.new(): SweeperClass
	local self = setmetatable(
		{
			Tasks = {},
		} :: self,
		SweeperClass
	)

	return self
end

function SweeperClass:GiveTask(Task: Task): string
	local taskType: number

	if typeof(Task) == "RBXScriptConnection" then
		taskType = 1
	elseif typeof(Task) == "Instance" then
		taskType = 2
	elseif typeof(Task) == "function" then
		taskType = 3
	elseif type(Task) == "thread" then
		taskType = 4
	else
		local s1, r1 = pcall(function()
			return type(Task) == "table" and Task.Disconnect
		end)
		local s2, r2 = pcall(function()
			return type(Task) == "table" and Task.Destroy
		end)

		if s1 and r1 then
			taskType = 1
		elseif s2 and r2 then
			taskType = 2
		else
			error("Invalid task type")
		end
	end

	local taskId = generateTaskId()
	table.insert(self.Tasks, { taskId, taskType, Task }) -- I wish luau typechecking didnt produce these warnings.
	return taskId
end

function SweeperClass:RemoveTask(TaskId: string): ()
	for i, taskEntry in ipairs(self.Tasks) do
		if taskEntry[1] == TaskId then
			table.remove(self.Tasks, i)
			break
		end
	end
end

function SweeperClass:SweepTask(TaskId: string): ()
	for i, taskEntry in ipairs(self.Tasks) do
		if taskEntry[1] == TaskId then
			local taskType = taskEntry[2]
			local task = taskEntry[3]

			if taskType == 1 then
				local conn = task :: Connection
				conn:Disconnect()
			elseif taskType == 2 then
				local destroyable = task :: Destroyable
				destroyable:Destroy()
			elseif taskType == 3 then
				local closure = task :: Closure
				closure()
			elseif taskType == 4 then
				local threadTask = task :: thread
				coroutine.close(threadTask)
			end

			table.remove(self.Tasks, i)
			break
		end
	end
end

function SweeperClass:Sweep(): ()
	for i = #self.Tasks, 1, -1 do
		local taskEntry = self.Tasks[i]
		self:SweepTask(taskEntry[1])
	end
end

SweeperClass.Destroy = SweeperClass.Sweep

return Sweeper
