------------------------------------------------------------------------------------
-- Module to contain config default dicts, the options table configuration,
-- and any helper funcs
------------------------------------------------------------------------------------
local addon_name, st = ...
local LSM = LibStub("LibSharedMedia-3.0")
local ST = LibStub("AceAddon-3.0"):GetAddon(addon_name)
-- local print = st.utils.print_msg

--=========================================================================================
-- Functions to handle options
--=========================================================================================
function ST:get_class_options_table()
	return self.db.profile[self.player_class]
end

function ST:get_hand_table(hand)
	return self.db.profile[self.player_class][hand]
end

function ST:convert_color(t, new_alpha)
	local r,g,b,a = unpack(t)
	a = new_alpha or a
	r = r/255
	g = g/255
	b = b/255
	return r, g, b, a
end

------------------------------------------------------------------------------------
-- Default settings for the addon.

ST.defaults = {

	profile = {

		-- Class-specific defaults
		ROGUE = ST.ROGUE.defaults,

		-- Top level
		welcome_message = true,
		bar_enabled = true,

		-- Show individual timers
		show_mh = true,
		show_oh = true,
		show_ranged = true,

		-- GCD underlay
		show_gcd_underlay = true,

		-- -- Mainhand options
		-- mainhand = {
		-- 	-- behaviour
		-- 	enabled = true,
		-- 	-- Bar dimensions
		-- 	bar_height = 32,
		-- 	bar_width = 345,
		-- 	-- Bar positioning
		-- 	bar_locked = true,
		-- 	bar_x_offset = 0,
		-- 	bar_y_offset = -180,
		-- 	bar_point = "CENTER",
		-- 	bar_rel_point = "CENTER",
		-- 	-- Bar textures
		-- 	bar_texture_key = "Solid",
        -- 	gcd_texture_key = "Solid",
        -- 	backplane_texture_key = "Solid",
        -- 	border_texture_key = "None",
		-- 	deadzone_texture_key = "Solid",
		-- 	backplane_alpha = 0.85,
		-- 	-- Colors
		-- 	bar_color_default = {0.14, 0.66, 0.14, 1.0},
		-- 	bar_color_gcd = {0.48, 0.48, 0.48, 1.0},
		-- 	bar_color_deadzone = {0.72, 0.05, 0.05, 0.72},
		-- 	-- Font settings
		-- 	font_size = 16,
		-- 	font_color = {1.0, 1.0, 1.0, 1.0},
		-- 	text_font = LSM.DefaultMedia.font,
		-- 	font_outline_key = "outline",
        -- 	left_text = "attack_speed",
        -- 	right_text = "swing_timer",
		-- 	-- Border settings
		-- 	border_mode_key = "Solid",
		-- 	backplane_outline_width = 2,
		-- },

		-- -- Offhand options
		-- offhand = {
		-- 	-- behaviour
		-- 	enabled = true,
		-- 	-- Bar dimensions
		-- 	bar_height = 32,
		-- 	bar_width = 345,
		-- 	-- Bar positioning
		-- 	bar_locked = true,
		-- 	bar_x_offset = 0,
		-- 	bar_y_offset = -80,
		-- 	bar_point = "CENTER",
		-- 	bar_rel_point = "CENTER",
		-- 	-- Bar textures
		-- 	bar_texture_key = "Solid",
        -- 	gcd_texture_key = "Solid",
        -- 	backplane_texture_key = "Solid",
        -- 	border_texture_key = "None",
		-- 	deadzone_texture_key = "Solid",
		-- 	backplane_alpha = 0.85,
		-- 	-- Colors
		-- 	bar_color_default = {0.14, 0.66, 0.14, 1.0},
		-- 	bar_color_gcd = {0.48, 0.48, 0.48, 1.0},
		-- 	bar_color_deadzone = {0.72, 0.05, 0.05, 0.72},
		-- 	-- Font settings
		-- 	font_size = 16,
		-- 	font_color = {1.0, 1.0, 1.0, 1.0},
		-- 	text_font = LSM.DefaultMedia.font,
		-- 	font_outline_key = "outline",
        -- 	left_text = "attack_speed",
        -- 	right_text = "swing_timer",
		-- 	-- Border settings
		-- 	border_mode_key = "Solid",
		-- 	backplane_outline_width = 2,
		-- },

		-- -- Ranged options
		-- ranged = {
		-- 	-- behaviour
		-- 	enabled = true,
		-- 	-- Bar dimensions
		-- 	bar_height = 32,
		-- 	bar_width = 345,
		-- 	-- Bar positioning
		-- 	bar_locked = true,
		-- 	bar_x_offset = 0,
		-- 	bar_y_offset = 20,
		-- 	bar_point = "CENTER",
		-- 	bar_rel_point = "CENTER",
		-- 	-- Bar textures
		-- 	bar_texture_key = "Solid",
		-- 	gcd_texture_key = "Solid",
		-- 	backplane_texture_key = "Solid",
		-- 	border_texture_key = "None",
		-- 	deadzone_texture_key = "Solid",
		-- 	backplane_alpha = 0.85,
		-- 	-- Colors
		-- 	bar_color_default = {0.14, 0.66, 0.14, 1.0},
		-- 	bar_color_gcd = {0.48, 0.48, 0.48, 1.0},
		-- 	bar_color_deadzone = {0.72, 0.05, 0.05, 0.72},
		-- 	-- Font settings
		-- 	font_size = 16,
		-- 	font_color = {1.0, 1.0, 1.0, 1.0},
		-- 	text_font = LSM.DefaultMedia.font,
		-- 	font_outline_key = "outline",
		-- 	left_text = "attack_speed",
		-- 	right_text = "swing_timer",
		-- 	-- Border settings
		-- 	border_mode_key = "Solid",
		-- 	backplane_outline_width = 2,
		-- },
		
		-- Behaviour toggles
		lag_detection_enabled = true,
		judgement_marker_enabled = true,
        bar_twist_color_enabled = false,
		hide_when_not_ret = true,
		enable_deadzone = true,

		-- Auto-hide setting
		visibility_key = "always",

		-- Lag calibration
		lag_multiplier = 1.4,
		lag_offset = 15,

		-- Marker position settings
		gcd_padding_mode = "Dynamic",
		gcd_static_padding_ms = 100,
		twist_padding_mode = "None",
		twist_window_padding_ms = 0,

		-- Bar dimensions
		bar_height = 32,
		bar_width = 345,

		-- Bar positioning
		bar_locked = true,
		bar_x_offset = 0,
		bar_y_offset = -180,
		bar_point = "CENTER",
		bar_rel_point = "CENTER",

		-- Frame strata/draw level
		frame_strata = "MEDIUM",
		draw_level = 10,

		-- Bar textures
		bar_texture_key = "Solid",
        gcd_texture_key = "Solid",
        backplane_texture_key = "Solid",
        border_texture_key = "None",
		deadzone_texture_key = "Solid",
		backplane_alpha = 0.85,

		-- Deadzone scaling
		deadzone_scale_factor = 1.0,

		-- Border settings
		border_mode_key = "Solid",
		backplane_outline_width = 2,

		-- Font settings
		font_size = 16,
		font_color = {1.0, 1.0, 1.0, 1.0},
		text_font = LSM.DefaultMedia.font,
		font_outline_key = "outline",
        left_text = "attack_speed",
        right_text = "swing_timer",

		-- Marker settings
		marker_width = 3,
		gcd1_enabled = false,
		gcd2_enabled = false,
		gcd_marker_color = {0.9, 0.9, 0.9, 1.0},
		twist_marker_color = {0.9,0.9,0.9,1.0},
		judgement_marker_color = {0.9,0.9,0.01,1.0},

		-- Special bar colors
		bar_color_default = {0.14, 0.66, 0.14, 1.0},

		-- GCD underlay bar colors
		bar_color_gcd = {0.48, 0.48, 0.48, 1.0},

		-- Deadzone bar colors
		bar_color_deadzone = {0.72, 0.05, 0.05, 0.72},

    },

}

