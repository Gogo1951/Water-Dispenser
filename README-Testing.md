# Water Dispenser // Manual Test Plan

This is the manual test plan for Water Dispenser, the steps to confirm it works before a release is tagged. For what it does, see [README.md](https://github.com/Gogo1951/Water-Dispenser/blob/main/README.md); for how it works, see [README-Technical.md](https://github.com/Gogo1951/Water-Dispenser/blob/main/README-Technical.md).

## Before you start

**Run the whole list on Classic Era, then `/reload` and run it again on TBC Anniversary.** Steps are numbered continuously so you can report "failed on step N."

Gather these once so you are not caught short mid-run:

- **A mage**, high enough to conjure water and food. Most steps use this character.
- **A warlock**, able to create a healthstone, for the healthstone and talent-row steps.
- **A second player** you can trade with, party with, and raid with. Several steps need a real trade window, and one needs them running the add-on too.
- **Trade partners of three shapes** — a mana user who is not a mage or warlock (priest, paladin, druid, shaman, or hunter), a warrior or rogue, and someone far below your level.
- **Bags with room**, including at least one genuinely empty slot, which is where a split lands. On the mage, two full stacks of conjured water and a couple of loose part-stacks.
- **Five of one stackable potion**, for splitting an exact amount out of a stack.
- **Four or more different giveable consumables** in bags, for the macro step.
- **A free macro slot** on the character running the macro step.
- **Somewhere safe to take damage** — a target dummy or an open-world mob — for the combat steps.
- **A non-English client**, only for the optional last step.

Unless a step says otherwise you are out of combat, and the settings start where they ship.

This plan covers the riskiest paths rather than every control. It deliberately skips the per-item **Distribute** dropdown, **Factor in Usage Level Requirements**, **Only Dispense When Playing These Classes**, **Share My Inventory** on its own, removing an item, and the welcome-message toggle — test those by hand if this release touched them.

## Verify this release's changes

This release rebuilds the item configuration panel, changes how an exact amount leaves your bags, and moves group inventory onto its own sharing path. These steps run first because they are the ones this release can have broken.

**Dispensed Items panel**

**1.** Type `/wd` and open **Dispensed Items**. The list on the left must show **Conjured Water**, **Conjured Food**, and **Healthstones**, each with an item icon, and **Add an Item** at the bottom. Open **Conjured Water**: under **Distribution** there must be **Strangers**, **Party**, and **Raid** columns, an **Everyone** row directly under the headings, and one row per class with the class name in its class color and a typed number box in every cell. Failure is a missing entry, a blank icon, a missing column, or a cell you cannot type in.

**2.** Type `15` into the Everyone row's **Strangers** box and press the **Apply** button that appears inside the box. Every class's Strangers box must become 15, with Party and Raid untouched. Now change one class's Strangers box to something else: the Everyone box above it must go blank, because the column no longer agrees. Failure is a column that does not fill, or an Everyone box still showing a number when the classes below disagree.

**3.** Type letters into any class box. It must be refused with *"Enter a number of items, or 0 to never dispense this."*, and the old number must stay. Then open **Healthstones** and type `5` into any box: it must be refused with a message saying the most it takes is 1. Failure is either being quietly accepted, or a value that saves and then reverts on its own.

**Exact amounts and stack splitting**

**4.** Open **Add an Item**, add the potion you have five of, then set its **Strangers** amount to `1`. Trade someone who is not in your group. Exactly one potion must go into the trade window, and your bags must be left holding four. Failure is five going over, nothing going over, or your bags ending on any number but four.

**5.** On Conjured Water, turn **Enable Reserves** off — it ships on at 20, which would swallow this test — and set your partner's class to `5` in the Strangers column. Carry a single full stack of 20 and open the trade. Five must go over and 15 must stay, and the stack must be broken exactly once rather than whittled down five separate times. Failure is 20 going over, or a burst of bag shuffling that leaves several small stacks behind. **Classic Era is the flavor to watch here** — its split has been seen handing back the whole stack instead. If nothing goes over at all, turn on **Enable Warnings When You Run Short** and repeat: the add-on must say in chat that this client would not split the stack, rather than sitting silent.

**6.** Fill every bag slot so a split has nowhere to land, then ask for an amount that needs one — 5 water while carrying only a full stack of 20. Nothing may be lost, nothing may be left stuck to your cursor, and no Lua error may appear. Failure is a vanished stack, an item glued to your pointer, or an error.

**Conjuring during a trade**

**7.** On the mage, open a trade and conjure water. Within about a second the water that cast produced must appear in the trade window, and a small part-stack is the correct result — a mid-trade cast deliberately ignores your reserve, your session cap, and the per-class amounts. Cast two or three more times: each must add its own part-stack, and nothing may merge them while the trade is open. Repeat once with conjured food, and once on the warlock with a healthstone. Failure is a cast adding nothing, the same stack being offered twice, or a Lua error once all six slots are full.

**Combining partial stacks**

**8.** Close the trade. Out of combat, conjure water four or five times and watch your bags: the part-stacks must pull together into full stacks of 20 within a second or so of the last cast, leaving at most one partial behind. Then pick a stack up onto your cursor and hold it there while your bags change — conjure with the other hand, or loot something. It must stay on your cursor. Failure is a row of small stacks that never settles, stacks that visibly churn, or an item dropping back into your bags out from under you.

**Maximum per Session**

**9.** On Conjured Water turn **Enable Maximum per Session** on and set it to `2`, leave **Enable Warnings When You Run Short** off, and trade the same stranger twice without reloading. The first trade must hand over 2 — let your partner accept first and click Accept second, since that ordering is what used to lose the credit. The second trade must hand over nothing **and print a line saying the cap is why**, even with warnings off. Trade someone else and they must still get their own 2. Failure is the second trade handing over another 2, or an empty window with nothing said.

**10.** Without reloading, raise **Maximum per Session** to `10` and trade that same player again. They must receive items straight away — the count starts over from the change, not from what they had already been given. Failure is the window staying empty until you reload.

**Inventory in player tooltips**

**11.** Hover your own character. A **Water Dispenser // Open Trade!** block must appear at the bottom of the tooltip, after a blank line, listing what you are carrying from your Dispensed Items list. Group with your partner running the add-on and hover them: their block must list what they are carrying. Hover a player outside your group: no block at all. Failure is a missing block on yourself or on a group member, or any block on a stranger.

**12.** Hover the warlock. A `Healthstone (Rank N/2)` row must show whether or not they are carrying a stone, where N is their Improved Healthstone rank. Now turn **Enable Dispense** off, from the options panel or with a Left-Click on the mini-map button: your own block must vanish, and your partner's view of you must clear within a few seconds. Turn it back on and both must return. Failure is no healthstone row on a warlock, or a block surviving with Dispense off.

When steps 1-12 pass on both flavors, this release's changes are verified. Proceed to `4 - Pre-Launch Review Prompt.md`.

## Core checks

**13.** Log in with the add-on freshly enabled. No Lua error may appear, and a single greeting line must print naming the version. Type `/reload`: it must come back the same way — one greeting, no error. Failure is an error on login or reload, no message, a doubled message, or a version reading as a literal `%s`.

**14.** Type `/wd`. The settings must appear **docked inside the Blizzard Options window**, with Water Dispenser selected in the category list and **Dispensed Items**, **Announcements**, **Profiles**, and **Diagnostic Tools** beneath it in that order. Close it, then reach the same panel two more ways: Shift + Middle-Click on the mini-map button, and clicking Water Dispenser in the Options category list yourself. All three must land on the same docked panel, and each child must open its own page. Failure is nothing happening at all, or a standalone window floating free of the Options frame. **TBC Anniversary is the flavor that historically breaks this**, so an Era-only run has not tested it.

**15.** Get into combat, then type `/wd`, and Shift + Middle-Click the mini-map button. Each must print *"As a safety precaution, the Options Interface cannot be opened during combat."* and the panel must stay shut. Leave combat and wait: it must not open by itself. Failure is the panel opening, silence with no message, or a red `ADDON_ACTION_BLOCKED` error naming the add-on.

**16.** Hover the mini-map button. The tooltip must show the add-on name and version, a **Dispense** row with its current state, a description line, and the **Shift + Middle-Click** hint at the bottom. Left-Click it: the Dispense state must flip **while you are still hovering**, and must match **Enable Dispense** in the settings. Drag the button around the mini-map, `/reload`, and confirm it is still where you dropped it. Failure is a missing tooltip line, a state that only updates once you move away and back, the two controls disagreeing, or a button that snaps back on reload.

**17.** With **Enable Dispense** on, trade someone who is not in your group. The right consumables must drop into the window on their own. Turn **Enable for Strangers** off and trade them again: nothing must be added. Party up and check **Enable for Party** the same way, then convert to a raid and check **Enable for Raid** — in a raid the defaults must hand over 40 water instead of 20. Failure is a window that fills with its toggle off, stays empty with it on, or uses party amounts in a raid.

**18.** Trade one partner of each shape and check what arrives: a mana user who is not a mage or warlock must get water and food; a warrior or rogue must get food and **no** water; as a mage, another mage must get neither; as a warlock, another warlock must get no healthstone. Failure is any of those four getting the wrong list.

**19.** Trade the partner far below your level. The water and food handed over must be a rank they can actually use — check the item tooltips against their level. Failure is your top-rank water going to someone too low to drink it. **Check this on both flavors**: Anniversary has conjured ranks and healthstone tiers that Era does not, so confirm the rank handed over is one that exists on the client you are on.

**20.** With a trade open, click **Clear Trade Window** on the side panel beside the trade frame. Every slot you filled must empty, with nothing left on your cursor. Click **Fill Trade Window**: it must repopulate with the same amounts. Failure is items staying put, an item stuck to your cursor, or a fill that does nothing.

**21.** Get into combat with a trade window open and click **Fill Trade Window**. A chat line must say the game blocks automated trades during combat, and nothing may enter the window. Conjure while still in combat: nothing may reach the window then or after the fight, and your bags must not be tidied. Leave combat with the trade still open: nothing may happen on its own, and Fill must then work normally. Finally turn **Enable Notifications When Dispensing Is Blocked** off and try the blocked fill again — it must stay completely silent. Failure is anything filling mid-combat, a blocked fill landing once combat ends, bags reshuffling during the fight, a message with the notification off, or a Lua error.

**22.** Under **Announcements**, turn **Enable Announcement Macro** on and drag the `- Dispenser` macro to your action bar. With exactly one giveable item in your bags, click it: the message must read as one complete sentence, with the item as a working link you can shift-click and hover. Now carry four or more different giveable consumables and click again: the message must end in ` ...` with the last item complete — never a half-rendered link, a stray `|`, or a name cut mid-word. Check the **Live Preview** on the panel against what actually posted, and check the channel — Say when ungrouped, Party in a party, Raid in a raid. Failure is a dangling fragment, a literal `%s`, a broken link, a message that fails to send, a preview that disagrees, or the wrong channel.

**23.** Open **Diagnostic Tools** on a fresh login. **Enable Diagnostic Tools** must be **off**, with everything below it hidden. Turn it on and work down the buttons: Start Event Log, open and close a trade, Stop Event Log, then Show Captured Events — the trade's events must still be listed after stopping. Then press Test Event Registration, Test WoW API Endpoints, Probe Trade Context, List Installed Add-ons, Dump Saved Variables, each Validate Data button, and List Library Versions. Failure is the toggle remembering being on from a previous session, an output box left empty, "(no events captured)" after you clearly triggered activity, or a `FAIL` line — note which one, and on which flavor.

**24.** Open **Profiles**. Your character must be on **Default**. Create a new profile: the settings must reset to defaults, the Dispensed Items list must rebuild to the three built-ins, and the announcement macro must follow. Switch back to Default: your settings and your macro must both return. Failure is stale entries surviving the switch, settings not restoring, or a macro still advertising the other profile's items.

**25.** *(Optional, and only on a non-English client.)* Log in on another locale, open the settings, trigger the welcome message, and click the announcement macro. Every label and message must read in that language with no raw keys like `OPTIONS_DISPENSE_MASTER` showing through, and no literal `%s`, `nil`, or number in the wrong place. Try **Russian** in particular — it is the longest locale here and the first to overflow the macro's limit, so its message must still end cleanly in ` ...` with the last item whole. Failure is a raw key, a broken placeholder, or a Russian message that fails to send.

When every step passes on both Classic Era and TBC Anniversary, manual testing is complete. Proceed to `4 - Pre-Launch Review Prompt.md`.
