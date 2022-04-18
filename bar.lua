
-- bar.lua =============================================================================
local addon_name, addon_data = ...
local print = addon_data.utils.print_msg
print('starting bar.lua parsing')

--=========================================================================================
-- BAR SETTINGS 
--=========================================================================================
addon_data.bar = {}
addon_data.bar.default_settings = {
	enabled = true,
	width = 400,
	height = 20,
	fontsize = 12,
    point = "CENTER",
	rel_point = "CENTER",
	x_offset = 0,
	y_offset = -180,
	in_combat_alpha = 1.0,
	ooc_alpha = 1.0,
	backplane_alpha = 1.0,
	is_locked = false,
    show_left_text = true,
    show_right_text = true,
    show_border = false,
    classic_bars = true,
    fill_empty = true,
    main_r = 0.1, main_g = 0.1, main_b = 0.9, main_a = 1.0,
    main_text_r = 1.0, main_text_g = 1.0, main_text_b = 1.0, main_text_a = 1.0,
    bar_color_default = {0.4, 0.4, 0.4, 1.0},
    bar_color_twisting = {0.51, 0.04, 0.73, 1.0},
    bar_color_twist_ready = {0., 0.99, 0., 1.0},
    bar_color_blood = {0.99, 0.37, 0.0, 1.0},
    bar_color_warning = {1.0, 0.0, 0.0, 1.0}, -- when if you cast SoC, you can't twist out of it that swing
    bar_color_gcd = {0.2, 0.2, 0.2, 1.0},
    twist_window = 0.4,
    grace_period = 0.2,
}

-- the following should be flagged when the swing speed changes to
-- evaluate the new offsets for ticks
addon_data.bar.recalculate_ticks = false
addon_data.bar.twist_tick_offset = 0.1
addon_data.bar.gcd1_tick_offset = 0.1
addon_data.bar.gcd2_tick_offset = 0.1

addon_data.bar.gcd_bar_width = 0.0

addon_data.bar.LoadSettings = function()
    -- If the carried over settings dont exist then make them
    if not character_bar_settings then
        character_bar_settings = {}
    end
    -- character_bar_settings = {} -- REMOVE ME THIS IS FOR TESTING
    -- If the carried over settings aren't set then set them to the defaults
    for setting, value in pairs(addon_data.bar.default_settings) do
        if character_bar_settings[setting] == nil then
            character_bar_settings[setting] = value
        end
    end

end

--=========================================================================================
-- Drag and drop settings
--=========================================================================================
addon_data.bar.OnFrameDragStart = function()
    if not character_player_settings.is_locked then
        addon_data.bar.frame:StartMoving()
    end
end

addon_data.bar.OnFrameDragStop = function()
    local frame = addon_data.bar.frame
    local settings = character_player_settings
    frame:StopMovingOrSizing()
    point, _, rel_point, x_offset, y_offset = frame:GetPoint()
    if x_offset < 20 and x_offset > -20 then
        x_offset = 0
    end
    settings.point = point
    settings.rel_point = rel_point
    settings.x_offset = addon_data.utils.SimpleRound(x_offset, 1)
    settings.y_offset = addon_data.utils.SimpleRound(y_offset, 1)
    addon_data.bar.UpdateVisualsOnSettingsChange()
    addon_data.bar.UpdateConfigPanelValues()
end

--=========================================================================================
-- Intialisation and setting change functionality
--=========================================================================================

