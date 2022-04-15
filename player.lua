local addon_name, addon_data = ...
local print = addon_data.utils.print_msg

--=========================================================================================
-- PLAYER SETTINGS 
--=========================================================================================
addon_data.player = {}
addon_data.player.default_settings = {
	enabled = true,
	width = 400,
	height = 20,
	fontsize = 12,
    point = "CENTER",
	rel_point = "CENTER",
	x_offset = 0,
	y_offset = -180,
	in_combat_alpha = 1.0,
	ooc_alpha = 0.65,
	backplane_alpha = 0.5,
	is_locked = false,
    show_left_text = true,
    show_right_text = true,
    show_border = false,
    classic_bars = true,
    fill_empty = true,
    main_r = 0.1, main_g = 0.1, main_b = 0.9, main_a = 1.0,
    main_text_r = 1.0, main_text_g = 1.0, main_text_b = 1.0, main_text_a = 1.0,
}

addon_data.player.class = UnitClass("player")[2]
addon_data.player.guid = UnitGUID("player")

-- addon_data.player.auras = UnitAura(addon_data.player.guid)

addon_data.player.swing_timer = 0.00001
addon_data.player.prev_weapon_speed = 0.1
addon_data.player.current_weapon_speed = 2
addon_data.player.weapon_id = GetInventoryItemID("player", 16)
addon_data.player.speed_changed = false
addon_data.player.extra_attacks_flag = false

-- containers for seal information
addon_data.player.n_active_seals = 0
addon_data.player.active_seals = {}
addon_data.player.active_seal_1 = nil
addon_data.player.active_seal_1_remaining = 0
addon_data.player.active_seal_2 = nil
addon_data.player.active_seal_2_remaining = 0

-- flag to run a double poll after 0.1s on aura change to catch bad API calls
addon_data.player.aura_repoll_counter = 0.0
addon_data.player.repoll_on_aura_change = false

-- a flag to ensure the code on swing completion only runs once
addon_data.player.reported_swing_timer_complete = false
addon_data.player.reported_swing_timer_complete_double = false
addon_data.player.time_since_swing_completion = 0.0

-- a flag to ensure the code on speed change only runs once per change
addon_data.player.reported_speed_change = false

-- Flag to detect if we have a new/falling off SotCr aura and need to change swing
-- timers to account for haste snapshotting
addon_data.crusader_lock = false
addon_data.crusader_currently_active = false

-- Flags to detect any spell casts that would reset the swing timer.
addon_data.player.how_cast_guid = nil
addon_data.player.holy_wrath_cast_guid = nil


addon_data.player.LoadSettings = function()
    -- If the carried over settings dont exist then make them
    if not character_player_settings then
        character_player_settings = {}
    end
    -- If the carried over settings aren't set then set them to the defaults
    for setting, value in pairs(addon_data.player.default_settings) do
        if character_player_settings[setting] == nil then
            character_player_settings[setting] = value
        end
    end
    -- Update settings that dont change unless the interface is reloaded
    addon_data.player.guid = UnitGUID("player")
end

-- Called when the swing timer reaches zero
addon_data.player.swing_timer_complete = function()
    -- handle seal of the crusader snapshotting for new crusader buffs
    addon_data.crusader_lock = false
    print('blah')
    addon_data.player.update_weapon_speed()
end

-- Called when the swing timer should be reset
addon_data.player.reset_swing_timer = function()
    -- addon_data.player.update_weapon_speed() -- NOT SURE IF THIS IS NEEDED
    addon_data.player.swing_timer = addon_data.player.current_weapon_speed
    addon_data.player.reported_swing_timer_complete = false
end

-- called w
addon_data.player.update_swing_timer = function(elapsed)
    if character_player_settings.enabled then
        if addon_data.player.swing_timer > 0 then
            addon_data.player.swing_timer = addon_data.player.swing_timer - elapsed
            if addon_data.player.swing_timer < 0 then
                addon_data.player.swing_timer = 0
            end
        end
    end
end

--=========================================================================================
-- Functions run when relevant events are intercepted
--=========================================================================================

addon_data.player.update_weapon_speed = function()
    -- Should be run when we receive an event that could indicate the player's 
    -- attack speed may have changed.
    addon_data.player.prev_weapon_speed = addon_data.player.current_weapon_speed
    print('API speed says:')
    print(UnitAttackSpeed("player"))

    -- Handle crusader snapshotting
    if addon_data.crusader_lock == true then
        print('Locking speed change because of crusader snapshot.')
        addon_data.player.speed_changed = false
        return
    end

    -- Update the attack speed and mark if it has changed.
    addon_data.player.current_weapon_speed, _ = UnitAttackSpeed("player")
    print(addon_data.player.current_weapon_speed)
    if addon_data.player.current_weapon_speed ~= addon_data.player.prev_weapon_speed then
        addon_data.player.speed_changed = true
        addon_data.player.reported_speed_change = false
    else
        addon_data.player.speed_changed = false
    end

