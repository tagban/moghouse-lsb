-----------------------------------
-- func: up <optional number> <optional target>
-- desc: Alters vertical coordinate
-----------------------------------
require('modules/module_utils')
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 'is',
}

commandObj.onTrigger = function(player, number, target)
    local value = 0

    -- if target == nil then
    --     target = player:getName()
    -- end

    local targ = player
    -- if targ == nil then
    --     player:printToPlayer(string.format('Player named "%s" not found!', target))
    --     return
    -- end

    if number ~= nil and number > 0 then
        value = targ:getYPos() - number
    else
        value = targ:getYPos() - 5
    end

    targ:setPos(targ:getXPos(), value, targ:getZPos(), targ:getRotPos())
end

xi.module.registerCommand('up', commandObj)
