-- RR3 (SNES) autosplitter for LiveSplit
-- Based on https://github.com/trysdyn/bizhawk-speedrun-lua
-- Arseniy Krasnov, 2018 
-- Requires LiveSplit 1.7+  BizHawk-1.13.2

TIME_BASE = 0x74E0
RACE_END = 0x0988
PLACE = 0x05FE
SCORE_SCREEN_BASE = 0x0004
MAX_INT_16 = 0xFFFF
START_BASE = 0x095D


last_race_end = 0
started = false
timers = {}
last_is_score_screen = false
can_save_time = false

local function init_livesplit()
	pipe_handle = io.open('//./pipe/LiveSplit', 'a+')
	
    if not pipe_handle then
        error("\nFailed1 to open LiveSplit named pipe!\n")
    end
	print('reset')
    pipe_handle:write("reset\r\n")
    pipe_handle:flush()

    return pipe_handle
end


local function check_race_end()
    local race_end = memory.read_s16_be(RACE_END)
	
    if last_race_end == race_end then
        return
    end

    last_race_end = race_end
	
    if race_end == 1 then
		can_save_time = true
        pipe_handle:write("split\r\n")
        pipe_handle:write("pause\r\n")
        pipe_handle:flush()
    end
	
	if race_end == 0 then
        pipe_handle:write("resume\r\n")
        pipe_handle:flush()
    end
end

function ms_to_string(timer)
  local minutes = math.floor(timer/600)
  local seconds = math.floor(math.fmod(timer, 600)/10)
  local ms = math.floor(math.fmod(timer,10))
  return string.format("%02d:%02d.%d",minutes,seconds,ms)
end


local function save_timer()
	local place = memory.read_u16_be(PLACE)
	local time_offset = 4*(place-1)
	local timer = memory.read_u16_be(TIME_BASE+time_offset)
	table.insert(timers, ms_to_string(timer))
end

local function check_score_screen()
	local is_score_screen = memory.read_u16_be(SCORE_SCREEN_BASE) == MAX_INT_16 and can_save_time
	
	if last_is_score_screen == is_score_screen and not can_save_time then
		return
	end
	
	last_is_score_screen = is_score_screen
	
	if is_score_screen then
		save_timer()
		can_save_time = false
	end
end

local function check_start()
    local this_time = memory.read_u16_be(START_BASE)
	
    if this_time ~= 0 then
		started = true
        return true
    end

    return false
end

local function draw_timers()
	if not table.getn(timers) then
		return
	end
	
	for i, timer in ipairs(timers) do
	  gui.text(0, i*15, timer)
	end
end

memory.usememorydomain("68K RAM")
pipe_handle = init_livesplit()

while true do
    if not started and check_start() then
        pipe_handle:write("start\r\n")
        pipe_handle:flush()
    end
	
    check_race_end()
	check_score_screen()
	draw_timers()
    emu.frameadvance()
end
