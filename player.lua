local addon_name, addon_data = ...
local print = addon_data.utils.print_msg
local floor = addon_data.utils.SimpleRound

--=========================================================================================
-- PLAYER SETTINGS 
--=========================================================================================
addon_data.player = {}
addon_data.player.default_settings = {
	-- enabled = true,
    lag_detection_enabled = true,
    lag_threshold = 0.00,
    lag_multiplier = 1.5,
	-- width = 400,
	-- height = 20,
	-- fontsize = 12,
    -- point = "CENTER",
	-- rel_point = "CENTER",
	-- x_offset = 0,
	-- y_offset = -180,
	-- in_combat_alpha = 1.0,
	-- ooc_alpha = 0.65,
	-- backplane_alpha = 0.5,
	-- is_locked = false,
    -- show_left_text = true,
    -- show_right_text = true,
    -- show_border = false,
    -- classic_bars = true,
    -- fill_empty = true,
    -- main_r = 0.1, main_g = 0.1, main_b = 0.9, main_a = 1.0,
    -- main_text_r = 1.0, main_text_g = 1.0, main_text_b = 1.0, main_text_a = 1.0,
}

addon_data.player.class, addon_data.player.english_class, _ = UnitClass("player")[2] -- seems broken?

-- print(UnitClass("player")[2])
-- print(addon_data.player.class)
addon_data.player.guid = UnitGUID("player")

-- addon_data.player.auras = UnitAura(addon_data.player.guid)

addon_data.player.swing_timer = 0.00001
addon_data.player.prev_weapon_speed = 0.1
addon_data.player.current_weapon_speed = 4.0
addon_data.player.weapon_id = GetInventoryItemID("player", 16)
addon_data.player.speed_changed = false
addon_data.player.extra_attacks_flag = false

-- flag for when we update equipment without double counting the 
addon_data.player.equipment_update_flag = false

-- containers for seal information
addon_data.player.n_active_seals = 0
addon_data.player.active_seals = {}
addon_data.player.active_seal_1 = nil
addon_data.player.active_seal_1_remaining = 0
addon_data.player.active_seal_2 = nil
addon_data.player.active_seal_2_remaining = 0

addon_data.player.twist_impossible = false

-- does the player have heroism/lust buff active
addon_data.player.has_bloodlust = false

 -- a flag for any non-instant cast we pick up that doesn't trigger GCD on cast start,
 -- but instead will trigger gcd on the cast finish
addon_data.player.spell_guid_awaiting_gcd = nil

-- containers for GCD information
addon_data.player.active_gcd_full_duration = 0.0 -- length of the currently active GCD
addon_data.player.active_gcd_remaining = 0.0 -- timer on currently active GCD.
addon_data.reported_gcd_lockout = true
addon_data.player.new_cast_flag = false
addon_data.player.gcd_lockout = false -- lock for when we have an active GCD ticking
addon_data.player.gcd_cooldown_poll_max = nil -- container for the first returned result of the GCD poll
addon_data.player.spell_gcd_duration = 1.5
addon_data.player.base_gcd_duration = 1.5 -- should never change, use this for CS

-- flag to run a double poll after 0.1s on aura change to catch bad API calls
addon_data.player.aura_repoll_counter = 0.0
addon_data.player.repoll_on_aura_change = true

-- a flag to ensure the code on swing completion only runs once
addon_data.player.reported_swing_timer_complete = false
addon_data.player.reported_swing_timer_complete_double = false
addon_data.player.time_since_swing_completion = 0.0

-- a flag to ensure the code on speed change only runs once per change
addon_data.player.reported_speed_change = true

-- Flag to detect if we have a new/falling off SotCr aura and need to change swing
-- timers to account for haste snapshotting
addon_data.crusader_lock = false
addon_data.crusader_currently_active = false

-- Flags to detect any spell casts that would reset the swing timer.
addon_data.player.how_cast_guid = nil
addon_data.player.holy_wrath_cast_guid = nil

-- A measure of the player's ping
addon_data.player.lag_world = 0.0

