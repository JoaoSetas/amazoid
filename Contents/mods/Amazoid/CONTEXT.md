# Amazoid Mod - Development Context Document

> **Use this document when starting a new chat session to continue development.**
> Copy and paste this entire document as context for the AI assistant.

## Project Summary

**Amazoid** is a Project Zomboid Build 42 mod featuring a mysterious mailbox merchant. Players find discovery letters in mailboxes, sign contracts to access the service, order items from catalogs, complete missions, and build reputation to unlock more catalogs and receive gifts.

**Repository**: `git@github.com:JoaoSetas/amazoid.git`
**Mod Location**: `C:\Users\setas\Zomboid\Workshop\Amazoid\Contents\mods\Amazoid\`

## Directory Structure

```
42/
├── mod.info                           # Mod metadata (versionMin=42.0)
├── media/
│   ├── lua/
│   │   ├── client/Amazoid/
│   │   │   ├── AmazoidClient.lua         # Client initialization, player data, reputation
│   │   │   ├── AmazoidClientMain.lua     # Client entry point, loads all client modules
│   │   │   ├── AmazoidContextMenu.lua    # Right-click menus for letters/catalogs
│   │   │   ├── AmazoidGifts.lua          # Action-based gift system
│   │   │   ├── AmazoidMissionTracker.lua # Kill tracking for elimination missions
│   │   │   ├── AmazoidProtectionDevice.lua
│   │   │   ├── AmazoidReputationTriggers.lua # Event listeners for rep-based rewards
│   │   │   └── UI/
│   │   │       ├── AmazoidBasePanel.lua    # Base UI panel class
│   │   │       ├── AmazoidLetterPanel.lua  # Letter reading UI, contract signing
│   │   │       ├── AmazoidCatalogPanel.lua # Catalog browsing UI
│   │   │       └── AmazoidMissionsPanel.lua
│   │   ├── server/Amazoid/
│   │   │   ├── AmazoidServer.lua       # Server initialization
│   │   │   ├── AmazoidServerMain.lua   # Server entry point
│   │   │   └── AmazoidSpawner.lua      # Mailbox letter spawning (DISABLED)
│   │   └── shared/Amazoid/
│   │       ├── AmazoidCatalogs.lua     # Catalog editions, items, unlock logic
│   │       ├── AmazoidData.lua         # Global Amazoid namespace, constants
│   │       ├── AmazoidDebug.lua        # Debug utilities
│   │       ├── AmazoidEvents.lua       # Centralized pub/sub event system
│   │       ├── AmazoidItems.lua        # Item definitions (Lua tables)
│   │       ├── AmazoidLetters.lua      # All letter templates (milestones, lore, etc)
│   │       ├── AmazoidMailbox.lua      # Mailbox detection, orders, visits
│   │       ├── AmazoidMain.lua         # Shared entry point, loads all shared modules
│   │       ├── AmazoidMissions.lua     # Mission generation and collection logic
│   │       ├── AmazoidSandbox.lua      # Sandbox option handling
│   │       └── AmazoidUtils.lua        # Utility functions
│   ├── scripts/
│   │   └── amazoid_items.txt           # Build 42 item definitions
│   └── sandbox-options.txt             # Mod settings
└── .github/
    └── copilot-instructions.md         # AI coding agent instructions
```

## Current State

### What Works
- ✅ Mod loads without errors
- ✅ Discovery letter appears in mailbox on first contact
- ✅ Contract signing activates mailbox service
- ✅ Catalog panel with edition/volume system
- ✅ Package-based delivery system (4 sizes)
- ✅ Collection missions (bring items to mailbox)
- ✅ Elimination missions (kill zombies with weapon requirements)
- ✅ Mission completion with rewards (money + reputation)
- ✅ Reputation-based catalog unlocks
- ✅ Spending-based volume unlocks (Basic Vol2 unlocks after first order)
- ✅ Seasonal catalogs (auto-given each season)
- ✅ Milestone letters (8 thresholds: 13, 18, 38, 60, 70, 80, 90, 100)
- ✅ Lore letters (7 letters revealing merchant backstory)
- ✅ Action-based gifts (heal, kill streak, survive, cook, read)
- ✅ Reputation-based gifts (6 gift tiers with packages)
- ✅ Centralized event system for decoupled communication
- ✅ Split-screen local co-op support (shared read tracking)
- ✅ Merchant visit retry logic (retries every 10 min if player too close)

### Not Yet Implemented
- ⬜ Scavenger missions (find marked zombie)
- ⬜ Timed delivery missions
- ⬜ Protection missions (protect device from zombies)

## Architecture

### Event System (AmazoidEvents.lua)
Centralized pub/sub for decoupled communication:
```lua
-- Subscribe
Amazoid.Events.on("ReputationChanged", function(data)
    print("Rep: " .. data.oldRep .. " -> " .. data.newRep)
end, 100) -- priority: higher = first