local bar_visibility_values = {
	always = "Always show",
	in_combat = "In Combat",
	contextual = "Contextual",
	hidden = "Hidden",
}

local contextual_visibility_values = {
	in_combat = "In Combat",
	has_attackable_target = "Has Attackable Target",
	in_range = "In Range of Target",	
}

local outline_map = {
	_none="",
	outline="OUTLINE",
	thick_outline="THICKOUTLINE",
}
ST.outline_map = outline_map

local bar_border_modes = {
	Solid="Solid",
	Texture="Texture",
	None="None",
}

local outlines = {
	_none="None",
	outline="Outline",
	thick_outline="Thick Outline",
}

local texts = {
	_none="Not shown",
	attack_speed="Attack speed",
	swing_timer="Swing timer",
}

local gcd_padding_modes = {
	Dynamic="Dynamic",
	Fixed="Fixed",
	None="None",
}

local valid_anchor_points = {
	TOPLEFT="TOPLEFT",
    TOPRIGHT="TOPRIGHT",
    BOTTOMLEFT="BOTTOMLEFT",
    BOTTOMRIGHT="BOTTOMRIGHT",
    TOP="TOP",
    BOTTOM="BOTTOM",
    LEFT="LEFT",
    RIGHT="RIGHT",
    CENTER="CENTER",
}

