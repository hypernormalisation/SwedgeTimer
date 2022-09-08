------------------------------------------------------------------------------------
-- Main module for creating the addon with AceAddon
------------------------------------------------------------------------------------
local addon_name, st = ...
local ST = LibStub("AceAddon-3.0"):NewAddon(addon_name, "AceConsole-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
local STL = LibStub("LibClassicSwingTimerAPI", true)
local print = st.utils.print_msg

------------------------------------------------------------------------------------
-- The init/enable/disable
------------------------------------------------------------------------------------
function ST:OnInitialize()

	-- Addon database
	local SwedgeTimerDB = LibStub("AceDB-3.0"):New(addon_name.."DB", self.defaults, true)
	self.db = SwedgeTimerDB

	-- Options table
	local AC = LibStub("AceConfig-3.0")
	local ACD = LibStub("AceConfigDialog-3.0")
	AC:RegisterOptionsTable(addon_name.."_Options", self.options)
	self.optionsFrame = ACD:AddToBlizOptions(addon_name.."_Options", addon_name)
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	AC:RegisterOptionsTable(addon_name.."_Profiles", profiles)
	ACD:AddToBlizOptions(addon_name.."_Profiles", "Profiles", addon_name)

	-- Slashcommands
	local register_func_string = "SlashCommand"
	self:RegisterChatCommand("st", register_func_string)
	self:RegisterChatCommand("swedgetimer", register_func_string)

	-- Make the frame for the STL to push events to.
	self:register_timer_callbacks()

end

function ST:OnEnable()
	-- only load if player is a paladin
	-- if not st.utils.player_is_paladin() then return end

	-- Sort out character information
	-- st.player.get_twohand_spec_points()
	st.player.guid = UnitGUID("player")
	st.player.weapon_id = GetInventoryItemID("player", 16)
	st.player.reset_swing_timer()
end

------------------------------------------------------------------------------------
-- The Event handlers for the STL
------------------------------------------------------------------------------------
function ST:register_timer_callbacks()
	self.tf = CreateFrame(addon_name.."TimerFrame", nil)
	STL.RegisterCallback(self.tf, "SWING_TIMER_START", self.timer_event_handler)
	-- STL.RegisterCallback(self.tf, "SWING_TIMER_UPDATE", self.timer_event_handler)
	-- STL.RegisterCallback(self.tf, "SWING_TIMER_CLIPPED", self.timer_event_handler)
	-- STL.RegisterCallback(self.tf, "SWING_TIMER_PAUSED", self.timer_event_handler)
	-- STL.RegisterCallback(self.tf, "SWING_TIMER_STOP", self.timer_event_handler)
	-- STL.RegisterCallback(self.tf, "SWING_TIMER_DELTA", self.timer_event_handler)
end

function ST:SWING_TIMER_START(event)

end

function ST:timer_event_handler(event, ...)
	return self[event](self.tf, event, ...)
end



function SwedgeTimer:SlashCommand(input, editbox)
	local ACD = LibStub("AceConfigDialog-3.0")
	ACD:Open(addon_name.."_Options")
end
