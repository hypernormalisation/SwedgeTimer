-- bar.lua =============================================================================
local addon_name, addon_data = ...
local print = addon_data.utils.print_msg

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

addon_data.bar.LoadSettings = function()
    -- If the carried over settings dont exist then make them
    if not character_bar_settings then
        character_bar_settings = {}
    end
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

    -- Create the main hand bar
    frame.bar = frame:CreateTexture(nil,"ARTWORK")
    frame:SetHeight(settings.height)
    -- Create the main spark
    frame.spark = frame:CreateTexture(nil,"OVERLAY")
    frame.spark:SetTexture('Interface/AddOns/Hurricane/Images/Spark')

    -- Create the main hand bar left text
    frame.left_text = frame:CreateFontString(nil, "OVERLAY")
    frame.left_text:SetFont("Fonts/FRIZQT__.ttf", settings.fontsize)
    frame.left_text:SetJustifyV("CENTER")
    frame.left_text:SetJustifyH("LEFT")
    -- Create the main hand bar right text
    frame.right_text = frame:CreateFontString(nil, "OVERLAY")
    frame.right_text:SetFont("Fonts/FRIZQT__.ttf", settings.fontsize)
    frame.right_text:SetJustifyV("CENTER")
    frame.right_text:SetJustifyH("RIGHT")

    -- Create the line markers
    frame.twist_line = frame:CreateLine()
    frame.gcd1_marker = frame:CreateLine()
    frame.gcd2_marker = frame:CreateLine()

    -- Run an update to configure the bar appropriately
    addon_data.bar.UpdateVisualsOnSettingsChange()
    addon_data.bar.UpdateVisualsOnUpdate()

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
                bgFile = "Interface/AddOns/Hurricane/Images/Background", 
                edgeFile = "Interface/AddOns/Hurricane/Images/Border", 
                tile = true, tileSize = 16, edgeSize = 12, 
                insets = { left = 8, right = 8, top = 8, bottom = 8}})
        else
            frame.backplane:SetBackdrop({
                bgFile = "Interface/AddOns/Hurricane/Images/Background", 
                edgeFile = nil, 
                tile = true, tileSize = 16, edgeSize = 16, 
                insets = { left = 8, right = 8, top = 8, bottom = 8}})
        end
        frame.backplane:SetBackdropColor(0,0,0,settings.backplane_alpha)

        frame.bar:SetPoint("TOPLEFT", 0, 0)
        frame.bar:SetHeight(settings.height)



        frame.bar:SetTexture('Interface/AddOns/Hurricane/Images/Bar')
        frame.bar:SetVertexColor(settings.main_r, settings.main_g, settings.main_b, settings.main_a)
        frame.spark:SetSize(16, settings.height)
        frame.left_text:SetPoint("TOPLEFT", 2, -(settings.height / 2) + (settings.fontsize / 2))
        frame.left_text:SetTextColor(settings.main_text_r, settings.main_text_g, settings.main_text_b, settings.main_text_a)
		frame.left_text:SetFont("Fonts/FRIZQT__.ttf", settings.fontsize)
	
        frame.right_text:SetPoint("TOPRIGHT", -5, -(settings.height / 2) + (settings.fontsize / 2))
        frame.right_text:SetTextColor(settings.main_text_r, settings.main_text_g, settings.main_text_b, settings.main_text_a)
		frame.right_text:SetFont("Fonts/FRIZQT__.ttf", settings.fontsize)

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

--=========================================================================================
-- OnUpdate widget handlers and functions
--=========================================================================================

-- This function will be called once every frame after the event-based code has run,
-- but before the frame is drawn.
-- As such it should be kept as minimal as possible to avoid wasting resources.
addon_data.bar.UpdateVisualsOnUpdate = function()
    local settings = character_player_settings
    local frame = addon_data.bar.frame

    if not settings.enabled then return end 

    local speed = addon_data.player.current_weapon_speed
    local timer = addon_data.player.swing_timer

    if speed == 0 then
        speed = 2
        print('WARNING: prevented zero division error')
    end

    -- Change bar colours depending on conditions.
    if addon_data.player.n_active_seals == 2 then
        addon_data.bar.frame.bar:SetVertexColor(0.6, 0.6, 0.9, 1.0)
    else
        addon_data.bar.frame.bar:SetVertexColor(
        settings.main_r, settings.main_g, settings.main_b, settings.main_a)
    end

    -- Update the main bars width
    width = math.min(settings.width - (settings.width * (timer / speed)), settings.width)
    if not settings.fill_empty then
        width = settings.width - width + 0.001
    end
    
    frame.bar:SetWidth(width)
    frame.spark:SetPoint('TOPLEFT', width - 8, 0)
    
    if width == settings.width or not settings.classic_bars or width == 0.001 then
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

        -- Update the alpha
    if addon_data.core.in_combat then
        frame:SetAlpha(settings.in_combat_alpha)
    else
        frame:SetAlpha(settings.ooc_alpha)
    end

    -- set the tick line for the twist window
    local l = frame.twist_line
    l:SetColorTexture(1,0,0,1)
    local offset = addon_data.bar.GetTwistWindowOffset() * -1
    l:SetStartPoint("TOPRIGHT",offset,0)
    l:SetEndPoint("BOTTOMRIGHT",offset,0)

    if addon_data.bar.draw_twist_window() then
        l:Show()
    else
        l:Hide()
    end
