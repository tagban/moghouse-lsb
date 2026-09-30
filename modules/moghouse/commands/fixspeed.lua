-----------------------------------
-- func: fixspeed
-- desc: Resets player movement speed.
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
    -- TODO(moghouse): the old player:speed(90) binding is gone. Speed is now forced with
    -- xi.mod.MOVE_SPEED_OVERRIDE (as the built-in !speed does); 0 clears the override, so the player
    -- returns to the server's regular speed (map.BASE_SPEED) instead of a literal 90. If a fixed 90
    -- is what was wanted, set the override to 90 here instead.
    player:setMod(xi.mod.MOVE_SPEED_OVERRIDE, 0)
    player:recalculateStats()
end

xi.module.registerCommand('fixspeed', commandObj)
