//
// Jump (MogHouse)
//
//   The game's /jump (the client's packet 0x11D) only plays an animation, relayed to everyone nearby.
//   Each one is handed to Lua as well, xi.moghouse.onJump(player) (modules/moghouse/jump.lua), which
//   lifts the player off the ground a little; the jump itself goes on as ever.
//

#include "map/entities/char_entity.h"
#include "map/lua/luautils.h"
#include "map/packets/basic.h"
#include "map/utils/moduleutils.h"

class JumpModule : public CPPModule
{
    void OnInit() override
    {
    }

    auto OnIncomingPacket(MapSession* session, CCharEntity* PChar, CBasicPacket& packet) -> bool override
    {
        if (PChar && packet.getType() == 0x11D)
        {
            luautils::callGlobal<void>("xi.moghouse.onJump", PChar);
        }

        return false; // not taken: LandSandBoat relays the jump as ever
    }
};

REGISTER_CPP_MODULE(JumpModule);
