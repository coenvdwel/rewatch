# 80000

Complete rewrite of the addon!!

Everything is different, yet everything feels the same!

* Sorry - your configs are all lost 😢
* Completely new system to manage settings through profiles
* Major improvements in memory and CPU usage
* Support to modify the spell bars!
* Support for other classes!
* Damage taken bar is gone again - aggro bar is back
* Fixed shapeshift mana/rage bar color changes
* Removed individually movable frames feature

## TODO

* Buttons (+ cooldown gcd + highlight on debuff)
* Germination bar
* Swiftmend (verdant infusion) and nourish extensions
* Show bar spell stacks (?)
* Options / profiles
 * Hidden/hide solo as part of profiles
 * activate profile through commandline
* Update README
* Rezzing message...
* Fix Cenarion Ward spell bar (and add it by default, when specced?)

## NICE TO HAVE

* Improve fixed spellbar color list
* Add mana size bar option
* Make something better than /rew add henk always
* Add some mythic helpers (affixes, default spells, ...)
* Show stacks and cooldown timer on player debuffs
* Small main frame hover buttons for lock/unlock and options

---

# 70003

* Fixed broken default setting values for new users
* Fixed attempts to create tooltip for users that do not exist
* Fixed saving of position of Rewatch frame on reloads
* Optimized buff and debuff checks and handles
* Only do text animation on first load
* Update version for Shadowlands patch (9.0.5)

# 70002

* Added "Show Damage Taken" option!

> Renders a small, red damage distribution bar for each player while in combat, indicating damage taken in the last 5 seconds. Hovering the health bar shows the exact DTPS.

* Added a debuff icon!

> Shows a small icon on a player bar affected with a debuff, if you can cleanse it.

* Added support for `Verdant Infusion` (legendary proc)!
* Fixed `Clearcasting` set and reset, changed indication to border highlight instead
* Fixed 'running up' of `Wild Growth` bar with cooldown
* Fixed scaling issues with frames and fonts, and allowing scaling up to 500%
* Fixed Lua errors when using checkboxes from the Interface options
* Fixed name rendering on initial game startup, adding typewriter effect to player frame loading
* Fixed rez/innervate /say messages where no longer allowed outside instances, fall back to /emote instead
* Performance improved for `Earth Shield` retrieval (Shaman)
* Performance improved for name rendering
* Vertically centralized the role icons
* Removed frame flash on sorting
* Player frame mouse-over highlight is less intense, so health remains better visible
* Prevent refreshing hots (`Flourish`, `Verdant Infusion`, ...) to resize bar scale
* No longer mark frames red for aggro (cluttered, and we have DTPS now!)
* Updated some default settings to be more visible (OOR transparency, font size, ...)
* Updated texts, images, links and everything so it's all nice and fancy again

# 70001

* Update version for Shadowlands (9.0.2)

# 70000

* Bugfix API changes for Shadowlands (9.0.1)