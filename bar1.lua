------------------------------------------------------------------------------------
-- Module for all swing timer bar code
------------------------------------------------------------------------------------
local addon_name, st = ...
local print = st.utils.print_msg
local SML = LibStub("LibSharedMedia-3.0")
local ST = LibStub("AceAddon-3.0"):GetAddon(addon_name)

------------------------------------------------------------------------------------
-- Helper funcs
------------------------------------------------------------------------------------
function ST:show_mh()
    local c = ST.db.profile
    if c.show_mh then
        return true
    end
    return false
end

function ST:show_oh()
    local c = ST.db.profile
    if c.show_oh and self.has_oh then
        return true
    end
    return false
end

function ST:show_ranged()
    local c = ST.db.profile
    if c.show_ranged and self.has_ranged then
        return true
    end
    return false
end

st.bar = {}

-- the following should be flagged when the swing speed changes to
-- evaluate the new offsets for ticks
st.bar.recalculate_ticks = true
st.bar.twist_tick_offset = 0.1
st.bar.gcd1_tick_offset = 0.1
st.bar.gcd2_tick_offset = 0.1
st.bar.gcd_bar_width = 0.0

local set_fonts = function()
	local db = ST.db.profile
	local frame = st.bar.frame
	local font_path = LSM:Fetch('font', db.text_font)

	local opt_string = outline_map[db.font_outline_key]
	frame.left_text:SetFont(font_path, db.font_size, opt_string)
	frame.right_text:SetFont(font_path, db.font_size, opt_string)
	frame.left_text:SetPoint("TOPLEFT", 3, -(db.bar_height / 2) + (db.font_size / 2))
	frame.right_text:SetPoint("TOPRIGHT", -3, -(db.bar_height / 2) + (db.font_size / 2))
	frame.left_text:SetTextColor(unpack(db.font_color))
	frame.right_text:SetTextColor(unpack(db.font_color))
end
st.set_fonts = set_fonts
ST.set_fonts = set_fonts

local set_marker_widths = function()
	local frame = st.bar.frame
	local db = ST.db.profile
	-- frame.twist_line:SetThickness(db.marker_width)
	frame.gcd1_line:SetThickness(db.marker_width)
	frame.gcd2_line:SetThickness(db.marker_width)
	frame.judgement_line:SetThickness(db.marker_width)
end
st.set_marker_widths = set_marker_widths

local set_marker_colors = function()
	local frame = st.bar.frame
	local db = ST.db.profile
	-- frame.twist_line:SetColorTexture(unpack(ST.db.profile.twist_marker_color))
	frame.gcd1_line:SetColorTexture(unpack(ST.db.profile.gcd_marker_color))
	frame.gcd2_line:SetColorTexture(unpack(ST.db.profile.gcd_marker_color))
	frame.judgement_line:SetColorTexture(unpack(ST.db.profile.judgement_marker_color))
end
st.set_marker_colors = set_marker_colors

st.set_markers = function()
	st.set_marker_colors()
	st.set_marker_widths()
	st.bar.set_marker_offsets()
end

-- st.configure_bar_outline = function()
--     -- print("self saying" .. tostring(self))
--     -- print("frame saying " .. tostring(self.mh.frame))
-- 	print('a')
--     print(ST.mh)
--     local frame = ST.mh.frame
--     local db = ST.db.profile
-- 	local mode = db.border_mode_key
-- 	local texture_key = db.border_texture_key
--     local tv = db.backplane_outline_width
-- 	-- 8 corresponds to no border
-- 	tv = tv + 8

-- 	-- Switch settings based on mode
-- 	if mode == "None" then
-- 		texture_key = "None"
-- 		tv = 8
-- 	elseif mode == "Texture" then
-- 		tv = 8
-- 	elseif mode == "Solid" then
-- 		texture_key = "None"
-- 	end

--     frame.backplane.backdropInfo = {
--         bgFile = SML:Fetch('statusbar', db.backplane_texture_key),
-- 		edgeFile = SML:Fetch('border', texture_key),
--         tile = true, tileSize = 16, edgeSize = 16, 
--         insets = { left = 6, right = 6, top = 6, bottom = 6}
--     }
--     frame.backplane:ApplyBackdrop()

-- 	tv = tv - 2
--     frame.backplane:SetPoint('TOPLEFT', -1*tv, tv)
--     frame.backplane:SetPoint('BOTTOMRIGHT', tv, -1*tv)
-- 	frame.backplane:SetBackdropColor(0,0,0, db.backplane_alpha)

