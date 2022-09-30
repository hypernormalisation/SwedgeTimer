--=========================================================================================
-- Module for Paladin-specific behaviours
--=========================================================================================
local addon_name, st = ...
local ST = LibStub("AceAddon-3.0"):GetAddon(addon_name)

-- Seal IDs
local soc_id = 20375
local sov_ids = {
    31801, 348704
}
local sol_id = 20165
local sow_id = 20166
local sor_id = 21084

-- Art of War
local aow_id = 59578

function ST.PALADIN.post_init(self)
    self.PALADIN.on_aura_change(self)
end

function ST.PALADIN.on_aura_change(self)
    -- Parse seals and art of war
    self.has_aow = false
    self.has_soc = false
    self.has_sov = false
    self.has_sol = false
    self.has_sow = false
    self.has_sor = false

    -- Iterate all player auras
    local i = 1
    while true do
        local name, _, _, _, _, _, _, _, _, spell_id = UnitAura("player", i)
        if name == nil then
            break
        end
        -- Seals
        if spell_id == soc_id then
            self.has_soc = true
        end
        if self:is_value_in_array(spell_id, sov_ids) then
            self.has_sov = true
        end
        if spell_id == sol_id then
            self.has_sol = true
        end
        if spell_id == sow_id then
            self.has_sow = true
        end
        if spell_id == sor_id then
            self.has_sor = true
        end

        -- Art of War
        if spell_id == aow_id then
            self.has_aow = true
        end

        i = i + 1
    end

    -- Finally set the bar color
    self:set_bar_color("mainhand")

end

function ST.PALADIN.set_bar_color(self, hand)
    -- Returns true if any special setting was applied to let the parent func know 
    -- to revert to default behaviour.
    -- Will set appropriate colors for seals and AoW procs if requested.
    local db_class = self:get_class_options_table()
    local frame = self:get_frame(hand)

    -- If enabled, Art of War color takes precedence.
    if db_class.use_aow_color and self.has_aow then
        frame.bar:SetVertexColor(
            self:convert_color(db_class.aow_color)
        )
        return true
    end

    -- Seal colors    
    if db_class.use_seal_colors then
        if self.has_soc then
            frame.bar:SetVertexColor(
                self:convert_color(db_class.soc_color)
            )
            return true
        end
        if self.has_sov then
            frame.bar:SetVertexColor(
                self:convert_color(db_class.sov_color)
            )
            return true
        end
        if self.has_sol then
            frame.bar:SetVertexColor(
                self:convert_color(db_class.sol_color)
            )
            return true
        end
        if self.has_sow then
            frame.bar:SetVertexColor(
                self:convert_color(db_class.sow_color)
            )
            return true
        end
        if self.has_sor then
            frame.bar:SetVertexColor(
                self:convert_color(db_class.sor_color)
            )
            return true
        end
    end

    return false
end
