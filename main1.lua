--=========================================================================================
-- Main module for creating the addon with AceAddon
--=========================================================================================
local addon_name, st = ...
local ST = LibStub("AceAddon-3.0"):NewAddon(addon_name, "AceConsole-3.0", "AceEvent-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
local STL = LibStub("LibClassicSwingTimerAPI", true)
local LRC = LibStub("LibRangeCheck-2.0")
local LLM = LibStub("LibLatencyMonitor")
local LGC = LibStub("LibGlobalCooldown")

local print = st.utils.print_msg

local SwingTimerInfo = function(hand)
    return STL:SwingTimerInfo(hand)
end

function table.pack(...)
	return { n = select("#", ...), ... }
  end
  

--=========================================================================================
-- Funcs/iterables to automate common tasks.
--=========================================================================================
-- keyword-accessible tables to handle case-switching
ST.mainhand = {}
ST.offhand = {}
ST.ranged = {}
ST.hands = {"mainhand", "offhand", "ranged"}
ST.interfaces_are_initialised = false

function ST:iter_hands()
	-- Iterates over melee/ranged/offhand 
	local i = 0
	local hands = self.hands
	local n = #hands
	return function ()
		i = i + 1
		while i <= n do
			return hands[i]
		end
		return nil
	end
end

function ST:get_frame(hand)
	-- Gets the frame associated with that hand's bar
	-- print("hand says: " .. tostring(hand))
	return self[hand].frame
end

function ST:get_in_range(hand)
	if hand == "ranged" then return self.in_ranged_range else return self.in_melee_range end
end

--=========================================================================================
-- Funcs to initialise the addon
--=========================================================================================
function ST:OnInitialize()
	-- ST.some_counter = ST.some_counter + 1
	-- print(string.format("init count: %i", ST.some_counter))

	-- Addon database
	local SwedgeTimerDB = LibStub("AceDB-3.0"):New(addon_name.."DB", self.defaults, true)
	self.db = SwedgeTimerDB
	print("unit class says: "..tostring(select(2, UnitClass("player"))))
	-- Options table
	local AC = LibStub("AceConfig-3.0")
	local ACD = LibStub("AceConfigDialog-3.0")
	AC:RegisterOptionsTable(addon_name.."_Options", self.options)
	self.optionsFrame = ACD:AddToBlizOptions(addon_name.."_Options", addon_name)

	-- Profile options
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	-- AC:RegisterOptionsTable(addon_name.."_Profiles", profiles)
	-- ACD:AddToBlizOptions(addon_name.."_Profiles", "Profiles", addon_name)

	-----------------------------------------------------------
	-- Callbackhandlers for letting the addon know that dependent
	-- libraries have their interfaces enabled.
	-----------------------------------------------------------
	-- Init our lib interfaces only once the range and swing timer
	-- libs are both loaded, as they are interdependent
	-- init_libs has a check to ensure this only happens once per reload
	self.lrc_ready = false
	self.stl_ready = false
	self.llm_ready = false
	LRC.RegisterCallback(self, LRC.CHECKERS_CHANGED, function()
			self.lrc_ready = true
			self:init_libs()
		end
	)
	STL.RegisterCallback(self, STL.SWING_TIMER_READY, function()
			self.stl_ready = true
			self:init_libs()
		end
	)

	-----------------------------------------------------------
	-- Callbackhandlers that are less sensitive to load orders.
	-----------------------------------------------------------
	-- LibLatencyMonitor
	LLM.RegisterCallback(self, LLM.LATENCY_CHANGED, self.callback_event_handler)

	-- LibGlobalCooldown
	LGC.RegisterCallback(self, LGC.GCD_STARTED, self.callback_event_handler)
	LGC.RegisterCallback(self, LGC.GCD_OVER, self.callback_event_handler)
	LGC.RegisterCallback(self, LGC.GCD_DURATIONS_UPDATED, self.callback_event_handler)

	-----------------------------------------------------------
	-- The set of containers and frames used in the addon.
	-----------------------------------------------------------
	-- Character info containers
	self.player_guid = UnitGUID("player")
	self.player_class = select(2, UnitClass("player"))
	self.has_oh = false
	self.has_ranged = false
	self.mh_timer = 0
	self.oh_timer = 0
	self.ranged_timer = 0

	-- Character state containers
	self.in_combat = false
	self.is_melee_attacking = false
	self.has_target = false
	self.has_attackable_target = false

	-- MH timer containers
	self.mainhand.start = nil
	self.mainhand.speed = nil
	self.mainhand.ends_at = nil
	self.mainhand.inactive_timer = nil
	self.mainhand.has_weapon = true
	self.mainhand.is_full = true  -- deliberately true
	self.mainhand.is_full_timer = nil
	self.mainhand.frame = CreateFrame("Frame", addon_name .. "MHBarFrame", UIParent)

	-- OH containers
	self.offhand.start = nil
	self.offhand.speed = nil
	self.offhand.ends_at = nil
	self.offhand.inactive_timer = nil
	self.offhand.has_weapon = nil
	self.offhand.is_full = false
	self.mainhand.is_full_timer = nil
	self.offhand.frame = CreateFrame("Frame", addon_name .. "OHBarFrame", UIParent)

	-- ranged containers
	self.ranged.start = nil
	self.ranged.speed = nil
	self.ranged.ends_at = nil
	self.ranged.inactive_timer = nil
	self.ranged.has_weapon = nil
	self.ranged.is_full = false
	self.ranged.frame = CreateFrame("Frame", addon_name .. "OHBarFrame", UIParent)

	-- GCD info containers
	self.gcd = {}
    self.gcd.duration = nil
	self.gcd.started = nil
	self.gcd.expires = nil
	self.gcd.phys_length = nil
	self.gcd.spell_length = nil

	-- Latency info containers
	self.latency = {}
	self.latency.update_interval_s = 1
	self.latency.home_ms = nil
	self.latency.world_ms = nil

	-----------------------------------------------------------
	-- Register events
	-----------------------------------------------------------
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_TARGET_SET_ATTACKING")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_ENTER_COMBAT")
	self:RegisterEvent("PLAYER_LEAVE_COMBAT")
	self:RegisterEvent("UNIT_TARGET")

	-----------------------------------------------------------
	-- Register Slashcommands
	-----------------------------------------------------------
	self:register_slashcommands()

