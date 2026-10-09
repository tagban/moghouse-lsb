-----------------------------------
-- MogHouse's !skyfx (modules/moghouse/commands/skyfx.lua), run in LandSandBoat's xi_test. Its C++
-- (modules/moghouse/cpp/skyfx.cpp: the zone's look, sent at the end of the weather packet) is built into
-- xi_map only, so stand-ins keep each zone's look here; the packet itself is seen in game.
-----------------------------------

local function withStandIns(fn)
    local looks = {}
    local realSet, realGet = rawget(_G, 'mogSkyFx'), rawget(_G, 'mogSkyFxGet')
    rawset(_G, 'mogSkyFx', function(zoneId, ...)
        looks[zoneId] = { ... }
    end)
    rawset(_G, 'mogSkyFxGet', function(zoneId)
        return table.unpack(looks[zoneId] or { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
    end)
    local ok, err = pcall(fn, looks)
    rawset(_G, 'mogSkyFx', realSet)
    rawset(_G, 'mogSkyFxGet', realGet)
    assert(ok, err)
end

local function gm()
    local player = xi.test.world:spawnPlayer({ zone = xi.zone.SOUTH_GUSTABERG, job = xi.job.WAR, level = 75 })
    player:setGMLevel(5)
    return player
end

describe('MogHouse !skyfx', function()
    it('puts an aurora in the zone, green unless told, at the strength asked', function()
        withStandIns(function(looks)
            local player = gm()
            local zone = player:getZoneID()

            xi.commands.skyfx.onTrigger(player, 'aurora')
            local l = looks[zone]
            assert(l ~= nil, 'the zone was given no look')
            assert(l[1] == 1, 'no aurora')
            assert(l[2] == 60 and l[3] == 255 and l[4] == 140, 'not green')
            assert(l[5] == 255, string.format('strength %d, not all of it', l[5]))

            xi.commands.skyfx.onTrigger(player, 'aurora', 'pink', '50')
            l = looks[zone]
            assert(l[2] == 255 and l[3] == 100 and l[4] == 200, 'not pink')
            assert(l[5] == 128, string.format('strength %d, not half', l[5]))
        end)
    end)

    it('keeps what the zone has when another part is changed, and turns it all off', function()
        withStandIns(function(looks)
            local player = gm()
            local zone = player:getZoneID()

            xi.commands.skyfx.onTrigger(player, 'aurora', 'blue')
            xi.commands.skyfx.onTrigger(player, 'wireframe')
            xi.commands.skyfx.onTrigger(player, 'filter', 'sepia', '40')
            local l = looks[zone]
            assert(l[1] == 1, 'the aurora went when the wireframe came')
            assert(l[6] == 1, 'not the zone in wireframe')
            assert(l[7] == 2 and l[11] == 102, 'not sepia at 40%')

            xi.commands.skyfx.onTrigger(player, 'wireframe', 'all')
            assert(looks[zone][6] == 2, 'not everything in wireframe')

            xi.commands.skyfx.onTrigger(player, 'filter', 'gold')
            l = looks[zone]
            assert(l[7] == 3 and l[8] == 255 and l[9] == 200 and l[10] == 80, 'not a gold filter')

            xi.commands.skyfx.onTrigger(player, 'off')
            l = looks[zone]
            assert(l[1] == 0 and l[6] == 0 and l[7] == 0, 'something stayed on')
        end)
    end)

    it('changes nothing for a word it does not know', function()
        withStandIns(function(looks)
            local player = gm()
            xi.commands.skyfx.onTrigger(player, 'rainbows')
            xi.commands.skyfx.onTrigger(player, 'aurora', 'plaid')
            xi.commands.skyfx.onTrigger(player, 'wireframe', 'sideways')
            xi.commands.skyfx.onTrigger(player, 'filter', 'plaid')
            assert(looks[player:getZoneID()] == nil, 'a look was set')
            xi.commands.skyfx.onTrigger(player) -- what the zone has: no error
        end)
    end)
end)
