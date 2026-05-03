# Water Dispenser

Auto-fills the trade window with the right consumables for whoever you're trading.

## What It Does

Whether you're a mage handing out water and food to your raid, a warlock pumping out healthstones, or anyone who's tired of dragging stacks one slot at a time — Water Dispenser handles the busywork. Open a trade and the right stacks drop in, sized for the partner's class and ranked for their level. An optional `- Dispenser` macro broadcasts what you have left to give in your group's chat channel.

## Quick Start

1. Install from [CurseForge](https://www.curseforge.com/wow/addons/water-dispenser-revisited) or clone from [GitHub](https://github.com/Gogo1951/Water-Dispenser).
2. Log in. Sensible defaults are set up automatically.
3. Open a trade with someone — stacks fill in. Done.
4. Optional: open **Options > AddOns > Water Dispenser > Announcements** and turn on "Enable Announcement Macro." A `- Dispenser` macro is created on your character; drag it from the Macro UI (`/m` or Game Menu > Macros) onto your action bar. Click to announce your giveaway list to your group.

## Class Defaults

| Item | Dispensed by | Solo / Group / Raid |
|---|---|---|
| Mage Water | Mage | 1 / 2 / 4 stacks for mana classes. |
| Mage Food | Mage | 1 / 2 / 4 stacks. |
| Healthstone | Warlock | 1 healthstone for anyone. |

If you have other items to hand out, you can add any consumable you want, as well as tweak any other settings in the Distribution Rules panel.

## Customization

Type `/wd` or open **Options > AddOns > Water Dispenser** to access the panel.

**Water Dispenser** — Toggle auto-fill per scope (Strangers / Party Members / Raid Members), enable rogue lockbox slotting, manage chat output, reset to defaults.

**Distribution Rules** — Set how many stacks of each item go to each class, in each scope. Add any tradable consumable from your bags. Per-item rules let you:

- Reserve some for yourself ("Keep at Least").
- Restrict to specific player classes ("Only Dispense when Playing These Class(es)").
- Skip the partner if they can't use it yet ("Factor in Usage Level Requirements").
- Choose whether the announcement includes the count.
- Allow partial stacks when you're running low.

**Announcements** — Turn on the `- Dispenser` macro and watch the live preview. Click the macro in-game to broadcast your giveaway list to whichever channel matches your group state (`/say`, `/party`, or `/raid`). Item names are real hyperlinks, so receivers can shift-click for the tooltip.

## Slash Commands

| Command | Effect |
|---|---|
| `/wd` | Opens the options panel. |
| `/wd fill` | Fills the trade window now. |
| `/wd clear` | Clears every slot in the trade window. |
| `/wd auto solo\|group\|raid on\|off` | Toggles auto-fill for the given scope. |
| `/wda` | Sends the announcement to your group's channel. |

## Testing Status

🟢 World of Warcraft Classic Era

🟢 Burning Crusade Classic Anniversary

🔴 Mists of Pandaria Classic

🔴 Retail

Please reach out if you would like to be involved with testing!

## Links

- [CurseForge](https://www.curseforge.com/wow/addons/water-dispenser)
- [GitHub](https://github.com/Gogo1951/Water-Dispenser)
- [Discord](https://discord.gg/eh8hKq992Q)

## History

This is a continuation of:

* Hoedown's [Water Dispenser](https://www.curseforge.com/wow/addons/water-dispenser-classic-tbc-classic).
* Junsa's [Water Dispenser Era](https://www.curseforge.com/wow/addons/water-dispenser).
