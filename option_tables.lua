------------------------------------------------------------------------------------
-- Module to contain option table defaults
------------------------------------------------------------------------------------
local addon_name, st = ...
local ST = LibStub("AceAddon-3.0"):GetAddon(addon_name)
local LSM = LibStub("LibSharedMedia-3.0")
local print = st.utils.print_msg

ST.opts_table = {
    name = "SwedgeTimer Options",
    type = "group",
    args = {},
}

ST.bar_texture_template = {
    order = 2,
    type = "select",
    dialogControl = "LSM30_Statusbar",
    values = LSM:HashTable("statusbar"),

    -- name = "Bar Texture",
    -- desc = "The texture of the swing bar.",
    -- get = function(info) return ST.db.profile.bar_texture_key or LSM.DefaultMedia.statusbar end,
    -- set = function(self, key)
    --     ST.db.profile.bar_texture_key = key
    --     st.bar.frame.bar:SetTexture(LSM:Fetch('statusbar', key))
    -- end
}


-- We're going to add helper funcs to a table that the hand opts
-- tables can reference for setters and getters.
ST.opts_funcs = {}
local opts_case_dict = {
    mainhand = {
        title = "Mainhand",
        panel_title = "Mainhand Settings",
        desc = "This panel configures the settings for the mainhand bar.",
        hands = {"mainhand"},
        order_offset = 3,
    },
    offhand = {
        title = "Offhand",
        panel_title = "Offhand Settings",
        desc = "This panel configures the settings for the offhand bar. It is only visible "..
        "to classes that can use offhand weapons.",
        hands = {"offhand"},
        order_offset = 4,
    },
    ranged = {
        title = "Ranged",
        panel_title = "Ranged Settings",
        desc = "This panel configures the settings for the ranged bar. It is only visible "..
        "to classes that can use ranged weapons.",
        hands = {"ranged"},
        order_offset = 5,
    },
    all_hands = {
        title = "All",
        panel_title = "Settings for all bars",
        desc = "This panel configures the settings for all bars. It is only visible "..
        "to classes that can use multiple types of weapons (mainhand/offhand/ranged).",
        hands = {"mainhand", "offhand", "ranged"},
        order_offset = 1,
    },
    melee_hands = {
        title = "Melee",
        panel_title = "Settings for all melee bars",
        desc = "This panel configures the settings for melee bars. It is only visible "..
        "to classes that can use both a mainhand and an offhand.",
        hands = {"mainhand", "offhand"},
        order_offset = 2,
    }
}
-- for _, hand in ipairs({"mainhand", "offhand", "ranged"}) do

-- This function will be run when the addon initialises to generate
-- the getter and setter funcs for the hands
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

        -- A getter for colors. Colors are stored in SwedgeTimer's 
        -- db as 0-255 ranges, and need converted to the expected
        -- 0-1 ranges.
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
    end
end

-- function ST.opts_funcs.test_getter_mh()
--     print('test_getter printout')
--     return true
-- end

function ST:generate_hand_options_table(hand)
    -- Function to generate an options table for a hand object.

    local settings = opts_case_dict[hand]
    local offset = settings.order_offset
    local title = settings.title

    local hand_title = title .. " Bar"
    if not (hand == "mainhand" or hand == "offhand" or hand == "ranged") then
        hand_title = hand_title .. "s"
    end

    print(hand_title)
    local opts_group = {
        handler = ST.opts_funcs[hand],
		name = hand_title,
		type = "group",
        order = offset,
		-- args = top_level_opts,
	}

    -- This will be the full options table for the hand.
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
            set = function(info, val) print(hand) end,
        },

        -- font settings
        texts_header = {
            order=4.00,
            type="header",
            name="Texts",
        },
        text_desc = {
            type = "description",
            order = 4.001,
            name = string.format("Options for bar texts."),
        },
        text_size = {
            type = "range",
            order = 4.01,
            name = "Text size",
            desc = "The size of the bar texts.",
            min = 10, max = 40, softMin = 8, softMax = 24,
            step = 1,
            get = "getter",
            set = "text_setter",
        },
        text_color = {
            order=4.03,
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
    }

    opts_group.args = opts
    -- print(opts_group)
    self.opts_table.args[hand] = opts_group

end

