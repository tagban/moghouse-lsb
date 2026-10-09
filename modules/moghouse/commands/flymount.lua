-----------------------------------
-- func: flymount
-- desc: Fly on a chocobo: up onto one and off the ground, as !fly flies, the chocobo kept. MogHouse's
--       own client flaps its wings and folds its legs while it flies (gamestate: riding a chocobo, with
--       the wallhack flag). Again: down on the nearest floor, and off the chocobo.
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

local TAKE_OFF = 3.0               -- yalms up from where they stand (a height in the game counts down: up is less)
local FLY_VAR = '[mogFly]on'       -- shared with !fly: 1 held to walls and the ground (jump.cpp), 2 their own wallhack
local MOUNT_VAR = '[mogFly]mount'  -- 1: this flight mounted them, so landing gets them off again

commandObj.FLY_VAR = FLY_VAR
commandObj.MOUNT_VAR = MOUNT_VAR

local FLY_SPEED = 220 -- as !fly's

-- A mounted player's speed is the mount's alone (CBattleEntity::UpdateSpeed: map.MOUNT_SPEED / 2, times
-- 1 + MOUNT_MOVE / 100), so the MOVE_SPEED_OVERRIDE !fly and !speed use does nothing on a chocobo:
-- MOUNT_MOVE takes it there instead (0: the mount's own speed again)
local function setMountSpeed(player, speed)
    local mountSpeed = (xi.settings and xi.settings.map and xi.settings.map.MOUNT_SPEED) or 80
    local base = math.max(1, math.floor(mountSpeed / 2))
    player:setMod(xi.mod.MOUNT_MOVE, speed > 0 and math.floor((speed / base - 1) * 100) or 0)
    player:recalculateStats()
end

commandObj.FLY_SPEED = FLY_SPEED

commandObj.onTrigger = function(player)
    local flying = player:getLocalVar(FLY_VAR)
    if flying ~= 0 then
        if flying == 1 then
            -- down on the nearest floor (mogGround: the collision below, else the navmesh's nearest point)
            local gx, gy, gz
            if mogGround then
                gx, gy, gz = mogGround(player)
            end

            if gx then
                player:setPos(gx, gy, gz, player:getRotPos())
            end

            player:setWallhack(false)
        end

        player:setLocalVar(FLY_VAR, 0)
        setMountSpeed(player, 0)
        if player:getLocalVar(MOUNT_VAR) == 1 then
            player:delStatusEffectSilent(xi.effect.MOUNTED)
        end

        player:setLocalVar(MOUNT_VAR, 0)
        player:setCostume(0)
        player:printToPlayer('Your chocobo lands, and you climb down.')
        return
    end

    -- on a chocobo first (a costume would hide it), unless they are on one already
    player:setCostume(0)
    if not player:hasStatusEffect(xi.effect.MOUNTED) then
        player:addStatusEffect(xi.effect.MOUNTED, { power = xi.mount.CHOCOBO, duration = 1800, origin = player, subPower = 64, silent = true })
        player:setLocalVar(MOUNT_VAR, 1)
    end

    player:setLocalVar(FLY_VAR, player:getWallhack() and 2 or 1)
    player:setWallhack(true)
    player:setPos(player:getXPos(), player:getYPos() - TAKE_OFF, player:getZPos(), player:getRotPos())
    setMountSpeed(player, FLY_SPEED)
    player:printToPlayer('Your chocobo spreads its wings and takes off! (MogHouse launcher: Space rises, X sinks.)')
end

xi.module.registerCommand('flymount', commandObj)
