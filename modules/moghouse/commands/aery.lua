-----------------------------------
-- func: aery
-- desc: Teleports player to Fafnir/Nidhogg.
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
    player:setPos(63, 6, 24, 221, xi.zone.DRAGONS_AERY) -- zone 154
end

xi.module.registerCommand('aery', commandObj)
