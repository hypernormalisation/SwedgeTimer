local MAJOR_VERSION = "LibLatencyMonitor"
local MINOR_VERSION = 1.0

local lib = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then
    return
end

local CreateFrame = CreateFrame
local C_Timer = C_Timer
local GetTime = GetTime
local GetNetStats = GetNetStats
local type = type

lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib)
lib.LATENCY_CHANGED = "LATENCY_CHANGED"

lib.bandwidth_down_KBps = nil
lib.bandwidth_up_KBps = nil
lib.home_latency_ms = nil
lib.world_latency_ms = nil
lib.update_interval_s = 1

-- Once this is 
lib.time_since_last_update = nil


function lib:set_update_timestamp()
    -- First called when we detect a valid change in latency and
    -- know when the 30s update happens.
    lib.time_since_last_update = GetTime()
    -- print(lib.time_since_last_update)
    C_Timer.After(30, function() self:set_update_timestamp() end)
end


function lib:latency_checker()
    -- prevent duplicate events booking multiple C_Timers
    lib.is_registered = true

	local old_home = self.home_latency_ms
	local old_world = self.world_latency_ms
    local down, up, home, world = GetNetStats()
	self.bandwidth_down_KBps = down
    self.bandwidth_up_KBps = up
    self.home_latency_ms = home
    self.world_latency_ms = world
	
    if old_home ~= self.home_latency_ms or old_world ~= self.world_latency_ms then
        -- print('new latency')
        -- print('old_home says: '..tostring(old_home))
        -- print(old_home == nil)
        -- print(lib.time_since_last_update == nil)
        if lib.time_since_last_update == nil and not (old_home == nil) then
            -- We'll poll every 1s until we detect a change, then we know subsequent
            -- changes are on a 30s timer.
            -- We'll also book a C_Timer to timestamp the lag updates.
            -- print('found first indication of update time')
            self.update_interval_s = 30
            self:set_update_timestamp()
        end
        self.callbacks:Fire("LATENCY_CHANGED", home, world)
	end
	C_Timer.After(self.update_interval_s, function() self:latency_checker() end)
end

function lib:set_check_interval(interval)
    if type(interval) == "number" then
        self.update_interval_s = interval
    end
end

function lib:activate()
    if not self.frame then
        local frame = CreateFrame("Frame")
        self.frame = frame
        frame:RegisterEvent("PLAYER_LOGIN")
    end
    self.frame:SetScript("OnEvent", function()
            if not self.is_registered then
                self:latency_checker()
                self.is_registered = true
            end
        end
    )
end

lib:activate()
