------------------------------------------------------------------------------------
-- Module to contain config default settings for the addon, per class and global
------------------------------------------------------------------------------------
local addon_name, st = ...
local LSM = LibStub("LibSharedMedia-3.0")
local ST = LibStub("AceAddon-3.0"):GetAddon(addon_name)



-- This table is used for any per-class settings that should apply globally.
ST.class_defaults = {
    class_enabled = true,
    bars_locked = true,
    bar_movement_mode = "all",
}

-- This table is used by AceDB's smart defaults feature
-- so we only have to override behaviour in class-specific tables.
ST.bar_defaults = {

    -- Visibility behaviour
    enabled = true,
    show_behaviour = "conditional",  -- can be conditional or always
    show_condition = "has_target",
    require_in_range = false,

    -- Out of range behaviour
    dim_oor = true,
    dim_alpha = 0.6,

    -- Bar dimensions
    bar_height = 20,
    bar_width = 275,

    -- Bar positions (handled by LibWindow-1.1)
    x = 0,
    y = -120,
    point = "CENTER",
    scale = 1,

    -- Bar appearance
    bar_texture_key = "Solid",
    border_texture_key = "None",
    bar_color_default = {137, 56, 27, 0.6},

    -- Backplane and border
    backplane_alpha = 0.85,
    backplane_texture_key = "Solid",
    border_mode_key = "Solid",
    backplane_outline_width = 2.0,

    -- Bar Texts
    text_size = 14,
    text_color = {255, 255, 255, 1.0},
    text_font = "PT Sans Narrow",
    text_outline_key = "outline",

    left_text_key  = "attack_speed",
    left_text_enabled = true,
    left_text_hide_inactive = false,
    left_text_x_percent_offset = 0,
    left_text_y_percent_offset = 0,


    right_text_key = "swing_timer",
    right_text_enabled = true,
    right_text_hide_inactive = true,
    right_text_x_percent_offset = 0,
    right_text_y_percent_offset = 0,

    -- GCD underlay
    show_gcd_underlay = true,
    bar_color_gcd = {140, 140, 140, 0.85},
    gcd_texture_key = "Solid",

    -- GCD markers
    gcd1a_marker_enabled = true,
    gcd1a_marker_anchor = "endofswing",
    gcd1a_marker_hide_inactive = true,
    gcd1a_marker_mode = "phys",
    gcd1a_marker_color = {230, 230, 230, 1.0},
    gcd1a_marker_width = 3,
    gcd1a_marker_fractional_height = 0.25,
    gcd1a_swing_anchor_wrap = true,

    gcd1b_marker_enabled = true,
    gcd1b_marker_anchor = "endofswing",
    gcd1b_marker_hide_inactive = true,
    gcd1b_marker_mode = "phys",
    gcd1b_marker_color = {230, 230, 230, 1.0},
    gcd1b_marker_width = 3,
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
-- DEATHKNIGHT
------------------------------------------------------------------------------------
ST.DEATHKNIGHT.defaults = {
    tag = "DEATHKNIGHT",
    has_class_options = false,
    -- Bar options
    ['**'] = ST.bar_defaults,
}

------------------------------------------------------------------------------------
-- DRUID
------------------------------------------------------------------------------------
ST.DRUID.defaults = {
    tag = "DRUID",
    has_class_options = true,
    -- Class-level options
    enable_maul_color = true,
    maul_color = {224, 76, 116, 1.0},
    insufficient_rage_color = {140, 140, 140, 1.0},

    use_form_colors = true,
    form_color_bear = {159, 4, 44, 1.0},
    form_color_cat = {189, 126, 9, 1.0},
    form_color_moonkin = {4, 148, 214, 1.0},
    form_color_tree = {4, 204, 124, 1.0},

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
-- HUNTER
------------------------------------------------------------------------------------
ST.HUNTER.defaults = {
    tag = "HUNTER",
    has_class_options = false,
    -- Bar options
    ['**'] = ST.bar_defaults,
    mainhand = {
        require_in_range = true,
    },
    offhand = {
        require_in_range = true,
		bar_x_offset = 0,
		bar_y_offset = -144,
		bar_color_default = {1, 66, 69, 0.8},
        show_gcd_underlay = false,
        gcd1_marker_enabled = false,

	},
	ranged = {
        require_in_range = false,
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
-- MAGE
------------------------------------------------------------------------------------
ST.MAGE.defaults = {
    class_enabled = false,
    tag = "MAGE",
    has_class_options = false,
    -- Bar options
    ['**'] = ST.bar_defaults,
    mainhand = {
        enabled = false,
    },
    ranged = {
        bar_x_offset = 0,
		bar_y_offset = -102,
        bar_color_default = {10, 160, 201, 1.0},
    }
}

------------------------------------------------------------------------------------
-- PALADIN
------------------------------------------------------------------------------------
ST.PALADIN.defaults = {
    tag = "PALADIN",
    has_class_options = true,

    use_seal_colors = true,
    soc_color = {70, 150, 36, 1.0},
    sov_color = {199, 157, 18, 1.0},
    sol_color = {42, 189, 125, 1.0},
    sow_color = {36, 171, 201, 1.0},
    sor_color = {102, 96, 209, 1.0},

    use_aow_glow = true,
    require_exo_ready = true,
    aow_glow_color = {209, 198, 115, 1.0},
    aow_glow_nlines = 12,
    aow_glow_freq = 0.03,
    aow_glow_line_length = 24,
    aow_glow_line_thickness = 1,
    aow_glow_offset = 1,

    -- Bar options
    ['**'] = ST.bar_defaults,
	mainhand = {
        enable_deadzone = true,
        bar_height = 22,
        bar_width = 280,
        text_size = 14,
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
-- PRIEST
------------------------------------------------------------------------------------
ST.PRIEST.defaults = {
    class_enabled = false,
    tag = "PRIEST",
    has_class_options = false,
    -- Bar options
    ['**'] = ST.bar_defaults,
    mainhand = {
        enabled = false,
    },
    ranged = {
        bar_x_offset = 0,
		bar_y_offset = -102,
        bar_color_default = {159, 194, 204, 1.0},
    }
}

------------------------------------------------------------------------------------
-- ROGUE
------------------------------------------------------------------------------------
ST.ROGUE.defaults = {
    tag = "ROGUE",
    has_class_options = false,
    -- Bar options
    ['**'] = ST.bar_defaults,
	mainhand = {
        enable_deadzone = true,
    },
	offhand = {
		bar_x_offset = 0,
		bar_y_offset = -144,
		bar_color_default = {1, 66, 69, 1.0},
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
		bar_color_default = {115, 17, 42, 1.0},
		font_size = 11,
        show_gcd_underlay = false,
        show_gcd_markers = false,
        show_range_finder = true,
	},
}

------------------------------------------------------------------------------------
-- SHAMAN
------------------------------------------------------------------------------------
ST.SHAMAN.defaults = {
    tag = "SHAMAN",
    has_class_options = false,
    -- Bar options
    ['**'] = ST.bar_defaults,
	mainhand = {
        bar_color_default = {35, 39, 173, 1.0},
        enable_deadzone = true,
    },
	offhand = {
		bar_x_offset = 0,
		bar_y_offset = -144,
		bar_color_default = {95, 98, 194, 1.0},
        show_gcd_underlay = false,
        gcd1_marker_enabled = false,
	},
}

------------------------------------------------------------------------------------
-- WARLOCK
------------------------------------------------------------------------------------
ST.WARLOCK.defaults = {
    class_enabled = false,
    tag = "WARLOCK",
    has_class_options = false,
    -- Bar options
    ['**'] = ST.bar_defaults,
    mainhand = {
        enabled = false,
    },
    ranged = {
        bar_x_offset = 0,
		bar_y_offset = -102,
        bar_color_default = {125, 10, 201, 1.0},
    }
}

------------------------------------------------------------------------------------
-- WARRIOR
------------------------------------------------------------------------------------
ST.WARRIOR.defaults = {
    tag = "WARRIOR",
    has_class_options = true,
    -- Class-level options
    enable_hs_color = true,
    hs_color = {224, 96, 116, 1.0},
    enable_cleave_color = true,
    cleave_color = {154, 219, 68, 1.0},
    insufficient_rage_color = {140, 140, 140, 1.0},
    -- Bar options
    ['**'] = ST.bar_defaults,
	mainhand = {
        enable_deadzone = true,
    },
	offhand = {
        y = -160,
		bar_color_default = {1, 66, 69, 0.8},
        show_gcd_underlay = false,
        gcd1a_marker_enabled = false,
        gcd1b_marker_enabled = false,
	},
	ranged = {
        require_in_range = true,
		bar_height = 13,
		bar_width = 200,
        y = 60,
		bar_color_default = {191, 88, 29, 0.8},
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