-- this function is called once to initialise all the graphics of the bar
addon_data.bar.init_bar_visuals = function()
    local settings = character_player_settings
    addon_data.bar.frame = CreateFrame("Frame", addon_name .. "BarFrame", UIParent)   
    local frame = addon_data.bar.frame

    -- Set initial frame properties
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(not settings.is_locked)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", addon_data.bar.OnFrameDragStart)
    frame:SetScript("OnDragStop", addon_data.bar.OnFrameDragStop)
    
    -- Create the backplane and border
    frame.backplane = CreateFrame("Frame", addon_name .. "BarBackdropFrame", frame, "BackdropTemplate")
    frame.backplane:SetPoint('TOPLEFT', -9, 9)
    frame.backplane:SetPoint('BOTTOMRIGHT', 9, -9)
    frame.backplane:SetFrameStrata('BACKGROUND')

    if settings.show_border then
        frame.backplane:SetBackdrop({
            bgFile = "Interface/AddOns/SwedgeTimer/Images/Background", 
            edgeFile = "Interface/AddOns/SwedgeTimer/Images/Border", 
            tile = true, tileSize = 16, edgeSize = 12, 
            insets = { left = 8, right = 8, top = 8, bottom = 8}})
    else
        frame.backplane:SetBackdrop({
            bgFile = "Interface/AddOns/SwedgeTimer/Images/Background", 
            edgeFile = nil, 
            tile = true, tileSize = 16, edgeSize = 16, 
            insets = { left = 8, right = 8, top = 8, bottom = 8}})
    end

    -- if settings.show_border then
    --     frame.backplane:SetBackdrop({
    --         bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    --         edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    --         edgeSize = 16,
    --         insets = { left = 4, right = 4, top = 4, bottom = 4 },
    --     })
    --     -- frame.backplane:SetBackdrop({
    --     --     bgFile = "Interface/AddOns/Hurricane/Images/Background", 
    --     --     edgeFile = "Interface/buttons/white8x8", 
    --     --     tile = true, tileSize = 16,
    --     --     edgeSize = 16, 
    --     --     insets = { left = 8, right = 8, top = 8, bottom = 8}})
    -- else
    --     frame.backplane:SetBackdrop({
    --         bgFile = "Interface/AddOns/Hurricane/Images/Background", 
    --         edgeFile = nil, 
    --         tile = true, tileSize = 16, edgeSize = 16, 
    --         insets = { left = 8, right = 8, top = 8, bottom = 8}})
    -- end

    -- Create the swing timer bar
    frame.bar = frame:CreateTexture(nil,"ARTWORK")
    frame:SetHeight(settings.height)
    frame.bar:SetPoint("TOPLEFT", 0, 0)
    frame.bar:SetHeight(settings.height)
    frame.bar:SetTexture('Interface/AddOns/SwedgeTimer/Images/Bar')
    frame.bar:SetVertexColor(unpack(character_bar_settings["bar_color_default"]))

    -- Create the GCD timer bar
    frame.gcd_bar = frame:CreateTexture(nil, "ARTWORK")
    frame.gcd_bar:SetPoint("TOPLEFT", 0, 0)
    frame.gcd_bar:SetHeight(settings.height)
    frame.gcd_bar:SetTexture('Interface/AddOns/SwedgeTimer/Images/Bar')
    frame.gcd_bar:SetVertexColor(unpack(character_bar_settings["bar_color_gcd"]))
    frame.gcd_bar:SetDrawLayer("ARTWORK", -1)

    -- Create the spark for the timer
    frame.spark = frame:CreateTexture(nil,"OVERLAY")
    -- frame.spark:SetTexture('Interface/AddOns/SwedgeTimer/Images/Spark')

    -- Create the bar left text
    frame.left_text = frame:CreateFontString(nil, "OVERLAY")
    frame.left_text:SetFont("Fonts/FRIZQT__.ttf", settings.fontsize, "OUTLINE")
    frame.left_text:SetShadowColor(0.0,0.0,0.0,1.0)
    frame.left_text:SetShadowOffset(1,-1)
    frame.left_text:SetJustifyV("CENTER")
    frame.left_text:SetJustifyH("LEFT")
    -- Create the bar right text
    frame.right_text = frame:CreateFontString(nil, "OVERLAY")
    frame.right_text:SetFont("Fonts/FRIZQT__.ttf", settings.fontsize, "OUTLINE")
    frame.right_text:SetShadowColor(0.0,0.0,0.0,1.0)
    frame.right_text:SetShadowOffset(1,-1)
    frame.right_text:SetJustifyV("CENTER")
    frame.right_text:SetJustifyH("RIGHT")

    -- Create the line markers
    frame.twist_line = frame:CreateLine() -- the twist window marker
    frame.twist_line:SetColorTexture(1,1,1,1)
    frame.twist_line:SetDrawLayer("OVERLAY", -1)
    frame.twist_line:SetThickness(3)
    frame.twist_line:SetStartPoint("TOPRIGHT", 0, 0) -- dummy vars so the line is initialised
    frame.twist_line:SetEndPoint("BOTTOMRIGHT", 0, 0)

    -- local offset = addon_data.bar.get_twist_tick_offset()
    -- print(offset)
    -- frame.bar.twist_tick_offset = offset
    -- frame.bar.recalculate_ticks = false
    -- frame.twist_line:SetStartPoint("TOPRIGHT",offset,0)
    -- frame.twist_line:SetEndPoint("BOTTOMRIGHT",offset,0)

    frame.gcd1_line = frame:CreateLine() -- the first gcd possible before a twist
    frame.gcd1_line:SetColorTexture(0.4,0.4,1,1)
    frame.gcd1_line:SetDrawLayer("OVERLAY", -1)
    frame.gcd1_line:SetThickness(3)
    
    frame.gcd2_line = frame:CreateLine()
    frame.gcd2_line:SetColorTexture(1,1,1,1)
    frame.gcd2_line:SetDrawLayer("OVERLAY", -1)
    frame.gcd2_line:SetThickness(3)
    
    -- Run an update to configure the bar appropriately
    -- addon_data.bar.UpdateVisualsOnSettingsChange()
    -- addon_data.bar.update_visuals_on_update()

    print('Successfully initialised all bar visuals.')
	frame:Show()
