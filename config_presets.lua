------------------------------------------------------------------------------------
-- Module to contain config default settings for the addon, per class and global
------------------------------------------------------------------------------------
local addon_name, st = ...
local LSM = LibStub("LibSharedMedia-3.0")
local ST = LibStub("AceAddon-3.0"):GetAddon(addon_name)



-- This table is used for any per-class settings that should apply globally.
ST.class_defaults = {
    class_enabled = true,
    timers_locked = true,
    bar_movement_mode = "all",
    enable_spec1 = true,
    enable_spec2 = true,
}

-- This table is used by AceDB's smart defaults feature
-- so we only have to override behaviour in class-specific tables.
ST.bar_defaults = {

    -- Visibility behaviour
    enabled = true,
    show_behaviour = "conditional",  -- can be conditional or always
    show_condition = "either",
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

    -- Timer bar appearance
    bar_texture_key = "Minimalist",
    bar_color_default = {93, 58, 207, 0.6},

    -- Background and border appearance
    background_color = {0.0, 0.0, 0.0, 0.85},
    background_texture_key = "Solid",

    border_color = {40, 40, 40, 0.95},
    border_texture_key = "Square Full White",
    border_width = 2,

    -- Bar Texts
    text_size = 14,
    text_color = {255, 255, 255, 1.0},
    text_font = "Expressway",
    text_outline_key = "outline",

    left_text_key  = "attack_speed",
    left_text_enabled = true,
    left_text_hide_inactive = false,
    left_text_x_percent_offset = 0,
    left_text_y_percent_offset = 0,

    center_text_key = "range_finder",
    center_text_enabled = false,
    center_text_hide_inactive = false,
    center_text_x_percent_offset = 0,
    center_text_y_percent_offset = 0,

    right_text_key = "swing_timer",
    right_text_enabled = true,
    right_text_hide_inactive = true,
    right_text_x_percent_offset = 0,
    right_text_y_percent_offset = 0,

    -- GCD underlay
    show_gcd_underlay = true,
    bar_color_gcd = {140, 140, 140, 0.85},
    gcd_texture_key = "Minimalist",

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
-- DEATHKNIGHT
------------------------------------------------------------------------------------
ST.DEATHKNIGHT.defaults = {
    -- Bar options
    ['**'] = ST.bar_defaults,
	mainhand = {
        enable_deadzone = true,
        gcd1a_marker_mode = "phys",
        gcd1b_marker_mode = "spell",
    },
	offhand = {
        y = -142,
		bar_color_default = {13, 79, 115, 0.8},
        show_gcd_underlay = false,
        gcd1a_marker_enabled = false,
        gcd1b_marker_enabled = false,
	},
}

------------------------------------------------------------------------------------
-- DRUID
------------------------------------------------------------------------------------
ST.DRUID.defaults = {
    -- Class-level options
    enable_maul_color = true,
    maul_color = {112, 19, 189, 1.0},
    insufficient_rage_color = {140, 140, 140, 1.0},

    -- Form-dependent visibility defaults
    form_vis_normal = true,
    form_vis_bear = true,
    form_vis_cat = true,
    form_vis_moonkin = true,
    form_vis_tree = true,
    form_vis_travel = true,
    form_vis_flight = true,

    use_form_colors = true,
    form_color_bear = {159, 4, 44, 1.0},
    form_color_cat = {189, 126, 9, 1.0},
    form_color_moonkin = {4, 148, 214, 1.0},
    form_color_tree = {4, 204, 124, 1.0},
    form_color_travel = {18, 85, 201, 1.0},
    form_color_flight = {18, 85, 201, 1.0},

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

    enable_raptor_strike_color = true,
    raptor_strike_color = {207, 58, 83, 1.0},

    -- Bar options
    ['**'] = ST.bar_defaults,
    mainhand = {
        require_in_range = true,
        show_condition = "both",
        bar_height = 14,
		bar_width = 200,
        show_gcd_underlay = false,
        gcd1a_marker_enabled = false,
        gcd1b_marker_enabled = false,
        border_width = 1,
        text_size = 10,
        y = -142,
    },
    offhand = {
        require_in_range = true,
        show_condition = "both",
		bar_color_default = {13, 79, 115, 0.8},
        show_gcd_underlay = false,
        gcd1a_marker_enabled = false,
        gcd1b_marker_enabled = false,
        bar_height = 14,
		bar_width = 200,
        text_size = 10,
        border_width = 1,
        y = -158,
	},
	ranged = {
        enable_deadzone = true,
        require_in_range = false,
        force_show_in_combat = false,
		bar_color_default = {6, 143, 47, 0.8},
        gcd1a_marker_enabled = false,
        gcd1b_marker_enabled = false,
        show_gcd_underlay = true,
        center_text_enabled = true,
	},
}

------------------------------------------------------------------------------------
-- MAGE
------------------------------------------------------------------------------------
ST.MAGE.defaults = {
    class_enabled = false,
    -- Bar options
    ['**'] = ST.bar_defaults,
    mainhand = {
        enabled = false,
        y = -142,
        gcd1a_marker_mode = "spell",
        gcd1b_marker_mode = "spell",

    },
    ranged = {
        bar_x_offset = 0,
		bar_y_offset = -102,
        bar_color_default = {125, 10, 201, 1.0},
        gcd1a_marker_mode = "spell",
        gcd1b_marker_mode = "spell",
    }
}

------------------------------------------------------------------------------------
-- PALADIN
------------------------------------------------------------------------------------
ST.PALADIN.defaults = {
    tag = "PALADIN",
    has_class_options = true,

    use_seal_colors = true,
    soc_color = {47, 128, 10, 1.0},
    sov_color = {192, 60, 38, 1.0},
    sol_color = {6, 140, 104, 1.0},
    sow_color = {22, 100, 117, 1.0},
    sor_color = {207, 58, 165, 1.0},
    soj_color = {204, 185, 18, 1.0},

    use_aow_glow = true,
    require_exo_ready = true,
    aow_glow_color = {209, 198, 115, 1.0},
    aow_glow_nlines = 12,
    aow_glow_freq = 0.1,
    aow_glow_line_length = 12,

    -- Bar options
    ['**'] = ST.bar_defaults,
	mainhand = {

        -- bar_color_default = {150, 18, 97, 0.9},

        enable_deadzone = true,
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
    -- Bar options
    ['**'] = ST.bar_defaults,
    mainhand = {
        enabled = false,
        y = -142,
        gcd1a_marker_mode = "spell",
        gcd1b_marker_mode = "spell",

    },
    ranged = {
        bar_x_offset = 0,
		bar_y_offset = -102,
        bar_color_default = {125, 10, 201, 1.0},
        gcd1a_marker_mode = "spell",
        gcd1b_marker_mode = "spell",
    }
}

------------------------------------------------------------------------------------
-- ROGUE
------------------------------------------------------------------------------------
ST.ROGUE.defaults = {
    -- Bar options
    ['**'] = ST.bar_defaults,
	mainhand = {
        enable_deadzone = true,
    },
	offhand = {
        y = -142,
		bar_color_default = {13, 79, 115, 0.8},
        show_gcd_underlay = false,
        gcd1a_marker_enabled = false,
        gcd1b_marker_enabled = false,
	},
	ranged = {
        enabled = false,
        show_behaviour = "conditional",
        show_condition = "either",
        require_in_range = true,
		bar_height = 15,
		bar_width = 200,
        y = -166,
		bar_color_default = {112, 8, 11, 0.8},
		font_size = 10,
        show_gcd_underlay = false,
        show_gcd_markers = false,
        show_range_finder = true,
        gcd1a_marker_enabled = false,
        gcd1b_marker_enabled = false,
	},
}

------------------------------------------------------------------------------------
-- SHAMAN
------------------------------------------------------------------------------------
ST.SHAMAN.defaults = {
    -- Bar options
    ['**'] = ST.bar_defaults,
	mainhand = {
        enable_deadzone = true,
        gcd1a_marker_mode = "phys",
        gcd1b_marker_mode = "spell",
    },
	offhand = {
        y = -142,
		bar_color_default = {13, 79, 115, 0.8},
        show_gcd_underlay = false,
        gcd1a_marker_enabled = false,
        gcd1b_marker_enabled = false,
	},
}

------------------------------------------------------------------------------------
-- WARLOCK
------------------------------------------------------------------------------------
ST.WARLOCK.defaults = {
    class_enabled = false,
    -- Bar options
    ['**'] = ST.bar_defaults,
    mainhand = {
        y = -142,
        enabled = false,
        gcd1a_marker_mode = "spell",
        gcd1b_marker_mode = "spell",

    },
    ranged = {
        bar_x_offset = 0,
		bar_y_offset = -102,
        bar_color_default = {125, 10, 201, 1.0},
        gcd1a_marker_mode = "spell",
        gcd1b_marker_mode = "spell",
    }
}

------------------------------------------------------------------------------------
-- WARRIOR
------------------------------------------------------------------------------------
ST.WARRIOR.defaults = {
    -- Class-level options
    enable_hs_color = true,
    hs_color = {130, 7, 9, 1.0},
    enable_cleave_color = true,
    cleave_color = {64, 130, 7, 1.0},
    insufficient_rage_color = {140, 140, 140, 1.0},

    use_bloodsurge_glow = true,
    bloodsurge_glow_color = {227, 57, 74, 1.0},
    bloodsurge_glow_nlines = 12,
    bloodsurge_glow_freq = 0.1,
    bloodsurge_glow_line_length = 12,

    hide_in_tank_spec = false,
    hide_in_arms_spec = false,

    -- Bar options
    ['**'] = ST.bar_defaults,
	mainhand = {
        enable_deadzone = true,
    },
	offhand = {
        y = -142,
		bar_color_default = {13, 79, 115, 0.8},
        show_gcd_underlay = false,
        gcd1a_marker_enabled = false,
        gcd1b_marker_enabled = false,
	},
	ranged = {
        enabled = false,
        show_behaviour = "conditional",
        show_condition = "either",
        require_in_range = true,
		bar_height = 15,
		bar_width = 200,
        y = -166,
		bar_color_default = {112, 8, 11, 0.8},
		font_size = 10,
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