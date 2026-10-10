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
//   (the bee: 40 small, for a Tarutaru, 41 for the middle-sized, 42 for a Galka; 43 the airship), and
//   other clients see none there.
//

#include "map/entities/char_entity.h"
#include "map/lua/lua_base_entity.h"
#include "map/utils/moduleutils.h"

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
};

REGISTER_CPP_MODULE(MountModule);