end

-- Determine wether or not to draw the GCD line.
-- Hide if we are not in SoC or the swing bar is full
addon_data.bar.draw_twist_window = function()
    if addon_data.player.swing_timer == 0 then
        return false
    end
    -- print(addon_data.player.active_seals["Seal of Command"] == nil)
    if addon_data.player.active_seals["Seal of Command"] ~= nil then
        return true
    end
    -- print('got here, returning false')
    return false
end

addon_data.bar.draw_right_text = function()
    if addon_data.player.swing_timer == 0 then
        return false
    end
    return true
end


-- a function to return the present bar color
-- is called every update, be efficient!
addon_data.bar.return_bar_color = function()
end

-- =============================================================================
-- Functions to calculate positioning of bar elements
addon_data.bar.GetTwistWindowOffset = function()
    local settings = character_player_settings
    return (0.4 / addon_data.player.current_weapon_speed) * settings.width
end


-- addon_data.bar.GetGCD1Offset = function()
--     local settings = character_player_settings
--     local _, duration = GetSpellCooldown(29515)
--     -- print(duration)
--     return ( (0.4 + duration) / addon_data.player.current_weapon_speed ) * settings.width
-- end

--[[============================================================================================]]--
--[[================================== CONFIG WINDOW RELATED ===================================]]--
--[[============================================================================================]]--

addon_data.bar.UpdateConfigPanelValues = function()
    local panel = addon_data.bar.config_frame
    local settings = character_player_settings
    panel.enabled_checkbox:SetChecked(settings.enabled)
    panel.show_border_checkbox:SetChecked(settings.show_border)
    panel.classic_bars_checkbox:SetChecked(settings.classic_bars)
    panel.fill_empty_checkbox:SetChecked(settings.fill_empty)
    panel.show_left_text_checkbox:SetChecked(settings.show_left_text)
    panel.show_right_text_checkbox:SetChecked(settings.show_right_text)
    panel.width_editbox:SetText(tostring(settings.width))
    panel.width_editbox:SetCursorPosition(0)
    panel.height_editbox:SetText(tostring(settings.height))
    panel.height_editbox:SetCursorPosition(0)
	panel.fontsize_editbox:SetText(tostring(settings.fontsize))
    panel.fontsize_editbox:SetCursorPosition(0)
    panel.x_offset_editbox:SetText(tostring(settings.x_offset))
    panel.x_offset_editbox:SetCursorPosition(0)
    panel.y_offset_editbox:SetText(tostring(settings.y_offset))
    panel.y_offset_editbox:SetCursorPosition(0)
    panel.main_color_picker.foreground:SetColorTexture(
        settings.main_r, settings.main_g, settings.main_b, settings.main_a)
    panel.main_text_color_picker.foreground:SetColorTexture(
        settings.main_text_r, settings.main_text_g, settings.main_text_b, settings.main_text_a)
    panel.in_combat_alpha_slider:SetValue(settings.in_combat_alpha)
    panel.in_combat_alpha_slider.editbox:SetCursorPosition(0)
    panel.ooc_alpha_slider:SetValue(settings.ooc_alpha)
    panel.ooc_alpha_slider.editbox:SetCursorPosition(0)
    panel.backplane_alpha_slider:SetValue(settings.backplane_alpha)
    panel.backplane_alpha_slider.editbox:SetCursorPosition(0)
end

addon_data.bar.EnabledCheckBoxOnClick = function(self)
    character_player_settings.enabled = self:GetChecked()
    addon_data.bar.UpdateVisualsOnSettingsChange()
end

addon_data.bar.TwistBarToggle = function()
    currently_on = character_player_settings.enabled == true
    if not currently_on then
        character_player_settings.enabled = true
    else
        character_player_settings.enabled = false
    end
    addon_data.bar.UpdateVisualsOnSettingsChange()
end

addon_data.bar.IsLockedCheckBoxOnClick = function(self)
    character_player_settings.is_locked = self:GetChecked()
    addon_data.bar.frame:EnableMouse(not character_player_settings.is_locked)
    addon_data.bar.UpdateVisualsOnSettingsChange()
end

addon_data.bar.ShowOffHandCheckBoxOnClick = function(self)
    character_player_settings.show_offhand = self:GetChecked()
    addon_data.bar.UpdateVisualsOnSettingsChange()
end

addon_data.bar.ShowBorderCheckBoxOnClick = function(self)
    character_player_settings.show_border = self:GetChecked()
    addon_data.bar.UpdateVisualsOnSettingsChange()
end

addon_data.bar.ClassicBarsCheckBoxOnClick = function(self)
    character_player_settings.classic_bars = self:GetChecked()
    addon_data.bar.UpdateVisualsOnSettingsChange()
end

addon_data.bar.FillEmptyCheckBoxOnClick = function(self)
    character_player_settings.fill_empty = self:GetChecked()
    addon_data.bar.UpdateVisualsOnSettingsChange()
