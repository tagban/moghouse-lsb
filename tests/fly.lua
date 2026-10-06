-----------------------------------
-- MogHouse's !fly (modules/moghouse/commands/fly.lua), run in LandSandBoat's xi_test.
-----------------------------------

describe('MogHouse !fly', function()
    it('takes off from where the player stands, as one of the fliers, and lands again', function()
        local player = xi.test.world:spawnPlayer({ zone = xi.zone.SOUTH_GUSTABERG, job = xi.job.WAR, level = 75 })
        player:setGMLevel(5)
        local y = player:getYPos()

        xi.commands.fly.onTrigger(player)
        assert(player:getWallhack(), 'no wallhack flag: the client would put them back down')
        assert(math.abs(player:getYPos() - (y - 3)) < 0.01, string.format('at %.2f, not 3 up from %.2f', player:getYPos(), y))

        local costume, known = player:getCostume(), false
        for _, f in ipairs(xi.commands.fly.flyers) do
            known = known or f[1] == costume
        end

        assert(known, string.format('costume %d is not one of the fliers', costume))

        local real = rawget(_G, 'mogGround')
        rawset(_G, 'mogGround', function(p) return p:getXPos(), y, p:getZPos() end) -- the floor below, as the C++ finds it
        xi.commands.fly.onTrigger(player)
        rawset(_G, 'mogGround', real)
        assert(not player:getWallhack(), 'still flying after the second !fly')
        assert(math.abs(player:getYPos() - y) < 0.01, string.format('landed at %.2f, not on the ground at %.2f', player:getYPos(), y))
        assert(player:getCostume() == 0, 'still in costume')
    end)

    it('keeps a wallhack the player already had, and sets a blocked flier back', function()
        local player = xi.test.world:spawnPlayer({ zone = xi.zone.SOUTH_GUSTABERG, job = xi.job.WAR, level = 75 })
        player:setGMLevel(5)
        player:setWallhack(true)
        local y = player:getYPos()

        xi.commands.fly.onTrigger(player)
        assert(player:getLocalVar(xi.commands.fly.FLY_VAR) == 2, 'not marked as flying on their own wallhack')
        xi.commands.fly.onTrigger(player)
        assert(player:getWallhack(), 'their own wallhack was turned off')
        assert(math.abs(player:getYPos() - (y - 3)) < 0.01, 'set on the ground although their wallhack is on')
        assert(player:getCostume() == 0, 'still in costume')

        xi.moghouse.onFlyBlocked(player, player:getXPos() + 1, y, player:getZPos())
        assert(math.abs(player:getYPos() - y) < 0.01, 'not set back')
    end)
end)
