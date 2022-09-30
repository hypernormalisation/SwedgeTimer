------------------------------------------------------------------------------------
-- Module to contain config default settings for the addon, per class and global
------------------------------------------------------------------------------------
local addon_name, st = ...
local LSM = LibStub("LibSharedMedia-3.0")
local ST = LibStub("AceAddon-3.0"):GetAddon(addon_name)

-- This table is used for any per-class settings that should apply globally.
ST.class_defaults = {
}

-- This table is used by AceDB's smart defaults feature
-- so we only have to override behaviour in class-specific tables.
ST.bar_defaults = {
    
    -- Visibility behaviour
    enabled = true,
    force_show_in_combat = true,
    hide_ooc = false, -- always overrides the other behaviours
    require_has_valid_target = true,
    require_in_range = false,

    -- Out of range behaviour
    oor_effect = "dim",
    dim_alpha = 0.6,

    -- Bar dimensions/positioning
    bar_height = 16,
    bar_width = 285,
    bar_locked = true,
    bar_x_offset = 0,
    bar_y_offset = -124,
    bar_point = "CENTER",
    bar_rel_point = "CENTER",

    -- Bar appearance
    bar_texture_key = "Solid",
    border_texture_key = "None",
    bar_color_default = {137, 56, 27, 0.6},

    -- Backplane and border
    backplane_alpha = 0.85,
    backplane_texture_key = "Solid",
    border_mode_key = "Solid",
    backplane_outline_width = 1.5,

    -- Bar Texts
    text_size = 12,
    text_color = {1.0, 1.0, 1.0, 1.0},
    text_font = "PT Sans Narrow",
    text_outline_key = "outline",

    left_text_key  = "attack_speed",
    left_text_enabled = true,
    left_text_hide_inactive = false,

    right_text_key = "swing_timer",
    right_text_enabled = true,
    right_text_hide_inactive = true,

    -- GCD underlay
    show_gcd_underlay = true,
    bar_color_gcd = {0.42, 0.42, 0.42, 0.8},
    gcd_texture_key = "Solid",

    -- GCD markers
    gcd1a_marker_enabled = true,
    gcd1a_marker_anchor = "endofswing",
    gcd1a_marker_hide_inactive = true,
    gcd1a_marker_mode = "phys",
    gcd1a_marker_color = {230, 230, 230, 1.0},
    gcd1a_marker_width = 2,
    gcd1a_marker_fractional_height = 0.25,
    gcd1a_swing_anchor_wrap = true,

    gcd1b_marker_enabled = true,
    gcd1b_marker_anchor = "endofswing",
    gcd1b_marker_hide_inactive = true,
    gcd1b_marker_mode = "phys",
    gcd1b_marker_color = {230, 230, 230, 1.0},
    gcd1b_marker_width = 2,
    gcd1b_marker_fractional_height = 0.25,
    gcd1b_swing_anchor_wrap = true,

    -- Deadzone settings
    enable_deadzone = false,
    deadzone_texture_key = "Solid",
    deadzone_bar_color = {141, 59, 81, 0.82},
    deadzone_hide_inactive = true,

    -- Show range
    show_range_finder = false,

}

------------------------------------------------------------------------------------
-- DRUID
------------------------------------------------------------------------------------
ST.DRUID.defaults = {
    tag = "DRUID",

    -- Class-level options
    enable_maul_color = true,
    maul_color = {224, 76, 116, 1.0},
    insufficient_rage_color = {140, 140, 140, 1.0},

    use_form_colors = true,
    form_color_bear = {159, 4, 44, 1.0},
    form_color_cat = {189, 126, 9, 1.0},
    form_color_moonkin = {4, 148, 214, 1.0},
    form_color_tree = {4, 204, 124, 1.0},
    -- form_color_normal = {4, 148, 214, 1.0},

    -- Bar options
    ['**'] = ST.bar_defaults,
    mainhand = {
        enable_deadzone = true,
        bar_color_default = {18, 85, 201, 1.0},
        gcd1a_marker_mode = "form",
        gcd1b_marker_mode = "form",
    },
    offhand = {
        enabled = false,
    },
    ranged = {
        enabled = false,
    },
}

------------------------------------------------------------------------------------
-- PALADIN
------------------------------------------------------------------------------------
ST.PALADIN.defaults = {
    tag = "PALADIN",

    use_seal_colors = true,
    soc_color = {70, 150, 36, 1.0},
    sov_color = {181, 181, 5, 1.0},
    sol_color = {42, 189, 125, 1.0},
    sow_color = {36, 171, 201, 1.0},
    sor_color = {102, 96, 209, 1.0},

    use_aow_color = false,
    aow_color = {235, 235, 174, 1.0},

    -- Bar options
    ['**'] = ST.bar_defaults,
	mainhand = {
        enable_deadzone = true,
        bar_color_default = {120, 120, 120, 0.95},
        gcd1a_marker_mode = "phys",
        gcd1b_marker_mode = "spell",
        -- gcd1a_marker_anchor = "swing",
        -- gcd1b_marker_anchor = "swing",
        gcd1a_swing_anchor_wrap = false,
        gcd1b_swing_anchor_wrap = false,
    },
}

------------------------------------------------------------------------------------
-- ROGUE
------------------------------------------------------------------------------------
ST.ROGUE.defaults = {

    tag = "ROGUE",

    -- Bar options
    ['**'] = ST.bar_defaults,
	mainhand = {
        enable_deadzone = true,
    },
	offhand = {
		bar_x_offset = 0,
		bar_y_offset = -144,
		bar_color_default = {1, 66, 69, 0.8},
        show_gcd_underlay = false,
        gcd1_marker_enabled = false,

	},
	ranged = {
        require_in_range = true,
        force_show_in_combat = false,
		bar_height = 13,
		bar_width = 200,
		bar_x_offset = 0,
		bar_y_offset = -102,
		bar_color_default = {115, 17, 42, 0.8},
		font_size = 11,
        show_gcd_underlay = false,
        show_gcd_markers = false,
        show_range_finder = true,
	},
}

------------------------------------------------------------------------------------
-- WARRIOR
------------------------------------------------------------------------------------
ST.WARRIOR.defaults = {
    tag = "WARRIOR",

    -- Class-level options
    enable_hs_color = true,
    hs_color = {224, 76, 116, 1.0},
    enable_cleave_color = true,
    cleave_color = {154, 219, 68, 1.0},
    insufficient_rage_color = {140, 140, 140, 1.0},

    -- Bar options
    ['**'] = ST.bar_defaults,
	mainhand = {
        enable_deadzone = true,
    },
	offhand = {
		bar_x_offset = 0,
		bar_y_offset = -144,
		bar_color_default = {1, 66, 69, 0.8},
        show_gcd_underlay = false,
        gcd1a_marker_enabled = false,
        gcd1b_marker_enabled = false,
	},
	ranged = {
        require_in_range = true,
        force_show_in_combat = false,
		bar_height = 13,
		bar_width = 200,
		bar_x_offset = 0,
		bar_y_offset = -102,
		bar_color_default = {115, 17, 42, 0.8},
		font_size = 11,
        show_gcd_underlay = false,
        show_gcd_markers = false,
        show_range_finder = true,
        gcd1a_marker_enabled = false,
        gcd1b_marker_enabled = false,
	},
}

--=========================================================================================
-- End, if debug verify module was read.
--=========================================================================================
if st.debug then print('-- Parsed config_presets.lua module correctly') end