end

-- this function is called when a setting related to bar visuals is changed
addon_data.bar.UpdateVisualsOnSettingsChange = function()
    local frame = addon_data.bar.frame
    local settings = character_player_settings
    -- print("enabled says: " .. tostring(settings.enabled))
    -- print("show_border says : " .. tostring(settings.show_border))
    if settings.enabled then
        frame:Show()
        frame:ClearAllPoints()
        frame:SetPoint(settings.point, UIParent, settings.rel_point, settings.x_offset, settings.y_offset)
        frame:SetWidth(settings.width)
        if settings.show_border then
            frame.backplane:SetBackdrop({
                bgFile = "Interface/AddOns/SwedgeTimer/Images/Background", 
                edgeFile = "Interface/AddOns/SwedgeTimer/Images/Border", 
                tile = true, tileSize = 16, edgeSize = 12, 
                insets = { left = 8, right = 8, top = 8, bottom = 8}})
        else
            frame.backplane:SetBackdrop({
                bgFile = "Interface/AddOns/SwedgeTimer/Images/Background", 
                edgeFile = nil, 
                tile = true, tileSize = 16, edgeSize = 16, 
                insets = { left = 8, right = 8, top = 8, bottom = 8}})
        end
        -- if settings.show_border then
        --     frame.backplane:SetBackdrop({
        --         bgFile = "Interface/AddOns/Hurricane/Images/Background", 
        --         edgeFile = "interface/buttons/white8x8", 
        --         tile = true, tileSize = 16,
        --         edgeSize = 16, 
        --         insets = { left = 8, right = 8, top = 8, bottom = 8}})
        -- else
        --     frame.backplane:SetBackdrop({
        --         bgFile = "Interface/AddOns/Hurricane/Images/Background", 
        --         edgeFile = nil, 
        --         tile = true, tileSize = 16, edgeSize = 16, 
        --         insets = { left = 8, right = 8, top = 8, bottom = 8}})
        -- end
        frame.backplane:SetBackdropColor(0,0,0,settings.backplane_alpha)

        frame.bar:SetPoint("TOPLEFT", 0, 0)
        frame.bar:SetHeight(settings.height)



        frame.bar:SetTexture('Interface/AddOns/SwedgeTimer/Images/Bar')
        frame.bar:SetVertexColor(unpack(character_bar_settings["bar_color_default"]))
        frame.spark:SetSize(16, settings.height)
        frame.left_text:SetPoint("TOPLEFT", 2, -(settings.height / 2) + (settings.fontsize / 2))
        frame.left_text:SetTextColor(settings.main_text_r, settings.main_text_g, settings.main_text_b, settings.main_text_a)
		-- frame.left_text:SetFont("Fonts/FRIZQT__.ttf", settings.fontsize)
	
        frame.right_text:SetPoint("TOPRIGHT", -5, -(settings.height / 2) + (settings.fontsize / 2))
        frame.right_text:SetTextColor(settings.main_text_r, settings.main_text_g, settings.main_text_b, settings.main_text_a)
		-- frame.right_text:SetFont("Fonts/FRIZQT__.ttf", settings.fontsize)

        if settings.show_left_text then
            frame.left_text:Show()
        else
            frame.left_text:Hide()
        end
        if settings.show_right_text then
            frame.right_text:Show()
        else
            frame.right_text:Hide()
        end
    else
        frame:Hide()
    end
