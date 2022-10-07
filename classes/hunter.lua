--=========================================================================================
-- Module for Hunter-specific behaviours
--=========================================================================================
local addon_name, st = ...
local ST = LibStub("AceAddon-3.0"):GetAddon(addon_name)

local raptor_strike_ids = {
    2973, 14260, 14261, 14262, 14263, 14264, 14265, 27014, 48995, 48996
}

function ST.HUNTER.on_spellcast_failed_quiet(self, unit_id, cast_guid, spell_id)
    if self:is_value_in_array(spell_id, raptor_strike_ids) then
        self.raptor_strike_queued = false
        self:set_bar_color("mainhand")
    end
end

function ST.HUNTER.on_spellcast_succeeded(self, unit_target, cast_guid, spell_id)
    if self:is_value_in_array(spell_id, raptor_strike_ids) then
        self.raptor_strike_queued = false
        self:set_bar_color("mainhand")
    end
end

function ST.HUNTER.on_current_spell_cast_changed(self, is_cancelled)
    -- This function detects when the player queues up a maul
    -- and sets relevant flags for the func to set bar colors.
    local db = self:get_class_table()
    -- Only run this logic if special on-next-attack colors are enabled in the druid settings.
    if not db.enable_raptor_strike_color then
        return
    end
    if db.enable_maul_color then
        for spell_id in self:generic_iter(raptor_strike_ids) do
            local result = IsCurrentSpell(spell_id)
            if result then
                self.raptor_strike_queued = true
                self:set_bar_color("mainhand")
                return
            end
        end
        self.raptor_strike_queued = false
    end
end

function ST.HUNTER.set_bar_color(self, hand)
    local db_class = self:get_class_table()
    local frame = self:get_visuals_frame(hand)
    if hand ~= "mainhand" then
        return false
    end

    -- On-next-attack behaviours
    if db_class.enable_raptor_strike_color and self.raptor_strike_queued then
        frame.bar:SetVertexColor(
            self:convert_color(db_class.raptor_strike_color)
        )
        return true
    end
    return false
end
