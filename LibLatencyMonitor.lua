local MAJOR_VERSION = "LibLatencyMonitor"
local MINOR_VERSION = 1.0

local lib = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then
    return
end

local CreateFrame = CreateFrame
local C_Timer = C_Timer
local GetNetStats = GetNetStats
local type = type

lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib)
lib.LATENCY_CHANGED = "LATENCY_CHANGED"

lib.bandwidth_down_KBps = 0
lib.bandwidth_up_KBps = 0
lib.home_latency_ms = 0
lib.world_latency_ms = 0
lib.update_interval_s = 5

function lib:latency_checker()
    lib.is_registered = true
	local old_home = self.home_latency_ms
	local old_world = self.world_latency_ms
    local down, up, home, world = GetNetStats()
	self.bandwidth_down_KBps = down
    self.bandwidth_up_KBps = up
    self.home_latency_ms = home
    self.world_latency_ms = world
    -- print('Latency says: ' ..tostring(self.world_latency_ms))
	if true then --  old_home ~= self.home_latency_ms or old_world ~= self.world_latency_ms then
        self.update_interval_s = 30 -- set this to 30 the first time we get an update
        print('firing event')
        self.callbacks:Fire("LATENCY_CHANGED", home, world)
	end
	C_Timer.After(self.update_interval_s, function() self:latency_checker() end)
end

function lib:set_check_interval(interval)
    if type(interval) == "number" then
        self.update_interval_s = interval
    end
end

-- function:update

function lib:update()
    -- Func to force an update to the endpoints.
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
