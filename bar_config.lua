-- bar_config.lua =============================================================================
local addon_name, addon_data = ...
local print = addon_data.utils.print_msg


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
if addon_data.debug then print('-- Parsed bar_config.lua module correctly') end