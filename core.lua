local addon_name, st = ...
local SwedgeTimer = LibStub("AceAddon-3.0"):NewAddon(addon_name, "AceEvent-3.0", "AceConsole-3.0")
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local SML = LibStub("LibSharedMedia-3.0")
local print = st.utils.print_msg

-- print(SML.DefaultMedia.statusbar)
-- -- print(SML.DefaultMedia.background)
-- print(SML:Fetch('statusbar', "Solid"))


function SwedgeTimer:OnInitialize()
	-- uses the "Default" profile instead of character-specific profiles
	-- https://www.wowace.com/projects/ace3/pages/api/ace-db-3-0
	SwedgeTimerDB = LibStub("AceDB-3.0"):New("SwedgeTimerDB", self.defaults, true)
	self.db = SwedgeTimerDB

	-- registers an options table and adds it to the Blizzard options window
	-- https://www.wowace.com/projects/ace3/pages/api/ace-config-3-0
	AC:RegisterOptionsTable("SwedgeTimer_Options", self.options)
	self.optionsFrame = ACD:AddToBlizOptions("SwedgeTimer_Options", "SwedgeTimer (label 1)")

	-- adds a child options table, in this case our profiles panel
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	AC:RegisterOptionsTable("SwedgeTimer_Profiles", profiles)
	ACD:AddToBlizOptions("SwedgeTimer_Profiles", "Profiles", "SwedgeTimer (label 1)")

	-- https://www.wowace.com/projects/ace3/pages/api/ace-console-3-0
	self:RegisterChatCommand("st", "SlashCommand")
	self:RegisterChatCommand("swedgetimer", "SlashCommand")

	-- self:GetCharacterInfo()
end

function SwedgeTimer:OnEnable()
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
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)

		--[[ or as a standalone window
		if ACD.OpenFrames["SwedgeTimer_Options"] then
			ACD:Close("SwedgeTimer_Options")
		else
			ACD:Open("SwedgeTimer_Options")
		end
		]]
	-- end
end

SwedgeTimer.defaults = {
	-- profile = {
	-- 	someToggle = true,
	-- 	someRange = 7,
	-- 	someInput = "Hello World",
	-- 	someSelect = 2, -- Banana
	-- },
    profile = {

		-- Behaviour toggles
		welcome_message = true,
		bar_enabled = true,
        lag_detection_enabled = true,
        hide_bar_when_inactive = true,
		judgement_marker_enabled = true,

		-- Bar dimensions
		bar_height = 32,
		bar_width = 345,

		-- Bar positioning
		bar_locked = true,
		bar_x_offset = 0,
		bar_y_offset = -180,

		-- Bar textures
        bar_texture_key = SML.DefaultMedia.statusbar,
        gcd_texture_key = SML.DefaultMedia.statusbar,
        backplane_texture_key = SML.DefaultMedia.statusbar,
		backplane_alpha = 0.85,
        
		-- Font settings
		font_size = 16,
		font_color = {1.0, 1.0, 1.0, 1.0},
		text_font = SML.DefaultMedia.font,
        

        -- bar_fontsize = 16,
        -- bar_width = 345,
        -- bar_height = 32,
        -- bar_x_offset = 0,
        -- bar_y_offset = -180,
        -- bar_backplane_alpha = 0.85,
        -- bar_is_locked = false,
        -- bar_show_attack_speed = true,
        -- bar_show_swing_timer = true,

        -- bar_twist_window_ms = 400,
        -- bar_gcd_padding_ms = 100,

        -- bar_twist_color_enabled = true,

		marker_width = 3,
		gcd_marker_color = {0.2, 0.3, 0.2, 1.0},
		twist_marker_color = {0.9,0.9,0.9,1.0},
		judgement_marker_color = {0.9,0.9,0.01,1.0},

        -- bar_line_width = 3,

		-- Seal color settings
        bar_color_default = {0.5, 0.5, 0.5, 1.0},
        bar_color_twist_ready = {0., 0.68, 0., 1.0},
        bar_color_blood = {0.7, 0.27, 0.0, 1.0},
		bar_color_command = {0., 0.68, 0., 1.0},
		bar_color_wisdom = {0., 0.4, 0.7, 1.0},
		bar_color_light = {0., 0.8, 0.4, 1.0},
		bar_color_justice = {0.8, 0.1, 0.7, 1.0},
		bar_color_vengeance = {0.8, 0.5, 0.4, 1.0},
		bar_color_righteousness = {0., 0.68, 0., 1.0},

		-- Special bar colors
        bar_color_cant_twist = {0.7, 0.7, 0.01, 1.0},
        bar_color_warning = {1.0, 0.0, 0.0, 1.0}, -- when if you cast SoC, you can't twist out of it that swing
        
		-- GCD underlay bar colors
		bar_color_gcd = {0.3, 0.3, 0.3, 1.0},

    },

}

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



local set_bar_position = function()
	local db = SwedgeTimer.db.profile
	local frame = st.bar.frame
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", UIParent, "CENTER", db.bar_x_offset, db.bar_y_offset)
	frame.bar:SetPoint("TOPLEFT", 0, 0)

	frame.bar:SetPoint("TOPLEFT", 0, 0)
	frame.gcd_bar:SetPoint("TOPLEFT", 0, 0)
	frame.left_text:SetPoint("TOPLEFT", 2, -(db.bar_height / 2) + (db.font_size / 2))
	frame.right_text:SetPoint("TOPRIGHT", 2, -(db.bar_height / 2) + (db.font_size / 2))
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
	frame.right_text:SetPoint("TOPLEFT", 2, -(db.bar_height / 2) + (db.font_size / 2))
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

