-----------------------------------
-- MogHouse's /jump (modules/moghouse/jump.lua), run in LandSandBoat's xi_test. The C++ half
-- (moghouse/cpp/jump.cpp: each 0x11D handed to xi.moghouse.onJump, and mogLeapTarget) is built into
-- xi_map only, so the Lua is called here directly, with a stand-in for mogLeapTarget.
-----------------------------------

describe('MogHouse /jump', function()
    local LIFT = 2.0

    -- mogLeapTarget, as the C++ module answers: nowhere to leap (a hop), unless a test says
    local leapTo
    before_each(function()
        leapTo = nil
        rawset(_G, 'mogLeapTarget', function(player, ahead, maxRise, maxDrop)
            if leapTo then
                return leapTo(player, ahead, maxRise, maxDrop)
            end
        end)
    end)

    after_each(function()
        rawset(_G, 'mogLeapTarget', nil)
    end)

    it('leaps onto the floor ahead: over its top, then down on it', function()
        local player = xi.test.world:spawnPlayer({ zone = xi.zone.SOUTH_GUSTABERG, job = xi.job.WAR, level = 75 })
        local x, y, z = player:getXPos(), player:getYPos(), player:getZPos()
        local asked = {}
        leapTo = function(p, ahead, maxRise, maxDrop)
            table.insert(asked, ahead)
            assert(maxRise == 3.0, 'the leap asked for the wrong rise')
            if ahead < 2.5 then
                return x + ahead, y, z -- the street before the ledge
            end

            return x + 2.5, y - 2, z -- a ledge 2 yalms up, 2.5 ahead
        end

        xi.moghouse.onJump(player)
        assert(#asked == 3, string.format('asked %d distances, not 3', #asked))
        assert(math.abs(player:getYPos() - (y - 3.5)) < 0.01,
            string.format('at the top %.3f, not 1.5 yalms over the ledge (%.3f)', player:getYPos(), y - 3.5))
        assert(math.abs(player:getXPos() - (x + 1.25)) < 0.01, 'not halfway over at the top')

        for _ = 1, 3 do
            xi.test.world:skipTime(1)
            xi.test.world:tickEntity(player)
        end

        assert(math.abs(player:getYPos() - (y - 2)) < 0.01 and math.abs(player:getXPos() - (x + 2.5)) < 0.01,
            string.format('landed at %.3f, %.3f, not on the ledge', player:getXPos(), player:getYPos()))
        assert(player:getLocalVar(xi.moghouse.jump.BUSY_VAR) == 0, 'the next jump is held back')
    end)

    it('hops in place on flat ground, not along it', function()
        local player = xi.test.world:spawnPlayer({ zone = xi.zone.SOUTH_GUSTABERG, job = xi.job.WAR, level = 75 })
        local x, y = player:getXPos(), player:getYPos()
        leapTo = function(p, ahead)
            return x + ahead, y - 0.1, player:getZPos() -- the ground ahead, a little slope
        end

        xi.moghouse.onJump(player)
        assert(math.abs(player:getXPos() - x) < 0.01, 'a jump on flat ground moved the player along')
        assert(math.abs(player:getYPos() - (y - LIFT)) < 0.01, 'not lifted in place')
    end)

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
