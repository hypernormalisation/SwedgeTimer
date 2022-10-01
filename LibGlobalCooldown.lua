local MAJOR_VERSION = "LibGlobalCooldown"
local MINOR_VERSION = 1

local lib = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then
    return
end

local CreateFrame = CreateFrame
local C_Timer = C_Timer
local GetCombatRatingBonus = GetCombatRatingBonus
local GetSpellCooldown = GetSpellCooldown
local GetSpellInfo = GetSpellInfo
local GetTime = GetTime
local GetShapeshiftForm = GetShapeshiftForm
local math = math
local select = select
local UnitClass = UnitClass

-- Callbacks and event names
lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib)
lib.GCD_OVER = "GCD_OVER"
lib.GCD_STARTED = "GCD_STARTED"
lib.GCD_DURATIONS_UPDATED = "GCD_DURATIONS_UPDATED"
lib.GCD_PHYS_UPDATED = "GCD_PHYS_UPDATED"
lib.GCD_SPELL_UPDATED = "GCD_SPELL_UPDATED"

-- Containers for state tracking
lib.in_combat = false
lib.current_form = nil

-- Containers for active GCD info
lib.gcd_duration = nil
lib.gcd_started = nil
lib.gcd_expires = nil

-- Containers for predicted GCD info
lib.phys_gcd = 1.5 -- will be modified for feral cats
lib.base_spell_gcd = 1.5
lib.current_spell_gcd = nil
lib.has_bloodlust = false
lib.has_breath_haste = false
lib.current_spell_haste = nil

-- A cast time that will be guaranteed to not benefit from a class's 
-- instant cast procs. Defaults to Flash of Light, but if the player is a 
-- Paladin we'll change this to rank 1 Frostbolt to avoid AoW instant casts.
lib.cast_time_1500ms_spell_id = 19750

function lib:Fire(event, ...)
	self.callbacks:Fire(event, ...)
end

-- Rounds down, e.g. if step=0.1 will round down to 1dp.
local simple_floor = function(num, step)
    return floor(num / step) * step
end

-----------------------------------------------------------
-- Funcs to manipulate state and fire events
-----------------------------------------------------------
function lib:calculate_expected_spell_gcd()
    -- First try to calc the expected GCD from first principles
    local rating_percent_reduction = GetCombatRatingBonus(20)
    local spell_gcd = self.base_spell_gcd
    local reduction_from_haste_rating = 100 / (100 + rating_percent_reduction)
    local current = spell_gcd * reduction_from_haste_rating
    if lib.has_bloodlust then
        current = current * (1/1.3)
    end
    if lib.has_breath_haste then
        current = current * (1/1.25)
    end

	-- Flash of Light has a 1.5s cast time so can be used to check
    -- for the spell GCD duration, in case we miss any multiplicative buffs.
    -- If there are any debuffs decreasing cast speed, this will be wrong,
    -- and we'll fallback on the first principles calc.
	local cast_time_test = select(4, GetSpellInfo(self.cast_time_1500ms_spell_id))
	cast_time_test = cast_time_test or 1500
	cast_time_test = cast_time_test / 1000 -- change from ms to s

	-- Get the minimum of the 2 methods, which should be the more accurate.
    -- print(current, cast_time_test)
	current = math.min(current, cast_time_test)

    -- The minimum GCD for all classes is 1s.
    if current < 1 then
        current = 1.0
    end
    -- print(string.format("current: %f, old: %f", current, self.current_spell_gcd))
    -- print(current, self.current_spell_gcd)
    -- Round to 4 decimal places
    -- current = simple_floor(current, 0.0001)

    -- If has changed, fire relevant triggers.
    if current ~= self.current_spell_gcd then
        self.current_spell_gcd = current
        self:Fire(self.GCD_SPELL_UPDATED, self.current_spell_gcd)
        self:Fire(self.GCD_DURATIONS_UPDATED, self.phys_gcd, self.current_spell_gcd)
    end
    -- print(string.format('spell GCD: %f, phys GCD: %f', current, self.phys_gcd))
end

function lib:release_gcd_lock()
    self.gcd_duration = nil
	self.gcd_started = nil
    self:Fire(self.GCD_OVER)