end


print('ok')
--=========================================================================================
-- OnUpdate widget handlers and functions
--=========================================================================================

addon_data.bar.update_visuals_on_update = function()
    -- This function will be called once every frame after the event-based code has run,
    -- but before the frame is drawn.
    -- Func is called by the player frame OnUpdate (maybe we should change this).
    -- As such it should be kept as minimal as possible to avoid wasting resources.

    local settings = character_player_settings
    local frame = addon_data.bar.frame
    if not settings.enabled then return end 

    local speed = addon_data.player.current_weapon_speed
    local timer = addon_data.player.swing_timer

    -- if speed == 0 then
    --     speed = 2
    --     print('WARNING: prevented zero division error')
    -- end

    -- Update the main bar's width
    local timer_width = math.min(settings.width - (settings.width * (timer / speed)), settings.width)
    if not settings.fill_empty then
        timer_width = settings.width - timer_width + 0.001
    end
    
    frame.bar:SetWidth(timer_width)
    frame.spark:SetPoint('TOPLEFT', timer_width - 8, 0)
    
    -- frame.gcd_bar:SetWidth(settings.width/2)
    frame.gcd_bar:Show()

    if timer_width == settings.width or not settings.classic_bars or timer_width == 0.001 then
        frame.spark:Hide()
    else
        frame.spark:Show()
    end

    -- Update the main bars text, hide right text if bar full
    frame.left_text:SetText(tostring(addon_data.utils.SimpleRound(speed, 0.1)))
    frame.right_text:SetText(tostring(addon_data.utils.SimpleRound(timer, 0.1)))
    if addon_data.bar.draw_right_text() then
        frame.right_text:Show()
    else
        frame.right_text:Hide()
    end

    -- If SoC, bar colour is time sensitive. Deal with that here.
    if addon_data.player.active_seals["Seal of Command"] ~= nil and addon_data.player.n_active_seals == 1 then
        if addon_data.player.swing_timer < character_bar_settings["twist_window"] then 
            addon_data.bar.frame.bar:SetVertexColor(unpack(character_bar_settings["bar_color_twist_ready"]))
        else
            local min_time = addon_data.player.spell_gcd_duration + character_bar_settings["grace_period"]
            if addon_data.player.swing_timer > min_time then            
                addon_data.bar.frame.bar:SetVertexColor(unpack(character_bar_settings["bar_color_twist_ready"]))
            else
                addon_data.bar.frame.bar:SetVertexColor(unpack(character_bar_settings["bar_color_warning"]))
            end
        end        
    end
    
end


addon_data.bar.hide_gcd_bar = function()
    -- function to "hide" the gcd bar by reducing the width to zero
    -- instead of using the dedicated Hide method
    addon_data.bar.gcd_bar_width = 0
    addon_data.bar.frame.gcd_bar:SetWidth(0)
end

addon_data.bar.set_gcd_bar_width = function()

    if not addon_data.player.gcd_lockout then
        addon_data.bar.gcd_bar_width = 0
        addon_data.bar.frame.gcd_bar:SetWidth(0)
    end

    local settings = character_player_settings
    local attack_speed = addon_data.player.current_weapon_speed
    local swing_timer = addon_data.player.swing_timer
    -- print(attack_speed)
    -- print(swing_timer)
    -- print(addon_data.player.active_gcd_remaining)
    local time_since_bar_start = addon_data.player.current_weapon_speed - addon_data.player.swing_timer


    local time_gcd_ends = time_since_bar_start + addon_data.player.active_gcd_remaining
    -- print("Time relative to bar the GCD ends = " .. tostring(time_gcd_ends))

    if time_gcd_ends > attack_speed then
        time_gcd_ends = attack_speed
    end
    -- print("Modified time relative to bar the GCD ends = " .. tostring(time_gcd_ends))


    -- local gcd_bar_width = settings.width - (time_gcd_ends / attack_speed)

    local gcd_bar_width = (time_gcd_ends / attack_speed) * settings.width
    -- print('offset says ' .. tostring(offset))

    -- -- if it exceeds the bar width, max it out.
    -- if offset > settings.width then
    --     gcd_bar_width = settings.width - 0.001
    -- elseif gcd_bar_width < 0 then
    --     gcd_bar_width = 0.001
    -- end
        
    -- print('gcd bar width says ' .. gcd_bar_width)
    addon_data.bar.gcd_bar_width = gcd_bar_width
    addon_data.bar.frame.gcd_bar:SetWidth(gcd_bar_width)
