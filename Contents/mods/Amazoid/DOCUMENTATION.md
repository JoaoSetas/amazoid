# Amazoid Mod - Complete Game Mechanics Documentation

> **The Mysterious Mailbox Merchant**
> A Project Zomboid Build 42 mod featuring a mysterious merchant service that delivers items to your mailbox.

---

## Table of Contents

1. [Overview](#overview)
2. [Getting Started](#getting-started)
3. [Reputation System](#reputation-system)
4. [Catalog System](#catalog-system)
5. [Mission System](#mission-system)
6. [Gift System](#gift-system)
7. [Letter System](#letter-system)
8. [Merchant Visit Mechanics](#merchant-visit-mechanics)
9. [Order System](#order-system)
10. [Event System (For Developers)](#event-system)
11. [Sandbox Options](#sandbox-options)
12. [Split-Screen Support](#split-screen-support)

---

## Overview

Amazoid introduces a mysterious merchant duo (Marcus & Julia) who run a delivery service during the zombie apocalypse. Players can order items from catalogs, complete missions for rewards, and build reputation to unlock better catalogs and receive gifts.

**Key Features:**
- 📬 Mailbox-based ordering system
- 📚 Multiple catalog categories with volume progression
- ⭐ Reputation system with unlocks
- 📋 Collection and elimination missions
- 🎁 Action-based and reputation-based gift system
- 📖 Rich lore revealing the merchants' backstory
- 🎮 Full split-screen co-op support

---

## Getting Started

### First Contact

1. **Wait for the Merchant** - Within the first 1-3 days (configurable), the merchant will visit a nearby mailbox when you're not looking
2. **Find the Letter** - Check nearby mailboxes for the **Discovery Letter**
3. **Read and Sign** - Right-click the letter, read it, and sign the contract
4. **Your First Order** - You'll receive a free starter catalog (Basic Vol. I) and your first mission

### The Mailbox

Once you sign the contract, that mailbox becomes YOUR mailbox. All deliveries, catalogs, missions, and communications happen there.

---

## Reputation System

Reputation ranges from **-100** to **100**, starting at **0**.

### How to Gain Reputation

| Action                          | Rep Change |
| ------------------------------- | ---------- |
| Complete mission                | +3         |
| Order delivered (per $10 spent) | +1         |
| Receive a gift                  | +1         |

### How to Lose Reputation

| Action                    | Rep Change          |
| ------------------------- | ------------------- |
| Fail mission              | -10                 |
| Underpay for order        | -2 per dollar short |
| Keep scavenger hunt items | -15                 |

### Reputation Effects

| Rep Level | Effect                                             |
| --------- | -------------------------------------------------- |
| Below 10  | Merchant may STEAL your money if you underpay      |
| 0-9       | Basic catalogs only                                |
| 5+        | Seasonal catalog unlocks                           |
| 10+       | Outdoor catalog unlocks                            |
| 15+       | Clothing catalog unlocks                           |
| 20+       | Tools catalog unlocks                              |
| 25+       | Literature catalog unlocks                         |
| 30+       | Medical catalog unlocks                            |
| 35+       | Electronics catalog unlocks                        |
| 40+       | Weapons catalog unlocks                            |
| 60+       | **Black Market** unlocks (firearms, military gear) |

### Complete Unlock Schedule

| Rep | What Unlocks                                              |
| --- | --------------------------------------------------------- |
| 0   | Basic Catalog                                             |
| 3   | Lore: "How It Started"                                    |
| 5   | **Seasonal Catalog**                                      |
| 8   | **Gift**: Bandages + Pills                                |
| 10  | **Outdoor Catalog**                                       |
| 13  | Milestone Letter                                          |
| 15  | **Clothing Catalog**                                      |
| 18  | Milestone Letter                                          |
| 20  | **Tools Catalog**                                         |
| 23  | **Gift**: Axe + Ripped Sheets                             |
| 25  | **Literature Catalog**                                    |
| 28  | Lore: "The Companions"                                    |
| 30  | **Medical Catalog**                                       |
| 33  | **Gift**: Hunting Knife + Bandages                        |
| 35  | **Electronics Catalog**                                   |
| 38  | Milestone Letter                                          |
| 40  | **Weapons Catalog**                                       |
| 43  | Lore: "The Discovery"                                     |
| 48  | Lore: "Trial and Error", **Gift**: Pistol + 9mm Ammo Box  |
| 58  | Lore: "Before the Fall"                                   |
| 60  | **Black Market Catalog**, Milestone Letter                |
| 65  | **Gift**: Katana                                          |
| 70  | Milestone Letter                                          |
| 72  | Lore: "The Secret"                                        |
| 78  | **Gift**: Assault Rifle + 2× 5.56 Ammo                    |
| 80  | Milestone Letter                                          |
| 85  | Lore: "Our Home" (reveals location)                       |
| 90  | Milestone Letter                                          |
| 92  | **Gift**: Sledgehammer + Kevlar Helmet + Bulletproof Vest |
| 100 | Final Milestone: "Welcome Home" (invitation to visit)     |

---

## Catalog System

### Catalog Categories

| Category         | Rep Required | Description                                       |
| ---------------- | ------------ | ------------------------------------------------- |
| **Basic**        | 0            | Food, beverages, lighting, kitchen supplies       |
| **Seasonal**     | 5            | Season-specific items (changes each season)       |
| **Outdoor**      | 10           | Camping, fishing, hunting gear                    |
| **Clothing**     | 15           | Everyday wear, protective gear                    |
| **Tools**        | 20           | Hand tools, building materials, automotive        |
| **Literature**   | 25           | Skill books (Carpentry, First Aid, Cooking, etc.) |
| **Medical**      | 30           | Bandages, medicine, first aid kits                |
| **Electronics**  | 35           | Lighting, power, communication devices            |
| **Weapons**      | 40           | Melee weapons, ranged weapons, ammo               |
| **Black Market** | 60           | Firearms, military gear, heavy equipment          |

### Volume Progression

Each category has multiple volumes (Vol. I, Vol. II, etc.):

**How Volumes Unlock:**
1. **Vol. I** - Unlocked when you reach the category's reputation requirement
2. **Vol. II+** - Unlocked by spending money in that category
3. **Threshold** - You must spend the cumulative value of all items in previous volumes

**Example:**
- Basic Vol. I items total ~$500 in value
- Spend $500+ on Basic items → Basic Vol. II unlocks
- Vol. II items total ~$800 → Spend $1300 total → Basic Vol. III unlocks

### Catalog Volumes Detail

**Basic (5 volumes):**
- Vol. I: Pantry Basics - Canned goods, beverages, lighting
- Vol. II: Survival Staples - Preserved foods, spirits, power
- Vol. III: Kitchen & Cleaning - Cookware, cleaning supplies
- Vol. IV: Comfort Foods - Snacks, sweets, breakfast items
- Vol. V: Home Goods - Paper products, containers, household

**Tools (4 volumes):**
- Vol. I: Essential Tools - Hammers, saws, screwdrivers
- Vol. II: Advanced Equipment - Mechanical, electrical, gardening
- Vol. III: Automotive - Car parts, mechanics tools
- Vol. IV: Crafting Supplies - Adhesives, materials, sewing

**Weapons (4 volumes):**
- Vol. I: Melee Combat - Blunt, bladed, improvised
- Vol. II: Ranged & Ammo - Attachments, ammunition, protection
- Vol. III: Heavy Hitters - Two-handed weapons, axes, polearms
- Vol. IV: Gunsmith Special - Handguns, revolvers, scopes (requires Rep 40)

**Medical (4 volumes):**
- Vol. I: Emergency Care - Basic bandages, disinfectant
- Vol. II: Advanced Medicine - Antibiotics, painkillers
- Vol. III: Field Medic - Suture kits, splints
- Vol. IV: Pharmacy - Full pharmaceutical selection (requires Rep 35)

**Seasonal (4 editions - automatic):**
- Spring: Gardening tools, seeds, rain gear
- Summer: Sun protection, cooling items, outdoor gear
- Autumn: Warm clothing, harvest tools, preserving supplies
- Winter: Cold weather gear, heating, hot drinks

**Black Market (2 volumes):**
- Vol. I: Firearms, exotic weapons, bulk ammunition
- Vol. II: Heavy weapons, military gear, power equipment

### Seasonal Catalogs

- Automatically given at the **start of each season**
- Only requires base seasonal unlock (Rep 35)
- Each season has unique items appropriate for that time of year
- Higher volumes unlock through spending, like other categories

### Daily Limit

You can only receive **one new catalog per day** maximum.

---

## Mission System

### Mission Types

#### Collection Missions
Bring specific items to your mailbox. The merchant collects them on the next visit.

**Tier 1 (Rep 0-9):**
- Items: Ripped Sheets (5), Nails (15), Sheet Ropes (2)
- Reward: $10-18

**Tier 2 (Rep 10-24):**
- Items: Planks (8), Twine (3), Wooden Mallet
- Reward: $18-28

**Tier 3 (Rep 25-34):**
- Items: Electronics Scrap (3), Metal Pipes (2), Skill Books
- Reward: $40-60

**Tier 4 (Rep 35-59):**
- Items: Gravel Bags (3), Welding Rods (2), Propane Tank
- Reward: $70-100

**Tier 5 (Rep 60+):**
- Items: Sheet Metal (3), Metal Drum, Generator Magazine
- Reward: $120-160

#### Elimination Missions
Kill a specified number of zombies, sometimes with specific weapon requirements.

| Tier | Rep   | Kill Count | Weapon           | Reward  | Time Limit      |
| ---- | ----- | ---------- | ---------------- | ------- | --------------- |
| 1    | 0-9   | 5-8        | Any/Melee        | $8-12   | None            |
| 2    | 10-24 | 10-15      | Any/Melee        | $15-25  | Optional 24h    |
| 3    | 25-34 | 12-20      | Any/Axe          | $25-40  | Optional 12-24h |
| 4    | 35-59 | 15-25      | Crowbar/Katana   | $40-60  | Optional 18h    |
| 5    | 60+   | 20-50      | Any/Sledgehammer | $50-100 | Optional 12-48h |

### Mission Rules

- **Daily Limit**: One mission spawned per day maximum
- **Active Limit**: No new mission if you have an active mission
- **Spawn Chance**: 70% per merchant visit (after first mission)
- **Type Distribution**: 60% collection, 40% elimination
- **Tier Selection**: 60% chance for highest available tier, 40% for random lower tier

### First Mission

Your first mission is always simple:
- Collect: Canned Beans (2), Apples (3), or Nails (5)
- Reward: $12-20

### Reward Formula

```
Final Reward = Base Reward × (1 + Reputation/100)
```

At 50 reputation, rewards are 50% higher than base!

---

## Gift System

### Action-Based Gifts

Triggered by player actions. Requires **minimum 10 reputation**.

| Trigger      | Threshold              | Gift                          | Cooldown        |
| ------------ | ---------------------- | ----------------------------- | --------------- |
| Heal wounds  | 5 healing actions      | Bandage or Sterilized Bandage | 24 hours        |
| Kill streak  | 20 kills within 1 hour | 9mm Ammo or Baseball Bat      | 24 hours        |
| Survive days | Every 7 days           | Canned Beans, Soup, Bandage   | Milestone-based |
| Cook food    | 10 cooking actions     | Pan or Pot                    | 24 hours        |
| Read books   | 3 skill books          | Random book                   | 24 hours        |

### Reputation-Based Gifts

Triggered when reaching specific reputation thresholds. Given once only.

| Rep | Gift Name            | Items                                           |
| --- | -------------------- | ----------------------------------------------- |
| 18  | First Appreciation   | 2× Bandage + Pills                              |
| 32  | Growing Trust        | Axe + 3× Ripped Sheets                          |
| 52  | Inner Circle Welcome | Pistol + 9mm Ammo Box                           |
| 65  | Family Privilege     | **Katana**                                      |
| 78  | Trusted Ally         | Assault Rifle + 2× 5.56 Boxes                   |
| 92  | Ultimate Trust       | Sledgehammer + Kevlar Helmet + Bulletproof Vest |

### Gift Packaging

Gifts come wrapped in appropriately-sized packages:
- **Small Package** (≤5 weight): Bandages, pills, ammo
- **Medium Package** (≤15 weight): Axes, smaller weapons
- **Large Package** (>15 weight): Heavy weapons, armor sets

---

## Letter System

### Letter Types

| Type                       | When You Receive It                                                          |
| -------------------------- | ---------------------------------------------------------------------------- |
| **Discovery Letter**       | First contact with any unclaimed mailbox                                     |
| **Welcome Letter**         | After signing the contract                                                   |
| **Milestone Letter**       | Reaching reputation thresholds (10, 20, 25, 35, 40, 50, 60, 70, 80, 90, 100) |
| **Lore Letter**            | Reaching lore thresholds (15, 28, 38, 48, 58, 72, 85)                        |
| **Gift Letter**            | Accompanying action-based gifts                                              |
| **Reputation Gift Letter** | Accompanying reputation-based gifts                                          |
| **Mission Letter**         | New mission available                                                        |
| **Completion Letter**      | Mission completed successfully                                               |
| **Order Confirmation**     | Order accepted and processing                                                |
| **Payment Needed**         | Not enough money for order                                                   |
| **Theft Notice**           | Money stolen (low reputation)                                                |

### Lore Letters (Story Content)

The lore letters gradually reveal the merchants' backstory:

1. **"How It Started"** (Rep 15) - They ran an antique shop before the outbreak
2. **"The Companions"** (Rep 28) - Meet Mr. Whiskers, Sergeant Fluffington (cats), and Chaos (dog)
3. **"The Discovery"** (Rep 38) - Marcus was bitten but didn't turn
4. **"Trial and Error"** (Rep 48) - Their experiments understanding the dead
5. **"Before the Fall"** (Rep 58) - More about their past
6. **"The Secret"** (Rep 72) - How they became invisible to zombies
7. **"Our Home"** (Rep 85) - Location revealed: North of Muldraugh, east of the river

### Triggered Letters (Achievement-Based)

**Kill Milestones:**
- 10 kills: "First Blood (Times Ten)"
- 50 kills: "Fifty Down"
- 100 kills: "The Centurion"

**Survival Milestones:**
- 7 days: "One Week Strong"
- 14 days: "Two Weeks In"
- 30 days: "The Month Survivor"

**Funny Outfit Letters:**
- Clown costume: "Fashion Statement"
- Spiffo costume: "Our Favorite Customer"
- Santa outfit: "Ho Ho... Oh."

---

## Merchant Visit Mechanics

### First Contact

**Timing:** Within 1-3 days of game start (configurable)

**Conditions for visit:**
- Player is 15-100 tiles away from a mailbox

**What happens:**
1. Discovery letter appears in mailbox
2. Starter catalog (Basic Vol. I) delivered
3. First mission letter included
4. Sound effect plays
5. Character says something like "I think I heard someone at the mailbox..."

### Regular Visits

**Frequency:** Every 1 hour (configurable)

**Conditions:** No player has the mailbox container open

**Visit Actions (in order):**
1. Check for new catalog unlocks (reputation-based)
2. Check for volume unlocks (spending-based)
3. Check for seasonal catalog (if season changed)
4. Process catalog orders (collect money, schedule delivery)
5. Deliver pending orders that are ready
6. Process completed missions (collect items, give rewards)
7. Spawn daily mission (if eligible)
8. Check for triggered letters (kill milestones, clothing, etc.)

### Player Notification

When the merchant visits, a random nearby player will say one of:
- "I think I heard someone at the mailbox..."
- "Was that the mailbox?"
- "Sounds like something was delivered..."
- "I heard something outside..."

---

## Order System

### How to Order

1. **Browse Catalog** - Right-click a catalog and select "Browse"
2. **Circle Items** - Click items to mark them for order
3. **Place Order** - Put catalog + money in the mailbox
4. **Wait** - Merchant collects on next visit and schedules delivery
5. **Receive** - Items arrive in packages after delivery time

### Payment Rules

| Situation                  | What Happens                                |
| -------------------------- | ------------------------------------------- |
| **First Order**            | FREE! No payment required                   |
| **Exact Payment**          | Order accepted, confirmation letter sent    |
| **Overpayment**            | Change returned with order                  |
| **Underpayment (Rep ≥10)** | Polite letter requesting more money         |
| **Underpayment (Rep <10)** | Merchant **STEALS ALL MONEY**, angry letter |

### Delivery Time

Base delivery time varies by:
- **Reputation** - Higher rep = faster delivery
- **Item count** - More items = slightly longer
- **Rush order** - 2× price for 0.5× time

### Package Sizes

| Total Weight | Package Type   |
| ------------ | -------------- |
| ≤5           | Small Package  |
| ≤15          | Medium Package |
| ≤30          | Large Package  |
| >30          | Delivery Crate |

If packages don't fit in the mailbox, they're placed on nearby ground.

---

## Event System

> **For Modders and Developers**

Amazoid provides a centralized event system for decoupled communication between modules.

### Subscribing to Events

```lua
Amazoid.Events.on("ReputationChanged", function(data)
    print("Reputation: " .. data.oldRep .. " -> " .. data.newRep)
    print("Reason: " .. data.reason)
end, 100) -- priority (higher = called first)
```

### Available Events

| Event               | Data Payload                                                           |
| ------------------- | ---------------------------------------------------------------------- |
| `ReputationChanged` | `{oldRep, newRep, amount, reason}`                                     |
| `MoneySpent`        | `{amount, categories, totalSpent, totalSpentByCategory, isFirstOrder}` |
| `OrderPlaced`       | `{order, mailbox}`                                                     |
| `OrderDelivered`    | `{order, mailbox}`                                                     |
| `MissionAccepted`   | `{mission}`                                                            |
| `MissionCompleted`  | `{mission, rewards}`                                                   |
| `MissionFailed`     | `{mission, reason}`                                                    |
| `ContractSigned`    | `{mailboxLocation}`                                                    |
| `FirstContact`      | `{mailbox}`                                                            |
| `CatalogUnlocked`   | `{category, volume}`                                                   |
| `VolumeUnlocked`    | `{category, volume}`                                                   |
| `GiftSent`          | `{triggerType, items, mailbox}`                                        |

### API Reference

```lua
-- Subscribe to event (returns nothing)
Amazoid.Events.on(eventName, callback, priority)

-- Unsubscribe from event
Amazoid.Events.off(eventName, callback)

-- Fire an event
Amazoid.Events.fire(eventName, data)

-- Clear all listeners for an event
Amazoid.Events.clear(eventName)

-- Get listener count
Amazoid.Events.getListenerCount(eventName)
```

---

## Sandbox Options

Configure these in sandbox settings when creating a world:

| Option                   | Default | Range   | Description                       |
| ------------------------ | ------- | ------- | --------------------------------- |
| FirstContactDays         | 3       | 1-30    | Days until first merchant contact |
| PriceMultiplier          | 1.0     | 0.1-5.0 | Item price modifier               |
| DeliveryTimeMultiplier   | 1.0     | 0.1-5.0 | Delivery speed modifier           |
| MerchantVisitInterval    | 1       | 1-24    | Hours between merchant visits     |
| ReputationGainMultiplier | 1.0     | 0.1-5.0 | Positive rep change modifier      |
| ReputationLossMultiplier | 1.0     | 0.1-5.0 | Negative rep change modifier      |

---

## Split-Screen Support

Amazoid fully supports local split-screen co-op:

- **First Contact** - Checks visibility for ALL local players before visiting
- **Merchant Visits** - Notifies all nearby players with voice lines
- **Mission Tracking** - Kill tracking works for all local players
- **Triggered Letters** - Checks clothing for any local player
- **Mailbox Access** - Any local player can access the contracted mailbox

---

## Tips for New Players

1. **Sign the contract early** - The sooner you start, the sooner you build reputation
2. **Complete missions** - +3 reputation each, and they're usually easy
3. **First order is free** - Use it to test the system!
4. **Don't underpay at low rep** - Below 10 rep, the merchant will steal your money
5. **Check for seasonal catalogs** - They appear automatically each season
6. **Spend in categories you want** - Spending unlocks higher volume catalogs
7. **Kill zombies for bonuses** - You might trigger kill streak gifts
8. **Read the lore** - It's a fun story about Marcus, Julia, and their pets!

---

## The Merchants

**Marcus & Julia** are a couple who survived the apocalypse through a combination of luck, knowledge, and a strange immunity Marcus developed after being bitten. They live in a hidden cabin north of Muldraugh with their pets:

- **Mr. Whiskers** - An ancient, judgmental cat
- **Sergeant Fluffington** - A loud orange cat with a military-joke name
- **Chaos** - A big, dumb, loyal dog who has saved their lives many times

They run the mailbox delivery service as a way to help survivors like you... and maybe find others who might understand their secret.

---

*"The dead don't see us anymore. We figured out why. Maybe we'll tell you someday."*
— The Merchants
