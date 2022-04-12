local addon_name, addon_data = ...
local L = addon_data.localization_table

local print = addon_data.utils.print_msg


addon_data.config = {}

addon_data.config.OnDefault = function()
    addon_data.core.RestoreAllDefaults()
    addon_data.config.UpdateConfigValues()
end

addon_data.config.InitializeVisuals = function()

    -- Add the parent panel
    addon_data.config.config_parent_panel = CreateFrame("Frame", "MyFrame", UIParent)
    local panel = addon_data.config.config_parent_panel
    panel:SetSize(1, 1)
    panel.global_panel = addon_data.config.CreateConfigPanel(panel)
    panel.global_panel:SetPoint('TOPLEFT', 10, -10)
    panel.global_panel:SetSize(1, 1)

    panel.name = "Hurricane"
    panel.default = addon_data.config.OnDefault
    InterfaceOptions_AddCategory(panel)
    
    -- Add the melee panel
    panel.config_melee_panel = CreateFrame("Frame", nil, panel)
    panel.config_melee_panel:SetSize(1, 1)
    panel.config_melee_panel.player_panel = addon_data.bar.CreateConfigPanel(panel.global_panel)
    panel.config_melee_panel.player_panel:SetPoint('TOPLEFT', 0, -120)
    panel.config_melee_panel.player_panel:SetSize(1, 1)
    panel.config_melee_panel.name = "Twist Bar Settings"
    panel.config_melee_panel.parent = panel.name
    panel.config_melee_panel.default = addon_data.config.OnDefault
end

addon_data.config.TextFactory = function(parent, text, size)
    local text_obj = parent:CreateFontString(nil, "ARTWORK")
    text_obj:SetFont("Fonts/FRIZQT__.ttf", size)
    text_obj:SetJustifyV("CENTER")
    text_obj:SetJustifyH("CENTER")
    text_obj:SetText(text)
    return text_obj
end

addon_data.config.CheckBoxFactory = function(g_name, parent, checkbtn_text, tooltip_text, on_click_func)
    local checkbox = CreateFrame("CheckButton", addon_name .. g_name, parent, "ChatConfigCheckButtonTemplate")
    getglobal(checkbox:GetName() .. 'Text'):SetText(checkbtn_text)
    checkbox.tooltip = tooltip_text
    checkbox:SetScript("OnClick", function(self)
        on_click_func(self)
    end)
    checkbox:SetScale(1.1)
    return checkbox
end

addon_data.config.EditBoxFactory = function(g_name, parent, title, w, h, enter_func)
    local edit_box_obj = CreateFrame("EditBox", addon_name .. g_name, parent, "BackdropTemplate")
    edit_box_obj.title_text = addon_data.config.TextFactory(edit_box_obj, title, 12)
    edit_box_obj.title_text:SetPoint("TOP", 0, 12)
    edit_box_obj:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 26,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4}
    })
    edit_box_obj:SetBackdropColor(0,0,0,1)
    edit_box_obj:SetSize(w, h)
    edit_box_obj:SetMultiLine(false)
    edit_box_obj:SetAutoFocus(false)
    edit_box_obj:SetMaxLetters(4)
    edit_box_obj:SetJustifyH("CENTER")
	edit_box_obj:SetJustifyV("CENTER")
    edit_box_obj:SetFontObject(GameFontNormal)
    edit_box_obj:SetScript("OnEnterPressed", function(self)
        enter_func(self)
        self:ClearFocus()
    end)
    edit_box_obj:SetScript("OnTextChanged", function(self)
        if self:GetText() ~= "" then
            enter_func(self)
        end
    end)
    edit_box_obj:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    return edit_box_obj
end

addon_data.config.SliderFactory = function(g_name, parent, title, min_val, max_val, val_step, func)
    local slider = CreateFrame("Slider", addon_name .. g_name, parent, "OptionsSliderTemplate")
    local editbox = CreateFrame("EditBox", "$parentEditBox", slider, "InputBoxTemplate")
    slider:SetMinMaxValues(min_val, max_val)
    slider:SetValueStep(val_step)
    slider.text = _G[addon_name .. g_name .. "Text"]
    slider.text:SetText(title)
    slider.textLow = _G[addon_name .. g_name .. "Low"]
    slider.textHigh = _G[addon_name .. g_name .. "High"]
    slider.textLow:SetText(floor(min_val))
    slider.textHigh:SetText(floor(max_val))
    slider.textLow:SetTextColor(0.8,0.8,0.8)
    slider.textHigh:SetTextColor(0.8,0.8,0.8)
    slider:SetObeyStepOnDrag(true)
    editbox:SetSize(45,30)
    editbox:ClearAllPoints()
    editbox:SetPoint("LEFT", slider, "RIGHT", 15, 0)
    editbox:SetText(slider:GetValue())
    editbox:SetAutoFocus(false)
    slider:SetScript("OnValueChanged", function(self)
        editbox:SetText(tostring(addon_data.utils.SimpleRound(self:GetValue(), val_step)))
        func(self)
    end)
    editbox:SetScript("OnTextChanged", function(self)
        local val = self:GetText()
        if tonumber(val) then
            self:GetParent():SetValue(val)
        end
    end)
    editbox:SetScript("OnEnterPressed", function(self)
        local val = self:GetText()
        if tonumber(val) then
            self:GetParent():SetValue(val)
            self:ClearFocus()
        end
    end)
    slider.editbox = editbox
    return slider
