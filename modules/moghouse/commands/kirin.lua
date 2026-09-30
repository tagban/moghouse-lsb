-----------------------------------
-- func: kirin
-- desc: Teleports player to Kirin.
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
    player:setPos(-76, 32, -4, -4, xi.zone.THE_SHRINE_OF_RUAVITAU) -- zone 178; rotation -4 wraps to 252
end

xi.module.registerCommand('kirin', commandObj)
