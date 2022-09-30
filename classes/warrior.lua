--=========================================================================================
-- Module for warrior-specific behaviours
--=========================================================================================
local addon_name, st = ...
local ST = LibStub("AceAddon-3.0"):GetAddon(addon_name)

ST.WARRIOR = {}

local hs_ids = {
    47450, 47449, 30324, 29707, 25286, 11567, 11566,
    11565, 11564, 1608, 285, 284, 78
}

local cleave_ids = {
    47520, 47519, 25231, 20569, 11609, 11608, 7369, 845
}


function ST.WARRIOR.on_rage_update(self)
    if (not self.hs_queued) and (not self.cleave_queued) then
        self.insufficient_rage = false
        return
    end
    
    if self.hs_queued then
        local power = UnitPower("player")
        local rage_cost = GetSpellPowerCost(47450)[1].cost
        if power < rage_cost then
            self.insufficient_rage = true
            self:set_bar_color("mainhand")
            return
        else
            self.insufficient_rage = false
            return
        end
    end

    if self.cleave_queued then
        local power = UnitPower("player")
        local rage_cost = GetSpellPowerCost(47520)[1].cost
        if power < rage_cost then
            self.insufficient_rage = true
            self:set_bar_color("mainhand")
            return
        else
            self.insufficient_rage = false
            return
        end
    end
end

function ST.WARRIOR.on_spellcast_failed_quiet(self, unit_id, cast_guid, spell_id)
    if self:is_value_in_array(spell_id, hs_ids) then
        self.hs_queued = false
        self:set_bar_color("mainhand")
        return
    end
    if self:is_value_in_array(spell_id, cleave_ids) then
        self.cleave_queued = false
        self:set_bar_color("mainhand")
        return
    end
end

function ST.WARRIOR.on_spellcast_succeeded(self, unit_target, cast_guid, spell_id)
    -- print(unit_target)
    -- print(spell_id)
    if self:is_value_in_array(spell_id, hs_ids) then
        self.hs_queued = false
        self:set_bar_color("mainhand")
        return
    end
    if self:is_value_in_array(spell_id, cleave_ids) then
        self.cleave_queued = false
        self:set_bar_color("mainhand")
        return
    end
end

function ST.WARRIOR.on_current_spell_cast_changed(self, is_cancelled)
    -- This function detects when the player queues up a heroic strike or cleave
    -- and sets relevant flags for the func to set bar colors.

    local db = self:get_class_options_table()

    -- Only run this logic if special on-next-attack colors are enabled in the warrior settings.
    if (not db.enable_hs_color) and not (db.enable_cleave_color) then
        return
    end

    if db.enable_hs_color then
        for spell_id in self:generic_iter(hs_ids) do
            local result = IsCurrentSpell(spell_id)
            if result then
                -- print('matched HS id: '..tostring(spell_id))
                self.hs_queued = true
                self.cleave_queued = false
                self:set_bar_color("mainhand")
                return
            end
        end
        self.hs_queued = false
    end

    -- If we get here, cleave color is enabled and no HS queued so check that always.
    for spell_id in self:generic_iter(cleave_ids) do
        local result = IsCurrentSpell(spell_id)
        if result then
            -- print('matched cleave id: '..tostring(spell_id))
            self.cleave_queued = true
            self:set_bar_color("mainhand")
            return
        end
    end
    self.cleave_queued = false
end

function ST.WARRIOR.set_bar_color(self, hand)
    -- Returns true if any special setting was applied to let the parent func know 
    -- to revert to default behaviour
    local db_class = self:get_class_options_table()
    local frame = self:get_frame(hand)
    
    if hand ~= "mainhand" then
        return false
    end

    -- On-next-attack behaviours
    if db_class.enable_hs_color and self.hs_queued and not (self.insufficient_rage) then
        frame.bar:SetVertexColor(
            self:convert_color(db_class.hs_color)
        )
        return true
    end
    if db_class.enable_cleave_color and self.cleave_queued and not (self.insufficient_rage) then
        frame.bar:SetVertexColor(
            self:convert_color(db_class.cleave_color)
        )
        return true
    end
    
    -- Insufficient rage for queue.
    if (self.cleave_queued or self.hs_queued) and self.insufficient_rage then
        frame.bar:SetVertexColor(
            self:convert_color(db_class.insufficient_rage_color)
        )
        return true
    end

    return false

end
