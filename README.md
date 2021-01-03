![logo](https://media.forgecdn.net/attachments/330/360/logo.png)

Rewatch is an addon to help you monitor your healing-over-time (HoT) spells as a druid. There's an easy main window which you can move around, which will contain six bars for every target; a health bar, energy-/rage-/mana bar, `Lifebloom` bar, `Rejuvenation` bar, `Regrowth` bar and a `Wild Growth` bar. Simply click a spell bar to cast that spell on that specific player and watch the clicked bar channel down as the corresponding HoT spell runs out.

Party- and raid healing has never been so easy!

⚠ For the best experience, use either Clique or mouse-over macros!

[changelog](https://www.curseforge.com/wow/addons/rewatch/pages/changelog) · [github](https://github.com/coenvdwel/rewatch) · [donate](https://www.paypal.com/donate/?hosted_button_id=AXK9MQKC3TLPE&item_name=Rewatch)

# Installation

* Extract into your `World of Warcraft\_retail_\Interface\AddOns` folder
* Log in to your Druid

# Getting started

* Click a health bar to target that player
* Click a spell bar to cast that spell on that player, and watch as the bar channels down as the HoT runs out
* Alt-click on a health bar to cast `Nature's Cure` on that player
* Shift-click on a health bar to `Revive` / `Rebirth` that player
* Ctrl-click on a health bar to cast `Innervate` on that player
* Check out the Esc > Interface > AddOns > Rewatch window for customization

# Example

![one](https://media.forgecdn.net/attachments/330/369/one.jpg) This is you (hi)

![two](https://media.forgecdn.net/attachments/330/370/two.jpg) Now hover... and click!

![three](https://media.forgecdn.net/attachments/330/371/three.jpg) And just watch as it runs down

![four](https://media.forgecdn.net/attachments/330/372/four.jpg) ...for ALL OF YOUR HOTS OMG!!

# Q&A

**Help, my frame is weird?**

Type `/rew sort`

**What is Clique or mouse-over macros?**

Clicking your spells and switching targets makes you so much slower. Get more efficient and switch today - regardless if you use Rewatch or not.

Macros are small tweaks to your actionbar spells, changing their behavior so they attempt to target the player that is under your mouse, without the need to actually click (target) them. You could still do all of that, if you really want - but once you go macro, you'll never go back(ro)!

Clique helps you achieve the same thing, basically, but without the need for you to actually type out these few macros.

**Tell me about those macros?**

Quite simple; hit Esc > Macros and choose Character Specific. Then click New, give it a name (eg "LB") and click the ❓ icon. Then copy-paste below code, save it and drag the macro icon onto your toolbar, replacing the 'old' version of your spell. Do this for all spells you want to be modified (eg `Lifebloom`, `Rejuvenation`, `Regrowth`, `Wild Growth`, `Swiftmend` and `Iron Bark`). That's all!

Macro:

```#showtooltip Lifebloom```

```/cast [target=mouseover,exists,help] Lifebloom; Lifebloom```