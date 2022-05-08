
-- bar.lua =============================================================================
local addon_name, st = ...
local print = st.utils.print_msg

--=========================================================================================
-- BAR SETTINGS 
--=========================================================================================
st.bar = {}
st.bar.default_settings = {
	enabled = true,
    hide_when_inactive = true,
    lag_detection_enabled = true,
	width = 345,
	height = 32,
	fontsize = 16,
    point = "CENTER",
	rel_point = "CENTER",
	x_offset = 0,
	y_offset = -180,
	-- in_combat_alpha = 1.0,
	-- ooc_alpha = 1.0,
	backplane_alpha = 0.85,
	is_locked = false,
    show_left_text = true,
    show_right_text = true,
    -- show_border = false,
    -- classic_bars = true,
    -- fill_empty = true,
    main_r = 0.1, main_g = 0.1, main_b = 0.9, main_a = 1.0,
    main_text_r = 1.0, main_text_g = 1.0, main_text_b = 1.0, main_text_a = 1.0,
    bar_color_default = {0.5, 0.5, 0.5, 1.0},
    bar_color_twisting = {0.51, 0.04, 0.73, 1.0},
    bar_color_twist_ready = {0., 0.68, 0., 1.0},
    bar_color_blood = {0.7, 0.27, 0.0, 1.0},
    bar_color_warning = {1.0, 0.0, 0.0, 1.0}, -- when if you cast SoC, you can't twist out of it that swing
    bar_color_gcd = {0.3, 0.3, 0.3, 1.0},
    bar_color_cant_twist = {0.7, 0.7, 0.01, 1.0},
    twist_window = 0.4,
    grace_period = 0.12,
    enable_twist_bar_color = true,
    tick_width = 3,
    judgement_marker = false
}

-- the following should be flagged when the swing speed changes to
-- evaluate the new offsets for ticks
st.bar.recalculate_ticks = false
st.bar.twist_tick_offset = 0.1
st.bar.gcd1_tick_offset = 0.1
st.bar.gcd2_tick_offset = 0.1

st.bar.gcd_bar_width = 0.0

st.bar.LoadSettings = function()
    -- If the carried over settings dont exist then make them
    if not swedgetimer_bar_settings then
        swedgetimer_bar_settings = {}
    end
    -- swedgetimer_bar_settings = {} -- REMOVE ME THIS IS FOR TESTING
    -- If the carried over settings aren't set then set them to the defaults
    for setting, value in pairs(st.bar.default_settings) do
        if swedgetimer_bar_settings[setting] == nil then
            swedgetimer_bar_settings[setting] = value
        end
    end

end

--=========================================================================================
-- Drag and drop settings
--=========================================================================================
st.bar.OnFrameDragStart = function()
    if not swedgetimer_bar_settings.is_locked then
        st.bar.frame:StartMoving()
    end
end

st.bar.OnFrameDragStop = function()
    local frame = st.bar.frame
    local settings = swedgetimer_bar_settings
    frame:StopMovingOrSizing()
    local point, _, rel_point, x_offset, y_offset = frame:GetPoint()
    -- if x_offset < 5 and x_offset > -5 then
    --     x_offset = 0
    -- end
    settings.point = point
    settings.rel_point = rel_point
    settings.x_offset = st.utils.simple_round(x_offset, 0.1)
    settings.y_offset = st.utils.simple_round(y_offset, 0.1)
    st.bar.UpdateVisualsOnSettingsChange()
    st.bar.UpdateConfigPanelValues()
    st.bar.set_bar_color()
end

--=========================================================================================
-- Intialisation and setting change functionality
--=========================================================================================