end

-- Function run when we intercept an event indicating the player's equipment has changed.
addon_data.player.on_equipment_change = function()
    local new_guid = GetInventoryItemID("player", 16)
    -- Check for a main hand weapon change
    if addon_data.player.weapon_id ~= new_guid then
        addon_data.player.update_weapon_speed()
        addon_data.player.reset_swing_timer()
    end
    addon_data.player.weapon_id = new_guid
end

-- Function run when we intercept an unfiltered combatlog event.
addon_data.player.OnCombatLogUnfiltered = function(combat_info)
	local _, event, _, source_guid, _, _, _, dest_guid, _, _, _, _, spell_name, _ = unpack(combat_info)
	
    -- Handle all relevant events where the player is the action source
    if (source_guid == addon_data.player.guid) then
	-- check for extra attacks that would accidently reset the swing timer
		if (event == "SPELL_EXTRA_ATTACKS") then
			addon_data.player.extra_attacks_flag = true
		end
        if (event == "SWING_DAMAGE") then
			if (addon_data.player.extra_attacks_flag == false) then
				addon_data.player.reset_swing_timer()
			end
			addon_data.player.extra_attacks_flag = false
        elseif (event == "SWING_MISSED") then
			addon_data.player.reset_swing_timer()
        end
    -- Handle all relevant events where the player is the target
    elseif (dest_guid == addon_data.player.guid) then
        if (event == "SWING_MISSED") then
            local miss_type, is_offhand = select(12, unpack(combat_info))
            if miss_type == "PARRY" then
                -- parry reduces your swing timer by 40%, but cannot go below 20%.
                local swing_timer_reduced_40p = addon_data.player.swing_timer * 0.6
                local min_swing_time = addon_data.player.current_weapon_speed * 0.2             
                if swing_timer_reduced_40p < min_swing_time then
                    addon_data.player.swing_timer = min_swing_time
                else
                    addon_data.player.swing_timer = swing_timer_reduced_40p
                end        
            end
        end
    end
    -- finally update the attack speed
    -- addon_data.player.update_weapon_speed()
end

-- Function to iterate over the player's auras and record any active Seals.
addon_data.player.parse_auras = function()
    local end_iter = false
    local counter = 1
    addon_data.player.n_active_seals = 0
    -- print('-------------')
    -- print('Processing auras on change...')

    -- copy the previous seals
    addon_data.player.previous_active_seals = addon_data.player.active_seals

    -- iterate over the current player auras and process seals
    addon_data.player.active_seals = {}
    while not end_iter do
        local name, icon, count, _, duration, expiration_time, _, _, _, spell_id = UnitAura("player", counter)
        if name == nil then
            end_iter = True
            break
        end
        -- if a seal spell, process it
        if string.find(name, 'Seal of ') then
            addon_data.player.active_seals[name] = true
            addon_data.player.n_active_seals = addon_data.player.n_active_seals + 1
            if name == 'Seal of the Crusader' then               
                addon_data.player.crusader_currently_active = true
            end
        end
        counter = counter + 1
    end
end

-- Function to parse the list of Seals and set flags etc.
addon_data.player.process_auras = function()
    -- Check if crusader currently active.
    if addon_data.player.active_seals["Seal of the Crusader"] == nil then
        addon_data.player.crusader_currently_active = false
    end
    -- check for any new Seal of the Crusader casts
    if addon_data.player.crusader_currently_active then
        if addon_data.player.previous_active_seals["Seal of the Crusader"] == nil then
            -- if we're also midway through a swing, need some additional logic 
            -- to handle the haste snapshotting
            if addon_data.player.swing_timer > 0 then
                print('enabling crusader lock, new SotC cast midswing')
                addon_data.crusader_lock = true
            end
        end
    -- check for any Seal of the Crusader that's fallen off midswing
    elseif addon_data.player.previous_active_seals["Seal of the Crusader"] then
        if addon_data.player.swing_timer > 0 then
            print('enabling crusader lock, old SotC fell off midswing')
            addon_data.crusader_lock = true
        end
    end
end

-- There is no information in the event payload on what changed, so we have to rescan auras
-- on the player.
addon_data.player.on_player_aura_change = function()

    -- Function that parses the auras to record seals.
    addon_data.player.parse_auras()

    -- Function that processes the above.
    addon_data.player.process_auras()

    print(addon_data.player.active_seals)
    print(addon_data.player.n_active_seals)   
end

