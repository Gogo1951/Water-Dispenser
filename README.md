# Water Dispenser

Effortless consumable distribution. Auto-fill the trade window with water, food, and healthstones. Add any item you want, like Hourglass Sand or Resistance Potions, to be given out to your raid.

TL;DR: If you're the mage or the warlock, this is the add-on that stops people asking twice. Open a trade and the right amount is already sitting in the window.

## Features

🎯 **Right Item, Right Amount** // Water and food step down to the best rank your partner can actually use, and every number is a count of individual items rather than stacks, so you can hand over exactly one Hourglass Sand, Resistance Potion, Flask, or Venom Sac out of a full stack.

👀 **See Who's Carrying What** // Hover a party or raid member and their tooltip lists everything they have set up to give, warlock healthstone rank included. An optional one-click macro posts your own leftovers to party or raid chat, with shift-clickable item links.

⚙️ **Your Rules, Your Stash** // Set how many each class gets from you as a stranger, in a party, or in a raid. Reserves wall off your personal supply so only the surplus goes out, and Maximum per Session stops one person draining your expensive potions on their fifth trade.

🧹 **Tidy Bags, Always Ready** // Conjured water and food land in a new bag slot every single cast, and the game never puts them back together. Water Dispenser merges the loose part-stacks between trades, so there's a whole stack waiting the moment someone asks.

🦺 **Safety First** // Only ever moves the consumables you've set up, never anything else. Never trades in combat, and never shuffles your bags mid-fight, mid-trade, or while you're dragging something.

## Setup

