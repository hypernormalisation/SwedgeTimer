------------------------------------------------------------------------------------
-- Module to contain config default
------------------------------------------------------------------------------------
local addon_name, st = ...
local LSM = LibStub("LibSharedMedia-3.0")
local ST = LibStub("AceAddon-3.0"):GetAddon(addon_name)
-- local print = st.utils.print_msg

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
		bar_full_delay = 0.3,

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

-- local contextual_visibility_values = {
-- 	in_combat = "In Combat",
-- 	has_attackable_target = "Has Attackable Target",
-- 	in_range = "In Range of Target",
-- }

-- local outline_map = {
-- 	_none="",
-- 	outline="OUTLINE",
-- 	thick_outline="THICKOUTLINE",
-- }
-- ST.outline_map = outline_map

-- local bar_border_modes = {
-- 	Solid="Solid",
-- 	Texture="Texture",
-- 	None="None",
-- }

-- ST.outlines = {
-- 	_none="None",
-- 	outline="Outline",
-- 	thick_outline="Thick Outline",
-- }

-- ST.texts = {
-- 	attack_speed="Attack speed",
-- 	swing_timer="Swing timer",
-- }

-- local gcd_padding_modes = {
-- 	Dynamic="Dynamic",
-- 	Fixed="Fixed",
-- 	None="None",
-- }

-- local valid_anchor_points = {
-- 	TOPLEFT="TOPLEFT",
--     TOPRIGHT="TOPRIGHT",
--     BOTTOMLEFT="BOTTOMLEFT",
--     BOTTOMRIGHT="BOTTOMRIGHT",
--     TOP="TOP",
--     BOTTOM="BOTTOM",
--     LEFT="LEFT",
--     RIGHT="RIGHT",
--     CENTER="CENTER",
-- }

local old_opts = {
	type = "group",
	name = addon_name,
	handler = ST,
	args = {

		------------------------------------------------------------------------------------
		-- Size/position options
		positioning = {
			type = "group",
			name = "Size and Position",
			handler = ST,
			order = 2,
			args = {

				------------------------------------------------------------------------------------
				-- position options
				position_header = {
					type = 'header',
					name = 'Position',
					order = 4,
				},
				position_description = {
					order=4.1,
					type="description",
					name="When the bar is not locked, it can be clicked and dragged with the mouse.",
				},
				position_description2 = {
					order=4.2,
					type="description",
					name="If you don't understand how UI frames anchor, then either keep both anchors on "..
					"CENTER and enter offsets manually, or position the bar with the mouse.",
				},
				bar_x_offset = {
					type = "input",
					order = 5,
					name = "Bar x offset",
					desc = "The x position of the bar.",
					get = function()
						return tostring(ST.db.profile.bar_x_offset)
					end,
					set = function(self, input)
						ST.db.profile.bar_x_offset = input
						set_bar_position()
					end			
				},
				bar_y_offset = {
					type = "input",
					order = 6,
					name = "Bar y offset",
					desc = "The y position of the bar.",
					get = function()
						return tostring(ST.db.profile.bar_y_offset)
					end,
					set = function(self, input)
						ST.db.profile.bar_y_offset = input
						set_bar_position()
					end			
				},

				bar_point = {
					order = 6.1,
					type="select",
					name = "Anchor",
					desc = "One of the region's anchors.",
					values = valid_anchor_points,
					get = "GetValue",
					set = function(self, input)
						ST.db.profile.bar_point = input
						set_bar_position()
					end,
				},
				bar_rel_point = {
					order = 6.2,
					type="select",
					name = "Relative anchor",
					desc = "Anchor point on region to align against.",
					values = valid_anchor_points,
					get = "GetValue",
					set = function(self, input)
						ST.db.profile.bar_rel_point = input
						set_bar_position()
					end,
				},
			},
		},

	}
}

--=========================================================================================
-- End, if debug verify module was read.
--=========================================================================================
if st.debug then print('-- Parsed config.lua module correctly') end
