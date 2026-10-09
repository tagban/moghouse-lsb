//
// Sky and picture effects (MogHouse)
//
//   A zone's look, for clients that know it (MogHouse's own, ffxi-native): an aurora in the sky, the
//   world drawn as a wireframe, a colour filter over the picture. It rides at the end of the zone's
//   weather packet (0x057), after the weather's own fields, tagged "MOGX": other clients read only
//   the weather, the zone's own as it was, and see nothing new.
//
//       mogSkyFx(zoneId, sky, skyR, skyG, skyB, skyStrength, world, filter, filterR, filterG, filterB, filterAmount)
//       mogSkyFxGet(zoneId) -> the same eleven values after zoneId (all 0: the zone as it is)
//
//   Sent to everyone in the zone when it is set, and to each player as they come into the zone (at
//   their client's 0x00C, after it has the zone). All 0 is the zone as it is: a weather packet without
//   the tail tells the clients so. Kept until the server restarts.
//
// The tail, from 0x0C of the packet (after the header and the weather's 8 bytes):
//   0x0C "MOGX"
//   0x10 version (1)
//   0x11 sky: 0 none, 1 an aurora
//   0x12 world: 0 as it is, 1 the zone's own meshes in wireframe (people and monsters as they are),
//        2 everything in wireframe
//   0x13 filter: 0 none, 1 grey, 2 sepia, 3 a colour, 4 inverted, 5 night vision
//   0x14 the sky's colour r, g, b and strength (0-255)
//   0x18 the filter's colour r, g, b and amount (0-255)
//   (0x1C in all)
//
#include "map/entities/char_entity.h"
#include "map/packets/basic.h"
#include "map/packets/s2c/0x057_weather.h"
#include "map/utils/moduleutils.h"
#include "map/utils/zoneutils.h"
#include "map/zone.h"

#include <array>
#include <tuple>
#include <unordered_map>

namespace
{
    constexpr std::size_t TAIL = 0x0C; // where the tail starts: after the header (4) and the weather (8)
    constexpr std::size_t SIZE = 0x1C;

    using Look = std::array<uint8, SIZE - TAIL>;

    std::unordered_map<uint16, Look> looks; // by zone

    auto weatherPacket(CZone* PZone) -> std::unique_ptr<GP_SERV_COMMAND_WEATHER>
    {
        // the zone's weather as it is, since it changed: nothing changes for anyone
        const auto& w = PZone->weather();
        return std::make_unique<GP_SERV_COMMAND_WEATHER>(w.changeTime(), w.current(), 4);
    }
} // namespace

class SkyFxModule : public CPPModule
{
    void OnInit() override
    {
        lua.set_function("mogSkyFx",
                         [](uint16 zoneId, uint8 sky, uint8 skyR, uint8 skyG, uint8 skyB, uint8 skyStrength, uint8 world, uint8 filter,
                            uint8 filterR, uint8 filterG, uint8 filterB, uint8 filterAmount)
                         {
                             CZone* PZone = zoneutils::GetZone(static_cast<xi::ZoneId>(zoneId));
                             if (!PZone)
                             {
                                 return;
                             }

                             if (sky == 0 && world == 0 && filter == 0)
                             {
                                 looks.erase(zoneId);
                             }
                             else
                             {
                                 looks[zoneId] = Look{ 'M', 'O', 'G', 'X', 1, sky, world, filter,
                                                       skyR, skyG, skyB, skyStrength, filterR, filterG, filterB, filterAmount };
                             }

                             // each player's copy gets the tail (OnPushPacket)
                             PZone->PushPacket(nullptr, CHAR_INZONE, std::unique_ptr<CBasicPacket>(weatherPacket(PZone)));
                         });

        lua.set_function("mogSkyFxGet",
                         [](uint16 zoneId)
                         {
                             Look l{};
                             if (auto it = looks.find(zoneId); it != looks.end())
                             {
                                 l = it->second;
                             }

                             return std::make_tuple(l[5], l[8], l[9], l[10], l[11], l[6], l[7], l[12], l[13], l[14], l[15]);
                         });
    }

    void OnPushPacket(CCharEntity* PChar, const std::unique_ptr<CBasicPacket>& packet) override
    {
        if (!PChar || !packet || packet->getType() != 0x057)
        {
            return;
        }

        auto it = looks.find(static_cast<uint16>(PChar->getZone()));
        if (it == looks.end())
        {
            return;
        }

        for (std::size_t i = 0; i < it->second.size(); ++i)
        {
            packet->ref<uint8>(TAIL + i) = it->second[i];
        }

        packet->setSize(SIZE);
    }

    auto OnIncomingPacket(MapSession* session, CCharEntity* PChar, CBasicPacket& packet) -> bool override
    {
        // in the zone (its 0x00A had the zone's weather, without the look): the look, after it
        if (PChar && packet.getType() == 0x00C && PChar->loc.zone && looks.contains(static_cast<uint16>(PChar->getZone())))
        {
            PChar->pushPacket(std::unique_ptr<CBasicPacket>(weatherPacket(PChar->loc.zone)));
        }

        return false; // not taken: LandSandBoat goes on with it
    }
};

REGISTER_CPP_MODULE(SkyFxModule);
