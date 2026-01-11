# Amazoid - Mysterious Mailbox Merchant

A Project Zomboid Build 42 mod featuring a mysterious merchant service that delivers items to your mailbox.

## Overview

Players discover a strange letter in a mailbox offering goods and services from mysterious merchants. Sign the contract, order items from catalogs, complete missions, and build reputation to unlock more catalogs, receive gifts, and uncover the merchants' backstory.

## Features

### Core Mechanics
- 📬 **Mailbox-based ordering system** - Your contracted mailbox becomes your delivery point
- 📚 **10 catalog categories** with volume progression
- ⭐ **Reputation system** (-100 to +100) with unlocks
- 📋 **Mission system** - Complete tasks for rewards
- 🎁 **Gift system** - Action-based and reputation-based gifts
- 📖 **7 lore letters** revealing the merchants' backstory
- 🎮 **Full split-screen co-op support**

### Getting Started

1. **Wait for the Merchant** - Within 1-3 days, a merchant visits a nearby mailbox
2. **Find the Letter** - Check mailboxes for the Discovery Letter
3. **Sign the Contract** - Read the letter and sign to activate service
4. **Your First Order** - Receive a free starter catalog and your first mission

### Catalogs

| Category         | Rep Required | Description                                 |
| ---------------- | ------------ | ------------------------------------------- |
| **Basic**        | 0            | Food, beverages, lighting, kitchen supplies |
| **Seasonal**     | 5            | Season-specific items (changes each season) |
| **Outdoor**      | 10           | Camping, fishing, hunting gear              |
| **Clothing**     | 15           | Everyday wear, protective gear              |
| **Tools**        | 20           | Hand tools, building materials, automotive  |
| **Literature**   | 25           | Skill books (Carpentry, First Aid, etc.)    |
| **Medical**      | 30           | Bandages, medicine, first aid kits          |
| **Electronics**  | 35           | Lighting, power, communication devices      |
| **Weapons**      | 40           | Melee weapons, ranged weapons, ammo         |
| **Black Market** | 60           | Firearms, military gear, heavy equipment    |

Each category has multiple volumes that unlock by spending money in that category.

### Reputation

**How to Gain:**
- Complete missions (+3)
- Order delivered (+1 per $10 spent)
- Receive gifts (+1)

**How to Lose:**
- Fail missions (-10)
- Underpay for orders (-2 per dollar short)
- Keep scavenger hunt items (-15)

**Warning:** Below 10 reputation, the merchant may steal your money if you underpay!

### Mission Types

| Type               | Status | Description                                      |
| ------------------ | ------ | ------------------------------------------------ |
| **Collection**     | ✅      | Bring specific items to your mailbox             |
| **Elimination**    | ✅      | Kill zombies (with optional weapon requirements) |
| **Scavenger Hunt** | 🔜      | Find marked zombies carrying valuable items      |
| **Timed Delivery** | 🔜      | Rush packages to other locations                 |
| **Protection**     | 🔜      | Defend a noisy device from zombie attacks        |

### Merchant Gifts

**Action-Based Gifts** (requires 10+ reputation):
- Heal wounds → Bandages
- Kill streaks (20 kills/hour) → Ammo or weapons
- Survive milestones (every 7 days) → Supplies
- Cook food → Cooking supplies
- Read skill books → Random book

**Reputation-Based Gifts** at thresholds: 8, 23, 33, 48, 65, 78, 92

### Lore & Story

Seven lore letters reveal the merchants' backstory as you build reputation:
- **Marcus & Julia** - A couple who survived the apocalypse
- **Mr. Whiskers & Sergeant Fluffington** - Their cats
- **Chaos** - Their loyal dog
- Their secret: They discovered how to become invisible to zombies
- At 85+ reputation, their hidden cabin location is revealed

## Installation

1. Subscribe on Steam Workshop, or
2. Place the `Amazoid` folder in your `Zomboid/Workshop/` directory
3. Enable the mod in the Project Zomboid mod manager

## Sandbox Options

| Option                   | Default | Description                       |
| ------------------------ | ------- | --------------------------------- |
| FirstContactDays         | 3       | Days until first merchant contact |
| PriceMultiplier          | 1.0     | Item price modifier               |
| DeliveryTimeMultiplier   | 1.0     | Delivery speed modifier           |
| MerchantVisitInterval    | 1       | Hours between merchant visits     |
| ReputationGainMultiplier | 1.0     | Positive rep change modifier      |
| ReputationLossMultiplier | 1.0     | Negative rep change modifier      |

## Development

This mod uses the Build 42 structure:
- `common/` - Shared assets (models, textures)
- `42/` - Version-specific code and mod.info
- See `Contents/mods/Amazoid/DOCUMENTATION.md` for full mechanics documentation
- See `Contents/mods/Amazoid/CONTEXT.md` for development context

## Version History

- **0.1.0** - Initial development version

## Credits

Created by setas

## License

This mod is free to use and modify for personal use.