SwedgeTimer.options = {
	type = "group",
	name = "SwedgeTimer",
	handler = SwedgeTimer,
	args = {
		welcome_message = {
			type = "toggle",
			order = 1,
			name = "Welcome message",
			desc = "Displays a login message showing the addon version on player login or reload.",
			get = "GetValue",
			set = "SetValue",
		},
		bar_enabled = {
			type = "toggle",
			order = 1,
			name = "Bar Enabled",
			desc = "Enables or disables the swing timer bar.",
			get = "GetValue",
			set = "SetValue",
			-- inline getter/setter example
			-- get = function(info) return SwedgeTimer.db.profile.bar_enabled end,
			-- set = function(info, value) SwedgeTimer.db.profile.bar_enabled = value end,
		},

		bar_behaviour = {
			type = "group",
			name = "Features",
			handler = SwedgeTimer,
			order = 1,
			args = {
				lag_detection_enabled = {
					type = "toggle",
					order = 1,
					name = "Lag detection",
					desc = "When enabled, the swing timer bar turns a special colour when the player is in Seal of Command"..
					" and the time remaining to cast a spell at the end of their GCD is lower than the current lag.",
					get = "GetValue",
					set = "SetValue",
				},
				hide_bar_when_inactive = {
					type = "toggle",
					order = 1,
					name = "Auto-hide bar",
					desc = "When enabled, hides the bar when there is no active seal or the player is out of combat.",
					get = "GetValue",
					set = "SetValue",
				},
				judgement_marker_enabled = {
					type = "toggle",
					order = 1,
					name = "Judgement Marker",
					desc = "When enabled, indicates where on the swing timer judgement will come off cooldown (if in "..
					"a high value spell to judge like Seal of Blood).",
					get = "GetValue",
					set = "SetValue",
				},
			}
		},

		-- Positioning
		positioning = {
			type = "group",
			name = "Size and position",
			handler = SwedgeTimer,
			order = 2,
			args = {

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

				position_header = {
					type = 'header',
					name = 'Position',
					order = 4,
				},

				bar_x_offset = {
					type = "input",
					order = 5,
					name = "Bar x offset",
					desc = "The x position of the bar.",
					get = "GetValue",
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
					get = "GetValue",
					set = function(self, input)
						SwedgeTimer.db.profile.bar_y_offset = input
						set_bar_position()
					end			
				},
				bar_locked = {
					type = "toggle",
					order = 7,
					name = "Bar locked",
					desc = "Locks the swing bar in-place.",
					get = "GetValue",
					set = "SetValue",
				},
			}
		},

		bar_appearance = {
			type = "group",
			name = "Appearance",
			handler = SwedgeTimer,
			order = 3,
			args = {

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
				
				colors_header = {
					order=5,
					type="header",
					name="Seal colors",
				},

				bar_color_default = {
					order=6,
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
					end
				},
				
				bar_color_blood = {
					order=7,
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
					end
				},

				bar_color_command = {
					order=8,
					type="color",
					name="Command",
					desc="Seal of Command (when the player can safely cast a GCD if near the beginning "..
					"of their swing, or should twist into another seal if at the end of their swing).",
					hasAlpha=false,
					get = function()
						local tab = SwedgeTimer.db.profile.bar_color_command
						return tab[1], tab[2], tab[3], tab[4]
					end,
					set = function(self,r,g,b,a)
						SwedgeTimer.db.profile.bar_color_command = {r,g,b,a}
					end
				},

				bar_color_wisdom = {
					order=10,
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
					end
				},

				bar_color_light = {
					order=11,
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
					end
				},

				bar_color_justice = {
					order=12,
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
					end
				},

				bar_color_vengeance = {
					order=12,
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
					end
				},

				bar_color_righteousness = {
					order=9,
					type="color",
					name="Righteousness",
					desc="Seal of Righteousness (when the player can safely cast a GCD if near the beginning "..
					"of their swing, or should twist into another seal if at the end of their swing).",
					hasAlpha=false,
					get = function()
						local tab = SwedgeTimer.db.profile.bar_color_righteousness
						return tab[1], tab[2], tab[3], tab[4]
					end,
					set = function(self,r,g,b,a)
						SwedgeTimer.db.profile.bar_color_righteousness = {r,g,b,a}
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
				bar_color_cant_twist = {
					order=14,
					type="color",
					name="Can't twist",
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

				gcd_header = {
					order=17,
					type="header",
					name="GCD underlay",
				},

				bar_color_gcd = {
					order=18,
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

				fonts_header = {
					order=20,
					type="header",
					name="Fonts",
				},

				font_size = {
					type = "range",
					order = 23,
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
					order=22,
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
					order = 21,
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

				markers_header = {
					order=30,
					type="header",
					name="Markers",
				},

				marker_width = {
					type = "range",
					order = 31,
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
					order=33,
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
					order=32,
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
					order=34,
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
		-- bar_y_offset = {
		-- 	type = "slider",
		-- 	order = 1,
		-- 	name = "Bar x offset",
		-- 	desc = "The x position of the bar.",
		-- 	get = "GetValue",
		-- 	step = 0.01,
		-- 	bigStep = 0.1
		-- 	set = function(self, input)
		-- 		local db = SwedgeTimer.db.profile
		-- 		-- SwedgeTimer.db.profile.bar_x_offset = input
		-- 		db.bar_x_offset = input
		-- 		st.bar.frame:SetPoint("CENTER", UIParent, "CENTER", db.bar_x_offset, db.bar_y_offset)
		-- 	end			
		-- },

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