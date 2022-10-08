# Changelog

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