-- this function is called once to initialise all the graphics of the bar
st.bar.init_bar_visuals = function()
    local settings = swedgetimer_bar_settings
    st.bar.frame = CreateFrame("Frame", addon_name .. "BarFrame", UIParent)   
    local frame = st.bar.frame

    -- Set initial frame properties
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(not settings.is_locked)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", st.bar.OnFrameDragStart)
    frame:SetScript("OnDragStop", st.bar.OnFrameDragStop)
    
    -- Create the backplane and border
    frame.backplane = CreateFrame("Frame", addon_name .. "BarBackdropFrame", frame, "BackdropTemplate")
    frame.backplane:SetPoint('TOPLEFT', -9, 9)
    frame.backplane:SetPoint('BOTTOMRIGHT', 9, -9)
    frame.backplane:SetFrameStrata('LOW')
    frame.backplane:SetBackdrop({
        bgFile = "Interface/AddOns/SwedgeTimer/Images/Background", 
        edgeFile = nil, 
        tile = true, tileSize = 16, edgeSize = 16, 
        insets = { left = 8, right = 8, top = 8, bottom = 8}}
    )
    frame.backplane:SetBackdropColor(0,0,0,settings.backplane_alpha)
    -- frame.backplane:SetDrawLayer("ARTWORK", -2)

    -- if settings.show_border then
    --     frame.backplane:SetBackdrop({
    --         bgFile = "Interface/AddOns/SwedgeTimer/Images/Background", 
    --         edgeFile = "Interface/AddOns/SwedgeTimer/Images/Border", 
    --         tile = true, tileSize = 16, edgeSize = 12, 
    --         insets = { left = 8, right = 8, top = 8, bottom = 8}})
    -- else
    --     frame.backplane:SetBackdrop({
    --         bgFile = "Interface/AddOns/SwedgeTimer/Images/Background", 
    --         edgeFile = nil, 
    --         tile = true, tileSize = 16, edgeSize = 16, 
    --         insets = { left = 8, right = 8, top = 8, bottom = 8}})
    -- end

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
    frame.bar:SetVertexColor(unpack(swedgetimer_bar_settings["bar_color_default"]))

    -- Create the GCD timer bar
    frame.gcd_bar = frame:CreateTexture(nil, "ARTWORK")
    frame.gcd_bar:SetPoint("TOPLEFT", 0, 0)
    frame.gcd_bar:SetHeight(settings.height)
    frame.gcd_bar:SetTexture('Interface/AddOns/SwedgeTimer/Images/Bar')
    frame.gcd_bar:SetVertexColor(unpack(swedgetimer_bar_settings["bar_color_gcd"]))
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
    frame.twist_line:SetThickness(swedgetimer_bar_settings.tick_width)
    frame.twist_line:SetStartPoint("TOPRIGHT", 0, 0) -- dummy vars so the line is initialised
    frame.twist_line:SetEndPoint("BOTTOMRIGHT", 0, 0)

    frame.gcd1_line = frame:CreateLine() -- the first gcd possible before a twist
    frame.gcd1_line:SetColorTexture(0.4,0.4,1,1)
    frame.gcd1_line:SetDrawLayer("OVERLAY", -1)
    frame.gcd1_line:SetThickness(swedgetimer_bar_settings.tick_width)
    
    frame.gcd2_line = frame:CreateLine()
    frame.gcd2_line:SetColorTexture(0.4,0.4,1,1)
    frame.gcd2_line:SetDrawLayer("OVERLAY", -1)
    frame.gcd2_line:SetThickness(swedgetimer_bar_settings.tick_width)
    
    frame.judgement_line = frame:CreateLine()
    frame.judgement_line:SetColorTexture(1.0,1.0,0.1,1)
    frame.judgement_line:SetDrawLayer("OVERLAY", -1)
    frame.judgement_line:SetThickness(swedgetimer_bar_settings.tick_width+2)

    -- Run an update to configure the bar appropriately
    -- st.bar.UpdateVisualsOnSettingsChange()
    -- st.bar.update_visuals_on_update()

    -- print('Successfully initialised all bar visuals.')
	frame:Show()
end

