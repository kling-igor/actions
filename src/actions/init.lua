local ACTIONS_PATH = ACTIONS_PATH or ({...})[1]:gsub("[%.\\/]init$", "") .. '.'

return {
	Dispatcher = require(ACTIONS_PATH  .. "dispatcher"),
	Task = require(ACTIONS_PATH  .. "tasks")
}