end


addon_data.bar.update_bar_on_combat = function()
    -- Function called to update bar when entering/leaving combat.
        -- Update the alpha
        if addon_data.core.in_combat then
            addon_data.bar.frame:SetAlpha(character_bar_settings.in_combat_alpha)
        else
            addon_data.bar.frame:SetAlpha(character_bar_settings.ooc_alpha)
        end
end

addon_data.bar.update_bar_on_timer_full = function()
    -- Function called when the bar fills up to change any bar visuals
    -- addon_data.bar.frame.twist_line:Hide()
    -- addon_data.bar.frame.gcd1_line:Hide()
    -- addon_data.bar.frame.gcd2_line:Hide()
    addon_data.bar.set_gcd_bar_width()
    addon_data.bar.frame.twist_line:Hide()
    addon_data.bar.frame.gcd1_line:Hide()
    addon_data.bar.frame.gcd2_line:Hide()
end

addon_data.bar.show_or_hide_ticks = function()
    local frame = addon_data.bar.frame

    -- always hide ticks at full swing timer
    if addon_data.player.swing_timer == 0 then
        addon_data.bar.frame.twist_line:Hide()
        addon_data.bar.frame.gcd1_line:Hide()
        addon_data.bar.frame.gcd2_line:Hide()
        return
    end

    -- Twist line
    if addon_data.bar.should_draw_twist_window() then
        frame.twist_line:Show()
    else
        frame.twist_line:Hide()
    end
    -- First GCD line
    if addon_data.bar.should_draw_gcd1_window() then
        frame.gcd1_line:Show()
    else
        frame.gcd1_line:Hide()
    end
    -- Second GCD line
    if addon_data.bar.should_draw_gcd2_window() then
        frame.gcd2_line:Show()
    else
        frame.gcd2_line:Hide()
    end
end

addon_data.bar.update_bar_on_swing_reset = function()
    -- Function called when the swing timer resets to change any bar visuals
    addon_data.bar.show_or_hide_ticks()
    -- Recalculate the gcd bar width
    addon_data.bar.set_gcd_bar_width()
end

addon_data.bar.update_bar_on_new_gcd = function()
    addon_data.bar.set_gcd_bar_width()
end

addon_data.bar.update_bar_on_speed_change = function()
    -- A function to be run once upon the player's speed updating.
    -- This will recalculate all necessary frame element updates here
    -- to keep them out the main onupdate function
    print('Recalculating bar visuals on speed change...')
    addon_data.bar.set_twist_tick_offset()
    addon_data.bar.set_gcd1_tick_offset()
    addon_data.bar.set_gcd2_tick_offset()
end

addon_data.bar.update_bar_on_aura_change = function()
    -- A function to be run once upon the player's auras changing.
    -- Aura changes determine if the twist line should be drawn or not.
    if addon_data.player.swing_timer ~=0 and addon_data.bar.should_draw_twist_window() then
        addon_data.bar.frame.twist_line:Show()
    else
        addon_data.bar.frame.twist_line:Hide()
    end
    addon_data.bar.set_bar_color()

    -- if the spell haste changes we need to update the tick offsets
    addon_data.bar.set_twist_tick_offset()
    addon_data.bar.set_gcd1_tick_offset()
    addon_data.bar.set_gcd2_tick_offset()

    -- determine if we should now show or hide the ticks
    addon_data.bar.show_or_hide_ticks()
end