addon_data.player.update_lag = function()
    local _, _, _, lag = GetNetStats()
    -- print('lag before calibration: ' .. tostring(lag))
    -- print('lag multiplier: ' .. tostring(character_player_settings.lag_multiplier))
    -- print('lag threshold: ' .. tostring(character_player_settings.lag_threshold))
    lag = (lag * character_player_settings.lag_multiplier) + character_player_settings.lag_threshold
    -- print('lag after calibration: ' .. tostring(lag))
    addon_data.player.lag_world = lag / 1000.0
end

addon_data.player.lag_detection_enabled = function()
    return character_player_settings.lag_detection_enabled
end

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
    -- print('Swing timer complete.')
    addon_data.player.update_weapon_speed()
    addon_data.bar.update_bar_on_timer_full()
end

-- Called when the swing timer should be reset
addon_data.player.reset_swing_timer = function()
    addon_data.crusader_lock = false
    addon_data.player.twist_impossible = false
    -- addon_data.player.update_weapon_speed() -- NOT SURE IF THIS IS NEEDED
    addon_data.player.swing_timer = addon_data.player.current_weapon_speed
    addon_data.player.reported_swing_timer_complete = false
    addon_data.bar.update_bar_on_swing_reset()
end

-- called onupdate to manually alter the swing timer with the elapsed time
addon_data.player.update_swing_timer = function(elapsed)
    if true then
        if addon_data.player.swing_timer > 0 then
            addon_data.player.swing_timer = addon_data.player.swing_timer - elapsed
            if addon_data.player.swing_timer < 0 then
                addon_data.player.swing_timer = 0
            end
        end
    end
end

-- called onupdate to manually alter the active GCD remaining time_before_swing
addon_data.player.update_active_gcd_timer = function(elapsed)
    if addon_data.player.active_gcd_remaining > 0 then
        addon_data.player.active_gcd_remaining = addon_data.player.active_gcd_remaining - elapsed
        if addon_data.player.active_gcd_remaining < 0 then
            addon_data.player.active_gcd_remaining = 0
        end
    end
end 

--=========================================================================================
-- Functions run when relevant events are intercepted
--=========================================================================================

addon_data.player.update_weapon_speed = function()
    -- Function called whenever it is possible that the attack speed has changed.
    -- We use the reported_speed_change flag to ensure that this logic happens
    -- exactly once during a player frame update, because multiple events can
    -- happen between the same update, and the logic to process speed changes
    -- is most efficiently handled in the onupdate.
    if not addon_data.player.reported_speed_change then 
        -- check the speed isn't the same, and if it is, return it
        -- this check picks up on multiple events between updates
        -- that can trigger attack speed changes
        local old = addon_data.player.current_weapon_speed
        local new = UnitAttackSpeed("player")
        if old == new then return end
    end

    -- Handle crusader snapshotting
    if addon_data.crusader_lock == true then
        print('Locking speed change because of crusader snapshot.')
        addon_data.player.speed_changed = false
        return
    end

    addon_data.player.prev_weapon_speed = addon_data.player.current_weapon_speed
    -- Poll the API for the attack speed
    addon_data.player.current_weapon_speed, _ = UnitAttackSpeed("player")
    -- print('API speed says: ' .. tostring(addon_data.player.current_weapon_speed))



    -- Update the attack speed and mark if it has changed.
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
        addon_data.player.equipment_update_flag = true
        addon_data.player.update_weapon_speed()
        addon_data.player.reset_swing_timer()
        addon_data.player.weapon_id = new_guid

        -- if we're also in combat, trigger a GCD
        if addon_data.core.in_combat then
            addon_data.player.process_possible_spell_cooldown()
        end
    end
end

