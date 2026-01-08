# Amazoid - Mysterious Mailbox Merchant
## Requirements Document

**Version:** 0.1.0  
**Last Updated:** January 8, 2026  
**Author:** setas  
**Game Version:** Project Zomboid Build 42+

---

## 1. Overview

### 1.1 Concept
Amazoid is a missions/store mod that introduces a mysterious merchant service operating through mailboxes. Players discover a strange letter offering goods and services, sign a contract, and can then order items from catalogs and complete missions to build reputation.

### 1.2 Core Theme
- Mystery and intrigue
- Survival economy
- Progressive discovery of lore
- Hidden merchants watching the player

---

## 2. Core Systems

### 2.1 Discovery System

| Requirement | Description | Priority |
|-------------|-------------|----------|
| REQ-DIS-001 | Discovery letters spawn randomly in mailboxes | High |
| REQ-DIS-002 | Letter spawn chance configurable in sandbox options | Medium |
| REQ-DIS-003 | Option to always spawn in starting house mailbox | Medium |
| REQ-DIS-004 | Option to spawn in all mailboxes | Low |
| REQ-DIS-005 | Player must find and read letter to begin | High |

### 2.2 Contract System

| Requirement | Description | Priority |
|-------------|-------------|----------|
| REQ-CON-001 | Player must sign contract to activate service | High |
| REQ-CON-002 | Contract binds service to specific mailbox | High |
| REQ-CON-003 | Only one active contract per player | High |
| REQ-CON-004 | Contract persists across save/load | High |
| REQ-CON-005 | Welcome letter sent after signing | Medium |

### 2.3 Catalog System

| Requirement | Description | Priority |
|-------------|-------------|----------|
| REQ-CAT-001 | Basic Catalog available at reputation 0 | High |
| REQ-CAT-002 | Tools Catalog unlocks at reputation 10 | High |
| REQ-CAT-003 | Weapons Catalog unlocks at reputation 25 | High |
| REQ-CAT-004 | Medical Catalog unlocks at reputation 25 | High |
| REQ-CAT-005 | Seasonal Catalog unlocks at reputation 35 | Medium |
| REQ-CAT-006 | Black Market Catalog unlocks at reputation 50 | High |
| REQ-CAT-007 | Seasonal catalog items change with game season | Medium |
| REQ-CAT-008 | All catalogs show item prices with discounts applied | High |
| REQ-CAT-009 | Items display size requirements (mailbox type needed) | High |

### 2.4 Ordering System

| Requirement | Description | Priority |
|-------------|-------------|----------|
| REQ-ORD-001 | Player can select items from available catalogs | High |
| REQ-ORD-002 | Player must place money in mailbox to pay | High |
| REQ-ORD-003 | Overpaying increases reputation | High |
| REQ-ORD-004 | Underpaying decreases reputation | High |
| REQ-ORD-005 | Orders have random delivery time (6-24 hours) | High |
| REQ-ORD-006 | Delivery time decreases with reputation | Medium |
| REQ-ORD-007 | Items appear in mailbox after delivery time | High |
| REQ-ORD-008 | Items must fit mailbox size constraints | High |
| REQ-ORD-009 | Order status persists across save/load | High |

### 2.5 Mailbox System

| Requirement | Description | Priority |
|-------------|-------------|----------|
| REQ-MBX-001 | Standard mailbox: small items only (weight ≤ 5) | High |
| REQ-MBX-002 | Large mailbox: medium items (weight ≤ 15) | High |
| REQ-MBX-003 | Delivery crate: large items (weight ≤ 50) | High |
| REQ-MBX-004 | Large mailbox can be found or crafted | Medium |
| REQ-MBX-005 | Delivery crate can be found or crafted | Medium |
| REQ-MBX-006 | Crafting recipes require appropriate skill levels | Medium |
| REQ-MBX-007 | Upgraded mailboxes can be placed by player | Medium |

### 2.6 Reputation System

| Requirement | Description | Priority |
|-------------|-------------|----------|
| REQ-REP-001 | Reputation ranges from -100 to +100 | High |
| REQ-REP-002 | Starting reputation is 0 | High |
| REQ-REP-003 | Completing missions adds +5 reputation | High |
| REQ-REP-004 | Failing missions removes -10 reputation | High |
| REQ-REP-005 | Overpaying adds +1 per dollar (max +5) | High |
| REQ-REP-006 | Underpaying removes -2 per dollar | High |
| REQ-REP-007 | Keeping scavenger hunt items removes -15 | High |
| REQ-REP-008 | Reputation unlocks catalogs (see 2.3) | High |
| REQ-REP-009 | Reputation provides discounts (up to 30%) | High |
| REQ-REP-010 | Milestone letters sent at thresholds | Medium |
| REQ-REP-011 | Negative reputation can suspend service | Low |

