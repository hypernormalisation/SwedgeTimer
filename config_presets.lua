------------------------------------------------------------------------------------
-- Module to contain config default settings for the addon, per class and global
------------------------------------------------------------------------------------
local addon_name, st = ...
local LSM = LibStub("LibSharedMedia-3.0")
local ST = LibStub("AceAddon-3.0"):GetAddon(addon_name)

ST.ROGUE = {}
ST.ROGUE.defaults = {

	-- Auto-hide setting
	visibility_key = "always",
    tag = "ROGUE",

	-- Mainhand options
	mainhand = {
		-- Visibility behaviour
        enabled = true,
        force_show_in_combat = true,
        hide_ooc = false, -- always overrides the other behaviours
        require_has_valid_target = true,
        require_in_range = false,
        

        -- Out of range behaviour
        effect = "dim",
        dim_alpha = 0.4,

        -- Bar dimensions
		bar_height = 16,
		bar_width = 285,
		-- Bar positioning
		bar_locked = true,
		bar_x_offset = 0,
		bar_y_offset = -124,
		bar_point = "CENTER",
		bar_rel_point = "CENTER",
		-- Bar textures
		bar_texture_key = "Solid",
		gcd_texture_key = "Solid",
		backplane_texture_key = "Solid",
		border_texture_key = "None",
		deadzone_texture_key = "Solid",
		backplane_alpha = 0.6,
		-- Colors
		bar_color_gcd = {0.48, 0.48, 0.48, 0.8},
		bar_color_deadzone = {0.72, 0.05, 0.05, 0.72},
		-- Font settings
		font_size = 12,
		font_color = {1.0, 1.0, 1.0, 1.0},
		text_font = "PT Sans Narrow",
		font_outline_key = "outline",
		left_text = "attack_speed",
		right_text = "swing_timer",
		-- Border settings
		border_mode_key = "Solid",
		backplane_outline_width = 1.5,
        -- GCD underlay settings
        show_gcd_underlay = true,
        -- Show GCD markers
        show_gcd_markers = true,
        -- Show range
        show_range_finder = true,
	},

	-- Offhand options
	offhand = {
		-- Visibility behaviour
        enabled = true,
        hide_ooc = false, -- always overrides the other behaviours
        force_show_in_combat = true,
        require_has_valid_target = true,
        require_in_range = false,

		-- Bar dimensions
		bar_height = 16,
		bar_width = 285,
		-- Bar positioning
		bar_locked = true,
		bar_x_offset = 0,
		bar_y_offset = -144,
		bar_point = "CENTER",
		bar_rel_point = "CENTER",
		-- Bar textures
		bar_texture_key = "Solid",
		gcd_texture_key = "Solid",
		backplane_texture_key = "Solid",
		border_texture_key = "None",
		deadzone_texture_key = "Solid",
		backplane_alpha = 0.6,
		-- Colors
		bar_color_default = {1, 66, 69, 1.0},
		bar_color_gcd = {0.48, 0.48, 0.48, 0.8},
		bar_color_deadzone = {0.72, 0.05, 0.05, 0.72},
		-- Font settings
		font_size = 12,
		font_color = {1.0, 1.0, 1.0, 1.0},
		text_font = "PT Sans Narrow",
		font_outline_key = "outline",
		left_text = "attack_speed",
		right_text = "swing_timer",
		-- Border settings
		border_mode_key = "Solid",
		backplane_outline_width = 0.5,
        -- GCD underlay settings
        show_gcd_underlay = false,
        -- Show GCD markers
        show_gcd_markers = false,
        -- Show range
        show_range_finder = false,
	},

	-- Ranged options
	ranged = {
		-- Visibility behaviour
        enabled = true,
        hide_ooc = false, -- always overrides the other behaviours
        force_show_in_combat = false,
        require_has_valid_target = true,
        require_in_range = true,

		-- Bar dimensions
		bar_height = 13,
		bar_width = 200,
		-- Bar positioning
		bar_locked = true,
		bar_x_offset = 0,
		bar_y_offset = -102,
		bar_point = "CENTER",
		bar_rel_point = "CENTER",
		-- Bar textures
		bar_texture_key = "Solid",
		gcd_texture_key = "Solid",
		backplane_texture_key = "Solid",
		border_texture_key = "None",
		deadzone_texture_key = "Solid",
		backplane_alpha = 0.6,
		-- Colors
		bar_color_default = {115, 17, 42, 1.0},
		bar_color_gcd = {0.48, 0.48, 0.48, 1.0},
		bar_color_deadzone = {0.72, 0.05, 0.05, 0.72},
		-- Font settings
		font_size = 11,
		font_color = {1.0, 1.0, 1.0, 1.0},
		text_font = "PT Sans Narrow",
		font_outline_key = "outline",
		left_text = "attack_speed",
		right_text = "swing_timer",
		-- Border settings
		border_mode_key = "Solid",
		backplane_outline_width = 1.5,
        -- GCD underlay settings
        show_gcd_underlay = false,
        -- Show GCD markers
        show_gcd_markers = false,
        -- Show range
        show_range_finder = true,
	},
}

--=========================================================================================
-- End, if debug verify module was read.
--=========================================================================================
if st.debug then print('-- Parsed config_presets.lua module correctly') end