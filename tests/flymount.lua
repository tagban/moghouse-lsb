-----------------------------------
-- MogHouse's !flymount (modules/moghouse/commands/flymount.lua), run in LandSandBoat's xi_test.
-----------------------------------

describe('MogHouse !flymount', function()
    it('mounts a chocobo and takes off, then lands and gets off again', function()
        local player = xi.test.world:spawnPlayer({ zone = xi.zone.SOUTH_GUSTABERG, job = xi.job.WAR, level = 75 })
        player:setGMLevel(5)
        local y = player:getYPos()

        xi.commands.flymount.onTrigger(player)
        assert(player:hasStatusEffect(xi.effect.MOUNTED), 'not on a chocobo')
        assert(player:getWallhack(), 'no wallhack flag: the client would put them back down')
        assert(math.abs(player:getYPos() - (y - 3)) < 0.01, string.format('at %.2f, not 3 up from %.2f', player:getYPos(), y))
        assert(player:getCostume() == 0, 'in a costume, which would hide the chocobo')
        assert(player:getMod(xi.mod.MOUNT_MOVE) > 100, string.format('the mount not sped up (MOUNT_MOVE %d)', player:getMod(xi.mod.MOUNT_MOVE)))

        local real = rawget(_G, 'mogGround')
        rawset(_G, 'mogGround', function(p) return p:getXPos(), y, p:getZPos() end) -- the floor below, as the C++ finds it
        xi.commands.flymount.onTrigger(player)
        rawset(_G, 'mogGround', real)
        assert(not player:getWallhack(), 'still flying after the second !flymount')
        assert(math.abs(player:getYPos() - y) < 0.01, string.format('landed at %.2f, not on the ground at %.2f', player:getYPos(), y))
        assert(not player:hasStatusEffect(xi.effect.MOUNTED), 'still on the chocobo')
        assert(player:getMod(xi.mod.MOUNT_MOVE) == 0, 'the mount still sped up after landing')
    end)

    it('keeps a chocobo the player was already riding', function()
        local player = xi.test.world:spawnPlayer({ zone = xi.zone.SOUTH_GUSTABERG, job = xi.job.WAR, level = 75 })
        player:setGMLevel(5)
        player:addStatusEffect(xi.effect.MOUNTED, { power = xi.mount.CHOCOBO, duration = 1800, origin = player, subPower = 64, silent = true })

        xi.commands.flymount.onTrigger(player)
        local real = rawget(_G, 'mogGround')
        rawset(_G, 'mogGround', function(p) return p:getXPos(), p:getYPos() + 3, p:getZPos() end)
        xi.commands.flymount.onTrigger(player)
        rawset(_G, 'mogGround', real)
        assert(player:hasStatusEffect(xi.effect.MOUNTED), 'their own chocobo was taken away on landing')
    end)
end)