-- Fire
Amazoid.Events.fire("ReputationChanged", {oldRep=10, newRep=15, reason="mission"})
```

**Available Events:**
- `ReputationChanged` - {oldRep, newRep, amount, reason}
- `MoneySpent` - {amount, categories, totalSpent, totalSpentByCategory}
- `OrderPlaced` / `OrderDelivered` - {order, mailbox}
- `MissionAccepted` / `MissionCompleted` / `MissionFailed`
- `ContractSigned` - {mailboxLocation}
- `GiftSent` - {triggerType, items, mailbox}

### Merchant Visit Logic
The merchant visits the player's contract mailbox periodically:
- **Hourly Check**: Attempts visit every hour via `Events.EveryHours`
- **Distance Check**: Merchant won't visit if any player is within 15 tiles of mailbox
- **Retry System**: If blocked by proximity, retries every 10 minutes via `Events.EveryTenMinutes`
- **Pending Flag**: `playerData.pendingMerchantVisit` tracks if retry is needed

### Split-Screen Read Tracking
For split-screen co-op, letter read status uses dual tracking:
1. PZ's native `player:addReadLiterature()` - per-player tracking
2. Custom `modData.AmazoidRead = true` - shared flag set when ANY player closes letter
3. `Amazoid.Utils.hasAnyPlayerRead(item)` - checks if any player has read

### Reputation Thresholds (Catalog Unlocks)
Catalog editions unlock at specific reputation levels (from AmazoidData.lua):

| Rep | Catalog Edition |
| --- | --------------- |
| 0   | Basic           |
| 5   | Seasonal        |
| 10  | Outdoor         |
| 15  | Clothing        |
| 20  | Tools           |
| 25  | Literature      |
| 30  | Medical         |
| 35  | Electronics     |
| 40  | Weapons         |
| 60  | Black Market    |

### Milestone Letter Thresholds
Milestone letters are sent at these reputation values:
- 13, 18, 38, 60, 70, 80, 90, 100

### Volume Unlock System
- **Basic Volume 2**: Unlocks after placing first order (since first order is free)
- **Other Volumes**: Unlock based on total spending in category ($100 per volume)

### Key Code Patterns

**Context Menu for Items:**
```lua
Events.OnFillInventoryObjectContextMenu.Add(function(playerNum, context, items)
    for i = 1, #items do
        local item = items[i]
        if instanceof(item, "InventoryItem") and item:getFullType() == "Amazoid.DiscoveryLetter" then
            context:addOption("Read Letter", item, onReadLetter, playerNum)
        end
    end
end)
```

**Safe Item Creation (B42):**
```lua
local item = instanceItem("Amazoid.SignedContract")
if item then
    inv:addItem(item)
else
    inv:AddItem("Amazoid.SignedContract")  -- fallback
end
```

**ModData Storage:**
```lua
-- Player data
local data = player:getModData().Amazoid or {}
data.reputation = 50
player:getModData().Amazoid = data

-- Global data
local globalData = ModData.getOrCreate("Amazoid")
```

## Debug Commands

```lua
AmazoidDebug.status()             -- Show full status
AmazoidDebug.giveRep(20)          -- Add reputation
AmazoidDebug.setRep(50)           -- Set reputation
AmazoidDebug.giveMission()        -- Give collection mission
AmazoidDebug.giveEliminationMission() -- Give elimination mission
AmazoidDebug.completeMissions()   -- Complete all missions
AmazoidDebug.merchantVisit()      -- Force merchant visit
AmazoidDebug.firstContact()       -- Force first contact
AmazoidDebug.giveAllCatalogs()    -- Give all catalogs
AmazoidDebug.test()               -- Full test setup
AmazoidDebug.testWeapon("Katana") -- Test specific weapon
AmazoidDebug.teleportToMailbox()  -- Teleport to contract mailbox
```

## Files to Check When Debugging

| Issue               | Check These Files                                                  |
| ------------------- | ------------------------------------------------------------------ |
| Events not firing   | `shared/Amazoid/AmazoidEvents.lua`                                 |
| Rep rewards missing | `client/Amazoid/AmazoidReputationTriggers.lua`                     |
| Gifts not appearing | `client/Amazoid/AmazoidGifts.lua`, `AmazoidReputationTriggers.lua` |
| Mission tracking    | `client/Amazoid/AmazoidMissionTracker.lua`                         |
| Catalog unlocks     | `shared/Amazoid/AmazoidCatalogs.lua`                               |
| Letter content      | `shared/Amazoid/AmazoidLetters.lua`                                |
| Order processing    | `shared/Amazoid/AmazoidMailbox.lua`                                |

## Useful PowerShell Commands

```powershell
# Check console for errors
Get-Content "$env:USERPROFILE\Zomboid\console.txt" -Tail 100 | Select-String "ERROR|SEVERE|Amazoid|nil"

# Check event firing
Get-Content "$env:USERPROFILE\Zomboid\console.txt" -Tail 50 | Select-String "Events"

# Git status
cd "C:\Users\setas\Zomboid\Workshop\Amazoid\Contents\mods\Amazoid"; git status
```

---

**To continue development**: Paste this document at the start of a new chat and describe what you want to work on next.
