# Water Dispenser

Effortless consumable distribution for mages and warlocks. Auto-fill the trade window with conjured water, food, and healthstones, the right rank and amount for every player, plus any item you add, like Hourglass Sand. Hand out a raid's worth in seconds.

**TL;DR:** Open a trade and Water Dispenser puts the right water, food, and healthstones in the window for you. Less counting stacks, more pulling bosses.

## Features

🎯 **Right Item, Right Amount** // Automatically gives each player the best water or food rank they can use, based on your distribution rules for their class.

👀 **Player Tooltips & Announcement Macro** // See what each player in your group has to give out, and announce your leftovers with a macro.

⚙️ **Your Rules, Your Stash** // Set different amounts by class and group, protect a personal reserve, cap what any one player gets per session, and save items for guildies or instances.

🧹 **Tidy Bags After a Trade** // Automatically combines loose conjured water and food stacks after trades, while leaving your bags alone during normal play.

🦺 **Safety First** // Water Dispenser only trades items you choose.

## Setup

1. Install the add-on, ideally using [CurseForge](https://www.curseforge.com/wow/addons/water-dispenser-revisited) or [Wago](https://addons.wago.io/addons/water-dispenser).
2. Log in. Sensible class defaults are already configured, so it works right away.
3. Open a trade with someone and the right amounts drop into the trade window automatically.
4. Want different amounts? Type `/wd` and set per-class amounts for strangers, party, and raid under Dispensed Items.
5. Optional: drag the `- Dispenser` macro from your character-specific macros onto your action bar to announce what you have to give.
6. *"You had me at H₂O."*

## How It Works

### Class Defaults

| Item | Conjured by | Strangers / Party / Raid |
|---|---|---|
| Water | Mage | 20 / 20 / 40 to mana users other than mages |
| Food | Mage | 20 / 20 / 40 to everyone but mages |
| Healthstone | Warlock | 1 to everyone but warlocks |

- Amounts are individual items, so 20 is one conjured stack and 40 is two.
- Mages hold back 20 water for themselves out of the box, so a full stack stays in your bags no matter how many people you hand out to.
- Type any number into the grid, then press the little **Apply** button in the box. The **Everyone** row at the top fills a whole column at once, and shows blank whenever the classes below don't all agree.

### In the Trade Window

- A small panel beside the trade window carries **Clear Trade Window** and **Fill Trade Window** buttons, so you can wipe the window or redo the fill by hand whenever you like.
- Conjure while a trade is open and the water, food, or healthstone you just made drops straight into the window, however small the stack. Your reserves, caps, and per-class amounts don't apply to it: casting mid-trade is you saying to hand it over.

### Seeing What Everyone Has

- Hover a party or raid member running Water Dispenser to see every item they have set up to give out, and how many they're carrying.
- Warlocks always show a `Healthstone (Rank N/2)` line stating their Improved Healthstone rank, carrying one or not, since that is what a raid coordinates around.
- Your own inventory always shows on your own tooltip, grouped or not.
- The `- Dispenser` macro posts your leftover giveaways to the channel that matches your group: Say when you're on your own, Party in a party, Raid in a raid, Instance in a dungeon or battleground group. Item names are real hyperlinks, so people can shift-click them for the tooltip.

<img width="200" src="https://github.com/user-attachments/assets/9db47e56-023c-4e07-b282-0b5a5a3093d5" />


### Mini-Map Button

| Click | What happens |
|---|---|
| Left-Click | Toggles Dispense on or off |
| Shift + Middle-Click | Opens the options panel, the same as typing `/wd` |
| Hover | Shows whether Dispense is currently on |

<img width="300" src="https://github.com/user-attachments/assets/8ef56312-1f0a-44b9-87b2-049acd80393e" />


### Options

- **Water Dispenser** // The welcome message, the mini-map button, the `/wd` command, and where to reach the author.
- **Dispense** // The master **Enable Dispense** switch and its per-scope toggles for raid members, party members, and strangers. Under those sit **Combine Partial Stacks After a Trade**, the warning when you run short, and whether Water Dispenser says anything when combat blocks a fill.
- **Dispensed Items** // Your list of consumables and the per-class amount grid. Every item also carries **Distribute** (Always, or In Instance for dungeons, raids, battlegrounds, and arenas), so an item meant for inside an instance stays quiet out in the world instead of tempting someone to ask, and **Guildies Only**, which holds the item back from anyone outside your guild. Below that sit the partner-level check, **Enable Reserves**, **Maximum per Session**, whether the item's count rides along in your tooltip and macro, and which of your own classes the item applies to.
- **Announcements** // The `- Dispenser` macro toggle, on by default, with a live preview of what it will say.
- **Inventory Tooltips** // **Show Inventory in Player Tooltips** and, beneath it, **Share My Inventory** if you would rather read other people's without sending your own. **Show Bag Tooltips for Dispensed Items** adds a line to your own bag items saying they are set to be given out.
- **Profiles** // Share one set of rules across every character, or give a character its own.
- **Diagnostic Tools** // Read-only probes to paste into a bug report.

<img width="800" src="https://github.com/user-attachments/assets/4b95d4e6-d9af-4b4a-972b-3e29266e1769" />


## Testing & Localization Status

🟢 World of Warcraft Classic (🟡 Season of Discovery) // WoW 1.15.9

🟢 World of Warcraft Forever // WoW 1.60.1

🟢 Burning Crusade Anniversary // WoW 2.5.6

🔴 Mists of Pandaria Classic // WoW 5.5.4

🔴 World of Warcraft // WoW 12.1.0

**Localization Status** // Works with all Classic WoW Locales (enUS, deDE, esES, esMX, frFR, itIT, koKR, ptBR, ruRU, zhCN, zhTW).

Please reach out if you would like to be involved!

## Links

- [GitHub](https://github.com/Gogo1951/Water-Dispenser)
- [Discord](https://discord.gg/eh8hKq992Q)

## Appreciation & History

👾 **I didn't create this add-on, I just updated it.**

- Razyel's [Water Dispenser](https://www.wowinterface.com/downloads/info25489-WaterDispenser.html)
- Junsa's [Water Dispenser Era](https://www.curseforge.com/wow/addons/water-dispenser-era)

## Related Add-ons

🟢 Pairs With // Gogo1951's [Connoisseur & Restocker](https://www.curseforge.com/wow/addons/consumable-connoisseur)

🟢 Pairs With // Gogo1951's [Play It Forward](https://www.curseforge.com/wow/addons/play-it-forward)

🟢 Pairs With // noobsgonewild's [Tank HealthStone Tracker](https://www.curseforge.com/wow/addons/tank-healthstone-tracker)

🟡 Some Overlap // Emmadruid's [ConjureHelper](https://www.curseforge.com/wow/addons/conjurehelper)

🟡 Some Overlap // afrugalpenguin's [MageTools](https://www.curseforge.com/wow/addons/magetools)

🟡 Some Overlap // Shadrizz's [Necrosis TBC Anniversary](https://www.curseforge.com/wow/addons/necrosis-tbc-anniversary)

🟡 Some Overlap // luvaboyy's [Thic-Portals](https://www.curseforge.com/wow/addons/thic-portals-your-portal-shop-helper)

🟡 Some Overlap // afrugalpenguin's [WarlockTools](https://www.curseforge.com/wow/addons/warlocktools)

🔴 Direct Alternative // HazeSuite's [HazeWaterBoy](https://www.curseforge.com/wow/addons/hazewaterboy)

🔴 Direct Alternative // Codermik's [tradeDispenser](https://www.curseforge.com/wow/addons/tradedispenser)

🔴 Direct Alternative // Mafkees's [TradeFill](https://www.curseforge.com/wow/addons/tradefill)

🔴 Direct Alternative // enshadowed_'s [Water Dispenser BCC](https://www.curseforge.com/wow/addons/water-dispenser-bcc)

🔴 Direct Alternative // BlessedRabies2's [Water Dispenser Fixed](https://www.curseforge.com/wow/addons/water-dispenser-fixed)
