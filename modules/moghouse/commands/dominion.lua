-----------------------------------
-- func: dominion
-- desc: Teleports player to Behemoth/King Behemoth.
-----------------------------------
require('modules/module_utils')
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 'iiii',
}

commandObj.onTrigger = function(player)
    player:setPos(-282, -19, 68, 241, xi.zone.BEHEMOTHS_DOMINION) -- zone 127
end

xi.module.registerCommand('dominion', commandObj)
