# Amazoid Mod - Copilot Instructions

## Project Overview
Project Zomboid **Build 42** mod featuring a mysterious mailbox merchant with catalog ordering, reputation system, and missions (collection + elimination). Supports split-screen local co-op.

> **Target Version**: Build 42 (versionMin=42.0 in mod.info)
> Build 42 has significant scripting changes from Build 41. Always verify patterns against B42 documentation.

## Documentation References

- **Modding Hub**: https://pzwiki.net/wiki/Modding
- **Lua API**: https://pzwiki.net/wiki/Lua_(API)
- **Scripts Reference**: https://pzwiki.net/wiki/Scripts
- **Debug Mode**: https://pzwiki.net/wiki/Debug_mode

### Vanilla Script/Lua Locations
```
C:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid\media\scripts\generated\items\
C:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid\media\lua\
```

## Architecture

### Directory Structure
```
42/media/
├── lua/
│   ├── client/Amazoid/     # UI, context menus, mission tracker, split-screen helpers
│   │   └── UI/             # Panel classes (BasePanel, CatalogPanel, LetterPanel, MissionsPanel)
│   ├── server/Amazoid/     # Spawning, order processing, world state
│   └── shared/Amazoid/     # Data constants, utilities, mailbox logic, missions, catalogs
├── scripts/                # Item definitions (amazoid_items.txt) - Build 42 syntax
└── sandbox-options.txt     # Mod settings
```

### Key Files
| File | Purpose |
|------|---------|
| `AmazoidData.lua` | Global `Amazoid` namespace, constants (reputation thresholds, mission types) |
| `AmazoidClient.lua` | Player data, split-screen helpers (`getAllLocalPlayers`, `findNearbyMailbox`), merchant visit logic |
| `AmazoidMailbox.lua` | Mailbox detection, contract handling, catalog/mission spawning, volume unlocks |
| `AmazoidMissions.lua` | Mission tiers (collection/elimination), generation, serialization |
| `AmazoidMissionTracker.lua` | Kill tracking for elimination missions, event hooks |
| `AmazoidDebug.lua` | Debug console commands (status, giveMission, merchantVisit, etc.), `getLocalPlayer()` for split-screen |
| `AmazoidCatalogs.lua` | Catalog editions (types × volumes) |
| `AmazoidLetters.lua` | All letter templates (milestones, lore, triggered letters) |
| `AmazoidUtils.lua` | Utility functions including `hasAnyPlayerRead()` for split-screen |

## Build 42 Script Syntax

**CRITICAL**: Build 42 uses different item syntax than Build 41.

```txt
module Amazoid {
    item MyItem {
        ItemType = base:normal,      // NOT "Type = Normal"
        DisplayCategory = Literature,
        Weight = 0.01,               // Letters: 0.01, Catalogs: 0.05
        Icon = Paperwork5,
        WorldStaticModel = Paperwork5,
    }
}
```

Valid ItemTypes: `base:normal`, `base:container`, `base:weapon`, `base:food`, `base:clothing`, etc.

## Lua Environment (Kahlua - Lua 5.1)

### Limitations
- **No `goto`/`continue`** - use nested conditionals or early returns
- **No ternary** - use `condition and valueA or valueB`
- **No bitwise operators** - use `bit.band()`, `bit.bor()`

### ModData Serialization Pattern
Nested tables in `modData` don't serialize reliably. Flatten before storing:
```lua
-- In AmazoidMissions.lua
function Amazoid.Missions.serializeForModData(mission)
    return {
        id = mission.id,
        missionNumber = mission.missionNumber,
        reqItemType = mission.requirements and mission.requirements.itemType,
        rewardMoney = mission.reward and mission.reward.money,
        -- ... flatten all nested fields
    }
end

function Amazoid.Missions.deserializeFromModData(flatMission)
    -- Reconstruct nested tables
end
```

### Split-Screen Support
Always use `getAllLocalPlayers()` instead of single-player assumptions:
```lua
-- In AmazoidClient.lua
for _, player in ipairs(Amazoid.Client.getAllLocalPlayers()) do
    -- Handle each local player
end

-- Notify all nearby players when merchant visits
Amazoid.Client.makeNearbyPlayersSay(mailbox, 100, "The merchant visited!")

-- In AmazoidDebug.lua, use getLocalPlayer() instead of getPlayer()
local player = AmazoidDebug.getLocalPlayer()
```