---

## 3. Mission System

### 3.1 Collection Missions

| Requirement | Description | Priority |
|-------------|-------------|----------|
| REQ-MIS-COL-001 | Request specific items to be left in mailbox | High |
| REQ-MIS-COL-002 | Items: canned goods, bandages, nails, planks, etc. | High |
| REQ-MIS-COL-003 | Quantity scales with reputation | Medium |
| REQ-MIS-COL-004 | Reward scales with difficulty | High |
| REQ-MIS-COL-005 | No time limit | High |

### 3.2 Elimination Missions

| Requirement | Description | Priority |
|-------------|-------------|----------|
| REQ-MIS-ELI-001 | Kill specified number of zombies | High |
| REQ-MIS-ELI-002 | Optional: require specific weapon type | High |
| REQ-MIS-ELI-003 | Kill count: 5-15 based on reputation | High |
| REQ-MIS-ELI-004 | Time limit: 48 game hours | High |
| REQ-MIS-ELI-005 | Track kills while mission active | High |
| REQ-MIS-ELI-006 | Weapon types: any, axe, bat, crowbar, pistol | Medium |

### 3.3 Scavenger Hunt Missions

| Requirement | Description | Priority |
|-------------|-------------|----------|
| REQ-MIS-SCA-001 | Mark a zombie with special outfit/appearance | High |
| REQ-MIS-SCA-002 | Zombie carries valuable item | High |
| REQ-MIS-SCA-003 | Player can return item for full reward | High |
| REQ-MIS-SCA-004 | Player can keep item with reputation penalty (-15) | High |
| REQ-MIS-SCA-005 | Time limit: 72 game hours | High |
| REQ-MIS-SCA-006 | Marked zombie spawns in nearby area | Medium |
| REQ-MIS-SCA-007 | Outfit types: red jacket, blue backpack, police, construction | Medium |

### 3.4 Timed Delivery Missions

| Requirement | Description | Priority |
|-------------|-------------|----------|
| REQ-MIS-TIM-001 | Package placed in player's mailbox | High |
| REQ-MIS-TIM-002 | Must deliver to another mailbox location | High |
| REQ-MIS-TIM-003 | Must complete before sunset | High |
| REQ-MIS-TIM-004 | Time limit: ~12 game hours | High |
| REQ-MIS-TIM-005 | Delivery location marked on map | Medium |
| REQ-MIS-TIM-006 | Higher reward than other missions | High |

### 3.5 Protection Missions

| Requirement | Description | Priority |
|-------------|-------------|----------|
| REQ-MIS-PRO-001 | Noisy device placed in mailbox | High |
| REQ-MIS-PRO-002 | Device attracts zombies | High |
| REQ-MIS-PRO-003 | Player must prevent device destruction | High |
| REQ-MIS-PRO-004 | Device has health that decreases when hit | High |
| REQ-MIS-PRO-005 | Protection duration: 30 minutes real-time | High |
| REQ-MIS-PRO-006 | Merchants "watching for entertainment" flavor | Medium |
| REQ-MIS-PRO-007 | Highest reward mission type | High |

---

## 4. Gift System

### 4.1 Trigger Conditions

| Requirement | Description | Priority |
|-------------|-------------|----------|
| REQ-GFT-001 | Track player healing actions | Medium |
| REQ-GFT-002 | Track player survival milestones (days) | Medium |
| REQ-GFT-003 | Track player kill streaks | Medium |
| REQ-GFT-004 | Track player cooking actions | Low |
| REQ-GFT-005 | Track player reading actions | Low |

### 4.2 Gift Delivery

| Requirement | Description | Priority |
|-------------|-------------|----------|
| REQ-GFT-010 | Gifts appear in mailbox with letter | High |
| REQ-GFT-011 | Healing trigger → bandage gift | Medium |
| REQ-GFT-012 | Survival milestone → supply gift | Medium |
| REQ-GFT-013 | Kill streak → weapon/ammo gift | Medium |
| REQ-GFT-014 | Gifts require minimum reputation | Medium |
| REQ-GFT-015 | Cooldown between gifts | Medium |

