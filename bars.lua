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

--=========================================================================================
-- Intialisation func (called once relevant libs are loaded once per hand)
--=========================================================================================
function ST:init_visuals_template(hand)
    print("initing visuals for hand: "..tostring(hand))
    local frame = self[hand].frame
    local db_shared = self.db.profile
    local db = self:get_hand_table(hand)

    -- Set initial frame properties
    frame:SetPoint("CENTER")
    frame:SetMovable(not db.bar_locked)
    frame:EnableMouse(not db.bar_locked)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", self[hand].on_drag_start)
    frame:SetScript("OnDragStop", self[hand].on_drag_stop)
    frame:SetHeight(db.bar_height)
    frame:SetWidth(db.bar_width)
    frame:ClearAllPoints()
    frame:SetPoint(db.bar_point, UIParent, db.bar_rel_point, db.bar_x_offset, db.bar_y_offset)

    -- Create the backplane and border
    frame.backplane = CreateFrame("Frame", addon_name .. "MHBarBackdropFrame",
        frame, "BackdropTemplate"
    )

    -- Adjust the frame draw levels so the backplane is below the frame
    frame:SetFrameLevel(db_shared.draw_level+1)
    frame.backplane:SetFrameLevel(db_shared.draw_level)
    -- Set to the requested frame strata
    frame:SetFrameStrata(db_shared.frame_strata)
    frame.backplane:SetFrameStrata(db_shared.frame_strata)

    -- Configure the backplane/outline
    self:configure_bar_outline(hand)

    -- Create the swing timer bar
    frame.bar = frame:CreateTexture(nil, "ARTWORK")
    frame.bar:SetPoint("TOPLEFT", 0, 0)
    frame.bar:SetHeight(db.bar_height)
    -- frame.bar:SetTexture(LSM:Fetch('statusbar', db.bar_texture_key))
    -- self:set_bar_color(hand)
    frame.bar:SetWidth(db.bar_width)

    -- Create the GCD timer bar
    frame.gcd_bar = frame:CreateTexture(nil, "ARTWORK")
    frame.gcd_bar:SetHeight(db.bar_height)
    -- frame.gcd_bar:SetTexture(LSM:Fetch('statusbar', db.gcd_texture_key))
    -- frame.gcd_bar:SetVertexColor(
    --     self:convert_color(db.bar_color_gcd)
    -- )
    frame.gcd_bar:SetDrawLayer("ARTWORK", -2)
    frame.gcd_bar:Hide()

    self:configure_bar_appearances(hand)

    -- Create the deadzone bar
    frame.deadzone = frame:CreateTexture(nil, "ARTWORK")
    frame.deadzone:SetPoint("TOPRIGHT", 0, 0)
    frame.deadzone:SetHeight(db.bar_height)
    frame.deadzone:SetDrawLayer("ARTWORK", -1)
    self:configure_deadzone(hand)
    self:set_deadzone_width(hand)
    if not db.enable_deadzone then
        frame.deadzone:Hide()
    end

    -- Create the attack speed/swing timer texts and init them
    frame.left_text = frame:CreateFontString(nil, "OVERLAY")
    frame.left_text:SetShadowColor(0.0,0.0,0.0,1.0)
    frame.left_text:SetShadowOffset(1,-1)
    frame.left_text:SetJustifyV("CENTER")
    frame.left_text:SetJustifyH("LEFT")

    frame.right_text = frame:CreateFontString(nil, "OVERLAY")
    frame.right_text:SetShadowColor(0.0,0.0,0.0,1.0)
    frame.right_text:SetShadowOffset(1,-1)
    frame.right_text:SetJustifyV("CENTER")
    frame.right_text:SetJustifyH("RIGHT")
    self:configure_texts(hand)

    -- Create the line markers
    frame.gcd1a_marker = frame:CreateLine()
    frame.gcd1a_marker:SetDrawLayer("OVERLAY", -1)
    frame.gcd1b_marker = frame:CreateLine()
    frame.gcd1b_marker:SetDrawLayer("OVERLAY", -1)

    -- frame.gcd2a_marker = frame:CreateLine()
    -- frame.gcd2a_marker:SetDrawLayer("OVERLAY", -1)
    -- frame.gcd2b_marker = frame:CreateLine()
    -- frame.gcd2b_marker:SetDrawLayer("OVERLAY", -1)

    self:configure_gcd_markers(hand)

    -- Finally show the frame
	frame:Show()
end

------------------------------------------------------------------------------------
-- Configuration functions (called on frame inits and setting changes)
-- These all operate on a given hand.
------------------------------------------------------------------------------------
function ST:configure_bar_appearances(hand)
    -- COnfigure textures/colors for bar and GCD underlay
    local frame = self[hand].frame
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
    local f = self:get_frame(hand)
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
	local f = self:get_frame(hand).deadzone
    f:SetTexture(LSM:Fetch('statusbar', db.deadzone_texture_key))
	f:SetVertexColor(
        self:convert_color(db.deadzone_bar_color)
    )
end

