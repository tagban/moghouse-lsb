-----------------------------------
-- func: flash
-- desc: Max movement speed.
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
    -- player:speed(255) is gone; the speed override mod is the current way to force a speed.
    player:setMod(xi.mod.MOVE_SPEED_OVERRIDE, 255)
    player:recalculateStats()
    player:printToPlayer('Use !fixspeed to go back to normal', xi.msg.channel.NS_PARTY)
end

xi.module.registerCommand('flash', commandObj)
