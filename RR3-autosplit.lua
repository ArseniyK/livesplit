-- RR3 (SNES) autosplitter for LiveSplit
-- Based on https://github.com/trysdyn/bizhawk-speedrun-lua
-- Arseniy Krasnov, 2018 
-- Requires LiveSplit 1.7+  BizHawk-1.13.2

last_race_end = 0
started = false

local function init_livesplit()
	pipe_handle = io.open('//./pipe/LiveSplit', 'a+')
	
    if not pipe_handle then
        error("\nFailed1 to open LiveSplit named pipe!\n")
    end
    
    pipe_handle:write("reset\r\n")
    pipe_handle:flush()

    return pipe_handle
end


local function check_race_end()
    local race_end = memory.read_s16_be(0x0988)
	
    if last_race_end == race_end then
        return
    end

    last_race_end = race_end
	
    if race_end == 1 then
        pipe_handle:write("split\r\n")
        pipe_handle:write("pause\r\n")
        pipe_handle:flush()
    end
	
	if race_end == 0 then
        pipe_handle:write("resume\r\n")
        pipe_handle:flush()
    end
end

local function check_start()
    local this_time = memory.read_u16_be(0x095D)
	
    if this_time ~= 0 then
		started = true
        return true
    end

    return false
end

memory.usememorydomain("68K RAM")
pipe_handle = init_livesplit()

while true do
    if not started and check_start() then
        pipe_handle:write("start\r\n")
        pipe_handle:flush()
    end
	
    check_race_end()
    emu.frameadvance()
end
