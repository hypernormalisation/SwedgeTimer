--=========================================================================================
-- Main module for SwedgeTimer
--=========================================================================================
local addon_name, st = ...
-- local version = "@project-version@"
local version = "3.0"
local ST = LibStub("AceAddon-3.0"):NewAddon(addon_name, "AceConsole-3.0", "AceEvent-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
local STL = LibStub("LibClassicSwingTimerAPI", true)
local LRC = LibStub("LibRangeCheck-2.0")
local LLM = LibStub("LibLatencyMonitor")
local LGC = LibStub("LibGlobalCooldown")
local LWIN = LibStub("LibWindow-1.1")

local print = st.utils.print_msg

ST.DEATHKNIGHT = {}
ST.DRUID = {}
ST.HUNTER = {}
ST.MAGE = {}
ST.PALADIN = {}
ST.PRIEST = {}
ST.ROGUE = {}
ST.SHAMAN = {}
ST.WARLOCK = {}
ST.WARRIOR = {}

--=========================================================================================
-- Funcs/iterables to automate common tasks
--=========================================================================================
local SwingTimerInfo = function(hand)
    return STL:SwingTimerInfo(hand)
end

function table.pack(...)
	return { n = select("#", ...), ... }
end

ST.interfaces_are_initialised = false

-- keyword-accessible tables to handle case-switching
ST.mainhand = {}
ST.offhand = {}
ST.ranged = {}

ST.class_hands = {
	DEATHKNIGHT = {"mainhand", "offhand"},
	DRUID = {"mainhand"},
	HUNTER = {"mainhand", "offhand", "ranged"},
	MAGE = {"mainhand", "ranged"},
	PALADIN = {"mainhand"},
	PRIEST = {"mainhand", "offhand"},
	ROGUE = {"mainhand", "offhand", "ranged"},
	SHAMAN = {"mainhand", "offhand"},
	WARLOCK = {"mainhand", "offhand"},
	WARRIOR = {"mainhand", "offhand", "ranged"},
}

function ST:iter_hands()
	-- Iterates over melee/ranged/offhand 
	local i = 0
	local hands = self.class_hands[self.player_class]
	local n = #hands
	return function ()
		i = i + 1
		while i <= n do
			return hands[i]
		end
		return nil
	end
end

function ST:generic_iter(array)
	local i = 0
	local n = #array
	return function()
		i = i + 1
		while i <= n do
			return array[i]
		end
	end
end

function ST:is_value_in_array(value, array)
	for _, v in pairs(array) do
		if v == value then
			return true
		end
	end
	return false
end

function ST:convert_color(t, new_alpha)
	-- Convert standard 0-255 colors down to WoW 0-1 ranges.
	local r,g,b,a = unpack(t)
	a = new_alpha or a
	r = r/255
	g = g/255
	b = b/255
	return r, g, b, a
end

function ST:convert_color_up(t, new_alpha)
	-- Convert WoW 0-1 ranges up to standard 0-255 ranges.
	local r,g,b,a = unpack(t)
	a = new_alpha or a
	r = r * 255
	g = g * 255
	b = b * 255
	return r, g, b, a
end

function ST:get_anchor_frame(hand)
	-- Gets the main anchor frame for the hand.
	return self[hand].anchor_frame
end

function ST:get_hiding_anchor_frame(hand)
	-- Get the hiding anchor frame, which also gets calls to show/hide.
	return self:get_anchor_frame(hand).hiding_anchor_frame
end

function ST:get_bar_frame(hand)
	-- Gets the bar frame for the hand.
	-- This is the frame with the backdrop, but *not* the frame
	-- with the bar visuals - that's a child of this one.
	return self:get_anchor_frame(hand).bar_frame
end

function ST:get_visuals_frame(hand)
	return self:get_bar_frame(hand).visuals_frame
end

function ST:get_profile_table()
	return self.db.profile
end

function ST:get_class_table()
	return self.db.profile[self.player_class]
end

function ST:get_hand_table(hand)
	return self.db.profile[self.player_class][hand]
end

function ST:get_in_range(hand)
	if hand == "ranged" then return self.in_ranged_range else return self.in_melee_range end
end

function ST:hide_bar(hand)
	self:get_bar_frame(hand):Hide()
	self:get_hiding_anchor_frame(hand):Hide()
end

function ST:show_bar(hand)
	local db_class = self:get_class_table()
	if db_class.class_enabled then
		self:get_bar_frame(hand):Show()
		self:get_hiding_anchor_frame(hand):Show()
	end
end

function ST:lock_frames()
	for hand in self:iter_hands() do
		local f = self:get_anchor_frame(hand)
		f:SetMovable(false)
		f:EnableMouse(false)
		f:SetScript("OnMouseWheel", nil)
	end
end

function ST:unlock_frames()
	for hand in self:iter_hands() do
		local f = self:get_anchor_frame(hand)
		f:SetMovable(true)
		f:EnableMouse(true)
		f:SetScript("OnMouseWheel", function(_, dir)
				LWIN.OnMouseWheel(f, dir)
				local ACR = LibStub("AceConfigRegistry-3.0")
				ACR:NotifyChange(ST.options_table_name)
			end
		)
	end
end


--=========================================================================================
-- Funcs to initialise the addon
--=========================================================================================
function ST:OnInitialize()

	-- Get player class first
	self.player_class_pretty, self.player_class = UnitClass("player")

	-- Register our media
	LSM:Register(
		"border", "Square Full White", [[Interface\BUTTONS\WHITE8X8]]
	)
	LSM:Register(
		"font", "Expressway", [[Interface\Addons\SwedgeTimer\Media\Fonts\Expressway.ttf]]
	)

	-- Addon database
	local SwedgeTimerDB = LibStub("AceDB-3.0"):New(addon_name.."DB", self.defaults, true)
	self.db = SwedgeTimerDB

	-----------------------------------------------------------
	-- Dynamically construct the options tables
	-----------------------------------------------------------
	local AC = LibStub("AceConfig-3.0")
	local ACD = LibStub("AceConfigDialog-3.0")
	self:set_opts()

	self.options_table_name = addon_name.."_Options"
	AC:RegisterOptionsTable(self.options_table_name, self.opts_table)
	self.optionsFrame = ACD:AddToBlizOptions(self.options_table_name, addon_name)

	-- Profile options
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	AC:RegisterOptionsTable(addon_name.."_Profiles", profiles)
	ACD:AddToBlizOptions(addon_name.."_Profiles", "Profiles", addon_name)

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
	-- Even though many are nilled, this collates them so
	-- we have a reference to each container visually 
	-- in the code.
	-----------------------------------------------------------
	-- Character info containers
	self.player_guid = UnitGUID("player")
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

	self.form_index = GetShapeshiftForm()
	self.is_cat_or_bear = false
	if self.player_class == "DRUID" then
		if self.form_index == 1 or self.form_index == 3 then
			self.is_cat_or_bear = true
		end
	end

	-- MH timer containers
	self.mainhand.start = nil
	self.mainhand.speed = nil
	self.mainhand.ends_at = nil
	self.mainhand.inactive_timer = nil
	self.mainhand.has_weapon = true
	self.mainhand.is_full = true  -- deliberately true
	self.mainhand.is_full_timer = nil
	self.mainhand.is_paused = false
	self.mainhand.current_progress = false

	-- OH containers
	self.offhand.start = nil
	self.offhand.speed = nil
	self.offhand.ends_at = nil
	self.offhand.inactive_timer = nil
	self.offhand.has_weapon = nil
	self.offhand.is_full = false
	self.offhand.is_full_timer = nil
	self.offhand.is_paused = false

	-- ranged containers
	self.ranged.start = nil
	self.ranged.speed = nil
	self.ranged.ends_at = nil
	self.ranged.inactive_timer = nil
	self.ranged.has_weapon = nil
	self.ranged.is_full = false

	-- GCD info containers
	self.gcd = {}
    self.gcd.duration = nil
	self.gcd.started = nil
	self.gcd.expires = nil
	self.gcd.phys_length = nil
	self.gcd.spell_length = nil

	self.gcd1_phys_time_before_swing = nil
	self.gcd1_spell_time_before_swing = nil
	self.gcd1_marker_position = nil

	-- self.gcd2_phys_time_before_swing = nil
	-- self.gcd2_spell_time_before_swing = nil
	-- self.gcd2_marker_position = nil

	-- Latency info containers
	self.latency = {}
	self.latency.update_interval_s = 1
	self.latency.home_ms = 0
	self.latency.calibrated_home_ms = 0
	self.latency.world_ms = 0
	self.latency.calibrated_world_ms = 0

	-----------------------------------------------------------
	-- Register WoW API events
	-----------------------------------------------------------
	self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED")
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_TARGET_SET_ATTACKING")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_ENTER_COMBAT")
	self:RegisterEvent("PLAYER_LEAVE_COMBAT")
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("UNIT_POWER_FREQUENT")
	self:RegisterEvent("UNIT_SPELLCAST_FAILED_QUIET")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterEvent("UNIT_TARGET")
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM")

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
	self.interfaces_are_initialised = true
	self:init_timers()
	self:init_range_finders()
	self:post_init()

	-- If requested, print a welcome message once everything is
	-- initialised properly.
	local db = self:get_profile_table()
	if db.welcome_message then
		self:Print("Version " .. version .. " loaded!")
	end
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
		self:get_bar_frame(hand):SetScript("OnUpdate", self[hand].onupdate)
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
	self:set_gcd_times_before_swing_seconds()
	self:on_latency_update()

	for hand in self:iter_hands() do
		self:set_gcd_marker_positions(hand)
		-- self:set_bar_full_state(hand)
		self:on_bar_inactive(hand)
		self[hand].is_full = true
	end

	if self[self.player_class].post_init then
		self[self.player_class].post_init(self)
	end

	-- Set frames to locked or unlocked based on settings.
	local db_class = self:get_class_table()
	if db_class.bars_locked then
		self:lock_frames()
	else
		self:unlock_frames()
	end
