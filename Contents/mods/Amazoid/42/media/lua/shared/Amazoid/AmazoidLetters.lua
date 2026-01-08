--[[
    Amazoid - Mysterious Mailbox Merchant
    Letters and Lore
    
    This file contains all letter templates and lore content.
]]

require "Amazoid/AmazoidData"

Amazoid.Letters = Amazoid.Letters or {}

-- Discovery letter (first contact)
Amazoid.Letters.Discovery = {
    title = "A Curious Proposition",
    content = [[
Dear Survivor,

We've been watching you. Don't be alarmed - we mean no harm. Quite the opposite, actually.

In these dark times, survival is paramount. We understand that better than most. That's why we're reaching out with a... proposition.

We run a delivery service. Yes, you read that correctly. While the world crumbles, we thrive. We have connections, resources, and most importantly - we deliver.

Enclosed you'll find our basic catalog. Simply mark the items you desire, leave the appropriate payment in this mailbox, and we'll handle the rest. Delivery times vary, but we always deliver.

If you wish to use our services, sign the contract below and leave it in the mailbox. Consider it a... mutual agreement.

A few rules:
1. Payment is expected. Underpaying is... frowned upon.
2. Overpaying is appreciated and remembered.
3. Complete our occasional requests, and doors will open.
4. Betray our trust, and doors will close.

We look forward to a prosperous relationship.

Your Friends in the Shadows

P.S. - How are we still alive? Let's just say we've adapted. The dead don't bother us anymore.

---
[ ] I ACCEPT THE TERMS OF SERVICE
    Signature: ________________
]]
}

-- Welcome letter (after signing contract)
Amazoid.Letters.Welcome = {
    title = "Welcome to the Family",
    content = [[
Dear Valued Customer,

Excellent choice.

Your account has been activated. You now have access to our Basic Catalog. Browse at your leisure, and remember - we're always watching.

As you prove your worth, more catalogs will become available. Tools. Weapons. Medicine. And for our most trusted clients... the Black Market.

Your first order is on us. A small token of appreciation.

Check the mailbox.

Stay alive,
The Merchants

P.S. - Your reputation with us starts at zero. Every action matters. Every payment counts. Choose wisely.
]]
}

-- Reputation milestone letters
Amazoid.Letters.Milestones = {
    [10] = {
        title = "Tools of the Trade",
        content = [[
Dear Customer,

Your dedication has not gone unnoticed.

As a token of our appreciation, you now have access to the Tools Catalog. Hammers, saws, nails - everything a survivor needs to build and repair.

We've also started receiving... requests. Small jobs that need doing. Complete them, and your reputation will grow. Decline, and no hard feelings.

Check the mailbox for your first opportunity.

Building trust,
The Merchants
]]
    },
    [25] = {
        title = "Armed and Dangerous",
        content = [[
Dear Trusted Customer,

You've proven yourself reliable. That's rare these days.

We're opening two new catalogs for you:
- Weapons Catalog: Defend yourself properly.
- Medical Catalog: Stay alive long enough to spend money.

The jobs are getting more interesting too. Some require... a certain moral flexibility.

We trust you'll make the right choices.

With growing respect,
The Merchants

P.S. - We've included a small gift. Consider it an investment in your survival.
]]
    },
    [35] = {
        title = "Seasons Change",
        content = [[
Dear Loyal Customer,

The weather doesn't stop us. Neither should it stop you.

You now have access to our Seasonal Catalog. Items change with the seasons - stock up while you can.

By the way, we've noticed how you survive. Impressive. Those who adapt are the ones who live.

We're more alike than you might think.

Watching the seasons pass,
The Merchants
]]
    },
    [50] = {
        title = "Welcome to the Black Market",
        content = [[
Dear Elite Customer,

Congratulations. You've reached the inner circle.

The Black Market is now open to you. Firearms. Military equipment. Things that shouldn't exist in civilian hands.

But you're not a civilian anymore, are you?

These items are expensive. Rare. Powerful. Handle with care.

We're also trusting you with more... sensitive missions. The rewards match the risks.

One day, perhaps, we'll meet in person. Until then...

From the shadows,
The Merchants

P.S. - We have two cats and a dog. They like you already.
]]
    },
}

