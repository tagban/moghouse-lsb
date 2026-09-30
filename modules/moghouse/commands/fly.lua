-----------------------------------
-- func: fly
-- desc: FLY Like an EAGLE... TO THE SEA. Tagban loves you.
-----------------------------------
require('modules/module_utils')
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 's',
}

-- Speed is now forced with the MOVE_SPEED_OVERRIDE mod (player:speed() is gone), as the built-in !speed does.
local function setSpeed(player, speed)
    player:setMod(xi.mod.MOVE_SPEED_OVERRIDE, speed)
    player:recalculateStats()
end

commandObj.onTrigger = function(player, target)
    -- The old name flag 0x200 was the wallhack flag, now its own getter/setter.
    if player:getWallhack() then
        player:setWallhack(false)
        -- TODO(moghouse): the old code set a literal speed of 90 here ("speed normal"); 0 clears the
        -- override so the player returns to the server's regular speed (map.BASE_SPEED) instead.
        setSpeed(player, 0)
        player:setCostume(0)
        player:printToPlayer('Fly turned off, wallhack off, speed normal, Costume off!.')
    else
        player:setWallhack(true)
        player:printToPlayer('FLYYYYYY LIKE AN EAGLE!!.')
        player:setPos(player:getXPos(), -45, player:getZPos(), player:getRotPos())
        setSpeed(player, 220)
        player:setCostume(444)
    end
end

xi.module.registerCommand('fly', commandObj)
