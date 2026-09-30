-----------------------------------
-- func: jinx <victim> <type> <power>
-- desc: Does mean things to annoying player.
-- A jinx lasts until the player zones, relogs or changes job (the train until the mobs are dead or
-- lose them).
-- DO NOT TELL PLAYER THIS.
-- DO NOT TELL PLAYER WHAT THIS COMMAND DOES.
-- DO NOT EVEN TELL PLAYER THIS COMMAND EXISTS.
-- Types:
--   agro (default)  every live mob in the victim's zone claims them and comes for them (power: only
--                   mobs within that many yalms; 0 or none, the whole zone)
--   defense         defense down to 1, evasion gone, and physical damage taken multiplied by power
--                   (default 5, at most 20): a level 2 Rarab hurts
--   crit            crits land on them more, and theirs less (power: %, default 10, at most 80)
--   speed           slower (power: %, default 10, at most 50)
--   interrupt       spells interrupted more (power: %, default 25, at most 80)
--   all             every one of the above (power for the crit/speed/interrupt part)
-----------------------------------
require('modules/module_utils')
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 2,
    parameters = 'ssi',
}

local function usage(player)
    player:printToPlayer('!jinx <victim> <agro defense crit speed interrupt all> [power]')
    player:printToPlayer('Lasts until the victim zones, relogs or changes job.')
    player:printToPlayer('DO NOT TELL PLAYER THIS.')
    player:printToPlayer('DO NOT TELL PLAYER WHAT THIS COMMAND DOES.')
    player:printToPlayer('DO NOT EVEN TELL PLAYER THIS COMMAND EXISTS.')
end

local function clamp(power, default, most)
    if power == nil or power <= 0 then
        return default
    end

    return math.min(power, most)
end

-- every live mob in the victim's zone (or within `range` yalms of them) claims them and comes for them
local function train(targ, range)
    local zone = targ:getZone()
    if zone == nil then
        return 0
    end

    local count = 0
    for _, mob in pairs(zone:getMobs()) do
        if
            mob:isSpawned() and
            mob:isAlive() and
            (range == nil or range <= 0 or mob:checkDistance(targ) <= range)
        then
            mob:updateClaim(targ)
            mob:addEnmity(targ, 1, 1000)
            mob:updateTarget()
            count = count + 1
        end
    end

    return count
end

local function defense(targ, power)
    local times = clamp(power, 5, 20)
    targ:addMod(xi.mod.DEFP, -100)                    -- defense to 1 (it cannot go lower)
    targ:addMod(xi.mod.EVA, -999)                     -- every swing lands
    targ:addMod(xi.mod.UDMGPHYS, (times - 1) * 10000) -- physical damage taken x times (uncapped)
    return times
end

local function crit(targ, power)
    local p = clamp(power, 10, 80)
    targ:addMod(xi.mod.CRITICAL_HIT_EVASION, -p) -- negative: the enemy crits more
    targ:addMod(xi.mod.CRITHITRATE, -p)
    return p
end

local function speed(targ, power)
    local p = clamp(power, 10, 50)
    targ:addMod(xi.mod.MOVE_SPEED_WEIGHT_PENALTY, p) -- a multiplicative slow, positive is slower
    return p
end

local function interrupt(targ, power)
    local p = clamp(power, 25, 80)
    targ:addMod(xi.mod.SPELLINTERRUPT, -p) -- positive is less interruption
    return p
end

local KNOWN = { agro = true, defense = true, crit = true, speed = true, interrupt = true, all = true }

commandObj.onTrigger = function(player, victim, jinx, power)
    if victim == nil then
        player:printToPlayer('Must specify a victim!')
        usage(player)
        return
    end

    local targ = GetPlayerByName(victim)
    if targ == nil then
        player:printToPlayer(string.format('Victim named \'%s\' not found!', victim))
        return
    end

    if targ:getGMLevel() > player:getGMLevel() then
        player:printToPlayer('You can\'t jinx a GM of a higher Tier than yourself.')
        player:printToPlayer(string.format('Everything you throw at %s bounces off and sticks to you..', victim))
        targ = player
    end

    jinx = jinx or 'agro'
    if not KNOWN[jinx] then
        usage(player)
        return
    end

    local name = targ:getName()

    if jinx == 'agro' or jinx == 'all' then
        local count = train(targ, jinx == 'agro' and power or nil)
        player:printToPlayer(string.format('%d mobs in %s\'s zone now want %s.', count, name, name))
    end

    if jinx == 'defense' or jinx == 'all' then
        local times = defense(targ, jinx == 'defense' and power or nil)
        player:printToPlayer(string.format('%s now has 1 defense, no evasion, and takes %dx physical damage.', name, times))
    end

    if jinx == 'crit' or jinx == 'all' then
        crit(targ, power)
        player:printToPlayer(string.format('%s now receives more critical hits, and delivers fewer.', name))
    end

    if jinx == 'speed' or jinx == 'all' then
        speed(targ, power)
        player:printToPlayer(string.format('%s now moves slower.', name))
    end

    if jinx == 'interrupt' or jinx == 'all' then
        interrupt(targ, power)
        player:printToPlayer(string.format('%s now has their spells interrupted more.', name))
    end
end

xi.module.registerCommand('jinx', commandObj)
