local addon_name, st = ...
local SwedgeTimer = LibStub("AceAddon-3.0"):NewAddon(addon_name, "AceEvent-3.0", "AceConsole-3.0")
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local SML = LibStub("LibSharedMedia-3.0")
local print = st.utils.print_msg


function SwedgeTimer:OnInitialize()
	-- uses the "Default" profile instead of character-specific profiles
	-- https://www.wowace.com/projects/ace3/pages/api/ace-db-3-0
	SwedgeTimerDB = LibStub("AceDB-3.0"):New("SwedgeTimerDB", self.defaults, true)
	self.db = SwedgeTimerDB

	-- registers an options table and adds it to the Blizzard options window
	-- https://www.wowace.com/projects/ace3/pages/api/ace-config-3-0
	AC:RegisterOptionsTable("SwedgeTimer_Options", self.options)
	self.optionsFrame = ACD:AddToBlizOptions("SwedgeTimer_Options", "SwedgeTimer")

	-- adds a child options table, in this case our profiles panel
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	AC:RegisterOptionsTable("SwedgeTimer_Profiles", profiles)
	ACD:AddToBlizOptions("SwedgeTimer_Profiles", "Profiles", "SwedgeTimer")

	-- https://www.wowace.com/projects/ace3/pages/api/ace-console-3-0
	self:RegisterChatCommand("st", "SlashCommand")
	self:RegisterChatCommand("swedgetimer", "SlashCommand")

	-- self:GetCharacterInfo()
end

function SwedgeTimer:OnEnable()
	
	-- Sort out character information
	st.player.get_twohand_spec_points()
	st.player.guid = UnitGUID("player")
	st.player.weapon_id = GetInventoryItemID("player", 16)


	-- print("Talent points on load says: "..tostring(select(5,GetTalentInfo(3, 13))))

	-- self:RegisterEvent("PLAYER_STARTED_MOVING")
end

-- function SwedgeTimer:PLAYER_STARTED_MOVING(event)
-- 	print(event)
-- end

-- function SwedgeTimer:GetCharacterInfo()
-- 	-- stores character-specific data
-- 	self.db.char.level = UnitLevel("player")
-- end

function SwedgeTimer:SlashCommand(input, editbox)
    -- if input == "bar" then
    --     st.bar.TwistBarToggle()
    -- elseif input == "lock" then
    --     st.bar.TwistBarLockToggle()
	-- if input == "enable" then
	-- 	self:Enable()
	-- 	self:Print("Enabled.")
	-- elseif input == "disable" then
	-- 	-- unregisters all events and calls SwedgeTimer:OnDisable() if you defined that
	-- 	self:Disable()
	-- 	self:Print("Disabled.")
	-- elseif input == "message" then
	-- 	print("this is our saved message:", self.db.profile.someInput)
	-- else
		-- self:Print("Some useful help message.")

		-- https://github.com/Stanzilla/WoWUIBugs/issues/89
		-- InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
		-- InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)

		ACD:Open("SwedgeTimer_Options")


		--[[ or as a standalone window
		if ACD.OpenFrames["SwedgeTimer_Options"] then
			ACD:Close("SwedgeTimer_Options")
		else
			ACD:Open("SwedgeTimer_Options")
		end
		]]
	-- end
end