end

--=========================================================================================
-- CallbackHandlers
--=========================================================================================
function ST.callback_event_handler(event, ...)
	-- Func to pass all callbacks to their relevant handler
	-- if string.find(event, "GCD") then
	-- 	print('<===============')
	-- 	print(event)
	-- 	local args = table.pack(...)
	-- 	for i=1, args.n do
	-- 		print(tostring(args[i]))
	-- 	end
	-- 	print('--------------->')
	-- end
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
		self:get_visuals_frame(hand).gcd_bar:Hide()
	end
end

function ST:GCD_DURATIONS_UPDATED(_, phys_length, spell_length)
	self.gcd.spell_length = spell_length
	self.gcd.phys_length = phys_length
	self:set_gcd_times_before_swing_seconds()
	if self.interfaces_are_initialised then
		self:on_gcd_length_change()
	end
end

-----------------------------------------------------------
-- Latency tracking
-----------------------------------------------------------
function ST:LATENCY_CHANGED(_, home, world)
	self.latency.home_ms = home
	self.latency.world_ms = world
	self:set_adjusted_latencies()
	if self.interfaces_are_initialised then
		self:set_gcd_times_before_swing_seconds()
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
	-- print(hand)
	self[hand].is_paused = true
end

function ST:SWING_TIMER_START(_, speed, expiration_time, hand)
	-- if not ST.interfaces_are_initialised then return end
	if self[hand].is_full_timer then
		self[hand].is_full_timer:Cancel()
		self[hand].is_full = false
		self:on_bar_active(hand)
	elseif self[hand].is_full then
		self[hand].is_full = false
		self:on_bar_active(hand)
	end
	self[hand].is_full = false
	self[hand].is_paused = false
	self[hand].start = GetTime()
	self[hand].speed = speed
	self[hand].ends_at = expiration_time
	self:set_bar_color(hand)
	if self.recent_form_change then
		self:on_gcd_length_change()
		self.recent_form_change = false
	end
