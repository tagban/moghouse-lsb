-----------------------------------
-- func: bringall
-- desc: Brings the users full alliance to them.
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
    local p = player:getAlliance()
    if p ~= nil then
        for _, member in pairs(p) do
            if member:isPC() and member:getID() ~= player:getID() then
                member:setPos(player:getXPos(), player:getYPos(), player:getZPos(), 0, player:getZoneID())
            end
        end
    end
end

xi.module.registerCommand('bringall', commandObj)
