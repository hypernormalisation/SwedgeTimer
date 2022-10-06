------------------------------------------------------------------------------------
-- Module for all swing timer bar/widget code.
--
-- Contains:
--   - The function to initialise all the frames on addon load
--   - configuration functions that are used on init/setting change
--   - UIHANDLER objects to handle drag/drop etc behaviour
--   - OnUpdate scripts to handle the limited number of things that are
--      best done on a per-frame basis.
--   - functions to manipulate the widgets in predefined ways
------------------------------------------------------------------------------------
local addon_name, st = ...
local print = st.utils.print_msg
local LSM = LibStub("LibSharedMedia-3.0")
local ST = LibStub("AceAddon-3.0"):GetAddon(addon_name)
local LWIN = LibStub("LibWindow-1.1")

--=========================================================================================
-- Intialisation func (called once relevant libs are loaded once per hand)
--=========================================================================================
function ST:init_visuals_template(hand)
    -- Get the relevant db table.
    local db = self:get_hand_table(hand)

    -- Make the anchor frame, which is the top-level parent of the bar
    -- visual frames in our addon, and set its initial size/position properties.
	local anchor_frame = CreateFrame(
		"Frame",
        addon_name .. hand .. "AnchorFrame",
        UIParent
	)
    self[hand].anchor_frame = anchor_frame

    -- Configure drag and drop handlers with LibWindow, adding a callback
    -- to the config menu to let the panel know the coords have changed.
    LWIN.RegisterConfig(anchor_frame, self:get_hand_table(hand))
    anchor_frame:RegisterForDrag("LeftButton")
    anchor_frame:SetScript("OnDragStart", function()
            LWIN.OnDragStart(anchor_frame)
        end
    )
    anchor_frame:SetScript("OnDragStop", function()
            LWIN.OnDragStop(anchor_frame)
            local ACR = LibStub("AceConfigRegistry-3.0")
            ACR:NotifyChange(self.options_table_name)
        end
    )

    -- Make a frame, also the size of the anchor, that will receive
    -- calls to show and hide the bar, so other addons like WeakAuras
    -- can anchor to this frame and respect show/hide but not our bar's
    -- dim settings.
    local hiding_anchor_frame = CreateFrame(
        "Frame",
        addon_name .. hand .. "HidingAnchorFrame",
        anchor_frame
    )
    anchor_frame.hiding_anchor_frame = hiding_anchor_frame

    -- Make a frame to house the bar components in full.
    -- This frame has to inherit from BackdropTemplate.
    local bar_frame = CreateFrame(
        "Frame",
        nil,
        anchor_frame,
        "BackdropTemplate"
    )
    anchor_frame.bar_frame = bar_frame

    -- Now make a frame to house the progress bar components
    local visuals_frame = CreateFrame(
        "Frame",
        nil,
        bar_frame
    )
    bar_frame.visuals_frame = visuals_frame

    -- Create the swing timer bar texture
    visuals_frame.bar = visuals_frame:CreateTexture(nil, "ARTWORK")
    visuals_frame.bar:SetPoint("TOPLEFT", 0, 0)

    -- Create the GCD timer bar
    visuals_frame.gcd_bar = visuals_frame:CreateTexture(nil, "ARTWORK")
    visuals_frame.gcd_bar:Hide()

    -- Create the deadzone bar
    visuals_frame.deadzone = visuals_frame:CreateTexture(nil, "ARTWORK")

    -- Create the attack speed/swing timer texts and init them
    visuals_frame.left_text = visuals_frame:CreateFontString(nil, "OVERLAY")
    visuals_frame.right_text = visuals_frame:CreateFontString(nil, "OVERLAY")

    -- Create the line markers
    visuals_frame.gcd1a_marker = visuals_frame:CreateLine()
    visuals_frame.gcd1b_marker = visuals_frame:CreateLine()

    self:configure_frame_strata(hand)
    self:configure_draw_layers(hand)
    self:configure_bar_size_and_positions(hand)
    self:configure_bar_outline(hand)
    self:configure_bar_appearances(hand)
    self:configure_deadzone(hand)
    self:set_deadzone_width(hand)
    self:configure_texts(hand)
    self:configure_gcd_markers(hand)

end

