# Dimensional Platformer

A Metroidvania platformer. Written in LÖVE (version 0.11.2).

## Playing

Download LÖVE 11.2 (https://github.com/love2d/love/releases/tag/11.2) and follow the official directions to run the LÖVE app via the directory (https://love2d.org/wiki/Getting_Started#Running_Games).  The included `run.bat` file can also be modified to point to your local copy of LÖVE 11.2.

Both keyboard and gamepad (default values for XBox controller) are supported.

Keyboard input involves:
* `WASD` or arrow keys to move
* `Z` to jump, double jump, or wall jump
* Hold `Z` in the air to glide
* `X` to dash
* `1`/`2` to shift dimensions

Gamepad input involves:
* Left stick or d-pad to move
* `A` button to jump, double jump, or wall jump
* Hold `A` button in the air to glide
* `X` button to dash
* Shoulder buttons to shift dimensions

Changing the `bDebug` flag to `true` in `conf.lua` will enable various debugging visualizations as well as the following debug inputs:
* While holding both left-ctrl and left-shift
  * `F1` prints coordinate data of the mouse cursor position
  * `F3` teleports all active players to the cursor position