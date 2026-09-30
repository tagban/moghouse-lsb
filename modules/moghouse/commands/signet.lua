-----------------------------------
-- func: signet
-- desc: Add signet and shit
-----------------------------------
require('modules/module_utils')
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = '',
}

commandObj.onTrigger = function(player)
    local nation   = player:getNation()
    local duration = (player:getRank(nation) + GetNationRank(nation) + 3) * 3600

    player:delStatusEffect(xi.effect.SIGIL)
    player:delStatusEffect(xi.effect.SANCTION)
    player:delStatusEffect(xi.effect.SIGNET)
    player:addStatusEffect(xi.effect.SIGNET, { duration = duration, origin = player }) -- Grant Signet

    player:printToPlayer('Signet granted for ' .. tostring(duration / 3600) .. ' hours.', xi.msg.channel.NS_PARTY)
end

xi.module.registerCommand('signet', commandObj)
