# Amazoid Mod - Complete Testing Checklist

This document contains every check required to validate all features of the Amazoid mod.

## Test Setup

### Prerequisites
1. [ ] Enable debug mode: Add `-debug` to Steam launch options
2. [ ] Load a save with the Amazoid mod enabled
3. [ ] Open Lua console (Escape → Debug)

### Quick Test Setup
```lua
AmazoidDebug.test()  -- Gives all items and sets up for testing
```

### Reset Between Tests
```lua
AmazoidDebug.reset()        -- Reset ALL Amazoid data (player, mailboxes, world)
AmazoidDebug.newGame()      -- Simulate fresh new game
```

---

## 1. Initial Discovery & Contract

### 1.1 First Contact Timing
- [ ] New game loads without instant first contact
- [ ] First contact occurs after 1+ hour delay from game start
- [ ] First contact happens within 1-3 days (sandbox FirstContactDays setting)
- [ ] Discovery letter spawns in a nearby mailbox (within 100 tiles)

**Debug:**
```lua
AmazoidDebug.firstContact()  -- Force first contact
```

### 1.2 Discovery Letter
- [ ] Discovery letter appears in mailbox
- [ ] Right-click mailbox shows "Read Discovery Letter" option
- [ ] Letter opens in UI panel with proper formatting
- [ ] Letter explains mailbox-based service
- [ ] "Sign Contract" checkbox and button are present
- [ ] Cannot sign without checking the checkbox
- [ ] Signing closes the panel

**Verify content includes:**
- [ ] How the mailbox service works
- [ ] Explanation that this mailbox becomes the contract mailbox
- [ ] Mention of catalogs and reputation

### 1.3 Contract Signing
- [ ] Signing creates player contract data
- [ ] Contract mailbox location is saved
- [ ] `hasContract` is set to true
- [ ] `contractSignedDay` is recorded (for milestone tracking)
- [ ] Basic catalog category is unlocked
- [ ] Player can now access Amazoid Services menu on mailbox

**Verify:**
```lua
AmazoidDebug.status()  -- Check contract status
```

---

## 2. Mailbox Context Menu

### 2.1 Before Contract
- [ ] Mailbox with discovery letter shows "Read Discovery Letter"
- [ ] Mailbox without discovery shows "No service available here"

### 2.2 After Contract (Contract Mailbox)
- [ ] "View Catalog" option present
- [ ] "View Missions" option present
- [ ] "Check Order Status" option present
- [ ] Current reputation displayed

### 2.3 Non-Contract Mailbox
- [ ] Shows "No service available here"

---

## 3. Catalog System

### 3.1 Catalog Categories & Unlocks
Test each catalog unlocks at correct reputation:

| Category     | Required Rep | Test Command              |
| ------------ | ------------ | ------------------------- |
| Basic        | 0            | `AmazoidDebug.setRep(0)`  |
| Medical      | 10           | `AmazoidDebug.setRep(10)` |
| Tools        | 25           | `AmazoidDebug.setRep(25)` |
| Seasonal     | 35           | `AmazoidDebug.setRep(35)` |
| Weapons      | 45           | `AmazoidDebug.setRep(45)` |
| Black Market | 60           | `AmazoidDebug.setRep(60)` |

- [ ] Basic unlocks at reputation 0+
- [ ] Medical unlocks at reputation 10+
- [ ] Tools unlocks at reputation 25+
- [ ] Seasonal unlocks at reputation 35+
- [ ] Weapons unlocks at reputation 45+
- [ ] Black Market unlocks at reputation 60+

### 3.2 Catalog Volumes
- [ ] Volume 1 spawns when category first unlocks
- [ ] Volume 2 spawns after completing Volume 1 (more missions)
- [ ] Higher volumes have more/better items
- [ ] Only one catalog spawns per day (daily limit)

