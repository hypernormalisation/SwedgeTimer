------------------------------------------------------------------------------------
-- Main module for creating the addon with AceAddon
------------------------------------------------------------------------------------
local addon_name, st = ...
local ST = LibStub("AceAddon-3.0"):NewAddon(addon_name, "AceConsole-3.0", "AceEvent-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
local STL = LibStub("LibClassicSwingTimerAPI", true)
local LRC = LibStub("LibRangeCheck-2.0")
-- print('LRC says: '..tostring(LRC))
-- local rcf = CreateFrame("Frame", nil)

local print = st.utils.print_msg

local SwingTimerInfo = function(hand)
    return STL:SwingTimerInfo(hand)
end

-- keyword-accessible tables
ST.mainhand = {}
ST.offhand = {}
ST.ranged = {}
ST.hands = {
	mainhand = true,
	offhand = true,
	ranged = true
}
ST.h = {"mainhand", "offhand", "ranged"}

function ST:iter_hands()
	local i = 0
	local hands = self.h
	local n = #hands
	return function ()
		i = i + 1
		while i <= n do
			return hands[i]
		end
		return nil
	end
end

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
	-- AC:RegisterOptionsTable(addon_name.."_Profiles", profiles)
	-- ACD:AddToBlizOptions(addon_name.."_Profiles", "Profiles", addon_name)

	local safeDistanceChecker = LRC:GetHarmMinChecker(30)
	print(safeDistanceChecker == nil)

	LRC:RegisterCallback(LRC.CHECKERS_CHANGED, function() self:init_range_finders() end)
	STL:RegisterCallback(STL.SWING_TIMER_READY, function() self:init_timers() end)

	-- Slashcommands
	self:register_slashcommands()

end

function ST:OnEnable()
	-- Sort out character information
	self.player_guid = UnitGUID("player")
	self.player_class = select(2, UnitClass("player"))
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
	self:RegisterEvent("PLAYER_TARGET_SET_ATTACKING")

end

------------------------------------------------------------------------------------
-- Range finding
------------------------------------------------------------------------------------
function ST:init_range_finders()
	self.rangefinder_interval = 0.2
	self.melee_range_checker_func = LRC:GetHarmMaxChecker(LRC.MeleeRange)
	local r = 30
	if self.player_class == "HUNTER" then
		r = 35
	end
	self.ranged_range_checker_func = LRC:GetHarmMaxChecker(r)
	self.in_melee_range = nil
	self.in_ranged_range = nil
	self.target_min_range = nil
	self.target_max_range = nil
	self:rf_update()
end

function ST:rf_update()
	self.in_melee_range = self:melee_range_checker_func("target")
	-- print(self.melee_result)
	self.in_ranged_range = self.ranged_range_checker_func("target")
	self.target_min_range, self.target_max_range = LRC:GetRange("target")
	-- print('minrange = '..tostring(self.target_min_range))
	-- print(self.target_max_range)
	C_Timer.After(self.rangefinder_interval, function() self:rf_update() end)
end

------------------------------------------------------------------------------------
-- State setting
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
-- GCD funcs
------------------------------------------------------------------------------------
function ST:needs_gcd()
	if self:get_hand_table("mainhand")["show_gcd_underlay"] or
		self:get_hand_table("offhand")["show_gcd_underlay"] or
		self:get_hand_table("ranged")["show_gcd_underlay"] then
		return true
	end
	return false
end

-- function ST:hands_needing_underlay()
-- 	local hands = {}
-- 	for 
-- end

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

	-- handle gcd if necessary
	if self.gcd.lock then
		self:set_gcd_width()
	end
end

function ST:SWING_TIMER_UPDATE(speed, expiration_time, hand)
	self = ST
	local t = GetTime()
	if expiration_time < t then
		expiration_time = t
	end
	self[hand].speed = speed
	self[hand].ends_at = expiration_time
	self:set_bar_texts(hand)
	-- handle gcd if necessary
	if self.gcd.lock then
		self:set_gcd_width()
	end
end

function ST:SWING_TIMER_CLIPPED(hand)
end

function ST:SWING_TIMER_PAUSED(hand)
end

function ST:SWING_TIMER_STOP(hand)
	-- unhooks update funcs
	-- ST[hand].frame:SetScript("OnUpdate", nil)
end

function ST:SWING_TIMER_DELTA(delta)
	print(string.format("DELTA = %s", delta))
end

-- Stub to call the appropriate handler.
-- Doesn't play well with self syntax sugar.
function ST.timer_event_handler(event, ...)
	local args = {...}
	-- print(args)
	local hand = nil
	if event == "SWING_TIMER_START" or event == "SWING_TIMER_UPDATE" then
		hand = args[3]
	else
		hand = args[1]
	end
	print('event says: '..tostring(event))
	print(string.format("%s: %s", hand, event))
	if hand == "offhand" then
		print(event)
	end
	ST[event](event, ...)
end

------------------------------------------------------------------------------------
-- AceEvent callbacks
------------------------------------------------------------------------------------
function ST:init_timers()
	print('RECEIVED STL CALLBACK')
	self:register_timer_callbacks()

	for hand in self:iter_hands() do
		local t = {SwingTimerInfo(hand)}
		print(string.format("%s, %s, %s", tostring(t[1]),
		tostring(t[2]), tostring(t[3])))
		self[hand].speed = t[1]
		self[hand].ends_at = t[2]
		self[hand].start = t[3]
		ST:init_visuals_template(hand)
		ST:set_bar_texts(hand)
		-- hook the onupdate
		self[hand].frame:SetScript("OnUpdate", self[hand].onupdate)
	end
	self.ranged.frame:Hide()
end

function ST:PLAYER_ENTERING_WORLD(event, is_initial_login, is_reloading_ui)
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
	if not self:needs_gcd() then
		return
	end
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
	-- for _, h in ipairs({"mainhand", "offhand", "ranged"}) do
	-- 	self[h].frame:SetScript("OnUpdate", nil)
	-- end
end

function ST:PLAYER_TARGET_SET_ATTACKING()
	print('offsetting offhand')
	local t = GetTime()
	local old_start = self.offhand.start
	if old_start + self.offhand.speed < t then
		self.offhand.start = GetTime() - self.offhand.speed
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
    -- local db = self:get_hand_table("mainhand")
	-- print(db.tag)
	-- print(db.bar_color_default)
	-- local r, g, b, a = self:convert_color(db.bar_color_default)
	-- print(r)
	-- print(g)
	-- print(b)
	print("iterating hands")
	for hand in self:iter_hands() do
		print('=')
		print(hand)
	end
end

function ST:SlashCommand(input, editbox)
	local ACD = LibStub("AceConfigDialog-3.0")
	ACD:Open(addon_name.."_Options")
end
