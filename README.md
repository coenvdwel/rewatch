# Rewatch

Awesome and minimalistic unit frames addon with clickable action bars on your party members for every HoT you got, which channels down as the HoT runs out. Can be configured to your style and can additionally show action buttons, debuff and more.

[changelog](https://www.curseforge.com/wow/addons/rewatch/pages/changelog) · [github](https://github.com/coenvdwel/rewatch) · [donate](https://www.paypal.com/donate/?hosted_button_id=AXK9MQKC3TLPE&item_name=Rewatch)

![Rewatch](https://raw.githubusercontent.com/coenvdwel/rewatch/master/docs/rewatch.gif)

💡 For the best experience, use either [Clique](https://www.curseforge.com/wow/addons/clique) or mouse-over macros ([here](https://www.dvorakgaming.com/warcraft/class-guides/macros/) and [here](https://wowpedia.fandom.com/wiki/Making_a_macro))

😎 Originally a druid-only addon, now open for all!

## Installation

* Extract to your `World of Warcraft\_retail_\Interface\AddOns` folder

## Getting started

* Click a health bar to target that player
* Click a spell bar to cast that spell on that player, and watch the bar channel down as the HoT runs out
* Type `/rew` to open the options menu, where you can customize styling, spells, buttons, macros, etc!
* There's a small mouse-over nudge at the bottom of the frame to move Rewatch around
* Also try;
  * All: alt-click to cleanse, shift-click to rez
  * Druid: ctrl-click to cast `Nature's Swiftness` + `Regrowth`
  * Paladin: ctrl-click to cast `Lay on Hands`

👉 Create different profiles to allow easy switching between solo-, mythic-, raid- or PVP setup!

🚀 Macro example;

    #showtooltip Lifebloom
    /cast [@mouseover,exists,help] Lifebloom; Lifebloom
