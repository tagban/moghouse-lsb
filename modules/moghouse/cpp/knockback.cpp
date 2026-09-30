//
// Knockback (MogHouse)
//
//   A Lua function for !slap: an action packet from `actor` hitting `targetId` with an animation and a
//   knockback (1-7), as mob skills knock players back. LandSandBoat's entity:knockback() is gone, and
//   its injectActionPacket has no knockback field. After teotwaki's injectKnockbackPacket.
//
//       mogKnockback(actor, targetId, knockback, animation)
//

#include "map/action/action.h"
#include "map/entities/base_entity.h"
#include "map/lua/lua_base_entity.h"
#include "map/packets/s2c/0x028_battle2.h"
#include "map/utils/moduleutils.h"
#include "map/zone.h"

class KnockbackModule : public CPPModule
{
    void OnInit() override
    {
        lua.set_function("mogKnockback",
                         [](CLuaBaseEntity* PLuaActor, uint32 targetId, uint8 knockback, uint16 animation)
                         {
                             CBaseEntity* PActor = PLuaActor ? PLuaActor->GetBaseEntity() : nullptr;
                             if (!PActor || !PActor->loc.zone)
                             {
                                 return;
                             }

                             action_t Action{
                                 .actorId    = PActor->id,
                                 .actiontype = ActionCategory::MobSkillFinish,
                                 .actionid   = 0,
                                 .targets    = {
                                     {
                                         .actorId = targetId,
                                         .results = {
                                             {
                                                 .resolution = ActionResolution::Hit,
                                                 .animation  = static_cast<ActionAnimation>(animation),
                                                 .knockback  = static_cast<Knockback>(knockback & 0x07),
                                             },
                                         },
                                     },
                                 },
                             };

                             PActor->loc.zone->PushPacket(PActor, CHAR_INRANGE_SELF, std::make_unique<GP_SERV_COMMAND_BATTLE2>(Action));
                         });
    }
};

REGISTER_CPP_MODULE(KnockbackModule);