-- function to detect any spell casts like repentance that would reset
-- the swing timer
addon_data.player.OnPlayerSpellCast = function(event, args)
    -- only process player casts
    if not args[1] == "player" then
        return
    end

    -- detect repentance casts and reset the timer
    if args[4] == 20066 then
        addon_data.player.reset_swing_timer()

    -- detect HoW casts and log the cast guid
    elseif args[4] == 27180 then
        addon_data.player.how_cast_guid = args[3]

    -- detect Holy Wrath casts and log the cast guid
    elseif args[4] == 27139 then
        addon_data.player.holy_wrath_cast_guid = args[3]
    end
end

-- function to detect the player's successful casts that reset the 
-- swing timer
addon_data.player.OnPlayerSpellCompletion = function(event, args)
    if args[2] == addon_data.player.how_cast_guid then
        -- print('player successfully cast HoW, resetting swing timer')
        addon_data.player.reset_swing_timer()
    elseif args[2] == addon_data.player.holy_wrath_cast_guid then
        -- print('player successfully cast Holy Wrath, resetting swing timer...')
        addon_data.player.reset_swing_timer()
    end
end


addon_data.player.OnUpdate = function(elapsed)
    
    -- Logic for when the swing timer is complete.
    if addon_data.player.swing_timer == 0 then
        if not addon_data.player.reported_swing_timer_complete then
            addon_data.player.swing_timer_complete()
            addon_data.player.reported_swing_timer_complete = true
            -- addon_data.player.reported_swing_timer_complete_double = false
            addon_data.player.time_since_swing_completion = 0
        end

        -- -- Ensure the player's swing timer is re-polled a short time after swing completion 
        -- -- to catch late API updates.
        -- if not addon_data.player.reported_swing_timer_complete_double then
        --     if addon_data.player.time_since_swing_completion < 0.1 then
        --         addon_data.player.time_since_swing_completion = addon_data.player.time_since_swing_completion + elapsed
        --     else
        --         print('additional check')
        --         addon_data.player.update_weapon_speed()
        --         addon_data.player.reported_swing_timer_complete_double = true
        --     end
        -- end
        
    end
    
    -- addon_data.player.update_weapon_speed()
    -- print(addon_data.player.current_weapon_speed)
    -- temp fix for div by zero
    -- if addon_data.player.current_weapon_speed == 0 then
    --     addon_data.player.current_weapon_speed = 2
    -- end
  
    -- Repoll the attack speed a short while after an aura change
    if addon_data.player.repoll_on_aura_change then
        if addon_data.player.aura_repoll_counter > 0.4 then
            print('SECONDARY API POLL ON AURA CHANGE')
            addon_data.player.update_weapon_speed()
            addon_data.player.repoll_on_aura_change = false
        else
            addon_data.player.aura_repoll_counter = addon_data.player.aura_repoll_counter + elapsed
        end
    end

	-- If the weapon speed changed due to buffs/debuffs, we need to modify the swing timer
    if addon_data.player.speed_changed then
        if not addon_data.player.reported_speed_change then
            addon_data.bar.recalculate_ticks = true
            print('swing speed changed, timer updating')
            print(tostring(addon_data.player.prev_weapon_speed) .. " > " .. tostring(addon_data.player.current_weapon_speed))
            local main_multiplier = addon_data.player.current_weapon_speed / addon_data.player.prev_weapon_speed
            addon_data.player.swing_timer = addon_data.player.swing_timer * main_multiplier
            addon_data.player.reported_speed_change = true
        end
    end

    -- Update the swing timer
    addon_data.player.update_swing_timer(elapsed)
    
    -- Update the bar visuals
    addon_data.bar.update_visuals_on_update()
end

--=========================================================================================
-- Create a frame to process events relating to player information.
--=========================================================================================
-- This function handles events related to the player's statistics
addon_data.player.player_frame_on_event = function(self, event, ...)
	local args = {...}
    if event == "UNIT_INVENTORY_CHANGED" then
        addon_data.player.on_equipment_change()
        addon_data.player.update_weapon_speed()
    
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local combat_info = {CombatLogGetCurrentEventInfo()}
        addon_data.player.OnCombatLogUnfiltered(combat_info)
    
    elseif event == "UNIT_AURA" then
        print('processing aura change')
        addon_data.player.on_player_aura_change()
        addon_data.player.update_weapon_speed()

        -- Trigger logic to repoll after a small amount of time
        addon_data.player.repoll_on_aura_change = true
        -- reset the counter if we're still waiting on a second poll
        if addon_data.player.aura_repoll_counter > 0.0 then
            addon_data.player.aura_repoll_counter = 0.0
        end


    elseif event == "UNIT_SPELLCAST_SENT" then
        addon_data.player.OnPlayerSpellCast(event, args)
    
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        addon_data.player.OnPlayerSpellCompletion(event, args)
	end
end

addon_data.player_frame = CreateFrame("Frame", addon_name .. "PlayerFrame", UIParent)

--=========================================================================================
-- End, if debug verify module was read.
--=========================================================================================
if addon_data.debug then print('-- Parsed player.lua module correctly') end