-- end

--=========================================================================================
-- Drag and drop handlers
--=========================================================================================
st.bar.OnFrameDragStart = function()
    if not ST.db.profile.bar_locked then
        st.bar.frame:StartMoving()
    end
end

st.bar.OnFrameDragStop = function()
    local frame = st.bar.frame
    local db = ST.db.profile
    frame:StopMovingOrSizing()
    local point, _, rel_point, x_offset, y_offset = frame:GetPoint()
    db.bar_x_offset = st.utils.simple_round(x_offset, 0.1)
    db.bar_y_offset = st.utils.simple_round(y_offset, 0.1)
    db.bar_point = point
    db.bar_rel_point = rel_point
    st.set_bar_position()
    st.bar.set_bar_color()
end

--=========================================================================================
-- Intialisation func
--=========================================================================================
-- this function is called once to initialise all the graphics of the bar
function ST:init_mh_bar_visuals()
    -- self.mh.frame = CreateFrame("Frame", addon_name .. "MHBarFrame", UIParent)

    local frame = self.mainhand.frame
    local db = self.db.profile

    -- Set initial frame properties
    frame:SetPoint("CENTER")
    frame:SetMovable(not db.bar_locked)
    frame:EnableMouse(not db.bar_locked)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", st.bar.OnFrameDragStart)
    frame:SetScript("OnDragStop", st.bar.OnFrameDragStop)
    frame:SetHeight(db.bar_height)
    frame:SetWidth(db.bar_width)
    frame:ClearAllPoints()
    frame:SetPoint(db.bar_point, UIParent, db.bar_rel_point, db.bar_x_offset, db.bar_y_offset)

    -- Create the backplane and border
    frame.backplane = CreateFrame("Frame", addon_name .. "MHBarBackdropFrame", frame, "BackdropTemplate")

    -- Adjust the frame draw levels so the backplane is below the frame
    frame:SetFrameLevel(db.draw_level+1)
    frame.backplane:SetFrameLevel(db.draw_level)
    -- Set to the requested frame strata
    frame:SetFrameStrata(db.frame_strata)
    frame.backplane:SetFrameStrata(db.frame_strata)

    -- Configure the backplane/outline
    self:configure_bar_outline()

    -- Create the swing timer bar
    frame.bar = frame:CreateTexture(nil,"ARTWORK")
    frame.bar:SetPoint("TOPLEFT", 0, 0)
    frame.bar:SetHeight(db.bar_height)
    frame.bar:SetTexture(SML:Fetch('statusbar', db.bar_texture_key))
    frame.bar:SetVertexColor(unpack(db.bar_color_default))

    -- Create the GCD timer bar
    frame.gcd_bar = frame:CreateTexture(nil, "ARTWORK")
    frame.gcd_bar:SetPoint("TOPLEFT", 0, 0)
    frame.gcd_bar:SetHeight(db.bar_height)
    frame.gcd_bar:SetTexture(SML:Fetch('statusbar', db.gcd_texture_key))
    frame.gcd_bar:SetVertexColor(unpack(db.bar_color_gcd))
    frame.gcd_bar:SetDrawLayer("ARTWORK", -2)

    -- Create the deadzone bar
    -- frame.deadzone = frame:CreateTexture(nil, "ARTWORK")
    -- frame.deadzone:SetPoint("TOPRIGHT", 0, 0)
    -- st.set_deadzone()
    -- frame.deadzone:SetHeight(db.bar_height)
    -- frame.deadzone:SetDrawLayer("ARTWORK", -1)
    -- if not db.enable_deadzone then
    --     frame.deadzone:Hide()
    -- end

    -- Create the attack speed/swing timer texts and init them
    -- frame.left_text = frame:CreateFontString(nil, "OVERLAY")
    -- frame.left_text:SetShadowColor(0.0,0.0,0.0,1.0)
    -- frame.left_text:SetShadowOffset(1,-1)
    -- frame.left_text:SetJustifyV("CENTER")
    -- frame.left_text:SetJustifyH("LEFT")

    -- frame.right_text = frame:CreateFontString(nil, "OVERLAY")
    -- frame.right_text:SetShadowColor(0.0,0.0,0.0,1.0)
    -- frame.right_text:SetShadowOffset(1,-1)
    -- frame.right_text:SetJustifyV("CENTER")
    -- frame.right_text:SetJustifyH("RIGHT")
    -- st.set_fonts()

    -- Create the line markers
    -- frame.twist_line = frame:CreateLine() -- the twist window marker
    -- frame.twist_line:SetDrawLayer("OVERLAY", -1)
    -- frame.gcd1_line = frame:CreateLine() -- the first gcd possible before a twist
    -- frame.gcd1_line:SetDrawLayer("OVERLAY", -1)
    -- frame.gcd2_line = frame:CreateLine()
    -- frame.gcd2_line:SetDrawLayer("OVERLAY", -1)
    -- frame.gcd2_line:SetColorTexture(0.4,0.4,1,1)
    -- frame.gcd2_line:SetThickness(db.marker_width)
    -- frame.judgement_line = frame:CreateLine()
    -- frame.judgement_line:SetDrawLayer("OVERLAY", -1)
    -- st.set_markers()

	frame:Show()
    if st.debug then print('Successfully initialised all bar visuals.') end
