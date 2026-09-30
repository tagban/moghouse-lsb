-----------------------------------
-- func: home
-- desc: Sends the target to their homepoint.
-----------------------------------
require('modules/module_utils')
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 0,
    parameters = 's',
}

commandObj.onTrigger = function(player)
    player:warp()
end

xi.module.registerCommand('home', commandObj)
