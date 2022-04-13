local addon_name, addon_data = ...


local print = addon_data.utils.print_msg
-- local print_tab = addon_data.utils.print_msg

-- PLAYER SETTINGS ======================================================================
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
addon_data.player.prev_weapon_speed = 2
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

-- Flag to detect if we have a new/falling off SotCr aura and need to change swing
-- timers to account for haste snapshotting
addon_data.crusader_active_previous_swing = false
addon_data.crusader_newly_active = false
addon_data.crusader_currently_active = false
addon_data.crusader_fallen_off = false
addon_data.crusader_fallen_off_mid_swing = false

addon_data.snapshot_new_crusader = false

addon_data.player.how_cast_guid = nil
addon_data.player.holy_wrath_cast_guid = nil

addon_data.player.InitSwingTimer = function()
    addon_data.player.swing_timer = 0.0001
end


-- Determine wether or not to draw the GCD line.
-- Hide if we are not in SoC or the swing bar is full
addon_data.player.DrawTwistWindow = function()
    if addon_data.player.swing_timer == 0 then
        return false
    end
    -- print(addon_data.player.active_seals["Seal of Command"] == nil)
    if addon_data.player.active_seals["Seal of Command"] ~= nil then
        return true
    end
    -- print('got here, returning false')
    return nil
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


addon_data.player.ResetSwingTimer = function()
    addon_data.player.swing_timer = addon_data.player.current_weapon_speed
end

addon_data.player.UpdateSwingTimer = function(elapsed)
    if character_player_settings.enabled then
        if addon_data.player.swing_timer > 0 then
            addon_data.player.swing_timer = addon_data.player.swing_timer - elapsed
            if addon_data.player.swing_timer < 0 then
                addon_data.player.swing_timer = 0
            end
        end
    end
end

addon_data.player.UpdateWeaponSpeed = function()
    addon_data.player.prev_weapon_speed = addon_data.player.current_weapon_speed

    -- handle seal of the crusader snapshotting for new crusader buffs
    if addon_data.player.swing_timer == 0 then
        addon_data.snapshot_new_crusader = false
        addon_data.crusader_fallen_off_mid_swing = false
    end
    if addon_data.snapshot_new_crusader == true then
        -- print('new crusader')
        addon_data.player.speed_changed = false
        return
    end

    -- and snapshotting for falling off crusader buffs
    if addon_data.crusader_fallen_off_mid_swing == true then
        addon_data.player.speed_changed = false
        return
    end

    addon_data.player.current_weapon_speed, _ = UnitAttackSpeed("player")
    if addon_data.player.current_weapon_speed ~= addon_data.player.prev_weapon_speed then
        addon_data.player.speed_changed = true
    else
        addon_data.player.speed_changed = false
    end
end

addon_data.player.OnInventoryChange = function()
    local new_guid = GetInventoryItemID("player", 16)
    -- Check for a main hand weapon change
    if addon_data.player.weapon_id ~= new_guid then
        addon_data.player.UpdateWeaponSpeed()
        addon_data.player.ResetSwingTimer()
    end
    addon_data.player.weapon_id = new_guid
end

addon_data.player.OnCombatLogUnfiltered = function(combat_info)
	local _, event, _, source_guid, _, _, _, dest_guid, _, _, _, _, spell_name, _ = unpack(combat_info)
	
    -- Handle all relevant events where the player is the action source
    if (source_guid == addon_data.player.guid) then
	-- check for extra attacks that would accidently reset the swing timer
		if (event == "SPELL_EXTRA_ATTACKS") then
			addon_data.player.extra_attacks_flag = true
		end
        if (event == "SWING_DAMAGE") then
			-- print('swing went off')
            -- local _, _, _, _, _, _, _, _, _, is_offhand = select(12, unpack(combat_info))
			if (addon_data.player.extra_attacks_flag == false) then
				addon_data.player.ResetSwingTimer()
			end
			addon_data.player.extra_attacks_flag = false
            addon_data.snapshot_new_crusader = false
            addon_data.player.crusader_newly_active = false
            addon_data.crusader_fallen_off_mid_swing = false
        elseif (event == "SWING_MISSED") then
			addon_data.player.ResetSwingTimer()
            addon_data.snapshot_new_crusader = false
            addon_data.player.crusader_newly_active = false
            addon_data.crusader_fallen_off_mid_swing = false
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
end

-- Called once on aura change for each active seal on the player
addon_data.player.OnSealChange = function(...)
    -- print('processing seal change')
    -- print('time now: ' .. GetTime())
    args = {...}
    if not args then
        return
    end
    -- for key, value in pairs(args) do
    --     print('key ' .. key)
    --     print(value)
    -- end
end