end

function ST:SWING_TIMER_STOP(_, hand)
	local db_shared = self.db.profile
	self[hand].is_full_timer = C_Timer.NewTimer(db_shared.bar_full_delay, function()
		-- self:set_bar_full_state(hand)
		-- print("C_Timer expired")
		self[hand].is_full = true
		self:on_bar_inactive(hand)
	end)
	if self.player_class == "DRUID" then
		self:on_attack_speed_change(hand)
	end
end

function ST:SWING_TIMER_UPDATE(_, speed, expiration_time, hand)
	local t = GetTime()
	if expiration_time < t then
		expiration_time = t
	end
	self[hand].is_paused = false
	self[hand].speed = speed
	self[hand].start = expiration_time - speed
	self[hand].ends_at = expiration_time
	-- print(string.format("%f : %f", t, expiration_time))
	if t >= expiration_time then
		self[hand].is_full = true
		self:on_bar_inactive(hand)
	else
		self[hand].is_full = false
	end
	-- print('New speed = ' .. tostring(speed))
	self:on_attack_speed_change(hand)
end

------------------------------------------------------------------------------------
-- Wow API event callbacks
------------------------------------------------------------------------------------
function ST:CURRENT_SPELL_CAST_CHANGED(event, is_cancelled)
	self:class_on_current_spell_cast_changed(is_cancelled)
end

function ST:PLAYER_ENTERING_WORLD(event, is_initial_login, is_reloading_ui)
end