------------------------------------------------------------------------------------
-- Bar configuration functions (called on frame inits and setting changes)
-- These all operate on a given hand.
------------------------------------------------------------------------------------
function ST:configure_draw_layers(hand)
    -- Sets the draw layers within the visuals frame for the swing timer
    -- bar sub-components.
    local f = self:get_visuals_frame(hand)
    f.gcd_bar:SetDrawLayer("ARTWORK", -2)
    f.deadzone:SetDrawLayer("ARTWORK", -1)
    f.gcd1a_marker:SetDrawLayer("OVERLAY", -1)
    f.gcd1b_marker:SetDrawLayer("OVERLAY", -1)
end

function ST:configure_bar_size_and_positions(hand)
    local db = self:get_hand_table(hand)
	
    -- First set the anchor frame and bar frames
    -- to the full size in the settings, and restore their
    -- positions with LibWindow
    local anchor_frame = self:get_anchor_frame(hand)
    anchor_frame:ClearAllPoints()
    anchor_frame:SetPoint("CENTER")
    anchor_frame:SetWidth(db.bar_width)
    anchor_frame:SetHeight(db.bar_height)
    LWIN.RestorePosition(anchor_frame)
    anchor_frame:Show()

    -- And also the hiding anchor frame.
    local hiding_anchor_frame = self:get_hiding_anchor_frame(hand)
    hiding_anchor_frame:ClearAllPoints()
    hiding_anchor_frame:SetPoint("CENTER")
    hiding_anchor_frame:Show()

    -- Might need to set the width/height of the bar_frame too
    local bar_frame = self:get_bar_frame(hand)
    bar_frame:ClearAllPoints()
    bar_frame:SetPoint("CENTER")
    bar_frame:SetWidth(db.bar_width)
    bar_frame:SetHeight(db.bar_height)

    -- For the visuals frame, we calculate a reduced size 
    -- based on the backplane settings.
    -- Set it internally for use elsewhere
    local visuals_frame = self:get_visuals_frame(hand)
    local vf_width = db.bar_width - (db.border_width * 2)
    local vf_height = db.bar_height - (db.border_width * 2)
    self[hand].vf_width = vf_width
    self[hand].vf_height = vf_height
    visuals_frame:SetHeight(vf_height)
    visuals_frame:SetWidth(vf_width)

    -- And set the subcomponent anchors (where appropriate)
    -- and sizes.
    visuals_frame.bar:SetPoint("TOPLEFT", 0, 0)
    visuals_frame.bar:SetHeight(vf_height)
    visuals_frame.bar:SetWidth(vf_width)
    visuals_frame.gcd_bar:SetHeight(vf_height)
    visuals_frame.deadzone:SetHeight(vf_height)
    visuals_frame.deadzone:SetPoint("TOPRIGHT")
    visuals_frame:ClearAllPoints()
    visuals_frame:SetPoint("CENTER")
    self:configure_texts(hand)
    self:configure_gcd_markers(hand)
    self:configure_bar_outline(hand)
end

function ST:configure_frame_strata(hand)
    local frame = self:get_bar_frame(hand)
    local db = self:get_profile_table()
    frame:SetFrameLevel(db.draw_level+1)
    frame:SetFrameStrata(db.frame_strata)
end

function ST:configure_bar_appearances(hand)
    -- COnfigure textures/colors for bar and GCD underlay
    local frame = self:get_visuals_frame(hand)
    local db = self:get_hand_table(hand)
    frame.bar:SetTexture(LSM:Fetch('statusbar', db.bar_texture_key))
    frame.gcd_bar:SetTexture(LSM:Fetch('statusbar', db.gcd_texture_key))
    self:set_bar_color(hand)
    frame.gcd_bar:SetVertexColor(
        self:convert_color(db.bar_color_gcd)
    )
end

function ST:configure_gcd_markers(hand)
    -- Configure textures and marker widths.
    local db = self:get_hand_table(hand)
    local f = self:get_visuals_frame(hand)
    f.gcd1a_marker:SetColorTexture(
        self:convert_color(db.gcd1a_marker_color)
    )
    f.gcd1b_marker:SetColorTexture(
        self:convert_color(db.gcd1b_marker_color)
    )
    f.gcd1a_marker:SetThickness(db.gcd1a_marker_width)
    f.gcd1b_marker:SetThickness(db.gcd1b_marker_width)
