# Roguelike Prototype

A semi-procedurally generated, top-down, ARPG, roguelike.  Written in LÖVE (version 0.10.1).

## Playing

Download LÖVE 0.10.1 (https://github.com/love2d/love/releases/tag/0.10.1) and follow the official directions to run the LÖVE app via the directory (https://love2d.org/wiki/Getting_Started#Running_Games).  The included `run.bat` file can also be modified to point to your local copy of LÖVE 0.10.1.

Upon launching the game, pressing the spacebar will spawn a player character.

Keyboard input involves:
* `WASD` for movement
* Left click to attack
* `1`/`2` keys for primary/secondary ability
* `space` to dodge
* `E` to interact
* Holding left-ctrl while attacking or using an ability spends skill points to rank up the attack/skill
* Holding left-shift while attacking or using an ability spends skill points to increase the proficiency of the attack/skill

Connecting gamepads and pressing the start button (based on a default XBox controller) will spawn additional players, although gamepad input is incomplete and unstable.

Changing the `bDebug` flag to `true` in `conf.lua` will enable various debugging visualizations as well as the following debug inputs:
* While holding both left-ctrl and left-shift
  * `F1` prints coordinate data of the mouse cursor position
  * `F2` grants 5000 xp to all active players
  * `F3` teleports all active players to the cursor position
  * `F5` regenerates the current level
  * `F8` respawns all enemies in the current room