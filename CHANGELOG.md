# Changelog

## [2.0.8] -- 2023-05-09

### Fixed
- Fixed a bug where indeterminate ordering of evet callbacks was makinng the weapon checks for offhand and ranged lag behind
  equipment changes. This will fix a bug for warriors where ElvUI being loaded causes equipping a shield to break the offhand timer.
- Fixed an issue where an outdated version of LibCustomGlow was being pulled (if any other addon loaded by the user included the 
  more up to date version of this library, the bug would not have occurred).

## [2.0.7] -- 2023-01-19

### Changed
- The addon has been confirmed to function properly in 3.4.1 and the Interface tag updated to reflect this.

## [2.0.6] - 2022-12-25

### Fixed
- The LibRangeCheck-2.0 library takes a finite amount of time on first client load to gather the information it needs to 
  function properly. Previously, the code to show and hide bars was blocked until the range checking
  was functional. Now show/hide checks will be run immediately.
- Added some additional cross-checks to ensure bars show and hide when necessary.


## [2.0.5] - 2022-12-24

### Fixed
- Fixed an issue with warrior shields where the offhand timer bar initialisation was
  being broken by a zero attack speed. This might fix a bug warriors have experiencing
  with the offhand timer bar breaking during swaps, but still unclear.
- Timer bar elements are now properly recalculated in full when the player's weapon changes.

## [2.0.4] - 2022-11-24

### Added 
- Seal of Justice custom timer bar color added for Paladins.
- Druids can now enable custom bar visibilities based on their current form.
- Druids can now enable custom bar colours for travel and flight form.

### Fixed
- Druid forms now properly respect the adaptive form index for Moonkin and Tree form
depending on if Moonkin and Tree forms are currently talented.

## [2.0.3] - 2022-11-15

### Fixed
- Addon now uses an updated version of LibClassicSwingTimerAPI, which fixes some lua errors around C_Timers.

## [2.0.2] - 2022-10-11

### Added
- Warrior Bloodsurge glow proc options added
- Bar Positioning menus now also lets the user change bar dimensions there

### Fixed
- Typo in GCD marker settings fixed

## [2.0.1] - 2202-10-08

### Fixed
- Removed an eroneous debug print when druids cast Maul.
- Fixed typo in the settings UI's info panel.

## [2.0.0] - 2022-10-07

The TBC Ret Paladin version of the Addon has been re-written from the ground up to support
every class in WotLK.

### Added
- Support for mainhand/offhand/ranged swing timers.
- Ships tailored and customisable timer configurations for every class in WotLK.
- Some classes (Druid/Hunter/Paladin/Warrior) ship with specific aura/proc monitors that are
  configurable in the settings menu.
- Support for adjustable scale with the mousewheel when the timers are not locked.
- A range finder is now included that can dim the timer when the player is out of range.
  The range estimation is now an option for timer texts, with a new central text option to support it.
- GCD markers now support showing the physical or spell GCD duration, and can be anchored to both
  the end of the swing timer bar, or to the progress bar itself, moving with the timer progress.

### Changed
- SwedgeTimer no longer implements its own Swing Timer engine, it now uses LibClassicSwingTimerAPI, a project by Ralgathor (with contributions from Swedge and Buds) that produces a standardised swing timer API. It takes account of the many different edge cases the WoW swing timer has for each class.
- Timer border and background customisation has been improved.
- Improved timer positioning within the UI powered by LibWindow-1.1.

### Removed
- With the demise of Seal Twisting, some of the Ret Paladin functionality to help with seal
  twisting has been removed. Much of that functionality is generally useful, and has been adapted into the rest of the addon.