# Water Dispenser // Notes

> The maintainer's settled rulings for Water Dispenser, kept so no review raises them again: exceptions to the Gogo1951 add-on Style Guide, and decisions it leaves open.

## Exceptions

### Mini-map Dispense Report
- **Departs from:** MINIMAP BUTTON → Tooltip Structure, the feature blocks followed directly by the options block.
- **Instead:** a Dispense Report section between the Dispense block and the options block lists what the player can give right now, each item's icon and name with its amount, and is left out when there is nothing to give.
- **Why:** how much a dispenser has left to give is the question its button is hovered for.

## Decisions

- Group inventory sharing ships with both toggles on — Show Inventory in Player Tooltips and Share My Inventory (`ShareInventory`) — so hovering a groupmate shows what they have to give. Share My Inventory is gated by Show Inventory in Player Tooltips; the broadcast travels on the add-on channel to the player's own party or raid only, never posts to chat, carries just the configured giveaway items and their counts, and the panel carries the off switch.
- Combine Partial Stacks After a Trade (`RestackBags`) ships on by default as a sub-option of Enable Dispense: conjured water and food land in a fresh bag slot on every cast and the game never merges them, so without it the dispenser regularly has no full stack to hand over. It runs on `TRADE_CLOSED` and nothing else, never off a bag event, touches only the add-on's own configured items, and stands down in combat and with anything on the cursor.
- The announcement macro defaults on and is created silently, with no "macro is ready" print.
- The AceDB conversion shipped with no migration bridge, so a pre-conversion mini-map position and reserve amount fall back to defaults; no bridge is added for it.
- Conjuring during an open trade places the slot the new items landed in straight into the trade window, partial or not, with no restack step and no reserve, session-cap or per-class check on that slot; there is no restack or full-stack wait.
- The default 20-water reserve on Conjured Water stays.
- The announcement macro and the player tooltip count only the best rank of a conjured collection on hand, while a trade cascades to lower ranks when the best runs short; giveable ranks are never summed.
- An item page opens with one silver status line, and only while nothing would go out: the item is off for the class being played, or every amount is 0.
- Maximum per Player sits among an item's settings, under Guildies Only, rather than with the amounts, because it ships off; Enable Reserves stays under the amount grid.
- The Clear and Fill panel appears only beside trades on a character with at least one item switched on for its class; Enable Dispense off still shows it, since Fill is the manual path.
- A silver status line under the trade panel's buttons says what the window holds or, when it is empty, the first reason the fill held back; it never prints to chat.
- Hold Off While You're Master Looter ships on by default as a sub-option of Enable Dispense; it stops only the automatic fill when a trade opens while the player is master looter inside a dungeon or raid, and Fill Trade Window and conjuring mid-trade still work.
- Conjure buttons ship on by default as a sub-option of Enable Dispense; they appear only beside an open trade, only for a class that knows a built-in collection's spell, and each casts the best rank the trade partner can use, skipping a healthstone tier already carried and falling back to the lowest rank known.
- Declined: a whisper-keyword request queue with automatic position replies, because Water Dispenser sends no chat on its own; the player's own macro is its only voice.
- Declined: a never-give list of player names, because Maximum per Player already covers someone draining the player's supply.
- Declined: a thank-you whisper after each trade, because Water Dispenser sends no chat on its own.
- Declined: a Guild, Officer or Yell choice for the announcement macro, because its automatic Say, Party, Raid or Instance choice already reaches the people who can trade.
- Declined: an Open Macros button beside Enable Announcement Macro; the Announcements page stays one switch and its preview.
- Declined: a running total of what has been handed out since login.
- Declined: an SEO rewrite of the sales pitch toward terms like "mage water", "warlock" and "auto trade"; the "Effortless consumable distribution." pitch stays in the README, every TOC's Notes and every locale's OPTIONS_DESCRIPTION.
- The LICENSE's first year is 2026, the year Gogo1951 took over the add-on, not the repo's 2024 start under its previous maintainer.
- Diagnostic Tools' Settings tab carries one context report per feature (Trade & Fill, Conjure & Restack, Announcement Macro, Inventory Tooltips) rather than one combined probe, so a player pastes only the report that matches their problem.
- The Inventory Tooltips diagnostic report prints groupmates' character names beside the names their add-on messages arrived under, with their advertised counts, because a spelling mismatch between the two is that feature's silent failure and only shows with both side by side; the panel's review-before-pasting hint says so.