function ST:configure_texts(hand)
    local db = self:get_hand_table(hand)
	local frame = self:get_frame(hand)
	local font_path = LSM:Fetch('font', db.text_font)
	local opt_string = self.outline_map[db.text_outline_key]

    frame.left_text:SetFont(font_path, db.text_size, opt_string)
    frame.left_text:SetPoint("TOPLEFT", 3, -(db.bar_height / 2) + (db.text_size / 2))
	frame.left_text:SetTextColor(
        self:convert_color(db.text_color)
    )
    if db.left_text_enabled then
        frame.left_text:Show()
    else
        frame.left_text:Hide()
    end

    frame.right_text:SetFont(font_path, db.text_size, opt_string)
	frame.right_text:SetPoint("TOPRIGHT", -3, -(db.bar_height / 2) + (db.text_size / 2))
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
	local frame = self[hand].frame
    local db = self:get_hand_table(hand)
	local mode = db.border_mode_key
	local texture_key = db.border_texture_key
    local tv = db.backplane_outline_width
	tv = tv + 8 -- 8 corresponds to no border
	-- Switch settings based on mode
	if mode == "None" then
		texture_key = "None"
		tv = 8
	elseif mode == "Texture" then
		tv = 8
	elseif mode == "Solid" then
		texture_key = "None"
	end
    frame.backplane.backdropInfo = {
        bgFile = LSM:Fetch('statusbar', db.backplane_texture_key),
		edgeFile = LSM:Fetch('border', texture_key),
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 6, right = 6, top = 6, bottom = 6}
    }
    frame.backplane:ApplyBackdrop()
	tv = tv - 2
    frame.backplane:SetPoint('TOPLEFT', -1*tv, tv)
    frame.backplane:SetPoint('BOTTOMRIGHT', tv, -1*tv)
	frame.backplane:SetBackdropColor(0,0,0, db.backplane_alpha)
end

function ST:configure_bar_position(hand)
    local db = self:get_hand_table(hand)
	local frame = self[hand].frame
	frame:ClearAllPoints()
	frame:SetPoint(db.bar_point, UIParent, db.bar_rel_point, db.bar_x_offset, db.bar_y_offset)
	frame.bar:SetPoint("TOPLEFT", 0, 0)
	frame.bar:SetPoint("TOPLEFT", 0, 0)
	frame.gcd_bar:SetPoint("TOPLEFT", 0, 0)
	frame.deadzone:SetPoint("TOPRIGHT", 0, 0)
	frame.left_text:SetPoint("TOPLEFT", 3, -(db.bar_height / 2) + (db.text_size / 2))
	frame.right_text:SetPoint("TOPRIGHT", -3, -(db.bar_height / 2) + (db.text_size / 2))
	self:configure_bar_outline(hand)
end

function ST:configure_gcd_underlay(hand)
    local db = self:get_hand_table(hand)
	local frame = self:get_frame(hand)
    frame.gcd_bar:SetTexture(LSM:Fetch('statusbar', db.gcd_texture_key))
    frame.gcd_bar:SetVertexColor(
        self:convert_color(db.bar_color_gcd)
    )
    frame.gcd_bar:SetDrawLayer("ARTWORK", -2)
end

--=========================================================================================
-- UIHANDLERs
--=========================================================================================
function ST:drag_stop_template(hand)
    local frame = self[hand].frame
    local db = self:get_hand_table(hand)
    frame:StopMovingOrSizing()
    local point, _, rel_point, x_offset, y_offset = frame:GetPoint()
    db.bar_x_offset = st.utils.simple_round(x_offset, 0.1)
    db.bar_y_offset = st.utils.simple_round(y_offset, 0.1)
    db.bar_point = point
    db.bar_rel_point = rel_point
    self:configure_bar_position(hand)
    -- self:set_bar_color(hand)
end

function ST:drag_start_template(hand)
    local db = self:get_profile_table(hand)
    if not db.bar_locked then
        ST[hand].frame:StartMoving()
    end
end

function ST.mainhand.on_drag_start()
    ST:drag_start_template('mainhand')
end

function ST.mainhand.on_drag_stop()
    ST:drag_stop_template('mainhand')
end

function ST.offhand.on_drag_start()
    ST:drag_start_template('offhand')
end

function ST.offhand.on_drag_stop()
    ST:drag_stop_template('offhand')
end

function ST.ranged.on_drag_start()
    ST:drag_start_template('ranged')
end

function ST.ranged.on_drag_stop()
    ST:drag_stop_template('ranged')
end

