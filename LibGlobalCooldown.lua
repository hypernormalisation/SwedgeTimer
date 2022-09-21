local MAJOR_VERSION = "LibGlobalCooldown"
local MINOR_VERSION = 1

local lib = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then
    return
end

local CreateFrame = CreateFrame
local C_Timer = C_Timer
local GetSpellCooldown = GetSpellCooldown
local GetTime = GetTime

lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib)
lib.GCD_OVER = "GCD_OVER"
lib.GCD_STARTED = "GCD_STARTED"

lib.in_combat = false

lib.gcd_lock = false
lib.gcd_duration = nil
lib.gcd_started = nil
lib.gcd_expires = nil

function lib:release_gcd_lock()
	self.gcd_lock = false
    self.gcd_duration = nil
	self.gcd_started = nil
    self:Fire(self.GCD_OVER)
end

function lib:Fire(event, ...)
	self.callbacks:Fire(event, ...)
end

function lib:poll_gcd()
    if self.gcd_lock then
        return
    end
    local time_started, duration_reported = GetSpellCooldown(29515)
    if duration_reported == 0 then
        return
    end
	local t = GetTime()
	self.gcd_lock = true
    local duration_actual = duration_reported - (t - time_started)
    local expires = t + duration_actual
    self.gcd_duration = duration_actual
	self.gcd_started = t
	self.gcd_expires = expires
    self:Fire(self.GCD_STARTED, duration_actual, expires)
	C_Timer.After(self.gcd_duration, function() self:release_gcd_lock() end)
end

function lib:SPELL_UPDATE_COOLDOWN()
    self:poll_gcd()
end

function lib:PLAYER_REGEN_DISABLED()
    self.in_combat = true
end

function lib:PLAYER_REGEN_ENABLED()
    self.in_combat = false
end

function lib:activate()
    if not self.frame then
        local frame = CreateFrame("Frame")
        self.frame = frame
        frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    end
    self.frame:SetScript("OnEvent", function(_, event, ...)
            lib[event](lib, event, ...)
        end
    )
end

lib:activate()