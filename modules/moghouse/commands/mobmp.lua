-----------------------------------
-- func: mobmp <optional MobID>
-- desc: Used to get a mob's entity flags for testing.
--       MUST either target a mob first or else specify a Mob ID.
-----------------------------------
require('modules/module_utils')
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 'i',
}

local function error(player, msg)
    player:printToPlayer(msg)
    player:printToPlayer('!mobmp {mob ID} or Target something!')
end

commandObj.onTrigger = function(player, target)
    -- validate target
    local targ
    if not target then
        targ = player:getCursorTarget()
        if not targ or not targ:isMob() then
            error(player, 'You must either supply a mob ID or target a mob.')
            return
        end
    else
        targ = GetMobByID(target)
        if not targ then
            error(player, 'Invalid mob ID.')
            return
        end
    end

    -- set flags
    local flags = targ:getMP()
    player:printToPlayer(string.format('%s\'s MP is: %u', targ:getName(), flags))
end

xi.module.registerCommand('mobmp', commandObj)
