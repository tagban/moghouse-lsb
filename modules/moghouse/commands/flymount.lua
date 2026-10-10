-----------------------------------
-- func: flymount
-- desc: Fly on a mount: up onto one and off the ground, as !fly flies, the mount kept. A chocobo by
--       default (MogHouse's own client flaps its wings and folds its legs while it flies); or one of the
--       game's own fliers by name: !flymount hippogryph (tulfaire, levitus, fenrir, pot, chair, ...), or
--       MogHouse's own: !flymount bee (sized to its rider; MogHouse's client makes it, others see none).
--       Again: down on the nearest floor, and off the mount.
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

local TAKE_OFF = 3.0               -- yalms up from where they stand (a height in the game counts down: up is less)
local FLY_VAR = '[mogFly]on'       -- shared with !fly: 1 held to walls and the ground (jump.cpp), 2 their own wallhack
local MOUNT_VAR = '[mogFly]mount'  -- 1: this flight mounted them, so landing gets them off again

commandObj.FLY_VAR = FLY_VAR
commandObj.MOUNT_VAR = MOUNT_VAR

local FLY_SPEED = 220 -- as !fly's

-- the mounts by name (xi.mount's): the game's winged and floating ones first (all carry any race)
local MOUNTS =
{
    chocobo = 'CHOCOBO',
    hippogryph = 'HIPPOGRYPH', griffin = 'HIPPOGRYPH',
    tulfaire = 'TULFAIRE', bird = 'TULFAIRE',
    levitus = 'LEVITUS',
    fenrir = 'FENRIR',
    pot = 'MAGIC_POT', magicpot = 'MAGIC_POT',
    chair = 'SPECTRAL_CHAIR',
    spheroid = 'SPHEROID',
    bomb = 'BOMB', goldenbomb = 'GOLDEN_BOMB',
    moogle = 'MOOGLE',
    omega = 'OMEGA',
    ixion = 'IXION',
    byakko = 'BYAKKO',
    raptor = 'RAPTOR',
    tiger = 'TIGER',
    crab = 'CRAB',
    morbol = 'MORBOL',
    wivre = 'WIVRE',
    adamantoise = 'ADAMANTOISE',
    goobbue = 'GOOBBUE',
    coeurl = 'COEURL',
}

commandObj.MOUNTS = MOUNTS

-- MogHouse's own mounts, past retail's: its client makes their models (ffxi-native, runtime/portable/mounts.h;
-- other clients draw nothing). The bee comes in three sizes, by who rides it.
local BEE_SMALL, BEE, BEE_LARGE = 40, 41, 42

local function ownMount(player, key)
    if key == 'bee' then
        local race = player:getRace()
        if race == xi.race.TARU_M or race == xi.race.TARU_F then
            return BEE_SMALL
        elseif race == xi.race.GALKA then
            return BEE_LARGE
        end

        return BEE
    end
end

commandObj.ownMount = ownMount

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

commandObj.onTrigger = function(player, name)
    local mount = xi.mount.CHOCOBO
    if name and name ~= '' then
        local key = string.lower(name):gsub('[%s_%-]', '')
        mount = ownMount(player, key) or (MOUNTS[key] and xi.mount[MOUNTS[key]])
        if not mount then
            local names = { 'bee' }
            for k in pairs(MOUNTS) do
                table.insert(names, k)
            end

            table.sort(names)
            player:printToPlayer('!flymount <mount>: ' .. table.concat(names, ', '))
            return
        end
    end

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
        player:printToPlayer('Your mount lands, and you climb down.')
        return
    end

    -- on the mount first (a costume would hide it), unless they are riding it already (another one
    -- named is swapped in for theirs, and gone again on landing)
    player:setCostume(0)
    if name and name ~= '' and player:hasStatusEffect(xi.effect.MOUNTED) and player:getLocalVar(MOUNT_VAR) == 0 then
        local own = player:getStatusEffect(xi.effect.MOUNTED)
        if own and own:getPower() ~= mount then
            player:delStatusEffectSilent(xi.effect.MOUNTED)
        end
    end

    if not player:hasStatusEffect(xi.effect.MOUNTED) then
        -- the mount the client draws is the character update's mount index, which only the game's own
        -- Mount command sets: set here first (modules/moghouse/cpp/mount.cpp), the effect then sends it
        if mogSetMount then
            mogSetMount(player, mount)
        end

        player:addStatusEffect(xi.effect.MOUNTED, { power = mount, duration = 1800, origin = player, subPower = 64, silent = true })
        player:setLocalVar(MOUNT_VAR, 1)
    end

    player:setLocalVar(FLY_VAR, player:getWallhack() and 2 or 1)
    player:setWallhack(true)
    player:setPos(player:getXPos(), player:getYPos() - TAKE_OFF, player:getZPos(), player:getRotPos())
    setMountSpeed(player, FLY_SPEED)
    player:printToPlayer('Your mount takes to the air! (MogHouse launcher: Space rises, X sinks.)')
end

xi.module.registerCommand('flymount', commandObj)