---

## 5. Lore System

### 5.1 Letter Progression

| Requirement | Description | Priority |
|-------------|-------------|----------|
| REQ-LOR-001 | Discovery letter introduces service | High |
| REQ-LOR-002 | Welcome letter after contract signing | High |
| REQ-LOR-003 | Milestone letters at reputation thresholds | Medium |
| REQ-LOR-004 | Lore letters reveal merchant backstory | Medium |
| REQ-LOR-005 | Final lore reveals merchant location | Medium |

### 5.2 Merchant Identity

| Requirement | Description | Priority |
|-------------|-------------|----------|
| REQ-LOR-010 | Merchants are Marcus & Julia (couple) | Medium |
| REQ-LOR-011 | They have 2 cats and 1 dog | Medium |
| REQ-LOR-012 | They discovered a way to be "invisible" to zombies | Medium |
| REQ-LOR-013 | They live in hidden cabin north of Muldraugh | Medium |
| REQ-LOR-014 | Location revealed at reputation 90+ | Medium |
| REQ-LOR-015 | Players can eventually meet them (end-game) | Low |

---

## 6. Technical Requirements

### 6.1 Save/Load

| Requirement | Description | Priority |
|-------------|-------------|----------|
| REQ-TEC-001 | Player data persists in ModData | High |
| REQ-TEC-002 | World data persists in global ModData | High |
| REQ-TEC-003 | Pending orders persist across sessions | High |
| REQ-TEC-004 | Active missions persist across sessions | High |
| REQ-TEC-005 | Reputation persists across sessions | High |
| REQ-TEC-006 | Discovered lore persists | High |

### 6.2 Multiplayer

| Requirement | Description | Priority |
|-------------|-------------|----------|
| REQ-TEC-010 | Support local split-screen | High |
| REQ-TEC-011 | Each player has separate reputation | High |
| REQ-TEC-012 | Each player has separate contract | High |
| REQ-TEC-013 | Online multiplayer deferred to future | Low |

### 6.3 Configuration

| Requirement | Description | Priority |
|-------------|-------------|----------|
| REQ-TEC-020 | Sandbox option: letter spawn chance | Medium |
| REQ-TEC-021 | Sandbox option: starting mailbox letter | Medium |
| REQ-TEC-022 | Sandbox option: price multiplier | Medium |
| REQ-TEC-023 | Sandbox option: delivery time multiplier | Medium |
| REQ-TEC-024 | Sandbox option: reputation gain multiplier | Low |
| REQ-TEC-025 | Sandbox option: enable/disable missions | Low |

---

## 7. User Interface

### 7.1 Mailbox Interaction

| Requirement | Description | Priority |
|-------------|-------------|----------|
| REQ-UI-001 | Context menu option "Check for Amazoid Mail" | High |
| REQ-UI-002 | Context menu option "View Catalogs" (after contract) | High |
| REQ-UI-003 | Context menu option "Place Order" | High |
| REQ-UI-004 | Context menu option "View Active Missions" | High |
| REQ-UI-005 | Context menu option "Check Order Status" | Medium |

### 7.2 Catalog Window

| Requirement | Description | Priority |
|-------------|-------------|----------|
| REQ-UI-010 | Display available catalog categories | High |
| REQ-UI-011 | Display items with names and prices | High |
| REQ-UI-012 | Show discount applied | High |
| REQ-UI-013 | Show mailbox size required | High |
| REQ-UI-014 | Allow item selection for order | High |
| REQ-UI-015 | Show order total | High |
| REQ-UI-016 | Locked catalogs shown grayed with requirement | Medium |

### 7.3 Mission Window

| Requirement | Description | Priority |
|-------------|-------------|----------|
| REQ-UI-020 | Display available missions | High |
| REQ-UI-021 | Display mission description and requirements | High |
| REQ-UI-022 | Display mission rewards | High |
| REQ-UI-023 | Display mission time remaining | High |
| REQ-UI-024 | Accept/decline mission buttons | High |
| REQ-UI-025 | Show current mission progress | High |

### 7.4 Letter Reading

| Requirement | Description | Priority |
|-------------|-------------|----------|
| REQ-UI-030 | Display letter in readable UI panel | High |
| REQ-UI-031 | Letter has styled/themed appearance | Medium |
| REQ-UI-032 | Contract signing checkbox for discovery letter | High |
| REQ-UI-033 | Close button | High |

