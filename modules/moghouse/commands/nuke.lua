-----------------------------------
-- func: nuke
-- desc: expresses GM anger on cursor target
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

    if os.time() - player:getCharVar('GM_LAST_NUKE') > 9 then
        player:setCharVar('GM_LAST_NUKE', os.time())
        -- Begin Wrath of the Gods Animation
        -- injectActionPacket: (target, category, animation, info, reaction, message, actionParam, param)
        victim:injectActionPacket(victim:getID(), 5, 207, 0, 0, 0, 10, 1)
        victim:injectActionPacket(victim:getID(), 5, 270, 0, 0, 0, 10, 1)
        -- End Wrath of the Gods Animation
        victim:printToPlayer('Some tyrant GM just nuked you. o_O; ')
    else
        player:printToPlayer('Too soon to zap again.')
    end
end

xi.module.registerCommand('nuke', commandObj)