end

addon_data.config.color_picker_factory = function(g_name, parent, r, g, b, a, text, on_click_func)
    local color_picker = CreateFrame('Button', addon_name .. g_name, parent)
    color_picker:SetSize(15, 15)
    color_picker.normal = color_picker:CreateTexture(nil, 'BACKGROUND')
    color_picker.normal:SetColorTexture(1, 1, 1, 1)
    color_picker.normal:SetPoint('TOPLEFT', -1, 1)
    color_picker.normal:SetPoint('BOTTOMRIGHT', 1, -1)
    color_picker.foreground = color_picker:CreateTexture(nil, 'ARTWORK')
    color_picker.foreground:SetColorTexture(r, g, b, a)
    color_picker.foreground:SetAllPoints()
    color_picker:SetNormalTexture(color_picker.foreground)
    color_picker:SetScript('OnClick', on_click_func)
    color_picker.text = addon_data.config.TextFactory(color_picker, text, 12)
    color_picker.text:SetPoint('LEFT', 25, 0)
    return color_picker
end

addon_data.config.UpdateConfigValues = function()
    local panel = addon_data.config.config_frame
    local settings = character_player_settings
    local settings_core = character_core_settings
	panel.welcome_checkbox:SetChecked(settings_core.welcome_message)
end

addon_data.config.WelcomeCheckBoxOnClick = function(self)
	character_core_settings.welcome_message = self:GetChecked()
    addon_data.core.UpdateAllVisualsOnSettingsChange()
end

addon_data.config.CreateConfigPanel = function(parent_panel)
    addon_data.config.config_frame = CreateFrame("Frame", addon_name .. "GlobalConfigPanel", parent_panel)
    local panel = addon_data.config.config_frame
    local settings = character_player_settings
    -- Title Text
    panel.title_text = addon_data.config.TextFactory(panel, "Settings", 18)
    panel.title_text:SetPoint("TOPLEFT", 0, 0)
    panel.title_text:SetTextColor(1, 0.9, 0, 1)
    	
    -- Welcome message checkbox
    panel.welcome_checkbox = addon_data.config.CheckBoxFactory(
        "WelcomeCheckBox",
        panel,
        " Welcome Message",
        "Displays the welcome message upon login/reload.",
        addon_data.config.WelcomeCheckBoxOnClick)
    panel.welcome_checkbox:SetPoint("TOPLEFT", 0, -20)
    
    -- Return the final panel
    addon_data.config.UpdateConfigValues()
    return panel
end


