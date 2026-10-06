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

-- what a flier turns into, one at random (costumes are model numbers, as mob_pools' modelid has them)
local FLYERS =
{
    { 256, 'Golden Bat' }, { 264, 'Bat Eye' }, { 272, 'Hunting Wasp' }, { 280, 'Bomb King' },
    { 281, 'Volcanic Bomb' }, { 336, 'Roc' }, { 398, 'Wyvern' }, { 448, 'Mayfly' },
    { 1365, 'Hippogryph' }, { 1720, 'Colibri' }, { 1726, 'Heraldic Imp' }, { 1744, 'Molted Puk' },
    { 1808, 'Wamoura' },
}

local TAKE_OFF = 3.0 -- yalms up from where they stand (a height in the game counts down: up is less)

commandObj.flyers = FLYERS

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
        -- the wallhack flag keeps the client from putting them back on the ground; with the MogHouse
        -- launcher, Space rises, X sinks, and moving climbs or dives the way the camera looks
        local flier = FLYERS[math.random(#FLYERS)]
        player:setWallhack(true)
        player:setPos(player:getXPos(), player:getYPos() - TAKE_OFF, player:getZPos(), player:getRotPos())
        setSpeed(player, 220)
        player:setCostume(flier[1])
        player:printToPlayer(string.format('You turn into a %s and take off! (MogHouse launcher: Space rises, X sinks.)', flier[2]))
    end
end

xi.module.registerCommand('fly', commandObj)
