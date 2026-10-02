-----------------------------------
-- MogHouse's /jump lift (modules/moghouse/jump.lua), run in LandSandBoat's xi_test. The C++ half
-- (moghouse/cpp/jump.cpp, each 0x11D handed to xi.moghouse.onJump) is built into xi_map only, so the
-- Lua is called here directly, as the module calls it.
-----------------------------------

describe('MogHouse /jump', function()
    local LIFT = 1.5

    it('lifts the player off the ground, one jump at a time', function()
        local player = xi.test.world:spawnPlayer({ zone = xi.zone.SOUTH_GUSTABERG, job = xi.job.WAR, level = 75 })
        local y      = player:getYPos()

        xi.moghouse.onJump(player)
        assert(math.abs(player:getYPos() - (y - LIFT)) < 0.01,
            string.format('height %.3f after a jump from %.3f', player:getYPos(), y))

        xi.moghouse.onJump(player) -- while the first is in the air
        assert(math.abs(player:getYPos() - (y - LIFT)) < 0.01, 'a second jump stacked on the first')
    end)

    it('sets a player still hanging at the lifted height back down', function()
        local player = xi.test.world:spawnPlayer({ zone = xi.zone.SOUTH_GUSTABERG, job = xi.job.WAR, level = 75 })
        local y      = player:getYPos()

        xi.moghouse.onJump(player)
        for _ = 1, 3 do
            xi.test.world:skipTime(1)
            xi.test.world:tickEntity(player)
        end

        assert(math.abs(player:getYPos() - y) < 0.01,
            string.format('still at %.3f, not back at %.3f', player:getYPos(), y))
        assert(player:getLocalVar(xi.moghouse.jump.BUSY_VAR) == 0, 'the next jump is held back')
    end)

    it('does not lift the knocked out', function()
        local player = xi.test.world:spawnPlayer({ zone = xi.zone.SOUTH_GUSTABERG, job = xi.job.WAR, level = 75 })
        player:setHP(0)
        xi.test.world:tickEntity(player)
        local y = player:getYPos()

        xi.moghouse.onJump(player)
        assert(math.abs(player:getYPos() - y) < 0.01, 'a knocked out player jumped')
    end)
end)
