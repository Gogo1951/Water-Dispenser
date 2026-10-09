# Water Dispenser // Test Plan

Water Dispenser fills the trade window with the water, food, healthstones and other items you set up to give. This time we most want you to try the new panel beside the trade window: its status line and its conjure buttons.

**Play on Classic Era, Season of Discovery, TBC Anniversary, and WoW Forever.** If something looks wrong, tell us the check number and what you saw on [Discord](https://discord.gg/eh8hKq992Q).

## What's New

1. Open a trade and read the line under **Fill Trade Window**: it should say what went in, or why the window stayed empty.
2. As a mage or warlock, open a trade with a lower-level player and click a conjure button under **Fill Trade Window**: it should make a rank they can use and drop it straight into the trade.
3. As master looter in a dungeon or raid, open a trade: it should stay empty until you click **Fill Trade Window**.
4. Turn on **Enable Maximum per Player** for an item and trade the same player past that amount: the item should stop going over, with a note in chat.
5. Hover the mini-map button while carrying things to give: the tooltip should list what you can give right now.
6. Hover a warlock in your group: their tooltip should show their Improved Healthstone rank, such as *Improved Healthstone 2/2*.
7. Under **Dispensed Items**, set every amount on an item to 0: a line at the top of its page should say nothing goes out yet.

## Everything Else

8. Trade a stranger, a party member and a raid member: each should get the right items, with 40 water in a raid instead of 20.
9. Trade a warrior or rogue, then a much lower-level player: the warrior or rogue gets food but no water, and the low-level player gets water they can drink.
10. As a mage, conjure water with a trade open: the new water should go straight into the window.
11. Hover a group member who runs the add-on: their tooltip should list what they have to give.
12. Turn on the `- Dispenser` macro under **Announcements** and click it: it should post your leftovers to Say, Party or Raid with clickable item links.
13. Type `/wd`, then Shift + Middle-Click the mini-map button, first out of combat and then in combat: the options should open only out of combat.
14. On WoW Forever, fight something while hovering group members and conjuring with a trade open: no errors, and the tooltips come back once the fight ends.
