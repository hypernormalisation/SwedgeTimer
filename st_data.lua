print('parsing st_data.lua')
local addon_name, st = ...
local print = st.utils.print_msg
local floor = st.utils.SimpleRound
local get_tab = st.utils.convert_lookup_table
st.data = {}

--=========================================================================================
-- SEAL IDs
--=========================================================================================
-- Seal of Blood/the Martyr
local sob_ids = {
    31892, 348700
}
st.data.sob_ids = get_tab(sob_ids)

-- Seal of Command
local soc_ids = {
    20375, 20915, 20918, 20919, 20920, 27170
}
st.data.soc_ids = get_tab(soc_ids)

-- Seal of Righteousness
local sor_ids = {
    20154, 20287, 20288, 20289, 20290, 20291, 20292, 20293, 27155
}
st.data.sor_ids = get_tab(sor_ids)

-- Seal of the Crusader
local sotc_ids = {
    21082, 20162, 20305, 20306, 20307, 20308, 27158
}
st.data.sotc_ids = get_tab(sotc_ids)

-- Seal of Justice
local soj_ids = {
    20164, 31895
}
st.data.soj_ids = get_tab(soj_ids)

-- Seal of Wisdom
local sow_ids = {
    20166, 20356, 20357, 27166
}
st.data.sow_ids = get_tab(sow_ids)

-- Seal of Light IDs
local sol_ids = {
    20165, 20347, 20348, 20349, 27160
}
st.data.sol_ids = get_tab(sol_ids)

-- Seal of Vengeance/Corruption IDs
local sov_ids = {
    31801, 348704
}
st.data.sov_ids = get_tab(sov_ids)

--=========================================================================================
-- End, if debug verify module was read.
--=========================================================================================
if st.debug then print('-- Parsed st_data.lua module correctly') end
