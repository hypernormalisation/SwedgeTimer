# 1.1.0

## Fixes

- multiplicative spell haste from Kil'Jaedin fight's "Breath: Haste" buff is now properly taken into account when the GCD marker positions are calculate.
- accounted for an issue where the UnitAttackSpeed API endpoint sometimes returns 0, typically on first load, which introduced infinities in swing timer calculations that persisted until a player action was taken.
- Seal of the Crusader snapshotting has been redone, such that haste changes can now also be processed while the snapshotting is in effect.
- the lag compensation system now recalculates impossible twists when haste effects change midswing.
- the swing timer bar is now able to be clicked through to UI elements underneath when the bar is locked in place.