end

function lib:poll_gcd()
    -- Function to be called when we have reason to believe a new GCD may 
    -- have triggered. Locks out new updates when we're on a GCD.
    if self.gcd_duration then
        return
    end
    local time_started, duration_reported = GetSpellCooldown(29515)
    if duration_reported == 0 then
        return
    end
	local t = GetTime()
    local duration_actual = duration_reported - (t - time_started)
    local expires = t + duration_actual
    self.gcd_duration = duration_reported
	self.gcd_started = time_started
	self.gcd_expires = expires
    -- print(duration_reported)
    self:Fire(self.GCD_STARTED, duration_actual, expires)
	C_Timer.After(duration_actual, function() self:release_gcd_lock() end)
end

-----------------------------------------------------------
-- Event handlers
-----------------------------------------------------------
function lib:COMBAT_RATING_UPDATE()
    local new_spell_haste = GetCombatRating(CR_HASTE_SPELL)
    -- print(new_spell_haste)
    if new_spell_haste ~= self.current_spell_haste then
        -- print('spell haste changed')
        self.current_spell_haste = new_spell_haste
        self:calculate_expected_spell_gcd()
    end
end

function lib:PLAYER_LOGIN()
    -- Populate info on class here.
    local class = select(2, UnitClass("player"))
    -- print("class says: "..tostring(class))
    self.class = class

    if self.class == "PALADIN" then
        self.cast_time_1500ms_spell_id = 116
    end
    lib.phys_gcd = 1.5
    lib.base_spell_gcd = 1.5
    -- Set the phys gcds for special cases i.e. rogue/cat.
    if class == "ROGUE" then
        lib.phys_gcd = 1
    elseif self.class == "DRUID" then
        local i = GetShapeshiftForm()
        if i == 3 then
            lib.phys_gcd = 1
        end
        self.current_form = i
    end

    self:calculate_expected_spell_gcd()
    self:Fire("GCD_DURATIONS_UPDATED", lib.phys_gcd, lib.current_spell_gcd)
end

-- function lib:PLAYER_REGEN_DISABLED()
--     self.in_combat = true
-- end

-- function lib:PLAYER_REGEN_ENABLED()
--     self.in_combat = false
-- end

function lib:SPELL_UPDATE_COOLDOWN()
    self:poll_gcd()
end

function lib:UNIT_AURA()
    self:calculate_expected_spell_gcd()
end

function lib:UNIT_SPELLCAST_INTERRUPTED()
    if self.gcd_duration then
        self:release_gcd_lock()
    end
end

function lib:UPDATE_SHAPESHIFT_FORM()
    -- Only druids have their physical gcd change.
    if not self.class == "DRUID" then
        return
    end
    local i = GetShapeshiftForm()
    if i == 3 then
        self.phys_gcd = 1.0
    else
        self.phys_gcd = 1.5
    end
    -- print('detected shapeshift')
    -- -- If shifting to or from cat form, Fire an event.
    -- print(i, self.current_form)
    -- if i == 3 or self.current_form == 3 then
    --     if not i == self.current_form then
    --         print('Firing change to/from cat')
    self.current_form = i
    self:Fire(self.GCD_PHYS_UPDATED, lib.phys_gcd)
    self:Fire(self.GCD_DURATIONS_UPDATED, lib.phys_gcd, lib.current_spell_gcd)
    --     end
    -- end
end

function lib:activate()
    if not self.frame then
        local frame = CreateFrame("Frame")
        self.frame = frame
        frame:RegisterEvent("PLAYER_LOGIN")
        -- print('first load:')
        -- print(GetShapeshiftForm())


        -- frame:RegisterEvent("PLAYER_REGEN_DISABLED")
        -- frame:RegisterEvent("PLAYER_REGEN_ENABLED")
        frame:RegisterEvent("COMBAT_RATING_UPDATE")
        frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        frame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
        frame:RegisterUnitEvent("UNIT_AURA", "player")
        frame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "player")
    end
    self.frame:SetScript("OnEvent", function(_, event, ...)
            lib[event](lib, event, ...)
        end
    )
end
lib:activate()
