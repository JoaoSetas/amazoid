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
    content = [[Dear Survivor,

We've been watching you. Don't be alarmed.

In these dark times, survival is paramount. That's why we're reaching out with a proposition.

We run a delivery service. While the world crumbles, we thrive. We have connections, resources, and we deliver - right to your mailbox.

How it works:
1. Sign the contract below to activate service at THIS mailbox.
2. Browse our catalogs and leave payment in the mailbox.
3. Check back later - your items will be waiting.
4. Complete our requests and earn reputation for better catalogs.

This mailbox will be your connection to us. All deliveries, payments, and communications happen here. Choose wisely - once you sign, this is YOUR mailbox.

Interested? Sign the contract and check the mailbox again soon.

Your Friends in the Shadows

P.S. - The dead don't bother us anymore.
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

-- Reputation milestone letters (sent when player reaches reputation thresholds)
-- New thresholds: 13, 18, 38, 60, 70, 80, 90, 100
Amazoid.Letters.Milestones = {
    [13] = {
        title = "Growing Trust",
        content = [[
Dear Customer,

Your dedication has not gone unnoticed.

Thirteen points of trust. It's a start, and a promising one.

We've been watching you handle our packages with care. The items arrive, the payments clear. It's refreshing.

Most customers don't last this long. They get careless. Greedy. Dead.

You're different. We like different.

Keep it up, and doors will open.

Building trust,
The Merchants
]]
    },
    [18] = {
        title = "A Steady Customer",
        content = [[
Dear Customer,

Eighteen points now. You're climbing steadily.

We've started telling the cats about you. Mr. Whiskers is skeptical, but Sergeant Fluffington seems curious.

The dog just wants to meet everyone. He's not the best judge of character.

You've got outdoor gear and clothing options now. Keep building trust - tools and literature are just around the corner.

Watching with interest,
The Merchants

P.S. - The dog likes to bark at the mailbox when your orders come in. We think he's rooting for you.
]]
    },
    [38] = {
        title = "Valued Partner",
        content = [[
Dear Valued Customer,

Thirty-eight reputation points. You're proving yourself.

By now you've got access to quite a selection - medical supplies, electronics, literature. Everything a survivor needs to thrive, not just survive.

The missions you'll see now are getting more interesting. Some require... a certain moral flexibility.

We trust you'll make the right choices.

Almost family,
The Merchants
]]
    },
    [60] = {
        title = "The Inner Circle",
        content = [[
Dear Friend,

Yes, friend. You've earned that.

Sixty points of trust. Do you know how rare that is? Most people never get past thirty. They betray us. Or they die.

You've done neither.

We're starting to share things with you now. Stories. Hints. Maybe soon, secrets.

The missions you'll see now... they're not for everyone. But we think you can handle them.

With genuine respect,
Marcus & Julia

P.S. - We used our real names. That's trust.
]]
    },
    [70] = {
        title = "One of Us",
        content = [[
Dear Friend,

Seventy. We're running out of ways to say "impressive."

You've been through more than most. Killed more. Survived longer. Spent more money.

We joke, but the money matters less now. You're an investment. A partner.

If things go wrong out there, you know where to send word. We look after our own.

The cats send their regards. The dog is still excited about everything.

Family now,
M & J
]]
    },
    [80] = {
        title = "Trust Complete",
        content = [[
Dear Partner,

Eighty points. We never thought we'd see it.

In another life, we might have been friends from the start. Shared dinners. Game nights. Normal things.

This world took that from all of us. But it gave us something else.

Purpose.

We help people like you. You help us stay hidden. It works.

When you hit one hundred, we'll share everything. The secret. The location. All of it.

Almost there,
Marcus & Julia
]]
    },
    [90] = {
        title = "The Final Stretch",
        content = [[
Dear True Friend,

Ninety reputation. Ten more to go.

We've told you about the smell. About how we hide. But there's more.

It's not just hiding. It's... understanding. The dead aren't mindless. Not completely. They remember things. Patterns. Feelings.

We learned to feel like them. Think like them. Move like them.

It sounds horrifying. It is. But it keeps us alive.

Ten more points, and we'll show you how.

Almost ready,
M & J

P.S. - Sergeant Fluffington caught a mouse today. He's very proud.
]]
    },
    [100] = {
        title = "Welcome Home",
        content = [[
Dear Family,

One hundred. You did it.

There's nothing more we can unlock for you. No more catalogs. No more tiers. You've seen everything we have to offer.

But there's one more thing.

Come find us. North of Muldraugh, east of the river. Look for the cabin that isn't on any map. We'll be waiting.

Bring food. Bring stories. Bring yourself.

The cats will pretend they don't care. The dog will lose his mind with joy. We'll make tea.

And we'll tell you everything. How we survive. How you can too.

This isn't goodbye. It's hello.

See you soon,
Marcus & Julia

P.S. - We're proud of you. Genuinely. Whatever happens next, you made it.
]]
    },
}

-- Lore letters (discovered through missions or high reputation)
-- These reveal the merchants' backstory gradually
-- Thresholds: 3, 28, 43, 48, 58, 72, 85 (avoid milestone/gift collisions)
Amazoid.Letters.Lore = {
    {
        id = "lore_origins",
        title = "How It Started",
        reputationRequired = 3,
        content = [[
Customer,

You seem curious about us. We like that.

Before the outbreak, we ran a small antique shop. Nothing fancy. Old books, furniture, the occasional mysterious artifact.

People thought we were eccentric. They weren't wrong.

When things fell apart, we didn't panic. We had supplies. We had knowledge. And we had each other.

The shop is gone now. But the business continues.

- The Merchants
]]
    },
    {
        id = "lore_pets",
        title = "The Companions",
        reputationRequired = 28,
        content = [[
Customer,

You've probably noticed we mention our pets a lot.

Mr. Whiskers was already old when the world ended. He's ancient now. Moves slow, judges fast. Doesn't trust anyone.

Sergeant Fluffington is younger. Orange. Very loud about his opinions. Got the name from a joke that stopped being funny years ago.

Chaos... Chaos is a good dog. Big. Dumb. Loyal. He's saved our lives more times than we can count.

They're family. The only family we have left.

Well, them and customers like you.

- M & J
]]
    },
    {
        id = "lore_discovery",
        title = "The Discovery",
        reputationRequired = 43,
        content = [[
Customer,

We should tell you how we figured it out.

Three months into the outbreak, Marcus got bit. Not badly, but enough. We thought it was over.

It wasn't.

The wound healed. The fever passed. He didn't turn.

We spent months trying to understand why. What was different. What made him survive when everyone else died.

The answer changed everything.

More soon. You're earning our trust.

- Julia
]]
    },
    {
        id = "lore_experiments",
        title = "Trial and Error",
        reputationRequired = 48,
        content = [[
Customer,

After Marcus survived the bite, we started testing things.

What attracted the dead? What repelled them? Could we predict their movements?

Turns out, yes. They're creatures of habit. Memory. They go to places that felt important when they were alive.

And smell. Always smell. They hunt by it. Fear it. Follow it.

Marcus stopped smelling right to them after the bite. Like he was part of their world now, but still thinking.

We started working on making me the same way.

It took a while.

- Julia
]]
    },
    {
        id = "lore_method",
        title = "Before the Fall",
        reputationRequired = 58,
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
        id = "lore_secret",
        title = "The Secret",
        reputationRequired = 72,
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
        id = "lore_home",
        title = "Our Home",
        reputationRequired = 85,
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

-- Gift letters (sent with surprise gifts based on reputation and actions)
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

--- Get milestone letter if player crossed a reputation threshold
---@param newReputation number New reputation level
---@param oldReputation number Old reputation level
---@return table|nil Letter data or nil if no milestone crossed
function Amazoid.Letters.getMilestoneLetter(newReputation, oldReputation)
    for threshold, letter in pairs(Amazoid.Letters.Milestones) do
        if newReputation >= threshold and oldReputation < threshold then
            return letter
        end
    end
    return nil
end

--- Get next undiscovered lore letter if player has enough reputation
---@param reputation number Current reputation
---@param discoveredLore table Already discovered lore IDs
---@return table|nil Letter data or nil if none available
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

-- Triggered Letters (based on player milestones)
Amazoid.Letters.Triggered = {
    -- Kill milestones
    kills_10 = {
        id = "kills_10",
        title = "First Blood (Times Ten)",
        content = [[
Dear Customer,

We've been watching. Ten of the dead, put back to rest.

Not bad for a survivor. Most don't make it past five.

A little tip: we sometimes need help with "pest control." Keep those skills sharp, and we might have work for you. The elimination missions pay well.

Keep swinging,
The Merchants

P.S. - We recommend washing your clothes. The smell lingers.
]]
    },
    kills_50 = {
        id = "kills_50",
        title = "Fifty Down",
        content = [[
Dear Customer,

Fifty. That's a small horde you've handled.

We're impressed. Our couriers have been safer lately, and we suspect you're the reason.

Keep building trust with us. The higher your reputation, the better the equipment we can offer. Some of our premium options are worth the wait.

The dead fear you,
The Merchants

P.S. - We counted. One of them was wearing a chef's hat. Seemed wrong somehow.
]]
    },
    kills_100 = {
        id = "kills_100",
        title = "The Centurion",
        content = [[
Dear Customer,

One hundred kills. A centurion of the apocalypse.

We've seen many survivors come and go. Most become statistics. You? You're becoming a legend.

At this rate, you might actually live long enough to see our Black Market. Trust us - it's worth the wait. Military hardware. Night vision. Things the government doesn't want civilians to have.

Not that there's a government anymore.

With genuine respect,
The Merchants

P.S. - Our dog wants to meet you. The cats are more cautious.
]]
    },
    -- Days survived milestones
    days_7 = {
        id = "days_7",
        title = "One Week Strong",
        content = [[
Dear Customer,

Seven days. You've survived longer than most.

The first week is the hardest, they say. Finding food, shelter, learning that the world has ended. You've adapted.

Have you checked our catalogs lately? As your reputation grows, new options become available. Keep doing business with us and doors will open.

Here's to many more weeks,
The Merchants

P.S. - We remember our first week. It involved a lot of hiding in closets.
]]
    },
    days_14 = {
        id = "days_14",
        title = "Two Weeks In",
        content = [[
Dear Customer,

Two weeks of survival. You're not just lucky - you're skilled.

We've noticed you settling in. Building. Preparing. Good instincts.

A word of advice: summer won't last forever, and winter in Kentucky is... challenging. Check our seasonal options if you've unlocked them. Plan ahead.

Stay warm (for now),
The Merchants

P.S. - We've started a betting pool on how long you'll last. Frankly, you're making us rich.
]]
    },
    days_30 = {
        id = "days_30",
        title = "The Month Survivor",
        content = [[
Dear Customer,

Thirty days. A full month in this new world.

You've outlived 99% of the population. Congratulations. Or condolences. We're never sure which is appropriate.

If you've been building your reputation with us, you might have access to medical supplies by now. Antibiotics, proper bandages... the things that keep survivors surviving.

We're genuinely rooting for you.

Your friends in commerce,
The Merchants

P.S. - We celebrated your monthiversary. The dog got extra treats in your honor.
]]
    },
    -- Funny clothing comments
    clown_outfit = {
        id = "clown_outfit",
        title = "Fashion Statement",
        content = [[
Dear Customer,

We don't usually comment on customer attire, but...

The clown outfit. Really?

We respect your choices. Personal expression is important, especially in the apocalypse. But perhaps consider that zombies are attracted to movement and noise. Bright colors and floppy shoes might not be optimal.

Then again, maybe you're using psychological warfare. If so, it's working. One of our couriers saw you and nearly drove off the road laughing.

Honk honk,
The Merchants

P.S. - We enclosed nothing. The outfit IS the gift. To us.
]]
    },
    spiffo_costume = {
        id = "spiffo_costume",
        title = "Our Favorite Customer",
        content = [[
Dear Customer,

SPIFFO!

We love Spiffo. Everyone loves Spiffo. Before everything went wrong, we used to eat at Spiffo's every Tuesday.

Seeing you in that costume brought a tear to our eye. Not since the old days...

Keep wearing it. You're keeping the dream alive.

Your biggest fans,
The Merchants

P.S. - "You can't out-pizza the Spiffo." We miss that slogan.
]]
    },
    santa_outfit = {
        id = "santa_outfit",
        title = "Ho Ho... Oh.",
        content = [[
Dear Customer,

Is it Christmas already? We've lost track of dates.

The Santa outfit is... festive. In a post-apocalyptic sort of way.

We suppose the children need hope, wherever they are. Not that there are many children left. This got dark quickly.

Merry... something,
The Merchants

P.S. - If you find any reindeer, let us know. We have questions.
]]
    },
    prisoner_outfit = {
        id = "prisoner_outfit",
        title = "A Fresh Start",
        content = [[
Dear Customer,

Orange is the new... survival?

We don't judge. Whatever you did before, it doesn't matter now. The world has bigger problems than whatever put you in those stripes.

Besides, some of our best customers were "reformed" individuals. Great work ethic. Very motivated.

No questions asked,
The Merchants

P.S. - If you robbed a Spiffo's, we WILL judge. Some things are unforgivable.
]]
    },
    military_outfit = {
        id = "military_outfit",
        title = "Thank You For Your Service",
        content = [[
Dear Customer,

We see you've got military gear. Fitting in with the local... scenery.

Word of advice: be careful. The military presence didn't end well for most soldiers. Their zombified colleagues are everywhere, and they might have friends who shoot first.

On the bright side, you look very tactical. Very intimidating.

Stay frosty,
The Merchants

P.S. - When you hit Black Market reputation, we have some gear that'll make you feel right at home.
]]
    },
    bathrobe = {
        id = "bathrobe",
        title = "Casual Friday",
        content = [[
Dear Customer,

We admire your confidence.

Fighting zombies in a bathrobe takes a special kind of person. The kind who wakes up, looks at the apocalypse, and says "I'm comfortable."

We're not here to criticize. If anything, we're inspired. Maybe we'll start wearing pajamas too.

Cozy and deadly,
The Merchants

P.S. - Slippers next? We won't tell anyone.
]]
    },
}

--- Get triggered letter if milestone was just reached
---@param triggerId string The trigger ID (e.g., "kills_10", "days_7", "clown_outfit")
---@return table|nil Letter data or nil
function Amazoid.Letters.getTriggeredLetter(triggerId)
    return Amazoid.Letters.Triggered[triggerId]
end

print("[Amazoid] Letters module loaded")