-- this function is called when a setting related to bar visuals is changed
st.bar.UpdateVisualsOnSettingsChange = function()
    local frame = st.bar.frame
    local settings = swedgetimer_bar_settings
    -- print("enabled says: " .. tostring(settings.enabled))
    -- print("show_border says : " .. tostring(settings.show_border))

    if settings.enabled then
        frame:Show()
        frame:ClearAllPoints()
        frame:SetPoint(settings.point, UIParent, settings.rel_point, settings.x_offset, settings.y_offset)
        frame:SetWidth(settings.width)
        frame:SetHeight(settings.height)

        frame.backplane:SetBackdropColor(0,0,0,settings.backplane_alpha)
        frame.bar:SetPoint("TOPLEFT", 0, 0)
        frame.bar:SetHeight(settings.height)
        frame.bar:SetWidth(settings.width)

        frame.gcd_bar:SetPoint("TOPLEFT", 0, 0)
        frame.gcd_bar:SetHeight(settings.height)
        frame.gcd_bar:SetWidth(settings.width)

        frame.bar:SetTexture('Interface/AddOns/SwedgeTimer/Images/Bar')
        frame.bar:SetVertexColor(unpack(swedgetimer_bar_settings["bar_color_default"]))

        frame.twist_line:SetThickness(swedgetimer_bar_settings.tick_width)
        frame.gcd1_line:SetThickness(swedgetimer_bar_settings.tick_width)
        frame.gcd2_line:SetThickness(swedgetimer_bar_settings.tick_width)
        frame.judgement_line:SetThickness(swedgetimer_bar_settings.tick_width+1)


        frame.left_text:SetPoint("TOPLEFT", 2, -(settings.height / 2) + (settings.fontsize / 2))
        frame.left_text:SetTextColor(settings.main_text_r, settings.main_text_g, settings.main_text_b, settings.main_text_a)
		frame.left_text:SetFont("Fonts/FRIZQT__.ttf", settings.fontsize, "OUTLINE")
	
        frame.right_text:SetPoint("TOPRIGHT", -5, -(settings.height / 2) + (settings.fontsize / 2))
        frame.right_text:SetTextColor(settings.main_text_r, settings.main_text_g, settings.main_text_b, settings.main_text_a)
		frame.right_text:SetFont("Fonts/FRIZQT__.ttf", settings.fontsize, "OUTLINE")

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

        st.bar.set_bar_color()

    else
        frame:Hide()
    end
end

--=========================================================================================
-- OnUpdate widget handlers and functions
--=========================================================================================

st.bar.update_visuals_on_update = function()
    -- This function will be called once every frame after the event-based code has run,
    -- but before the frame is drawn.
    -- Func is called by the player frame OnUpdate (maybe we should change this).
    -- As such it should be kept as minimal as possible to avoid wasting resources.


    st.bar.show_or_hide_bar()
    if not st.bar.should_show_bar() then return end 

    local settings = swedgetimer_bar_settings
    local frame = st.bar.frame
    local speed = st.player.current_weapon_speed
    local timer = st.player.swing_timer

    -- Update the main bar's width
    local timer_width = math.min(settings.width - (settings.width * (timer / speed)), settings.width)
    
    frame.bar:SetWidth(timer_width)
    -- frame.spark:SetPoint('TOPLEFT', timer_width - 8, 0)
    
    frame.gcd_bar:Show()

    -- Update the main bars text, hide right text if bar full
    frame.left_text:SetText(tostring(st.utils.simple_round(speed, 0.1)))
    frame.right_text:SetText(tostring(st.utils.simple_round(timer, 0.1)))
    if st.bar.draw_right_text() then
        frame.right_text:Show()
    else
        frame.right_text:Hide()
    end

    -- If SoC, bar colour is time sensitive. Deal with that here.
    if st.player.is_twist_seal_active() then
        if st.player.n_active_seals == 1 then
            if st.player.twist_impossible then
                st.bar.frame.bar:SetVertexColor(unpack(swedgetimer_bar_settings["bar_color_cant_twist"]))
            elseif st.player.swing_timer < swedgetimer_bar_settings["twist_window"] then 
                st.bar.frame.bar:SetVertexColor(unpack(swedgetimer_bar_settings["bar_color_twist_ready"]))
            else
                local min_time = st.player.spell_gcd_duration + swedgetimer_bar_settings["grace_period"]
                if st.player.swing_timer > min_time then            
                    st.bar.frame.bar:SetVertexColor(unpack(swedgetimer_bar_settings["bar_color_twist_ready"]))
                else
                    st.bar.frame.bar:SetVertexColor(unpack(swedgetimer_bar_settings["bar_color_warning"]))
                end
            end        
        end
    end
