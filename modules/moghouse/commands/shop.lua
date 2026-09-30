-----------------------------------
-- func: shop <page>
-- desc: BNETcc Server Shop. opens a custom shop anywhere in the world
-----------------------------------
require('modules/module_utils')
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 0,
    parameters = 'i',
}

-- Notes:
-- ALWAYS comment your additions!
-- Shop stock entries are now { itemId, price } tables (xi.shop.general takes a list of those).

commandObj.onTrigger = function(player, page)
    player:printToPlayer('Welcome to BNET.cc\'s shop of wares to aid you on your adventure!', xi.msg.channel.NS_PARTY)

    if page == 0 or page == nil then
        player:printToPlayer('1: HQ Crystal, 2: Food, 3: Meds, 4: Misc')
        player:printToPlayer(' 5: Tools 6: Cor Dies 7: fireworks 8: Swim wear')
        -- Edit and uncomment next line if you want more pages.
        -- player:printToPlayer('5: ??, 6: ??, 7: ??, 8: ??')
        player:printToPlayer('!shop <page#>')
    elseif page == 1 then
        local stock1 =
        {
            { 4238, 3000 }, -- HQ Fire Crystal
            { 4239, 3000 }, -- HQ Ice Crystal
            { 4240, 3000 }, -- HQ Wind Crystal
            { 4241, 3000 }, -- HQ Earth Crystal
            { 4242, 3000 }, -- HQ Lightning Crystal
            { 4243, 3000 }, -- HQ Water Crystal
            { 4244, 3000 }, -- HQ Light Crystal
            { 4245, 3000 }, -- HQ Dark Crystal
        }

        xi.shop.general(player, stock1)
        player:printToPlayer('At Elemensis, we stock only the highest quality crystals..')
    elseif page == 2 then
        local stock2 =
        {
            -- Non Custom "for low lv noobs in exp party" food, same price as AH so non exploitable.
            { 4376, 108 }, -- Meat Jerky
            { 5721, 500 }, -- Crab Sushi
            { 4271, 2000 }, -- Rice Dumpling
            { 4536, 3133 }, -- Blackened Frog
            --------------------------------------------------
            -- Custom food items
            -- { 4258, 32500 }, -- Red Drop
            -- { 4259, 32500 }, -- Clear Drop
            -- { 4260, 32500 }, -- Green Drop
            -- { 4261, 32500 }, -- Yellow Drop
            -- { 4262, 32500 }, -- Purple Drop
            -- { 4263, 32500 }, -- Blue Drop
            -- { 4264, 32500 }, -- White Drop
            -- { 4265, 4000 }, -- Black Drop
        }

        xi.shop.general(player, stock2)
        player:printToPlayer('Welcome to Cuisinable, Would you like fries with that?')
    elseif page == 3 then
        local stock3 =
        {
            { 4148, 316 }, -- Antidote
            { 4150, 2595 }, -- Eye Drops
            { 4151, 800 }, -- Echo drops
            { 4112, 910 }, -- Potion
            { 4128, 4832 }, -- Ether
            { 4153, 6000 }, -- Antacid
            { 4182, 15000 }, -- Instant Reraise
            { 4165, 5000 }, -- Silent Oil
            { 4164, 5000 }, -- Prism Powder
            { 4213, 5000 }, -- Icarus Wing
        }

        xi.shop.general(player, stock3)
        player:printToPlayer('Step right up folks Medocal! Cures blindness, sore throat, and various poisons!')
    elseif page == 4 then
        local stock4 =
        {
            -- { 15793, 150000 }, -- Anniversary Ring
            { 15761, 15000 }, -- Chariot Band
            { 15762, 15000 }, -- Empress Band
            { 15763, 35000 }, -- Emperor Band
            { 16368, 32000 }, -- Herder's Subligar
            { 18762, 32000 }, -- Custodes
            { 18503, 32000 }, -- Mammut
            { 19222, 32000 }, -- Wurger
            { 15880, 32000 }, -- Key Ring Belt
            { 19223, 24000 }, -- Attar of Roses
            { 16007, 24000 }, -- Protect Earing
            { 15835, 20000 }, -- Desperado Ring
            { 19157, 20000 }, -- Surviver
            { 15926, 20000 }, -- Bronze Bandolier
            { 19221, 20000 }, -- Firefly
            { 15834, 20000 }, -- Bind Ring
            { 16279, 20000 }, -- Pile Chain
        }

        xi.shop.general(player, stock4)
        player:printToPlayer('Gear Shack, we\'ve got your back.')
    elseif page == 5 then
        local stock5 =
        {
            { 5869, 500 }, -- Chonofuda
            { 5312, 500 }, -- Hiraishin
            { 5867, 500 }, -- Inoshishinofuda
            { 5864, 500 }, -- Jinko
            { 5315, 500 }, -- Jusatsu
            { 5863, 500 }, -- Kabenro
            { 5316, 500 }, -- Kaginawa
            { 5310, 500 }, -- Kawahori-Ogi
            { 5318, 500 }, -- Kodoku
            { 5311, 500 }, -- Makibishi
            { 5313, 500 }, -- Mizu-Deppo
            { 5866, 500 }, -- Mokukin
            { 5865, 500 }, -- Ryuno
            { 5317, 500 }, -- Sairui-Ran
            { 5417, 500 }, -- Sanjaku-Tenugui
            { 5314, 500 }, -- Shihei
            { 5868, 500 }, -- Shikanofuda
            { 5319, 500 }, -- Shinobi-Tabi
            { 5734, 500 }, -- Soshi
            { 5309, 500 }, -- Tsurara
            { 5308, 500 }, -- Uchitake
        }

        xi.shop.general(player, stock5)
        player:printToPlayer('All the ninja Tools you need for your adventure!')
    elseif page == 6 then
        local stock6 =
        {
            -- Die's
            { 5502, 100 }, -- Allies' Die
            { 5505, 100 }, -- Avenger's Die
            { 5486, 100 }, -- Bard Die
            { 5485, 100 }, -- Beastmaster Die
            { 5480, 100 }, -- Black Mage Die
            { 5500, 100 }, -- Blitzer's Die
            { 5492, 100 }, -- Blue Mage Die
            { 5497, 100 }, -- Bolter's Die
            { 5498, 100 }, -- Caster's Die
            { 5504, 100 }, -- Companion's Die
            { 5493, 100 }, -- Corsair Die
            { 5499, 100 }, -- Courser's Die
            { 5495, 100 }, -- Dancer Die
            { 5484, 100 }, -- Dark Knight Die
            { 5490, 100 }, -- Dragoon Die
            { 6368, 100 }, -- Geomancer Die
            { 5503, 100 }, -- Miser's Die
            { 5478, 100 }, -- Monk Die
            { 5489, 100 }, -- Ninja Die
            { 5483, 100 }, -- Paladin Die
            { 5494, 100 }, -- Puppetmaster Die
            { 5487, 100 }, -- Ranger Die
            { 5481, 100 }, -- Red Mage Die
            { 5488, 100 }, -- Samurai Die
            { 5496, 100 }, -- Scholar Die
            { 5491, 100 }, -- Summoner Die
            { 5501, 100 }, -- Tactician's Die
            { 5482, 100 }, -- Thief Die
            { 5477, 100 }, -- Warrior Die
            { 5479, 100 }, -- White Mage Die
        }

        xi.shop.general(player, stock6)
        player:printToPlayer('All the corsair dies you need for your adventure!')
    elseif page == 7 then
        local stock7 =
        {
            { 4186, 100 }, -- Airborne
            { 5441, 100 }, -- Angelwing
            { 4216, 100 }, -- Brilliant Snow
            { 4167, 100 }, -- Cracker
            { 4250, 100 }, -- Crackler
            { 5361, 100 }, -- Datechochin
            -- { 5883, 100 }, -- Falling Star (Not Working)
            { 4251, 100 }, -- Festive Fan
            { 5725, 100 }, -- Goshikitenge
            { 4184, 100 }, -- Kongou Inaho
            { 4183, 100 }, -- Konron Hassen
            { 4169, 100 }, -- Little Comet
            -- { 5882, 100 }, -- Marine Bliss (Not Working)
            { 4185, 100 }, -- Meifu Goma
            { 5360, 100 }, -- Muteppo
            { 4256, 100 }, -- Ouka Ranman
            { 4257, 100 }, -- Papillion
            { 5769, 100 }, -- Popper (Congrats!)
            -- { 4215, 100 }, -- Popstar (Not Working)
            -- { 5881, 100 }, -- Shisai Kaboku (Not Working)
            { 4217, 100 }, -- Sparkling Hand
            { 4253, 100 }, -- Spirit Masque
            { 4252, 100 }, -- Summer Fan
            { 4168, 100 }, -- Twinkle Shower
        }

        xi.shop.general(player, stock7)
        player:printToPlayer('Illegal fireworks... oh shit run its the fuz!')
    elseif page == 8 then
        local stock8 =
        {
            -- CHOCOBO SET
            { 11500, 10000 }, -- Chocobo Beret
            { 27765, 10000 }, -- Chocobo Masque
            { 27911, 10000 }, -- Chocobo Suit
            { 17074, 10000 }, -- Chocobo Wand
            { 10811, 10000 }, -- Chocobo Shield
            --MOOGLE SET
            { 16118, 10000 }, -- Moogle Cap,Enchantment Teleport
            { 10429, 10000 }, -- Moogle Masque
            { 10250, 10000 }, -- Moogle Suit, Dispense: Mog Missile
            { 18401, 10000 }, -- Moogle Rod, Enchantment Give Gift
            { 18842, 10000 }, -- Nomad Moogle Rod, Enchantment Give Gift
            { 16182, 10000 }, -- Town Moogle Shield, Enchantment Moogle Japery
            { 16183, 10000 }, -- Nomad Moogle Shield, Enchantment Moogle Japery
            --NOVENNIAL SET
            { 11853, 10000 }, -- Novennial Coat
            { 11956, 10000 }, -- Novennial Hose
            { 11854, 10000 }, -- Novennial Dress
            { 11957, 10000 }, -- Novennial Boots
            --DINNER SET
            { 11355, 10000 }, -- Dinner Jacket
            { 16378, 10000 }, -- Dinner Hose
            --SWIMSUITS
            { 11265, 10000 }, -- HUME M TOP
            { 11266, 10000 }, -- HUME F TOP
            { 11267, 10000 }, -- ELV M TOP
            { 11268, 10000 }, -- ELV F TOP
            { 11269, 10000 }, -- TARU M TOP
            { 11270, 10000 }, -- TARU F TOP
            { 11271, 10000 }, -- MITHRA TOP
            { 11272, 10000 }, -- GALKA TOP
            { 16321, 10000 }, -- HUME M BOTTOM
            { 16322, 10000 }, -- HUME F BOTTOM
            { 16323, 10000 }, -- ELV M BOTTOM
            { 16324, 10000 }, -- ELV F BOTTOM
            { 16325, 10000 }, -- TARU M BOTTOM
            { 16326, 10000 }, -- TARU F BOTTOM
            { 16327, 10000 }, -- MITHRA BOTTOM
            { 16328, 10000 }, -- GALKA BOTTOM
            -- DREAM SET
            { 18863, 10000 }, -- Dream Bell
            { 15752, 10000 }, -- Dream Boots
            { 15178, 10000 }, -- Dream Hat
            { 10382, 10000 }, -- Dream Mittens
            { 11967, 10000 }, -- Dream Pants
            { 14519, 10000 }, -- Dream Robe
            { 11965, 10000 }, -- Dream Trousers
        }

        xi.shop.general(player, stock8)
        player:printToPlayer('Got that summer bod? well grab the summer gear!')
    else
        player:printToPlayer(string.format('Page %i not found.', page))
    end
end

xi.module.registerCommand('shop', commandObj)