-- Function run when we intercept an unfiltered combatlog event.
addon_data.player.OnCombatLogUnfiltered = function(combat_info)
	local _, event, _, source_guid, _, _, _, dest_guid, _, _, _, _, spell_name, _ = unpack(combat_info)
	
    -- addon_data.player.extra_attacks_flag = false
    
    -- Handle all relevant events where the player is the action source
    if (source_guid == addon_data.player.guid) then
	-- check for extra attacks that would accidently reset the swing timer
		if (event == "SPELL_EXTRA_ATTACKS") then
			addon_data.player.extra_attacks_flag = true
		end
        if event == "SWING_EXTRA_ATTACKS" then
            addon_data.player.extra_attacks_flag = true
        end
        if (event == "SWING_DAMAGE") then
			if (addon_data.player.extra_attacks_flag == false) then
				addon_data.player.reset_swing_timer()
			end
			addon_data.player.extra_attacks_flag = false
        elseif (event == "SWING_MISSED") then
            if (addon_data.player.extra_attacks_flag == false) then
			    addon_data.player.reset_swing_timer()
            end
        end
    -- Handle all relevant events where the player is the target
    elseif (dest_guid == addon_data.player.guid) then
        if (event == "SWING_MISSED") then
            local miss_type, is_offhand = select(12, unpack(combat_info))
            if miss_type == "PARRY" then
                -- parry reduces your swing timer by 40%, but cannot go below 20%.
                local swing_timer_reduced_40p = addon_data.player.swing_timer - (0.4 * addon_data.player.current_weapon_speed)
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

addon_data.player.calculate_spell_GCD_duration = function()
    local rating_percent_reduction = GetCombatRatingBonus(20)
    local base = addon_data.player.base_gcd_duration
    local current = base * (100 / (100+rating_percent_reduction))
    if addon_data.player.has_bloodlust then
        current = current * (1/1.3)
    end
    -- minimum GCD for paladins in 1s
    if current < 1 then
        current = 1.0
    end
    -- round to 3 decimal places
    current = floor(current, 0.001)
    addon_data.player.spell_gcd_duration = current
    return current
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
    local has_bloodlust = false
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
        -- Catch bloodlust or heroism
        elseif spell_id == 2825 or spell_id == 32182 then
            has_bloodlust = true
        end
        counter = counter + 1
    end
    addon_data.player.has_bloodlust = has_bloodlust
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
                -- print('enabling crusader lock, new SotC cast midswing')
                addon_data.crusader_lock = true
            end
        end
    -- check for any Seal of the Crusader that's fallen off midswing
    elseif addon_data.player.previous_active_seals["Seal of the Crusader"] then
        if addon_data.player.swing_timer > 0 then
            -- print('enabling crusader lock, old SotC fell off midswing')
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

    -- print(addon_data.player.active_seals)
    -- print(addon_data.player.n_active_seals)
    addon_data.player.calculate_spell_GCD_duration()
    addon_data.player.update_weapon_speed()
    addon_data.bar.update_bar_on_aura_change()
    
end


-- addon_data.player.trigger_gcd = function()
--     -- Function to trigger a new GCD in the addon's internal code.
--     local _, duration = GetSpellCooldown(29515)
--     print('detected GCD going off, setting internally: ' .. tostring(duration))
--     addon_data.player.gcd_lockout = true
--     addon_data.player.active_gcd_full_duration = duration
--     addon_data.player.active_gcd_remaining = duration
--     -- tell the bar to update
--     addon_data.bar.update_bar_on_new_gcd()
-- end


-- Function to detect any spell casts like repentance that would reset
-- the swing timer, and to handle GCD tracking
addon_data.player.OnPlayerSpellCast = function(event, args)
    
    -- print('detected spell cast')
    -- only process player casts
    if not args[1] == "player" then
        return
    end
    
    -- poll the GCD immediately for the max duration
    -- local _, duration = GetSpellCooldown(29515)
    
    -- if spell is not judgement, check if we're not on GCD.
    local spell_id = args[4] -- universal for a given spell type
    local spell_guid = args[3] -- completely unique 

    -- if not addon_data.player.gcd_lockout and spell_id ~= 20271 then
    --     local _, duration = GetSpellCooldown(29515)

    --     if duration == 0 then
    --         print('found a delayed GCD cast, GUID: ' .. spell_guid)
    --         addon_data.player.spell_guid_awaiting_gcd = spell_guid
    --     else
    --         print('detected GCD going off: ' .. tostring(duration))
    --         addon_data.player.trigger_gcd()

    --         -- addon_data.player.gcd_lockout = true
    --         -- addon_data.player.active_gcd_full_duration = duration
    --         -- addon_data.player.active_gcd_remaining = duration
    --     end
    --     -- addon_data.player.trigger_gcd()
    -- end

    -- elseif duration == 0 then
    --     print('Clearing GCD lock, GCD is zero')

    -- print(args)
    
    -- print('GCD duration from poll = ' .. tostring(duration))
    -- our_duration = addon_data.player.calculate_spell_GCD_duration()
    -- print('GCD duration from calc = ' .. tostring(our_duration))


    -- print('Sp Haste rating = ' .. tostring(GetCombatRating(20)))
    -- print('Sp Haste bonus = ' .. tostring(GetCombatRatingBonus(20)))
    -- detect repentance casts and reset the timer
    if spell_id == 20066 then
        addon_data.player.reset_swing_timer()

    -- detect HoW casts and log the cast guid
    elseif spell_id == 27180 then
        addon_data.player.how_cast_guid = spell_guid

    -- detect Holy Wrath casts and log the cast guid
    elseif spell_id == 27139 then
        addon_data.player.holy_wrath_cast_guid = spell_guid
    end
