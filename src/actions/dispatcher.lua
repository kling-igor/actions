local Dispatcher = {}
Dispatcher.__index = Dispatcher
setmetatable(Dispatcher, Dispatcher)
---------------------------------------------------------------------------------------------------
function Dispatcher.__call()
	local dispatcher = {tasks = {task},
						newTasks = {},
						isRunning = false}
					 
	return setmetatable(dispatcher, {__index = Dispatcher})
end
---------------------------------------------------------------------------------------------------
function Dispatcher.__index(t, k)
	return nil
end
---------------------------------------------------------------------------------------------------
function Dispatcher:update(dt)
	self.isRunning = true
	
	if not self.shouldClear then
		for _,task in ipairs(self.tasks) do
			if not task.isFinished then
				task:update(dt)
				
				if self.shouldClear then
					break
				end
			end
		end
	end
	
	if self.shouldClear then
		for i = 1,#self.tasks do
			self.tasks[i] = nil
		end
		
		for i,task in ipairs(self.newTasks) do
			self.tasks[#self.tasks + 1] = task
			self.newTasks[i] = nil
		end
		
		self.shouldClear = false
	end	

	self.isRunning = false
end
---------------------------------------------------------------------------------------------------
function Dispatcher:addTask(task)
	if self.shouldClear then
		self.newTasks[#self.newTasks + 1] = task	
	else
		self.tasks[#self.tasks + 1] = task
	end
end
---------------------------------------------------------------------------------------------------
function Dispatcher:clear()
	if self.isRunning then
		self.shouldClear = true
	else
		for i = 1,#self.tasks do
			self.tasks[i] = nil
		end
	end
end
---------------------------------------------------------------------------------------------------
return Dispatcher