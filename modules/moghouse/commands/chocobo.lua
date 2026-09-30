-----------------------------------
-- func: chocobo
-- desc: Spawns a chocobo.
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

local function error(player, msg)
    player:printToPlayer(msg)
end

commandObj.onTrigger = function(player)
    if player:isEngaged() then
        error(player, '!chocobo cannot be used while in combat or under attack! Run away!')
    else
        player:setAnimation(xi.animation.CHOCOBO)
    end
end

xi.module.registerCommand('chocobo', commandObj)