addon_data.bar.CreateConfigPanel = function(parent_panel)
    addon_data.bar.config_frame = CreateFrame("Frame", addon_name .. "PlayerConfigPanel", parent_panel)
    local panel = addon_data.bar.config_frame
    local settings = character_player_settings
    
    -- Title Text
    panel.title_text = addon_data.config.TextFactory(panel, "Twist Bar", 18)
    panel.title_text:SetPoint("TOPLEFT", 0, 60)
    panel.title_text:SetTextColor(1, 0.82, 0, 1)
    
    -- Enabled Checkbox
    panel.enabled_checkbox = addon_data.config.CheckBoxFactory(
        "PlayerEnabledCheckBox",
        panel,
        "Enable",
        "Enables the twist bar.",
        addon_data.bar.EnabledCheckBoxOnClick)
    panel.enabled_checkbox:SetPoint("TOPLEFT", 10, 44)
    
    -- Is Locked Checkbox
    panel.is_locked_checkbox = addon_data.config.CheckBoxFactory(
        "IsLockedCheckBox",
        panel,
        " Lock Bar",
        "Locks the twist bar in place.",
        addon_data.bar.IsLockedCheckBoxOnClick)
    panel.is_locked_checkbox:SetPoint("TOPLEFT", 10, -40)

    -- Show Border Checkbox
    panel.show_border_checkbox = addon_data.config.CheckBoxFactory(
        "PlayerShowBorderCheckBox",
        panel,
        "Show border",
        "Enables the player bar's border.",
        addon_data.bar.ShowBorderCheckBoxOnClick)
    panel.show_border_checkbox:SetPoint("TOPLEFT", 10, -60)
    
    -- Show Classic Bars Checkbox
    panel.classic_bars_checkbox = addon_data.config.CheckBoxFactory(
        "PlayerClassicBarsCheckBox",
        panel,
        "Classic bars",
        "Enables the classic texture for the player's bars.",
        addon_data.bar.ClassicBarsCheckBoxOnClick)
    panel.classic_bars_checkbox:SetPoint("TOPLEFT", 10, -100)

    -- Fill/Empty Checkbox
    panel.fill_empty_checkbox = addon_data.config.CheckBoxFactory(
        "PlayerFillEmptyCheckBox",
        panel,
        "Fill / Empty",
        "Determines if the bar is full or empty when a swing is ready.",
        addon_data.bar.FillEmptyCheckBoxOnClick)
    panel.fill_empty_checkbox:SetPoint("TOPLEFT", 10, -120)

    -- Show Left Text Checkbox
    panel.show_left_text_checkbox = addon_data.config.CheckBoxFactory(
        "PlayerShowLeftTextCheckBox",
        panel,
        "Show Left Text",
        "Enables the player's left side text.",
        addon_data.bar.ShowLeftTextCheckBoxOnClick)
    panel.show_left_text_checkbox:SetPoint("TOPLEFT", 10, -140)

    -- Show Right Text Checkbox
    panel.show_right_text_checkbox = addon_data.config.CheckBoxFactory(
        "PlayerShowRightTextCheckBox",
        panel,
        "Show Right Text",
        "Enables the player's right side text.",
        addon_data.bar.ShowRightTextCheckBoxOnClick)
    panel.show_right_text_checkbox:SetPoint("TOPLEFT", 10, -160)
    
    -- Width EditBox
    panel.width_editbox = addon_data.config.EditBoxFactory(
        "PlayerWidthEditBox",
        panel,
        "Bar Width",
        75,
        25,
        addon_data.bar.WidthEditBoxOnEnter)
    panel.width_editbox:SetPoint("TOPLEFT", 240, -60, "BOTTOMRIGHT", 275, -85)
    -- Height EditBox
    panel.height_editbox = addon_data.config.EditBoxFactory(
        "PlayerHeightEditBox",
        panel,
        "Bar Height",
        75,
        25,
        addon_data.bar.HeightEditBoxOnEnter)
    panel.height_editbox:SetPoint("TOPLEFT", 320, -60, "BOTTOMRIGHT", 355, -85)
	-- Font Size EditBox
	panel.fontsize_editbox = addon_data.config.EditBoxFactory(
        "FontSizeEditBox",
        panel,
        "Font Size",
        75,
        25,
        addon_data.bar.FontSizeEditBoxOnEnter)
    panel.fontsize_editbox:SetPoint("TOPLEFT", 160, -60)
    -- X Offset EditBox
    panel.x_offset_editbox = addon_data.config.EditBoxFactory(
        "PlayerXOffsetEditBox",
        panel,
        "X Offset",
        75,
        25,
        addon_data.bar.XOffsetEditBoxOnEnter)
    panel.x_offset_editbox:SetPoint("TOPLEFT", 200, -110, "BOTTOMRIGHT", 275, -135)
    -- Y Offset EditBox
    panel.y_offset_editbox = addon_data.config.EditBoxFactory(
        "PlayerYOffsetEditBox",
        panel,
        "Y Offset",
        75,
        25,
        addon_data.bar.YOffsetEditBoxOnEnter)
    panel.y_offset_editbox:SetPoint("TOPLEFT", 280, -110, "BOTTOMRIGHT", 355, -135)
    
    -- Twist bar color picker
    panel.main_color_picker = addon_data.config.color_picker_factory(
        'PlayerMainColorPicker',
        panel,
        settings.main_r, settings.main_g, settings.main_b, settings.main_a,
        "Twist Bar Color",
        addon_data.bar.MainColorPickerOnClick)
    panel.main_color_picker:SetPoint('TOPLEFT', 205, -150)

    -- Twist bar text color picker
    panel.main_text_color_picker = addon_data.config.color_picker_factory(
        'PlayerMainTextColorPicker',
        panel,
        settings.main_text_r, settings.main_text_g, settings.main_text_b, settings.main_text_a,
        "Twist Bar Text Color",
        addon_data.bar.MainTextColorPickerOnClick)
    panel.main_text_color_picker:SetPoint('TOPLEFT', 205, -170)
    
    -- In Combat Alpha Slider
    panel.in_combat_alpha_slider = addon_data.config.SliderFactory(
        "PlayerInCombatAlphaSlider",
        panel,
        "In Combat Opacity",
        0,
        1,
        0.05,
        addon_data.bar.CombatAlphaOnValChange)
    panel.in_combat_alpha_slider:SetPoint("TOPLEFT", 405, -60)

    -- Out Of Combat Alpha Slider
    panel.ooc_alpha_slider = addon_data.config.SliderFactory(
        "PlayerOOCAlphaSlider",
        panel,
        "Out of Combat Opacity",
        0,
        1,
        0.05,
        addon_data.bar.OOCAlphaOnValChange)
    panel.ooc_alpha_slider:SetPoint("TOPLEFT", 405, -110)
    -- Backplane Alpha Slider
    panel.backplane_alpha_slider = addon_data.config.SliderFactory(
        "PlayerBackplaneAlphaSlider",
        panel,
        "Backplane Opacity",
        0,
        1,
        0.05,
        addon_data.bar.BackplaneAlphaOnValChange)
    panel.backplane_alpha_slider:SetPoint("TOPLEFT", 405, -160)
    
    -- Return the final panel
    addon_data.bar.UpdateConfigPanelValues()
    return panel
end

-- print('-- Parsed config module correctly')