1. Install the add-on, ideally using [CurseForge](https://www.curseforge.com/wow/addons/water-dispenser-revisited) or [Wago](https://addons.wago.io/addons/water-dispenser).
2. Log in. Sensible class defaults are already configured, so it works right away.
3. Open a trade with someone and the right amounts drop into the trade window automatically.
4. Want different amounts? Type `/wd` and set per-class, per-scope rules in Dispensed Items.
5. Optional: under the Announcements tab, enable the `- Dispenser` macro and drag it to your action bar to share what you have to give.
6. *"You had me at H₂O."*

## How It Works

### Class Defaults

| Item | Conjured by | Strangers / Party / Raid |
|---|---|---|
| Water | Mage | 20 / 20 / 40 to mana users |
| Food | Mage | 20 / 20 / 40 to everyone but mages |
| Healthstone | Warlock | 1 to everyone but warlocks |

Those are individual items, so 20 is one conjured stack and 40 is two. Mages also hold back 20 water for themselves out of the box, so a full stack stays in your bags no matter how many people you hand out to.

Type any number you like into the grid, then press the little **Apply** button in the box. The **Everyone** row at the top fills a whole column at once: put an amount in, apply it, and every class in that column changes. It shows blank whenever the classes below don't all agree.

### In the Trade Window

Open a trade and a small panel appears beside it with **Clear Trade Window** and **Fill Trade Window** buttons, so you can wipe the window or redo the fill by hand whenever you like.

Conjure while a trade is open and the water, food, or healthstone you just made drops straight into the trade window, however small the stack. Your reserves and per-class amounts are not applied to it: casting mid-trade is you saying to hand it over. They still govern the automatic fill when the window first opens.

### Seeing What Everyone Has

Hover a party or raid member and Water Dispenser adds a short block to the bottom of their tooltip: every item they have set up to give out, and how many they are carrying. Warlocks always show a `Healthstone (Rank N/2)` line stating their Improved Healthstone rank, carrying one or not, since that is what a raid coordinates around. Your own inventory always shows on your own tooltip, grouped or not.

To tell people out loud instead, turn on the macro under the Announcements tab and a `- Dispenser` macro appears on your character. Click it to post your leftover giveaways to the channel that matches your group: Say when you're on your own, Party in a group, Raid in a raid. Item names are real hyperlinks, so people can shift-click them for the tooltip.

### Mini-Map Button

| Click | What happens |
|---|---|
| Left-Click | Toggles Dispense on or off |
| Shift + Middle-Click | Opens the options panel, the same as typing `/wd` |
| Hover | Shows whether Dispense is currently on |

### Options

<img width="800" src="https://github.com/user-attachments/assets/78e15b06-f153-4e95-81e4-f47410eefdd0" />

- **Water Dispenser** // The welcome message, the mini-map button, and the master **Enable Dispense** switch with its per-scope toggles for raid members, party members, and strangers. The warning when you run short and the automatic combining of partial stacks live here too.
- **Dispensed Items** // Your list of consumables and the per-class amount grid. Every item also carries **Distribute** (Always, In Group for a party or raid, or In Raid only), so raid consumables stay quiet in a five-man instead of tempting someone to ask. Below that sit the partner-level check, **Enable Reserves**, **Maximum per Session**, and which of your own classes the item applies to.
- **Announcements** // The `- Dispenser` macro toggle with a live preview of what it will say, plus **Inventory in Player Tooltips** and, beneath it, **Share My Inventory** if you would rather read other people's without sending your own.
- **Profiles** // Share one set of rules across every character, or give a character its own.
- **Diagnostic Tools** // Read-only probes to paste into a bug report.

## Testing & Localization Status

🟢 World of Warcraft Classic (🟡 Season of Discovery) // WoW 1.15.9

🟢 Burning Crusade Anniversary // WoW 2.5.6

🔴 Mists of Pandaria Classic // WoW 5.5.4

🔴 World of Warcraft // WoW 12.1.0

**Localization Status** // Works with all Classic WoW Locales (enUS, deDE, esES, esMX, frFR, itIT, koKR, ptBR, ruRU, zhCN, zhTW).

Please reach out if you would like to be involved!

## Links

- [GitHub](https://github.com/Gogo1951/Water-Dispenser)
- [Discord](https://discord.gg/eh8hKq992Q)

## History

👾 **I didn't create this add-on, I just updated it.**

- Razyel's [Water Dispenser](https://www.wowinterface.com/downloads/info25489-WaterDispenser.html)
- Junsa's [Water Dispenser Era](https://www.curseforge.com/wow/addons/water-dispenser-era)

## Related Add-ons

🟢 Pairs With // Gogo1951's [Connoisseur](https://www.curseforge.com/wow/addons/consumable-connoisseur)

🟢 Pairs With // IzC's [IzC Auto Consumables](https://www.curseforge.com/wow/addons/izc-auto-consumables)

🟢 Pairs With // noobsgonewild's [Tank HealthStone Tracker](https://www.curseforge.com/wow/addons/tank-healthstone-tracker)

🟡 Some Overlap // Emmadruid's [ConjureHelper](https://www.curseforge.com/wow/addons/conjurehelper)

🟡 Some Overlap // afrugalpenguin's [MageTools](https://www.curseforge.com/wow/addons/magetools)

🟡 Some Overlap // Shadrizz's [Necrosis TBC Anniversary](https://www.curseforge.com/wow/addons/necrosis-tbc-anniversary)

🟡 Some Overlap // afrugalpenguin's [WarlockTools](https://www.curseforge.com/wow/addons/warlocktools)

🔴 Direct Alternative // HazeSuite's [HazeWaterBoy](https://www.curseforge.com/wow/addons/hazewaterboy)

🔴 Direct Alternative // Codermik's [tradeDispenser](https://www.curseforge.com/wow/addons/tradedispenser)

🔴 Direct Alternative // Mafkees's [TradeFill](https://www.curseforge.com/wow/addons/tradefill)

🔴 Direct Alternative // enshadowed_'s [Water Dispenser BCC](https://www.curseforge.com/wow/addons/water-dispenser-bcc)

🔴 Direct Alternative // BlessedRabies2's [Water Dispenser Fixed](https://www.curseforge.com/wow/addons/water-dispenser-fixed)
