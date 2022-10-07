--=========================================================================================
-- Module to contain presets for the options table generation
--=========================================================================================
local addon_name, st = ...
local ST = LibStub("AceAddon-3.0"):GetAddon(addon_name)
local LSM = LibStub("LibSharedMedia-3.0")

--=========================================================================================
-- Selections and orderings for dropdowns
--=========================================================================================
ST.valid_anchor_points = {
	TOPLEFT="TOPLEFT",
    TOPRIGHT="TOPRIGHT",
    BOTTOMLEFT="BOTTOMLEFT",
    BOTTOMRIGHT="BOTTOMRIGHT",
    TOP="TOP",
    BOTTOM="BOTTOM",
    LEFT="LEFT",
    RIGHT="RIGHT",
    CENTER="CENTER",
}

ST.outlines = {
	_none="None",
	outline="Outline",
	thick_outline="Thick Outline",
}

ST.texts = {
	attack_speed="Attack speed",
	swing_timer="Swing timer",
}

ST.bar_border_modes = {
	Solid="Solid",
	Texture="Texture",
	None="None",
}

ST.gcd_anchor_points = {
    endofswing = "End of Swing",
    swing = "Swing",
}

ST.gcd_marker_modes = {
    DRUID = {
        phys = "Physical GCD",
        spell = "Spell GCD",
        form = "Form-dependent",
    },
    NONDRUID = {
        phys = "Physical GCD",
        spell = "Spell GCD",
    },
}

ST.gcd_marker_offsets = {
    None = "None",
    Fixed = "Fixed",
    Dynamic = "Dynamic",
    Calibrated = "Calibrated",
}

ST.show_bar_opts = {
    always = "Always",
    conditional = "Conditionally",
}

ST.show_bar_conditions = {
    in_combat = "In Combat",
    has_target = "Has attackable target",
    both = "In Combat and has target",
    either = "In Combat or has target",
}

ST.show_bar_conditions_sorting = {
    [1] = "in_combat",
    [2] = "has_target",
    [3] = "either",
    [4] = "both",
}

--=========================================================================================
-- Functions to create the preset tables
--=========================================================================================
function ST:construct_latency_settings_table()
    -- Latency options
    ST.latency_presets = {
        header_latency = {
            order = 3.0,
            type = "header",
            name = "GCD Marker Offsets",
        },
        desc_latency = {
            order = 3.05,
            type = "description",
            name = "These options control fixed or latency-based offsets to the GCD marker positions. "..
            "This can help give a more representative picture of available time to act before a swing.",
        },
        gcd_marker_offset_mode = {
            type = "select",
            order = 3.1,
            name = "Marker Offset Mode",
            desc = "The type of offset, if any, to apply to the GCD marker positions. Fixed applies the specified "..
                "offset, Dynamic applies an offset based on latency, Calibrated combines the Fixed "..
                "and Dynamic offsets.",
            values = ST.gcd_marker_offsets,
            get = "getter",
            set = "latency_setter",
        },
        latency_linear_offset = {
            type = "range",
            order = 3.2,
            name = "Fixed Offset (ms)",
            desc = "Value in ms to add to Fixed or Calibrated latency.",
            min = 0, max = 200, step = 1,
            get = "getter",
            set = "latency_setter",
            disabled = function()
                local db = ST:get_profile_table()
                local is_fixed = db.gcd_marker_offset_mode == "Fixed"
                local is_calibrated = db.gcd_marker_offset_mode == "Calibrated"
                return not (is_fixed or is_calibrated)
            end,
        },
    }
end

function ST:construct_strata_settings_table()
    ST.draw_level_presets = {
        header_strata = {
            order = 4.0,
            type = "header",
            name = "Frame Strata and Draw Levels",
        },
        desc_strata = {
            order = 4.05,
            type = "description",
            name = "These options control the frame strata and draw levels of the addon's timers."..
                " Anything higher than MEDIUM will be drawn over some in-game menus, "..
                "so this is the highest strata allowed.",
        },
        frame_strata = {
            order = 7.2,
            type="select",
            name = "Frame strata",
            desc = "The frame strata the addon's timers should be drawn at.",
            values = {
                BACKGROUND = "BACKGROUND",
                LOW = "LOW",
                MEDIUM = "MEDIUM",
            },
            get = "getter",
            set = "strata_setter",
        },
        draw_level = {
            type = "range",
            order = 7.3,
            name = "Draw level",
            desc = "The bar's draw level within the frame strata.",
            min = 1, max=100, step=1,
            get = "getter",
            set = "strata_setter",
        },
    }