function ST:PLAYER_EQUIPMENT_CHANGED(event, slot, has_current)
	-- print('slot says: '..tostring(slot))
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
	-- Required to set the offhand timer delay when startattack or when
	-- target is changed (both fire this event).
	if not self.has_oh then return end
	local t = GetTime()
	local old_start = self.offhand.start
	if old_start + self.offhand.speed < t then
		self:set_bar_color('offhand')
		self.offhand.start = GetTime() - self.offhand.speed
	end
end

function ST:UNIT_AURA(event, unit_id, is_full_update, updated_auras)
	if unit_id ~= "player" or (not self.interfaces_are_initialised) then
		return
	end
	self:class_on_aura_change()
end

function ST:UNIT_POWER_FREQUENT(event, unit_id, powerType)
	-- Used to track if a warrior or druid has enough rage to cast
	-- any currently queued on-next-cast ability
	if unit_id ~= "player" or (not self.interfaces_are_initialised) then
		return
	end
	if powerType == "RAGE" then
		if self[self.player_class].on_rage_update then
			self[self.player_class].on_rage_update(self)
		end
	end
end

function ST:UNIT_SPELLCAST_FAILED_QUIET(event, unit_id, cast_guid, spell_id)
	if unit_id ~= "player" or (not self.interfaces_are_initialised) then
		return
	end
	-- Trigger any class-specific behaviour
	if self[self.player_class].on_spellcast_failed_quiet then
		self[self.player_class].on_spellcast_failed_quiet(self, unit_id, cast_guid, spell_id)
	end
end

function ST:UNIT_SPELLCAST_SUCCEEDED(event, unit_id, cast_guid, spell_id)
	if unit_id ~= "player" then
		return
	end
	-- Trigger any class-specific behaviour
	if self[self.player_class].on_spellcast_succeeded then
		self[self.player_class].on_spellcast_succeeded(self, unit_id, cast_guid, spell_id)
	end
end

function ST:UNIT_TARGET(event, unit_id)
	if unit_id ~= "player" then
		return
	end
	if UnitExists("target") then self.has_target = true else self.has_target = false end
	if UnitCanAttack("player", "target") == true then
		self.has_attackable_target = true
	else
		self.has_attackable_target = false
	end
end

function ST:UPDATE_SHAPESHIFT_FORM()
	-- At present, only druids care about shapeshifting, so the code
	-- to handle their forms goes here.
	if not self.class == "DRUID" then
        return
    end
    self.form_index = GetShapeshiftForm()
    if self.form_index == 1 or self.form_index ==3 then
        self.is_cat_or_bear = true
    else
        self.is_cat_or_bear = false
    end

	-- Set a flag to ensure a recalculation of bar elements at the next swing
	-- in case of any snapshotting
	self.recent_form_change = true
	if self.interfaces_are_initialised then
		self:on_attack_speed_change("mainhand")
		self:set_bar_color("mainhand")
	end

end

------------------------------------------------------------------------------------
-- Latency and GCD markers
------------------------------------------------------------------------------------
function ST:set_adjusted_latencies()
	-- Set the calibrated latencies
	local db = self:get_profile_table()
	local home = (self.latency.home_ms * db.latency_scale_factor) + db.latency_linear_offset
	self.latency.calibrated_home_ms = home
	local world = (self.latency.world_ms * db.latency_scale_factor) + db.latency_linear_offset
	self.latency.calibrated_world_ms = world
end

function ST:get_gcd_marker_time_offset_seconds()
	-- Gets the time offset in seconds according to the settings.
	local db = self:get_profile_table()
	local offset = 0
	if db.gcd_marker_offset_mode == "Dynamic" then
		offset = self.latency.world_ms
	elseif db.gcd_marker_offset_mode == "Calibrated" then
		offset = self.latency.calibrated_world_ms
	elseif db.gcd_marker_offset_mode == "Fixed" then
		offset = db.latency_linear_offset
	end
	offset = offset / 1000
	return offset
end

function ST:set_gcd_times_before_swing_seconds()
	-- Set all of the calculated times before our next swing.
	local base_phys = self.gcd.phys_length
	local base_spell = self.gcd.spell_length
	local offset = self:get_gcd_marker_time_offset_seconds()
	self.gcd.gcd1_phys_time_before_swing = base_phys + offset
	self.gcd.gcd1_spell_time_before_swing = base_spell + offset
	self.gcd.gcd2_phys_time_before_swing = (2 * base_phys) + offset
	self.gcd.gcd2_spell_time_before_swing = (2 * base_spell) + offset
