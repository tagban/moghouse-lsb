-----------------------------------
-- func: kill
-- desc: A trap for players trying GM commands: kills whoever types it and takes 20000 exp
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
    player:delExp(20000) -- Kiss some exp goodbye moron!

    -- Begin Wrath of the Gods Animation
    -- injectActionPacket: (target, category, animation, info, reaction, message, actionParam, param)
    player:injectActionPacket(player:getID(), 5, 271, 0, 0, 0, 10, 1)
    player:injectActionPacket(player:getID(), 5, 202, 0, 0, 0, 10, 1)
    player:injectActionPacket(player:getID(), 5, 207, 0, 0, 0, 10, 1)
    player:injectActionPacket(player:getID(), 5, 216, 0, 0, 0, 10, 1)
    player:injectActionPacket(player:getID(), 5, 270, 0, 0, 0, 10, 1)
    -- End Wrath of the Gods Animation

    player:setHP(0) -- DIE!
end

xi.module.registerCommand('kill', commandObj)