------------------------------------------------------------------------------------
-- Default settings for the addon.
SwedgeTimer.defaults = {
    profile = {

		-- Top level
		welcome_message = true,
		bar_enabled = true,

		-- Behaviour toggles
		lag_detection_enabled = true,
        hide_bar_when_inactive = true,
		judgement_marker_enabled = true,
        bar_twist_color_enabled = true,
		hide_when_not_ret = true,

		-- Lag calibration
		lag_multiplier = 1.2,
		lag_offset = 10,

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

		-- Bar textures
        bar_texture_key = SML.DefaultMedia.statusbar,
        gcd_texture_key = SML.DefaultMedia.statusbar,
        backplane_texture_key = SML.DefaultMedia.statusbar,
		backplane_alpha = 0.85,
        
		backplane_outline_offset = 10,
		backplane_outline_name = "Medium",

		-- Font settings
		font_size = 16,
		font_color = {1.0, 1.0, 1.0, 1.0},
		text_font = SML.DefaultMedia.font,       
        show_attack_speed_text = true,
        show_swing_timer_text = true,

		-- Marker settings
		marker_width = 3,
		gcd_marker_color = {0.2, 0.3, 0.2, 1.0},
		twist_marker_color = {0.9,0.9,0.9,1.0},
		judgement_marker_color = {0.9,0.9,0.01,1.0},

		-- Seal color settings
        bar_color_blood = {0.7, 0.27, 0.0, 1.0},
		bar_color_command = {0., 0.68, 0., 1.0},
		bar_color_wisdom = {0., 0.4, 0.7, 1.0},
		bar_color_light = {0., 0.8, 0.4, 1.0},
		bar_color_justice = {0.8, 0.1, 0.7, 1.0},
		bar_color_vengeance = {0.8, 0.5, 0.4, 1.0},
		bar_color_righteousness = {0., 0.68, 0., 1.0},
		bar_color_crusader = {0.5, 0.9, 0.9, 1.0},


		-- Special bar colors
        bar_color_cant_twist = {0.7, 0.7, 0.01, 1.0},
        bar_color_warning = {1.0, 0.0, 0.0, 1.0}, -- when if you cast SoC, you can't twist out of it that swing
        bar_color_twisting = {0.7,0.1,0.6,1.0},
		bar_color_default = {0.5, 0.5, 0.5, 1.0},

		-- GCD underlay bar colors
		bar_color_gcd = {0.3, 0.3, 0.3, 1.0},

    },

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

st.bar_outline_names = {
	None="None",
	Thin="Thin",
	Medium="Medium",
	Thick="Thick",
	Thicc="Thicc",
}

st.bar_outline_thicknesses = {
	None=8,
	Thin=9,
	Medium=10,
	Thick=11,
	Thicc=12,
}

st.get_thickness_value = function()
	local db = SwedgeTimer.db.profile
	return db.backplane_outline_offset
end

local MediaList = {}
local function getMediaData(info)
    local mediaType = info[#(info)]

    MediaList[mediaType] = MediaList[mediaType] or {}

    for k in pairs(MediaList[mediaType]) do MediaList[mediaType][k] = nil end
    for _, name in pairs(SML:List(mediaType)) do
        MediaList[mediaType][name] = name
    end

    return MediaList[mediaType]
end


------------------------------------------------------------------------------------
-- Functions to apply settings to the UI elements.
local set_bar_position = function()
	local db = SwedgeTimer.db.profile
	local frame = st.bar.frame
	frame:ClearAllPoints()
	frame:SetPoint(db.bar_point, UIParent, db.bar_rel_point, db.bar_x_offset, db.bar_y_offset)
	frame.bar:SetPoint("TOPLEFT", 0, 0)
	frame.bar:SetPoint("TOPLEFT", 0, 0)
	frame.gcd_bar:SetPoint("TOPLEFT", 0, 0)
	frame.left_text:SetPoint("TOPLEFT", 2, -(db.bar_height / 2) + (db.font_size / 2))
	frame.right_text:SetPoint("TOPRIGHT", 2, -(db.bar_height / 2) + (db.font_size / 2))
	st.set_outline_thickness()
end
st.set_bar_position = set_bar_position


local set_fonts = function()
	local db = SwedgeTimer.db.profile
	local frame = st.bar.frame
	local font_path = SML:Fetch('font', db.text_font)
	-- print(font_path)
	frame.left_text:SetFont(font_path, db.font_size, "OUTLINE")
	frame.right_text:SetFont(font_path, db.font_size, "OUTLINE")
	frame.left_text:SetPoint("TOPLEFT", 2, -(db.bar_height / 2) + (db.font_size / 2))
	frame.right_text:SetPoint("TOPRIGHT", 2, -(db.bar_height / 2) + (db.font_size / 2))
	frame.left_text:SetTextColor(unpack(db.font_color))
	frame.right_text:SetTextColor(unpack(db.font_color))
end
st.set_fonts = set_fonts

local set_bar_size = function()
	local db = SwedgeTimer.db.profile
	local frame = st.bar.frame
	frame:SetWidth(db.bar_width)
	frame:SetHeight(db.bar_height)
	frame.bar:SetWidth(db.bar_width)
	frame.bar:SetHeight(db.bar_height)
	frame.gcd_bar:SetWidth(db.bar_width)
	frame.gcd_bar:SetHeight(db.bar_height)
	set_fonts()
end

local set_marker_widths = function()
	local frame = st.bar.frame
	local db = SwedgeTimer.db.profile
	frame.twist_line:SetThickness(db.marker_width)
	frame.gcd1_line:SetThickness(db.marker_width)
	frame.gcd2_line:SetThickness(db.marker_width)
	frame.judgement_line:SetThickness(db.marker_width)
end
st.set_marker_widths = set_marker_widths

local set_marker_colors = function()
	local frame = st.bar.frame
	local db = SwedgeTimer.db.profile
	frame.twist_line:SetColorTexture(unpack(SwedgeTimer.db.profile.twist_marker_color))
	frame.gcd1_line:SetColorTexture(unpack(SwedgeTimer.db.profile.gcd_marker_color))
	frame.gcd2_line:SetColorTexture(unpack(SwedgeTimer.db.profile.gcd_marker_color))
	frame.judgement_line:SetColorTexture(unpack(SwedgeTimer.db.profile.judgement_marker_color))
end
st.set_marker_colors = set_marker_colors

st.set_markers = function()
	st.set_marker_colors()
	st.set_marker_widths()
end

st.set_outline_thickness = function()
	local db = SwedgeTimer.db.profile
	local val = SwedgeTimer.db.profile.backplane_outline_offset
	-- print(val)
	st.bar.frame.backplane:SetPoint('TOPLEFT', -1*val, val)
	st.bar.frame.backplane:SetPoint('BOTTOMRIGHT', val, -1*val)
end

------------------------------------------------------------------------------------
-- Now configure the option table for our settings interface.
SwedgeTimer.options = {
	type = "group",
	name = "SwedgeTimer",
	handler = SwedgeTimer,
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

		------------------------------------------------------------------------------------
		-- addon feature behaviour
		bar_behaviour = {
			type = "group",
			name = "Behaviour",
			handler = SwedgeTimer,
			order = 1,
			args = {
				hide_bar_when_inactive = {
					type = "toggle",
					order = 1,
					name = "Auto-hide bar",
					desc = "When enabled, hides the bar when there is no active seal or the player is out of combat.",
					get = "GetValue",
					set = "SetValue",
				},
				hide_when_not_ret = {
					type = "toggle",
					order = 1,
					name = "Hide when not Ret",
					desc = "When enabled, hides the bar when the player is not specced as retribution (determined by the presence of any "..
					"points in the Two-handed Weapon Specialization talent).",
					get = "GetValue",
					set = "SetValue",
				},
				judgement_marker_enabled = {
					type = "toggle",
					order = 2,
					name = "Judgement Marker",
					desc = "When enabled, indicates where on the swing timer judgement will come off cooldown (if in "..
					"a high value spell to judge like Seal of Blood).",
					get = "GetValue",
					set = "SetValue",
				},
				bar_twist_color_enabled = {
					type="toggle",
					order=4,
					name="Twist color",
					desc="When the player is actively twisting, and two seals are active, the bar will turn a special color "..
					"dictated in the settings.",
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
					"from the end of the swing to account for player input/lag. When the mode is set to Dynamic, this value uses the calibrated lag "..
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
						SwedgeTimer.db.profile.gcd_padding_mode=key
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
						SwedgeTimer.db.profile.gcd_static_padding_ms = key
						st.bar.set_gcd_marker_offsets()
					end,
					disabled = function()
						return SwedgeTimer.db.profile.gcd_padding_mode ~= "Fixed"
					end,
				},

				twist_window_descriptions = {
					order=10.1,
					type="description",
					name="When Twist window offset mode is Dynamic or Fixed, the twist window marker is pushed back "..
					"from the end of the swing to account for player input/lag. When the mode is set to Dynamic, this value uses the calibrated lag "..
					"described in Lag Compensation."
				},
				twist_padding_mode = {
					order=10.2,
					type="select",
					values=gcd_padding_modes,
					style="dropdown",
					desc="The type of twist window offset, if any, to use.",
					name="Twist window offset mode",
					get = "GetValue",
					-- set = "SetValue",
					set = function(self, key)
						SwedgeTimer.db.profile.twist_padding_mode = key
						st.bar.set_twist_tick_offset()
					end,

				},
				twist_window_padding_ms = {
					type = "range",
					order = 10.3,
					name = "Fixed twist offset (ms)",
					desc = "The time before the end of the swing that the twist indicator marker will be placed. Players with high "..
					"latency may wish to increase this value.",
					min = 0, max=400,
					step=1,
					get = "GetValue",
					set = function(self, key)
						SwedgeTimer.db.profile.twist_window_padding_ms = key
						st.bar.set_twist_tick_offset()
					end
					,
					disabled = function()
						return SwedgeTimer.db.profile.twist_padding_mode ~= "Fixed"
					end,
				},
			},
		},

		------------------------------------------------------------------------------------
		-- Lag detection
		lag_detection_section= {
			type = "group",
			name = "Lag Compensation",
			handler = SwedgeTimer,
			order = 2,			
			args = {
				lag_settings = {
					order=5.01,
					type="header",
					name="What is lag compensation?",
				},
				lag_descriptions1 = {
					order=5.02,
					type="description",
					name="Many Ret players are familiar with attempting a close twist after a GCD, only to swing in command.",
				},
				lag_descriptions101 = {
					order=5.03,
					type="description",
					image="Interface/AddOns/SwedgeTimer/Images/close_twist4.tga",
					imageWidth=350,
					imageHeight=350*0.2,
					imageCoords={0.00,1.0,0.4,0.6},
					name="",
				},
				lag_descriptions1001 = {
					order=5.031,
					type="description",
					name="In the above image, the player is in SoC, and has a small amount of time after their GCD ends to cast SoB."..
					" Even with spell queueing, if the player's lag is high enough, the SoB cast can be pushed into the next swing.",
				},
				lag_descriptions102 = {
					order=5.04,
					type="description",
					name="SwedgeTimer includes a lag compensation suite, that detects instances where the player will not be "..
					"able to twist before their swing goes off due to lag.",
				},
				lag_descriptions103 = {
					order=5.05,
					type="description",
					name="",
					image="Interface/AddOns/SwedgeTimer/Images/dont_twist1.blp",
					imageWidth=350,
					imageHeight=350*0.2,
					imageCoords={0.00,1.0,0.4,0.6},
					name="",
				},
				lag_descriptions104 = {
					order=5.06,
					type="description",
					name="If you see the bar turn the color specified above, don't try to twist; either ride the command swing and cast "..
					"a filler spell like Consecration, or momentarily stopattack before SoB/startattacking.",
				},

				lag_detection_enabled = {
					type = "toggle",
					order = 4.1,
					name = "Lag compensation",
					desc = "When enabled, the swing timer bar turns a special colour when the player is in Seal of Command"..
					" and the time remaining to cast a spell at the end of their GCD is lower than the current lag.",
					get = "GetValue",
					set = "SetValue",
					},
				bar_color_cant_twist = {
					order=4.2,
					type="color",
					name="Bar color",
					desc="The color the bar turns when the player is in a good seal to twist from, but "..
					"their GCD combined with their lag will mean they cannot twist this swing unless they stopattack.",
					hasAlpha=false,
					get = function()
						local tab = SwedgeTimer.db.profile.bar_color_cant_twist
						return tab[1], tab[2], tab[3], tab[4]
					end,
					set = function(self,r,g,b,a)
						SwedgeTimer.db.profile.bar_color_cant_twist = {r,g,b,a}
					end
				},
				lag_descriptions2001 = {
					order=5.20,
					type="header",
					name="How it works",
				},
				lag_descriptions_20002 = {
					order=5.201,
					type="description",
					name="To detect impossible twists, we compare the time left on the player's swing after the GCD expires to some value representing "..
					"the lag. If the time left after GCD is lower than this lag value, the lag compensation is triggered.",
				},
				lag_descriptions_2002 = {
					order=5.21,
					type="description",
					name="The player's raw lag is often not the most accurate predictor of impossible twists. Instead of using the raw lag, we "..
					"adjust the lag according to the settings below for the best result. SwedgeTimer is pre-calibrated, but everyone's connection is different, "..
					"and optimal settings may vary among players."
				},

				lag_descriptions3001 = {
					order=6.0,
					type="header",
					name="Do I need to calibrate?",
				},
				lag_descriptions_3002 = {
					order=6.22,
					type="description",
					name="To see if you require calibration, simply try some close twists on a target. Cast any spell when the bar is approaching the middle GCD marker, and try to twist your swing."..
					" if the special bar color triggers only when you get command swings, and you are able to twist all swings where the bar color does not trigger, you are calibrated correctly."..
					" If not, you may need to change the settings below.",
				},
				lag_descriptions4001 = {
					order=7.0,
					type="header",
					name="Calibration settings",
				},
				lag_descriptions_2 = {
					order=7.22,
					type="description",
					name="The figure compared to the swing time remaining after GCD is equal to (ax + b), where x is the raw latency, a is the multipler, and b is the offset.",
				},
				lag_descriptions_22 = {
					order=7.23,
					type="description",
					name="If the special bar color is not triggering when you're forced into command swings, increase the multiplier or the threshold a small amount and try again.",
				},
				lag_descriptions_23 = {
					order=7.24,
					type="description",
					name="If the special bar color is triggering when you are able to twist, reduce the multipler or the threshold by a small amount and try again.",
				},
				-- lag_descriptions_2 = {
				-- 	order=7.23,
				-- 	type="description",
				-- 	name=""
				-- },
				lag_multiplier = {
					type = "range",
					order = 7.3,
					name = "Lag multiplier",
					desc = "The player's world trip latency is multiplied by this value in the lag detection calibration.",
					min = 0, max = 2.0,
					step = 0.05,
					get = "GetValue",
					set = function(self, key)
						SwedgeTimer.db.profile.lag_multiplier = key
						st.bar.set_gcd_marker_offsets()
						st.bar.set_twist_tick_offset()
					end,
				},
				lag_offset = {
					type = "range",
					order = 7.3,
					name = "Lag offset (ms)",
					desc = "The player's world trip latency has this value added to it in the lag detection calibration.",
					min = 0, max = 200,
					step = 1,
					get = "GetValue",
					set = function(self, key)
						SwedgeTimer.db.profile.lag_offset = key
						st.bar.set_gcd_marker_offsets()
						st.bar.set_twist_tick_offset()
					end,
				},
			},
		},

		------------------------------------------------------------------------------------
		-- Size/position options
		positioning = {
			type = "group",
			name = "Size and Position",
			handler = SwedgeTimer,
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
						SwedgeTimer.db.profile.bar_width = key
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
						SwedgeTimer.db.profile.bar_height = key
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
				bar_x_offset = {
					type = "input",
					order = 5,
					name = "Bar x offset",
					desc = "The x position of the bar.",
					get = function()
						return tostring(SwedgeTimer.db.profile.bar_x_offset)
					end,
					set = function(self, input)
						SwedgeTimer.db.profile.bar_x_offset = input
						set_bar_position()
					end			
				},
				bar_y_offset = {
					type = "input",
					order = 6,
					name = "Bar y offset",
					desc = "The y position of the bar.",
					get = function()
						return tostring(SwedgeTimer.db.profile.bar_y_offset)
					end,
					set = function(self, input)
						SwedgeTimer.db.profile.bar_y_offset = input
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
						SwedgeTimer.db.profile.bar_point = input
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
						SwedgeTimer.db.profile.bar_rel_point = input
						set_bar_position()
					end,
				},
				bar_locked = {
					type = "toggle",
					order = 7,
					name = "Bar locked",
					desc = "Prevents the swing bar from being dragged with the mouse.",
					get = "GetValue",
					set = "SetValue",
				},
			}
		},

		------------------------------------------------------------------------------------
		-- All appearance options
		bar_appearance = {
			type = "group",
			name = "Appearance",
			handler = SwedgeTimer,
			order = 3,
			args = {

				------------------------------------------------------------------------------------
				-- texture options
				texture_header = {
					order=1,
					type="header",
					name="Textures",
				},
				bar_texture = {
					order = 2,
					type = "select",
					name = "Bar",
					desc = "test description",
					dialogControl = "LSM30_Statusbar",
					-- values = getMediaData,
					values = SML:HashTable("statusbar"),
					get = function(info) return SwedgeTimer.db.profile.bar_texture or SML.DefaultMedia.statusbar end,
					set = function(self, key)
						SwedgeTimer.db.profile.bar_texture = key
						st.bar.frame.bar:SetTexture(SML:Fetch('statusbar', key))
					end
				},
				
				gcd_texture = {
					order = 3,
					type = "select",
					name = "GCD underlay",
					dialogControl = "LSM30_Statusbar",
					-- values = getMediaData,
					values = SML:HashTable("statusbar"),
					get = function(info) return SwedgeTimer.db.profile.gcd_texture or SML.DefaultMedia.statusbar end,
					set = function(self, key)
						SwedgeTimer.db.profile.gcd_texture = key
						st.bar.frame.gcd_bar:SetTexture(SML:Fetch('statusbar', key))
					end
				},
		
				backplane_texture = {
					order = 4,
					type = "select",
					name = "Backplane",
					dialogControl = "LSM30_Statusbar",
					-- values = getMediaData,
					values = SML:HashTable("statusbar"),
					get = function(info) return SwedgeTimer.db.profile.backplane_texture_key or SML.DefaultMedia.statusbar end,
					set = function(self, key)
						SwedgeTimer.db.profile.backplane_texture_key = key
						st.bar.frame.backplane.backdropInfo.bgFile = SML:Fetch('statusbar', key)
						st.bar.frame.backplane:ApplyBackdrop()
						st.bar.frame.backplane:SetBackdropColor(0,0,0, SwedgeTimer.db.profile.backplane_alpha)
					end
				},
				backplane_alpha = {
					type = "range",
					order = 5,
					name = "Backplane alpha",
					desc = "The opacity of the swing bar's backplane.",
					min = 0.0, max = 1.0,
					step = 0.05,
					get = "GetValue",
					set = function(self, key)
						SwedgeTimer.db.profile.backplane_alpha = key
						st.bar.frame.backplane:SetBackdropColor(0, 0, 0, key)
					end,
				},
				backplane_outline_offset = {
					type = "select",
					order = 5.1,
					name = "Outline",
					desc = "The thickness of the outline around the swing timer bar.",
					values=st.bar_outline_names,
					sorting={"None", "Thin", "Medium", "Thick", "Thicc"},
					get = function() return tostring(SwedgeTimer.db.profile.backplane_outline_name) end,
					set = function(self, key)
						SwedgeTimer.db.profile.backplane_outline_name = key
						local val = st.bar_outline_thicknesses[key]
						SwedgeTimer.db.profile.backplane_outline_offset = val
						-- print(val)
						st.bar.frame.backplane:SetPoint('TOPLEFT', -1*val, val)
						st.bar.frame.backplane:SetPoint('BOTTOMRIGHT', val, -1*val)
					end
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
					order = 9.02,
					name = "Font size",
					desc = "The size of the swing timer and attack speed fonts.",
					min = 10, max = 40, softMin = 8, softMax = 24,
					step = 1,
					get = "GetValue",
					set = function(self, key)
						SwedgeTimer.db.profile.font_size = key
						set_fonts()
					end,
				},
				font_color = {
					order=9.9,
					type="color",
					name="Font color",
					desc="The color of the addon texts.",
					hasAlpha=false,
					get = function()
						return unpack(SwedgeTimer.db.profile.font_color)
					end,
					set = function(self,r,g,b,a)
						SwedgeTimer.db.profile.font_color = {r,g,b,a}
						set_fonts()
					end
				},
				text_font = {
					order = 9.01,
					type = "select",
					name = "Font",
					desc = "The font to use in the swing timer and attack speed text.",
					dialogControl = "LSM30_Font",
					-- values = getMediaData,
					values = SML:HashTable("font"),
					get = function(info) return SwedgeTimer.db.profile.text_font or SML.DefaultMedia.font end,
					set = function(self, key)
						SwedgeTimer.db.profile.text_font = key
						set_fonts()
					end
				},
				show_attack_speed_text = {
					type="toggle",
					order = 9.1,
					name = "Attack speed text",
					desc = "Shows the player's current attack speed at the left of the swing timer bar.",
					get = "GetValue",
					set = function(self, key)
						SwedgeTimer.db.profile.show_attack_speed_text = key
						if key then
							st.bar.frame.left_text:Show()
						else
							st.bar.frame.left_text:Hide()
						end
					end,
				},
				show_swing_timer_text = {
					type="toggle",
					order = 9.12,
					name = "Swing timer text",
					desc = "Shows the remaining time on the player's swing on the right of the swing bar.",
					get = "GetValue",
					set = function(self, key)
						SwedgeTimer.db.profile.show_swing_timer_text = key
						if key then
							st.bar.frame.right_text:Show()
						else
							st.bar.frame.right_text:Hide()
						end
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
						local tab = SwedgeTimer.db.profile.bar_color_default
						return tab[1], tab[2], tab[3], tab[4]
					end,
					set = function(self,r,g,b,a)
						SwedgeTimer.db.profile.bar_color_default = {r,g,b,a}
						st.bar.set_bar_color()
					end
				},
				bar_color_twisting = {
					order=12,
					type="color",
					name="Active twist",
					desc="The player is mid-twist and has multiple seals active.",
					hasAlpha=false,
					get = function()
						local tab = SwedgeTimer.db.profile.bar_color_twisting
						return tab[1], tab[2], tab[3], tab[4]
					end,
					set = function(self,r,g,b,a)
						SwedgeTimer.db.profile.bar_color_twisting = {r,g,b,a}
						st.bar.set_bar_color()
					end
				},
				bar_color_warning = {
					order=13,
					type="color",
					name="Don't cast",
					desc="The color the bar turns when the player is in a good seal to twist from, but "..
					"does not have time to incur a GCD before their swing completes.",
					hasAlpha=false,
					get = function()
						local tab = SwedgeTimer.db.profile.bar_color_warning
						return tab[1], tab[2], tab[3], tab[4]
					end,
					set = function(self,r,g,b,a)
						SwedgeTimer.db.profile.bar_color_warning = {r,g,b,a}
					end
				},
				-- bar_color_cant_twist = {
				-- 	order=14,
				-- 	type="color",
				-- 	name="Can't twist (lag)",
				-- 	desc="The color the bar turns when the player is in a good seal to twist from, but "..
				-- 	"their GCD combined with their lag will mean they cannot twist this swing unless they stopattack.",
				-- 	hasAlpha=false,
				-- 	get = function()
				-- 		local tab = SwedgeTimer.db.profile.bar_color_cant_twist
				-- 		return tab[1], tab[2], tab[3], tab[4]
				-- 	end,
				-- 	set = function(self,r,g,b,a)
				-- 		SwedgeTimer.db.profile.bar_color_cant_twist = {r,g,b,a}
				-- 	end
				-- },

				------------------------------------------------------------------------------------
				-- Seal color settings
				seal_colors_header = {
					order=20,
					type="header",
					name="Seal colors",
				},



				bar_color_command = {
					order=21,
					type="color",
					name="Command",
					desc="Seal of Command (will turn the \"Don\'t Cast\" color when the player should not cast and wait to twist).",
					hasAlpha=false,
					get = function()
						local tab = SwedgeTimer.db.profile.bar_color_command
						return tab[1], tab[2], tab[3], tab[4]
					end,
					set = function(self,r,g,b,a)
						SwedgeTimer.db.profile.bar_color_command = {r,g,b,a}
						st.bar.set_bar_color()
					end
				},
				bar_color_righteousness = {
					order=22,
					type="color",
					name="Righteousness",
					desc="Seal of Righteousness (will turn the \"Don\'t Cast\" color when the player should not cast and wait to twist)",
					hasAlpha=false,
					get = function()
						local tab = SwedgeTimer.db.profile.bar_color_righteousness
						return tab[1], tab[2], tab[3], tab[4]
					end,
					set = function(self,r,g,b,a)
						SwedgeTimer.db.profile.bar_color_righteousness = {r,g,b,a}
						st.bar.set_bar_color()
					end
				},				
				bar_color_blood = {
					order=23,
					type="color",
					name="Blood",
					desc="Seal of Blood/Seal of the Martyr",
					hasAlpha=false,
					get = function()
						local tab = SwedgeTimer.db.profile.bar_color_blood
						return tab[1], tab[2], tab[3], tab[4]
					end,
					set = function(self,r,g,b,a)
						SwedgeTimer.db.profile.bar_color_blood = {r,g,b,a}
						st.bar.set_bar_color()
					end
				},
				bar_color_wisdom = {
					order=25,
					type="color",
					name="Wisdom",
					desc="Seal of Wisdom",
					hasAlpha=false,
					get = function()
						local tab = SwedgeTimer.db.profile.bar_color_wisdom
						return tab[1], tab[2], tab[3], tab[4]
					end,
					set = function(self,r,g,b,a)
						SwedgeTimer.db.profile.bar_color_wisdom = {r,g,b,a}
						st.bar.set_bar_color()
					end
				},

				bar_color_light = {
					order=26,
					type="color",
					name="Light",
					desc="Seal of Light",
					hasAlpha=false,
					get = function()
						local tab = SwedgeTimer.db.profile.bar_color_light
						return tab[1], tab[2], tab[3], tab[4]
					end,
					set = function(self,r,g,b,a)
						SwedgeTimer.db.profile.bar_color_light = {r,g,b,a}
						st.bar.set_bar_color()
					end
				},

				bar_color_justice = {
					order=27,
					type="color",
					name="Justice",
					desc="Seal of Justice",
					hasAlpha=false,
					get = function()
						local tab = SwedgeTimer.db.profile.bar_color_justice
						return tab[1], tab[2], tab[3], tab[4]
					end,
					set = function(self,r,g,b,a)
						SwedgeTimer.db.profile.bar_color_justice = {r,g,b,a}
						st.bar.set_bar_color()
					end
				},
				bar_color_crusader = {
					order=27.1,
					type="color",
					name="Crusader",
					desc="Seal of the Crusader",
					hasAlpha=false,
					get = function()
						local tab = SwedgeTimer.db.profile.bar_color_crusader
						return tab[1], tab[2], tab[3], tab[4]
					end,
					set = function(self,r,g,b,a)
						SwedgeTimer.db.profile.bar_color_crusader = {r,g,b,a}
						st.bar.set_bar_color()
					end
				},
				bar_color_vengeance = {
					order=24,
					type="color",
					name="Vengeance",
					desc="Seal of Vengeance/Seal of Corruption",
					hasAlpha=false,
					get = function()
						local tab = SwedgeTimer.db.profile.bar_color_vengeance
						return tab[1], tab[2], tab[3], tab[4]
					end,
					set = function(self,r,g,b,a)
						SwedgeTimer.db.profile.bar_color_vengeance = {r,g,b,a}
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
					hasAlpha=false,
					get = function()
						local tab = SwedgeTimer.db.profile.bar_color_gcd
						return tab[1], tab[2], tab[3], tab[4]
					end,
					set = function(self,r,g,b,a)
						SwedgeTimer.db.profile.bar_color_gcd = {r,g,b,a}
						st.bar.frame.gcd_bar:SetVertexColor(unpack(SwedgeTimer.db.profile.bar_color_gcd))
					end
				},


				------------------------------------------------------------------------------------
				-- Marker appearance settings
				markers_header = {
					order=50,
					type="header",
					name="Markers",
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
						SwedgeTimer.db.profile.marker_width = key
						set_marker_widths()
					end,
				},
				gcd_marker_color = {
					order=53,
					type="color",
					name="GCD",
					desc="The color of the GCD markers.",
					hasAlpha=false,
					get = function()
						return unpack(SwedgeTimer.db.profile.gcd_marker_color)
					end,
					set = function(self,r,g,b,a)
						SwedgeTimer.db.profile.gcd_marker_color = {r,g,b,a}
						set_marker_colors()
					end
				},
				twist_marker_color = {
					order=52,
					type="color",
					name="Twist window",
					desc="The color of the twist window marker.",
					hasAlpha=false,
					get = function()
						return unpack(SwedgeTimer.db.profile.twist_marker_color)
					end,
					set = function(self,r,g,b,a)
						SwedgeTimer.db.profile.twist_marker_color = {r,g,b,a}
						set_marker_colors()
					end
				},
				judgement_marker_color = {
					order=54,
					type="color",
					name="Judgement indicator",
					desc="The color of the judgement indicator marker, which shows when judgement will come off cooldown"..
					" on the player's swing timer.",
					hasAlpha=false,
					get = function()
						return unpack(SwedgeTimer.db.profile.judgement_marker_color)
					end,
					set = function(self,r,g,b,a)
						SwedgeTimer.db.profile.judgement_marker_color = {r,g,b,a}
						set_marker_colors()
					end
				},
			}
		},

        -- Textures

		-- someRange = {
		-- 	type = "range",
		-- 	order = 2,
		-- 	name = "a slider",
		-- 	-- this will look for a getter/setter on our handler object
		-- 	get = "GetSomeRange",
		-- 	set = "SetSomeRange",
		-- 	min = 1, max = 10, step = 1,
		-- },
		-- group1 = {
		-- 	type = "group",
		-- 	order = 3,
		-- 	name = "a group",
		-- 	inline = true,
		-- 	-- getters/setters can be inherited through the table tree
		-- 	get = "GetValue",
		-- 	set = "SetValue",
		-- 	args = {
		-- 		someInput = {
		-- 			type = "input",
		-- 			order = 1,
		-- 			name = "an input box",
		-- 			width = "double",
		-- 		},
		-- 		someDescription = {
		-- 			type = "description",
		-- 			order = 2,
		-- 			name = function() return format("The current time is: |cff71d5ff%s|r", date("%X")) end,
		-- 			fontSize = "large",
		-- 		},
		-- 		someSelect = {
		-- 			type = "select",
		-- 			order = 3,
		-- 			name = "a dropdown",
		-- 			values = {"Apple", "Banana", "Strawberry"},
		-- 		},
		-- 	},
	},
}

-- function SwedgeTimer:GetSomeRange(info)
-- 	return self.db.profile.someRange
-- end

-- function SwedgeTimer:SetSomeRange(info, value)
-- 	self.db.profile.someRange = value
-- end

-- -- https://www.wowace.com/projects/ace3/pages/ace-config-3-0-options-tables#title-4-1
function SwedgeTimer:GetValue(info)
    -- print(info)
	return self.db.profile[info[#info]]
end

function SwedgeTimer:SetValue(info, value)
	self.db.profile[info[#info]] = value
end