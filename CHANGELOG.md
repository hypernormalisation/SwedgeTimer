# 1.2.0

## Features

- GCD underlay color settings include alpha
- option to change borders
- text on the left and right can be swapped (doesn't imports old setting)
- texture on bar have a fixed scale by default and is not rescaled to the current progress, can be changed to old look

## Fixes

- extra logic for more haste detection for GCD with Flash of Light

# 1.1.0

## Fixes

- multiplicative spell haste from Kil'Jaedin fight's "Breath: Haste" buff is now properly taken into account when the GCD marker positions are calculate.
- accounted for an issue where the UnitAttackSpeed API endpoint sometimes returns 0, typically on first load, which introduced infinities in swing timer calculations that persisted until a player action was taken.
- Seal of the Crusader snapshotting has been redone, such that haste changes can now also be processed while the snapshotting is in effect.
- the lag compensation system now recalculates impossible twists when haste effects change midswing.
- the swing timer bar is now able to be clicked through to UI elements underneath when the bar is locked in place.
- the swing timer now resets properly under a very fringe case where the user is in the attacking state and casting a spell when their swing timer reaches zero. This triggers an almost "phantom hit" in the game engine, setting your melee attack on cooldowin. It can be circumvented by using `/stopattack` in macros when casting to ensure no swings are lost.