# Water Dispenser // Test Plan

Water Dispenser fills the trade window with the water, food, healthstones and other items you set up to give. This time we most want you to try the new mini-map menu that opens when you hover the button.

**Play on Classic Era, Season of Discovery, TBC Anniversary, and WoW Forever.** If something looks wrong, tell us the check number and what you saw on [Discord](https://discord.gg/eh8hKq992Q).

## What's New

1. Hover the mini-map button: a menu opens on the side away from the screen edge, showing whether Dispense is on and what you have left to give, and closes when you move away or press Escape.
2. Click **Toggle** in the menu, then open a trade: the menu should say Off and the line under **Fill Trade Window** should say Dispense is off.
3. Open **More Features** in the menu and flip each switch: the count beside it and the matching switches under `/wd` should follow.
4. Hover a group member who runs the add-on: their tooltip block should be headed "Open Trade!", and turning off **Enable Open Trade! in Player Tooltips** should hide it.
5. Open the AddOns list: Water Dispenser should show its new logo.

## Everything Else

6. Trade a stranger, a party member and a raid member: each should get the right items, with 40 water in a raid instead of 20.
7. Trade a warrior or rogue, then a much lower-level player: the warrior or rogue gets food but no water, and the low-level player gets water they can drink.
8. As a mage or warlock, click a conjure button under **Fill Trade Window**: it should make a rank your partner can use and drop it straight into the trade.
9. As master looter in a dungeon or raid, open a trade: it should stay empty until you click **Fill Trade Window**.
10. Hover a group member who runs the add-on: their tooltip should list what they have to give, and a warlock's should show their Improved Healthstone rank.
11. Click the `- Dispenser` macro solo and in a raid: it should post your leftovers to Say or Raid with clickable item links.
12. Type `/wd`, then click **Water Dispenser Options** in the mini-map menu, first out of combat and then in combat: the options should open only out of combat.
13. On WoW Forever, fight something while hovering group members and conjuring: no errors, and the tooltips come back once the fight ends.