-- There is no information in the event payload on what changed, so we have to rescan auras
-- on the player.
addon_data.player.OnUnitAuraChange = function()
    local end_iter = false
    local counter = 1
    addon_data.player.n_active_seals = 0
    -- print('-------------')
    -- print('Processing auras on change...')

    -- copy the previous seals
    local previous_active_seals = addon_data.player.active_seals
    addon_data.player.active_seals = {}
    while not end_iter do
        local name, icon, count, _, duration, expiration_time, _, _, _, spell_id = UnitAura("player", counter)
        if name == nil then
            end_iter = True
            break
        end
        -- print(name .. " - " .. icon .. " - "  .. spell_id .. " - "  .. count .. " - expires: " .. expiration_time)

        -- if a seal spell, process it
        if string.find(name, 'Seal of ') then
            addon_data.player.OnSealChange(name, spell_id, expiration_time)
            -- table.insert(addon_data.player.active_seals, name)
            addon_data.player.active_seals[name] = true
            addon_data.player.n_active_seals = addon_data.player.n_active_seals + 1
            if name == 'Seal of the Crusader' then               
                addon_data.player.crusader_currently_active = true
            end
        end

        counter = counter + 1
    end

    if addon_data.player.active_seals["Seal of the Crusader"] == nil then
        addon_data.player.crusader_currently_active = false
    end

    -- check for any new Seal of the Crusader casts
    if addon_data.player.crusader_currently_active then
        if previous_active_seals["Seal of the Crusader"] == nil then
            addon_data.player.crusader_newly_active = true
            -- print('crusader newly up')
            -- print('swing timer says: ' .. addon_data.player.swing_timer)

            -- if we're also midway through a swing, need some additional logic 
            -- to handle the haste snapshotting
            if addon_data.player.swing_timer > 0 then
                -- print('midway a swing and new crusader, trigger additional speed logic')
                addon_data.snapshot_new_crusader = true
            end
        end
    -- check for any Seal of the Crusader that's fallen off midswing
    elseif previous_active_seals["Seal of the Crusader"] then
        if addon_data.player.swing_timer > 0 then
            -- print('crusader fallen off, need some snapshot magic')
            addon_data.crusader_fallen_off_mid_swing = true
        end
    end
    -- print(addon_data.player.active_seals)
    -- print('N active seals = ' .. addon_data.player.n_active_seals)
    -- for key, value in pairs(addon_data.player.active_seals) do
    --     print('key ' .. key)
    --     print(value)
    -- end
end

-- function to detect any spell casts like repentance that would reset
-- the swing timer
addon_data.player.OnPlayerSpellCast = function(event, args)
    -- print('processing spell cast')
    
    -- only process player casts
    if not args[1] == "player" then
        return
    end

    -- print('event: ' .. event)
    -- for key, value in pairs(args) do
    --     print(key .. " : " .. value)
    -- end

    -- detect repentance casts and reset the timer
    if args[4] == 20066 then
        addon_data.player.ResetSwingTimer()

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
        addon_data.player.ResetSwingTimer()
    elseif args[2] == addon_data.player.holy_wrath_cast_guid then
        -- print('player successfully cast Holy Wrath, resetting swing timer...')
        addon_data.player.ResetSwingTimer()
    end
end

addon_data.player.OnUpdate = function(elapsed)
    if character_player_settings.enabled then
        -- Update the weapon speed
        addon_data.player.UpdateWeaponSpeed()
        -- temp fix for div by zero
        if addon_data.player.current_weapon_speed == 0 then
            addon_data.player.current_weapon_speed = 2
        end		
	    -- If the weapon speed changed due to buffs/debuffs, we need to modify the timers
        if addon_data.player.speed_changed then
            -- print('swing speed changed, timer updating')
            -- print(tostring(addon_data.player.current_weapon_speed))
            local main_multiplier = addon_data.player.current_weapon_speed / addon_data.player.prev_weapon_speed
            addon_data.player.swing_timer = addon_data.player.swing_timer * main_multiplier
        end
        -- Update the main hand swing timer
        addon_data.player.UpdateSwingTimer(elapsed)
        -- Update the visuals
        addon_data.bar.UpdateVisualsOnUpdate()
    end
end

--=========================================================================================
-- Create a frame to process events relating to player information.
--=========================================================================================
-- This function handles events related to the player's statistics
local function player_frame_on_event(self, event, ...)
	local args = {...}
    if event == "UNIT_INVENTORY_CHANGED" then
        addon_data.player.OnInventoryChange()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local combat_info = {CombatLogGetCurrentEventInfo()}
        addon_data.player.OnCombatLogUnfiltered(combat_info)
    elseif event == "UNIT_AURA" then
        addon_data.player.OnUnitAuraChange()
    elseif event == "UNIT_SPELLCAST_SENT" then
        -- print('player casted a spell')
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
