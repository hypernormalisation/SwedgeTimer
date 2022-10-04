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
    name = "SwedgeTimer",
    type = "group",
    args = {
        global_header = {
            order = 0.01,
            type = "header",
            name = "Global and Class Configuration",
        },
        -- This title breaks the bar submenus from the global one.
        bar_header = {
            order = 10,
            type = "header",
            name = "Bar Configuration",
        },
    },
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
-- Setter for latency options.
ST.opts_funcs.global.latency_setter = function(_, info, value)
    local db = ST:get_profile_table()
    db[info[#info]] = value
    ST:set_adjusted_latencies()
    ST:set_gcd_times_before_swing_seconds()
    for hand in ST:iter_hands() do
        ST:set_deadzone_width(hand)
        ST:set_gcd_marker_positions(hand)
    end
end
-- Setter for strata options.
ST.opts_funcs.global.strata_setter = function(_, info, value)
    local db = ST:get_profile_table()
    db[info[#info]] = value
    for hand in ST:iter_hands() do
        ST:configure_frame_strata(hand)
    end
end

function ST:generate_top_level_options_table()
    -- Set the top-level options that are displayed above the settings menu.
    self.opts_table.handler = self.opts_funcs.global
    self.opts_table.args.class_enabled = {
        type = "toggle",
        order = 1.1,
        name = string.format("%s Enable/Disable", self.player_class_pretty),
        desc = "Enables or disables SwedgeTimer for this class.",
        get = function()
            local db = ST:get_class_table()
            return db.class_enabled
        end,
        set = function(_, value)
            local db = ST:get_class_table()
            db.class_enabled = value
        end,
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

    -- Add behaviour panel
    ST.opts_table.args.behaviour = ST.behaviour_group

end

--=========================================================================================
-- This section sets the widget set/get functions using handlers.
--=========================================================================================
function ST:set_opts_case_dict()
    -- This function sets a case dict for setting the bar sub-menus.
    self.opts_case_dict = {
        mainhand = {
            title = "Mainhand Controls",
            panel_title = string.format("Mainhand", self.player_class_pretty),
            desc = "This panel and its subpanels configure the settings for the mainhand bar.\n",
            hands = {"mainhand"},
            order_offset = 1,
        },
        offhand = {
            title = "Offhand Controls",
            panel_title = string.format("Offhand", self.player_class_pretty),
            desc = "This panel and its subpanels configure the settings for the offhand bar.\n",
            hands = {"offhand"},
            order_offset = 2,
        },
        ranged = {
            title = "Ranged Controls",
            panel_title = string.format("Ranged", self.player_class_pretty),
            desc = "This panel and its subpanels configure the settings for the ranged bar.\n",
            hands = {"ranged"},
            order_offset = 3,
        },
        all_hands = {
            title = "All Bar Controls",
            panel_title = string.format("All %s hands", self.player_class_pretty),
            desc = "This panel and its subpanels configure the settings for all bars. It is only visible "..
            "to classes that can use multiple types of weapons (mainhand/offhand/ranged)."..
            "\n\nAny changes made here will apply to *all bars*, use caution!\n",
            hands = {"mainhand", "offhand", "ranged"},
            order_offset = 4,
        },
        melee_hands = {
            title = "Melee Bar Controls",
            panel_title = string.format("%s Melee hands", self.player_class_pretty),
            desc = "This panel and its subpanels configure the settings for both melee bars. It is only visible "..
            "to classes that can use mainhand, offhand, and ranged weapons."..
            "\n\nAny changes made here will apply to *both the mainhand and offhand bars*, use caution!\n",
            hands = {"mainhand", "offhand"},
            order_offset = 5,
        },
    }
end

-- This function will be run when the addon initialises to generate
-- the getter and setter funcs for the hands. These will be a little specialised
-- to ensure the appropriate config functions in the addon are run when the user
-- changes the settings.
function ST:set_opts_funcs()
    for hand, settings in pairs(ST.opts_case_dict) do
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
                ST:configure_bar_size(h)
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
                local color_table = {ST:convert_color_up({r, g, b, a})}
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

        -- GCD1a anchor disabler
        ST.opts_funcs[hand].gcd1a_anchor_disable = function()
            if hand == "mainhand" or hand == "offhand" or hand == "ranged" then
                return not ST:get_hand_table(hand).gcd1a_marker_enabled
            else
                return not ST:get_hand_table("mainhand").gcd1a_marker_enabled
            end
        end
        -- GCD1a wrap disabler
        ST.opts_funcs[hand].gcd1a_wrap_disable = function()
            if hand == "mainhand" or hand == "offhand" or hand == "ranged" then
                local marker_enabled = ST:get_hand_table(hand).gcd1a_marker_enabled
                local is_anchored_swing = ST:get_hand_table(hand).gcd1a_marker_anchor == "swing"
                return (not marker_enabled) or (not is_anchored_swing)
            else
                local marker_enabled = ST:get_hand_table("mainhand").gcd1a_marker_enabled
                local is_anchored_swing = ST:get_hand_table("mainhand").gcd1a_marker_anchor == "swing"
                return (not marker_enabled) or (not is_anchored_swing)
            end
        end
        -- GCD1b anchor disabler
        ST.opts_funcs[hand].gcd1b_anchor_disable = function()
            if hand == "mainhand" or hand == "offhand" or hand == "ranged" then
                return not ST:get_hand_table(hand).gcd1b_marker_enabled
            else
                return not ST:get_hand_table("mainhand").gcd1b_marker_enabled
            end
        end
        -- GCD1b wrap disabler
        ST.opts_funcs[hand].gcd1b_wrap_disable = function()
            if hand == "mainhand" or hand == "offhand" or hand == "ranged" then
                local marker_enabled = ST:get_hand_table(hand).gcd1b_marker_enabled
                local is_anchored_swing = ST:get_hand_table(hand).gcd1b_marker_anchor == "swing"
                return (not marker_enabled) or (not is_anchored_swing)
            else
                local marker_enabled = ST:get_hand_table("mainhand").gcd1b_marker_enabled
                local is_anchored_swing = ST:get_hand_table("mainhand").gcd1b_marker_anchor == "swing"
                return (not marker_enabled) or (not is_anchored_swing)
            end
        end

        -- Bar vis disablers
        ST.opts_funcs[hand].not_always_shown_disabler = function()
            local db = ST:get_hand_table("mainhand")
            if hand == "mainhand" or hand == "offhand" or hand == "ranged" then
                db = ST:get_hand_table(hand)
            end
            return db.show_behaviour == "always"
        end
        ST.opts_funcs[hand].require_in_range_disabler = function()
            local db = ST:get_hand_table("mainhand")
            if hand == "mainhand" or hand == "offhand" or hand == "ranged" then
                db = ST:get_hand_table(hand)
            end
            if db.show_behaviour == "always" then
                return true
            end
            if db.show_condition == "in_combat" then
                return true
            end
            return false
        end

        -- Range disablers
        ST.opts_funcs[hand].oor_dim_alpha_disabler = function()
            local db = ST:get_hand_table("mainhand")
            if hand == "mainhand" or hand == "offhand" or hand == "ranged" then
                db = ST:get_hand_table(hand)
            end
            return not db.dim_oor
        end
    end
end

--=========================================================================================
-- Class settings/opts tables/getters and setters
--=========================================================================================
-- Generate getter and setters
function ST:generate_class_getters_setters()
    self.class_getsetters = {}

    -- A generic getter func
    ST.class_getsetters.getter = function(_, info)
        local db = ST:get_class_table()
        return db[info[#info]]
    end

    -- A generic setter func
    ST.class_getsetters.setter = function(_, info, value)
        local db = ST:get_class_table()
        db[info[#info]] = value
        for h in ST:iter_hands() do
            ST:configure_texts(h)
            ST:configure_bar_size(h)
            ST:configure_bar_appearances(h)
            ST:configure_bar_outline(h)
            ST:configure_gcd_markers(h)
            ST:set_gcd_marker_positions(h)
        end
    end

    ST.class_getsetters.color_getter = function(self, info)
        local db = ST:get_class_table()
        local color_table = db[info[#info]]
        return ST:convert_color(color_table)
    end

    ST.class_getsetters.color_setter = function(self, info, r, g, b, a)
        local db = ST:get_class_table()
        local color_table = {ST:convert_color_up({r, g, b, a})}
        db[info[#info]] = color_table
        for h in ST:iter_hands() do
            ST:configure_texts(h)
            ST:configure_gcd_markers(h)
            ST:configure_deadzone(h)
            ST:configure_bar_outline(h)
            ST:set_bar_color(h)
        end
    end
end

ST.class_opts_funcs = {}
function ST:generate_class_options_table()
    self:generate_class_getters_setters()
    -- Function to generate the per-class settings.
    if ST.class_opts_funcs[self.player_class] then
        local args = self.class_opts_funcs[self.player_class](self)
        ST.opts_table.args.class = {
            name = string.format("%s Configuration", self.player_class_pretty),
            type = "group",
            desc = string.format("This panel contains settings specific to the %s class.",
                self.player_class_pretty),
            order = 0.5,
            args = args,
            handler = self.class_getsetters,
        }
    end
end

function ST.class_opts_funcs.PALADIN(self)
    local opts_group = {}
    return opts_group
end

function ST.class_opts_funcs.WARRIOR(self)
    local opts_group = {
        class_header = {
            type = "header",
            order = 1.0,
            name = "Warrior Configuration",
        },
        queue_desc = {
            order = 1.02,
            type = "description",
            name = "The bar can be configured to turn a custom color when an on-next-attack ability is queued."
        },
        enable_hs_color = {
            type = "toggle",
            order = 1.1,
            name = "Heroic Strike color",
            desc = "Enables a custom color for the mainhand bar when Heroic Strike is queued.",
            get = "getter",
            set = "setter",
        },
        hs_color = {
            order=1.2,
            type="color",
            name="",
            desc="Color to use when Heroic Strike is queued.",
            hasAlpha=true,
            get = "color_getter",
            set = "color_setter",
            disabled = function()
                local db = ST:get_class_table()
                return not db.enable_hs_color
            end,
        },
        enable_cleave_color = {
            type = "toggle",
            order = 1.3,
            name = "Cleave color",
            desc = "Enables a custom color for the mainhand bar when Cleave is queued.",
            get = "getter",
            set = "setter",
        },
        cleave_color = {
            order=1.4,
            type="color",
            name="",
            desc="Color to use when Cleave is queued.",
            hasAlpha=true,
            get = "color_getter",
            set = "color_setter",
            disabled = function()
                local db = ST:get_class_table()
                return not db.enable_cleave_color
            end,
        },
        lb1 = {
            type = "header",
            order = 1.45,
            name = "",
        },
        rage_desc = {
            order = 1.5,
            type = "description",
            name = "If either of the above are enabled, the mainhand bar will turn a certain color when the player "..
                "has queued an on-next-attack ability, but has since dropped below the rage threshold necessary "..
                "to use the ability."
        },
        insufficient_rage_color = {
            order=1.6,
            type="color",
            name="Insufficient Rage color",
            desc="Color to use when the player drops below the rage threshold for the queued ability.",
            hasAlpha=true,
            get = "color_getter",
            set = "color_setter",
        },
    }
    return opts_group
end


--=========================================================================================
-- Per-hand opts table entries.
--=========================================================================================
function ST:generate_hand_options_table(hand)
    -- Function to generate an options table for a hand object.
    local settings = ST.opts_case_dict[hand]
    local offset = settings.order_offset
    local title = settings.title

    -- print(hand_title)
    local opts_group = {
        handler = ST.opts_funcs[hand],
		name = settings.panel_title,
		type = "group",
        desc = settings.desc,
        order = offset,
	}

    -- This will be the options table for the hand.
    -- All standard widgets are configured here.
    local opts = {
        enabled = {
            type = "toggle",
            order = 1.04,
            name = "Bar enabled",
            desc = "Enables or disables the swing timer bar.",
            get = "getter",
            set = "setter",
        },

        -- Bar size options here
        size_header = {
            order = 1.1,
            name = "Bar Size",
            type = "header",
        },
        bar_width = {
            type = "range",
            order = 2,
            name = "Width",
            desc = "The width of the swing timer bar.",
            min = 100, max = 600, step = 1,
            get = "getter",
            set = "bar_setter",
        },

        bar_height = {
            type = "range",
            order = 3,
            name = "Height",
            desc = "The height of the swing timer bar.",
            min = 6, max = 60, step = 1,
            get = "getter",
            set = "bar_setter",
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
        -- Add in the GCD mode options, which are class-dependent.
        if self.player_class == "DRUID" then
            opts_group.args.gcd_markers_group.args.gcd1a_marker_mode = {
                order = 2.2,
                type = "select",
                name = "GCD type to show",
                desc = "The GCD type to show (physical/spell). If set to Form Dependent, will show the physical "..
                    "GCD duration in cat/bear form, and the spell GCD duration in all other forms.",
                values = ST.gcd_marker_modes.DRUID,
                get = "getter",
                set = "bar_setter",
                disabled = "gcd1a_anchor_disable"
            }
            opts_group.args.gcd_markers_group.args.gcd1b_marker_mode = {
                order = 2.7,
                type = "select",
                name = "GCD type to show",
                desc = "The GCD type to show (physical/spell). If set to Form Dependent, will show the physical "..
                    "GCD duration in cat/bear form, and the spell GCD duration in all other forms.",
                values = ST.gcd_marker_modes.DRUID,
                get = "getter",
                set = "bar_setter",
                disabled = "gcd1b_anchor_disable"
            }
        else
            opts_group.args.gcd_markers_group.args.gcd1a_marker_mode = {
                order = 2.2,
                type = "select",
                name = "GCD type to show",
                desc = "The GCD type to show (physical/spell).",
                values = ST.gcd_marker_modes.NONDRUID,
                get = "getter",
                set = "bar_setter",
                disabled = "gcd1a_anchor_disable"
            }
            opts_group.args.gcd_markers_group.args.gcd1b_marker_mode = {
                order = 2.7,
                type = "select",
                name = "GCD type to show",
                desc = "The GCD type to show (physical/spell).",
                values = ST.gcd_marker_modes.NONDRUID,
                get = "getter",
                set = "bar_setter",
                disabled = "gcd1b_anchor_disable"
            }
        end
    end

    -- Only basic hands and melee hands get visibility behaviour.
    if hand == "mainhand" or hand == "offhand" or hand == "ranged" or hand == "melee_hands" then
        local vis_opts = {
            vis_header = {
                type = "header",
                order = 20.0,
                name = "Bar Visibility",
            },
            show_behaviour = {
                type = "select",
                order = 20.1,
                name = "Show...",
                values = ST.show_bar_opts,
                desc = "Choose to always show the bar, or to require some conditions.",
                get = "getter",
                set = "setter",
            },
            show_condition = {
                type = "select",
                order = 20.2,
                name = "Conditions to show",
                values = ST.show_bar_conditions,
                desc = "Choose to always show the bar, or to require some conditions.",
                get = "getter",
                set = "setter",
                sorting = ST.show_bar_conditions_sorting,
                disabled = "not_always_shown_disabler",
            },
            require_in_range = {
                type = "toggle",
                order = 20.3,
                name = "Require target in-range",
                desc = "If requiring a valid target, will only show the bar when the player is in range with this hand.",
                get = "getter",
                set = "setter",
                disabled = "require_in_range_disabler",
            },
            range_header = {
                type = "header",
                order = 21.0,
                name = "Out-of-range Behaviour",
            },
            dim_oor = {
                type = "toggle",
                order = 21.1,
                name = "Dim out of range",
                desc = "Dims the bar when the player is out of range with this hand, or has no target.",
                get = "getter",
                set = "setter",
            },
            dim_alpha = {
                type = "range",
                order = 21.2,
                name = "Alpha",
                desc = "The bar alpha when out of range.",
                min = 0, max = 1, step = 0.01,
                get = "getter",
                set = "setter",
                disabled = "oor_dim_alpha_disabler",
            }
        }
        for k, v in pairs(vis_opts) do
            opts_group.args[k] = v
        end
    end

    -- Assign it to the opts table.
    if hand == "mainhand" or hand == "offhand" or hand == "ranged" then
        -- if not self.opts_table.args.single_control then
        --     local sp_desc = string.format(
        --         "This panel allows the user to control individual swing timer bars for %ss.",
        --         self.player_class_pretty
        --     )
        --     self.opts_table.args.single_control = {
        --         name = string.format("%s Bar Controls", self.player_class_pretty),
        --         type = "group",
        --         desc = sp_desc,
        --         args = {},
        --     }
        --     -- self.opts_table.args.multi_control.args.multi_header = {
        --     --     name = "",
        --     --     order = 0.1,
        --     --     type = "header",
        --     -- }
        --     self.opts_table.args.single_control.args.single_desc = {
        --         name = sp_desc,
        --         order = 0.2,
        --         type = "description",
        --     }
        -- end
        self.opts_table.args[hand] = opts_group
    else
        -- If we need to, construct the multi-bar control panel and group.
        if not self.opts_table.args.multi_control then
            local mp_desc = "This panel allows the user to control multiple groups of bars at once for this class."
            self.opts_table.args.multi_control = {
                name = "Multi-bar Controls",
                type = "group",
                desc = mp_desc,
                args = {},
                order = 8.0,
            }
            self.opts_table.args.multi_control.args.multi_header = {
                name = "Control Multiple Bars at Once",
                order = 0.1,
                type = "header",
            }
            self.opts_table.args.multi_control.args.multi_desc = {
                name = mp_desc,
                order = 0.2,
                type = "description",
            }
        end
        self.opts_table.args.multi_control.args[hand] = opts_group
    end
end