end

-- function to detect the player's successful casts that reset the 
-- swing timer
addon_data.player.OnPlayerSpellCompletion = function(event, args)
    -- print('Spell completed')
    if args[2] == addon_data.player.how_cast_guid then
        -- print('player successfully cast HoW, resetting swing timer')
        addon_data.player.reset_swing_timer()
    elseif args[2] == addon_data.player.holy_wrath_cast_guid then
        -- print('player successfully cast Holy Wrath, resetting swing timer...')
        addon_data.player.reset_swing_timer()
    end
    -- Catch any previous casts and check for GCD that *didn't* trigger a GCD
    -- Poll the GCD endpoint to see if we've started one.
    if args[2] == addon_data.player.spell_guid_awaiting_gcd then          
        local _, duration = GetSpellCooldown(29515)
        if duration > 0 then
            -- print('Received a late GCD from cast completion.')
        end
    end

end


-- Called when the player's spellcast is interrupt to reset the gcd.
addon_data.player.on_spell_interrupt = function()
    addon_data.player.active_gcd_remaining = 0
end


-- A function to repoll the GCD that does not respect the lockout
-- Used in the onupdate to account for event lag
addon_data.player.force_gcd_repoll = function()
    if addon_data.player.gcd_lockout then
        -- print('force repolling GCD')
        -- local time_now = GetTime()
        local time_now2, duration = GetSpellCooldown(29515)
        -- print('time_now says: ' .. time_now)
        -- print('time_now2 says: ' .. time_now)
        -- print('force repolled GCD: ' .. tostring(duration))

        addon_data.player.active_gcd_full_duration = duration
        addon_data.player.active_gcd_remaining = duration
    end
end