end

function ST:construct_delay_settings_table()
    ST.delay_on_full_settings = {
        delay_on_full_header = {
            type = "header",
            order = 9,
            name = "Delay on Inactive State"
        },
        delay_on_full_desc = {
            type = "description",
            order = 9.1,
            name = "SwedgeTimer allows for the timer's visual state to change when filling (active) and full "..
                "(inactive). This setting allows the user to specify a delay once the progress bar fills up before "..
                "the timer changes to the inactive state, to prevent the timer state rapidly shifting between "..
                "active/inactive due to latency effects."
        },
        bar_full_delay = {
            type = "range",
            order = 9.2,
            name = "Delay (s)",
            desc = "SwedgeTimer allows for different timer configurations when the swing timer bar is " ..
                "full or filling. A delay can be set to prevent these states rapidaly changing during normal " ..
                "combat.",
            get = "getter",
            set = "setter",
            min = 0, max = 1.0, step = 0.01,
        },
    }
end

function ST:construct_advanced_settings_table()
    ST.behaviour_group = {
        type = "group",
        name = "Advanced Behaviour",
        desc = "Panel controlling advanced addon behaviour.",
        order = 9.0,
        args = {},
    }
    for k, v in pairs(ST.latency_presets) do
        ST.behaviour_group.args[k] = v
    end
    for k, v in pairs(ST.draw_level_presets) do
        ST.behaviour_group.args[k] = v
    end
    for k, v in pairs(ST.delay_on_full_settings) do
        ST.behaviour_group.args[k] = v
    end
end

function ST:construct_bar_appearance_settings_table()
    ST.bar_appearance_preset = {

        -- Bar size options
        size_header = {
            order = 0.1,
            name = "Bar Dimensions",
            type = "header",
        },
        size_desc = {
            order = 0.11,
            name = "It is recommended to change the timer dimensions to a ratio you like and adjust the overall "..
            "size of the bar using the scale setting (either mousewheel scroll with the timer unlocked, or use the "..
            "Positioning/Scale panel.",
            type = "description",
        },
        bar_width = {
            type = "range",
            order = 0.2,
            name = "Width",
            desc = "The width of the swing timer.",
            min = 100, max = 600, step = 1,
            get = "getter",
            set = "bar_setter",
        },
        bar_height = {
            type = "range",
            order = 0.3,
            name = "Height",
            desc = "The height of the swing timer.",
            min = 6, max = 60, step = 1,
            get = "getter",
            set = "bar_setter",
        },


        bar_header = {
            order = 1.0,
            type = "header",
            name = "Progress Bar Appearance",
        },
        bar_color_default = {
            order = 1.1,
            type="color",
            name="Color",
            desc="The color of the progress bar.",
            hasAlpha=true,
            get = "color_getter",
            set = "color_setter",
        },
        bar_texture_key = {
            order = 1.2,
            type = "select",
            name = "Texture",
            desc = "The texture of the progress bar.",
            dialogControl = "LSM30_Statusbar",
            values = LSM:HashTable("statusbar"),
            get = "getter",
            set = "bar_setter",
        },

        background_header = {
            order = 2.0,
            type = "header",
            name = "Background Appearance",
        },
        background_color = {
            order = 2.1,
            type="color",
            name="Color",
            desc="The color of the timer background.",
            hasAlpha=true,
            get = "color_getter",
            set = "color_setter",
        },
        background_texture_key = {
            order = 2.2,
            type = "select",
            name = "Texture",
            desc = "The texture of the timer background.",
            dialogControl = "LSM30_Statusbar",
            values = LSM:HashTable("statusbar"),
            get = "getter",
            set = "bar_setter",
        },

        border_header = {
            order = 3.0,
            type = "header",
            name = "Border Appearance"
        },
        border_color = {
            order = 3.1,
            type="color",
            name="Color",
            desc="The color of the timer border.",
            hasAlpha=true,
            get = "color_getter",
            set = "color_setter",
        },
        border_texture_key = {
            order = 3.2,
            type = "select",
            name = "Texture",
            desc = "The border texture of the timer.",
            dialogControl = "LSM30_Border",
            values = LSM:HashTable("border"),
            get = "getter",
            set = "bar_setter",
        },
        border_desc = {
            order = 3.21,
            type = "description",
            name = "Sometimes due to how the WoW client handles pixels and scaling, the border texture"..
            " can be uneven around the timer."..
            " If this happens, the width can be fine-tweaked until the texture is an even thickness on all sides."
        },
        border_width = {
            order = 3.3,
            type = "range",
            name = "Border thickness",
            desc = "The thickness of the timer border.",
            min = 0.1, max = 8,
            step = 0.1,
            get = "getter",
            set = "bar_setter",
        },
    }