## Testing Workflow

1. Add `-debug` to Steam launch options
2. Load save with Amazoid mod enabled
3. Open Lua console (use debug mode)
4. Use debug commands:

```lua
AmazoidDebug.status()             -- Show reputation, contract status
AmazoidDebug.merchantVisit()      -- Trigger merchant visit now
AmazoidDebug.giveMission()        -- Give a collection mission
AmazoidDebug.giveEliminationMission() -- Give an elimination mission
AmazoidDebug.setRep(50)           -- Set reputation to unlock black market
AmazoidDebug.test()               -- Full setup for testing
```

### Error Checking
```powershell
Get-Content "$env:USERPROFILE\Zomboid\console.txt" -Tail 100 | Select-String "ERROR|SEVERE|Amazoid|nil value"
```

## Key Patterns

### Daily Limits
Missions and catalogs are limited to one per day using day tracking:
```lua
local currentDay = math.floor(getGameTime():getWorldAgeHours() / 24)
if currentDay <= Amazoid.Client.playerData.lastMissionDay then return false end
-- ... spawn mission ...
Amazoid.Client.playerData.lastMissionDay = currentDay
```

### Item Pricing by Rarity
Weapon prices in `AmazoidItems.lua` scale by in-game rarity:
- Common melee (Bat): ~$150
- Rare melee (Crowbar, Axe): $300-400
- Very rare (Katana, Sledgehammer): $2000-2500
- Firearms: $800-3000

### Mission Design
- **Collection**: Request craftable/findable items NOT sold by merchant
- **Elimination**: Rewards ~$1-2 per zombie, bonuses for weapon restrictions
- Mission number stored in mission object before adding to `activeMissions`

### Reputation Thresholds (from AmazoidData.lua)
```lua
CATALOG_BASIC = 0,
CATALOG_SEASONAL = 5,
CATALOG_OUTDOOR = 10,
CATALOG_CLOTHING = 15,
CATALOG_TOOLS = 20,
CATALOG_LITERATURE = 25,
CATALOG_MEDICAL = 30,
CATALOG_ELECTRONICS = 35,
CATALOG_WEAPONS = 40,
CATALOG_BLACKMARKET = 60,
```

### Milestone Letter Thresholds
```lua
-- Reputation values that trigger milestone letters
13, 18, 38, 60, 70, 80, 90, 100
```

### Merchant Visit Retry Pattern
Merchant visits hourly but retries every 10 minutes if player is too close:
```lua
-- Hourly check
function onEveryHour()
    Amazoid.Client.tryMerchantVisit()
end

-- Retry every 10 min if pending
function onEveryTenMinutes()
    if not Amazoid.Client.playerData.pendingMerchantVisit then return end
    if not Amazoid.Client.isPlayerTooCloseToMailbox() then
        -- Perform visit...
        Amazoid.Client.playerData.pendingMerchantVisit = false
    end
end
```

### Split-Screen Read Tracking
For letters/catalogs, use dual tracking for split-screen support:
```lua
-- When closing letter (in AmazoidLetterPanel.lua)
local modData = self.letterItem:getModData()
modData.AmazoidRead = true

-- Check if ANY player has read (in AmazoidUtils.lua)
function Amazoid.Utils.hasAnyPlayerRead(item)
    local modData = item:getModData()
    if modData and modData.AmazoidRead then return true end
    -- Fallback: check all players' read literature
end
```

### Volume Unlock Pattern
Basic Volume 2 has special unlock condition (first order is free):
```lua
-- In AmazoidMailbox.lua checkVolumeUnlocks()
if basicVolume == 1 and Amazoid.Client.playerData.hasPlacedFirstOrder then
    -- Unlock Basic Volume 2 (special case - any order unlocks it)
end
-- Other volumes use spending thresholds
```

## Multiplayer Considerations

- `lua/client/` runs on each player's machine
- `lua/server/` runs on host/server only
- `lua/shared/` runs on both
- Use `sendClientCommand`/`sendServerCommand` for client-server sync
