# Water Dispenser — Manual Test Plan

This is the manual test plan for Water Dispenser — the steps to confirm it works before a release is tagged. For what it does, see [README.md](https://github.com/Gogo1951/Water-Dispenser/blob/main/README.md); for how it works, see [README-Technical.md](https://github.com/Gogo1951/Water-Dispenser/blob/main/README-Technical.md).

---

## How to run this plan

Run the whole list on Classic Era, then again on TBC Anniversary. Do a `/reload` before starting each flavor.

Every step names what you should see and what failure looks like. Steps are numbered continuously from 1, so a bug report only has to say "failed on step 34." Work top to bottom — later steps sometimes depend on settings an earlier step turned on.

Where a step calls out a difference between the two flavors, run it on **both**. The flavor it names as the one that tends to break is exactly the run where that step earns its keep — skipping it means you have not finished testing.

---

## Before you start

Gather these once so you're not caught short mid-run.

- **Two game clients** — Classic Era and TBC Anniversary. The plan runs in full on each.
- **A mage**, high enough to conjure water and food. Most steps use this character.
- **A warlock**, able to create a healthstone. Needed for the healthstone steps.
- **A second player** to trade with, who can join your party and your raid. Several steps need a real trade window, and the macro steps need a party and a raid to check the channel.
- **A trade partner who is not a mage or warlock** — a priest, paladin, druid, shaman, or hunter is ideal, because the defaults give water to mana users. Have a warrior or rogue available too, since they are configured to receive food but no water.
- **Bags with room**, and on the mage at least two full stacks of conjured water plus a few partial stacks.
- **Four or more different giveable consumables** in bags for the truncation steps.
- **Somewhere safe to take damage** — a target dummy or an open-world mob — for the combat steps.
- **At least one free macro slot** on the character used for the announcement steps.
- **A non-English client** — optional, only for the localization spot-check at the end.

Unless a step says otherwise, you are out of combat.

---

## Verify this release's changes

Four things changed in this release. These steps are the highest-value part of the plan — run them first.

### Settings panel routing

**1.** Type `/wd`. The settings must appear **docked inside the Blizzard Options window**, with Water Dispenser selected in the category list on the left. Failure looks like either nothing happening at all, or a standalone window floating free of the Options frame.

**2.** Close Options. Hold Shift and Middle-Click the mini-map button. The same docked panel must open. Failure is the same two shapes: nothing, or a floating window.

**3.** With the panel open, click each of the child entries under Water Dispenser in the category list — Distribution Rules, Announcements, Profiles, Diagnostic Tools. Each must open its own page inside the Options window. Failure is a child that is missing from the list, or one that opens blank.

**4.** Run steps 1 and 2 again on **TBC Anniversary** before calling this section done. Both entry points must dock there exactly as they do on Classic Era. Failure is the same two shapes — a floating window, or nothing at all — and on Anniversary it means this release's main fix did not land. Era has always worked, so an Era-only run tells you nothing about this change.

### Conjuring during a trade

**5.** On the mage, open a trade with your partner. Conjure water. Within about a second, the trade window must fill with **full** stacks of water. Failure is a half-size stack landing in the trade, or nothing arriving at all.

**6.** Still in the trade, conjure water two or three more times in quick succession. The partial stacks must merge and the trade still show whole stacks. Failure is several small stacks sitting in the trade slots.

**7.** Repeat step 5 with conjured food, and on the warlock with a healthstone. Each must behave the same way. Failure is any of the three not triggering a fill.

**8.** Join a group with several other players and stand somewhere busy while other people cast spells, with a trade window open. Water Dispenser must ignore all of it and react only to your own conjures. Failure is the trade re-filling or the bags reshuffling when somebody else casts.

### Options text color

**9.** Open the settings. The description text under the add-on title, and the descriptions on the Distribution Rules and Announcements pages, must read **white**. Failure is gray body text.

**10.** Hover the mini-map button. The feature description line under "Dispense" must read white. Failure is gray.

**11.** Open Diagnostic Tools and turn on "Enable Diagnostic Tools". The event-log hint, the taint-log hint, and the two External Tools lines must read **silver** — visibly dimmer than the white body text in step 9. Failure is all of it rendering the same shade.

**12.** On those two External Tools lines, check the sentence **stays silver after** the blue `/console scriptErrors 1` and `/etrace` text. Failure is the line turning white partway through, right after the blue part.

### Announcement macro sentence

**13.** Under the Announcements tab, turn on "Enable Announcement Macro". A chat message must confirm the macro was created. Failure is no message, or a message saying all macro slots are in use when you have a free one.

**14.** With exactly **one** giveable item in your bags, click the `- Dispenser` macro. The message posted must read as one complete sentence — the item, then the closing line. Failure is a dangling fragment, a missing closing phrase, or a stray `%s` appearing literally in chat.

**15.** The item in that message must be a working link — shift-click it and it should insert into your chat box; hover it and a tooltip should appear. Failure is plain text, or a link that shows raw bracket-and-pipe characters.

**16.** Now put **four or more** different giveable consumables in your bags and click the macro again. The message must end in ` ...`. Failure is a message that gets cut off mid-word or mid-link, or one that fails to send at all.

**17.** Look at the last item in that truncated message. It must be complete — full name, working link. Failure is a half-rendered link, a stray `|` character, or an item name cut in the middle.

**18.** Check the Live Preview on the Announcements page against what the macro actually posted. They must say the same thing. Failure is the preview showing different items, different counts, or a different sentence.

When steps 1–18 pass on both flavors, this release's changes are verified — proceed to `4 - Pre-Launch Review Prompt.md`.

---

## Loading and the welcome message

**19.** Log in with the add-on freshly enabled. A single greeting line must print in chat, naming the version. Failure is no message, a doubled message, or a version showing as a literal `%s`.

**20.** In the settings, turn off "Enable Welcome Message", then `/reload`. No greeting must appear. Failure is the message still printing.

**21.** Turn it back on and `/reload`. The greeting must return. Failure is the setting not sticking.

---

## Options panel

**22.** Open the settings and confirm the child pages appear in this order under Water Dispenser: Distribution Rules, Announcements, Profiles, Diagnostic Tools. Failure is a missing page or a different order.

**23.** On the main page, toggle "Enable Dispense" off. The four sub-toggles beneath it — Raid Members, Party Members, Strangers, and the missing-stacks warning — must disappear. Failure is them staying visible.

**24.** Toggle "Enable Dispense" back on. The four sub-toggles must reappear. Failure is them staying hidden.

**25.** Toggle "Enable Mini-map Button" off. The mini-map button must vanish immediately. Failure is it staying on the mini-map.

**26.** Toggle it back on. The button must reappear in the same spot. Failure is it not returning, or returning in a different position.

**27.** Change several settings, then `/reload`. Every setting must come back the way you left it. Failure is anything reverting to its default.

**28.** Log out and back in. The same settings must still be in place. Failure is anything resetting between sessions.

**29.** Scroll to the bottom of the main page. Four links must be listed in this order — Discord, GitHub, CurseForge, Wago — with a version line below them. Failure is a missing link, a wrong order, or a version reading as a blank.

---

## Mini-map button

**30.** Hover the mini-map button. A tooltip must appear showing the add-on name and version, a "Dispense" line with its current state, a description, and the Shift + Middle-Click hint at the bottom. Failure is no tooltip, or missing lines.

**31.** Left-click the button. The "Dispense" state in the tooltip must flip between Enabled and Disabled **while you are still hovering**. Failure is the tooltip not updating until you move away and back.

**32.** Confirm that flipping it here also flips "Enable Dispense" in the settings. Failure is the two disagreeing.

**33.** Drag the button around the mini-map. It must follow the cursor and stay where you drop it. Failure is it snapping back.

**34.** `/reload` and confirm the button is still where you left it. Failure is it jumping to a default position.

**35.** Switch to a different character on the same account. The button must be in that same position — it is shared account-wide. Failure is it reverting per character.

---

## Slash command

**36.** Type `/wd`. The settings must open, docked. Failure is nothing happening or a floating window. (This is the same check as step 1 — repeat it here after all the toggling above, in case a setting change broke it.)

**37.** Type `/wd` a second time while the panel is already open. It must stay open and usable, not error. Failure is a Lua error or the panel closing.

---

## Dispensing into a trade

**38.** With "Enable Dispense" on and "Enable for Strangers" on, open a trade with a player who is not in your group. The right consumables must drop into the trade window on their own. Failure is an empty trade window.

**39.** Turn "Enable for Strangers" off and trade the same player again. Nothing must be added automatically. Failure is it filling anyway.

**40.** Party up with your partner, turn "Enable for Party Members" on, and open a trade. It must fill. Failure is an empty window.

**41.** Convert to a raid, turn "Enable for Raid Members" on, and open a trade. It must fill, and with the raid amounts — the defaults give two stacks instead of one. Failure is party-sized amounts in a raid.

**42.** Trade a **mana-using** partner (priest, paladin, druid, shaman, hunter, warlock). They must receive both water and food. Failure is water missing.

**43.** Trade a **warrior or rogue**. They must receive food but **no water** — that is the intended default. Failure is water being handed over.

**44.** As a mage, trade another **mage**. They must receive neither water nor food. Failure is either being added.

**45.** As a warlock, trade another **warlock**. No healthstone must be added. Failure is one being added.

**46.** Trade a partner who is much lower level than you. The water and food handed over must be a rank they can actually use — check the item tooltips against their level. Failure is your top-rank water being handed to someone too low to drink it.

**47.** In the trade window, click **Clear Trade Window** on the side panel. Every slot you filled must empty. Failure is items staying put, or an item ending up stuck on your cursor.

**48.** Click **Fill Trade Window**. The trade must repopulate. Failure is nothing happening, or the window filling with the wrong amounts.

---

## Distribution Rules

**49.** Open Distribution Rules. Three built-in entries must be listed — Conjured Water, Conjured Food, Healthstones — each with an icon. Failure is a missing entry or a blank icon.

**50.** Open Conjured Water and check its three tabs: Strangers, Party Members, Raid Members. Each must show a slider per class, with class names in class colors. Failure is a missing tab or an unlabeled slider.

**51.** Change a class slider, `/reload`, and confirm the new value is still there. Failure is it reverting.

**52.** Open Healthstones and check its sliders stop at 1 — healthstones only ever trade one at a time. Failure is a slider going higher.

**53.** On Conjured Water's Item Settings tab, set "Keep at Least" to a number below what you're carrying. Open a trade — the amount left in your bags must not drop below that number. Failure is the add-on giving away your reserve.

**54.** On Item Settings, uncheck your own class under "Only Dispense when Playing These Classes". Open a trade — that item must not be handed over. Failure is it being dispensed anyway.

**55.** `/reload` and confirm the class you unchecked is still unchecked. Failure is it re-checking itself.

**56.** Open the Add Item tab. A dropdown must list tradable consumables from your bags. Soulbound items and items already configured must **not** appear. Failure is a soulbound item being offered.

**57.** Add one, confirm a chat message names it, then remove it using the Remove Item button and confirm a second message. The entry must disappear from the sidebar. Failure is the entry lingering, or no confirmation prompt on removal.

---

## Announcement macro

**58.** With the macro enabled, open your macro list. A macro named `- Dispenser` must be there, with a drink icon, sorted near the top. Failure is a missing macro or a truncated name.

**59.** Ungrouped, click the macro. The message must post to Say. Failure is it going to the wrong channel or erroring.

**60.** In a party, click it. The message must post to Party. Failure is it going to Say.

**61.** In a raid, click it. The message must post to Raid. Failure is it going to Party.

**62.** Loot or conjure something so your bag contents change, wait a moment, then click the macro again. The counts must reflect what you now hold. Failure is stale numbers.

**63.** Set "Keep at Least" high enough that nothing is left to give. Click the macro. Nothing must be posted. Failure is a message announcing items you don't have spare.

**64.** Turn "Enable Announcement Macro" off. A chat message must confirm deletion, and the macro must be gone from your macro list. Failure is the macro surviving.

---

## Combat behavior

**65.** Get into combat with a trade window already open, then trigger a fill. A chat message must say dispensing is paused. Failure is the trade filling mid-combat, or a Lua error appearing.

**66.** Leave combat with the trade still open. A message must say it is resuming, and the trade must then fill. Failure is nothing happening after combat ends.

**67.** Conjure water while in combat with a trade open. Nothing must reshuffle your bags until combat ends, then the merge and fill must happen. Failure is bags being rearranged mid-combat.

**68.** Change a setting that updates the macro while in combat. No error must appear, and the macro must update once combat ends. Failure is a Lua error or a macro that never catches up.

**69.** Close the trade window while in combat. No error must appear. Failure is a Lua error on closing.

---

## Diagnostic Tools

**70.** Open Diagnostic Tools on a fresh login. The enable toggle must be **off**, and everything below it hidden. Failure is it remembering being on from a previous session.

**71.** Turn it on. The sections below must appear. Failure is nothing revealing.

**72.** Click "Start Event Log", do something that triggers the add-on — open a trade, conjure — then click "Show Captured Events". The output box must list events with timestamps. Failure is an empty log after you clearly triggered activity.

**73.** Click "Stop Event Log", then "Show Captured Events" again. The log must be cleared. Failure is old entries persisting.

**74.** Click "Test Event Registration" and "Test WoW API Endpoints". Both must fill the output box, and every line should read PASS. Failure is a FAIL line — note which one and on which flavor.

**75.** Click "Probe Trade Context" with a trade open and again with none. Both must produce readable output describing the current state. Failure is an empty box or an error.

**76.** Click "Dump Saved Variables". Your current settings must appear as readable text. Failure is an empty dump or an error.

---

## Profiles

**77.** Open Profiles. Your character must be on a profile named Default. Failure is each character having its own profile out of the box.

**78.** Create a new profile. Settings must reset to defaults, and the Distribution Rules sidebar must rebuild to the three built-ins. Failure is the sidebar keeping stale entries from the old profile.

**79.** Switch back to Default. Your original settings must return, and the announcement macro must update to match. Failure is settings not restoring, or a macro still showing the other profile's items.

**80.** Use "Copy From" to copy Default into your new profile. The settings must carry across. Failure is nothing changing.

---

## Flavor differences to watch

Do not let a clean Classic Era run stand in for both flavors. These are the places the two clients have behaved differently:

- **The settings panel docking (steps 1–4, 36).** This is the big one. Classic Era has always docked correctly; TBC Anniversary is the client where the panel opened floating, or refused to open at all. Run these steps on Anniversary or you have not tested the change.
- **Conjured item ranks (steps 42–46).** The two clients have different top-rank conjured water and food. Check the rank handed over is one that actually exists and is usable on the client you're testing.
- **Healthstone tiers (steps 45, 52).** Anniversary has higher healthstone tiers than Era. Confirm the warlock steps use a stone that exists on the client you're on.
- **Any Lua error at all.** An error that appears on one flavor and not the other is a flavor difference by definition — note which client it happened on.

---

## Localization spot-check

Optional, and only worth doing on a non-English client.

**81.** Log in on a non-English client and open the settings. Every label and description must be in that language. Failure is a raw key like `OPTIONS_DISPENSE_MASTER` showing through, which means a string is missing.

**82.** Trigger the welcome message and the combat-paused message. Both must read as natural sentences in that language, with the version number appearing correctly. Failure is a literal `%s`, a `nil`, or a number in the wrong place.

**83.** Click the announcement macro. The sentence must read naturally with the item list in the right place for that language. On Korean the item list comes **first** and the verb closes the sentence — that ordering is intentional and correct, not a bug. Failure is the item list missing entirely, appearing twice, or the sentence ending with no closing phrase after it.

**84.** Test truncation on **Russian** specifically. Russian text takes the most space of any locale here, so it is the first to overflow the message limit. With four or more giveable items, the Russian message must still end cleanly in ` ...` with the last item complete. Failure is a message that fails to send, or one cut inside an item link.

---

## Sign-off

Manual testing is complete when **every step passes on both Classic Era and TBC Anniversary**. One flavor is not enough — step 4 exists precisely because the most recent bug only appeared on Anniversary.

When both rows below are filled in and passing, the add-on is ready for `4 - Pre-Launch Review Prompt.md`.

| Flavor | Tester | Date | Result | Failed steps |
|---|---|---|---|---|
| Classic Era | | | Pass / Fail | |
| TBC Anniversary | | | Pass / Fail | |