end


function ST:construct_text_settings_table()
    ST.fonts_table_preset = {
        texts_header = {
            order = 4.002,
            type = "header",
            name = "Text Appearance",
        },
        text_size = {
            type = "range",
            order = 4.03,
            name = "Text size",
            desc = "The size of the timer texts.",
            min = 10, max = 40, softMin = 8, softMax = 34,
            step = 1,
            get = "getter",
            set = "text_setter",
        },
        text_color = {
            order=4.035,
            type="color",
            name="Text color",
            desc="The color of the timer texts.",
            hasAlpha=false,
            get = "color_getter",
            set = "color_setter",
        },
        text_font = {
            order = 4.02,
            type = "select",
            name = "Font",
            desc = "The font to use in the timer texts.",
            dialogControl = "LSM30_Font",
            values = LSM:HashTable("font"),
            get = "getter",
            set = "text_setter",
        },
        text_outline_key = {
            order=4.04,
            type="select",
            values=ST.outlines,
            style="dropdown",
            desc="The outline type to use with the timer texts.",
            name="Text outline",
            get = "getter",
            set = "text_setter",
        },
        texts_left_header = {
            order=4.045,
            type="header",
            name="Left Text Control",
        },
        texts_left_desc = {
            type = "description",
            order = 4.05,
            name = "Controls what text to show on the left of the timer, and when to show it.",
        },
        -- lb01 = {
        --     order=4.051,
        --     type="header",
        --     name="",
        -- },
        left_text_enabled = {
            type = "toggle",
            order = 4.06,
            name = "Enabled",
            desc = "Enables or disables the left timer text.",
            get = "getter",
            set = "setter",
        },
        left_text_key = {
            type="select",
            order = 4.08,
            values=ST.texts,
            style="dropdown",
            name = "",
            desc = "What to show on the left of the timer.",
            get = "getter",
            set = "text_setter",
            disabled = "left_text_disable",
        },
        left_text_hide_inactive = {
            type = "toggle",
            order = 4.07,
            name = "Hide when bar full",
            desc = "Hides the text when the timer is full.",
            get = "getter",
            set = "setter",
            disabled = "left_text_disable",
        },
        -- left_text_position_header = {
        --     type = "header",
        --     order = 4.081,
        --     name = "Left Text Position",
        -- },
        left_text_position_desc = {
            type = "description",
            order = 4.0811,
            name = "Controls the left text's positional offsets as a percent of the timer size.",
        },
        left_text_x_percent_offset = {
            type = "range",
            order = 4.082,
            name = "x offset %",
            desc = "The text's horizontal offset as a percentage of the timer width.",
            min = -100 , max = 100, softMin = -30, softMax = 30,
            step = 0.1,
            get = "getter",
            set = "text_setter",
        },
        left_text_y_percent_offset = {
            type = "range",
            order = 4.083,
            name = "y offset %",
            desc = "The text's vertical offset as a percentage of the timer height.",
            min = -250 , max = 250, softMin = -150, softMax = 150,
            step = 0.1,
            get = "getter",
            set = "text_setter",
        },

        texts_right_header = {
            order=4.095,
            type="header",
            name="Right Text Control",
        },
        texts_right_desc = {
            type = "description",
            order = 4.097,
            name = "Controls what text to show on the right of the timer, and when to show it.",
        },
        right_text_enabled = {
            type = "toggle",
            order = 4.10,
            name = "Right Text Enabled",
            desc = "Enables or disables the right text.",
            get = "getter",
            set = "setter",
        },
        right_text_key = {
            type="select",
            order = 4.12,
            values=ST.texts,
            style="dropdown",
            name = "",
            desc = "What to show on the right of the timer.",
            get = "getter",
            set = "text_setter",
            disabled = "right_text_disable",
        },
        right_text_hide_inactive = {
            type = "toggle",
            order = 4.11,
            name = "Hide when bar full",
            desc = "Hides the text when the timer is full.",
            get = "getter",
            set = "setter",
            disabled = "right_text_disable",
        },
        right_text_position_desc = {
            type = "description",
            order = 4.1205,
            name = "Controls the right text's positional offsets as a percent of the timer size.",
        },
        right_text_x_percent_offset = {
            type = "range",
            order = 4.121,
            name = "x offset %",
            desc = "The text's horizontal offset as a percentage of the timer width.",
            min = -100 , max = 100, softMin = -30, softMax = 30,
            step = 0.1,
            get = "getter",
            set = "text_setter",
        },
        right_text_y_percent_offset = {
            type = "range",
            order = 4.122,
            name = "y offset %",
            desc = "The text's vertical offset as a percentage of the timer height.",
            min = -250 , max = 250, softMin = -150, softMax = 150,
            step = 0.1,
            get = "getter",
            set = "text_setter",
        },
    }