-- Called when we receive the SPELL_UPDATE_COOLDOWN event
addon_data.player.process_possible_spell_cooldown = function()
    -- first check if we're on gcd lockout
    if addon_data.player.gcd_lockout then
        -- print('on gcd lockout already, ignoring')
        return
    end

    local time_started, duration = GetSpellCooldown(29515)
    -- print('detected GCD going off, setting internally: ' .. tostring(duration))
    if duration == 0 then
        -- print('SPELL_UPDATE_COOLDOWN with no GCD duration')
        return
    end

    local time_now = GetTime()
    local calced_duration_remaining = duration - (time_now - time_started)
    -- print(time_now - time_started)
    -- print('time_now says:' .. tostring(time_now))
    -- print('time_started says: ' .. tostring(time_started))
    -- print('duration says: ' .. tostring(duration))
    -- print('calculated duration remaining:' .. tostring(calced_duration_remaining))

    addon_data.player.gcd_lockout = true
    addon_data.reported_gcd_lockout = false
    addon_data.player.active_gcd_full_duration = duration
    addon_data.player.active_gcd_remaining = calced_duration_remaining
    
    -- -- Figure out if we're lagging
    -- local gcd_with_lag = time_now + duration
    -- print('GCD with lag says:' .. tostring(gcd_with_lag))
    -- local time_since_previous_swing = addon_data.player.current_weapon_speed - addon_data.player.swing_timer
    -- local gcd_ends_relative_to_swing = time_since_previous_swing + duration
    -- print('GCD ends relative to swing: ' .. tostring(gcd_ends_relative_to_swing))
    -- if gcd_ends_relative_to_swing > addon_data.player.current_weapon_speed then
    --     if addon_data.player.swing_timer > character_bar_settings.twist_window then
    --         print('SHIT SON WE COULD BE MISSING THIS TWIST')
    --         addon_data.player.twist_impossible = true
    --     end
    -- end

    -- Figure out if we're lagging
    addon_data.player.update_lag()

    -- This is the lag derived from the difference in the duration remaining from the API
    -- and when we are first aware of the GCD. This is most often zero but sometimes there
    -- will be a pronounced difference that I theorise is due to lag, and is more likely
    -- to be accurate that the ping from the GetNetStats API, which only repolls every 30s.
    -- local dynamic_lag = duration - calced_duration_remaining
    -- print('Dynamic lag estimate: ' .. tostring(dynamic_lag))

    local gcd_ends_relative_to_swing = 0
    local time_since_previous_swing = addon_data.player.current_weapon_speed - addon_data.player.swing_timer

    -- if dynamic_lag > 0 then
    --     print('DETECTED DYNAMIC LAG, using for estimate.')
    --     local gcd_with_lag = calced_duration_remaining + dynamic_lag
    --     gcd_ends_relative_to_swing = time_since_previous_swing + gcd_with_lag
    -- else
    --     local gcd_with_lag = calced_duration_remaining + addon_data.player.lag_world
    --     gcd_ends_relative_to_swing = time_since_previous_swing + gcd_with_lag
    -- end

    local gcd_with_lag = calced_duration_remaining + addon_data.player.lag_world
    gcd_ends_relative_to_swing = time_since_previous_swing + gcd_with_lag
    -- local gcd_with_lag = calced_duration_remaining + addon_data.player.lag_world
    
    -- local gcd_ends_relative_to_swing = time_since_previous_swing + gcd_with_lag
    -- print('GCD + lag ends relative to swing: ' .. tostring(gcd_ends_relative_to_swing))
    -- print('Current attack speed: ' .. tostring(addon_data.player.current_weapon_speed))
    -- print('Lag after calibration: ' .. tostring(addon_data.player.lag_world))
       
    -- local gcd_relative_to_swing_with_threshold = gcd_ends_relative_to_swing + character_player_settings.lag_threshold
    if character_bar_settings.lag_detection_enabled then
        if gcd_ends_relative_to_swing > addon_data.player.current_weapon_speed then
            if addon_data.player.swing_timer > character_bar_settings.twist_window then
                -- print('SHIT SON WE COULD BE MISSING THIS TWIST')
                addon_data.player.twist_impossible = true
            end
        end
    end

    -- addon_data.player.update_lag

    -- tell the bar to update
    -- addon_data.bar.update_bar_on_new_gcd()
end


