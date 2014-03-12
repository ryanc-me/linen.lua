local path_to_lume = "lume"	-- replace with absolute
local path_to_lurker = "lurker" -- path to lume/lurker

if tostring(...) == "Channel" then
	-- thread block

	require("love.timer")
	require("love.filesystem")
	lume = require(path_to_lume)
	lurker = require(path_to_lurker)

	local time = love.timer.getTime
	local sleep = love.timer.sleep

	local channel 	= ...				-- linen.channel
	local directory = channel:demand()	-- dir (from linin.lua)
	local interval 	= channel:demand()	-- lurker.interval
	local lasttime	= 0
	local changes	= nil

	lurker.print("Linen thread initialized")

	-- enter the check loop
	while true do
		
		changes = lurker.getchanged()	-- check for file changes

		if #changes > 0 then
			-- wait for the channel to acknowledge that we've found a change
			channel:supply(true)
			changes = nil
		end
		
		if (type(channel:peek()) == "number") then
			interval = channel:pop()
		end
		
		sleep(interval)
	end
else
	-- main init
	
	-- grab the path to this file, relative to main lua
	local pos = string.find(...,  "linen", 0)
	local dir = (...):sub(0, pos - 1):gsub("\\", "/"):gsub("(%a)%.(%a-)", "%1/%2")

	local linen = {}

	linen._version = "1.0.1"
	linen.compat = true
	linen.dir = dir.."/linen.lua"

	function linen.init()
		assert(lurker, "lurker must be required BEFORE linen")
		assert(lurker._version == linen._version or linen.compat, "version mismatch between lurker and linen. the latest files can be found at github.com/rxi/lurker and github.com/mginshe/linen respectively")

		-- initialize and start the thread
		linen.thread = love.thread.newThread(dir.."/linen.lua")
		linen.channel = love.thread.getChannel("__LINEN_THREAD__")

		-- start the thread and push init data (see "thread block")
		linen.thread:start(linen.channel)		-- linen.channel
		linen.channel:push(linen.dir)			-- dir (from linen.lua)
		linen.channel:push(lurker.interval)		-- lurker.interval

		lurker.update = linen.update	-- overwrite lurker's update function
	end

	function linen.update(dt)
		if lurker.state == "init" then
    		lurker.exitinitstate()
  		end	

  		-- check the thread for changes
		if linen.channel:peek() == true then
			linen.channel:pop()

			-- run the hotswap code
			local changed = lurker.scan()
			if #changed > 0 and lurker.lasterrorfile then
				local f = lurker.lasterrorfile
				lurker.lasterrorfile = nil
				lurker.hotswapfile(f)
			end
		end
	end

	function linen.setInterval(i)
		lurker.interval = i or lurker.interval

		linen.channel:push(lurker.interval)
	end
	
	return linen.init()
end