end

--=========================================================================================
-- Funcs to trigger updates to the bar's conditions on certain events.
--=========================================================================================
st.bar.update_bar_on_combat = function()
    -- Function called to update bar when entering/leaving combat.
    st.bar.show_or_hide_bar()
end

st.bar.update_bar_on_timer_full = function()
    -- Function called when the bar fills up to change any bar visuals
    st.bar.set_gcd_bar_width()
    st.bar.frame.twist_line:Hide()
    st.bar.frame.gcd1_line:Hide()
    st.bar.frame.gcd2_line:Hide()
end


st.bar.update_bar_on_swing_reset = function()
    -- Function called when the swing timer resets to change any bar visuals
    st.bar.show_or_hide_ticks()
    -- Recalculate the gcd bar width
    st.bar.set_gcd_bar_width()
    -- calc any judgements
    st.bar.calc_judgement()
end

st.bar.update_bar_on_new_gcd = function()
    st.bar.set_gcd_bar_width()
end

st.bar.update_bar_on_speed_change = function()
    -- A function to be run once upon the player's speed updating.
    -- This will recalculate all necessary frame element updates here
    -- to keep them out the main onupdate function
    -- print('Recalculating bar visuals on speed change...')
    st.bar.set_tick_offsets()
    st.bar.set_gcd_bar_width()
    st.bar.show_or_hide_ticks()
end

st.bar.set_tick_offsets = function()
    st.bar.set_twist_tick_offset()
    st.bar.set_gcd1_tick_offset()
    st.bar.set_gcd2_tick_offset()   
end

st.bar.update_bar_on_aura_change = function()
    -- A function to be run once upon the player's auras changing.
    -- Aura changes determine if the twist line should be drawn or not.
    st.bar.set_bar_color()

    -- if the spell haste changes we need to update the tick offsets
    st.bar.set_tick_offsets()

    -- determine if we should now show or hide the ticks
    st.bar.show_or_hide_ticks()

    -- determine if the bar should be auto hidden
    st.bar.show_or_hide_bar()

    -- check for judgements if necessary
    st.bar.calc_judgement()
end

st.bar.update_bar_on_parry = function()
    -- called whenever the player parries an attack
    st.bar.set_gcd_bar_width()  
    st.bar.calc_judgement()
end


--=========================================================================================
-- Funcs to recalculate/show/hide etc bar elements
--=========================================================================================
st.bar.has_judgement_seal = function()
    -- returns true if the player has a seal they typically want to judge
    if st.player.active_seals['blood'] ~= nil then
        return true
    elseif st.player.active_seals['righteousness'] then
        return true
    elseif st.player.active_seals['vengeance'] then
        return true
    elseif st.player.active_seals['justice'] then
        return true
    end
    return false
end