addon_data.player.frame_on_update = function(self, elapsed)
    
    -- print('elapsed says')
    -- print(elapsed)

    -- Logic for when the swing timer is complete.
    if addon_data.player.swing_timer == 0 and not addon_data.player.reported_swing_timer_complete then
        addon_data.player.swing_timer_complete()
        addon_data.bar.update_bar_on_timer_full()
        addon_data.player.reported_swing_timer_complete = true
        addon_data.player.twist_impossible = false
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
            
    -- addon_data.player.update_weapon_speed()
    -- print(addon_data.player.current_weapon_speed)
    -- temp fix for div by zero
    -- if addon_data.player.current_weapon_speed == 0 then
    --     addon_data.player.current_weapon_speed = 2
    -- end
  
    -- Repoll the attack speed a short while after an aura change
    if addon_data.player.repoll_on_aura_change then
        if addon_data.player.aura_repoll_counter > 0.3 then
            -- print('SECONDARY API POLL ON AURA CHANGE')
            addon_data.player.update_weapon_speed()
            addon_data.player.aura_repoll_counter = 0.0
            addon_data.player.repoll_on_aura_change = false
        else
            addon_data.player.aura_repoll_counter = addon_data.player.aura_repoll_counter + elapsed
        end
    end

    -- If there is a GCD lock, check if we should clear it.
    if addon_data.player.gcd_lockout then
        addon_data.player.update_active_gcd_timer(elapsed)
        if addon_data.player.active_gcd_remaining == 0 then
            -- print('reached end of GCD, releasing lock')
            addon_data.player.gcd_lockout = false
            addon_data.bar.hide_gcd_bar()
        end
    end

    -- If the weapon speed changed due to buffs/debuffs, we need to modify the swing timer
    -- and inform all the UI elements that need things altered or recalculated.   
    if addon_data.player.speed_changed and not addon_data.player.reported_speed_change then
        -- print('swing speed changed, timer updating')
        -- print(tostring(addon_data.player.prev_weapon_speed) .. " > " .. tostring(addon_data.player.current_weapon_speed))
        

        -- Modify swing timer but only if we don't have the equipment flag set because the timer is already reset
        if not addon_data.player.equipment_update_flag then
            local multiplier = addon_data.player.current_weapon_speed / addon_data.player.prev_weapon_speed
            -- print('multiplier: ' .. tostring(multiplier))
            -- print('swing timer before multiplier: ' .. tostring(addon_data.player.swing_timer))
            addon_data.player.swing_timer = addon_data.player.swing_timer * multiplier
            -- print('swing timer after multiplier: ' .. tostring(addon_data.player.swing_timer))
            -- print(addon_data.player.swing_timer)
            -- print('swing timer after update func and elapsed: ' .. tostring(addon_data.player.swing_timer))
            
        else
            -- print('intercepting redundant speed change from equipment change')
            addon_data.player.equipment_update_flag = false
        end            
        -- recalculate any necessary bar visuals
        addon_data.bar.update_bar_on_speed_change()
        -- flag so this only runs once on speed change
        addon_data.player.reported_speed_change = true

    end

    if addon_data.player.gcd_lockout and not addon_data.reported_gcd_lockout then
        -- addon_data.player.force_gcd_repoll()     
        addon_data.bar.update_bar_on_new_gcd()
        addon_data.reported_gcd_lockout = true
    end 


    -- Always update the swing timer with how much time has elapsed
    addon_data.player.update_swing_timer(elapsed)


    -- Always update the bar visuals
    addon_data.bar.update_visuals_on_update()


end

--=========================================================================================
-- Create a frame to process events relating to player information.
--=========================================================================================
-- This function handles events related to the player's statistics
addon_data.player.frame_on_event = function(self, event, ...)
	local args = {...}
    if event == "UNIT_INVENTORY_CHANGED" then
        -- print('INVENTORY CHANGE DETECTED')
        addon_data.player.on_equipment_change()
        addon_data.player.process_possible_spell_cooldown()
        -- addon_data.player.update_weapon_speed()

    elseif event == "UNIT_SPELLCAST_SENT" then
        -- print('INFO: received spellcast trigger')
        addon_data.player.OnPlayerSpellCast(event, args)        

    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local combat_info = {CombatLogGetCurrentEventInfo()}
        addon_data.player.OnCombatLogUnfiltered(combat_info)
    
    elseif event == "UNIT_AURA" then
        -- print('processing aura change')
        addon_data.player.on_player_aura_change()

        -- Trigger logic to repoll after a small amount of time
        addon_data.player.repoll_on_aura_change = true
        -- reset the counter if we're still waiting on a second poll
        if addon_data.player.aura_repoll_counter > 0.0 then
            addon_data.player.aura_repoll_counter = 0.0
        end
    
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        addon_data.player.OnPlayerSpellCompletion(event, args)

    elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
        -- print('found an interruption')
        addon_data.player.on_spell_interrupt()
    

    elseif event == "SPELL_UPDATE_COOLDOWN" then
        -- print('spell update cd triggering a GCD')
        addon_data.player.process_possible_spell_cooldown()
    end

end

addon_data.player_frame = CreateFrame("Frame", addon_name .. "PlayerFrame", UIParent)

--=========================================================================================
-- End, if debug verify module was read.
--=========================================================================================
if addon_data.debug then print('-- Parsed player.lua module correctly') end