end

function ST:configure_deadzone(hand)
	local db = self:get_hand_table(hand)
	local f = self:get_visuals_frame(hand).deadzone
    if not db.enable_deadzone then
        f:Hide()
    else
        f:Show()
    end
    f:SetTexture(LSM:Fetch('statusbar', db.deadzone_texture_key))
	f:SetVertexColor(
        self:convert_color(db.deadzone_bar_color)
    )
end

function ST:configure_texts(hand)
    local db = self:get_hand_table(hand)
	local frame = self:get_visuals_frame(hand)
	local font_path = LSM:Fetch('font', db.text_font)
	local opt_string = self.outlines[db.text_outline_key]
    local w, h = self:get_bar_visuals_width_and_height(hand)

    -- The best center point for the x offset seems to be about 1% above normal.
    local left_text_x_offset = ((db.left_text_x_percent_offset + 1)/ 100) * w
    -- The best center point for the y offset seems to be about 5% below normal.
    local left_text_y_offset = ((db.left_text_y_percent_offset - 5)/ 100) * h
    frame.left_text:SetPoint(
        "LEFT",
        left_text_x_offset,
        left_text_y_offset
    )
    frame.left_text:SetFont(font_path, db.text_size, opt_string)
    frame.left_text:SetTextColor(
        self:convert_color(db.text_color)
    )
    if db.left_text_enabled then
        frame.left_text:Show()
    else
        frame.left_text:Hide()
    end

    local right_text_x_offset = ((db.right_text_x_percent_offset -1)/ 100) * w
    local right_text_y_offset = ((db.right_text_y_percent_offset - 5)/ 100) * h
	frame.right_text:SetPoint(
        "RIGHT",
        right_text_x_offset,
        right_text_y_offset
    )
    frame.right_text:SetFont(font_path, db.text_size, opt_string)
	frame.right_text:SetTextColor(
        self:convert_color(db.text_color)
    )
    if db.right_text_enabled then
        frame.right_text:Show()
    else
        frame.right_text:Hide()
    end
end

function ST:configure_bar_outline(hand)
	local frame = self:get_bar_frame(hand)
    local db = self:get_hand_table(hand)
    frame.backdropInfo = {
        bgFile = LSM:Fetch('statusbar', db.background_texture_key),
		edgeFile = LSM:Fetch('border', db.border_texture_key),
        tile = true, tileSize = 16, edgeSize = db.border_width,
        -- insets = {
        --     left = db.border_width,
        --     right = db.border_width,
        --     top = db.border_width,
        --     bottom = db.border_width
        -- }
    }
    frame:ApplyBackdrop()
    frame:SetBackdropBorderColor(
        self:convert_color(db.border_color)
    )
	frame:SetBackdropColor(
        self:convert_color(db.background_color)
    )
end

function ST:configure_gcd_underlay(hand)
    local db = self:get_hand_table(hand)
	local frame = self:get_visuals_frame(hand)
    frame.gcd_bar:SetTexture(LSM:Fetch('statusbar', db.gcd_texture_key))
    frame.gcd_bar:SetVertexColor(
        self:convert_color(db.bar_color_gcd)
    )
    frame.gcd_bar:SetDrawLayer("ARTWORK", -2)
end

--=========================================================================================
-- Property funcs
--=========================================================================================
function ST:get_bar_visuals_width_and_height(hand)
    return self[hand].vf_width, self[hand].vf_height
end