end

function ST:init_libs()
	-- This function inits our interfaces to the libraries we use,
	-- but only once those libraries are fully ready and have
	-- all of the information necessary.
	if self.interfaces_are_initialised then
		return
	end
	if not self.lrc_ready and self.stl_ready then
		return
	end
	self:init_timers()
	self:init_range_finders()
	self.interfaces_are_initialised = true
	self:post_init()
end

function ST:init_timers()
	self:register_timer_callbacks()
	self:check_weapons()
	for hand in self:iter_hands() do
		local t = {SwingTimerInfo(hand)}
		-- print(string.format("%s, %s, %s", tostring(t[1]),
		-- tostring(t[2]), tostring(t[3])))
		self[hand].speed = t[1]
		self[hand].ends_at = t[2]
		self[hand].start = t[3]
		ST:init_visuals_template(hand)
		ST:set_bar_texts(hand)
		-- hook the onupdate
		self[hand].frame:SetScript("OnUpdate", self[hand].onupdate)
	end
end

function ST:register_timer_callbacks()
	STL.RegisterCallback(self, "SWING_TIMER_CLIPPED", self.callback_event_handler)
	STL.RegisterCallback(self, "SWING_TIMER_DELTA", self.callback_event_handler)
	STL.RegisterCallback(self, "SWING_TIMER_PAUSED", self.callback_event_handler)
	STL.RegisterCallback(self, "SWING_TIMER_START", self.callback_event_handler)
	STL.RegisterCallback(self, "SWING_TIMER_STOP", self.callback_event_handler)
	STL.RegisterCallback(self, "SWING_TIMER_UPDATE", self.callback_event_handler)
end

function ST:check_weapons()
	-- Detect what weapon types are equipped.
	for hand in self:iter_hands() do
		local speed = SwingTimerInfo(hand)
		-- print(speed)
		if speed == 0 then
			self[hand].has_weapon = false
		else
			self[hand].has_weapon = true
		end
	end
end