---

## 8. Items & Scripts

### 8.1 Custom Items

| Requirement | Description | Priority |
|-------------|-------------|----------|
| REQ-ITM-001 | Amazoid Discovery Letter (readable item) | High |
| REQ-ITM-002 | Amazoid Catalog (readable item) | High |
| REQ-ITM-003 | Amazoid Contract (signed document) | High |
| REQ-ITM-004 | Mission Letters (various types) | High |
| REQ-ITM-005 | Delivery Package (for timed missions) | High |
| REQ-ITM-006 | Protection Device (noisy item) | High |
| REQ-ITM-007 | Large Mailbox (placeable) | Medium |
| REQ-ITM-008 | Delivery Crate (placeable) | Medium |

### 8.2 Crafting Recipes

| Requirement | Description | Priority |
|-------------|-------------|----------|
| REQ-ITM-010 | Large Mailbox recipe (Carpentry 4) | Medium |
| REQ-ITM-011 | Delivery Crate recipe (Carpentry 6) | Medium |

---

## 9. Future Considerations

### 9.1 Deferred Features (Post-Release)

| Feature | Description |
|---------|-------------|
| Online Multiplayer | Full multiplayer support with shared/separate economies |
| Merchant Meeting | Physical encounter with Marcus & Julia |
| Rush Orders | Pay extra for faster delivery |
| Mystery Box | Random item bundles at discount |
| Merchant's Rival | Competing merchant with different items/missions |
| Referral System | Give letters to NPCs/players |
| Subscription Tier | Pay weekly for premium benefits |

### 9.2 Content Expansion

| Feature | Description |
|---------|-------------|
| More Catalog Items | Vehicles, generators, rare books |
| More Mission Types | Sabotage, recon, crafting requests |
| More Lore | Extended backstory, more letters |
| Seasonal Events | Special holiday items and missions |
| Achievements | Track player accomplishments |

---

## 10. Testing Requirements

### 10.1 Functional Testing

| Test Case | Description |
|-----------|-------------|
| TST-001 | Letter spawns in mailboxes correctly |
| TST-002 | Contract signing activates service |
| TST-003 | Orders deduct money and deliver items |
| TST-004 | Reputation changes calculate correctly |
| TST-005 | Catalog unlocks at correct thresholds |
| TST-006 | All mission types complete correctly |
| TST-007 | Gifts trigger on player actions |
| TST-008 | Save/load preserves all data |
| TST-009 | Split-screen works with two players |

### 10.2 Edge Cases

| Test Case | Description |
|-----------|-------------|
| TST-020 | Order with insufficient payment |
| TST-021 | Mission timeout handling |
| TST-022 | Mailbox destroyed with pending order |
| TST-023 | Player death with active missions |
| TST-024 | Multiple orders at same time |
| TST-025 | Reputation at min/max limits |

---

## Appendix A: Reputation Thresholds

| Reputation | Unlock |
|------------|--------|
| 0 | Basic Catalog, Collection Missions |
| 10 | Tools Catalog, Elimination Missions |
| 20 | Scavenger Hunt Missions |
| 25 | Weapons Catalog, Medical Catalog |
| 30 | Timed Delivery Missions |
| 35 | Seasonal Catalog |
| 40 | Protection Missions |
| 50 | Black Market Catalog |
| 60 | Lore Letter 1 (Before the Fall) |
| 75 | Lore Letter 2 (The Secret) |
| 90 | Lore Letter 3 (Our Home - Location Reveal) |

## Appendix B: Price Examples

| Item | Base Price | At Rep 50 (15% discount) | At Rep 100 (30% discount) |
|------|------------|--------------------------|---------------------------|
| Canned Beans | $15 | $13 | $11 |
| Hammer | $45 | $38 | $32 |
| Axe | $120 | $102 | $84 |
| Pistol | $350 | $298 | $245 |
| Generator | $1000 | $850 | $700 |

## Appendix C: Mission Rewards

| Mission Type | Base Reward | Rep Bonus | Total Example (Rep 50) |
|--------------|-------------|-----------|------------------------|
| Collection | $50-100 | +$0.5/rep | $75-125 |
| Elimination | $75-150 | +$1/rep | $125-200 |
| Scavenger | $100-200 | +$2/rep | $200-300 |
| Timed Delivery | $150-250 | +$3/rep | $300-400 |
| Protection | $200-400 | +$4/rep | $400-600 |
