Actions = require 'actions'

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

describe("Tasks", function()
	describe("Call", function()
		it("should call callee", function()
			
			local called = false
			
			local task = Call(function(parameter)
					called = parameter
				end, true)
			
			task:update(1)
			
			assert.True(called)
			
			assert.True(task.isFinished)
		end)
	end)

	describe("Wait", function()
		it("should not be completed till specified delay", function()
			
			local task = Wait(1)
			
			task:update(0.9)
			assert.False(task.isFinished)
			
			task:update(0.1)
			assert.True(task.isFinished)
		end)
	end)


	describe("ChangeValue", function()
		it("should change value accordingly to passed time", function()
			
			local value = 0
			local time = 1
			local task = ChangeValue(time, value, 10, function(val) value = val  end) -- linear easing by default
			
			task:update(time / 2)
			assert.equal(5, value)
			
			task:update(time / 2)
			assert.equal(10, value)
			
			assert.True(task.isFinished)
		end)
	end)

	describe("MoveXBy", function()
		it("should change object value accordingly to passed time", function()
			local object = {x = 5}
			local time = 1
			local task = MoveXBy(time, 10, object) -- linear easing by default
			
			task:update(time / 2)
			assert.equal(10, object.x)
			
			task:update(time / 2)
			assert.equal(15, object.x)
			
			assert.True(task.isFinished)
		end)
	end)

	describe("MoveYBy", function()
		it("should change object value accordingly to passed time", function()
			local object = {y = 5}
			local time = 1
			local task = MoveYBy(time, 10, object) -- linear easing by default
			
			task:update(time / 2)
			assert.equal(10, object.y)
			
			task:update(time / 2)
			assert.equal(15, object.y)
			
			assert.True(task.isFinished)
		end)
	end)

	describe("MoveXTo", function()
		it("should change object value accordingly to passed time", function()
			local object = {x = 0}
			local time = 1
			local task = MoveXTo(time, 10, object) -- linear easing by default
			
			task:update(time / 2)
			assert.equal(5, object.x)
			
			task:update(time / 2)
			assert.equal(10, object.x)
			
			assert.True(task.isFinished)
		end)
	end)

	describe("MoveYTo", function()
		it("should change object value accordingly to passed time", function()
			local object = {y = 0}
			local time = 1
			local task = MoveYTo(time, 10, object) -- linear easing by default
			
			task:update(time / 2)
			assert.equal(5, object.y)
			
			task:update(time / 2)
			assert.equal(10, object.y)
			
			assert.True(task.isFinished)
		end)
	end)

	describe("SpinTo", function()
		it("should change object value accordingly to passed time", function()
			local object = {angle = 0}
			local time = 1
			local task = SpinTo(time, 10, object) -- linear easing by default
			
			task:update(time / 2)
			assert.equal(5, object.angle)
			
			task:update(time / 2)
			assert.equal(10, object.angle)
			
			assert.True(task.isFinished)
		end)
	end)

	describe("SpinBy", function()
		it("should change object value accordingly to passed time", function()
			local object = {angle = 5}
			local time = 1
			local task = SpinBy(time, 10, object) -- linear easing by default
			
			task:update(time / 2)
			assert.equal(10, object.angle)
			
			task:update(time / 2)
			assert.equal(15, object.angle)
			
			assert.True(task.isFinished)
		end)
	end)

	describe("RepeatForever", function()
		it("should be neverending", function()
		
			local task = RepeatForever(Wait(1))
			task:update(1)
			
			assert.False(task.isFinished)
			
			task:update(10)
			assert.False(task.isFinished)
		end)
	end)

	describe("Repeat", function()
		it("should run exactly specified times", function()
			
			local loops = 2
			local actual_loops = 0
			local task = Repeat(Call(function() actual_loops = actual_loops + 1 end), loops)
			task:update(1)
			task:update(1)
			
			
			task:update(1)
				
			assert.True(task.isFinished)
			assert.equal(actual_loops, loops)
		end)
	end)
end)

describe("Dispatcher", function()
	describe("addTask", function()
		it("should run tasks in queue", function()
			local dispatcher = Dispatcher()
			local called = false
			
			dispatcher:addTask(Call(function() called = true end))
			
			dispatcher:update(1)
			
			assert.True(called)
		end)
	
		it("should run tasks in different queues simultaneously, but in order they've been added", function()
			local dispatcher = Dispatcher()
			local called_1 = 0
			local called_2 = 0
			
			dispatcher:addTask(Call(function() called_1 = 1 end))
			dispatcher:addTask(Call(function() called_2 = called_1 + 1 end))
			
			dispatcher:update(1)
			
			assert.equal(1, called_1)
			assert.equal(2, called_2)
		end)
	
		it("should run tasks consecutively if added as sequence", function()
			local dispatcher = Dispatcher()
			local called_1_1 = 0
			local called_1_2 = 0
			local called_2 = 0
			
			dispatcher:addTask(Call(function() called_1_1 = 1 end) + 
							    Call(function() called_1_2 = called_2 + 1 end))
			dispatcher:addTask(Call(function() called_2 = called_1_1 + 1 end))
			
			dispatcher:update(1)
			dispatcher:update(1)
			
			assert.equal(1, called_1_1)	-- 1-st update
			assert.equal(3, called_1_2)	-- 2-nd update
			assert.equal(2, called_2)		-- 1-st update
		end)
	
		it("should throw error if mixing task with incomaptible type", function()
			local nop = function() end
			assert.error(function() local seqience = Call(nop) + {}  end)
		end)
		
	end)
end)