-----------------------------------
-- func: jinx <victim> <type> <power>
-- desc: Does mean things to annoying player.
-- If player re-logs zones or job changes, jinx will be removed.
-- DO NOT TELL PLAYER THIS.
-- DO NOT TELL PLAYER WHAT THIS COMMAND DOES.
-- DO NOT EVEN TELL PLAYER THIS COMMAND EXISTS.
-- Default type of jinx used is "Agro Magnet" :)
-- Power and Duration are only for status effect type jinxing.
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

-- Old mod names and their current equivalents:
--   MOD_STEALTH        -> xi.mod.STEALTH
--   MOD_CRITHITRATE    -> xi.mod.CRITHITRATE
--   MOD_ENEMYCRITRATE  -> xi.mod.CRITICAL_HIT_EVASION (the sign is reversed: a negative value now raises the enemy's crit rate)
--   MOD_MOVE (% speed) -> xi.mod.MOVE_SPEED_WEIGHT_PENALTY (multiplicative % slow, positive = slower)
--   MOD_SPELLINTERRUPT -> xi.mod.SPELLINTERRUPT (positive = less interruption, so negative raises it, as before)
-- TODO(moghouse): nothing in current LandSandBoat reads xi.mod.STEALTH, so the "agro" jinx (and the agro part of "all")
-- has no effect; there is no mod that widens a player's aggro range.

commandObj.onTrigger = function(player, victim, jinx, power)
    if victim == nil then
        player:printToPlayer('Must specify a victim!')
        player:printToPlayer('!jinx <victim> <agro crit speed interrupt>')
        player:printToPlayer('If player re-logs zones or job changes, jinx will be removed.')
        player:printToPlayer('DO NOT TELL PLAYER THIS.')
        player:printToPlayer('DO NOT TELL PLAYER WHAT THIS COMMAND DOES.')
        player:printToPlayer('DO NOT EVEN TELL PLAYER THIS COMMAND EXISTS.')
    else
        local targ = GetPlayerByName(victim)
        if targ ~= nil then
            if targ:getGMLevel() > player:getGMLevel() then
                player:printToPlayer('You can\'t jinx a GM of a higher Tier than yourself.')
                player:printToPlayer(string.format('Everything you throw at %s bounces off and sticks to you..', victim))
                targ = player
            end

            if jinx == nil then
                jinx = 'agro'
            end

            if jinx == 'all' then
                if power == nil or power == 0 then
                    power = 10
                elseif power > 80 then
                    power = 80
                end

                targ:addMod(xi.mod.STEALTH, -power)
                player:printToPlayer(string.format('Victim \'%s\' now has increased agro range.', victim))
                targ:addMod(xi.mod.CRITICAL_HIT_EVASION, -power)
                targ:addMod(xi.mod.CRITHITRATE, -power)
                player:printToPlayer(string.format('Victim \'%s\' now receive more critical hits.', victim))
                player:printToPlayer(string.format('Victim \'%s\' now delivers fewer critical hits.', victim))
                targ:addMod(xi.mod.MOVE_SPEED_WEIGHT_PENALTY, power)
                player:printToPlayer(string.format('Victim \'%s\' now has decreased movement speed.', victim))
                targ:addMod(xi.mod.SPELLINTERRUPT, -power)
                player:printToPlayer(string.format('Victim \'%s\' now has increased spell interuption chance.', victim))
            elseif jinx == 'agro' then
                if power == nil or power == 0 then
                    power = 10
                elseif power > 50 then
                    power = 50
                end

                targ:addMod(xi.mod.STEALTH, -power)
                player:printToPlayer(string.format('Victim \'%s\' now has increased agro range.', victim))
            elseif jinx == 'crit' then
                if power == nil or power == 0 then
                    power = 10
                elseif power > 80 then
                    power = 80
                end

                targ:addMod(xi.mod.CRITICAL_HIT_EVASION, -power)
                targ:addMod(xi.mod.CRITHITRATE, -power)
                player:printToPlayer(string.format('Victim \'%s\' now receive more critical hits.', victim))
                player:printToPlayer(string.format('Victim \'%s\' now delivers fewer critical hits.', victim))
            elseif jinx == 'speed' then
                if power == nil or power == 0 then
                    power = 10
                elseif power > 50 then
                    power = 50
                end

                targ:addMod(xi.mod.MOVE_SPEED_WEIGHT_PENALTY, power)
                player:printToPlayer(string.format('Victim \'%s\' now has decreased movement speed.', victim))
            elseif jinx == 'interrupt' then
                if power == nil or power == 0 then
                    power = 25
                elseif power > 80 then
                    power = 80
                end

                targ:addMod(xi.mod.SPELLINTERRUPT, -power)
                player:printToPlayer(string.format('Victim \'%s\' now has increased spell interruption chance.', victim))
            else
                player:printToPlayer('!jinx <victim> <agro crit speed interrupt>')
                player:printToPlayer('If player re-logs zones or job changes, jinx will be removed.')
                player:printToPlayer('DO NOT TELL PLAYER THIS.')
                player:printToPlayer('DO NOT TELL PLAYER WHAT THIS COMMAND DOES.')
                player:printToPlayer('DO NOT EVEN TELL PLAYER THIS COMMAND EXISTS.')
            end
        else
            player:printToPlayer(string.format('Victim named \'%s\' not found!', victim))
            player:printToPlayer('!jinx <victim> <type>')
        end
    end
end

xi.module.registerCommand('jinx', commandObj)
