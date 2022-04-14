-- main.lua ============================================================================
local addon_name, addon_data = ...
local L = addon_data.localization_table

-- local name = UnitName("player")
local version = "v0.0.1"
local load_message = "version " .. version .. " loaded!"

-- shorthand
local print = addon_data.utils.print_msg


-- CORE =================================================================================
addon_data.core = {}
addon_data.core.in_combat = false

--=========================================================================================
-- A frame to detect if the player is in combat or not.
addon_data.core.in_combat_frame = CreateFrame("Frame", addon_name .. "CombatFrame", UIParent)
local function in_combat_frame_event_handler(self, event, ...)
    if event == "PLAYER_REGEN_ENABLED" then
        addon_data.core.in_combat = false
    elseif event == "PLAYER_REGEN_DISABLED" then
        addon_data.core.in_combat = true
    end
end

--=========================================================================================
-- Funcs for loading and initialising all data.
--=========================================================================================
addon_data.core.all_timers = {
    addon_data.bar,
}

addon_data.core.default_settings = {
    one_frame = false,
	welcome_message = true
}

addon_data.core.LoadSettings = function()
    -- If the carried over settings dont exist then make them
    if not character_core_settings then
        character_core_settings = {}
    end
    -- If the carried over settings aren't set then set them to the defaults
    for setting, value in pairs(addon_data.core.default_settings) do
        if character_core_settings[setting] == nil then
            character_core_settings[setting] = value
        end
    end
end

addon_data.core.RestoreDefaults = function()
    for setting, value in pairs(addon_data.core.default_settings) do
        character_core_settings[setting] = value
    end
end

addon_data.core.UpdateAllVisualsOnSettingsChange = function()
    addon_data.bar.UpdateVisualsOnSettingsChange()
end


local function LoadAllSettings(self)
    addon_data.player.LoadSettings()
	addon_data.bar.LoadSettings()
    addon_data.core.LoadSettings()
end

local function InitializeAllVisuals()
    addon_data.bar.init_bar_visuals()
    addon_data.config.InitializeVisuals()
end

-- function to update all values
local function CoreFrame_OnUpdate(self, elapsed)
    addon_data.player.OnUpdate(elapsed)
end


-- SLASH COMMANDS ===================================================================
SLASH_SWEDGETIMER_HOME1 = "/swedgetimer"
SLASH_SWEDGETIMER_HOME2 = "/SWEDGETIMER"
SLASH_SWEDGETIMER_HOME3 = "/st"
SlashCmdList["SWEDGETIMER_HOME"] = function(option)
    -- print(option)
    if option == "bar" then
        addon_data.bar.TwistBarToggle()

    -- If no args, bring up the main config window
    elseif option == '' then
        InterfaceOptionsFrame_OpenToCategory(addon_data.config.config_parent_panel)
        InterfaceOptionsFrame_OpenToCategory(addon_data.config.config_parent_panel)
    else
        print('usage advice: will be implemented later i promise')
    end
end

--=========================================================================================
-- Now, a frame to load the addon upon intercepting the ADDON_LOADED event trigger
--=========================================================================================
-- This function is called once when the addon is loaded, and 
-- sets up the various frames and elements.
local function init_addon(self)

    if addon_data.debug then print('Registering events and widget handlers...') end
    -- Register the in-combat events and widget handlers
    addon_data.core.in_combat_frame:SetScript("OnEvent", in_combat_frame_event_handler)
    addon_data.core.in_combat_frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    addon_data.core.in_combat_frame:RegisterEvent("PLAYER_REGEN_DISABLED")

    -- Attach the events and widget handlers for the player stats frame
    addon_data.player_frame:SetScript("OnEvent", addon_data.player.player_frame_on_event)
    addon_data.player_frame:SetScript("OnUpdate", CoreFrame_OnUpdate)
    addon_data.player_frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    addon_data.player_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    addon_data.player_frame:RegisterEvent("UNIT_INVENTORY_CHANGED")
    addon_data.player_frame:RegisterUnitEvent("UNIT_AURA", "player")
    addon_data.player_frame:RegisterEvent("UNIT_SPELLCAST_SENT")
    addon_data.player_frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

	-- Load the settings for the core and all timers
	-- addon_data.player.LoadSettings()
	-- addon_data.core.LoadSettings()
    if addon_data.debug then print('Loading all settings...') end
    LoadAllSettings()
    -- print('... settings loaded successfully')

    -- Load visuals
    if addon_data.debug then print('Initialising visuals...') end
    addon_data.bar.recalculate_ticks = true -- force initial draw
    InitializeAllVisuals()

    -- Any other misc operations that happen at the start
    addon_data.player.InitSwingTimer()

    -- If appropriate show welcome message
    if addon_data.debug then print('... complete!') end
    if character_core_settings.welcome_message then	print(load_message)	end
end

-- The frame responsible for loading the addon at the appropriate time
addon_data.core.init_frame = CreateFrame("Frame", addon_name .. "InitFrame", UIParent)
local function init_frame_event_handler(self, event, ...)
    local args = {...}
    if event == "ADDON_LOADED" then
        if args[1] == "SwedgeTimer" then
            init_addon()
        end
    end
end

addon_data.core.init_frame:SetScript("OnEvent", init_frame_event_handler)
addon_data.core.init_frame:RegisterEvent("ADDON_LOADED")

--=========================================================================================
-- End, if debug verify module was read.
--=========================================================================================
if addon_data.debug then print('-- Parsed main.lua module correctly') end
