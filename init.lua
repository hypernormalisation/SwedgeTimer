local addon_name, st = ...
local isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local isWrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC and LE_EXPANSION_LEVEL_CURRENT == LE_EXPANSION_WRATH_OF_THE_LICH_KING

st.is_version_supported = true
if not (isWrath or isClassic) then
    st.is_version_supported = false
end