------------------------------------------------------------------------------------
-- Functions to apply settings to the UI elements.
-- local set_bar_position = function()
-- 	local db = ST.db.profile
-- 	local frame = st.bar.frame
-- 	frame:ClearAllPoints()
-- 	frame:SetPoint(db.bar_point, UIParent, db.bar_rel_point, db.bar_x_offset, db.bar_y_offset)
-- 	frame.bar:SetPoint("TOPLEFT", 0, 0)
-- 	frame.bar:SetPoint("TOPLEFT", 0, 0)
-- 	frame.gcd_bar:SetPoint("TOPLEFT", 0, 0)
-- 	frame.deadzone:SetPoint("TOPRIGHT", 0, 0)
-- 	frame.left_text:SetPoint("TOPLEFT", 3, -(db.bar_height / 2) + (db.font_size / 2))
-- 	frame.right_text:SetPoint("TOPRIGHT", -3, -(db.bar_height / 2) + (db.font_size / 2))
-- 	st.configure_bar_outline()
-- end
-- st.set_bar_position = set_bar_position

-- local set_fonts = function()
-- 	local db = ST.db.profile
-- 	local frame = ST.mainhand.frame
-- 	local font_path = LSM:Fetch('font', db.text_font)

-- 	local opt_string = outline_map[db.font_outline_key]
-- 	frame.left_text:SetFont(font_path, db.font_size, opt_string)
-- 	frame.right_text:SetFont(font_path, db.font_size, opt_string)
-- 	frame.left_text:SetPoint("TOPLEFT", 3, -(db.bar_height / 2) + (db.font_size / 2))
-- 	frame.right_text:SetPoint("TOPRIGHT", -3, -(db.bar_height / 2) + (db.font_size / 2))
-- 	frame.left_text:SetTextColor(unpack(db.font_color))
-- 	frame.right_text:SetTextColor(unpack(db.font_color))
-- end
-- st.set_fonts = set_fonts

-- local set_bar_size = function()
-- 	local db = ST.db.profile
-- 	local frame = st.bar.frame
-- 	frame:SetWidth(db.bar_width)
-- 	frame:SetHeight(db.bar_height)
-- 	frame.bar:SetWidth(db.bar_width)
-- 	frame.bar:SetHeight(db.bar_height)
-- 	-- frame.gcd_bar:SetWidth(db.bar_width)
-- 	frame.gcd_bar:SetHeight(db.bar_height)
-- 	set_fonts()
-- 	st.set_markers()
-- end