end

------------------------------------------------------------------------------------
-- Range finding
------------------------------------------------------------------------------------
function ST:init_range_finders()
	self.rangefinder_interval = 0.05
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
	-- On the very first load of the game, CHECKERS_CHANGED can get a callback
	-- before the checker funcs are ready. If that happens, loop a C_Timer
	-- regardless and re-assign the functions until we get valid checkers,
	-- then resume normal function.
	if self.melee_range_checker_func == nil then
		C_Timer.After(self.rangefinder_interval, function()
				self.melee_range_checker_func = LRC:GetHarmMaxChecker(LRC.MeleeRange)
				local r = 30
				if self.player_class == "HUNTER" then
					r = 35
				end
				self.ranged_range_checker_func = LRC:GetHarmMaxChecker(r)
				self:rf_update()
			end
		)
		return
	end
	self.in_melee_range = self.melee_range_checker_func("target")
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
	local frame = self:get_bar_frame(hand)
	if db.dim_oor then
		if not self:get_in_range(hand) then
			frame:SetAlpha(db.dim_alpha)
		else
			frame:SetAlpha(1.0)
		end
	else
		frame:SetAlpha(1.0)
	end
end

------------------------------------------------------------------------------------
-- Bar visibility
------------------------------------------------------------------------------------
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
	-- Determines if the bar should be shown or not.
	local db = self:get_hand_table(hand)
	if db.show_behaviour == "always" then
		self:show_bar(hand)
		return
	end
	if db.show_condition == "in_combat" then
		if self.in_combat then
			self:show_bar(hand)
		else
			self:hide_bar(hand)
		end
	elseif db.show_condition == "has_target" then
		if not self.has_attackable_target then
			self:hide_bar(hand)
			return
		end
		if db.require_in_range then
			if not self:get_in_range(hand) then
				self:hide_bar(hand)
				return
			end
		end
		self:show_bar(hand)
	elseif db.show_condition == "both" then
		if not self.in_combat then
			self:hide_bar(hand)
			return
		end
		if not self.has_attackable_target then
			self:hide_bar(hand)
			return
		end
		if db.require_in_range then
			if not self:get_in_range(hand) then
				self:hide_bar(hand)
				return
			end
		end
		self:show_bar(hand)
	elseif db.show_condition == "either" then
		if self.in_combat then
			self:show_bar(hand)
			return
		end
		if not self.has_attackable_target then
			self:hide_bar(hand)
			return
		end
		if db.require_in_range then
			if not self:get_in_range(hand) then
				self:hide_bar(hand)
				return
			end
		end
		self:show_bar(hand)
	end
end

function ST:set_bar_visibilities()
	-- Function hooked onto the rangefinder C_Timer to determine bar states
	local db_class = self:get_class_table()
	if not db_class.class_enabled then
		for hand in self:iter_hands() do
			self:hide_bar(hand)
		end
	end

	for hand in self:iter_hands() do
		-- print(string.format("%s in range: %s", hand, tostring(in_range)))
		if not self:bar_is_enabled(hand) then
			self:hide_bar(hand)
		else
			self:handle_bar_visibility(hand)
		end
	end
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
	local register_func_string = "open_menu"
	self:RegisterChatCommand("st", register_func_string)
	self:RegisterChatCommand("swedgetimer", register_func_string)
	self:RegisterChatCommand("test1", "test1")
end

function ST:test1()
	-- local db = self:get_class_table()
	-- if db.bars_locked then
	-- 	self:Print("Unlocking bar frames")
	-- 	db.bars_locked = false
	-- 	self:unlock_frames()
	-- else
	-- 	self:Print("Locking bar frames")
	-- 	db.bars_locked = true
	-- 	self:lock_frames()
	-- end
end

function ST:open_menu()
	local ACD = LibStub("AceConfigDialog-3.0")
	ACD:Open(addon_name.."_Options")
end

if st.debug then st.utils.print_msg('-- Parsed main1.lua module correctly') end

--=========================================================================================
-- Funcs to apply per-class settings
--=========================================================================================
function ST:class_on_aura_change()
	local c = self.player_class
	if self[c].on_aura_change then
		self[c].on_aura_change(self)
	end
end

function ST:class_on_current_spell_cast_changed(is_cancelled)
	local c = self.player_class
	if self[c].on_current_spell_cast_changed then
		self[c].on_current_spell_cast_changed(self, is_cancelled)
	end
end