end

function ST:construct_border_settings_table()
    ST.borders_preset = {
        -- Border settings
        header_borders = {
            order=4.0,
            type="header",
            name="Border Appearance",
        },
        -- bar_border_description = {
        --     order=4.1,
        --     type="description",
        --     name="The bar border can either be set to a solid color, a texture, or disabled.",
        -- },
        -- header_borders2 = {
        --     order=4.25,
        --     type="header",
        --     name="Solid Border width",
        -- },
        border_width = {
            type = "range",
            order = 4.4,
            name = "Border thickness",
            desc = "The thickness of the bar border.",
            min = 0.1, max = 8,
            step = 0.1,
            get = "getter",
            set = "bar_setter",
        },
        border_texture_key = {
            order = 4.5,
            type = "select",
            name = "Texture",
            desc = "The border texture of the swing bar.",
            dialogControl = "LSM30_Border",
            values = LSM:HashTable("border"),
            get = "getter",
            set = "bar_setter",
        },
        border_color = {
            order = 4.6,
            type = "color",
            name = "Color",
            desc = "The color of the border texture.",
            get = "color_getter",
            set = "color_setter"
        }
    }
end

function ST:construct_gcd_underlay_settings_table()
    ST.gcd_underlay_preset = {
        header = {
            type = "header",
            name = "GCD Underlay Settings",
            order = 1.0,
        },
        desc = {
            type = "description",
            order = 1.1,
            name = "A texture can be placed after the progress bar to show the user"..
                " the ongoing duration of any active Global Cooldown."
        },
        lb1 = {
            type = "header",
            order = 1.2,
            name = ""
        },
        show_gcd_underlay = {
            type = "toggle",
            order = 1.3,
            name = "Enable",
            desc = "Enables or disables the GCD underlay for this hand.",
            get = "getter",
            set = "setter",
        },
        lb2 = {
            type = "description",
            order = 1.31,
            name = "",
        },
        gcd_texture_key = {
            order = 1.4,
            type = "select",
            name = "Texture",
            desc = "The texture of the GCD underlay bar.",
            dialogControl = "LSM30_Statusbar",
            values = LSM:HashTable("statusbar"),
            get = "getter",
            set = "bar_setter",
        },
        bar_color_gcd = {
            order=1.5,
            type="color",
            name="Color",
            desc="The color of the GCD underlay bar.",
            hasAlpha=true,
            get = "color_getter",
            set = "color_setter",
        },
    }
end