-- local set_marker_widths = function()
-- 	local frame = st.bar.frame
-- 	local db = ST.db.profile
-- 	-- frame.twist_line:SetThickness(db.marker_width)
-- 	frame.gcd1_line:SetThickness(db.marker_width)
-- 	frame.gcd2_line:SetThickness(db.marker_width)
-- 	frame.judgement_line:SetThickness(db.marker_width)
-- end
-- st.set_marker_widths = set_marker_widths

-- local set_marker_colors = function()
-- 	local frame = st.bar.frame
-- 	local db = ST.db.profile
-- 	-- frame.twist_line:SetColorTexture(unpack(ST.db.profile.twist_marker_color))
-- 	frame.gcd1_line:SetColorTexture(unpack(ST.db.profile.gcd_marker_color))
-- 	frame.gcd2_line:SetColorTexture(unpack(ST.db.profile.gcd_marker_color))
-- 	frame.judgement_line:SetColorTexture(unpack(ST.db.profile.judgement_marker_color))
-- end
-- st.set_marker_colors = set_marker_colors

-- st.set_markers = function()
-- 	st.set_marker_colors()
-- 	st.set_marker_widths()
-- 	st.bar.set_marker_offsets()
-- end

-- Function to be called whenever the state of the backdrop or texture
-- outline are changed.
-- function ST:configure_bar_outline()
-- 	local frame = self.mainhand.frame
-- 	local db = self.db.profile
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
--         bgFile = LSM:Fetch('statusbar', db.backplane_texture_key),
-- 		edgeFile = LSM:Fetch('border', texture_key),
--         tile = true, tileSize = 16, edgeSize = 16, 
--         insets = { left = 6, right = 6, top = 6, bottom = 6}
--     }
--     frame.backplane:ApplyBackdrop()

-- 	tv = tv - 2
--     frame.backplane:SetPoint('TOPLEFT', -1*tv, tv)
--     frame.backplane:SetPoint('BOTTOMRIGHT', tv, -1*tv)
-- 	frame.backplane:SetBackdropColor(0,0,0, db.backplane_alpha)

-- end

-- st.set_deadzone = function()
-- 	local db = ST.db.profile
-- 	local f = st.bar.frame.deadzone
--     f:SetTexture(LSM:Fetch('statusbar', db.deadzone_texture_key))
-- 	f:SetVertexColor(unpack(db.bar_color_deadzone))
-- end


