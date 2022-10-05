------------------------------------------------------------------------------------
-- Module to contain config default
------------------------------------------------------------------------------------
local addon_name, st = ...
local LSM = LibStub("LibSharedMedia-3.0")
local ST = LibStub("AceAddon-3.0"):GetAddon(addon_name)
-- local print = st.utils.print_msg
local LWIN = LibStub("LibWindow-1.1")

------------------------------------------------------------------------------------
-- Default settings for the addon.
ST.defaults = {

	profile = {

		-- Top level
		welcome_message = true,
		bars_locked = true,
		enabled = true, -- top level control

		-- Frame strata/draw level
		frame_strata = "MEDIUM",
		draw_level = 10,

		-- Bar visual behaviour
		bar_full_delay = 0.05,

		-- Latency scale factors.
		latency_linear_offset = 0.0,
		latency_scale_factor = 1.0,

		-- GCD marker offsets
		gcd_marker_offset_mode = "None",
		gcd_marker_offset_scale_factor = 1.0,
		gcd_marker_fixed_offset = 50,

		-- Deadzone
		deadzone_scale_factor = 1.4,

		-- Class-specific defaults
		['**'] = ST.class_defaults,
		DEATHKNIGHT = ST.DEATHKNIGHT.defaults,
		DRUID = ST.DRUID.defaults,
		HUNTER = ST.HUNTER.defaults,
		MAGE = ST.MAGE.defaults,
		PALADIN = ST.PALADIN.defaults,
		PRIEST = ST.PRIEST.defaults,
		ROGUE = ST.ROGUE.defaults,
		SHAMAN = ST.SHAMAN.defaults,
		WARLOCK = ST.WARLOCK.defaults,
		WARRIOR = ST.WARRIOR.defaults,
    },

}

--=========================================================================================
-- Functions to handle options
--=========================================================================================
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

function ST:handle_bar_positioning()
	local db_class = self:get_class_table()
end

function ST:move_together_dragstart()
	for h in self:iter_hands() do
		print(h)
		local f = self:get_frame(h)
		LWIN.OnDragStart(f)
		-- LWIN.windowData[f].isDragging = true
		-- f:StartMoving()
	end
end

function ST:move_together_dragstop()
	for h in self:iter_hands() do
		local f = self:get_frame(h)
		-- LWIN.windowData[f].isDragging = false
		-- f:StopMovingOrSizing()
		LWIN.OnDragStop(f)
		-- LWIN.SavePosition(f)
	end
end

--=========================================================================================
-- End, if debug verify module was read.
--=========================================================================================
if st.debug then print('-- Parsed config.lua module correctly') end
