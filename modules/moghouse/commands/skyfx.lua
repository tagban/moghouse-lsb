-----------------------------------
-- func: skyfx
-- desc: The zone's look for MogHouse's own client: an aurora in the sky, the world as a wireframe, a
--       colour filter. Everyone in the zone sees it, and everyone who comes in, until it is turned off
--       or the server restarts. Other clients see the zone as ever. (modules/moghouse/cpp/skyfx.cpp)
--
--   !skyfx                                  what the zone has
--   !skyfx aurora [colour] [strength 1-100] an aurora: green, blue, pink, red, gold, purple, white
--   !skyfx wireframe [world|all|off]        the zone's own meshes (people as they are), or everything
--   !skyfx filter <kind> [amount 1-100]     grey, sepia, invert, night, or a colour; off
--   !skyfx off                              all of it off
-----------------------------------
require('modules/module_utils')
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 'sss',
}

local COLOURS =
{
    green  = { 60, 255, 140 },
    blue   = { 80, 170, 255 },
    pink   = { 255, 100, 200 },
    red    = { 255, 60, 60 },
    gold   = { 255, 200, 80 },
    purple = { 170, 90, 255 },
    white  = { 230, 240, 255 },
}

-- the filters by name (a colour's name is the colour filter, 3)
local FILTERS = { grey = 1, gray = 1, sepia = 2, invert = 4, night = 5 }
local FILTER_NAMES = { 'grey', 'sepia', 'a colour', 'inverted', 'night vision' }
local WORLD_NAMES = { 'the zone in wireframe', 'everything in wireframe' }

local function usage(player)
    player:printToPlayer('!skyfx aurora [colour] [strength] | wireframe [world|all|off] | filter <grey|sepia|invert|night|colour|off> [amount] | off')
    player:printToPlayer('Colours: green, blue, pink, red, gold, purple, white')
end

-- 1-100 to 0-255 (nil: all of it)
local function amount(value)
    local n = tonumber(value)
    if n == nil then
        return 255
    end

    return math.floor(math.max(1, math.min(100, n)) * 255 / 100 + 0.5)
end

local function colourName(r, g, b)
    for name, c in pairs(COLOURS) do
        if c[1] == r and c[2] == g and c[3] == b then
            return name
        end
    end

    return string.format('%d,%d,%d', r, g, b)
end

local function describe(player, zoneId)
    local sky, sr, sg, sb, ss, world, filter, fr, fg, fb, fa = mogSkyFxGet(zoneId)
    if sky == 0 and world == 0 and filter == 0 then
        player:printToPlayer('The zone looks as it always does.')
        return
    end

    local parts = {}
    if sky == 1 then
        table.insert(parts, string.format('a %s aurora at %d%%', colourName(sr, sg, sb), math.floor(ss * 100 / 255 + 0.5)))
    end

    if world > 0 then
        table.insert(parts, WORLD_NAMES[world] or 'a wireframe')
    end

    if filter > 0 then
        local name = filter == 3 and colourName(fr, fg, fb) or FILTER_NAMES[filter] or 'a filter'
        table.insert(parts, string.format('%s at %d%%', name, math.floor(fa * 100 / 255 + 0.5)))
    end

    player:printToPlayer('The zone has ' .. table.concat(parts, ', ') .. '.')
end

commandObj.onTrigger = function(player, what, arg1, arg2)
    local zoneId = player:getZoneID()
    local sky, sr, sg, sb, ss, world, filter, fr, fg, fb, fa = mogSkyFxGet(zoneId)
    what = what and string.lower(what) or nil
    arg1 = arg1 and string.lower(arg1) or nil

    if what == nil then
        describe(player, zoneId)
        return
    elseif what == 'off' then
        sky, world, filter = 0, 0, 0
    elseif what == 'aurora' then
        local colour = COLOURS[arg1 or 'green']
        local strength = arg2
        if colour == nil and tonumber(arg1) then -- !skyfx aurora 60: green, at 60
            colour, strength = COLOURS.green, arg1
        end

        if colour == nil then
            usage(player)
            return
        end

        if arg1 == 'off' then
            sky = 0
        else
            sky, sr, sg, sb, ss = 1, colour[1], colour[2], colour[3], amount(strength)
        end
    elseif what == 'wireframe' then
        local modes = { world = 1, all = 2, off = 0 }
        local mode = modes[arg1 or 'world']
        if mode == nil then
            usage(player)
            return
        end

        world = mode
    elseif what == 'filter' then
        if arg1 == 'off' then
            filter = 0
        elseif FILTERS[arg1 or ''] then
            filter, fr, fg, fb, fa = FILTERS[arg1], 0, 0, 0, amount(arg2)
        elseif COLOURS[arg1 or ''] then
            local c = COLOURS[arg1]
            filter, fr, fg, fb, fa = 3, c[1], c[2], c[3], amount(arg2)
        else
            usage(player)
            return
        end
    else
        usage(player)
        return
    end

    mogSkyFx(zoneId, sky, sr, sg, sb, ss, world, filter, fr, fg, fb, fa)
    describe(player, zoneId)
end

xi.module.registerCommand('skyfx', commandObj)