--=========================================================================================
-- OnUpdate funcs
--=========================================================================================
function ST:onupdate_common(hand, elapsed)
    -- Template OnUpdate function for each bar.
    local frame = self[hand].frame
    local d = self[hand]
    local t = GetTime()
    local db = self:get_hand_table(hand)
    if not d.is_paused then
        d.current_progress = math.min(1, (t - d.start) /
            (d.ends_at - d.start)
        )
    else
    end

    local timer_width = db.bar_width * d.current_progress
    frame.bar:SetWidth(max(1, timer_width))
    frame.bar:SetTexCoord(0, d.current_progress, 0, 1)
    local progress = d.current_progress
    
    -- Update the main bar's width
    local timer_width = db.bar_width * progress
    frame.bar:SetWidth(max(1, timer_width))
	frame.bar:SetTexCoord(0, progress, 0, 1)
    
    -- Update the GCD underlay if necessary.
    if db.show_gcd_underlay and self.gcd.expires then
        self:set_gcd_width(hand, timer_width, progress)
    end

    -- If any gcd marker is anchored to the bar position, handle
    -- that here.
    if db.gcd1a_marker_enabled and db.gcd1a_marker_anchor == "swing" then
        local gcd_d = self:get_gcd_marker_duration(hand, '1a')
        local gcd_additional_progress = gcd_d / d.speed
        local combined_progress = progress + gcd_additional_progress
        if not d.is_full then
            frame.gcd1a_marker:Show()
        else
            frame.gcd1a_marker:Hide()
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
        local offset = combined_progress * db.bar_width
        local v_offset = db.bar_height * db.gcd1a_marker_fractional_height * -1
        frame.gcd1a_marker:SetStartPoint("TOPLEFT", offset, 0)
        frame.gcd1a_marker:SetEndPoint("TOPLEFT", offset, v_offset)
    end
    if db.gcd1b_marker_enabled and db.gcd1b_marker_anchor == "swing" then
        local gcd_d = self:get_gcd_marker_duration(hand, '1b')
        -- print(gcd_d)
        local gcd_additional_progress = gcd_d / d.speed
        local combined_progress = progress + gcd_additional_progress
        if not d.is_full then
            frame.gcd1b_marker:Show()
        else
            frame.gcd1b_marker:Hide()
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
        local offset = combined_progress * db.bar_width
        local v_offset = db.bar_height * db.gcd1b_marker_fractional_height
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
    local frame = self:get_frame(hand)
    if db.gcd1a_marker_enabled or db.gcd1b_marker_enabled then
        self:set_gcd_marker_positions(hand)
        -- frame.gcd1a_marker:Show()
    end
    -- if db.gcd1b_marker_enabled then
    --     frame.gcd1b_marker:Show()
    -- end
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
    local frame = self:get_frame(hand)
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
    local frame = self:get_frame(hand)
    local tab = self[hand]
    local gcd_progress = (self.gcd.expires - tab.start) / (tab.ends_at - tab.start)
    -- if gcd would go over the end of the bar, instead use the swing timer
    -- bar progress to evalute texture coords and gcd bar width
    if gcd_progress > 1 then
        local gcd_width = db.bar_width - timer_width
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
        local gcd_width = (db.bar_width * gcd_progress) - timer_width
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
    local frame = self:get_frame(hand)
    local s = self[hand].speed

    local hand_is_full = GetTime() >= self[hand].ends_at
    -- print('hand_is_full says: '..tostring(hand_is_full))

    if db_hand.gcd1a_marker_enabled and db_hand.gcd1a_marker_anchor == "endofswing" then
        local t_before = self:get_gcd_marker_duration(hand, '1a')
        local progress = t_before / s
        -- print(progress)
        -- print(self[hand].is_full)
        if progress >= 1 or self[hand].is_full then
            frame.gcd1a_marker:Hide()
        else
            -- print("showing 1a")
            frame.gcd1a_marker:Show()
        end
        local offset = progress * db_hand.bar_width * -1
        local v_offset = db_hand.bar_height * db_hand.gcd1a_marker_fractional_height * -1
        frame.gcd1a_marker:SetStartPoint("TOPRIGHT", offset, 0)
        frame.gcd1a_marker:SetEndPoint("TOPRIGHT", offset, v_offset)
    else
        frame.gcd1a_marker:Hide()
    end
    if db_hand.gcd1b_marker_enabled and db_hand.gcd1b_marker_anchor == "endofswing" then
        local t_before = self:get_gcd_marker_duration(hand, '1b')
        local progress = t_before / s
        if progress >= 1 or self[hand].is_full then
            frame.gcd1b_marker:Hide()
        else
            frame.gcd1b_marker:Show()
        end
        local offset = progress * db_hand.bar_width * -1
        local v_offset = db_hand.bar_height * db_hand.gcd1b_marker_fractional_height
        frame.gcd1b_marker:SetStartPoint("BOTTOMRIGHT", offset, 0)
        frame.gcd1b_marker:SetEndPoint("BOTTOMRIGHT", offset, v_offset)
    else
        frame.gcd1b_marker:Hide()
    end
end

function ST:set_bar_texts(hand)
    -- Function to set the requisite texts on the bar.
    if self[hand].is_paused then return end
    local frame = self[hand].frame
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
    local frame = self:get_frame(hand).deadzone
    local db_shared = self.db.profile
    if not db.enable_deadzone then
        return
    end
    local frac = (self.latency.world_ms / 1000) / self[hand].speed
    frac = frac * db_shared.deadzone_scale_factor
    frame:SetWidth(max(1, frac * db.bar_width))
end

function ST:set_bar_color(hand, color_table)
    local db = self:get_hand_table(hand)
    local frame = self[hand].frame

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
