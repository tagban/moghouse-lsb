-----------------------------------
-- MogHouse's commands, run in LandSandBoat's xi_test (a map server with simulated players):
-- tools/test.sh runs these against a built image.
-----------------------------------

-- the commands and the GM level each needs (a change to either is meant, so it shows here)
local PERMISSIONS =
{
    apocnigh = 0, fixspeed = 0, grats = 0, home = 0, job = 0, kill = 0, shop = 0, starlight = 0,

    aery = 1, cerberus = 1, chocobo = 1, dominion = 1, down = 1, flash = 1, fly = 1, flymount = 1, gmgear = 1,
    gmisland = 1, kirin = 1, learnmagic = 1, mobmp = 1, seahorror = 1, signet = 1, skyfx = 1, slap = 1, up = 1,

    bringall = 2, jinx = 2, nopants = 2, nuke = 2,
}

local function spawnPair(zone)
    local gm = xi.test.world:spawnPlayer({ zone = zone, job = xi.job.WHM, level = 75 })
    gm:setGMLevel(5)
    local victim = xi.test.world:spawnPlayer({ zone = zone, job = xi.job.WAR, level = 75 })
    return gm, victim
end

-- the lowest level live mob in the victim's zone: a level 1-3 Sarutabaruta mob
local function weakestMob(player)
    local weakest
    for _, mob in pairs(player:getZone():getMobs()) do
        if mob:isSpawned() and mob:isAlive() and (weakest == nil or mob:getMainLvl() < weakest:getMainLvl()) then
            weakest = mob
        end
    end

    return weakest
end

-- the damage `mob` deals `victim` in `seconds` of fighting, the victim standing still at full HP
local function damageTaken(mob, victim, seconds)
    victim:setHP(victim:getMaxHP())
    mob:setPos(victim:getXPos() + 1, victim:getYPos(), victim:getZPos())
    mob:updateClaim(victim)
    mob:addEnmity(victim, 1, 1000)
    mob:updateTarget()

    local lost = 0
    for _ = 1, seconds do
        local before = victim:getHP()
        xi.test.world:skipTime(1)
        xi.test.world:tickEntity(mob)
        lost = lost + math.max(0, before - victim:getHP())
        victim:setHP(victim:getMaxHP())
    end

    return lost
end

