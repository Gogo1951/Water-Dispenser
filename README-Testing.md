# Water Dispenser // Manual Test Plan

This is the manual test plan for Water Dispenser, the steps to confirm it works before a release is tagged. For what it does, see [README.md](https://github.com/Gogo1951/Water-Dispenser/blob/main/README.md); for how it works, see [README-Technical.md](https://github.com/Gogo1951/Water-Dispenser/blob/main/README-Technical.md).

## Before you start

**Run the whole list on Classic Era, then `/reload` and run it again on TBC Anniversary.** Steps are numbered continuously so you can report "failed on step N."

Gather these once so you are not caught short mid-run:

- **A mage**, high enough to conjure water and food. Most steps use this character.
- **A warlock**, able to create a healthstone, for the healthstone and tooltip steps.
- **A second player** you can trade with, party with, and raid with, running the add-on themselves. Several steps need a real trade window, and one needs them leaving and rejoining your party.
- **Trade partners of three shapes** — a mana user who is not a mage or warlock (priest, paladin, druid, shaman, or hunter), a warrior or rogue, and someone far below your level.
- **Bags with room**, including at least one genuinely empty slot, which is where a split lands. On the mage, two full stacks of conjured water and a couple of loose part-stacks.
- **Two part-stacks of one potion that add up to five** — a 3 and a 2 in separate bag slots, not merged.
- **A full stack of a stackable trade good plus a loose 1** of the same thing — Runecloth is ideal.
- **Four or more different giveable consumables** in bags, for the macro step.
- **A free macro slot** on the character running the macro step.
- **Somewhere safe to take damage** — a target dummy or an open-world mob — for the combat steps.
- **A non-English client**, only for the optional last step.

Unless a step says otherwise you are out of combat, and the settings start where they ship.

This plan covers the riskiest paths rather than every control. It deliberately skips the per-item **Distribute** dropdown, **Factor in Usage Level Requirements**, **Include Quantity in Player Tooltip & Announcement Macro**, **Enable Reserves** and **Enable Maximum per Session** on their own, removing an item, rejecting letters typed into an amount box, and the welcome-message toggle — test those by hand if this release touched them.

## Verify this release's changes

This release breaks the settings into their own panels, rewrites how the trade window is filled so a partner receives one stack instead of a slot per scrap, and stops the add-on repeating itself to the group. These steps run first because they are the ones this release can have broken.

**Settings moved to their own panels**

**1.** Type `/wd`. Under Water Dispenser the category list must now read **Dispense**, **Dispensed Items**, **Announcements**, **Inventory Tooltips**, **Profiles**, **Diagnostic Tools**, in that order. Open each and confirm the settings landed where they belong: **Dispense** holds Enable Dispense with Raid, Party, and Strangers indented under it, then Automatically Combine Partial Stacks in Bags, Enable Warnings When You Run Short, and a **Combat** section at the bottom. **Inventory Tooltips** holds Show Inventory in Player Tooltips with Share My Inventory indented under it. **Announcements** holds only the macro toggle and its preview. The root panel holds the welcome message, the mini-map button, /Commands, Feedback & Support, and a version line. Failure is a missing panel, a panel out of order, or a setting still sitting on its old page — Dispense on the root panel, or the tooltip pair on Announcements.

**2.** On the root panel, read the four **Feedback & Support** addresses end to end. Each must show its whole address inside the box, the long CurseForge one included, which used to be cut off mid-address with no way to read the rest. Click into one and select the text: it must select and copy but refuse to be edited. The last line of the panel must read the word *Version* followed by the version number. Failure is an address truncated in the box, a box you can type into, or a version line missing its word.

**3.** Leave the **Dispense** panel open on screen and Left-Click the mini-map button. **Enable Dispense** on the open panel must flip to match, with the three scope toggles under it appearing or disappearing at the same moment. Click it back and they must return. Failure is the panel still showing the old state until you switch pages and come back.

**Dispensed Items**

**4.** Open **Dispensed Items**. The list on the left must read **Conjured Water**, **Conjured Food**, **Healthstone** — singular, not "Healthstones" — each with an item icon, and **Add an Item** at the bottom. Open **Add an Item** and drop down **Available Items**: the list must be in alphabetical order by item name. Add one: it must appear in the list on the left with **no chat message** announcing it. Then type a number into any cell of the **Distribution** grid: the small accept button inside the box must read **Apply**, not "Okay". Failure is a picker in some other order (item names shuffled with no pattern), a "Saved:" line in chat, or a button labeled Okay.

**One stack, not a slot per scrap**

**5.** Open **Add an Item** and add the potion you are carrying as a 3 and a 2, then set the **Everyone** row's **Strangers** box to `5` and press **Apply**. Trade someone who is not in your group. **One** trade slot holding 5 must go over — the two part-stacks combined in your bags first — and your bags must be left holding none of that potion. Failure is two trade slots of 3 and 2, or only one of the two part-stacks going over.

**6.** On **Conjured Water**, turn **Enable Reserves** off — it ships on at 20, which would swallow this test — and set the **Everyone** row's **Strangers** box to `5`. Carry a single full stack of 20 and trade a stranger. **One** slot holding 5 must go over, 15 must stay in your bags, and the stack must be broken exactly once rather than whittled down five separate times. Failure is 20 going over, several small stacks left behind, or nothing going over at all. **Classic Era is the flavor to watch here** — its split has been seen handing back the whole stack instead. If nothing goes over, turn on **Enable Warnings When You Run Short** and repeat: the add-on must say in chat that this client would not split the stack, rather than sitting silent.

**7.** Add the stackable trade good you carry as a full stack **plus a loose 1**, and set its **Everyone** row's **Strangers** box to `2`. Trade a stranger. Exactly **one** trade slot holding 2 must go over, never two slots of 1 each, and your bags must be left holding a total of two fewer in any arrangement; whatever loose scrap the shaping left behind pulls back together once the trade closes. Failure is the loose 1 going over on its own, two separate slots of 1, or the trade stopping at 1.

**8.** Still on **Conjured Water** with **Enable Reserves** off, set the **Everyone** row's **Strangers** box to `40`. Carry exactly two full stacks of 20 and trade a stranger. Both stacks must go over — two trade slots, 40 in total — leaving you with no conjured water. Failure is one stack going over while the other sits in your bags, a third helping being conjured out of nowhere, or the bags being shuffled around to build something that is already there.

**9.** Repeat step 6 three or four times in a row — open the trade, watch it fill, close it, let the bags settle — and watch the middle of your screen each time. The red **"Couldn't split those items"** error must never appear, even though the trade fills correctly. Failure is that error flashing up on any pass.

**10.** Fill every bag slot so a split has nowhere to land, then ask for an amount that needs one — 5 water while carrying only a full stack of 20. Nothing may be lost, nothing may be left stuck to your cursor, and no Lua error may appear; a *Missing:* line naming conjured water is the expected outcome with warnings on. Failure is a vanished stack, an item glued to your pointer, or an error.

**Group inventory**

**11.** Party with your partner, both running the add-on, and hover each other: each block must list what the other is carrying. Now have them leave the party and rejoin. Within a few seconds their block must show your list again without you touching your bags. Then change an amount on one of your items: their view of you must update to match. Failure is a rejoined partner seeing nothing until you loot something, or a settings change never reaching them.

**Tooltips only list what you would actually hand over**

**12.** On the warlock, carry some conjured water traded over from the mage, and hover yourself. **Conjured Water must not be listed** — it is set to dispense only while you are playing a mage — while the `Healthstone (Rank N/2)` row must still show. Now open **Dispensed Items** > **Conjured Water** and tick **Warlock** under **Only Dispense When Playing These Classes**: the water must appear in your block. Untick it and it must go again. Failure is water listed on a warlock with the class unticked, or a missing healthstone row.

When steps 1-12 pass on both flavors, this release's changes are verified. Proceed to `4 - Pre-Launch Review Prompt.md`.

## Core checks

**13.** Log in with the add-on freshly enabled. No Lua error may appear, and a single greeting line must print naming the version. Type `/reload`: it must come back the same way — one greeting, no error. Failure is an error on login or reload, no message, a doubled message, or a version reading as a literal `%s`.

**14.** Type `/wd`. The settings must appear **docked inside the Blizzard Options window**, with Water Dispenser selected in the category list and its six children beneath it. Close it, then reach the same panel two more ways: Shift + Middle-Click on the mini-map button, and clicking Water Dispenser in the Options category list yourself. All three must land on the same docked panel, and each child must open its own page. Failure is nothing happening at all, or a standalone window floating free of the Options frame. **TBC Anniversary is the flavor that historically breaks this**, so an Era-only run has not tested it.

**15.** Get into combat, then type `/wd`, and Shift + Middle-Click the mini-map button. Each must print *"As a safety precaution, the Options Interface cannot be opened during combat."* and the panel must stay shut. Leave combat and wait: it must not open by itself. Failure is the panel opening, silence with no message, or a red `ADDON_ACTION_BLOCKED` error naming the add-on.

**16.** Hover the mini-map button. The tooltip must show the add-on name and version, a **Dispense** row with its current state, a description line, and the **Shift + Middle-Click** hint at the bottom. Left-Click it: the Dispense state must flip **while you are still hovering**. Drag the button around the mini-map, `/reload`, and confirm it is still where you dropped it. Failure is a missing tooltip line, a state that only updates once you move away and back, or a button that snaps back on reload.

**17.** With **Enable Dispense** on, trade someone who is not in your group. The right consumables must drop into the window on their own. Turn **Enable for Strangers** off and trade them again: nothing must be added. Party up and check **Enable for Party** the same way, then convert to a raid and check **Enable for Raid** — in a raid the defaults must hand over 40 water instead of 20. Failure is a window that fills with its toggle off, stays empty with it on, or uses party amounts in a raid.

**18.** Trade one partner of each shape and check what arrives: a mana user who is not a mage or warlock must get water and food; a warrior or rogue must get food and **no** water; as a mage, another mage must get neither; as a warlock, another warlock must get no healthstone. Then trade the partner far below your level: the water and food handed over must be a rank they can actually use — check the item tooltips against their level. Failure is any of those getting the wrong list, or your top-rank water going to someone too low to drink it. **Check this on both flavors**: Anniversary has conjured ranks and healthstone tiers that Era does not, so confirm the rank handed over is one that exists on the client you are on.

**19.** With a trade open, click **Clear Trade Window** on the side panel beside the trade frame. Every slot you filled must empty, with nothing left on your cursor. Click **Fill Trade Window**: it must repopulate with the same amounts. Failure is items staying put, an item stuck to your cursor, or a fill that does nothing.

**20.** Get into combat with a trade window open and click **Fill Trade Window**. A chat line must say the game blocks automated trades during combat, and nothing may enter the window. Conjure while still in combat: nothing may reach the window then or after the fight, and your bags must not be tidied. Leave combat with the trade still open: nothing may happen on its own, and Fill must then work normally. Finally turn **Enable Notifications When Dispensing Is Blocked** off and try the blocked fill again — it must stay completely silent. Failure is anything filling mid-combat, a blocked fill landing once combat ends, bags reshuffling during the fight, a message with the notification off, or a Lua error.

**21.** On the mage, open a trade and conjure water. Within about a second the water that cast produced must appear in the trade window, and a small part-stack is the correct result — a mid-trade cast deliberately ignores your reserve, your session cap, and the per-class amounts. Cast two or three more times: each must add its own part-stack, and nothing may merge them while the trade is open. Repeat once with conjured food, and once on the warlock with a healthstone. Now close the trade and watch your bags: the part-stacks must pull together into full stacks of 20 within a second or so, leaving at most one partial behind. Then pick a stack up onto your cursor and hold it there while your bags change — conjure with the other hand, or loot something. It must stay on your cursor. Failure is a cast adding nothing, the same stack being offered twice, a Lua error once all six slots are full, a row of small stacks that never settles after the trade, or an item dropping back into your bags out from under you.

**22.** Under **Announcements**, turn **Enable Announcement Macro** on and drag the `- Dispenser` macro to your action bar. With exactly one giveable item in your bags, click it: the message must read as one complete sentence, with the item as a working link you can shift-click and hover. Now carry four or more different giveable consumables and click again: the message must end in ` ...` with the last item complete — never a half-rendered link, a stray `|`, or a name cut mid-word. Check the **Live Preview** on the panel against what actually posted, and check the channel — Say when ungrouped, Party in a party, Raid in a raid. Failure is a dangling fragment, a literal `%s`, a broken link, a message that fails to send, a preview that disagrees, or the wrong channel.

**23.** Open **Diagnostic Tools** on a fresh login. **Enable Diagnostic Tools** must be **off**, with everything below it hidden. Turn it on and work down the buttons: Start Event Log, open and close a trade, Stop Event Log, then Show Captured Events — the trade's events must still be listed after stopping, and where the report ends in a summary of suppressed traffic, read that block rather than hunting individual lines. Then press Test Event Registration, Test WoW API Endpoints, Probe Trade Context, List Installed Add-ons, Dump Saved Variables, each Validate Data button, and List Library Versions. Finally switch **Enable Diagnostic Tools** off and back on: every output box must be empty again, with the event log reading as nothing captured. Failure is the toggle remembering being on from a previous session, an output box left empty when you first run it, an old report still sitting there after the toggle was switched off and on, or a `FAIL` line — note which one, and on which flavor.

**24.** Open **Profiles**. Your character must be on **Default**. Create a new profile: the settings must reset to defaults, the Dispensed Items list must rebuild to the three built-ins, and the announcement macro must follow. Switch back to Default: your settings and your macro must both return. Failure is stale entries surviving the switch, settings not restoring, or a macro still advertising the other profile's items.

**25.** *(Optional, and only on a non-English client.)* Log in on another locale, open the settings, trigger the welcome message, and click the announcement macro. Every label and message must read in that language with no raw keys like `OPTIONS_DISPENSE_MASTER` or `TAB_INVENTORY_TOOLTIPS` showing through, and no literal `%s`, `nil`, or number in the wrong place. Try **Russian** in particular — it is the longest locale here and the first to overflow the macro's limit, so its message must still end cleanly in ` ...` with the last item whole. Failure is a raw key, a broken placeholder, or a Russian message that fails to send.

When every step passes on both Classic Era and TBC Anniversary, manual testing is complete. Proceed to `4 - Pre-Launch Review Prompt.md`.
