-----------------------------------
-- func: slap
-- desc: Slaps the target player.
-- copy: (c) 2016 atom0s [For use on LegionDark only!]
-----------------------------------
require('modules/module_utils')
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 'si',
}

commandObj.onTrigger = function(player, target, damage)
    -- Sanity checks..
    local isHidden = player:getCharVar('GMHidden')
    if isHidden ~= 0 then
        player:printToPlayer('Slap does not work while GM hidden!')
        return
    end

    -- Obtain the player target to knockback..
    local t = GetPlayerByName(target)
    if t == nil then
        player:printToPlayer('Invalid target; could not find that player.')
        return
    end

    -- Must be in the same zone..
    if player:getZoneID() ~= t:getZoneID() then
        player:printToPlayer('You must be in the same zone as the target player.')
        return
    end

    -- Must be in range of the target..
    if player:checkDistance(t) > 48 then
        player:printToPlayer('You must be within target range of the person you want to slap!')
        return
    end

    -- Prepare the parameters..
    local dmg = damage or 0

    -- Knockback the target: the strongest (7), with the original's animation (899), through the
    -- knockback module (modules/moghouse/cpp/knockback.cpp)
    mogKnockback(player, t:getID(), 7, 899)

    -- Damage the target..
    if dmg > 0 then
        t:addHP(-dmg)
    end

    local m = string.format('Slapped %s for %d damage.', t:getName(), dmg)
    player:printToPlayer(m)
end

xi.module.registerCommand('slap', commandObj)