-- Determine wether or not to draw the twist line
-- Hide if we are not in SoC or the swing bar is full
addon_data.bar.should_draw_twist_window = function()
    if addon_data.player.active_seals["Seal of Command"] ~= nil then
        return true
    end
    return false
end

-- determine wether or not to draw the gcd1 line
addon_data.bar.should_draw_gcd1_window = function()
    local settings = character_player_settings
    if math.abs(addon_data.bar.gcd1_tick_offset) > settings.width then
        return false
    end
    return true
end

-- determine wether or not to draw the gcd2 line
addon_data.bar.should_draw_gcd2_window = function()
    local settings = character_player_settings
    if math.abs(addon_data.bar.gcd2_tick_offset) > settings.width then
        return false
    end
    return true
end

addon_data.bar.set_twist_tick_offset = function()
-- Set the offset position of the twist window
    local settings = character_player_settings
    local bar_fraction = (0.4 / addon_data.player.current_weapon_speed)
    local offset = bar_fraction * settings.width * -1
    -- print('twist tick time = ' .. time_value)
    addon_data.bar.twist_tick_offset = offset
    addon_data.bar.frame.twist_line:SetStartPoint("TOPRIGHT", offset, 0)
    addon_data.bar.frame.twist_line:SetEndPoint("BOTTOMRIGHT", offset, 0)
end

-- Get the offset position of the first gcd window tick
addon_data.bar.set_gcd1_tick_offset = function()
    local settings = character_player_settings
    -- dummy for the actual gcd value, which we will figure out later
    local gcd_duration = addon_data.player.spell_gcd_duration
    local grace_period = character_bar_settings["grace_period"]
    local time_before_swing = gcd_duration + grace_period
    -- print('GCD1 tick time = ' .. time_before_swing)
    offset = (time_before_swing / addon_data.player.current_weapon_speed) * settings.width * -1
    addon_data.bar.gcd1_tick_offset = offset
    addon_data.bar.frame.gcd1_line:SetStartPoint("TOPRIGHT", offset, 0)
    addon_data.bar.frame.gcd1_line:SetEndPoint("BOTTOMRIGHT", offset, 0)
end

-- Get the offset position of the second gcd window tick
addon_data.bar.set_gcd2_tick_offset = function()
    local settings = character_player_settings
    -- dummy for the actual gcd value, which we will figure out later
    local gcd_duration = addon_data.player.spell_gcd_duration
    local grace_period = character_bar_settings["grace_period"]
    local time_before_swing = (2 * gcd_duration) + grace_period
    -- print('GCD2 tick time = ' .. time_before_swing)
    offset = (time_before_swing / addon_data.player.current_weapon_speed) * settings.width * -1
    addon_data.bar.gcd2_tick_offset = offset
    addon_data.bar.frame.gcd2_line:SetStartPoint("TOPRIGHT", offset, 0)
    addon_data.bar.frame.gcd2_line:SetEndPoint("BOTTOMRIGHT", offset, 0)
end



addon_data.bar.set_bar_color = function()
    -- This function sets the bar colour for all cases outside of seal of command, which has
    -- a time sensitive component and must be handled on-update.

    -- if no seal return default color
    if addon_data.player.n_active_seals == 0 then
        addon_data.bar.frame.bar:SetVertexColor(unpack(character_bar_settings["bar_color_default"]))
        return
    end   
    -- if we're currently twisting return twist color
    if addon_data.player.n_active_seals == 2 then
        addon_data.bar.frame.bar:SetVertexColor(unpack(character_bar_settings["bar_color_twisting"]))
        return
    end

    -- if we're only under SoB, return the blood color
    if addon_data.player.active_seals["Seal of Blood"] ~= nil then
        addon_data.bar.frame.bar:SetVertexColor(unpack(character_bar_settings["bar_color_blood"]))
        return
    end

    -- if we get to the end return the default color
    addon_data.bar.frame.bar:SetVertexColor(unpack(character_bar_settings["bar_color_default"]))
end

-- draw the right text or not
addon_data.bar.draw_right_text = function()
    if addon_data.player.swing_timer == 0 then
        return false
    end
    return true
end

--=========================================================================================
-- End, if debug verify module was read.
--=========================================================================================
if addon_data.debug then print('-- Parsed bar.lua module correctly') end