**Debug:**
```lua
AmazoidDebug.giveCatalog()                    -- Give basic catalog
AmazoidDebug.giveCatalogEdition("weapons_vol2")  -- Give specific edition
AmazoidDebug.giveAllCatalogs()                -- Give all editions
AmazoidDebug.listEditions()                   -- List all available editions
```

### 3.3 Catalog UI
- [ ] Catalog opens when used from inventory
- [ ] Catalog opens when viewed from mailbox menu
- [ ] Page navigation works (next/prev)
- [ ] Edition name displays in header
- [ ] Items display with name, price, icon
- [ ] Locked items show lock icon and rep requirement
- [ ] Seasonal items show correct season

### 3.4 Ordering from Catalog
- [ ] Left-click circles an item (adds to order)
- [ ] Right-click circles multiple (quantity selection)
- [ ] Circled items show circle overlay and count
- [ ] Order summary updates with total price
- [ ] "Place Order" button calculates correct total
- [ ] Order total accounts for discount
- [ ] Orders are saved to catalog modData

---

## 4. Order Processing

### 4.1 Placing Orders
- [ ] Circle items in catalog
- [ ] Leave catalog with circled items in mailbox
- [ ] Leave money in mailbox (equal or greater than total)
- [ ] Wait for merchant visit

**Debug:**
```lua
AmazoidDebug.merchantVisit()  -- Trigger merchant visit
AmazoidDebug.mailboxStatus()  -- Check mailbox contents
```

### 4.2 Order Confirmation
- [ ] Money is removed from mailbox
- [ ] Order receipt letter appears in mailbox
- [ ] Receipt shows ordered items and total
- [ ] Change is returned if overpaid
- [ ] Player stats update (totalOrders, totalSpent)

### 4.3 Order Delivery
- [ ] Delivery happens after delivery time
- [ ] Items appear in delivery package
- [ ] Package size matches order size (Small/Medium/Large/Crate)
- [ ] All ordered items are in package
- [ ] Delivery notification sounds

### 4.4 Payment Scenarios
| Scenario      | Expected Result                                               |
| ------------- | ------------------------------------------------------------- |
| Exact payment | Order processed, reputation neutral                           |
| Overpayment   | Order processed, change returned, no reputation bonus         |
| Underpayment  | Order canceled, "not enough money" letter, reputation penalty |
| No money      | Order canceled, warning letter                                |

- [ ] Exact payment works correctly
- [ ] Overpayment returns change (no bonus)
- [ ] Underpayment cancels order with penalty
- [ ] No money gives warning

---

## 5. Mission System

### 5.1 First Mission
- [ ] First mission letter spawns with discovery letter
- [ ] First mission is always a simple collection task
- [ ] Mission text is not truncated
- [ ] Mission shows "Leave them in the mailbox after signing the contract."

**Debug:**
```lua
AmazoidDebug.giveMission()  -- Give a collection mission
```

### 5.2 Collection Missions

#### Tier Requirements
| Tier | Rep Range | Example Items                     |
| ---- | --------- | --------------------------------- |
| 1    | 0-9       | Rags, Nails, Plank                |
| 2    | 10-19     | Bandage, Sheet, Doorknob          |
| 3    | 20-34     | Metal Bar, Glue, Pipe             |
| 4    | 35-49     | Axe, Generator Magazine, Padlock  |
| 5    | 50+       | Sledgehammer, Propane Tank, Watch |

- [ ] Missions match player reputation tier
- [ ] Items are craftable/findable (not merchant-sold)
- [ ] Item count is reasonable
- [ ] Reward scales with difficulty

#### Completing Collection Missions
- [ ] Place required items in mailbox
- [ ] Wait for merchant visit
- [ ] Items are removed from mailbox
- [ ] Money reward appears in mailbox
- [ ] Reputation increases
- [ ] Mission completion letter appears
- [ ] Mission removed from active list

**Debug:**
```lua
AmazoidDebug.listMissions()      -- Show active missions
AmazoidDebug.completeMissions()  -- Force complete missions
```

