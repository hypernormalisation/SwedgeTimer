------------------------------------------------------------------------------------
-- Module to contain option table defaults
--
-- The module's purpose is to dynamically generate any options tables
-- depending on player class that the addon need. So for example,
-- a Paladin will only ever see the mainhand options, and the Paladin-specific 
-- class options.
------------------------------------------------------------------------------------
local addon_name, st = ...
local ST = LibStub("AceAddon-3.0"):GetAddon(addon_name)
local LSM = LibStub("LibSharedMedia-3.0")
local print = st.utils.print_msg

-- This object will eventually be passed to AceConfig as the options
-- table for the addon. We'll build it dynamically upon addon init.
ST.opts_table = {
    name = "SwedgeTimer Options",
    type = "group",
    args = {},
}


-- We're going to add helper funcs to a table that the hand opts
-- tables can reference for setters and getters.
ST.opts_funcs = {}

-- Setter and getter for global funcs
ST.opts_funcs.global = {}
ST.opts_funcs.global.getter = function(_, info)
    local db = ST:get_profile_table()
    return db[info[#info]]
end
ST.opts_funcs.global.setter = function(_, info, value)
    local db = ST:get_profile_table()
    db[info[#info]] = value
end


local opts_case_dict = {
    mainhand = {
        title = "Mainhand Controls",
        panel_title = "Mainhand Settings",
        desc = "This panel and its subpanels configures the settings for the mainhand bar.\n",
        hands = {"mainhand"},
        order_offset = 1,
    },
    offhand = {
        title = "Offhand Controls",
        panel_title = "Offhand Settings",
        desc = "This panel and its subpanels configures the settings for the offhand bar. It is only visible "..
        "to classes that can use offhand weapons.\n",
        hands = {"offhand"},
        order_offset = 2,
    },
    ranged = {
        title = "Ranged Controls",
        panel_title = "Ranged Settings",
        desc = "This panel and its subpanels configures the settings for the ranged bar. It is only visible "..
        "to classes that can use ranged weapons.\n",
        hands = {"ranged"},
        order_offset = 3,
    },
    all_hands = {
        title = "All Bar Controls",
        panel_title = "Settings for all bars",
        desc = "This panel and its subpanels configures the settings for all bars. It is only visible "..
        "to classes that can use multiple types of weapons (mainhand/offhand/ranged)."..
        "\n\nAny changes made here will apply to *all bars*, use caution!\n",
        hands = {"mainhand", "offhand", "ranged"},
        order_offset = 4,
    },
    melee_hands = {
        title = "Melee Bar Controls",
        panel_title = "Settings for all melee bars",
        desc = "This panel and its subpanels configures the settings for melee bars. It is only visible "..
        "to classes that can use all three of a mainhand, offhand, and ranged weapon."..
        "\n\nAny changes made here will apply to *both the mainhand and offhand bars*, use caution!\n",
        hands = {"mainhand", "offhand"},
        order_offset = 5,
    },
}

-- This function will be run when the addon initialises to generate
-- the getter and setter funcs for the hands. These will be a little specialised
-- to ensure the appropriate config functions in the addon are run when the user
-- changes the settings.
function ST:set_opts_funcs()

    for hand, settings in pairs(opts_case_dict) do

        ST.opts_funcs[hand] = {}

        -- A generic getter func for each hand
        if hand == "mainhand" or hand == "offhand" or hand == "ranged" then
            ST.opts_funcs[hand].getter = function(_, info)
                local db = ST:get_hand_table(hand)
                return db[info[#info]]
            end
        else
            -- Just default to the mainhand for the all_bars func.
            ST.opts_funcs[hand].getter = function(_, info)
                local db = ST:get_hand_table("mainhand")
                return db[info[#info]]
            end
        end

        -- A generic setter func for this hand, to be used when
        -- no further state change has to happen
        ST.opts_funcs[hand].setter = function(_, info, value)
            for h in ST:generic_iter(settings.hands) do
                local db = ST:get_hand_table(h)
                db[info[#info]] = value
            end
        end

        -- A setter for bar texts
        ST.opts_funcs[hand].text_setter = function(_, info, value)
            for h in ST:generic_iter(settings.hands) do
                local db = ST:get_hand_table(h)
                db[info[#info]] = value
                ST:configure_texts(h)
            end
        end

        -- A setter for bar appearances
        ST.opts_funcs[hand].bar_setter = function(_, info, value)
            for h in ST:generic_iter(settings.hands) do
                local db = ST:get_hand_table(h)
                db[info[#info]] = value
                ST:configure_bar_appearances(h)
                ST:configure_bar_outline(h)
                ST:configure_gcd_markers(h)
                ST:set_gcd_marker_positions(h)
            end
        end

        -- A getter for colors. Colors are stored in SwedgeTimer's 
        -- db as 0-255 ranges, and need converted to the expected
        -- 0-1 ranges for the client.
        if hand == "mainhand" or hand == "offhand" or hand == "ranged" then
            ST.opts_funcs[hand].color_getter = function(self, info)
                local db = ST:get_hand_table(hand)
                local color_table = db[info[#info]]
                -- print(color_table)
                return ST:convert_color(color_table)
            end
        else
            ST.opts_funcs[hand].color_getter = function(self, info)
                local db = ST:get_hand_table("mainhand")
                local color_table = db[info[#info]]
                return ST:convert_color(color_table)
            end
        end

        -- A setter for colors, which trigger text and bar color configs
        -- We scale up the 0-1 ranges the client uses to the 0-255 ranges
        -- that the SwedgeTimer db uses.
        ST.opts_funcs[hand].color_setter = function(self, info, r, g, b, a)
            for h in ST:generic_iter(settings.hands) do
                local db = ST:get_hand_table(h)
                ST:Print(r,g,b,a)
                local color_table = {ST:convert_color_up({r, g, b, a})}
                print(color_table)
                db[info[#info]] = color_table
                ST:configure_texts(h)
                ST:configure_gcd_markers(h)
                ST:configure_deadzone(h)
                ST:configure_bar_outline(h)
                ST:set_bar_color(h)
            end
        end

        -------------------------------------------------------------------------
        -- Disabler funcs
        -------------------------------------------------------------------------
        -- Left text disabler
        ST.opts_funcs[hand].left_text_disable = function()
            if hand == "mainhand" or hand == "offhand" or hand == "ranged" then
                return not ST:get_hand_table(hand).left_text_enabled
            else
                return not ST:get_hand_table("mainhand").left_text_enabled
            end
        end

        -- Right text disabler
        ST.opts_funcs[hand].right_text_disable = function()
            if hand == "mainhand" or hand == "offhand" or hand == "ranged" then
                return not ST:get_hand_table(hand).right_text_enabled
            else
                return not ST:get_hand_table("mainhand").right_text_enabled
            end
        end

        -- Solid Border disabler
        ST.opts_funcs[hand].solid_border_disable = function()
            if hand == "mainhand" or hand == "offhand" or hand == "ranged" then
                return ST:get_hand_table(hand).border_mode_key ~= "Solid"
            else
                return ST:get_hand_table("mainhand").border_mode_key ~= "Solid"
            end
        end

        -- Texture Border disabler
        ST.opts_funcs[hand].texture_border_disable = function()
            if hand == "mainhand" or hand == "offhand" or hand == "ranged" then
                return ST:get_hand_table(hand).border_mode_key ~= "Texture"
            else
                return ST:get_hand_table("mainhand").border_mode_key ~= "Texture"
            end
        end

    end
end

function ST:generate_class_options_table()
    -- Function to generate the per-class settings.
end

function ST:generate_top_level_options_table()

    -- Set the top-level options that are displayed above the settings menu.
    self.opts_table.handler = self.opts_funcs.global
    self.opts_table.args.enabled = {
        type = "toggle",
        order = 1.1,
        name = "Global Enable/Disable",
        desc = "Enables or disables all visuals in SwedgeTimer.",
        get = "getter",
        set = "setter",
    }
    self.opts_table.args.bars_locked = {
        type = "toggle",
        order = 1.2,
        name = "Bars locked",
        desc = "Prevents all swing timer bars from being dragged with the mouse.",
        get = "getter",
        set = function(_, input)
            local db = ST:get_profile_table()
            db.bars_locked = input
            for hand in ST:iter_hands() do
                local frame = self:get_frame(hand)
                frame:SetMovable(not input)
                frame:EnableMouse(not input)
            end
        end,
    }
    self.opts_table.args.welcome_message = {
        type = "toggle",
        order = 1.3,
        name = "Welcome message",
        desc = "Displays a login message showing the addon version on player login or reload.",
        get = "getter",
        set = "setter",
    }

end

function ST:generate_hand_options_table(hand)
    -- Function to generate an options table for a hand object.
    local settings = opts_case_dict[hand]
    local offset = settings.order_offset
    local title = settings.title

    -- print(hand_title)
    local opts_group = {
        handler = ST.opts_funcs[hand],
		name = title,
		type = "group",
        desc = settings.desc,
        order = offset,
	}

    -- This will be the options table for the hand.
    -- All standard widgets are configured here.
    local opts = {

        -- Top level settings
        top_header = {
            order=1.001,
            type="header",
            name=settings.panel_title,
        },
        top_desc = {
            type = "description",
            order = 1.01,
            name = settings.desc,
        },
        enabled = {
            type = "toggle",
            order = 1.04,
            name = "Bar enabled",
            desc = "Enables or disables the swing timer bar.",
            get = "getter",
            set = "setter",
        },

        -- Bar appearance options go here.
        bar_appearance_group = {
            type = "group",
            order = 1.50,
            name = "Textures/Colors",
            args = ST.bar_appearance_preset,
        },

        -- Border options go here.
        bar_borders_group = {
            type = "group",
            order = 1.7,
            name = "Borders/Outlines",
            args = ST.borders_preset,
        },

        -- Font options all go here.
        texts_group = {
            type = "group",
            order = 2.00,
            name = "Texts",
            args = ST.fonts_table_preset,
        },

    }
    opts_group.args = opts

    -- Any optional groups should go here.
    if hand == "mainhand" or hand == "ranged" then
        opts_group.args.gcd_markers_group = {
            type = "group",
            order = 3.0,
            name = "GCD Markers",
            args = ST.gcd_markers_preset
        }
    end

    -- Assign it
    self.opts_table.args[hand] = opts_group

end

