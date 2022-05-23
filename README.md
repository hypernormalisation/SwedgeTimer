# swedgetimer
A seal twisting swing timer addon for Retribution Paladins in WoW Classic TBC.

![image](https://user-images.githubusercontent.com/52763122/169720056-0098d0d7-e283-40e1-bbb2-d96c7990bb3d.png)

## What is SwedgeTimer?

SwedgeTimer is a standalone swing timer bar to help Retribution Paladins seal twist more effectively.
It is not a WeakAura, it is built from the ground up in lua, and does not use the WeakAura API in any way.

SwedgeTimer replicates all the standard features of the current WeakAura state-of-the-art, including the GCD underlay, timing markers, and colour coding based on active seals, while adding new features like dynamic GCD marker positioning and a late-twist detection system.

It is extensively configurable in both appearance and functionality.
![image](https://user-images.githubusercontent.com/52763122/169720281-d694beda-bf6c-48bb-8816-0f05b18adf6f.png)

The addon does not aim to replace any of the other components of a typical Ret UI or heads-up-display.
You can use it with e.g. [Surv's seal timer and proc tracker](https://wago.io/zKo3ViLqJ), purpose-built to work with SwedgeTimer, to arrive at a complete Ret UI.

## Why use this over a WeakAura swing timer?

There are many advantages in using SwedgeTimer over convention WeakAura swing timers.

See the wiki for more information: [Why use SwedgeTimer](https://github.com/hypernormalisation/SwedgeTimer/wiki/Why-use-SwedgeTimer)

## Install Instructions

It is recommended to install the addon from either Curseforge via the Curse Client, or from the Wago.io provider on the WoWUp Client:

- https://www.curseforge.com/wow/addons/swedgetimer
- https://addons.wago.io/addons/swedgetimer

This way, your addon will be automatically updated when a new release comes out.

If you want to install the addon manually, simply download the `SwedgeTimer.zip` file from the latest release on [the releases page](https://github.com/hypernormalisation/SwedgeTimer/releases).

## Usage Instructions

SwedgeTimer's config can be opened with the slashcommand `\st` in the chat box, or via the addon interface options in the WoW menu.
The bar itself can be clicked and dragged, and then locked inplace when the player is happy with the positioning via. the config menu.

For a full description of what each setting does, see [the relevant wiki page](https://github.com/hypernormalisation/SwedgeTimer/wiki/Settings-Explained).

