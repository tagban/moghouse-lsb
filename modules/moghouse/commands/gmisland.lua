-----------------------------------
-- func: gmisland
-- desc: Sets the players position to secret island... muahahaha
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
    player:setPos(0, 0, 443, 59, xi.zone.JUGNER_FOREST) -- zone 104
end

xi.module.registerCommand('gmisland', commandObj)
