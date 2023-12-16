------------------------------------------------------------------------------------
-- Module to contain option table defaults
--
-- The module's purpose is to dynamically generate any options tables
-- depending on player class that the addon needs. So for example,
-- a Paladin will only ever see the mainhand options, and the Paladin-specific 
-- class options.
------------------------------------------------------------------------------------
local addon_name, st = ...
local ST = LibStub("AceAddon-3.0"):GetAddon(addon_name)
local LSM = LibStub("LibSharedMedia-3.0")
local LWIN = LibStub("LibWindow-1.1")
local print = st.utils.print_msg

-- This object will eventually be passed to AceConfig as the options
-- table for the addon. We'll build it dynamically upon addon init.
ST.opts_table = {
    name = "Welcome to SwedgeTimer!",
    type = "group",
    args = {
        desc1 = {
            type = "description",
            order = 1.1,
            name = "SwedgeTimer is a general-purpose swing timer addon for Vanilla and Wrath. "..
                "It aims to be a one-stop-shop for swing timers, supporting independent and feature-rich "..
                "timer configurations for every use-case.",
        },
        -- This title breaks the bar submenus from the global one.
        bar_header = {
            order = 10,
            type = "header",
            name = "Configuration",
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

    local main_args = {
        class_enabled = {
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
        },
        enable_spec1 = {
            type = "toggle",
            order = 1.11,
            name = "Spec 1",
            desc = "Enables the timer when Talent Specialization 1 is active.",
            get = function()
                return ST:get_class_table().enable_spec1
            end,
            set = function(_, value)
                ST:get_class_table().enable_spec1 = value
            end,
            disabled = function()
                return not ST:get_class_table().class_enabled
            end,
        },
        enable_spec2 = {
            type = "toggle",
            order = 1.12,
            name = "Spec 2",
            desc = "Enables the timer when Talent Specialization 2 is active.",
            get = function()
                return ST:get_class_table().enable_spec2
            end,
            set = function(_, value)
                ST:get_class_table().enable_spec2 = value
            end,
            disabled = function()
                return not ST:get_class_table().class_enabled
            end,
        },
        timers_locked = {
            type = "toggle",
            order = 1.2,
            name = "Timers locked",
            desc = "Prevents all swing timers from being dragged or scaled with the mouse.",
            get = function()
                local db = ST:get_class_table()
                return db.timers_locked
            end,
            set = function(_, input)
                local db = ST:get_class_table()
                db.timers_locked = input
                if db.timers_locked then
                    ST:lock_frames()
                else
                    ST:unlock_frames()
                end
            end,
        },
        ["Welcome message"] = {
            type = "toggle",
            order = 1.3,
            name = "Welcome message",
            desc = "Displays a login message showing the addon version on player login or reload.",
            get = "getter",
            set = "setter",
        },
    }
    self.opts_table.args.main = {
        type = "group",
        order = 0.1,
        name = "Main Settings",
        args = main_args,
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
            pretty_name = "Mainhand",
            title = "Mainhand Controls",
            panel_title = string.format("Mainhand", self.player_class_pretty),
            desc = "This panel and its subpanels configure the settings for the mainhand timer.\n",
            hands = {"mainhand"},
            order_offset = 1,
        },
        offhand = {
            pretty_name = "Offhand",
            title = "Offhand Controls",
            panel_title = string.format("Offhand", self.player_class_pretty),
            desc = "This panel and its subpanels configure the settings for the offhand timer.\n",
            hands = {"offhand"},
            order_offset = 2,
        },
        ranged = {
            pretty_name = "Ranged",
            title = "Ranged Controls",
            panel_title = string.format("Ranged", self.player_class_pretty),
            desc = "This panel and its subpanels configure the settings for the ranged timer.\n",
            hands = {"ranged"},
            order_offset = 3,
        },
        all_hands = {
            title = "All Bar Controls",
            panel_title = string.format("All %s hands", self.player_class_pretty),
            desc = "This panel and its subpanels configure the settings for all timers. It is only visible "..
            "to classes that can use multiple types of weapons (mainhand/offhand/ranged)."..
            "\n\nAny changes made here will apply to *all timers*, use caution!\n",
            hands = self.class_hands[self.player_class],
            order_offset = 4,
        },
        melee_hands = {
            title = "Melee Bar Controls",
            panel_title = string.format("%s Melee hands", self.player_class_pretty),
            desc = "This panel and its subpanels configure the settings for both melee timers. It is only visible "..
            "to classes that can use mainhand, offhand, and ranged weapons."..
            "\n\nAny changes made here will apply to *both the mainhand and offhand timers*, use caution!\n",
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
                ST:configure_bar_size_and_positions(h)
                ST:configure_bar_appearances(h)
                ST:configure_bar_outline(h)
                ST:configure_gcd_markers(h)
                ST:set_gcd_marker_positions(h)
                ST:configure_deadzone(h)
                ST:set_deadzone_width(h)
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
                ST:configure_bar_appearances(h)
                ST:configure_gcd_markers(h)
                ST:configure_deadzone(h)
                ST:configure_bar_outline(h)
                ST:set_bar_color(h)
                ST:set_deadzone_width(h)
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

        -- Center text disabler
        ST.opts_funcs[hand].center_text_disable = function()
            if hand == "mainhand" or hand == "offhand" or hand == "ranged" then
                return not ST:get_hand_table(hand).center_text_enabled
            else
                return not ST:get_hand_table("mainhand").center_text_enabled
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
        ST:determine_form_visibility_flag()
        for h in ST:iter_hands() do
            ST:configure_texts(h)
            ST:configure_bar_size_and_positions(h)
            ST:configure_bar_appearances(h)
            ST:configure_bar_outline(h)
            ST:configure_gcd_markers(h)
            ST:set_gcd_marker_positions(h)
            ST:handle_bar_visibility(h)
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
            order = 2.5,
            args = args,
            handler = self.class_getsetters,
        }
    end
end

function ST.class_opts_funcs.PALADIN(self)
    local opts_group = {
        -- class_header = {
        --     type = "header",
        --     order = 1.0,
        --     name = "Paladin Configuration",
        -- },
        seal_header = {
            type = "header",
            order = 1.01,
            name = "Seal Context Colors",
        },
        seal_desc = {
            type = "description",
            order = 1.1,
            name = "The timer bar can be configured to turn a custom color depending on the paladin's active seal.",
        },
        use_seal_colors = {
            type = "toggle",
            order = 1.11,
            name = "Enable",
            desc = "Enables custom colors for the mainhand bar based on active seal.",
            get = "getter",
            set = "setter",
        },
        soc_color = {
            order=1.12,
            type="color",
            name="Seal of Command",
            desc="Color to use when Seal of Command is active.",
            hasAlpha=true,
            get = "color_getter",
            set = "color_setter",
            disabled = function()
                local db = ST:get_class_table()
                return not db.use_seal_colors
            end,
        },
        sov_color = {
            order=1.13,
            type="color",
            name="Seal of Corruption/Vengeance",
            desc="Color to use when Seal of Corruption/Vengeance is active.",
            hasAlpha=true,
            get = "color_getter",
            set = "color_setter",
            disabled = function()
                local db = ST:get_class_table()
                return not db.use_seal_colors
            end,
        },
        sor_color = {
            order=1.14,
            type="color",
            name="Seal of Righteousness",
            desc="Color to use when Seal of Righteousness is active.",
            hasAlpha=true,
            get = "color_getter",
            set = "color_setter",
            disabled = function()
                local db = ST:get_class_table()
                return not db.use_seal_colors
            end,
        },
        sol_color = {
            order=1.15,
            type="color",
            name="Seal of Light",
            desc="Color to use when Seal of Light is active.",
            hasAlpha=true,
            get = "color_getter",
            set = "color_setter",
            disabled = function()
                local db = ST:get_class_table()
                return not db.use_seal_colors
            end,
        },
        sow_color = {
            order=1.16,
            type="color",
            name="Seal of Wisdom",
            desc="Color to use when Seal of Wisdom is active.",
            hasAlpha=true,
            get = "color_getter",
            set = "color_setter",
            disabled = function()
                local db = ST:get_class_table()
                return not db.use_seal_colors
            end,
        },
        soj_color = {
            order=1.17,
            type="color",
            name="Seal of Justice",
            desc="Color to use when Seal of Justice is active.",
            hasAlpha=true,
            get = "color_getter",
            set = "color_setter",
            disabled = function()
                local db = ST:get_class_table()
                return not db.use_seal_colors
            end,
        },
        aow_header = {
            type = "header",
            order = 2.0,
            name = "Art of War Procs",
        },
        aow_desc = {
            type = "description",
            order = 2.1,
            name = "The timer bar can be configured to glow when the Paladin has Art of War.",
        },
        use_aow_glow = {
            type = "toggle",
            order = 2.2,
            name = "Enable",
            desc = "Enables a glow color when the Paladin has Art of War",
            get = "getter",
            set = "setter",
        },
        require_exo_ready = {
            type = "toggle",
            order = 2.21,
            name = "Require Exorcism Ready",
            desc = "If set, the glow effect will only happen when Exorcism is off cooldown.",
            get = "getter",
            set = "setter",
        },
        aow_glow_color = {
            order=2.3,
            type="color",
            name="Color",
            desc="Glow color to use when the Paladin has an Art of War proc.",
            hasAlpha=true,
            get = "color_getter",
            set = "color_setter",
            disabled = function()
                local db = ST:get_class_table()
                return not db.use_aow_glow
            end,
        },
        aow_glow_nlines = {
            type = "range",
            order = 2.4,
            name = "Number of glow lines",
            desc = "The number of lines to use in the glow effect.",
            min = 1, max = 200,
            step = 1,
            get = "getter",
            set = "setter",
            disabled = function()
                local db = ST:get_class_table()
                return not db.use_aow_glow
            end,
        },
        aow_glow_freq = {
            type = "range",
            order = 2.5,
            name = "Glow frequency",
            desc = "The rotation frequency of the glow effect.",
            min = 0.01, max = 1.0, step = 0.01,
            get = "getter",
            set = "setter",
            disabled = function()
                local db = ST:get_class_table()
                return not db.use_aow_glow
            end,
        },
        aow_glow_line_length = {
            type = "range",
            order = 2.6,
            name = "Glow line length",
            desc = "The glow line length.",
            min = 1, max = 30, step = 1,
            get = "getter",
            set = "setter",
            disabled = function()
                local db = ST:get_class_table()
                return not db.use_aow_glow
            end,
        },
    }
    return opts_group
end

function ST.class_opts_funcs.WARRIOR(self)
    local opts_group = {
        tank_vid_header = {
            type = "header",
            order = 0.8,
            name = "Spec-dependent enable/disable"
        },
        hide_in_tank_spec = {
            type = "toggle",
            order = 0.81,
            name = "Hide when Protection",
            desc = "When enabled, the timer will hide when the Warrior is in Protection spec ("..
            "activated when Improved Defensive Stance is talented).",
            get = "getter",
            set = "setter",
        },
        hide_in_arms_spec = {
            type = "toggle",
            order = 0.82,
            name = "Hide when Arms",
            desc = "When enabled, the timer will hide when the Warrior is in Arms spec ("..
            "activated when Bladestorm is talented).",
            get = "getter",
            set = "setter",
        },
        class_header = {
            type = "header",
            order = 1.0,
            name = "On-next-attack Configuration",
        },
        queue_desc = {
            order = 1.02,
            type = "description",
            name = "The mainhand timer bar can be configured to turn a custom color when an on-next-attack ability is queued."
        },
        lb0 = {
            type = "header",
            order = 1.03,
            name = "",
        },
        enable_hs_color = {
            type = "toggle",
            order = 1.1,
            name = "Enable Heroic Strike",
            desc = "Enables a custom color for the mainhand bar when Heroic Strike is queued.",
            get = "getter",
            set = "setter",
        },
        hs_color = {
            order=1.2,
            type="color",
            name="Color",
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
            name = "Enable Cleave",
            desc = "Enables a custom color for the mainhand bar when Cleave is queued.",
            get = "getter",
            set = "setter",
        },
        cleave_color = {
            order=1.4,
            type="color",
            name="Color",
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
            name = "If either of the above are enabled, the mainhand timer bar will turn a certain color when the player "..
                "has queued an on-next-attack ability, but has since dropped below the rage threshold necessary "..
                "to use the ability."
        },
        lb2 = {
            type = "header",
            order = 1.55,
            name = "",
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
        header3 = {
            order = 2.0,
            type = "header",
            name = "Bloodsurge Glow"
        },
        desc3 = {
            order = 2.1,
            type = "description",
            name = "The mainhand timer can be configured to have a glow effect when the"..
            " player gets a Bloodsurge instant slam proc."
        },
        use_bloodsurge_glow = {
            type = "toggle",
            order = 2.2,
            name = "Enable",
            desc = "Enables a glow color when the Warrior has Bloodsurge",
            get = "getter",
            set = "setter",
        },
        bloodsurge_glow_color = {
            order=2.3,
            type="color",
            name="Color",
            desc="Glow color to use.",
            hasAlpha=true,
            get = "color_getter",
            set = "color_setter",
            disabled = function()
                local db = ST:get_class_table()
                return not db.use_bloodsurge_glow
            end,
        },
        bloodsurge_glow_nlines = {
            type = "range",
            order = 2.4,
            name = "Number of glow lines",
            desc = "The number of lines to use in the glow effect.",
            min = 1, max = 200,
            step = 1,
            get = "getter",
            set = "setter",
            disabled = function()
                local db = ST:get_class_table()
                return not db.use_bloodsurge_glow
            end,
        },
        bloodsurge_glow_freq = {
            type = "range",
            order = 2.5,
            name = "Glow frequency",
            desc = "The rotation frequency of the glow effect.",
            min = 0.01, max = 1.0, step = 0.01,
            get = "getter",
            set = "setter",
            disabled = function()
                local db = ST:get_class_table()
                return not db.use_bloodsurge_glow
            end,
        },
        bloodsurge_glow_line_length = {
            type = "range",
            order = 2.6,
            name = "Glow line length",
            desc = "The glow line length.",
            min = 1, max = 30, step = 1,
            get = "getter",
            set = "setter",
            disabled = function()
                local db = ST:get_class_table()
                return not db.use_bloodsurge_glow
            end,
        },
    }
    return opts_group
end

function ST.class_opts_funcs.HUNTER(self)
    local opts_group = {
        form_color_header = {
            type = "header",
            order = 1.0,
            name = "Raptor Strike Queueing",
        },
        rs_desc = {
            order = 1.001,
            type = "description",
            name = "The mainhand progress bar can be configured to turn a custom color when Raptor Strike is queued."
        },
        enable_raptor_strike_color = {
            type = "toggle",
            order = 1.1,
            name = "Enable",
            desc = "Enables a special bar color when Raptor Strike is queued on the next attack.",
            get = "getter",
            set = "setter",
        },
        raptor_strike_color = {
            order=1.2,
            type="color",
            name="Color",
            desc="Color to use when Raptor Strike is queued.",
            hasAlpha=true,
            get = "color_getter",
            set = "color_setter",
        },
    }
    return opts_group
end

function ST.class_opts_funcs.DRUID(self)
    local opts_group = {

        -- Form-dependent visibility
        form_vis_header = {
            type = "header",
            order = 3.0,
            name = "Form-dependent Visibility"
        },
        form_vis_desc = {
            type = "description",
            order = 3.1,
            name = "The timer bar can be configured to be only visible in certain forms.",
        },
        form_vis_normal = {
            type = "toggle",
            order = 3.2,
            name = "No Form",
            desc = "Show the bar when in default form.",
            get = "getter",
            set = "setter",
        },
        form_vis_bear = {
            type = "toggle",
            order = 3.3,
            name = "Bear/Dire Bear",
            desc = "Show the bar when in Bear or Dire Bear form.",
            get = "getter",
            set = "setter",
        },
        form_vis_cat = {
            type = "toggle",
            order = 3.4,
            name = "Cat",
            desc = "Show the bar when in Cat form.",
            get = "getter",
            set = "setter",
        },
        form_vis_moonkin = {
            type = "toggle",
            order = 3.5,
            name = "Moonkin",
            desc = "Show the bar when in Moonkin form.",
            get = "getter",
            set = "setter",
        },
        form_vis_tree = {
            type = "toggle",
            order = 3.6,
            name = "Tree of Life",
            desc = "Show the bar when in Tree of Life form.",
            get = "getter",
            set = "setter",
        },
        form_vis_travel = {
            type = "toggle",
            order = 3.7,
            name = "Travel Form",
            desc = "Show the bar when in Travel form.",
            get = "getter",
            set = "setter",
        },
        form_vis_flight = {
            type = "toggle",
            order = 3.8,
            name = "Flight Form",
            desc = "Show the bar when in Flight form.",
            get = "getter",
            set = "setter",
        },

        -- Form-dependent colors
        form_color_header = {
            type = "header",
            order = 4,
            name = "Form-dependent Colors",
        },
        form_color_desc = {
            order = 4.1,
            type = "description",
            name = "Enables the timer bar color changing depending on the druid's form."
        },
        use_form_colors = {
            type = "toggle",
            order = 4.3,
            name = "Enable",
            desc = "Enables form-dependent colors.",
            get = "getter",
            set = "setter",
        },
        lb02 = {
            type = "description",
            order = 4.4,
            name = "",
        },
        form_color_bear = {
            order=5.0,
            type="color",
            name="Bear/Dire Bear",
            desc="Color to use when in Bear/Dire Bear form.",
            hasAlpha=true,
            get = "color_getter",
            set = "color_setter",
        },
        form_color_cat = {
            order=5.1,
            type="color",
            name="Cat",
            desc="Color to use when in Cat form.",
            hasAlpha=true,
            get = "color_getter",
            set = "color_setter",
        },
        form_color_moonkin = {
            order=5.2,
            type="color",
            name="Moonkin",
            desc="Color to use when in Moonkin form.",
            hasAlpha=true,
            get = "color_getter",
            set = "color_setter",
        },
        form_color_tree = {
            order=5.3,
            type="color",
            name="Tree of Life",
            desc="Color to use when in Tree of Life form.",
            hasAlpha=true,
            get = "color_getter",
            set = "color_setter",
        },
        form_color_travel = {
            order=5.4,
            type="color",
            name="Travel Form",
            desc="Color to use when in Travel form.",
            hasAlpha=true,
            get = "color_getter",
            set = "color_setter",
        },
        form_color_flight = {
            order=5.5,
            type="color",
            name="Flight Form",
            desc="Color to use when in Flight form.",
            hasAlpha=true,
            get = "color_getter",
            set = "color_setter",
        },

        -- Maul color
        class_header = {
            type = "header",
            order = 11.0,
            name = "Maul",
        },
        queue_desc = {
            order = 11.02,
            type = "description",
            name = "The timer bar can be configured to turn a custom color when maul is queued."
        },
        enable_maul_color = {
            type = "toggle",
            order = 11.1,
            name = "Enable Maul Color",
            desc = "Enables a custom color for the mainhand bar when Maul is queued.",
            get = "getter",
            set = "setter",
        },
        maul_color = {
            order=11.2,
            type="color",
            name="Color",
            desc="Color to use when Heroic Strike is queued.",
            hasAlpha=true,
            get = "color_getter",
            set = "color_setter",
            disabled = function()
                local db = ST:get_class_table()
                return not db.enable_maul_color
            end,
        },
        rage_desc = {
            order = 12.1,
            type = "description",
            name = "If the above is enabled, the mainhand timer bar will turn a certain color when the player "..
                "has queued Maul, but has since dropped below the rage threshold necessary "..
                "to use the ability."
        },
        insufficient_rage_color = {
            order=12.3,
            type="color",
            name="Insufficient Rage color",
            desc="Color to use for the timer bar when the player drops below the rage threshold for the queued ability.",
            hasAlpha=true,
            get = "color_getter",
            set = "color_setter",
        },
    }
    return opts_group

end

--=========================================================================================
-- Bar Positioning group
--=========================================================================================
function ST:generate_bar_position_options_table()

    local opts_group = {
		name = "Size/Positioning/Scale",
		type = "group",
        desc = "This panel controls the positioning and scales of the bars in SwedgeTimer.",
        order = 0.6,
        args = {
            section_desc = {
                order = 0.1,
                type = "description",
                name = "This panel allows the user to control each timer's position. It is recommended "..
                    "to move the timers into position with the mouse with the timers unlocked in the global "..
                    "settings, and carry out any fine tuning here.",
            }
        },
    }

    local hand_offsets = {
        mainhand = 1.0,
        offhand = 2.0,
        ranged = 3.0,
    }

    for hand in self:iter_hands() do
        local offset = hand_offsets[hand]
        local name_pretty = self.opts_case_dict[hand].pretty_name
        local g = {
            [hand .. "_header"] = {
                type = "header",
                order = 1.0 + offset,
                name = name_pretty,
            },
            [hand .. "bar_width"] = {
                type = "range",
                order = 1.01 + offset,
                name = "Width",
                desc = "The pixel width of the swing timer.",
                min = 100, max = 600, step = 1,
                get = function()
                    return ST:get_hand_table(hand).bar_width
                end,
                set = function(_, value)
                    ST:get_hand_table(hand).bar_width = value
                    ST:configure_bar_size_and_positions(hand)
                    ST:configure_bar_appearances(hand)
                    ST:configure_bar_outline(hand)
                    ST:configure_gcd_markers(hand)
                    ST:set_gcd_marker_positions(hand)
                    ST:configure_deadzone(hand)
                    ST:set_deadzone_width(hand)
                end
            },
            [hand .. "bar_height"] = {
                type = "range",
                order = 1.02 + offset,
                name = "Height",
                desc = "The pixel height of the swing timer.",
                min = 6, max = 60, step = 1,
                get = function()
                    return ST:get_hand_table(hand).bar_height
                end,
                set = function(_, value)
                    ST:get_hand_table(hand).bar_height = value
                    ST:configure_bar_size_and_positions(hand)
                    ST:configure_bar_appearances(hand)
                    ST:configure_bar_outline(hand)
                    ST:configure_gcd_markers(hand)
                    ST:set_gcd_marker_positions(hand)
                    ST:configure_deadzone(hand)
                    ST:set_deadzone_width(hand)
                end
            },
            [hand .. "_x"] = {
                type = "range",
                order = 1.1 + offset,
                name = "x coord",
                min = -2000, max = 2000, step = 1,
                softMin = -1000, softMax = 1000,
                get = function()
                    return ST:get_hand_table(hand).x
                end,
                set = function(_, value)
                    ST:get_hand_table(hand).x = value
                    LWIN.RestorePosition(ST:get_anchor_frame(hand))
                end,
            },
            [hand .. "_y"] = {
                type = "range",
                order = 1.2 + offset,
                name = "y coord",
                min = -2000, max = 2000, step = 1,
                softMin = -800, softMax = 800,
                get = function()
                    return ST:get_hand_table(hand).y
                end,
                set = function(_, value)
                    ST:get_hand_table(hand).y = value
                    LWIN.RestorePosition(ST:get_anchor_frame(hand))
                end,
            },
            [hand .. "_point"] = {
                type = "select",
                order = 1.3 + offset,
                name = "Anchor Point",
                desc = "The anchor point to the Parent UI.",
                values = ST.valid_anchor_points,
                get = function()
                    return ST:get_hand_table(hand).point
                end,
                set = function(_, value)
                    ST:get_hand_table(hand).point = value
                    LWIN.RestorePosition(ST:get_anchor_frame(hand))
                end,
            },
            [hand .. "_scale"] = {
                type = "range",
                order = 1.4 + offset,
                name = "Scale",
                min = 0.1, max = 2.0, step = 0.01,
                get = function()
                    return ST:get_hand_table(hand).scale
                end,
                set = function(_, value)
                    ST:get_hand_table(hand).scale = value
                    LWIN.RestorePosition(ST:get_anchor_frame(hand))
                end,
            },
        }
        for k, v in pairs(g) do
            opts_group.args[k] = v
        end
    end
    self.opts_table.args.positions = opts_group
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

        enabled_header = {
            order = 0.001,
            name = "Timer Enabled",
            type = "header",
        },
        enabled = {
            type = "toggle",
            order = 0.01,
            name = "Enabled",
            desc = "Enables or disables the swing timer.",
            get = "getter",
            set = "setter",
        },
        bar_appearance_group = {
            type = "group",
            order = 1.5,
            name = "Appearance",
            args = ST.bar_appearance_preset,
        },

        -- Font options all go here.
        texts_group = {
            type = "group",
            order = 2.00,
            name = "Texts",
            args = ST.fonts_table_preset,
        },

        -- Deadzone group
        deadzone_group = {
            type = "group",
            order = 2.1,
            name = "Deadzone",
            args = ST.deadzone_settings_table,
        },

        -- GCD underlay group
        underlay_group = {
            type = "group",
            order = 2.2,
            name = "GCD Underlay",
            args = ST.gcd_underlay_preset,
        },

        -- GCD marker group
        gcd_markers_group = {
            type = "group",
            order = 3.0,
            name = "GCD Markers",
            args = ST.gcd_markers_preset
        }
    }

    opts_group.args = opts

    -- Any optional groups should go here.
    if hand == "mainhand" or hand == "ranged" then
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
    if true then --hand == "mainhand" or hand == "offhand" or hand == "ranged" or hand == "melee_hands" then
        local vis_opts = {
            vis_header = {
                type = "header",
                order = 0.1,
                name = "Bar Visibility",
            },
            show_behaviour = {
                type = "select",
                order = 0.2,
                name = "Show...",
                values = ST.show_bar_opts,
                desc = "Choose to always show the bar, or to require some conditions.",
                get = "getter",
                set = "setter",
            },
            show_condition = {
                type = "select",
                order = 0.3,
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
                order = 0.4,
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
        self.opts_table.args[hand] = opts_group
    else
        -- If we need to, construct the multi-bar control panel and group.
        if not self.opts_table.args.multi_control then
            local mp_desc = "This panel allows the user to control multiple groups of bars at once for this class."
            self.opts_table.args.multi_control = {
                name = "Multi-timer Controls",
                type = "group",
                desc = mp_desc,
                args = {},
                order = 8.0,
            }
            self.opts_table.args.multi_control.args.multi_header = {
                name = "Control Multiple Timers at Once",
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

function ST:set_opts()
    -- Finally, a function to be run on init that will dynamically generate
    -- all the requested panel tables on a per-hand/per-class basis.
    
    -- Sets a dict for hand/collection-based case switching. 
    self:set_opts_case_dict()
    
    -- Generate the preset options tables that don't require special case switching.
    self:build_preset_options_tables()

    -- Generates some handler setters/getters/disablers for hands/collections.
	self:set_opts_funcs()

    -- Generate the top level, position, and class opts if they exist.
    self:generate_top_level_options_table()
	self:generate_bar_position_options_table()
	self:generate_class_options_table()

    -- Generate all basic hand panels
	for hand in self:iter_hands() do
		self:generate_hand_options_table(hand)
	end

    -- Generate an "All hands" collection control panel if multiple hands exist
	local hands = self.class_hands[self.player_class]
	if #hands ~= 1 then
		self:generate_hand_options_table("all_hands")
	end

	-- Only generate "melee hands" collection control panel if class can use all three
    -- basic hands.
	if #hands == 3 then
		self:generate_hand_options_table("melee_hands")
	end
end