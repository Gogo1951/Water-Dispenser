# Water Dispenser // Manual Test Plan

This is the manual test plan for Water Dispenser, the steps to confirm it works before a release is tagged. For what it does, see [README.md](https://github.com/Gogo1951/Water-Dispenser/blob/main/README.md); for how it works, see [README-Technical.md](https://github.com/Gogo1951/Water-Dispenser/blob/main/README-Technical.md).

## Before you start

**Run the whole list on Classic Era, then `/reload` and run it again on TBC Anniversary.** Steps are numbered continuously so you can report "failed on step N."

Gather these once so you are not caught short mid-run:

- **A mage**, high enough to conjure water and food. Most steps use this character.
- **A warlock**, able to create a healthstone, for the healthstone and class-filter steps.
- **A second player** you can trade with, party with, and raid with, running the add-on themselves. Several steps need a real trade window, and one needs them leaving and rejoining your party.
- **Trade partners of three shapes**: a mana user who is not a mage or warlock (priest, paladin, druid, shaman, or hunter), a warrior or rogue, and someone far below your level.
- **Bags with room**, including at least one genuinely empty slot, which is where a split lands. On the mage, enough conjured water to carry 40 of your best rank at once, plus a handful of loose part-stacks.
- **Two part-stacks of one potion that add up to five**, a 3 and a 2 in separate bag slots, not merged.
- **Something you have not configured**, a bandage or a food buff, for the tooltip steps.
- **A bank you can reach**, for one hover in step 7.
- **Four or more different giveable consumables** in bags, for the macro step.
- **A free macro slot** on the character running the macro step.
- **Somewhere safe to take damage**, a target dummy or an open-world mob, for the combat steps.
- **A non-English client**, only for the optional last step.

Unless a step says otherwise you are out of combat, and the settings start where they ship.

This plan covers the riskiest paths rather than every control. It deliberately skips the per-item **Distribute** dropdown, **Factor in the Item's Required Level**, **Include Quantity in Player Tooltip & Announcement Macro**, **Enable Maximum per Session** on its own, the Profiles panel beyond the one check in step 12, rejecting letters typed into an amount box, and the welcome-message toggle. Test those by hand if this release touched them.

## Verify this release's changes

This release stops the add-on tidying your bags while you are just playing, and moves that tidy-up to the moment a trade closes. It also stops a fill acting while you are holding something, drops the split retry, adds a line to your own bag items saying they are set to be given out, and makes your player tooltip and the announcement macro count only what you would really part with. These steps run first because they are the ones this release can have broken.

**Bags are left alone until a trade closes**

**1.** On the mage, out of combat with no trade open, conjure water five or six times so you are carrying a row of small part-stacks. Watch your bags for a full ten seconds: they must **stay** as separate part-stacks. Now drag half a stack into an empty bag slot by hand, so you are holding two stacks of your own making, and wait again: both must stay exactly where you put them. Failure is any stack merging into another on its own while you stand there doing nothing, which is the old behavior this release removed.

**2.** Pick a stack of water up onto your cursor and hold it for ten seconds while your bags change around you, conjuring with the other hand. It must stay on your cursor the whole time and never drop back into your bags. Failure is the item leaving your cursor by itself.

**3.** Still carrying those loose part-stacks, open a trade with your partner and close it without trading anything. Within about a second the part-stacks must pull together into full stacks of 20, leaving at most one partial behind, and everything must be still within two or three seconds. Failure is nothing happening at all, or bags still shuffling ten seconds after the window closed.

**4.** Open **Dispense**. The setting must now read **Combine Partial Stacks After a Trade**, indented under Enable Dispense. Turn it off, and with loose part-stacks in your bags open and close a trade: nothing may combine. Turn it back on while those loose stacks are still sitting there: **nothing may happen at the moment you tick the box**. Only the next trade close may tidy them. Failure is the bags tidying the instant the box is ticked, or the setting still reading "Automatically Combine Partial Stacks in Bags".

**5.** With **Combine Partial Stacks After a Trade** on and loose part-stacks in your bags, open a trade, pick a stack up onto your cursor, and close the trade while still holding it. Nothing may merge, and the item must stay on your cursor. Put it down in an empty slot: nothing may merge then either. Repeat once more, closing the trade and immediately getting into combat: nothing may merge while you are fighting, and nothing may merge once the fight ends either, since the tidy-up only ever runs off a trade closing. Failure is a merge in either case, or the held item being taken off your cursor.

**Filling stands down while you are holding something**

**6.** Open a trade that fills normally, then pick an item up onto your cursor and, still holding it, change your bags: conjure, or loot something. Nothing may leave your cursor, nothing new may enter the trade window while you hold it, and no error may appear. Now drop the item into an empty bag slot: the fill must pick up where it left off and finish filling the window. Failure is the item being dropped out from under you, an item going missing, or the trade never finishing after you put it down.

**The split no longer retries**

**7.** On **Conjured Water**, turn **Enable Reserves** off (it ships on at 20, which would swallow this test) and set the **Everyone** row's **Strangers** box to `5`. Carry a single full stack of 20 and trade a stranger four or five times in a row, closing and reopening the window each time and watching the middle of your screen. One trade slot holding 5 must go over on every pass, 15 must stay in your bags, and the red **"Couldn't split those items"** error must **never** appear. Failure is that error flashing up on any pass, 20 going over, or several small stacks left behind. **Classic Era is the flavor to watch here**: its split has been seen handing back the whole stack instead. If nothing goes over at all, turn on **Enable Warnings When You Run Short** and repeat, and the add-on must say in chat that this client would not split the stack rather than sitting silent.

**Bag item tooltips**

**8.** Open **Inventory Tooltips**. Below **Show Inventory in Player Tooltips** and its indented **Share My Inventory**, a separate un-indented toggle must read **Show Bag Tooltips for Dispensed Items**, on by default. On the mage, hover a stack of conjured water in your bags: the tooltip must end with a **Water Dispenser //** line reading *"This item will be dispensed. Partial stacks of it are combined when a trade closes."* Hover the item you never configured: no such line. Put a stack of water in your bank and hover it there: no line either, because the bank is not your bags. Failure is a missing line, a line on an item you never configured or on a banked one, a line that spills past the bottom edge of the tooltip frame, or the same line appearing twice.

**9.** Work the gates, hovering a stack of conjured water again after each change. Turn **Show Bag Tooltips for Dispensed Items** off: the line must go. Back on, then turn **Enable Dispense** off on the Dispense panel: it must go again. Back on, then turn **Combine Partial Stacks After a Trade** off: the line must shorten to *"This item will be dispensed."* with the stacks sentence gone. Finally turn **Show Inventory in Player Tooltips** off: the bag line must **stay**, because it is its own setting rather than a sub-option. Now log in as the warlock carrying conjured water traded over from the mage and hover it: no line, since water only dispenses while you are playing a mage. Failure is any gate that does nothing, or the line surviving on the warlock.

**Your tooltip and the macro count only what you would really give**

**10.** On the mage, with **Enable Reserves** back on at its shipped 20 for **Conjured Water**, carry exactly 20 water of your best rank and hover yourself. Conjured Water must **not** be listed at all, because the reserve is holding every one of them. Conjure until you carry 40, and hover again: the row must read **20**, the amount past the reserve, not 40. Failure is the raw bag count showing, or a row appearing while the reserve covers everything you have.

**11.** Turn **Enable Dispense** off. Hover yourself: your Water Dispenser block must list nothing. Open **Announcements**: the **Live Preview** must read *"Nothing to announce while Enable Dispense is switched off, under the Dispense tab."* rather than the generic notice telling you to restock your bags. Click the `- Dispenser` macro: it must post nothing at all. Turn Dispense back on, and all three must come back. While you are there, read a count in the announcement: it must read like `x40`, with no space between the `x` and the number. Failure is the old restock wording, a macro that still lists items with dispensing off, a tooltip block still advertising, or a count reading `x 40`.

**Group inventory after a roster change**

**12.** Party with your partner, both running the add-on, and hover each other: each block must list what the other has to give. Have them leave the party and rejoin. Within a few seconds each of you must see the other's list again, without either of you touching your bags. Convert to a raid and check the same. Failure is a rejoined partner reading as empty, or a groupmate's block disappearing and never coming back.

**Mini-map button hide and show**

**13.** Drag the mini-map button to a distinctive spot. On the root **Water Dispenser** panel turn **Enable Mini-map Button** off: the button must disappear. Turn it back on: it must return **to the spot you dragged it to**, not to the default position. `/reload` and confirm it is still there. Then on **Profiles** create a new profile: the button must still be on screen and still respond to clicks, and landing back at the default position here is correct. Switch back to Default and it must return to your spot. Failure is a button that comes back at the default angle after a simple off and on, one that never comes back, or one that stops responding after a profile switch.

When steps 1-13 pass on both flavors, this release's changes are verified. Proceed to `4 - Pre-Launch Review Prompt.md`.

## Core checks

**14.** Log in with the add-on freshly enabled. No Lua error may appear, and a single greeting line must print naming the version. Type `/reload`: it must come back the same way, one greeting and no error. Failure is an error on login or reload, no message, a doubled message, or a version reading as a literal `%s`.

**15.** Type `/wd`. The settings must appear **docked inside the Blizzard Options window**, with Water Dispenser selected in the category list and six children beneath it: **Dispense**, **Dispensed Items**, **Announcements**, **Inventory Tooltips**, **Profiles**, **Diagnostic Tools**, in that order. Close it and reach the same panel two more ways: Shift + Middle-Click on the mini-map button, and clicking Water Dispenser in the Options category list yourself. All three must land on the same docked panel, and each child must open its own page. Failure is nothing happening at all, a standalone window floating free of the Options frame, or a child missing or out of order. **TBC Anniversary is the flavor that historically breaks this**, so an Era-only run has not tested it.

**16.** Get into combat, then type `/wd`, then Shift + Middle-Click the mini-map button. Each must print *"As a safety precaution, the Options Interface cannot be opened during combat."* and the panel must stay shut. Leave combat and wait: it must not open by itself. Failure is the panel opening, silence with no message, or a red `ADDON_ACTION_BLOCKED` error naming the add-on.

**17.** Hover the mini-map button. The tooltip must show the add-on name and version, a **Dispense** row with its current state, a description line, and the **Shift + Middle-Click** hint at the bottom. Left-Click it: the Dispense state must flip **while you are still hovering**. Leave the **Dispense** panel open on screen and Left-Click again: **Enable Dispense** on the open page must flip to match, with the toggles under it appearing or disappearing at the same moment. Failure is a missing tooltip line, a state that only updates once you move away and back, or a panel still showing the old state until you switch pages.

**18.** With **Enable Dispense** on, trade someone who is not in your group. The right consumables must drop into the window on their own. Turn **Enable for Strangers** off and trade them again: nothing must be added. Party up and check **Enable for Party** the same way, then convert to a raid and check **Enable for Raid**, where the defaults must hand over 40 water instead of 20. Failure is a window that fills with its toggle off, stays empty with it on, or uses party amounts in a raid.

**19.** Trade one partner of each shape and check what arrives: a mana user who is not a mage or warlock must get water and food; a warrior or rogue must get food and **no** water; as a mage, another mage must get neither; as a warlock, another warlock must get no healthstone. Then trade the partner far below your level: the water and food handed over must be a rank they can actually use, so check the item tooltips against their level. Failure is any of those getting the wrong list, or your top-rank water going to someone too low to drink it. **Check this on both flavors**: Anniversary has conjured ranks and healthstone tiers that Era does not, so confirm the rank handed over is one that exists on the client you are on.

**20.** Add the potion you are carrying as a 3 and a 2, set its **Everyone** row's **Strangers** box to `5`, and press **Apply**. Trade someone outside your group. **One** trade slot holding 5 must go over, the two part-stacks having been combined in your bags first, and your bags must be left holding none of that potion. Failure is two trade slots of 3 and 2, or only one of the part-stacks going over. Then fill every bag slot so a split has nowhere to land and ask for an amount that needs one, 5 water while carrying only a full stack of 20: nothing may be lost, nothing may be left stuck to your cursor, and no Lua error may appear, with a *Missing:* line naming conjured water the expected outcome when warnings are on.

**21.** With a trade open, click **Clear Trade Window** on the side panel beside the trade frame. Every slot you filled must empty, with nothing left on your cursor. Click **Fill Trade Window**: it must repopulate with the same amounts. Now get into combat with the trade window open and click **Fill Trade Window** again: a chat line must say the game blocks automated trades during combat, and nothing may enter the window then or once the fight ends. Turn **Enable Notifications When Dispensing Is Blocked** off and try the blocked fill once more: it must stay completely silent. Failure is items staying put on a clear, an item stuck to your cursor, anything filling mid-combat, a blocked fill landing after combat, a message with the notification off, or a Lua error.

**22.** On the mage, open a trade and conjure water. Within about a second the water that cast produced must appear in the trade window, and a small part-stack is the correct result: a mid-trade cast deliberately ignores your reserve, your session cap, and the per-class amounts. Cast two or three more times, and each must add its own part-stack with nothing merging them while the window is open. Repeat once with conjured food, and once on the warlock with a healthstone. Failure is a cast adding nothing, the same stack being offered twice, or a Lua error once all six slots are full.

**23.** Under **Announcements**, turn **Enable Announcement Macro** on and drag the `- Dispenser` macro to your action bar. With exactly one giveable item in your bags, click it: the message must read as one complete sentence, with the item as a working link you can shift-click and hover. Now carry four or more different giveable consumables and click again: the message must end in ` ...` with the last item complete, never a half-rendered link, a stray `|`, or a name cut mid-word. Check the **Live Preview** on the panel against what actually posted, and check the channel: Say when ungrouped, Party in a party, Raid in a raid. Failure is a dangling fragment, a literal `%s`, a broken link, a message that fails to send, a preview that disagrees, or the wrong channel.

**24.** Open **Diagnostic Tools** on a fresh login. **Enable Diagnostic Tools** must be **off**, with everything below it hidden. Turn it on and work down the buttons: Start Event Log, open and close a trade, Stop Event Log, then Show Captured Events. The trade's events must still be listed after stopping, and where the report ends in a summary of suppressed traffic, read that block rather than hunting individual lines. Then press Test Event Registration, Test WoW API Endpoints, Probe Trade Context, List Installed Add-ons, Dump Saved Variables, each Validate Data button, and List Library Versions. Finally switch **Enable Diagnostic Tools** off and back on: every output box must be empty again, with the event log reading as nothing captured. Failure is the toggle remembering being on from a previous session, an output box left empty when you first run it, an old report still sitting there after the toggle was switched off and on, or a `FAIL` line. Note which one, and on which flavor.

**25.** *(Optional, and only on a non-English client.)* Log in on another locale, open the settings, trigger the welcome message, hover a bag item set to be dispensed, and click the announcement macro. Every label and message must read in that language with no raw keys like `OPTIONS_BAG_TOOLTIPS` or `TOOLTIP_WILL_DISPENSE_STACKED` showing through, and no literal `%s`, `nil`, or number in the wrong place. Try **Russian** in particular: it is the longest locale here and the first to overflow the macro's limit, so its message must still end cleanly in ` ...` with the last item whole. Failure is a raw key, a broken placeholder, or a Russian message that fails to send.

When every step passes on both Classic Era and TBC Anniversary, manual testing is complete. Proceed to `4 - Pre-Launch Review Prompt.md`.
