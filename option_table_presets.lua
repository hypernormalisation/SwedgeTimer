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

-- The fonts
ST.fonts_table_preset = {
    -- font settings
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
        name = "Controls what text to show on the left, and when to show them.",
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
        name = "Controls what text to show on the right, and when to show them.",
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