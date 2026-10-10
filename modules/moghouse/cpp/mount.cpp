//
// Which mount a player is seen riding (MogHouse)
//
//   The client draws a rider's mount from the mount index in their character update (0x00D's
//   MountIndex, 8 bits), which LandSandBoat sets only from the game's own Mount command. A script that
//   mounts a player by the MOUNTED effect (!flymount) sets it here first, before the effect:
//
//       mogSetMount(player, mountId)   -- xi.mount's, or MogHouse's own past them (40 on, below)
//       mountId = mogGetMount(player)
//
//   The effect's change of animation then sends it. The client finds a mount's model at file id
//   102704 + mountId: retail's go to 37 (39 and 64 too); MogHouse's client makes its own from 40 on
//   (the bee: 40 small, for a Tarutaru, 41 for the middle-sized, 42 for a Galka; 43 the airship).
//
//   A client without them has no file there, and what it does with a mount it has no model of isn't
//   known: everyone else is told a retail mount in their place (the Crackclaw for the bee, the Levitus
//   for the airship), in each copy
//   of the rider's character update (0x00D, MountIndex: bits 4-11 of the word at 0x44) but the rider's
//   own. (Until the server can tell MogHouse's client from others, MogHouse's players see it too.)
//

#include "map/entities/char_entity.h"
#include "map/lua/lua_base_entity.h"
#include "map/packets/basic.h"
#include "map/utils/moduleutils.h"

namespace
{
    constexpr uint8 OWN_FIRST = 40;      // MogHouse's own mounts, from here on
    constexpr uint8 AIRSHIP   = 43;
    constexpr std::size_t FLAGS6 = 0x44; // GateId : 4, MountIndex : 8, ...

    // what others are told instead: the Levitus for the airship (it floats too), the Crackclaw (a beetle)
    // for the bees
    constexpr auto standIn(uint32 mount) -> uint32
    {
        return mount == AIRSHIP ? 24 : 37;
    }
} // namespace

class MountModule : public CPPModule
{
    void OnInit() override
    {
        lua.set_function("mogSetMount",
                         [](CLuaBaseEntity* PLuaPlayer, uint8 mountId)
                         {
                             auto* PChar = PLuaPlayer ? dynamic_cast<CCharEntity*>(PLuaPlayer->GetBaseEntity()) : nullptr;
                             if (PChar)
                             {
                                 PChar->m_mountId = mountId;
                             }
                         });

        lua.set_function("mogGetMount",
                         [](CLuaBaseEntity* PLuaPlayer) -> uint8
                         {
                             auto* PChar = PLuaPlayer ? dynamic_cast<CCharEntity*>(PLuaPlayer->GetBaseEntity()) : nullptr;
                             return PChar ? PChar->m_mountId : 0;
                         });
    }

    void OnPushPacket(CCharEntity* PChar, const std::unique_ptr<CBasicPacket>& packet) override
    {
        if (!PChar || !packet || packet->getType() != 0x00D || packet->getSize() < FLAGS6 + 4 || packet->ref<uint32>(0x04) == PChar->id)
        {
            return;
        }

        uint32 flags = packet->ref<uint32>(FLAGS6);
        uint32 mount = (flags >> 4) & 0xFF;
        if (mount >= OWN_FIRST)
        {
            packet->ref<uint32>(FLAGS6) = (flags & ~(0xFFu << 4)) | (standIn(mount) << 4);
        }
    }
};

REGISTER_CPP_MODULE(MountModule);
