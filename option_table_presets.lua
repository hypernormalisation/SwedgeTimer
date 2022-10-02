------------------------------------------------------------------------------------
-- Module to contain presets for the options table generation
------------------------------------------------------------------------------------
local addon_name, st = ...
local ST = LibStub("AceAddon-3.0"):GetAddon(addon_name)
local LSM = LibStub("LibSharedMedia-3.0")


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

-- The fonts
ST.fonts_table_preset = {
    texts_header = {
        order=4.002,
        type="header",
        name="Text Appearance",
    },
    text_size = {
        type = "range",
        order = 4.03,
        name = "Text size",
        desc = "The size of the bar texts.",
        min = 10, max = 40, softMin = 8, softMax = 24,
        step = 1,
        get = "getter",
        set = "text_setter",
    },
    text_color = {
        order=4.01,
        type="color",
        name="Text color",
        desc="The color of the addon texts.",
        hasAlpha=false,
        get = "color_getter",
        set = "color_setter",
    },
    text_font = {
        order = 4.02,
        type = "select",
        name = "Font",
        desc = "The font to use in the addon texts.",
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
        desc="The outline type to use with the font.",
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
        name = "Controls what text to show on the left of the bar, and when to show it.",
    },
    left_text_enabled = {
        type = "toggle",
        order = 4.06,
        name = "Left Text Enabled",
        desc = "Enables or disables the left text.",
        get = "getter",
        set = "setter",
    },
    left_text_key = {
        type="select",
        order = 4.07,
        values=ST.texts,
        style="dropdown",
        name = "",
        desc = "What to show on the left of the swing timer bar.",
        get = "getter",
        set = "text_setter",
        disabled = "left_text_disable",
    },
    left_text_hide_inactive = {
        type = "toggle",
        order = 4.08,
        name = "Hide when bar full",
        desc = "Hides the text when the timer bar is full.",
        get = "getter",
        set = "setter",
        disabled = "left_text_disable",
    },
    texts_right_header = {
        order=4.095,
        type="header",
        name="Right Text Control",
    },
    texts_right_desc = {
        type = "description",
        order = 4.097,
        name = "Controls what text to show on the right of the bar, and when to show it.",
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
        order = 4.11,
        values=ST.texts,
        style="dropdown",
        name = "",
        desc = "What to show on the right of the swing timer bar.",
        get = "getter",
        set = "text_setter",
        disabled = "right_text_disable",
    },
    Right_text_hide_inactive = {
        type = "toggle",
        order = 4.12,
        name = "Hide when bar full",
        desc = "Hides the text when the timer bar is full.",
        get = "getter",
        set = "setter",
        disabled = "right_text_disable",
    },
}

ST.bar_appearance_preset = {
    -- Textures
    header_textures = {
        order=1.0,
        type="header",
        name="Textures",
    },
    bar_texture_key = {
        order = 2,
        type = "select",
        name = "Bar",
        desc = "The texture of the swing bar.",
        dialogControl = "LSM30_Statusbar",
        values = LSM:HashTable("statusbar"),
        get = "getter",
        set = "bar_setter",
    },
    gcd_texture_key = {
        order = 2.1,
        type = "select",
        name = "GCD underlay",
        desc = "The texture of the GCD underlay bar.",
        dialogControl = "LSM30_Statusbar",
        values = LSM:HashTable("statusbar"),
        get = "getter",
        set = "bar_setter",
    },
    backplane_texture_key = {
        order = 2.2,
        type = "select",
        name = "Backplane",
        desc = "The texture of the bar's backplane.",
        dialogControl = "LSM30_Statusbar",
        values = LSM:HashTable("statusbar"),
        get = "getter",
        set = "bar_setter",
    },

    -- Colors
    header_colors = {
        order=3.0,
        type="header",
        name="Default colors",
    },
    bar_color_default = {
        order=3.1,
        type="color",
        name="Bar color",
        desc="The default color of the swing timer bar.",
        hasAlpha=true,
        get = "color_getter",
        set = "color_setter",
    },
    bar_color_gcd = {
        order=3.21,
        type="color",
        name="GCD underlay color",
        desc="The color of the GCD underlay bar.",
        hasAlpha=true,
        get = "color_getter",
        set = "color_setter",
    },
    backplane_alpha = {
        type = "range",
        order = 3.3,
        name = "Backplane alpha",
        desc = "The opacity of the swing bar's backplane.",
        min = 0.0, max = 1.0,
        step = 0.05,
        get = "getter",
        set = "bar_setter",
    },
}

ST.borders_preset = {
    -- Border settings
    header_borders = {
        order=4.0,
        type="header",
        name="Border Mode",
    },
    bar_border_description = {
        order=4.1,
        type="description",
        name="The bar border can either be set to a solid color, a texture, or disabled.",
    },
    border_mode_key = {
        order=4.2,
        type="select",
        values=ST.bar_border_modes,
        style="dropdown",
        desc="The outline mode to use for the bar border, if any.",
        name="Border mode",
        get = "getter",
        set = "bar_setter",
    },
    header_borders2 = {
        order=4.25,
        type="header",
        name="Solid Border width",
    },
    linebreak_1 = {
        type="description",
        order = 4.3,
        name = "If border mode is set to Solid, this controls the border width.",
    },
    backplane_outline_width = {
        type = "range",
        order = 4.4,
        name = "Solid outline thickness",
        desc = "The thickness of the outline around the swing timer bar, if in Solid border mode.",
        min = 0, max = 5,
        step = 0.2,
        get = "getter",
        set = "bar_setter",
        disabled = "solid_border_disable",
    },
    header_borders3 = {
        order=4.41,
        type="header",
        name="Texture Border",
    },
    linebreak_2 = {
        type="description",
        order = 4.45,
        name = "If border mode is set to Texture, this controls the texture.",
    },
    border_texture_key = {
        order = 4.5,
        type = "select",
        name = "Border",
        desc = "The border texture of the swing bar.",
        dialogControl = "LSM30_Border",
        values = LSM:HashTable("border"),
        get = "getter",
        set = "bar_setter",
        disabled = "texture_border_disable",
    },
}

ST.gcd_markers_preset = {
    desc_1 = {
        type="description",
        order = 1.0,
        name = "These settings control the GCD markers on the top and bottom of the swing timer bar."..
        " The markers represent one standard physical or spell GCD's time on the bar from their anchor point. "..
        "They can be anchored to the end of the swing, or to the swing progress itself. "..
        "The spell or physical GCD duration shown can be set manually or set to be context-sensitive, e.g. "..
        "changing to the physical GCD duration for druids when in bear/cat form, and spell GCD duration when "..
        "in other forms.",
    },
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

    markers_beheaviour_header = {
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

    -- MODE WIDGET GETS INSERTED INTO THIS TABLE BY THE TABLE CREATION FUNC
    -- BECAUSE THE OPTIONS ARE CLASS-SENSITIVE. order = 2.2

    gcd1a_marker_anchor = {
        type = "select",
        order = 2.3,
        name = "Anchor point",
        desc = "The anchor point for the top GCD marker.",
        get = "getter",
        set = "bar_setter",
    }

}