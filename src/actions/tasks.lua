local tween = require 'tween.tween' 

local TaskSequence = {}
TaskSequence.__index = TaskSequence
---------------------------------------------------------------------------------------------------
function TaskSequence.new()
	local tasksequence =  {
			tasks = {},
			currentTaskId = 1,
			isFinished = false}
		
	return setmetatable(tasksequence, TaskSequence)
end
---------------------------------------------------------------------------------------------------
function TaskSequence:update(dt)
	if self.isFinished then return end
		
	local task = self.tasks[self.currentTaskId]
	task:update(dt)
	
	if task.isFinished then
		if self.currentTaskId < #self.tasks then
			self.currentTaskId = self.currentTaskId + 1
		else
			self.isFinished = true
		end
	end
end
---------------------------------------------------------------------------------------------------
function TaskSequence:addTask(task)
	self.tasks[#self.tasks + 1] = task
end

function TaskSequence:reset()
	self.isFinished = false
	self.currentTaskId = 1
	for _,task in ipairs(self.tasks) do
		task:reset()
	end
end
---------------------------------------------------------------------------------------------------

local Task_mt = {}

local function addTask(a, b)
	local a_mt = getmetatable(a)
	local b_mt = getmetatable(b)
	
	if a_mt == Task_mt and b_mt == Task_mt then
		local sequence = TaskSequence.new()
		sequence:addTask(a)
		sequence:addTask(b)
		return sequence
	elseif a_mt == TaskSequence and b_mt == Task_mt then
		a:addTask(b)
		return a
	elseif a_mt == Task_mt and b_mt == TaskSequence then
		b:addTask(a)
		return b
	else
		error('adding incompatible types')
	end
end

Task_mt.__add = addTask

local Task = {}
---------------------------------------------------------------------------------------------------
function Task.Call(func,...)
	local parameters = {...}
	local task = {
		isFinished = false,
		update = function(self, dt)
			func(unpack(parameters))
			self.isFinished = true
		end,
		reset = function(self)
			self.isFinished = false
		end
	}
	
	return setmetatable(task, Task_mt)
end
---------------------------------------------------------------------------------------------------
function Task.Wait(time)
	local task = {
		isFinished = false,
		current_time = 0,
		update = function(self, dt)
			self.current_time = self.current_time + dt
			if self.current_time >= time then
				self.isFinished = true
			end
		end,
		reset = function(self)
			self.isFinished = false
			self.current_time = 0
		end
	}
	return setmetatable(task, Task_mt)
end
---------------------------------------------------------------------------------------------------
function Task.ChangeValue(time,initialValue, finalValue, onchangeCallback, easing)
	local task = {
		isFinished = false,
		value = initialValue,
		update = function(self, dt)
			if self.isFinished then return end
			
			self.isFinished = self.tween:update(dt)
			
			onchangeCallback(self.value)
		end
	}
	
	task.tween = tween.new(time, task, {value = finalValue}, easing or 'linear')
	
	task.reset = function(self)
			self.isFinished = false
			self.value = initialValue
			self.tween = tween.new(time, task, {value = finalValue}, easing or 'linear')
		end
	
	return setmetatable(task, Task_mt)
end
---------------------------------------------------------------------------------------------------
function Task.MoveXBy(time,dx,object,easing)
	local current_x = object.x
	local task = {
		isFinished = false,
		update = function(self, dt)
			if not self.tween then
				self.tween = tween.new(time, object, {x = current_x + dx}, easing or 'linear')
			end
			self.isFinished = self.tween:update(dt)
		end,
		reset = function(self)
			self.isFinished = false
			self.tween = nil
		end
	}
	
	return setmetatable(task, Task_mt)
end
---------------------------------------------------------------------------------------------------
function Task.MoveYBy(time,dy,object,easing)
	local task = {
		isFinished = false,
		update = function(self, dt)
			if not self.tween then
				self.tween = tween.new(time, object, {y = object.y + dy}, easing or 'linear')
			end
			self.isFinished = self.tween:update(dt)
		end,
		reset = function(self)
			self.isFinished = false
			self.tween = nil
		end
	}
	
	return setmetatable(task, Task_mt)
end
---------------------------------------------------------------------------------------------------
function Task.MoveXTo(time,x,object,easing)
	local current_x = object.x
	local task = {
		isFinished = false,
		tween = tween.new(time, object, {x = x}, easing or 'linear'),
		update = function(self, dt)
			self.isFinished = self.tween:update(dt)
		end,
		reset = function(self)
			self.isFinished = false
			object.x = current_x
			self.tween = tween.new(time, object, {x = x}, easing or 'linear')
		end
	}
	
	return setmetatable(task, Task_mt)
end
---------------------------------------------------------------------------------------------------
function Task.MoveYTo(time,y,object,easing)
	local current_y = object.y
	local task = {
		isFinished = false,
		tween = tween.new(time, object, {y = y}, easing or 'linear'),
		update = function(self, dt)
			self.isFinished = self.tween:update(dt)
		end,
		reset = function(self)
			self.isFinished = false
			object.y = current_y
			self.tween = tween.new(time, object, {y = y}, easing or 'linear')
		end
	}
	
	return setmetatable(task, Task_mt)
end
---------------------------------------------------------------------------------------------------
function Task.SpinBy(time,angle,object,easing)
	local current_angle = object.angle
	local task = {
		isFinished = false,
		update = function(self, dt)
			if not self.tween then
				self.tween = tween.new(time, object, {angle = object.angle + angle}, easing or 'linear')
			end
			
			self.isFinished = self.tween:update(dt)
		end,
		reset = function(self)
			self.isFinished = false
			self.tween = nil
		end
	}
	
	return setmetatable(task, Task_mt)	
end
---------------------------------------------------------------------------------------------------
function Task.SpinTo(time,angle,object,easing)
	local current_angle = object.angle
	local task = {
		isFinished = false,
		tween = tween.new(time, object, {angle = angle}, easing or 'linear'),
		update = function(self, dt)
			self.isFinished = self.tween:update(dt)
		end,
		reset = function(self)
			self.isFinished = false
			object.angle = current_angle
			self.tween = tween.new(time, object, {angle = angle}, easing or 'linear')
		end
	}
	
	return setmetatable(task, Task_mt)	
end
---------------------------------------------------------------------------------------------------
function Task.RepeatForever(task)
	local forever_task = {isFinished = false,
			reset = function(self) end,
		    update = function(self, dt)
				task:update(dt)
				if task.isFinished then
					task:reset()
				end
		    end   
		}
		
	return setmetatable(forever_task, Task_mt)			
end
---------------------------------------------------------------------------------------------------
function Task.Repeat(task, times)
	
	local cycles = times and math.floor(math.abs(times)) or 1
	
	local repeat_task = {isFinished = false,
			times = cycles,
			reset = function(self)
				self.isFinished = false
				self.times = cycles
			end,
		    update = function(self, dt)
				if self.times == 0 then return end
					
				task:update(dt)
				if task.isFinished then
					self.times = self.times - 1
						
					if self.times > 0 then
						task:reset()
					else
						self.isFinished = true
					end
				end
		    end   
		}
		
	return setmetatable(repeat_task, Task_mt)				
end
---------------------------------------------------------------------------------------------------
return Task