local addon_name, st = ...
local SwedgeTimer = LibStub("AceAddon-3.0"):NewAddon(addon_name, "AceConsole-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
local STL = LibStub("LibClassicSwingTimerAPI", true)
local print = st.utils.print_msg

function SwedgeTimer:OnInitialize()
	local AC = LibStub("AceConfig-3.0")
	local ACD = LibStub("AceConfigDialog-3.0")

	local SwedgeTimerDB = LibStub("AceDB-3.0"):New(addon_name.."DB", self.defaults, true)
	self.db = SwedgeTimerDB

	AC:RegisterOptionsTable(addon_name.."_Options", self.options)
	self.optionsFrame = ACD:AddToBlizOptions(addon_name.."_Options", addon_name)
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	AC:RegisterOptionsTable(addon_name.."_Profiles", profiles)
	ACD:AddToBlizOptions(addon_name.."_Profiles", "Profiles", addon_name)
	local register_func_string = "SlashCommand"
	self:RegisterChatCommand("st", register_func_string)
	self:RegisterChatCommand("swedgetimer", register_func_string)

end

function SwedgeTimer:OnEnable()
	-- only load if player is a paladin
	-- if not st.utils.player_is_paladin() then return end

	-- Sort out character information
	-- st.player.get_twohand_spec_points()
	st.player.guid = UnitGUID("player")
	st.player.weapon_id = GetInventoryItemID("player", 16)
	st.player.reset_swing_timer()
end

function SwedgeTimer:SlashCommand(input, editbox)
	local ACD = LibStub("AceConfigDialog-3.0")
	ACD:Open(addon_name.."_Options")
end
