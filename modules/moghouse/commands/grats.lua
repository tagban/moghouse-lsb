-----------------------------------
-- func: grats
-- desc: triggers the congratulation animation normally seen on fireworks
-----------------------------------
require('modules/module_utils')
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 0,
    parameters = '',
}

commandObj.onTrigger = function(player)
    -- injectActionPacket now takes the target first and the action ID/param last:
    -- (target, category, animation, info, reaction, message, actionParam, param); the last two as the built-in !injectaction.
    player:injectActionPacket(player:getID(), 5, 107, 0, 0, 0, 10, 1)
end

xi.module.registerCommand('grats', commandObj)