end


--=========================================================================================
-- OnUpdate widget handlers and functions
--=========================================================================================
ST.mainhand.onupdate = function(elapsed)
    -- print('onupdate called')
    -- st.bar.show_or_hide_bar()
    -- if not st.bar.should_show_bar() then return end
    local self = ST
    local frame = self.mainhand.frame
    -- local speed = st.player.current_weapon_speed
    -- local timer = st.player.swing_timer

    local t = GetTime()
    local progress = math.min(1, (t - self.mainhand.start) /
        (self.mainhand.ends_at - self.mainhand.start)
    )

	-- local progress = 1 - math.max(0, math.min(1, timer / speed))
    local db = ST.db.profile

    -- Update the main bar's width
    local timer_width = db.bar_width * progress
    frame.bar:SetWidth(timer_width)
	frame.bar:SetTexCoord(0, progress, 0, 1)
	
    -- Update the deadzone's width
    -- frame.deadzone:SetWidth(st.bar.get_deadzone_width())

	-- -- Set texts
	-- local lookup = {
	-- 	attack_speed=format("%.1f", st.utils.simple_round(speed, 0.1)),
	-- 	swing_timer=format("%.1f", st.utils.simple_round(timer, 0.1)),
	-- }
	-- local left = lookup[db.left_text]
	-- local right = lookup[db.right_text]
	
    -- -- Update the main bars text, hide right text if bar full
    -- frame.left_text:SetText(left)
    -- frame.right_text:SetText(right)

    -- -- If SoC/SoR, bar colour is time/context sensitive. Deal with that here.
    -- if st.player.is_twist_seal_active() then
    --     if st.player.n_active_seals == 1 then
    --         local twist_window_time = st.bar.get_twist_window_time_before_swing()
    --         local gcd1_time = select(1, st.bar.get_gcd_times_before_swing())
    --         if st.player.twist_impossible then
    --             st.bar.frame.bar:SetVertexColor(unpack(db.bar_color_cant_twist))
    --         elseif st.player.swing_timer < twist_window_time then 
    --             st.bar.frame.bar:SetVertexColor(unpack(db.bar_color_command))
    --         else
    --             if st.player.swing_timer > gcd1_time then            
    --                 st.bar.frame.bar:SetVertexColor(unpack(db.bar_color_command))
    --             else
    --                 st.bar.frame.bar:SetVertexColor(unpack(db.bar_color_warning))
    --             end
    --         end        
    --     end
    -- end
end

ST.offhand.onupdate = function(elapsed)
end


ST.ranged.onupdate = function(elapsed)
end


--=========================================================================================
-- Funcs to alter widgets
--=========================================================================================
function ST:get_current_bar_width(hand)

end

function ST:set_gcd_width()
    -- Called when there is an active gcd either when a new gcd is triggered
    -- or when the swing timer resets.
    local frame = self.mainhand.frame
    local db = self.db.profile

    if self.gcd.expires > self.mainhand.ends_at then
        frame.gcd_bar:SetWidth(db.bar_width)
        return
    end
    -- Else figure out the width to set it at.
    local t = self.gcd.expires
    local progress = math.min(1, (t - self.mainhand.start) /
        (self.mainhand.ends_at - self.mainhand.start)
    )
    local timer_width = db.bar_width * progress
    frame.gcd_bar:SetWidth(timer_width)
end