--=========================================================================================
-- OnUpdate funcs
--=========================================================================================
function ST:onupdate_common(hand, elapsed)
    -- Template OnUpdate function for each bar.
    local frame = self:get_visuals_frame(hand)
    local d = self[hand]
    local t = GetTime()
    local db = self:get_hand_table(hand)
    if not d.is_paused then
        d.current_progress = math.min(1, (t - d.start) /
            (d.ends_at - d.start)
        )
    else
    end

    -- local timer_width = db.bar_width * d.current_progress
    -- frame.bar:SetWidth(max(1, timer_width))
    -- frame.bar:SetTexCoord(0, d.current_progress, 0, 1)
    local progress = d.current_progress
    local w, h = self:get_bar_visuals_width_and_height(hand)
    -- Update the main bar's width
    local timer_width = w * progress
    frame.bar:SetWidth(max(1, timer_width))
	frame.bar:SetTexCoord(0, progress, 0, 1)
    
    -- Update the GCD underlay if necessary.
    if db.show_gcd_underlay and self.gcd.expires then
        self:set_gcd_width(hand, timer_width, progress)
    end

    -- If any gcd marker is anchored to the swing, handle
    -- that here.
    if db.gcd1a_marker_enabled and db.gcd1a_marker_anchor == "swing" then
        local gcd_d = self:get_gcd_marker_duration(hand, '1a')
        local gcd_additional_progress = gcd_d / d.speed
        local combined_progress = progress + gcd_additional_progress
        -- Hide it only if the bar is full and hide_inactive is enabled, 
        -- otherwise show.
        if d.is_full and db.gcd1a_marker_hide_inactive then
            frame.gcd1a_marker:Hide()
        else
            frame.gcd1a_marker:Show()
        end
        if combined_progress > 1.0 then
            if db.gcd1a_swing_anchor_wrap then
                while combined_progress > 1.0 do
                    combined_progress = combined_progress - 1.0
                end
            else
                combined_progress = 1.0
                frame.gcd1a_marker:Hide()
            end
        end
        local offset = combined_progress * w
        local v_offset = h * db.gcd1a_marker_fractional_height * -1
        frame.gcd1a_marker:SetStartPoint("TOPLEFT", offset, 0)
        frame.gcd1a_marker:SetEndPoint("TOPLEFT", offset, v_offset)
    end
    if db.gcd1b_marker_enabled and db.gcd1b_marker_anchor == "swing" then
        local gcd_d = self:get_gcd_marker_duration(hand, '1b')
        local gcd_additional_progress = gcd_d / d.speed
        local combined_progress = progress + gcd_additional_progress
        if d.is_full and db.gcd1b_marker_hide_inactive then
            frame.gcd1b_marker:Hide()
        else
            frame.gcd1b_marker:Show()
        end
        if combined_progress > 1.0 then
            if db.gcd1b_swing_anchor_wrap then
                while combined_progress > 1.0 do
                    combined_progress = combined_progress - 1.0
                end
            else
                combined_progress = 1.0
                frame.gcd1b_marker:Hide()
            end
        end
        -- print(combined_progress)
        local offset = combined_progress * w
        local v_offset = h * db.gcd1b_marker_fractional_height
        frame.gcd1b_marker:SetStartPoint("BOTTOMLEFT", offset, 0)
        frame.gcd1b_marker:SetEndPoint("BOTTOMLEFT", offset, v_offset)
    end

    -- Set texts
    self:set_bar_texts(hand)
end

ST.mainhand.onupdate = function(elapsed)
    ST:onupdate_common("mainhand", elapsed)
end

ST.offhand.onupdate = function(elapsed)
    ST:onupdate_common("offhand", elapsed)
end

ST.ranged.onupdate = function(elapsed)
    ST:onupdate_common("ranged", elapsed)
end

--=========================================================================================
-- Collections of widget altering funcs to be called on specific events/conditions
-- Some operate generally, others on a given hand.
--=========================================================================================
function ST:on_latency_update()
    for hand in self:iter_hands() do
        self:set_deadzone_width(hand)
    end
end

function ST:on_gcd_length_change()
    -- This function fires when the *predicted length* of a GCD
    -- changes, and doesn't refer to any active GCD.
    for hand in self:iter_hands() do
        self:set_gcd_marker_positions(hand)
    end
end

function ST:on_attack_speed_change(hand)
    self:set_deadzone_width(hand)
    self:set_bar_texts(hand)
    self:set_gcd_marker_positions(hand)
end

function ST:on_bar_active(hand)
    -- Called when the bar enters the active state.
    -- This is whenever the player goes from a persistently idle state
    -- to actively swinging.
    local db = self:get_hand_table(hand)
    local frame = self:get_visuals_frame(hand)
    if db.gcd1a_marker_enabled or db.gcd1b_marker_enabled then
        self:set_gcd_marker_positions(hand)
    end
    if db.enable_deadzone then
        frame.deadzone:Show()
    end
    if db.left_text_hide_inactive then
        frame.left_text:Hide()
    end
    if db.right_text_hide_inactive then
        frame.right_text:Hide()
    end
