-----------------------------------
-- func: nopants
-- desc: PANTS OFF. expresses GM anger on cursor target
-----------------------------------
require('modules/module_utils')
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 2,
    parameters = '',
}

commandObj.onTrigger = function(player)
    local victim = player:getCursorTarget()

    if victim == nil then
        player:printToPlayer('Must target a player with cursor!')
        return
    end

    if victim:isPC() == false then
        player:printToPlayer('Must target a player with cursor!')
        return
    end

    victim:unequipItem(xi.slot.LEGS)
    victim:unequipItem(xi.slot.FEET)
    victim:printToPlayer('NO PANTS ARE THE BEST PANTS! - ODOYLE RULES!')
end

xi.module.registerCommand('nopants', commandObj)
