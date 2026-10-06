-----------------------------------
-- A jump that leaves the ground (MogHouse)
--
-- The game's /jump (J, with the MogHouse launcher) only plays an animation.
-- modules/moghouse/cpp/jump.cpp hands each one here.
--
-- A jump is a hop: lifted a little, as !up lifts them, and set back down if still hanging there a
-- moment later. Unless there is a higher floor within 3 yalms ahead (mogLeapTarget, the zone's own
-- collision: at most MAX_RISE above, with nothing in the way): then a leap onto it, up and over, then
-- down on it; of those at each distance in AHEAD, the highest. One jump at a time: they never stack
-- into flying.
-- Heights count down in the game: up is less.
-----------------------------------
require('modules/module_utils')
-----------------------------------
xi = xi or {}
xi.moghouse = xi.moghouse or {}

xi.moghouse.jump =
{
    AHEAD     = { 1.0, 1.5, 2.0, 2.5, 3.0 }, -- yalms in front where a higher floor is looked for
    MAX_RISE  = 6.0,  -- the highest a leap lands above where it started (a Bastok Markets ledge: 2.14)
    STEP      = 0.4,  -- a floor ahead higher than this above where they stand: a ledge to leap onto
    PEAK      = 2.0,  -- a leap's top, above the higher of the two floors
    LAND_MS   = 250,  -- from the top of a leap to landing
    HOP       = 2.5,  -- a hop's lift, where there is nowhere to leap to
    SETTLE_MS = 100,  -- a hop still hanging after this long: back down (at the server's next tick,
                      -- 0.4 seconds apart: so the next one)
    BUSY_VAR  = '[mogJump]busy',
}

local function done(p)
    p:setLocalVar(xi.moghouse.jump.BUSY_VAR, 0)
end

xi.moghouse.onJump = function(player)
    local j = xi.moghouse.jump

    if
        player:isDead() or
        player:getLocalVar(j.BUSY_VAR) == 1 or
        player:hasStatusEffect(xi.effect.MOUNTED)
    then
        return
    end

    local x, y, z, rot = player:getXPos(), player:getYPos(), player:getZPos(), player:getRotPos()
    player:setLocalVar(j.BUSY_VAR, 1)

    local tx, ty, tz -- the highest ledge ahead
    if mogLeapTarget then
        for _, ahead in ipairs(j.AHEAD) do
            local cx, cy, cz = mogLeapTarget(player, ahead, j.MAX_RISE, 0)
            if cx and y - cy > j.STEP and (not ty or cy < ty - 0.05) then -- higher (less) by more than a slope's wobble
                tx, ty, tz = cx, cy, cz
            end
        end
    end

    if tx then
        -- the leap: halfway over at its top, then down on the far floor
        local top = math.min(y, ty) - j.PEAK
        player:setPos((x + tx) / 2, top, (z + tz) / 2, rot)
        player:timer(j.LAND_MS, function(p)
            p:setPos(tx, ty, tz, p:getRotPos())
            done(p)
        end)
        return
    end

    -- the hop
    local lifted = y - j.HOP
    player:setPos(x, lifted, z, rot)
    player:timer(j.SETTLE_MS, function(p)
        if math.abs(p:getYPos() - lifted) < 0.01 then
            p:setPos(p:getXPos(), y, p:getZPos(), p:getRotPos())
        end

        done(p)
    end)
end