end

function ST:on_bar_inactive(hand)
    -- Called when the bar enters the inactive state.
    -- This is when the player stops swinging with a full timer for 
    -- some finite and configurable period of time.
    -- print("TRIGGERING BAR INACTIVE")
    local db = self:get_hand_table(hand)
    local frame = self:get_visuals_frame(hand)
    if db.gcd1a_marker_hide_inactive then
        frame.gcd1a_marker:Hide()
    end
    if db.gcd1b_marker_hide_inactive then
        frame.gcd1b_marker:Hide()
    end
    if db.deadzone_hide_inactive then
        frame.deadzone:Hide()
    end
    if db.left_text_hide_inactive then
        frame.left_text:Hide()
    end
    if db.right_text_hide_inactive then
        frame.right_text:Hide()
    end
end

--=========================================================================================
-- Funcs to alter widgets outside of configuration changes.
-- These all operate on a given hand.
--=========================================================================================
function ST:set_gcd_width(hand, timer_width, progress)
    local db = self:get_hand_table(hand)
    local frame = self:get_visuals_frame(hand)
    local tab = self[hand]
    local gcd_progress = (self.gcd.expires - tab.start) / (tab.ends_at - tab.start)
    -- if gcd would go over the end of the bar, instead use the swing timer
    -- bar progress to evalute texture coords and gcd bar width
    local w = self:get_bar_visuals_width_and_height(hand)
    if gcd_progress > 1 then
        local gcd_width = w - timer_width
        frame.gcd_bar:SetWidth(max(1, gcd_width))
        if gcd_width == 0 then
            frame.gcd_bar:Hide()
        else
            frame.gcd_bar:Show()
        end
        -- print(gcd_width)
        -- print(string.format("%f %f", progress, gcd_width))
        frame.gcd_bar:SetTexCoord(progress, 1, 0, 1)
    else
        local gcd_width = (w * gcd_progress) - timer_width
        frame.gcd_bar:Show()
        frame.gcd_bar:SetWidth(max(1, gcd_width))
        frame.gcd_bar:SetTexCoord(progress, gcd_progress, 0, 1)
    end
    frame.gcd_bar:SetPoint("TOPLEFT", timer_width, 0)
end

function ST:get_gcd_marker_duration(hand, marker)
    local db = self:get_hand_table(hand)
    if marker == '1a' then
        local t = self.gcd.gcd1_phys_time_before_swing
        if db.gcd1a_marker_mode == "spell" then
            t = self.gcd.gcd1_spell_time_before_swing
        elseif db.gcd1a_marker_mode == "form" then
            if not self.is_cat_or_bear then
                t = self.gcd.gcd1_spell_time_before_swing
            end
        end
        return t
    elseif marker == '1b' then
        local t = self.gcd.gcd1_phys_time_before_swing
        if db.gcd1b_marker_mode == "spell" then
            t = self.gcd.gcd1_spell_time_before_swing
        elseif db.gcd1b_marker_mode == "form" then
            if not self.is_cat_or_bear then
                t = self.gcd.gcd1_spell_time_before_swing
            end
        end
        return t
    end
end

