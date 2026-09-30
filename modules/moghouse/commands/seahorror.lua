-----------------------------------
-- func: seahorror
-- desc: Spawns a ton of NMs at once. Allows GM's to trigger NMs that are commonly requested. Add more if you tell me!
-----------------------------------
require('modules/module_utils')
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 'iiii',
}

commandObj.onTrigger = function(player)
    -- SpawnMob(mobId, despawnSeconds)
    SpawnMob(17678350, 160000) -- SeaHorror (Ship bound for Selbina)
    SpawnMob(17682446, 160000) -- SeaHorror (Ship bound for Mhaura)
    SpawnMob(17215494, 160000) -- BUBBLY BERNIE (South Gustaberg)
end

xi.module.registerCommand('seahorror', commandObj)
