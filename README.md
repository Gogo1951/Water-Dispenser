# Water Dispenser

Auto-fills the trade window with the right consumables for whoever you're trading. Water, food, healthstones, lockboxes — class-aware, level-aware, with separate stacks for solo, party, and raid. Stop dragging stacks one slot at a time.

## Features

💧 **Smart Auto-Fill** // Open a trade and the right stacks drop in — class-aware, level-aware, sized for solo, party, or raid.

🧰 **Distribution Rules** // Add any tradable consumable, set per-class quantities, reserve some for yourself, restrict by class or level, allow partial stacks.

📣 **Announcement Macro** // The `- Dispenser` macro broadcasts your giveaway list to `/say`, `/party`, or `/raid` with shift-clickable item links.

🗝️ **Rogue Lockbox Slotting** // Drops your locked items into the un-tradeable slot when a rogue trades you for a pick.

## Setup

1. Install the add-on, ideally using [CurseForge](https://www.curseforge.com/wow/addons/water-dispenser-revisited).
2. Log in. Sensible defaults are set up automatically.
3. Open a trade with someone — the right stacks drop in.
4. (Optional) Type `/wd` to tweak Distribution Rules and enable the `- Dispenser` announcement macro.
5. Hand out water like Oprah hands out cars. (=

## How It Works

### Class Defaults

| Item | Dispensed by | Solo / Group / Raid |
| --- | --- | --- |
| Mage Water | Mage | 1 / 2 / 4 stacks for mana classes |
| Mage Food | Mage | 1 / 2 / 4 stacks |
| Healthstone | Warlock | 1 healthstone for anyone |

If you have other items to hand out, you can add any consumable you want, as well as tweak any other settings in the Distribution Rules panel.

### Distribution Rules

Set how many stacks of each item go to each class, in each scope (Strangers / Party Members / Raid Members). Add any tradable consumable from your bags. Per-item rules let you:

* Reserve some for yourself ("Keep at Least").
* Restrict to specific player classes ("Only Dispense when Playing These Class(es)").
* Skip the partner if they can't use it yet ("Factor in Usage Level Requirements").
* Choose whether the announcement includes the count.
* Allow partial stacks when you're running low.

### Announcement Macro

Turn on the `- Dispenser` macro in **Options > AddOns > Water Dispenser > Announcements** and watch the live preview. Drag the macro from the Macro UI (`/m` or Game Menu > Macros) onto your action bar. Click it to broadcast your giveaway list to whichever channel matches your group state — `/say`, `/party`, or `/raid`. Item names are real hyperlinks, so receivers can shift-click for the tooltip.

### Slash Commands

| Command | Effect |
| --- | --- |
| `/wd` | Open the options panel. |
| `/wd fill` | Fill the trade window now. |
| `/wd clear` | Clear every slot in the trade window. |
| `/wd auto solo\|group\|raid on\|off` | Toggle auto-fill for the given scope. |
| `/wda` | Send the announcement to your group's channel. |

## Testing & Localization Status

🟢 World of Warcraft Classic (🟡 Season of Discovery) // WoW 1.15.8

🟢 Burning Crusade Anniversary // WoW 2.5.5

🔴 Mists of Pandaria Classic // WoW 5.5.3

🔴 World of Warcraft // WoW 12.0.5

**Localization Status** // Works with all Classic WoW Locales (enUS, deDE, esES, esMX, frFR, itIT, koKR, ptBR, ruRU, zhCN, zhTW).

Please reach out if you would like to be involved!

## Links

* [CurseForge](https://www.curseforge.com/wow/addons/water-dispenser-revisited)
* [GitHub](https://github.com/Gogo1951/Water-Dispenser)
* [Discord](https://discord.gg/eh8hKq992Q)

## History

👾 **I didn't create this add-on, I just updated it.**

* Hoedown's [Water Dispenser](https://www.curseforge.com/wow/addons/water-dispenser-classic-tbc-classic)
* Junsa's [Water Dispenser Era](https://www.curseforge.com/wow/addons/water-dispenser)

## Related Add-ons

🟢 Pairs With // gogo1951's [Connoisseur](https://www.curseforge.com/wow/addons/consumable-connoisseur)

🟢 Pairs With // VithRus's [Warlock Healthstone Tracker](https://www.curseforge.com/wow/addons/warlock-healthstone-tracker)

🟢 Pairs With // VithRus's [Warlock Healthstone Tracker - BlizzUI](https://www.curseforge.com/wow/addons/warlock-healthstone-tracker-blizzui)

🟢 Pairs With // Yarillo's [Warlock Healthstone Tracker Tweaked](https://www.curseforge.com/wow/addons/warlockhealthstonetracker)

🟡 Some Overlap // afrugalpenguin's [WarlockTools](https://www.curseforge.com/wow/addons/warlocktools)

🟡 Some Overlap // [Mage Vendor](https://www.curseforge.com/wow/addons/mage-vendor)

🔴 Direct Alternative // BlessedRabies2's [Water Dispenser Fixed](https://www.curseforge.com/wow/addons/water-dispenser-fixed)

🔴 Direct Alternative // Linae-Kronos's [tradeDispenser](https://github.com/Linae-Kronos/tradeDispenser)

🔴 Direct Alternative // TheLuxSupport's [Mage2Order](https://www.curseforge.com/wow/addons/mage2order)

🔴 Direct Alternative // [TradeFill](https://www.curseforge.com/wow/addons/tradefill)

🔴 Direct Alternative // [TradeStone](https://www.curseforge.com/wow/addons/tradestone)