function ST:set_gcd_marker_positions(hand)
    -- This function's task is to first check if any GCD markers should
    -- be shown. It then calculates the necessary offsets from the end of the bar,
    -- and sets them.
    -- print('Setting marker positions for hand: ' .. tostring(hand))
    local db_hand = self:get_hand_table(hand)
    local db_class = self:get_class_table()
    local frame = self:get_visuals_frame(hand)
    local s = self[hand].speed

    local hand_is_full = GetTime() >= self[hand].ends_at
    -- print('hand_is_full says: '..tostring(hand_is_full))
    local w, h = self:get_bar_visuals_width_and_height(hand)

    -- Only process if enabled
    if db_hand.gcd1a_marker_enabled then
        if db_hand.gcd1a_marker_anchor == "endofswing" then
            local t_before = self:get_gcd_marker_duration(hand, '1a')
            local progress = t_before / s
            -- If progress > 1 then the marker is pushed off the side of the bar, 
            -- more than one standard swing, so *always* hide it.
            if progress >= 1 then
                frame.gcd1a_marker:Hide()
            else
                -- If the bar is full and hide_when_inactive, also hide
                if (self[hand].is_full and db_hand.gcd1a_marker_hide_inactive) then
                    frame.gcd1a_marker:Hide()
                else
                    -- If we get here, show it
                    local offset = progress * w * -1
                    local v_offset = h * db_hand.gcd1a_marker_fractional_height * -1
                    frame.gcd1a_marker:SetStartPoint("TOPRIGHT", offset, 0)
                    frame.gcd1a_marker:SetEndPoint("TOPRIGHT", offset, v_offset)
                    frame.gcd1a_marker:Show()
                end
            end
        end
    else
        frame.gcd1a_marker:Hide()
    end
    if db_hand.gcd1b_marker_enabled then
        if db_hand.gcd1b_marker_anchor == "endofswing" then
            local t_before = self:get_gcd_marker_duration(hand, '1b')
            local progress = t_before / s
            if progress >= 1 or (self[hand].is_full and db_hand.gcd1b_marker_hide_inactive) then
                frame.gcd1b_marker:Hide()
            else
                frame.gcd1b_marker:Show()
            end
            local offset = progress * w * -1
            local v_offset = h * db_hand.gcd1b_marker_fractional_height
            frame.gcd1b_marker:SetStartPoint("BOTTOMRIGHT", offset, 0)
            frame.gcd1b_marker:SetEndPoint("BOTTOMRIGHT", offset, v_offset)
        end
    else
        frame.gcd1b_marker:Hide()
    end
end

function ST:set_bar_texts(hand)
    -- Function to set the requisite texts on the bar.
    if self[hand].is_paused then return end
    local frame = self:get_visuals_frame(hand)
    local db = self:get_hand_table(hand)
    local t = GetTime()
    local speed = self[hand].speed
    local timer = max(0, self[hand].ends_at - t)
    local lookup = {
        attack_speed=format("%.1f", st.utils.simple_round(speed, 0.1)),
        swing_timer=format("%.1f", st.utils.simple_round(timer, 0.1)),
    }
    if db.left_text_enabled then
        if db.left_text_hide_inactive and self[hand].is_full then
            frame.left_text:Hide()
        else
            local text = lookup[db.left_text_key]
            frame.left_text:SetText(text)
            frame.left_text:Show()
        end
    else
        frame.left_text:Hide()
    end
    if db.right_text_enabled then
        if db.right_text_hide_inactive and self[hand].is_full then
            frame.right_text:Hide()
        else
            local text = lookup[db.right_text_key]
            frame.right_text:SetText(text)
            frame.right_text:Show()
        end
    else
        frame.right_text:Hide()
    end
end

function ST:set_deadzone_width(hand)
    -- print('call to set deadzone width for '..hand)
    local db = self:get_hand_table(hand)
    local frame = self:get_visuals_frame(hand).deadzone
    local db_shared = self.db.profile
    local frac = (self.latency.world_ms / 1000) / self[hand].speed
    frac = frac * db_shared.deadzone_scale_factor
    local w = self:get_bar_visuals_width_and_height(hand)
    frame:SetWidth(max(1, frac * w))

    -- Determine if to show or hide.
    if not db.enable_deadzone then
        frame:Hide()
        return
    end
    if db.deadzone_hide_inactive and self[hand].is_full then
        frame:Hide()
        return
    end
    frame:Show()
end

function ST:set_bar_color(hand, color_table)
    local db = self:get_hand_table(hand)
    local frame = self:get_visuals_frame(hand)

    -- If given a manual color, set that.
    if color_table then
        frame.bar:SetVertexColor(
            unpack(color_table)
        )
        return
    end

    -- If a class override exists, use it.
    local result = false
    if self[self.player_class].set_bar_color then
        result = self[self.player_class].set_bar_color(self, hand)
    end

    -- If no special behaviour was triggered, revert to the default.
    if not result then
        frame.bar:SetVertexColor(
            self:convert_color(db.bar_color_default)
        )
    end
end


if st.debug then st.utils.print_msg('-- Parsed bars.lua module correctly') end