st.bar.calc_judgement = function()
    -- Function to check if we need to draw the judgement line
    -- and then to calulate its position. Called when the speed or timer changes.
    if not st.player.judgement_being_tracked or not swedgetimer_bar_settings.judgement_marker then
        return
    end

    local line = st.bar.frame.judgement_line
    local remaining = st.player.judgement_cd_remaining
    local timer = st.player.swing_timer
    local elapsed = st.player.current_weapon_speed - timer
    -- local time_remaining_on_swing = st.player.current_weapon_speed - st.player.swing_timer
    -- print(time_remaining_on_swing)
    -- print('judgement time remaining  = ' .. tostring(remaining))
    -- print('swing timer remaining     = ' .. tostring(timer))
    
    if remaining < timer then
        -- print('judgement off cd this swing')
        if st.bar.has_judgement_seal() then
            local offset = ((remaining + elapsed) / st.player.current_weapon_speed) * swedgetimer_bar_settings.width
            -- print(offset)
            line:SetStartPoint("TOPLEFT", offset, 5)
            line:SetEndPoint("BOTTOMLEFT", offset, -5)
            line:Show()
        else
            line:Hide()
        end
    else
        line:Hide()
    end

end

st.bar.show_or_hide_bar = function()
    -- Function called to show or hide the bar
    local frame = st.bar.frame
    if st.bar.should_show_bar() then
        frame:Show()
    else
        frame:Hide()
    end
end

st.bar.should_show_bar = function()
    -- Logic for if the bar should be visible
    if swedgetimer_bar_settings.enabled then
        if swedgetimer_bar_settings.hide_when_inactive then
            if st.player.n_active_seals == 0 and not st.core.in_combat then
                return false
            end
        end
        return true
    end
    return false
end

st.bar.hide_gcd_bar = function()
    -- function to "hide" the gcd bar by reducing the width to zero
    -- instead of using the dedicated Hide method
    st.bar.gcd_bar_width = 0
    st.bar.frame.gcd_bar:SetWidth(0)
end

st.bar.set_gcd_bar_width = function()

    if not st.player.gcd_lockout then
        st.bar.hide_gcd_bar()
    end

    local settings = swedgetimer_bar_settings
    local attack_speed = st.player.current_weapon_speed
    -- local swing_timer = st.player.swing_timer
    -- print(attack_speed)
    -- print(swing_timer)
    -- print(st.player.active_gcd_remaining)
    local time_since_bar_start = st.player.current_weapon_speed - st.player.swing_timer


    local time_gcd_ends = time_since_bar_start + st.player.active_gcd_remaining
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
    st.bar.gcd_bar_width = gcd_bar_width
    st.bar.frame.gcd_bar:SetWidth(gcd_bar_width)
end

-- Func to figure out if the ticks should be
st.bar.show_or_hide_ticks = function()
    local frame = st.bar.frame

    -- always hide ticks at full swing timer
    if st.player.swing_timer == 0 then
        st.bar.frame.twist_line:Hide()
        st.bar.frame.gcd1_line:Hide()
        st.bar.frame.gcd2_line:Hide()
        return
    end

    -- Twist line
    if st.bar.should_draw_twist_window() then
        frame.twist_line:Show()
    else
        frame.twist_line:Hide()
    end
    -- First GCD line
    if st.bar.should_draw_gcd1_window() then
        frame.gcd1_line:Show()
    else
        frame.gcd1_line:Hide()
    end
    -- Second GCD line
    if st.bar.should_draw_gcd2_window() then
        frame.gcd2_line:Show()
    else
        frame.gcd2_line:Hide()
    end
end

-- Determine wether or not to draw the twist line
-- Hide if we are not in SoC or the swing bar is full
st.bar.should_draw_twist_window = function()
    if st.player.is_twist_seal_active() then
        return true
    end
    return false
end

-- determine wether or not to draw the gcd1 line
st.bar.should_draw_gcd1_window = function()
    local settings = swedgetimer_bar_settings
    if math.abs(st.bar.gcd1_tick_offset) > settings.width then
        return false
    end
    return true
end

-- determine wether or not to draw the gcd2 line
st.bar.should_draw_gcd2_window = function()
    local settings = swedgetimer_bar_settings
    if math.abs(st.bar.gcd2_tick_offset) > settings.width then
        return false
    end
    return true