function ST:post_init()
	-- Takes care of any miscellaneous widget/state manipulation that needs to run
	-- once the libraries and addon are initialised.
	for hand in self:iter_hands() do
		self:set_bar_full_state(hand)
		self[hand].is_full = true
	end
end

--=========================================================================================
-- CallbackHandlers
--=========================================================================================
function ST.callback_event_handler(event, ...)
	-- Func to pass all callbacks to their relevant handler
	-- print('===============')
	-- print(event)
	-- local args = table.pack(...)
	-- for i=1, args.n do
	-- 	print(tostring(args[i]))
	-- end
	-- print('===============')
	ST[event](ST, event, ...)
end

-----------------------------------------------------------
-- GCD lib funcs
-----------------------------------------------------------
function ST:GCD_STARTED(_, duration, expires)
	-- print(duration)
	-- print(expires)
	self.gcd.expires = expires
end

function ST:GCD_OVER()
	self.gcd.expires = nil
	for hand in self:iter_hands() do
		self:get_frame(hand).gcd_bar:Hide()
	end
end

function ST:GCD_DURATIONS_UPDATED(_, phys_length, spell_length)
	self.gcd.spell_length = spell_length
	self.gcd.phys_length = phys_length
	self:on_gcd_length_change()
end

-----------------------------------------------------------
-- Latency tracking
-----------------------------------------------------------
function ST:LATENCY_CHANGED(_, home, world)
	self.latency.home_ms = home
	self.latency.world_ms = world
	if self.interfaces_are_initialised then
		self:on_latency_update()
	end
end

-----------------------------------------------------------
-- Swing Timer Lib
-----------------------------------------------------------
function ST:SWING_TIMER_CLIPPED(_, hand)
end

function ST:SWING_TIMER_DELTA(_, delta)
	-- print(string.format("DELTA = %s", delta))
end

function ST:SWING_TIMER_PAUSED(_, hand)
end

function ST:SWING_TIMER_START(_, speed, expiration_time, hand)
	if self[hand].is_full_timer then
		self[hand].is_full_timer:Cancel()
		self:set_filling_state(hand)
	elseif self[hand].is_full then
		self[hand].is_full = false
		self:set_filling_state(hand)
	end
	self[hand].start = GetTime()
	self[hand].speed = speed
	self[hand].ends_at = expiration_time
end

function ST:SWING_TIMER_STOP(_, hand)
	local db_shared = self.db.profile
	self[hand].is_full_timer = C_Timer.NewTimer(db_shared.bar_full_delay, function()
		self:set_bar_full_state(hand)
		self[hand].is_full = true
	end)
end

function ST:SWING_TIMER_UPDATE(_, speed, expiration_time, hand)
	local t = GetTime()
	if expiration_time < t then
		expiration_time = t
	end
	self[hand].speed = speed
	self[hand].ends_at = expiration_time
	-- print('New speed = ' .. tostring(speed))
	self:on_attack_speed_change(hand)
end

------------------------------------------------------------------------------------
-- AceEvent callbacks
------------------------------------------------------------------------------------
function ST:PLAYER_ENTERING_WORLD(event, is_initial_login, is_reloading_ui)
end

function ST:PLAYER_EQUIPMENT_CHANGED(event, slot, has_current)
	print('slot says: '..tostring(slot))
	-- print(slot)
	if slot == 16 or slot == 17 or slot == 18 then
		self:check_weapons()
		print('has_oh: '.. tostring(self.offhand.has_weapon))
		print('has ranged: '..tostring(self.ranged.has_weapon))
	end
end

function ST:PLAYER_REGEN_ENABLED()
	self.in_combat = false
end

function ST:PLAYER_REGEN_DISABLED()
	self.in_combat = true
end

function ST:PLAYER_ENTER_COMBAT()
	self.is_melee_attacking = true
end

function ST:PLAYER_LEAVE_COMBAT()
	self.is_melee_attacking = false
end

function ST:PLAYER_TARGET_SET_ATTACKING()
	-- print('offsetting offhand')
	local t = GetTime()
	local old_start = self.offhand.start
	if old_start + self.offhand.speed < t then
		self:set_bar_color('offhand')
		self.offhand.start = GetTime() - self.offhand.speed
	end
end

