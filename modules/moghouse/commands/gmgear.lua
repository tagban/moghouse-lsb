-----------------------------------
-- func: gmgear
-- desc: GM Gear. Gives an item to the target player.
-----------------------------------
require('modules/module_utils')
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 'sii',
}

commandObj.onTrigger = function(player)
    -- ADD RACE SPECIFIC STARTGEAR
    if player:getRace() == xi.race.HUME_M or player:getRace() == xi.race.HUME_F then
        player:addItem(12551) -- GM Body
        player:addItem(12523) -- GM Head
        player:addItem(12807) -- GM Legs
        player:addItem(12935) -- GM Feet
        player:addItem(12679) -- GM Hands
        player:printToPlayer('GM Gear Added to Inventory')
    else
        player:printToPlayer('Race cannot wear GM Gear but here\'s the accessories...')
    end

    player:addItem(17012) -- GM Fishing Rod
    player:addItem(17644) -- GM GSword
    player:addItem(16622) -- GM Sword
    player:addItem(12332) -- GM Shield
    player:addItem(13505) -- GM Ring
    player:addItem(13358) -- GM Earring
    player:addItem(13606) -- GM Cape
    player:addItem(17174) -- GM Bow
    player:addItem(13215) -- GM Belt
    player:addItem(17326) -- GM Arrow
    player:addItem(13074) -- GM Neck
end

xi.module.registerCommand('gmgear', commandObj)
