-----------------------------------
-- func: apocnigh
-- desc: opens a custom shop to access buying the apoc nigh earrings.
-----------------------------------
require('modules/module_utils')
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 0,
    parameters = '',
}

commandObj.onTrigger = function(player)
    -- Must have RoZ and CoP done and rank 9.
    local zilartClear = player:hasCompletedMission(xi.mission.log_id.ZILART, xi.mission.id.zilart.AWAKENING)
    local chainsClear = player:hasCompletedMission(xi.mission.log_id.COP, xi.mission.id.cop.DAWN)
    local currentRank = player:getRank(player:getNation())

    if zilartClear == true and chainsClear == true and currentRank >= 9 then
        local stock =
        {
            { 15965, 500000 }, -- Ethereal Earring
            { 15964, 500000 }, -- Hallow Earring
            { 15963, 500000 }, -- Magnetic Earring
            { 15962, 500000 }, -- Static Earring
        }

        xi.shop.general(player, stock)
        player:printToPlayer('You have proven your worth, enjoy the rewards..')
    else
        player:printToPlayer('You are not worthy..')
    end
end

xi.module.registerCommand('apocnigh', commandObj)
