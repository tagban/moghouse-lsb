-----------------------------------
-- A jump that leaves the ground (MogHouse)
--
-- The game's /jump (Space, with the MogHouse launcher's overlay) only plays an animation.
-- modules/moghouse/cpp/jump.cpp hands each one here: the player is lifted a little, as !up lifts
-- them, so walking on lands them on what is there (a rock, a step). Still hanging at that height a
-- moment later (they did not move), they are set back down where they were. One jump at a time: the
-- lifts never stack into flying.
-----------------------------------
require('modules/module_utils')
-----------------------------------
xi = xi or {}
xi.moghouse = xi.moghouse or {}

xi.moghouse.jump =
{
    LIFT      = 1.5,  -- yalms (a height in the game counts down: up is less)
    SETTLE_MS = 700,  -- still at the lifted height after this long: back down
    BUSY_VAR  = '[mogJump]busy',
}

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
    local lifted       = y - j.LIFT

    player:setLocalVar(j.BUSY_VAR, 1)
    player:setPos(x, lifted, z, rot)
    player:timer(j.SETTLE_MS, function(p)
        if math.abs(p:getYPos() - lifted) < 0.01 then
            p:setPos(p:getXPos(), y, p:getZPos(), p:getRotPos())
        end

        p:setLocalVar(j.BUSY_VAR, 0)
    end)
end
