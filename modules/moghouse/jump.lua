-----------------------------------
-- A jump that leaves the ground (MogHouse)
--
-- The game's /jump (Space, with the MogHouse launcher's overlay) only plays an animation.
-- modules/moghouse/cpp/jump.cpp hands each one here.
--
-- A leap: where there is a floor a little way ahead (mogLeapTarget, the zone's own collision: at most
-- MAX_RISE above, any way below within MAX_DROP, with nothing in the way), the player arcs onto it: up
-- and over, then down on it. Of the floors at each distance in AHEAD, the highest: by a ledge, onto the
-- ledge, not a step along the ground before it. Elsewhere, a hop: lifted a little, as !up lifts them, and set back down if
-- still hanging there a moment later. One jump at a time: they never stack into flying.
-- Heights count down in the game: up is less.
-----------------------------------
require('modules/module_utils')
-----------------------------------
xi = xi or {}
xi.moghouse = xi.moghouse or {}

xi.moghouse.jump =
{
    AHEAD     = { 1.5, 2.0, 2.5 }, -- yalms in front where a leap may land
    MAX_RISE  = 2.5,  -- the highest a leap lands above where it started (a Bastok Markets ledge: 2.14)
    MAX_DROP  = 6.0,  -- the lowest below
    STEP      = 0.4,  -- a floor ahead nearer than this to where they stand: flat, a hop in place
    PEAK      = 1.0,  -- a leap's top, above the higher of the two floors
    LAND_MS   = 250,  -- from the top of a leap to landing
    HOP       = 1.5,  -- a hop's lift, where there is nowhere to leap to
    SETTLE_MS = 700,  -- a hop still hanging after this long: back down
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

    local tx, ty, tz
    if mogLeapTarget then
        for _, ahead in ipairs(j.AHEAD) do
            local cx, cy, cz = mogLeapTarget(player, ahead, j.MAX_RISE, j.MAX_DROP)
            if cx and math.abs(cy - y) > j.STEP and (not ty or cy < ty - 0.05) then -- higher (less) by more than a slope's wobble
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
