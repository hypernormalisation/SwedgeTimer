------------------------------------------------------------------------------------
-- Main module for creating the addon with AceAddon
------------------------------------------------------------------------------------
local addon_name, st = ...
local ST = LibStub("AceAddon-3.0"):NewAddon(addon_name, "AceConsole-3.0", "AceEvent-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
local STL = LibStub("LibClassicSwingTimerAPI", true)
-- local print = st.utils.print_msg

local SwingTimerInfo = function(hand)
    return STL:SwingTimerInfo(hand)
end

ST.mainhand = {}
ST.offhand = {}
ST.ranged = {}

------------------------------------------------------------------------------------
-- The init/enable/disable
------------------------------------------------------------------------------------
function ST:OnInitialize()

	-- Addon database
	local SwedgeTimerDB = LibStub("AceDB-3.0"):New(addon_name.."DB", self.defaults, true)
	self.db = SwedgeTimerDB

	-- Options table
	local AC = LibStub("AceConfig-3.0")
	local ACD = LibStub("AceConfigDialog-3.0")
	AC:RegisterOptionsTable(addon_name.."_Options", self.options)
	self.optionsFrame = ACD:AddToBlizOptions(addon_name.."_Options", addon_name)
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	AC:RegisterOptionsTable(addon_name.."_Profiles", profiles)
	ACD:AddToBlizOptions(addon_name.."_Profiles", "Profiles", addon_name)

	-- Slashcommands
	self:register_slashcommands()



end

function ST:OnEnable()
	-- Sort out character information
	self.player_guid = UnitGUID("player")
	self.has_oh = false
	self.has_ranged = false
	self.mh_timer = 0
	self.oh_timer = 0
	self.ranged_timer = 0
	self:check_weapons()

	-- MH timer containers
	-- self.mh.last_swing = nil
	self.mainhand.start = nil
	self.mainhand.speed = nil
	self.mainhand.ends_at = nil
	self.mainhand.inactive_timer = nil
	self.mainhand.frame = CreateFrame("Frame", addon_name .. "MHBarFrame", UIParent)

	-- OH containers
	self.offhand.start = nil
	self.offhand.speed = nil
	self.offhand.ends_at = nil
	self.offhand.inactive_timer = nil
	self.offhand.frame = CreateFrame("Frame", addon_name .. "OHBarFrame", UIParent)

	-- ranged containers
	self.ranged.start = nil
	self.ranged.speed = nil
	self.ranged.ends_at = nil
	self.ranged.inactive_timer = nil
	self.ranged.frame = CreateFrame("Frame", addon_name .. "OHBarFrame", UIParent)

	-- GCD info containers
	self.gcd = {}
	self.gcd.lock = false
    self.gcd.duration = nil
	self.gcd.started = nil
	self.gcd.expires = nil

	-- Register events
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")

end

------------------------------------------------------------------------------------
-- The Internal timers
------------------------------------------------------------------------------------
function ST:check_weapons()
	-- Detect what weapon types are equipped.
	-- Called when equipment is changed.
	local mh_info = {SwingTimerInfo('mainhand')}
	local oh_info = {SwingTimerInfo('offhand')}
	local ranged_info = {SwingTimerInfo('ranged')}
	self.has_oh = false
	self.has_ranged = false
	if oh_info[1] ~= 0 then
		self.has_oh = true
	end
	if ranged_info[1] ~= 0 then
		self.has_ranged = true
	end
end



------------------------------------------------------------------------------------
-- The Event handlers for the STL
------------------------------------------------------------------------------------
function ST:register_timer_callbacks()
	STL.RegisterCallback(self, "SWING_TIMER_START", self.timer_event_handler)
	STL.RegisterCallback(self, "SWING_TIMER_UPDATE", self.timer_event_handler)
	STL.RegisterCallback(self, "SWING_TIMER_CLIPPED", self.timer_event_handler)
	STL.RegisterCallback(self, "SWING_TIMER_PAUSED", self.timer_event_handler)
	STL.RegisterCallback(self, "SWING_TIMER_STOP", self.timer_event_handler)
	STL.RegisterCallback(self, "SWING_TIMER_DELTA", self.timer_event_handler)
end

function ST:SWING_TIMER_START(speed, expiration_time, hand)
	local self = ST
	self[hand].start = GetTime()
	self[hand].speed = speed
	self[hand].ends_at = expiration_time
	-- hook the onupdate
	self[hand].frame:SetScript("OnUpdate", self[hand].onupdate)
	
	-- handle gcd if necessary
	if self.gcd.lock then
		self:set_gcd_width()
	end
	-- end
	-- print("I got called!")
	-- print(speed)
	-- print(expiration_time)
	-- print(hand)
end

function ST:SWING_TIMER_UPDATE(speed, expiration_time, hand)
end

function ST:SWING_TIMER_CLIPPED(hand)
end

function ST:SWING_TIMER_PAUSED(hand)
end

function ST:SWING_TIMER_STOP(hand)
	-- unhooks update funcs
	ST[hand].frame:SetScript("OnUpdate", nil)
end

function ST:SWING_TIMER_DELTA(hand)
end

-- Stub to call the appropriate handler.
-- Doesn't play well with self syntax sugar.
function ST.timer_event_handler(event, ...)
	local args = {...}
	-- print(args)
	local hand = nil
	if event == "SWING_TIMER_START" or event == "SWING_TIMER_UPDATE" then
		hand = args[3]
	end
	if event == "SWING_TIMER_STOP" then
		hand = args[1]
	end
	if hand == "mainhand" then
		print(event)
	end
	ST[event](event, ...)
end

------------------------------------------------------------------------------------
-- AceEvent callbacks
------------------------------------------------------------------------------------
function ST:PLAYER_ENTERING_WORLD(event, is_initial_login, is_reloading_ui)
	-- Timer information should be first accessed here.
	print('player entering world')
	self:register_timer_callbacks()
	self:init_mh_bar_visuals()

end

function ST:PLAYER_EQUIPMENT_CHANGED(event, slot, has_current)
	print('slot says: '..tostring(slot))
	-- print(slot)
	if slot == 16 or slot == 17 or slot == 18 then
		self:check_weapons()
		print('has_oh: '.. tostring(self.has_oh))
		print('has ranged: '..tostring(self.has_ranged))
	end
end

-- GCD events
function ST:SPELL_UPDATE_COOLDOWN()
	if self.gcd.lock then
		return
	end
	local time_started, duration = GetSpellCooldown(29515)
    if duration == 0 then
        return
    end
	local t = GetTime()
	self.gcd.lock = true
    self.gcd.duration = duration - (t - time_started)
	self.gcd.started = t
	self.gcd.expires = t + self.gcd.duration
	print(self.gcd.started, self.gcd.duration)
	self:set_gcd_width()
	-- set a timer to release the GCD lock when it expires
	C_Timer.After(self.gcd.duration, function() self:release_gcd_lock() end)
end

function ST:release_gcd_lock()
	-- Called when a GCD expires.
	self.gcd.lock = false
    self.gcd.duration = nil
	self.gcd.started = nil
	self.mainhand.frame.gcd_bar:SetWidth(0)
end

function ST:PLAYER_REGEN_ENABLED()
	-- unhook all onupdates when out of combat
	for _, h in ipairs({"mainhand", "offhand", "ranged"}) do
		self[h].frame:SetScript("OnUpdate", nil)
	end
end

------------------------------------------------------------------------------------
-- Slashcommands
------------------------------------------------------------------------------------
function ST:register_slashcommands()
	local register_func_string = "SlashCommand"
	self:RegisterChatCommand("st", register_func_string)
	self:RegisterChatCommand("swedgetimer", register_func_string)
	self:RegisterChatCommand("test1", "test1")
end

function ST:test1()
	-- local b = OffhandHasWeapon()
	-- print(b)
	-- self:check_weapons()
	local a, b, c = SwingTimerInfo("ranged")
	print(a,b,c)
end

function ST:SlashCommand(input, editbox)
	local ACD = LibStub("AceConfigDialog-3.0")
	ACD:Open(addon_name.."_Options")
end