function ST:construct_gcd_marker_settings_table()
    ST.gcd_markers_preset = {
        header = {
            type = "header",
            name = "GCD Marker Settings",
            order = 0.9,
        },
        desc_1 = {
            type="description",
            order = 1.0,
            name = "These settings control the GCD markers on the top and bottom of the swing timer."..
            " The markers represent one standard physical or spell GCD's time on the timer from their anchor point. "..
            "They can be anchored to the end of the swing, or to the swing progress itself. "..
            "The spell or physical GCD duration shown can be set manually or set to be context-sensitive, e.g. "..
            "changing to the physical GCD duration for druids when in bear/cat form, and spell GCD duration when "..
            "in other forms.",
        },

        -- Marker Appearance
        markers_appearance_header = {
            type = "header",
            name = "Marker Appearance",
            order = 1.1,
        },
        gcd1a_marker_color = {
            order=1.2,
            type="color",
            name="Top marker color",
            desc="The color of the top GCD marker.",
            hasAlpha=true,
            get = "color_getter",
            set = "color_setter",
        },
        gcd1b_marker_color = {
            order=1.3,
            type="color",
            name="Bottom marker color",
            desc="The color of the top GCD marker.",
            hasAlpha=true,
            get = "color_getter",
            set = "color_setter",
        },
        gcd1a_marker_width = {
            type = "range",
            order = 1.4,
            name = "Top marker width",
            desc = "The line width of the top GCD marker.",
            min = 1, max = 6,
            step = 1,
            get = "getter",
            set = "bar_setter",
        },
        gcd1b_marker_width = {
            type = "range",
            order = 1.5,
            name = "Bottom marker width",
            desc = "The line width of the bottom GCD marker.",
            min = 1, max = 6,
            step = 1,
            get = "getter",
            set = "bar_setter",
        },
        gcd1a_marker_fractional_height = {
            type = "range",
            order = 1.6,
            name = "Top marker height",
            desc = "The height of the top marker as a fraction of the bar height",
            min = 0.01, max = 1.0,
            step = 0.01,
            get = "getter",
            set = "bar_setter",
        },
        gcd1b_marker_fractional_height = {
            type = "range",
            order = 1.6,
            name = "Bottom marker height",
            desc = "The height of the bottom marker as a fraction of the bar height",
            min = 0.01, max = 1.0,
            step = 0.01,
            get = "getter",
            set = "bar_setter",
        },

        -- Top Marker Behaviour
        markers_beheaviour_header_top = {
            order=2.0,
            type="header",
            name="Top Marker Behaviour",
        },
        gcd1a_marker_enabled = {
            type = "toggle",
            order = 2.1,
            name = "Enable",
            desc = "Toggles drawing the top GCD marker on the bar.",
            get = "getter",
            set = "bar_setter",
        },
        gcd1a_marker_hide_inactive = {
            type = "toggle",
            order = 2.12,
            name = "Hide when full",
            desc = "Will hide the top GCD marker when the swing timer bar is full.",
            get = "getter",
            set = "bar_setter",
            disabled = "gcd1a_anchor_disable",
        },
        -- MODE WIDGET GETS INSERTED INTO THIS TABLE BY THE TABLE CREATION FUNC
        -- BECAUSE THE OPTIONS ARE CLASS-SENSITIVE. order = 2.2
        gcd1a_marker_anchor = {
            type = "select",
            order = 2.3,
            name = "Anchor point",
            values=ST.gcd_anchor_points,
            desc = "The anchor point for the top GCD marker.",
            get = "getter",
            set = "bar_setter",
            disabled = "gcd1a_anchor_disable",
        },
        gcd1a_swing_anchor_wrap = {
            type = "toggle",
            order = 2.4,
            name = "Wrap Swing markers",
            desc = "If the marker anchor is Swing, toggles the marker wrapping back to the start of the bar "..
                "when the GCD marker falls in the player's next swing.",
            get = "getter",
            set = "bar_setter",
            disabled = "gcd1a_wrap_disable",
        },

        -- Bottom Marker Behaviour
        markers_beheaviour_header_bottom = {
            order=2.5,
            type="header",
            name="Top Marker Behaviour",
        },
        gcd1b_marker_enabled = {
            type = "toggle",
            order = 2.6,
            name = "Enable",
            desc = "Toggles drawing the bottom GCD marker on the bar.",
            get = "getter",
            set = "bar_setter",
        },
        gcd1b_marker_hide_inactive = {
            type = "toggle",
            order = 2.62,
            name = "Hide when full",
            desc = "Will hide the bottom GCD marker when the swing timer bar is full.",
            get = "getter",
            set = "bar_setter",
            disabled = "gcd1b_anchor_disable",
        },
        -- MODE WIDGET GETS INSERTED INTO THIS TABLE BY THE TABLE CREATION FUNC
        -- BECAUSE THE OPTIONS ARE CLASS-SENSITIVE. order = 2.7
        gcd1b_marker_anchor = {
            type = "select",
            order = 2.8,
            name = "Anchor point",
            values=ST.gcd_anchor_points,
            desc = "The anchor point for the bottom GCD marker.",
            get = "getter",
            set = "bar_setter",
            disabled = "gcd1b_anchor_disable",
        },
        gcd1b_swing_anchor_wrap = {
            type = "toggle",
            order = 2.9,
            name = "Wrap Swing markers",
            desc = "If the marker anchor is Swing, toggles the marker wrapping back to the start of the bar "..
                "when the GCD marker falls in the player's next swing.",
            get = "getter",
            set = "bar_setter",
            disabled = "gcd1b_wrap_disable",
        },
    }