------------------------------------------------------------------------------------
-- Now configure the option table for our settings interface.
ST.options = {
	type = "group",
	name = addon_name,
	handler = ST,
	args = {

		------------------------------------------------------------------------------------
		-- top-level settings
		welcome_message = {
			type = "toggle",
			order = 1.1,
			name = "Welcome message",
			desc = "Displays a login message showing the addon version on player login or reload.",
			get = "GetValue",
			set = "SetValue",
		},
		bar_enabled = {
			type = "toggle",
			order = 1,
			name = "Enabled",
			desc = "Enables or disables SwedgeTimer.",
			get = "GetValue",
			set = "SetValue",
		},

		bar_locked = {
			type = "toggle",
			order = 1.12,
			name = "Bar locked",
			desc = "Prevents the swing bar from being dragged with the mouse.",
			get = "GetValue",
			set = function(self, input)
				ST.db.profile.bar_locked = input
				st.bar.frame:SetMovable(not input)
				st.bar.frame:EnableMouse(not input)
			end,
		},

		------------------------------------------------------------------------------------
		-- addon feature behaviour
		bar_behaviour = {
			type = "group",
			name = "Behaviour",
			handler = ST,
			order = 1,
			args = {
				
				------------------------------------------------------------------------------------
				-- Visibility options, when to show the bar.
				autohide_header = {
					type="header",
					order=5.0,
					name="Bar visibility",
				},
				autohide_desc = {
					type="description",
					order=5.01,
					name="Determines under what conditions the bar should be shown.",
				},
				visibility_key = {
					type="select",
					order=5.1,
					name="Visibility",
					desc="The visibility setting to use.",
					values=bar_visibility_values,
					sorting=bar_vis_ordering,
					get = "GetValue",
					set = "SetValue",
				},

				------------------------------------------------------------------------------------
				-- marker options
				marker_settings = {
					order=6,
					type="header",
					name="Marker settings",
				},
				marker_descriptions = {
					order=7,
					type="description",
					name="When GCD offset mode is Dynamic or Fixed, the GCD markers are pushed back "..
					"from the end of the swing to account for player input/lag. When the mode is set to Dynamic, this uses the calibrated lag "..
					"described in Lag Compensation."
				},
				gcd_padding_mode = {
					order=8,
					type="select",
					values=gcd_padding_modes,
					style="dropdown",
					desc="The type of GCD offset, if any, to use.",
					name="GCD offset mode",
					get = "GetValue",
					set = function(self, key)
						ST.db.profile.gcd_padding_mode=key
						st.bar.set_gcd_marker_offsets()
					end,
				},
				gcd_static_padding_ms = {
					type = "range",
					order = 9,
					name = "Fixed GCD offset (ms)",
					desc = "The GCD markers are set at one and two standard GCDs before the swing ends, plus this offset.",
					min = 0, max = 400,
					step = 1,
					get = "GetValue",
					set = function(self, key)
						ST.db.profile.gcd_static_padding_ms = key
						st.bar.set_gcd_marker_offsets()
					end,
					disabled = function()
						return ST.db.profile.gcd_padding_mode ~= "Fixed"
					end,
				},

			},
		},

		------------------------------------------------------------------------------------
		-- Size/position options
		positioning = {
			type = "group",
			name = "Size and Position",
			handler = ST,
			order = 2,
			args = {

				------------------------------------------------------------------------------------
				-- size options
				size_header = {
					type='header',
					name='Size',
					order=1,
				},

				bar_width = {
					type = "range",
					order = 2,
					name = "Width",
					desc = "The width of the swing timer bar.",
					min = 100, max = 600,
					step = 1,
					get = "GetValue",
					set = function(self, key)
						ST.db.profile.bar_width = key
						set_bar_size()
					end,
				},

				bar_height = {
					type = "range",
					order = 3,
					name = "Height",
					desc = "The height of the swing timer bar.",
					min = 6, max = 60,
					step = 1,
					get = "GetValue",
					set = function(self, key)
						ST.db.profile.bar_height = key
						set_bar_size()
					end,
				},

				------------------------------------------------------------------------------------
				-- position options
				position_header = {
					type = 'header',
					name = 'Position',
					order = 4,
				},
				position_description = {
					order=4.1,
					type="description",
					name="When the bar is not locked, it can be clicked and dragged with the mouse.",
				},
				position_description2 = {
					order=4.2,
					type="description",
					name="If you don't understand how UI frames anchor, then either keep both anchors on "..
					"CENTER and enter offsets manually, or position the bar with the mouse.",
				},
				bar_x_offset = {
					type = "input",
					order = 5,
					name = "Bar x offset",
					desc = "The x position of the bar.",
					get = function()
						return tostring(ST.db.profile.bar_x_offset)
					end,
					set = function(self, input)
						ST.db.profile.bar_x_offset = input
						set_bar_position()
					end			
				},
				bar_y_offset = {
					type = "input",
					order = 6,
					name = "Bar y offset",
					desc = "The y position of the bar.",
					get = function()
						return tostring(ST.db.profile.bar_y_offset)
					end,
					set = function(self, input)
						ST.db.profile.bar_y_offset = input
						set_bar_position()
					end			
				},

				bar_point = {
					order = 6.1,
					type="select",
					name = "Anchor",
					desc = "One of the region's anchors.",
					values = valid_anchor_points,
					get = "GetValue",
					set = function(self, input)
						ST.db.profile.bar_point = input
						set_bar_position()
					end,
				},
				bar_rel_point = {
					order = 6.2,
					type="select",
					name = "Relative anchor",
					desc = "Anchor point on region to align against.",
					values = valid_anchor_points,
					get = "GetValue",
					set = function(self, input)
						ST.db.profile.bar_rel_point = input
						set_bar_position()
					end,
				},


				------------------------------------------------------------------------------------
				-- strata/draw level options
				strata_header = {
					type = 'header',
					name = 'Frame Strata',
					order = 7.0,
				},
				strata_description = {
					type = 'description',
					name = 'The frame strata the addon should be drawn at. Anything higher than MEDIUM '..
                    'will be drawn over some in-game menus, so this is the highest strata allowed.',
					order = 7.1,
				},
				frame_strata = {
					order = 7.2,
					type="select",
					name = "Frame strata",
					desc = "The frame strata the addon should be drawn at.",
					values = {
						BACKGROUND = "BACKGROUND",
						LOW = "LOW",
						MEDIUM = "MEDIUM",
					},
					get = "GetValue",
					set = function(self, input)
						ST.db.profile.frame_strata = input
						st.bar.frame:SetFrameStrata(input)
						st.bar.frame.backplane:SetFrameStrata(input)
					end,
				},
				draw_level = {
					type = "range",
					order = 7.3,
					name = "Draw level",
					desc = "The bar's draw level within the frame strata.",
					min = 1, max=100,
					step=1,
					get = "GetValue",
					set = function(self, input)
						ST.db.profile.draw_level = input
						st.bar.frame:SetFrameLevel(input+1)
						st.bar.frame.backplane:SetFrameLevel(input)
					end
				},

			},
		},

		------------------------------------------------------------------------------------
		-- All appearance options
		bar_appearance = {
			type = "group",
			name = "Appearance",
			handler = ST,
			order = 3,
			args = {

				------------------------------------------------------------------------------------
				-- texture options
				texture_header = {
					order=1,
					type="header",
					name="Textures",
				},
				bar_texture_key = {
					order = 2,
					type = "select",
					name = "Bar",
					desc = "The texture of the swing bar.",
					dialogControl = "LSM30_Statusbar",
					values = LSM:HashTable("statusbar"),
					get = function(info) return ST.db.profile.bar_texture_key or LSM.DefaultMedia.statusbar end,
					set = function(self, key)
						ST.db.profile.bar_texture_key = key
						st.bar.frame.bar:SetTexture(LSM:Fetch('statusbar', key))
					end
				},
				
				gcd_texture_key = {
					order = 2.1,
					type = "select",
					name = "GCD underlay",
					desc = "The texture of the GCD underlay bar.",
					dialogControl = "LSM30_Statusbar",
					values = LSM:HashTable("statusbar"),
					get = function(info) return ST.db.profile.gcd_texture_key or LSM.DefaultMedia.statusbar end,
					set = function(self, key)
						ST.db.profile.gcd_texture_key = key
						st.bar.frame.gcd_bar:SetTexture(LSM:Fetch('statusbar', key))
						st.bar.set_gcd_bar_width()
					end
				},

				backplane_texture_key = {
					order = 2.2,
					type = "select",
					name = "Backplane",
					desc = "The texture of the bar's backplane.",
					dialogControl = "LSM30_Statusbar",
					values = LSM:HashTable("statusbar"),
					get = function(info) return ST.db.profile.backplane_texture_key or
                        LSM.DefaultMedia.statusbar end,
					set = function(self, key)
						ST.db.profile.backplane_texture_key = key
						st.bar.frame.backplane.backdropInfo.bgFile = LSM:Fetch('statusbar', key)
						st.bar.frame.backplane:ApplyBackdrop()
						st.bar.frame.backplane:SetBackdropColor(0,0,0, ST.db.profile.backplane_alpha)
					end
				},

				backplane_alpha = {
					type = "range",
					order = 2.3,
					name = "Backplane alpha",
					desc = "The opacity of the swing bar's backplane.",
					min = 0.0, max = 1.0,
					step = 0.05,
					get = "GetValue",
					set = function(self, key)
						ST.db.profile.backplane_alpha = key
						st.bar.frame.backplane:SetBackdropColor(0, 0, 0, key)
					end,
				},


				------------------------------------------------------------------------------------
				-- Border options
				bar_border_header = {
					order=3.5,
					type="header",
					name="Bar border",
				},
				bar_border_description = {
					order=3.51,
					type="description",
					name="The bar border can either be set to a solid color, a texture, or disabled.",
				},

				border_mode_key = {
					order=3.6,
					type="select",
					values=bar_border_modes,
					style="dropdown",
					desc="The outline mode to use for the bar border, if any.",
					name="Border mode",
					get = "GetValue",
					set = function(self, key)
						ST.db.profile.border_mode_key = key
						st.configure_bar_outline()
				
					end,
				},

				placeholder_1 = {
					type="description",
					order = 3.8,
					name = "",
				},

				backplane_outline_width = {
					type = "range",
					order = 5.1,
					name = "Solid outline thickness",
					desc = "The thickness of the outline around the swing timer bar, if in Solid border mode.",
					min = 0, max = 5,
					step = 0.2,
					get = "GetValue",
					set = function(self, key)
						ST.db.profile.backplane_outline_width = key
						st.configure_bar_outline()
					end,
					disabled = function()
						return ST.db.profile.border_mode_key ~= "Solid"
					end,
				},

				border_texture_key = {
					order = 6,
					type = "select",
					name = "Border",
					desc = "The border texture of the swing bar.",
					dialogControl = "LSM30_Border",
					values = LSM:HashTable("border"),
					get = function(info) return ST.db.profile.border_texture_key or LSM.DefaultMedia.border end,
					set = function(self, key)
						ST.db.profile.border_texture_key = key
						st.configure_bar_outline()
					end,
					disabled = function()
						return ST.db.profile.border_mode_key ~= "Texture"
					end,
				},

				------------------------------------------------------------------------------------
				-- font settings
				fonts_header = {
					order=9,
					type="header",
					name="Fonts",
				},
				font_size = {
					type = "range",
					order = 9.03,
					name = "Font size",
					desc = "The size of the swing timer and attack speed fonts.",
					min = 10, max = 40, softMin = 8, softMax = 24,
					step = 1,
					get = "GetValue",
					set = function(self, key)
						ST.db.profile.font_size = key
						set_fonts()
					end,
				},
				font_color = {
					order=9.04,
					type="color",
					name="Font color",
					desc="The color of the addon texts.",
					hasAlpha=false,
					get = function()
						return unpack(ST.db.profile.font_color)
					end,
					set = function(self,r,g,b,a)
						ST.db.profile.font_color = {r,g,b,a}
						set_fonts()
					end
				},
				text_font = {
					order = 9.01,
					type = "select",
					name = "Font",
					desc = "The font to use in the swing timer and attack speed text.",
					dialogControl = "LSM30_Font",
					values = LSM:HashTable("font"),
					get = function(info) return ST.db.profile.text_font or LSM.DefaultMedia.font end,
					set = function(self, key)
						ST.db.profile.text_font = key
						set_fonts()
					end
				},
				font_outline_key = {
					order=9.02,
					type="select",
					values=outlines,
					style="dropdown",
					desc="The outline type to use with the font.",
					name="Font outline",
					get = "GetValue",
					set = function(self, key)
						ST.db.profile.font_outline_key = key
						set_fonts()
					end,
				},
				left_text = {
					type="select",
					order = 9.1,
					values=texts,
					style="dropdown",
					name = "Left text",
					desc = "What to shows on the left of the swing timer bar.",
					get = "GetValue",
					set = function(self, key)
						ST.db.profile.left_text = key
						-- set_texts()
					end
				},
				right_text = {
					type="select",
					order = 9.1,
					values=texts,
					style="dropdown",
					name = "Right text",
					desc = "What to shows on the right of the swing timer bar.",
					get = "GetValue",
					set = function(self, key)
						ST.db.profile.right_text = key
						-- set_texts()
					end,
				},
				
				------------------------------------------------------------------------------------
				-- Contextual color settings
				context_colors_header = {
					type="header",
					order = 10,
					name = "Contextual bar colors",
				},
				bar_color_default = {
					order=11,
					type="color",
					name="No seal",
					desc="No seal active on the player.",
					hasAlpha=false,
					get = function()
						local tab = ST.db.profile.bar_color_default
						return tab[1], tab[2], tab[3], tab[4]
					end,
					set = function(self,r,g,b,a)
						ST.db.profile.bar_color_default = {r,g,b,a}
						st.bar.set_bar_color()
					end
				},
	
				------------------------------------------------------------------------------------
				-- GCD settings
				gcd_header = {
					order=30,
					type="header",
					name="GCD underlay",
				},
				bar_color_gcd = {
					order=31,
					type="color",
					name="Underlay color",
					desc="The color of the GCD underlay.",
					hasAlpha=true,
					get = function()
						local tab = ST.db.profile.bar_color_gcd
						return tab[1], tab[2], tab[3], tab[4]
					end,
					set = function(self,r,g,b,a)
						ST.db.profile.bar_color_gcd = {r,g,b,a}
						st.bar.frame.gcd_bar:SetVertexColor(unpack(ST.db.profile.bar_color_gcd))
					end
				},

				------------------------------------------------------------------------------------
				-- Marker appearance settings
				markers_header = {
					order=50,
					type="header",
					name="Markers",
				},
				gcd1_enabled = {
					type = "toggle",
					order = 50.1,
					name = "Enable GCD marker 1",
					desc = "Toggles drawing the first GCD marker on the bar.",
					get = "GetValue",
					set = function(self, key)
						ST.db.profile.gcd1_enabled = key
						st.bar.show_or_hide_ticks()
					end,
				},
				gcd2_enabled = {
					type = "toggle",
					order = 50.2,
					name = "Enable GCD marker 2",
					desc = "Toggles drawing the second GCD marker on the bar.",
					get = "GetValue",
					set = function(self, key)
						ST.db.profile.gcd2_enabled = key
						st.bar.show_or_hide_ticks()
					end,
				},
				marker_width = {
					type = "range",
					order = 55,
					name = "Marker width",
					desc = "The width of the twist window GCD, and judgement markers.",
					min = 1, max = 6,
					step = 1,
					get = "GetValue",
					set = function(self, key)
						ST.db.profile.marker_width = key
						set_marker_widths()
					end,
				},
				gcd_marker_color = {
					order=53,
					type="color",
					name="GCD color",
					desc="The color of the GCD markers.",
					hasAlpha=false,
					get = function()
						return unpack(ST.db.profile.gcd_marker_color)
					end,
					set = function(self,r,g,b,a)
						ST.db.profile.gcd_marker_color = {r,g,b,a}
						set_marker_colors()
					end
				},
			}
		},
	}
}

function ST:GetValue(info)
	return self.db.profile[info[#info]]
end

function ST:SetValue(info, value)
	self.db.profile[info[#info]] = value
end

--=========================================================================================
-- End, if debug verify module was read.
--=========================================================================================
if st.debug then print('-- Parsed config.lua module correctly') end
