
# 70003
*not released yet*

* Fixed broken default setting values for new users
* Fixed attempts to create tooltip for users that do not exist
* Fixed saving of position of Rewatch frame on reloads
* Optimized buff and debuff checks and handles
* Only do text animation on first load
* Update for WoW version 90005

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