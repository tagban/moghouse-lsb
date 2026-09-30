-----------------------------------
-- func: cerberus
-- desc: Teleports player to Cerberus.
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
    player:setPos(320, -23, -66, 61, xi.zone.MOUNT_ZHAYOLM) -- zone 61
end

xi.module.registerCommand('cerberus', commandObj)