### 5.3 Elimination Missions

**Debug:**
```lua
AmazoidDebug.giveEliminationMission()  -- Give elimination mission
```

#### Tier Requirements
| Tier | Rep Range | Kill Count | Weapon Types                    |
| ---- | --------- | ---------- | ------------------------------- |
| 1    | 0-9       | 5-10       | Any, Melee                      |
| 2    | 10-24     | 10-15      | Any, Melee                      |
| 3    | 25-34     | 12-20      | Any, Specific (Axe)             |
| 4    | 35-59     | 15-25      | Any, Specific (Crowbar, Katana) |
| 5    | 60+       | 20-50      | Any, Specific (Sledgehammer)    |

- [ ] Kill tracking starts when mission accepted
- [ ] Progress notifications at 1, 5, 10, 15, etc. kills
- [ ] Weapon requirement enforced (wrong weapon doesn't count)
- [ ] "any" weapon type accepts all weapons
- [ ] "melee" type accepts all melee weapons
- [ ] Specific weapon type (e.g., Base.Axe) only accepts that weapon
- [ ] Time limit (if any) counts down
- [ ] Mission auto-completes when kill count reached
- [ ] Reward: ~$1-2 per zombie
- [ ] Kill count persists across saves

### 5.4 Daily Mission Limits
- [ ] Only one mission spawns per in-game day
- [ ] New mission won't spawn if one already active
- [ ] 70% chance per merchant visit (when eligible)

---

## 6. Reputation System

### 6.1 Reputation Gains
| Action                       | Rep Change |
| ---------------------------- | ---------- |
| Complete order (per $10)     | +1         |
| Complete collection mission  | +3         |
| Complete elimination mission | +3         |
| Receive gift                 | +1         |

- [ ] Order completion gives reputation based on amount spent
- [ ] Mission completion gives +3 reputation
- [ ] Gift receipt gives +1 reputation

### 6.2 Reputation Losses
| Action                  | Rep Change |
| ----------------------- | ---------- |
| Underpay order (per $1) | -2         |
| Fail mission            | -10        |
| Keep scavenger items    | -15        |

- [ ] Underpaying penalizes reputation
- [ ] Failed missions penalize heavily

### 6.3 Reputation Effects
- [ ] Catalog unlocks at thresholds
- [ ] Mission tiers unlock at thresholds
- [ ] Below threshold 10: merchant may "steal" money (random)
- [ ] Discount increases with reputation

**Verify:**
```lua
AmazoidDebug.status()     -- Check current reputation
AmazoidDebug.setRep(50)   -- Set specific reputation
AmazoidDebug.giveRep(10)  -- Add reputation
```

---

## 7. Merchant Visits

### 7.1 Visit Timing
- [ ] Merchant visits every hour (sandbox setting)
- [ ] No instant visit on game load
- [ ] Visit processes all contracted mailboxes

### 7.2 Visit Processing Order
1. [ ] Spawn catalogs (if eligible)
2. [ ] Process catalog orders (if money + circled items)
3. [ ] Deliver pending orders (if delivery time passed)
4. [ ] Process missions (collect items, reward)
5. [ ] Spawn new missions (if eligible)
6. [ ] Check triggered letters (milestones, clothing)
7. [ ] Notify player (sound + speech bubble)

**Debug:**
```lua
AmazoidDebug.merchantVisit()  -- Trigger visit now
```

### 7.3 Visit Notifications
- [ ] Mailbox sound plays
- [ ] Nearby players (within 100 tiles) say random phrase
- [ ] Notifications only if merchant added something new

---

## 8. Triggered Letters (Milestones)

### 8.1 Kill Milestones
| Kills | Letter Title              | Content Hints                    |
| ----- | ------------------------- | -------------------------------- |
| 10    | "First Blood (Times Ten)" | Hints about elimination missions |
| 50    | "Fifty Down"              | Hints about Weapons catalog      |
| 100   | "The Centurion"           | Hints about Black Market         |

- [ ] Letter spawns on next merchant visit after milestone
- [ ] Letter only spawns once per milestone
- [ ] Kill count tracks across saves

### 8.2 Days Survived Milestones
| Days | Letter Title         | Content Hints                |
| ---- | -------------------- | ---------------------------- |
| 7    | "One Week Strong"    | Hints about Tools catalog    |
| 14   | "Two Weeks In"       | Hints about Seasonal catalog |
| 30   | "The Month Survivor" | Hints about Medical catalog  |

- [ ] Days counted from contract signing, not game start
- [ ] Letter spawns on next merchant visit after milestone
- [ ] Letter only spawns once per milestone

### 8.3 Clothing Detection Letters
| Outfit   | Letter Title                 |
| -------- | ---------------------------- |
| Clown    | "Fashion Statement"          |
| Spiffo   | "Our Favorite Customer"      |
| Santa    | "Ho Ho... Oh."               |
| Prisoner | "A Fresh Start"              |
| Military | "Thank You For Your Service" |
| Bathrobe | "Casual Friday"              |

- [ ] Detected by worn items, not inventory
- [ ] Only triggers once per outfit type
- [ ] Letter content is humorous/lore-appropriate

**Test clothing items:**
- Clown: Hat_ClownWig, Jacket_Clown, Trousers_Clown
- Spiffo: SpiffoSuit, SpiffoHead, Suit_Spiffo
- Santa: Hat_SantaHat, Vest_SantaJacket, Trousers_SantaRed
- Prisoner: Jumpsuit_Prisoner, Tshirt_InmateOrange, Trousers_Prisoner
- Military: Hat_Army, Hat_BalaclavaArmy, Vest_BulletArmy, Jacket_Army
- Bathrobe: Robe_Bathrobe, Vest_BathRobe

---

## 9. Gift System

### 9.1 Gift Triggers
| Trigger      | Threshold        | Gift Items                       |
| ------------ | ---------------- | -------------------------------- |
| Heal wounds  | 5 heals          | Bandage, AlcoholBandage          |
| Kill streak  | 20 kills quickly | Bullets9mm, BaseballBat          |
| Survive days | Every 7 days     | TinnedBeans, TinnedSoup, Bandage |
| Cook food    | 10 cooked items  | Pan, Pot                         |
| Read books   | 3 skill books    | Random book                      |

- [ ] Gift triggers after reaching threshold
- [ ] Gift appears in contracted mailbox
- [ ] Gift letter included
- [ ] 24-hour cooldown between gifts
- [ ] Requires minimum 10 reputation
- [ ] Counter resets after gift (where applicable)

---

## 10. UI Panels

### 10.1 Letter Panel (AmazoidLetterPanel)
- [ ] Opens for discovery letter, mission letters, triggered letters
- [ ] Title displays correctly
- [ ] Content renders with proper formatting
- [ ] Line breaks work (`<LINE>`)
- [ ] Colors work (`<RGB:r,g,b>`)
- [ ] Scroll works for long content
- [ ] Close button works
- [ ] Contract checkbox/sign button (discovery only)

### 10.2 Catalog Panel (AmazoidCatalogPanel)
- [ ] Opens from inventory or mailbox menu
- [ ] Edition header shows correct name
- [ ] Page navigation (prev/next) works
- [ ] Items display correctly
- [ ] Locked items show requirements
- [ ] Circle/uncircle works
- [ ] Order total updates
- [ ] Close button works

### 10.3 Missions Panel (AmazoidMissionsPanel)
- [ ] Opens from mailbox menu
- [ ] Lists all active missions
- [ ] Shows mission type, title, progress
- [ ] Collection missions show item requirements
- [ ] Elimination missions show kill progress
- [ ] Close button works

---

## 11. Split-Screen Support

### 11.1 Multi-Player Detection
- [ ] `getAllLocalPlayers()` returns all local players
- [ ] Works with 0, 1, 2, 3, 4 players

### 11.2 Per-Player Features
- [ ] Each player has own contract data
- [ ] Each player has own reputation
- [ ] Each player has own missions

### 11.3 Shared Features
- [ ] All nearby players hear merchant visit notifications
- [ ] Object visibility checks for any local player

**Test with split-screen:**
- [ ] Player 1 signs contract
- [ ] Player 2 can see merchant notifications
- [ ] Both players can access their own mailboxes

---

## 12. Item Definitions

### 12.1 Letter Items
| Item               | Weight | Icon          |
| ------------------ | ------ | ------------- |
| DiscoveryLetter    | 0.01   | Paperwork5    |
| SignedContract     | 0.01   | LiquorLicense |
| MerchantLetter     | 0.01   | Paperwork5    |
| MissionLetter      | 0.01   | Paperwork5    |
| LoreLetter         | 0.01   | Paperwork5    |
| DeliveryNoteLetter | 0.01   | Paperwork5    |
| GiftLetter         | 0.01   | Paperwork5    |
| OrderReceipt       | 0.01   | Receipt       |

- [ ] All letters have correct weight (0.01)
- [ ] All letters have correct icons

### 12.2 Catalog Items
| Item    | Weight | Icon      |
| ------- | ------ | --------- |
| Catalog | 0.05   | Newspaper |

- [ ] Catalog has correct weight (0.05)
- [ ] Edition stored in modData.AmazoidEdition

### 12.3 Package Items
| Item                  | Capacity | Weight |
| --------------------- | -------- | ------ |
| DeliveryPackageSmall  | 5        | 0.1    |
| DeliveryPackageMedium | 15       | 0.2    |
| DeliveryPackageLarge  | 30       | 0.3    |
| DeliveryCrate         | 50       | 0.5    |

- [ ] Packages are containers
- [ ] Packages have correct capacity

### 12.4 Special Items
| Item             | Purpose                                   |
| ---------------- | ----------------------------------------- |
| ProtectionDevice | Protection missions (not yet implemented) |

---

## 13. Sandbox Options

### 13.1 Available Options
| Option                   | Default | Range   | Description                       |
| ------------------------ | ------- | ------- | --------------------------------- |
| FirstContactDays         | 3       | 1-30    | Days until first merchant contact |
| PriceMultiplier          | 1.0     | 0.1-5.0 | Multiplier for all prices         |
| DeliveryTimeMultiplier   | 1.0     | 0.1-5.0 | Multiplier for delivery times     |
| MerchantVisitInterval    | 1       | 1-24    | Hours between merchant visits     |
| ReputationGainMultiplier | 1.0     | 0.1-5.0 | Multiplier for reputation gains   |
| ReputationLossMultiplier | 1.0     | 0.1-5.0 | Multiplier for reputation losses  |

- [ ] FirstContactDays affects first contact timing
- [ ] PriceMultiplier affects all catalog prices
- [ ] DeliveryTimeMultiplier affects delivery wait times
- [ ] MerchantVisitInterval affects visit frequency
- [ ] ReputationGainMultiplier affects positive rep changes
- [ ] ReputationLossMultiplier affects negative rep changes

---

## 14. Persistence & Saves

### 14.1 Player Data Persistence
- [ ] Contract status saves/loads
- [ ] Reputation saves/loads
- [ ] Active missions save/load
- [ ] Order history saves/loads
- [ ] Unlocked catalogs save/load
- [ ] Kill counts save/load
- [ ] Sent triggered letters save/load
- [ ] Contract signed day saves/loads

### 14.2 Mailbox Data Persistence
- [ ] Contract mailbox saves/loads
- [ ] Discovery letter flag saves/loads
- [ ] Pending orders save/load
- [ ] Catalog modData (circled items) saves/loads

### 14.3 Global Data Persistence
- [ ] Letter numbering persists
- [ ] Mission numbering persists

---

## 15. Error Handling

### 15.1 Console Error Check
After each test session:
```powershell
Get-Content "$env:USERPROFILE\Zomboid\console.txt" -Tail 100 | Select-String "ERROR|SEVERE|Amazoid|nil value"
```

- [ ] No Lua errors related to Amazoid
- [ ] No nil value errors
- [ ] No undefined variable errors

### 15.2 Edge Cases
- [ ] Empty mailbox on merchant visit (no crash)
- [ ] No contract mailbox set (graceful handling)
- [ ] Missing modData (graceful initialization)
- [ ] Invalid catalog edition (fallback)
- [ ] Mission with missing requirements (skip gracefully)

---

## 16. Debug Commands Reference

### Status Commands
```lua
AmazoidDebug.status()          -- Player status
AmazoidDebug.mailboxStatus()   -- Mailbox contents
AmazoidDebug.listMissions()    -- Active missions
AmazoidDebug.listOrders()      -- Pending orders
AmazoidDebug.listEditions()    -- All catalog editions
AmazoidDebug.showSeason()      -- Current season
AmazoidDebug.scanMailboxes()   -- Find nearby mailboxes
```

### Setup Commands
```lua
AmazoidDebug.test()            -- Full test setup
AmazoidDebug.setContractMailbox() -- Set nearest mailbox as contract
AmazoidDebug.firstContact()    -- Force first contact
AmazoidDebug.merchantVisit()   -- Trigger merchant visit
```

### Item Commands
```lua
AmazoidDebug.giveLetter()      -- Discovery letter
AmazoidDebug.giveContract()    -- Signed contract
AmazoidDebug.giveCatalog()     -- Basic catalog
AmazoidDebug.giveCatalogEdition("weapons_vol2")
AmazoidDebug.giveAllCatalogs()
AmazoidDebug.giveAllEditions("weapons")
```

### Mission Commands
```lua
AmazoidDebug.giveMission()           -- Collection mission
AmazoidDebug.giveEliminationMission() -- Elimination mission
AmazoidDebug.completeMissions()      -- Complete all missions
AmazoidDebug.clearMissions()         -- Clear all missions
```

### Reputation Commands
```lua
AmazoidDebug.setRep(50)        -- Set reputation
AmazoidDebug.giveRep(10)       -- Add reputation
```

### Reset Commands
```lua
AmazoidDebug.reset()           -- Reset all data
AmazoidDebug.newGame()         -- Simulate new game
AmazoidDebug.reload()          -- Reload Lua files
```

---

## 17. Known Issues / Not Yet Implemented

### Not Implemented
- [ ] Scavenger missions (find marked zombie)
- [ ] Timed delivery missions (deliver to another mailbox)
- [ ] Protection missions (protect noisy device from zombies)
- [ ] Multiplayer server synchronization

### Potential Issues to Watch
- [ ] Nested tables in modData may not serialize correctly
- [ ] Split-screen edge cases with multiple contract mailboxes
- [ ] Memory usage with many tracked kills

---

## Test Completion Sign-Off

| Section              | Tested By | Date | Pass/Fail |
| -------------------- | --------- | ---- | --------- |
| 1. Initial Discovery |           |      |           |
| 2. Context Menu      |           |      |           |
| 3. Catalog System    |           |      |           |
| 4. Order Processing  |           |      |           |
| 5. Mission System    |           |      |           |
| 6. Reputation System |           |      |           |
| 7. Merchant Visits   |           |      |           |
| 8. Triggered Letters |           |      |           |
| 9. Gift System       |           |      |           |
| 10. UI Panels        |           |      |           |
| 11. Split-Screen     |           |      |           |
| 12. Item Definitions |           |      |           |
| 13. Sandbox Options  |           |      |           |
| 14. Persistence      |           |      |           |
| 15. Error Handling   |           |      |           |

**Final Approval:** _______________  **Date:** _______________