describe('MogHouse commands', function()
    it('are all registered, at their GM levels', function()
        for name, level in pairs(PERMISSIONS) do
            local command = xi.commands[name]
            assert(command ~= nil, string.format('!%s is not registered', name))
            assert(command.cmdprops.permission == level,
                string.format('!%s needs GM level %d, expected %d', name, command.cmdprops.permission, level))
        end
    end)

    describe('!jinx defense', function()
        local gm
        local victim

        before_each(function()
            gm, victim = spawnPair(xi.zone.WEST_SARUTABARUTA)
        end)

        it('takes defense to nothing and multiplies damage taken by 5', function()
            xi.commands.jinx.onTrigger(gm, victim:getName(), 'defense')

            victim.assert:hasModifier(xi.mod.DEFP, -100)
            victim.assert:hasModifier(xi.mod.UDMGPHYS, 30000) -- x4
            victim.assert:hasModifier(xi.mod.DMGPHYS, 2500)   -- x1.25: x5 in all
        end)

        it('never wraps its 16-bit mods, however often it is cast', function()
            for _ = 1, 10 do
                xi.commands.jinx.onTrigger(gm, victim:getName(), 'defense', 16)
            end

            victim.assert:hasModifier(xi.mod.DEFP, -100)
            victim.assert:hasModifier(xi.mod.UDMGPHYS, 30000)
            victim.assert:hasModifier(xi.mod.DMGPHYS, 30000)
            assert(victim:getMod(xi.mod.EVA) >= -9999, 'evasion wrapped')
        end)

        it('lets a level 2 mob hurt a level 75 warrior', function()
            local mob = weakestMob(victim)
            assert(mob ~= nil, 'no live mob in the zone')

            local before = damageTaken(mob, victim, 60)
            xi.commands.jinx.onTrigger(gm, victim:getName(), 'defense')
            local after = damageTaken(mob, victim, 60)

            print(string.format('%s (level %d), 60 seconds on a WAR75: %d damage, jinxed %d',
                mob:getName(), mob:getMainLvl(), before, after))
            assert(after >= 50, string.format('jinxed, only %d damage in a minute', after))
            assert(after > before * 3, string.format('jinxed %d, not much above %d', after, before))
        end)

        it('bounces off a GM of a higher level onto the caster', function()
            victim:setGMLevel(6)
            xi.commands.jinx.onTrigger(gm, victim:getName(), 'defense')

            victim.assert:hasModifier(xi.mod.DEFP, 0)
            gm.assert:hasModifier(xi.mod.DEFP, -100)
        end)
    end)

    describe('!jinx agro', function()
        it('sets every live mob in the zone on the victim', function()
            local gm, victim = spawnPair(xi.zone.EAST_SARUTABARUTA)

            local alive = {}
            for _, mob in pairs(victim:getZone():getMobs()) do
                if mob:isSpawned() and mob:isAlive() then
                    table.insert(alive, mob)
                end
            end

            assert(#alive > 10, string.format('only %d live mobs to test with', #alive))

            xi.commands.jinx.onTrigger(gm, victim:getName(), 'agro')
            xi.test.world:tick()

            local onVictim = 0
            for _, mob in ipairs(alive) do
                local target = mob:getTarget()
                if mob:isEngaged() and target ~= nil and target:getID() == victim:getID() then
                    onVictim = onVictim + 1
                end
            end

            print(string.format('%d of %d live mobs on the victim', onVictim, #alive))
            assert(onVictim == #alive, string.format('only %d of %d mobs came for the victim', onVictim, #alive))
            assert(gm:getZone():getID() == victim:getZone():getID())
        end)

        it('only those within range when a range is given', function()
            local gm, victim = spawnPair(xi.zone.NORTH_GUSTABERG)

            xi.commands.jinx.onTrigger(gm, victim:getName(), 'agro', 30)
            xi.test.world:tick()

            for _, mob in pairs(victim:getZone():getMobs()) do
                if mob:isSpawned() and mob:isAlive() and mob:checkDistance(victim) > 40 then
                    local target = mob:getTarget()
                    assert(target == nil or target:getID() ~= victim:getID(),
                        string.format('%s, %d yalms away, came anyway', mob:getName(), mob:checkDistance(victim)))
                end
            end
        end)
    end)

    -- LandSandBoat builds C++ modules into xi_map only, not xi_test, so mogKnockback (knockback.cpp) is
    -- not here: a stand-in records the call. The packet itself is seen in game.
    describe('!slap', function()
        it('knocks the victim back as hard as it goes, with the slap animation, and hurts', function()
            local gm, victim = spawnPair(xi.zone.SOUTH_GUSTABERG)
            gm:setPos(victim:getXPos() + 2, victim:getYPos(), victim:getZPos())
            victim:setHP(victim:getMaxHP())

            local calls = {}
            local real = rawget(_G, 'mogKnockback')
            rawset(_G, 'mogKnockback', function(actor, targetId, knockback, animation)
                table.insert(calls, { actor = actor:getID(), target = targetId, knockback = knockback, animation = animation })
            end)

            local ok, err = pcall(xi.commands.slap.onTrigger, gm, victim:getName(), 5)
            rawset(_G, 'mogKnockback', real)
            assert(ok, err)

            assert(#calls == 1, string.format('mogKnockback called %d times', #calls))
            assert(calls[1].actor == gm:getID(), 'the slap came from someone else')
            assert(calls[1].target == victim:getID(), 'the slap hit someone else')
            assert(calls[1].knockback == 7, 'not the strongest knockback')
            assert(calls[1].animation == 899, 'not the slap animation')
            assert(victim:getHP() == victim:getMaxHP() - 5, 'the 5 damage was not dealt')
        end)

        it('does nothing to a player out of reach', function()
            local gm, victim = spawnPair(xi.zone.SOUTH_GUSTABERG)
            gm:setPos(victim:getXPos() + 100, victim:getYPos(), victim:getZPos())

            local called = false
            local real = rawget(_G, 'mogKnockback')
            rawset(_G, 'mogKnockback', function()
                called = true
            end)

            local ok, err = pcall(xi.commands.slap.onTrigger, gm, victim:getName(), 5)
            rawset(_G, 'mogKnockback', real)
            assert(ok, err)
            assert(not called, 'slapped from 100 yalms away')
        end)
    end)
end)