end

st.bar.set_twist_tick_offset = function()
-- Set the offset position of the twist window
    local settings = swedgetimer_bar_settings
    local bar_fraction = (settings.twist_window / st.player.current_weapon_speed)
    local offset = bar_fraction * settings.width * -1
    -- print('twist tick time = ' .. time_value)
    st.bar.twist_tick_offset = offset
    st.bar.frame.twist_line:SetStartPoint("TOPRIGHT", offset, 0)
    st.bar.frame.twist_line:SetEndPoint("BOTTOMRIGHT", offset, 0)
end

-- Get the offset position of the first gcd window tick
st.bar.set_gcd1_tick_offset = function()
    local settings = swedgetimer_bar_settings
    local gcd_duration = st.player.spell_gcd_duration
    local grace_period = swedgetimer_bar_settings["grace_period"]
    local time_before_swing = gcd_duration + grace_period
    -- print('GCD1 tick time = ' .. time_before_swing)
    local offset = (time_before_swing / st.player.current_weapon_speed) * settings.width * -1
    st.bar.gcd1_tick_offset = offset
    st.bar.frame.gcd1_line:SetStartPoint("TOPRIGHT", offset, 0)
    st.bar.frame.gcd1_line:SetEndPoint("BOTTOMRIGHT", offset, 0)
end

-- Get the offset position of the second gcd window tick
st.bar.set_gcd2_tick_offset = function()
    local settings = swedgetimer_bar_settings
    local gcd_duration = st.player.spell_gcd_duration
    local grace_period = swedgetimer_bar_settings["grace_period"]
    local time_before_swing = (2 * gcd_duration) + grace_period
    -- print('GCD2 tick time = ' .. time_before_swing)
    local offset = (time_before_swing / st.player.current_weapon_speed) * settings.width * -1
    st.bar.gcd2_tick_offset = offset
    st.bar.frame.gcd2_line:SetStartPoint("TOPRIGHT", offset, 0)
    st.bar.frame.gcd2_line:SetEndPoint("BOTTOMRIGHT", offset, 0)
end

-- function to determine if any seal we are happy to run with is up
-- i.e blood justice or vengeance
st.bar.is_running_seal_active = function()
    if st.player.active_seals["blood"] ~= nil then
        return true
    elseif st.player.active_seals["justice"] ~= nil then
        return true
    elseif st.player.active_seals["vengeance"] ~= nil then
        return true
    end
    return false
end


-- This function sets the bar colour for all cases outside of command, which has
-- a time sensitive component and must be handled on-update.
st.bar.set_bar_color = function()
    -- if no seal return default color
    if st.player.n_active_seals == 0 then
        st.bar.frame.bar:SetVertexColor(unpack(swedgetimer_bar_settings["bar_color_default"]))
        return
    end   
    -- if we're currently twisting return twist color
    if st.player.n_active_seals == 2 and swedgetimer_bar_settings.enable_twist_bar_color then
        st.bar.frame.bar:SetVertexColor(unpack(swedgetimer_bar_settings["bar_color_twisting"]))
        return
    end
    -- if we're only under SoB, return the blood color
    if st.bar.is_running_seal_active() then
        st.bar.frame.bar:SetVertexColor(unpack(swedgetimer_bar_settings["bar_color_blood"]))
        return
    end
    -- if we get to the end return the default color
    st.bar.frame.bar:SetVertexColor(unpack(swedgetimer_bar_settings["bar_color_default"]))
end

-- draw the right text or not
st.bar.draw_right_text = function()
    if not swedgetimer_bar_settings.show_right_text then
        return false
    end
    if st.player.swing_timer == 0 then
        return false
    end
    return true
end

--=========================================================================================
-- End, if debug verify module was read.
--=========================================================================================
if st.debug then print('-- Parsed bar.lua module correctly') end