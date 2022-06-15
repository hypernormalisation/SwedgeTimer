# 1.3.0

## Features

- The player now has finer control over when the bar is automatically hidden because of no seal or the player being out of combat
  
![image](https://user-images.githubusercontent.com/52763122/173918272-a6784d57-ba01-4723-9b14-a913a39cf89c.png)

- A new "deadzone" feature has been added, that shows the region of the bar near the end of a player's swing where they are locked into their current seal this swing due to latency. This feature is enabled by default, but can be disabled. The deadzone alpha, texture, and color may all be changed in the settings menu.

![image](https://user-images.githubusercontent.com/52763122/173918367-7c92aef6-6f87-4f42-a2e7-d13ed5148315.png)

![image](https://user-images.githubusercontent.com/52763122/173918444-2fda281e-30a8-41d8-826c-b1283c02730f.png)

## Fixes

- Fixed a call that should have been suppressed when the player class is not paladin that produced a small lua error.
- The backplane is now drawn on the same frame strata, which should lead to fewer incidences where intersecting UI components are above the backplane but below the bar elements.
- Fixed an issue where the right text was drawn too close to the end of the bar on the bar being moved. Text is now generally further away from the bar borders.