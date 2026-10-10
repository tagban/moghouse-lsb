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

    it('flies the mount named, and lists them for a name it does not know', function()
        local player = xi.test.world:spawnPlayer({ zone = xi.zone.SOUTH_GUSTABERG, job = xi.job.WAR, level = 75 })
        player:setGMLevel(5)

        xi.commands.flymount.onTrigger(player, 'nosuchbeast')
        assert(not player:hasStatusEffect(xi.effect.MOUNTED), 'mounted on a name it does not know')
        assert(not player:getWallhack(), 'took off on a name it does not know')

        xi.commands.flymount.onTrigger(player, 'Hippogryph')
        local effect = player:getStatusEffect(xi.effect.MOUNTED)
        assert(effect and effect:getPower() == xi.mount.HIPPOGRYPH, 'not on a hippogryph')
        assert(mogGetMount(player) == xi.mount.HIPPOGRYPH, string.format('the client is told mount %d, not the hippogryph', mogGetMount(player)))
        assert(player:getWallhack(), 'not flying')

        local real = rawget(_G, 'mogGround')
        rawset(_G, 'mogGround', function(p) return p:getXPos(), p:getYPos() + 3, p:getZPos() end)
        xi.commands.flymount.onTrigger(player)
        rawset(_G, 'mogGround', real)
        assert(not player:hasStatusEffect(xi.effect.MOUNTED), 'still on the hippogryph')
    end)

    it('sizes the bee to its rider', function()
        local cases = { { xi.race.TARU_F, 40 }, { xi.race.HUME_M, 41 }, { xi.race.MITHRA, 41 }, { xi.race.GALKA, 42 } }
        for _, case in ipairs(cases) do
            local player = xi.test.world:spawnPlayer({ zone = xi.zone.SOUTH_GUSTABERG, job = xi.job.WAR, level = 75, race = case[1] })
            player:setGMLevel(5)
            assert(xi.commands.flymount.ownMount(player, 'bee') == case[2],
                string.format('race %d: bee %s, not %d', case[1], tostring(xi.commands.flymount.ownMount(player, 'bee')), case[2]))
        end

        local player = xi.test.world:spawnPlayer({ zone = xi.zone.SOUTH_GUSTABERG, job = xi.job.WAR, level = 75 })
        player:setGMLevel(5)
        xi.commands.flymount.onTrigger(player, 'bee')
        local effect = player:getStatusEffect(xi.effect.MOUNTED)
        assert(effect and effect:getPower() >= 40 and effect:getPower() <= 42, 'not on a bee')
        assert(mogGetMount(player) == effect:getPower(), 'the client is told another mount than the bee')
        assert(xi.commands.flymount.ownMount(player, 'airship') == 43, 'no airship')
        assert(xi.commands.flymount.ownMount(player, 'boat') == 44, 'no boat')
    end)
end)