end

addon_data.bar.ShowLeftTextCheckBoxOnClick = function(self)
    character_player_settings.show_left_text = self:GetChecked()
    addon_data.bar.UpdateVisualsOnSettingsChange()
end

addon_data.bar.ShowRightTextCheckBoxOnClick = function(self)
    character_player_settings.show_right_text = self:GetChecked()
    addon_data.bar.UpdateVisualsOnSettingsChange()
end

addon_data.bar.WidthEditBoxOnEnter = function(self)
    character_player_settings.width = tonumber(self:GetText())
    addon_data.bar.UpdateVisualsOnSettingsChange()
end

addon_data.bar.HeightEditBoxOnEnter = function(self)
    character_player_settings.height = tonumber(self:GetText())
    addon_data.bar.UpdateVisualsOnSettingsChange()
end

addon_data.bar.FontSizeEditBoxOnEnter = function(self)
    character_player_settings.fontsize = tonumber(self:GetText())
    addon_data.bar.UpdateVisualsOnSettingsChange()
end

addon_data.bar.XOffsetEditBoxOnEnter = function(self)
    character_player_settings.x_offset = tonumber(self:GetText())
    addon_data.bar.UpdateVisualsOnSettingsChange()
end

addon_data.bar.YOffsetEditBoxOnEnter = function(self)
    character_player_settings.y_offset = tonumber(self:GetText())
    addon_data.bar.UpdateVisualsOnSettingsChange()
end

addon_data.bar.MainColorPickerOnClick = function()
    local settings = character_player_settings
    local function MainOnActionFunc(restore)
        local settings = character_player_settings
        local new_r, new_g, new_b, new_a
        if restore then
            new_r, new_g, new_b, new_a = unpack(restore)
        else
            new_a, new_r, new_g, new_b = 1 - OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB()
        end
        settings.main_r, settings.main_g, settings.main_b, settings.main_a = new_r, new_g, new_b, new_a
        addon_data.bar.frame.bar:SetVertexColor(
            settings.main_r, settings.main_g, settings.main_b, settings.main_a)
        addon_data.bar.config_frame.main_color_picker.foreground:SetColorTexture(
            settings.main_r, settings.main_g, settings.main_b, settings.main_a)
    end
    ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = 
        MainOnActionFunc, MainOnActionFunc, MainOnActionFunc
    ColorPickerFrame.hasOpacity = true 
    ColorPickerFrame.opacity = 1 - settings.main_a
    ColorPickerFrame:SetColorRGB(settings.main_r, settings.main_g, settings.main_b)
    ColorPickerFrame.previousValues = {settings.main_r, settings.main_g, settings.main_b, settings.main_a}
    ColorPickerFrame:Show()
end

addon_data.bar.MainTextColorPickerOnClick = function()
    local settings = character_player_settings
    local function MainTextOnActionFunc(restore)
        local settings = character_player_settings
        local new_r, new_g, new_b, new_a
        if restore then
            new_r, new_g, new_b, new_a = unpack(restore)
        else
            new_a, new_r, new_g, new_b = 1 - OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB()
        end
        settings.main_text_r, settings.main_text_g, settings.main_text_b, settings.main_text_a = new_r, new_g, new_b, new_a
        addon_data.bar.frame.left_text:SetTextColor(
            settings.main_text_r, settings.main_text_g, settings.main_text_b, settings.main_text_a)
        addon_data.bar.frame.right_text:SetTextColor(
            settings.main_text_r, settings.main_text_g, settings.main_text_b, settings.main_text_a)
        addon_data.bar.config_frame.main_text_color_picker.foreground:SetColorTexture(
            settings.main_text_r, settings.main_text_g, settings.main_text_b, settings.main_text_a)
    end
    ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = 
        MainTextOnActionFunc, MainTextOnActionFunc, MainTextOnActionFunc
    ColorPickerFrame.hasOpacity = true 
    ColorPickerFrame.opacity = 1 - settings.main_text_a
    ColorPickerFrame:SetColorRGB(settings.main_text_r, settings.main_text_g, settings.main_text_b)
    ColorPickerFrame.previousValues = {settings.main_text_r, settings.main_text_g, settings.main_text_b, settings.main_text_a}
    ColorPickerFrame:Show()
end


addon_data.bar.CombatAlphaOnValChange = function(self)
    character_player_settings.in_combat_alpha = tonumber(self:GetValue())
    addon_data.bar.UpdateVisualsOnSettingsChange()
end

addon_data.bar.OOCAlphaOnValChange = function(self)
    character_player_settings.ooc_alpha = tonumber(self:GetValue())
    addon_data.bar.UpdateVisualsOnSettingsChange()
end

addon_data.bar.BackplaneAlphaOnValChange = function(self)
    character_player_settings.backplane_alpha = tonumber(self:GetValue())
    addon_data.bar.UpdateVisualsOnSettingsChange()
end

--=========================================================================================
-- End, if debug verify module was read.
--=========================================================================================
if addon_data.debug then print('-- Parsed bar.lua module correctly') end