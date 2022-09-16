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
	
	-- Mainhand options
	mainhand = {
        tag = "ROGUE",
		-- behaviour
		enabled = true,
		-- Bar dimensions
		bar_height = 24,
		bar_width = 345,
		-- Bar positioning
		bar_locked = true,
		bar_x_offset = 0,
		bar_y_offset = -100,
		bar_point = "CENTER",
		bar_rel_point = "CENTER",
		-- Bar textures
		bar_texture_key = "Solid",
		gcd_texture_key = "Solid",
		backplane_texture_key = "Solid",
		border_texture_key = "None",
		deadzone_texture_key = "Solid",
		backplane_alpha = 0.85,
		-- Colors
		bar_color_default = {255, 209, 56, 1.0},
		bar_color_gcd = {0.48, 0.48, 0.48, 1.0},
		bar_color_deadzone = {0.72, 0.05, 0.05, 0.72},
		-- Font settings
		font_size = 16,
		font_color = {1.0, 1.0, 1.0, 1.0},
		text_font = LSM.DefaultMedia.font,
		font_outline_key = "outline",
		left_text = "attack_speed",
		right_text = "swing_timer",
		-- Border settings
		border_mode_key = "Solid",
		backplane_outline_width = 2,
        -- GCD underlay settings
        show_gcd_underlay = true,
	},

	-- Offhand options
	offhand = {
		-- behaviour
		enabled = true,
		-- Bar dimensions
		bar_height = 24,
		bar_width = 345,
		-- Bar positioning
		bar_locked = true,
		bar_x_offset = 0,
		bar_y_offset = -130,
		bar_point = "CENTER",
		bar_rel_point = "CENTER",
		-- Bar textures
		bar_texture_key = "Solid",
		gcd_texture_key = "Solid",
		backplane_texture_key = "Solid",
		border_texture_key = "None",
		deadzone_texture_key = "Solid",
		backplane_alpha = 0.85,
		-- Colors
		bar_color_default = {230, 199, 97, 1.0},
		bar_color_gcd = {0.48, 0.48, 0.48, 1.0},
		bar_color_deadzone = {0.72, 0.05, 0.05, 0.72},
		-- Font settings
		font_size = 16,
		font_color = {1.0, 1.0, 1.0, 1.0},
		text_font = LSM.DefaultMedia.font,
		font_outline_key = "outline",
		left_text = "attack_speed",
		right_text = "swing_timer",
		-- Border settings
		border_mode_key = "Solid",
		backplane_outline_width = 2,
        -- GCD underlay settings
        show_gcd_underlay = false,
	},

	-- Ranged options
	ranged = {
		-- behaviour
		enabled = true,
		-- Bar dimensions
		bar_height = 24,
		bar_width = 345,
		-- Bar positioning
		bar_locked = true,
		bar_x_offset = 0,
		bar_y_offset = 20,
		bar_point = "CENTER",
		bar_rel_point = "CENTER",
		-- Bar textures
		bar_texture_key = "Solid",
		gcd_texture_key = "Solid",
		backplane_texture_key = "Solid",
		border_texture_key = "None",
		deadzone_texture_key = "Solid",
		backplane_alpha = 0.85,
		-- Colors
		bar_color_default = {0.14, 0.66, 0.14, 1.0},
		bar_color_gcd = {0.48, 0.48, 0.48, 1.0},
		bar_color_deadzone = {0.72, 0.05, 0.05, 0.72},
		-- Font settings
		font_size = 16,
		font_color = {1.0, 1.0, 1.0, 1.0},
		text_font = LSM.DefaultMedia.font,
		font_outline_key = "outline",
		left_text = "attack_speed",
		right_text = "swing_timer",
		-- Border settings
		border_mode_key = "Solid",
		backplane_outline_width = 2,
        -- GCD underlay settings
        show_gcd_underlay = false,
	},
}

--=========================================================================================
-- End, if debug verify module was read.
--=========================================================================================
if st.debug then print('-- Parsed config_presets.lua module correctly') end