local addon_name, st = ...
-- local L = st.localization_table
local print = st.utils.print_msg

st.config = {}

st.config.OnDefault = function()
    st.core.RestoreAllDefaults()
    st.config.UpdateConfigValues()
end

st.config.InitializeVisuals = function()

    -- Add the parent panel
    st.config.config_parent_panel = CreateFrame("Frame", addon_name .. "MyConfigFrame", UIParent)
    local panel = st.config.config_parent_panel
    panel:SetSize(1, 1)
    panel.global_panel = st.config.CreateConfigPanel(panel)
    panel.global_panel:SetPoint('TOPLEFT', 10, -10)
    panel.global_panel:SetSize(1, 1)

    panel.name = "SwedgeTimer"
    panel.default = st.config.OnDefault
    InterfaceOptions_AddCategory(panel)
    
    -- Add the melee panel
    panel.config_melee_panel = CreateFrame("Frame", nil, panel)
    panel.config_melee_panel:SetSize(1, 1)
    panel.config_melee_panel.player_panel = st.bar.CreateConfigPanel(panel.global_panel)
    panel.config_melee_panel.player_panel:SetPoint('TOPLEFT', 0, -120)
    panel.config_melee_panel.player_panel:SetSize(1, 1)
    panel.config_melee_panel.name = "Twist Bar Settings"
    panel.config_melee_panel.parent = panel.name
    panel.config_melee_panel.default = st.config.OnDefault
end

st.config.TextFactory = function(parent, text, size)
    local text_obj = parent:CreateFontString(nil, "ARTWORK")
    text_obj:SetFont("Fonts/FRIZQT__.ttf", size)
    text_obj:SetJustifyV("CENTER")
    text_obj:SetJustifyH("CENTER")
    text_obj:SetText(text)
    return text_obj
end

st.config.CheckBoxFactory = function(g_name, parent, checkbtn_text, tooltip_text, on_click_func)
    local checkbox = CreateFrame("CheckButton", addon_name .. g_name, parent, "ChatConfigCheckButtonTemplate")
    getglobal(checkbox:GetName() .. 'Text'):SetText(checkbtn_text)
    checkbox.tooltip = tooltip_text
    checkbox:SetScript("OnClick", function(self)
        on_click_func(self)
    end)
    checkbox:SetScale(1.1)
    return checkbox
end

st.config.EditBoxFactory = function(g_name, parent, title, w, h, enter_func)
    local edit_box_obj = CreateFrame("EditBox", addon_name .. g_name, parent, "BackdropTemplate")
    edit_box_obj.title_text = st.config.TextFactory(edit_box_obj, title, 12)
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

st.config.SliderFactory = function(g_name, parent, title, min_val, max_val, val_step, func)
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
        editbox:SetText(tostring(st.utils.simple_round(self:GetValue(), val_step)))
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

st.config.color_picker_factory = function(g_name, parent, r, g, b, a, text, on_click_func)
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
    color_picker.text = st.config.TextFactory(color_picker, text, 12)
    color_picker.text:SetPoint('LEFT', 25, 0)
    return color_picker
end

st.config.UpdateConfigValues = function()
    local panel = st.config.config_frame
    -- local settings = swedgetimer_player_settings
    local settings_core = swedgetimer_core_settings
	panel.welcome_checkbox:SetChecked(settings_core.welcome_message)
end

st.config.WelcomeCheckBoxOnClick = function(self)
	swedgetimer_core_settings.welcome_message = self:GetChecked()
    st.core.UpdateAllVisualsOnSettingsChange()
end

st.config.CreateConfigPanel = function(parent_panel)
    st.config.config_frame = CreateFrame("Frame", addon_name .. "GlobalConfigPanel", parent_panel)
    local panel = st.config.config_frame
    -- local settings = swedgetimer_player_settings
    -- Title Text
    panel.title_text = st.config.TextFactory(panel, "Settings", 18)
    panel.title_text:SetPoint("TOPLEFT", 0, 0)
    panel.title_text:SetTextColor(1, 0.9, 0, 1)
    	
    -- Welcome message checkbox
    panel.welcome_checkbox = st.config.CheckBoxFactory(
        "WelcomeCheckBox",
        panel,
        " Welcome Message",
        "Displays the welcome message upon login/reload.",
        st.config.WelcomeCheckBoxOnClick)
    panel.welcome_checkbox:SetPoint("TOPLEFT", 0, -20)
    
    -- Return the final panel
    st.config.UpdateConfigValues()
    return panel
end

--=========================================================================================
-- End, if debug verify module was read.
--=========================================================================================
if st.debug then print('-- Parsed config.lua module correctly') end