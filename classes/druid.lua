--=========================================================================================
-- Module for Druid-specific behaviours
--=========================================================================================
local addon_name, st = ...
local ST = LibStub("AceAddon-3.0"):GetAddon(addon_name)

local maul_ids = {
    6807, 6808, 6809, 8972, 9745, 9880, 9881, 26996, 48479, 48480
}

function ST.DRUID.on_rage_update(self)
    if not self.maul_queued then
        self.insufficient_rage = false
        return
    end
    if self.maul_queued then
        local power = UnitPower("player")
        local rage_cost = GetSpellPowerCost(48480)[1].cost
        if power < rage_cost then
            self.insufficient_rage = true
            self:set_bar_color("mainhand")
        else
            self.insufficient_rage = false
        end
    end
end

function ST.DRUID.on_spellcast_failed_quiet(self, unit_id, cast_guid, spell_id)
    if self:is_value_in_array(spell_id, maul_ids) then
        self.maul_queued = false
        self:set_bar_color("mainhand")
    end
end

function ST.DRUID.on_spellcast_succeeded(self, unit_target, cast_guid, spell_id)
    if self:is_value_in_array(spell_id, maul_ids) then
        self.maul_queued = false
        self:set_bar_color("mainhand")
    end
end

function ST.DRUID.on_current_spell_cast_changed(self, is_cancelled)
    -- This function detects when the player queues up a maul
    -- and sets relevant flags for the func to set bar colors.
    local db = self:get_class_table()
    -- Only run this logic if special on-next-attack colors are enabled in the druid settings.
    if not db.enable_maul_color then
        return
    end

    if db.enable_maul_color then
        for spell_id in self:generic_iter(maul_ids) do
            local result = IsCurrentSpell(spell_id)
            if result then
                self.maul_queued = true
                self:set_bar_color("mainhand")
                return
            end
        end
        self.maul_queued = false
    end
end

function ST.DRUID.set_bar_color(self, hand)
    -- Returns true if any special setting was applied to let the parent func know 
    -- to revert to default behaviour.
    -- Will set appropriate colors for maul queued if requested in the settings,
    -- and will set a special color when the player has one of those queued up but has
    -- insufficient rage to cast them.
    local db_class = self:get_class_table()
    local frame = self:get_visuals_frame(hand)
    self:get_druid_talent_info()
	self:determine_form_visibility_flag()
    if hand ~= "mainhand" then
        return false
    end

    -- On-next-attack behaviours
    if db_class.enable_maul_color and self.maul_queued and not (self.insufficient_rage) then
        frame.bar:SetVertexColor(
            self:convert_color(db_class.maul_color)
        )
        return true
    end
    
    -- Insufficient rage for queue.
    if self.maul_queued and self.insufficient_rage then
        frame.bar:SetVertexColor(
            self:convert_color(db_class.insufficient_rage_color)
        )
        return true
    end

    -- Form-specific behaviours.
    if db_class.use_form_colors then
        if self.form_index == 1 then
            frame.bar:SetVertexColor(
                self:convert_color(db_class.form_color_bear)
            )
            return true
        elseif self.form_index == 4 then
            frame.bar:SetVertexColor(
                self:convert_color(db_class.form_color_travel)
            )
            return true
        elseif self.form_index == 3 then
            frame.bar:SetVertexColor(
                self:convert_color(db_class.form_color_cat)
            )
            return true
        elseif self.form_index == 5 and self.has_moonkin then
            frame.bar:SetVertexColor(
                self:convert_color(db_class.form_color_moonkin)
            )
            return true
        elseif self.form_index == 5 and self.has_tree_of_life then
            frame.bar:SetVertexColor(
                self:convert_color(db_class.form_color_tree)
            )
            return true
        elseif self.form_index == 5 and (not self.has_tree_of_life and not self.has_moonkin) then
            frame.bar:SetVertexColor(
                self:convert_color(db_class.form_color_flight)
            )
            return true
        elseif self.form_index == 6 then
            frame.bar:SetVertexColor(
                self:convert_color(db_class.form_color_flight)
            )
            return true
        end
    end
    return false

end