function ST:UNIT_TARGET(event, unitId)
	if unitId ~= "player" then
		return
	end
	if UnitExists("target") then self.has_target = true else self.has_target = false end
	if UnitCanAttack("player", "target") == true then
		self.has_attackable_target = true
	else
		self.has_attackable_target = false
	end
end

------------------------------------------------------------------------------------
-- Range finding
------------------------------------------------------------------------------------
function ST:init_range_finders()
	self.rangefinder_interval = 0.1
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
	-- print(self.mainhand.is_full)
	self.in_melee_range = self:melee_range_checker_func("target")
	-- print(self.melee_result)
	self.in_ranged_range = self.ranged_range_checker_func("target") and not self.in_melee_range
	self.target_min_range, self.target_max_range = LRC:GetRange("target")
	-- print('minrange = '..tostring(self.target_min_range))
	-- print(self.target_max_range)
	self:set_bar_visibilities()
	self:handle_oor()
	C_Timer.After(self.rangefinder_interval, function() self:rf_update() end)
end

------------------------------------------------------------------------------------
-- Bar out-of-range behaviour
------------------------------------------------------------------------------------
function ST:handle_oor()
	for hand in self:iter_hands() do
		if self:bar_is_enabled(hand) then
			self:handle_oor_hand(hand)
		end
	end
end

function ST:handle_oor_hand(hand)
	local db = self:get_hand_table(hand)
	local frame = self:get_frame(hand)

	if db.oor_effect == "dim" then
		if not self:get_in_range(hand) then
			frame:SetAlpha(db.dim_alpha)
		else
			frame:SetAlpha(1.0)
		end
	end
end

------------------------------------------------------------------------------------
-- Bar visibility
------------------------------------------------------------------------------------
function ST:hide_bar(hand)
	self:get_frame(hand):Hide()
end

function ST:show_bar(hand)
	self:get_frame(hand):Show()
end

function ST:bar_is_enabled(hand)
	local db = self:get_hand_table(hand)
	if hand == "mainhand" then -- always has weapon
		if db.enabled then
			return true
		else
			return false
		end
	elseif db.enabled and self[hand].has_weapon then
		return true
	else
		return false
	end
end

function ST:handle_bar_visibility(hand)
	-- Out of combat requirement overrides all else
	local db = self:get_hand_table(hand)
	if db.hide_ooc then
		if not self.in_combat then
			self:hide_bar(hand)
			return
		end
	end
	if db.force_show_in_combat then
		if self.in_combat then
			self:show_bar(hand)
			return
		end
	end
	-- Then target and range checks
	if db.require_has_valid_target then
		if self.has_attackable_target then
			if db.require_in_range then
				if not self:get_in_range(hand) then
					self:hide_bar(hand)
					return
				end
			end
		else
			self:hide_bar(hand)
			return
		end
	end
	-- If we get here, bar should be shown
	self:show_bar(hand)
end

function ST:set_bar_visibilities()
	-- Function hooked onto the rangefinder C_Timer to determine bar states
	for hand in self:iter_hands() do
		-- Get appropriate range
		-- print(string.format("%s in range: %s", hand, tostring(in_range)))
		if not self:bar_is_enabled(hand) then
			self:hide_bar(hand)
		else
			self:handle_bar_visibility(hand)
		end
	end
end

------------------------------------------------------------------------------------
-- State setting
------------------------------------------------------------------------------------


function ST:set_bar_full_state(hand)
	self:set_bar_color(hand, {0.5, 0.5, 0.5, 1.0})
end

function ST:set_filling_state(hand)
	self:set_bar_color(hand)
end

------------------------------------------------------------------------------------
-- GCD functionality
------------------------------------------------------------------------------------
function ST:needs_gcd()
	if self:get_hand_table("mainhand")["show_gcd_underlay"] or
		self:get_hand_table("offhand")["show_gcd_underlay"] or
		self:get_hand_table("ranged")["show_gcd_underlay"] then
		return true
	end
	return false
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
    local db = self:get_hand_table("mainhand")
	local f = self:get_frame("mainhand")
	-- self.mainhand.frame.gcd_bar
end

function ST:SlashCommand(input, editbox)
	local ACD = LibStub("AceConfigDialog-3.0")
	ACD:Open(addon_name.."_Options")
end
