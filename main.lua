-- main.lua ============================================================================
local addon_name, st = ...
local L = st.localization_table

-- local name = UnitName("player")
local version = "0.1.8"
local load_message = "version " .. version .. " loaded!"

-- shorthand
local print = st.utils.print_msg


-- CORE =================================================================================
st.core = {}
st.core.in_combat = false

--=========================================================================================
-- A frame to detect if the player is in combat or not.
st.core.in_combat_frame = CreateFrame("Frame", addon_name .. "CombatFrame", UIParent)
local function in_combat_frame_event_handler(self, event, ...)
    if event == "PLAYER_REGEN_ENABLED" then
        st.core.in_combat = false
    elseif event == "PLAYER_REGEN_DISABLED" then
        st.core.in_combat = true
    end
    st.bar.update_bar_on_combat()
end

--=========================================================================================
-- Funcs for loading and initialising all data.
--=========================================================================================
st.core.all_timers = {
    st.bar,
}

st.core.default_settings = {
	welcome_message = true
}

st.core.LoadSettings = function()
    -- If the carried over settings dont exist then make them
    if not swedgetimer_core_settings then
        swedgetimer_core_settings = {}
    end
    -- If the carried over settings aren't set then set them to the defaults
    for setting, value in pairs(st.core.default_settings) do
        if swedgetimer_core_settings[setting] == nil then
            swedgetimer_core_settings[setting] = value
        end
    end
end

st.core.RestoreDefaults = function()
    for setting, value in pairs(st.core.default_settings) do
        swedgetimer_core_settings[setting] = value
    end
end

st.core.UpdateAllVisualsOnSettingsChange = function()
    st.bar.UpdateVisualsOnSettingsChange()
end


local function LoadAllSettings(self)
    st.player.LoadSettings()
	st.bar.LoadSettings()
    st.core.LoadSettings()
end

local function InitializeAllVisuals()
    st.bar.init_bar_visuals()
    st.config.InitializeVisuals()
end

-- SLASH COMMANDS ===================================================================
SLASH_SWEDGETIMER_HOME1 = "/swedgetimer"
SLASH_SWEDGETIMER_HOME2 = "/SWEDGETIMER"
SLASH_SWEDGETIMER_HOME3 = "/st"
SlashCmdList["SWEDGETIMER_HOME"] = function(option)
    -- print(option)
    if option == "bar" then
        st.bar.TwistBarToggle()
    elseif option == "lock" then
        st.bar.TwistBarLockToggle()
        
    -- If no args, bring up the main config window
    elseif option == '' then
        -- Doing it twice works around the longstanding Blizzard bug
	    -- that fails to actually open the requested panel if it's
	    -- not currently visible in the lefthand list, and scrolling
	    -- is required to bring it into view.
        InterfaceOptionsFrame_OpenToCategory(st.config.config_parent_panel)
        InterfaceOptionsFrame_OpenToCategory(st.config.config_parent_panel)
    else
        print('Recognised SwedgeTimer commands:')
        print('--  /st lock  : toggles bar lock')
        print('--  /st bar   : toggles bar visibility')
    end
end

--=========================================================================================
-- Now, a frame to load the addon upon intercepting the ADDON_LOADED event trigger
--=========================================================================================
-- This function is called once when the addon is loaded, and 
-- sets up the various frames and elements.
local function init_addon(self)

    if st.debug then print('Loading all settings...') end
    LoadAllSettings()

    -- Load visuals
    if st.debug then print('Initialising visuals...') end
    st.bar.recalculate_ticks = true -- force initial draw
    InitializeAllVisuals()

    if st.debug then print('Registering events and widget handlers...') end
    -- Register the in-combat events and widget handlers
    st.core.in_combat_frame:SetScript("OnEvent", in_combat_frame_event_handler)
    st.core.in_combat_frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    st.core.in_combat_frame:RegisterEvent("PLAYER_REGEN_DISABLED")

    -- Attach the events and widget handlers for the player stats frame
    st.player_frame:SetScript("OnEvent", st.player.frame_on_event)
    st.player_frame:SetScript("OnUpdate", st.player.frame_on_update)
    st.player_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    st.player_frame:RegisterEvent("UNIT_INVENTORY_CHANGED")
    st.player_frame:RegisterUnitEvent("UNIT_AURA", "player")
    st.player_frame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "player")

    st.player_frame:RegisterEvent("UNIT_SPELLCAST_SENT")
    st.player_frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    st.player_frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    st.player_frame:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")

    -- Any operations to initialise the player state
    st.player.swing_timer = 0.00001
    st.player.update_weapon_speed()
    st.player.calculate_spell_GCD_duration()
    st.player.on_player_aura_change()
    st.player.update_lag()

    -- Some settings that have to be set after the bar is initialised
    st.bar.UpdateVisualsOnSettingsChange()
    st.bar.update_visuals_on_update()
    st.bar.set_bar_color()
    st.bar.set_gcd_bar_width()
    st.bar.set_bar_color()
    st.bar.show_or_hide_bar()

    -- If appropriate show welcome message
    if st.debug then print('... complete!') end
    if swedgetimer_core_settings.welcome_message then	print(load_message)	end
end

-- The frame responsible for loading the addon at the appropriate time
st.core.init_frame = CreateFrame("Frame", addon_name .. "InitFrame", UIParent)
local function init_frame_event_handler(self, event, ...)
    local args = {...}
    if event == "ADDON_LOADED" then
        if args[1] == "SwedgeTimer" then
            local english_class = select(2, UnitClass("player"))
            -- Only load the addon if the player is a paladin
            if english_class ~= "PALADIN" then
                st.core.init_frame:SetScript("OnEvent", nil)
                return
            end
        
            -- else, load it
            init_addon()

            -- Now we've loaded, remove the handler from the frame to stop it 
            -- processing events
            st.core.init_frame:SetScript("OnEvent", nil)
        end
    end
end

st.core.init_frame:SetScript("OnEvent", init_frame_event_handler)
st.core.init_frame:RegisterEvent("ADDON_LOADED")

--=========================================================================================
-- End, if debug verify module was read.
--=========================================================================================
if st.debug then print('-- Parsed main.lua module correctly') end