end

function ST:construct_deadzone_settings_table()
    ST.deadzone_settings_table = {
        header = {
            type = "header",
            name = "Deadzone Settings",
            order = 1.0,
        },
        desc_1 = {
            type="description",
            order = 1.1,
            name = "The Deadzone is a shaded region at the end of the swing timer bar indicating the  "..
                "player's latency to the game world. When the bar progress is inside the deadzone, "..
                "it should not be possible to input a new action that will occur before the swing goes off.\n\n"..
                "This can be used to queue abilities that should be registered immediately after the swing, "..
                "such as form changes while bearweaving.",
        },
        lb1 = {
            type = "header",
            name = "",
            order = 1.2,
        },
        enable_deadzone = {
            type = "toggle",
            order = 1.3,
            name = "Enable Deadzone",
            desc = "Toggles drawing the Deadzone on the bar.",
            get = "getter",
            set = "bar_setter",
        },
        deadzone_hide_inactive = {
            type = "toggle",
            order = 1.35,
            name = "Hide when bar inactive",
            desc = "Hides the Deadzone when the bar is in the inactive state.",
            get = "getter",
            set = "bar_setter",
        },
        deadzone_texture_key = {
            type = "select",
            order = 1.4,
            name = "Texture",
            desc = "Texture to use for the Deadzone.",
            values = LSM:HashTable("statusbar"),
            dialogControl = "LSM30_Statusbar",
            get = "getter",
            set = "bar_setter",
        },
        deadzone_bar_color = {
            type = "color",
            order = 1.5,
            name="Deadzone color",
            desc="The color of the Deadzone bar.",
            hasAlpha=true,
            get = "color_getter",
            set = "color_setter"
        },
    }
end

function ST:construct_info_panel()
    ST.info_panel = {
        header = {
            type = "header",
            name = "Welcome to SwedgeTimer!",
            order = 1.0,
        },
        desc1 = {
            type = "description",
            order = 1.1,
            name = "SwedgeTimer is a general-purpose Swing Timer addon for Wrath of the Lich King Classic. "..
                "It aims to be a one-stop-shop for swing timers, supporting independent and feature-rich "..
                "timer configurations for each class in the game."
                -- "SwedgeTimer is powered by LibClassicSwingTimerAPI and accounts for the many "..
                -- "edge cases in WoW's often confusing swing timer implementation.",
        },
        header2 = {
            type = "header",
            name = "Timer Visibility",
            order = 1.2,
        },
        desc2 = {
            type = "description",
            order = 1.3,
            name = "By default the addon only shows timers relevant to each class, and disables all timers"..
                " for caster classes.\n\n"..
                "Also by default, the timers will only show under certain conditions, usually requiring that "..
                "the player is either in-combat or has an attackable target. By default, range finders "..
                "are also enabled that will partially fade the timer when the target is out-of-range.\n\n"..
                "The visibility conditions can be set in each timer's menu on the right panel."
        },
        header3 = {
            type = "header",
            name = "Positions and Scales",
            order = 1.4,
        },
        desc3 = {
            type = "description",
            order = 1.5,
            name = "When the timers are unlocked (see top panel), they can be clicked and "..
                "dragged to new positions. When unlocked, the mousewheel can also be used to increase "..
                "or decrease the timer scale.\n\n"..
                "The Bar Positioning/Scale menu on the left can also be used for a finer control of position/scale.",
        },
        header4 = {
            type = "header",
            name = "Features",
            order = 1.6,
        },
        desc4 = {
            type = "description",
            order = 1.7,
            name = "SwedgeTimer includes a number of features as standard, including a GCD underlay, adjustable GCD time"..
                " markers, and a Deadzone indicating the player's latency."..
                " All of these features can be configured in each timer's submenu on the left panel,"..
                " where the timer appearance can also be fully customised."
        },
        header5 = {
            type = "header",
            name = "Class-specific Features",
            order = 1.8,
        },
        desc5 = {
            type = "description",
            order = 1.9,
            name = "SwedgeTimer includes modules that display specialised information for certain classes."..
                " For instance, Paladins have access to seal-dependent progress bar colors and proc alert glows."..
                " If a class has such configuration, it will be visible in the left panel of the settings menu.",
        }
    }