-- Mission letters
Amazoid.Letters.Missions = {
    Collection = {
        title = "A Simple Request",
        content = [[
Dear Customer,

We need supplies. You need money. Simple transaction.

Leave the following in the mailbox:
[ITEMS]

Payment upon delivery.

The Merchants
]]
    },
    Elimination = {
        title = "Pest Control",
        content = [[
Dear Customer,

The dead are getting too numerous near one of our routes.

We need [COUNT] zombies eliminated. Use [WEAPON] - we want to confirm kills.

Work fast. Time is money.

Reward: $[REWARD]

The Merchants
]]
    },
    Scavenger = {
        title = "Lost Property",
        content = [[
Dear Customer,

One of our couriers... didn't make it. They were carrying something valuable.

Look for a zombie wearing [DESCRIPTION]. They have what we need.

Return it to the mailbox. Or don't. But we'll know.

Reward: $[REWARD]
Keep it: [PENALTY] reputation

Your choice.

The Merchants
]]
    },
    TimedDelivery = {
        title = "URGENT - Time Sensitive",
        content = [[
Dear Customer,

No time for pleasantries.

Package in the mailbox. Needs to reach [LOCATION] before sunset.

Don't open it. Don't ask questions. Just deliver.

Reward: $[REWARD]
Failure: We'll be disappointed.

Move fast.

The Merchants
]]
    },
    Protection = {
        title = "Entertainment",
        content = [[
Dear Customer,

We've placed a device in your mailbox. It makes noise. A lot of noise.

Your job: Keep the zombies from destroying it. For [TIME].

Why? Let's just say we appreciate a good show.

We'll be watching.

Reward: $[REWARD]
Failure: The show must go on. Without you.

Good luck,
The Merchants

P.S. - Seriously though, this will be funny. For us.
]]
    },
}

-- Lore letters (discovered through missions or high reputation)
Amazoid.Letters.Lore = {
    {
        id = "lore_1",
        title = "Before the Fall",
        reputationRequired = 60,
        content = [[
Customer,

You've been with us long enough. Time you knew a bit more.

Before all this, we were nobody special. Just a couple trying to get by. Had two cats - Mr. Whiskers and Sergeant Fluffington. And a dog named Chaos. Named him that as a joke.

Joke's on us now, isn't it?

When the dead started walking, everyone ran. We stayed. Watched. Learned.

The dead don't see us anymore. We figured out why. Maybe we'll tell you someday.

- M & J
]]
    },
    {
        id = "lore_2",
        title = "The Secret",
        reputationRequired = 75,
        content = [[
Customer,

Still curious? Good.

The dead hunt by smell. Sound. Movement. But mostly smell. Living flesh has a signature they can't resist.

We don't have that signature anymore. Not completely.

It took time. Experimentation. A lot of close calls with Chaos almost giving us away.

We're not immune. Just... uninteresting to them. Like furniture.

This knowledge is valuable. More valuable than any gun.

Maybe, when you've proven yourself completely, we'll share more.

- M & J
]]
    },
    {
        id = "lore_3",
        title = "Our Home",
        reputationRequired = 90,
        content = [[
Customer,

Fine. You've earned this.

We live in the woods. North of Muldraugh, east of the river. There's an old cabin that doesn't show up on any map.

Not an invitation. A test.

If you find us, we'll talk. Really talk. Maybe even share our secret.

Bring food for the cats. And something squeaky for Chaos.

No guarantees you'll find us. The woods are dangerous, and we like our privacy.

But you've come this far.

- Marcus & Julia

P.S. - The cats are named after military ranks. Julia's idea of humor.
]]
    },
}

-- Gift letters
Amazoid.Letters.Gifts = {
    HealWound = {
        title = "We Noticed",
        content = [[
Customer,

We saw you patching yourself up. Those rags won't do.

Enclosed: A proper bandage.

Stay alive. You owe us money.

The Merchants
]]
    },
    SurviveDays = {
        title = "Still Breathing",
        content = [[
Customer,

[DAYS] days. Impressive.

Here's to many more.

[GIFT]

The Merchants
]]
    },
    KillStreak = {
        title = "Impressive Work",
        content = [[
Customer,

We watched you handle that horde. Brutal. Efficient.

Reminded us of ourselves.

Here's something to help with the next one.

[GIFT]

The Merchants
]]
    },
}

--- Get the discovery letter
---@return table Letter data
function Amazoid.Letters.getDiscoveryLetter()
    return Amazoid.Letters.Discovery
end

--- Get milestone letter if applicable
---@param newReputation number New reputation level
---@param oldReputation number Old reputation level
---@return table|nil Letter data or nil
function Amazoid.Letters.getMilestoneLetter(newReputation, oldReputation)
    for threshold, letter in pairs(Amazoid.Letters.Milestones) do
        if newReputation >= threshold and oldReputation < threshold then
            return letter
        end
    end
    return nil
end

--- Get lore letter if available
---@param reputation number Current reputation
---@param discoveredLore table Already discovered lore IDs
---@return table|nil Letter data or nil
function Amazoid.Letters.getNextLoreLetter(reputation, discoveredLore)
    for _, lore in ipairs(Amazoid.Letters.Lore) do
        if reputation >= lore.reputationRequired then
            local alreadyDiscovered = false
            for _, discovered in ipairs(discoveredLore) do
                if discovered == lore.id then
                    alreadyDiscovered = true
                    break
                end
            end
            if not alreadyDiscovered then
                return lore
            end
        end
    end
    return nil
end

print("[Amazoid] Letters module loaded")