end

function ST:construct_class_info_panel()
    ST.class_info_panel = {
        header = {
            type = "header",
            name = string.format("Default Settings", self.player_class_pretty),
            order = 1.0,
        },
    }

    -- Generate the per-class settings.
    local per_class = {}
    if self.player_class == "DEATHKNIGHT" then
        per_class = {
            d1 = {
                type = "description",
                order = 1.1,
                name = "Death Knights can use a mainhand and offhand weapon, and by default these timers are both "..
                "enabled. The offhand timer only displays if the player has an offhand weapon equipped."..
                "\n\nBy default, the timers will only show when the player is in-combat or has an attackable "..
                "target, and the timers will be dimmed when the player is outside of melee range"..
                " of their target, or has no target.\n\n"..
                "The GCD underlay is enabled on the mainhand timer. The GCD markers show the expected "..
                "Spell GCD duration, and are anchored to the end of the timer."..
                " The markers can also be anchored to the timer's progress instead."
            },
            h2 = {
                type = "header",
                order = 1.2,
                name = "Multi-timer controls",
            },
            d2 = {
                type = "description",
                order = 1.3,
                name = "A Multi-timer control is included to let the player alter properties of both the mainhand "..
                "and offhand timers together, accessible from the relevant panel on the left."
            },
        }
    elseif self.player_class == "DRUID" then
       per_class = {
        d1 = {
            type = "description",
            order = 1.1,
            name = "Druids are only capable of using mainhand weapons, and so the class only has "..
            "a single timer."..
            "\n\nBy default, the timer will only show when the player is in-combat or has an attackable "..
            "target. By default, the timer will be dimmed when the player is outside of melee range."..
            "\n\nThe GCD underlay is enabled. "..
            "The GCD markers show the Spell GCD duration while in normal, Moonkin, and Tree form, "..
            "and show the Physical GCD duration while in cat, bear, and dire bear form."..
            ". Spell GCD duration is affected by haste rating and buffs, while the"..
            " physical GCD duration is not."..
            "The markers are anchored to the end of the timer bar, and will hide when the timer is inactive."..
            " The markers can also be anchored to the timer's progress instead."
        },
        h2 = {
            type = "header",
            order = 1.2,
            name = "Form Colors",
        },
        d2 = {
            type = "description",
            order = 1.3,
            name = "The timer bar is by default configured to change color based on the druid's form. These colors "..
            "can be specified in Druid Configuration."
        },
        h3 = {
            type = "header",
            order = 1.4,
            name = "Maul Queueing",
        },
        d3 = {
            type = "description",
            order = 1.5,
            name = "The progress bar is configured to change color when the druid has Maul queued for their next attack. "..
            "The bar will also turn a special color when the druid has Maul queued but rage decay or rage spending "..
            "takes them below the rage threshold to cast Maul."
        },
       }
        
    elseif self.player_class == "HUNTER" then

    elseif self.player_class == "MAGE" then

    elseif self.player_class == "PALADIN" then
        per_class = {
            d1 = {
                type = "description",
                order = 1.1,
                name = "Paladins are only capable of using mainhand weapons, and so the class only has "..
                "a single mainhand timer."..
                "\n\nBy default, the timer will only show when the player is in-combat or has an attackable "..
                "target. By default, the timer will be dimmed when the player is outside of melee range."..
                "\n\nThe GCD underlay is enabled for the mainhand. "..
                "The GCD markers are split between showing the expected Physical GCD (top) and Spell "..
                "GCD (bottom). Spell GCD duration is affected by haste rating and related buffs, while the"..
                " Physical GCD duration is not."..
                "The markers are anchored to the timer's end, and will hide when the bar is inactive."..
                " The markers can also be anchored to the timer's progress instead."
            },
            h1 = {
                type = "header",
                order = 1.2,
                name = "Seal Colors",
            },
            d2 = {
                type = "description",
                order = 1.3,
                name = "Paladins by default have their progress bar set to a grey color with no seal, "..
                "and when a seal is active on the paladin the bar turns a color corresponding to the seal. "..
                "This can be changed in Paladin Configuration."
            },
            h3 = {
                type = "header",
                order = 1.4,
                name = "Art of War",
            },
            d3 = {
                type = "description",
                order = 1.5,
                name = "The timer is configured to have a pixel glow when the player both has Art of War and has Exorcism "..
                "off cooldown. The glow can be disabled or tweaked in Paladin Configuration."..
                " The glow effect can also be set to not require Exorcism off cooldown, which can be handy "..
                "for Rets who want to optimise their Flash of Light casts.",
        }
    }
    elseif self.player_class == "PRIEST" then

    elseif self.player_class == "ROGUE" then
        per_class = {
            d1 = {
                type = "description",
                order = 1.1,
                name = "Rogues have access to mainhand, offhand, and ranged weapons. "..
                "The mainhand and offhand timers are enabled by default, while the ranged timer is disabled. "..
                "If the ranged timer is enabled, it will be a smaller bar below the offhand, which will only "..
                "show when the rogue is both in-combat, and in range with the equipped ranged weapon.\n\n"..
                "The main/offhand timers will by default only show when the player has a valid target, or "..
                "is in combat."..
                "\n\nThe GCD underlay is enabled for the mainhand. "..
                "The GCD markers show the physical GCD duration anchored to the end of the swing."
            },
            h2 = {
                type = "header",
                order = 1.2,
                name = "Multi-timer controls",
            },
            d2 = {
                type = "description",
                order = 1.3,
                name = "As Rogue is a class that can use all three weapon types, two Multi-timer controls are included."..
                " These can be used to alter all three timer properties together, or to alter just the mainhand and offhand"..
                " together."
            },
        }
    elseif self.player_class == "SHAMAN" then

    elseif self.player_class == "WARLOCK" then

    elseif self.player_class == "WARRIOR" then
        per_class = {
            d1 = {
                type = "description",
                order = 1.1,
                name = "Warriors have access to mainhand, offhand, and ranged weapons. "..
                "The mainhand and offhand timers are enabled by default, while the ranged timer is disabled. "..
                "If the ranged timer is enabled, it will be a smaller bar below the offhand, which will only "..
                "show when the warrior is both in-combat, and in range with the equipped ranged weapon.\n\n"..
                "The main/offhand timers will by default only show when the player has a valid target, or "..
                "is in combat."..
                "\n\nThe GCD underlay is enabled for the mainhand. "..
                "The GCD markers show the physical GCD duration anchored to the end of the swing."
            },
            h2 = {
                type = "header",
                order = 1.2,
                name = "Multi-timer controls",
            },
            d2 = {
                type = "description",
                order = 1.3,
                name = "As Warrior is a class that can use all three weapon types, two Multi-timer controls are included."..
                " These can be used to alter all three timer properties together, or to alter just the mainhand and offhand"..
                " together."
            },
            h3 = {
                type = "header",
                order = 1.4,
                name = "HS/Cleave Queueing",
            },
            d3 = {
                type = "description",
                order = 1.5,
                name = "The mainhand progress bar is configured to change color when the Warrior has an on-next-attack"..
                " queued, with different colors enabled for Heroic Strike and Cleave."..
                "The bar will also turn a special color when the player has an on-next-attack ability "..
                "queued but rage decay or rage spending "..
                "takes them below the rage threshold to cast it."
            },
        }
    end

    -- Add the per-class
    for k, v in pairs(per_class) do
        ST.class_info_panel[k] = v
    end
end

-- Finally, a function to build all of the above
function ST:build_preset_options_tables()
    self:construct_latency_settings_table()
    self:construct_strata_settings_table()
    self:construct_delay_settings_table()
    self:construct_advanced_settings_table()
    self:construct_text_settings_table()
    self:construct_bar_appearance_settings_table()
    self:construct_border_settings_table()
    self:construct_gcd_underlay_settings_table()
    self:construct_gcd_marker_settings_table()
    self:construct_deadzone_settings_table()
    self:construct_info_panel()
    self:construct_class_info_panel()
end