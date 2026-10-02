//
// Jump (MogHouse)
//
//   The game's /jump (the client's packet 0x11D) only plays an animation, relayed to everyone nearby.
//   Each one is handed to Lua as well, xi.moghouse.onJump(player) (modules/moghouse/jump.lua), and the
//   jump itself goes on as ever.
//
//   For the leap, Lua asks where it would land:
//
//       x, y, z = mogLeapTarget(player, ahead, maxRise, maxDrop)
//
//   the floor `ahead` yalms in front of the player (the way they face), found in the zone's own
//   collision (the client's, as LandSandBoat loads it), if it is at most maxRise above them or maxDrop
//   below, with room to stand there and nothing in the way of the leap (walls, fences, the game's
//   invisible barriers) at the height of a body over the higher of the two floors; else nothing.
//   Heights count down in the game: up is less.
//

#include "common/utils.h"
#include "map/entities/char_entity.h"
#include "map/lua/lua_base_entity.h"
#include "map/lua/luautils.h"
#include "map/packets/basic.h"
#include "map/utils/moduleutils.h"
#include "map/ximesh/ximesh.h"
#include "map/zone.h"

namespace
{

constexpr float BODY = 2.0f; // a body's height (LandSandBoat's ENTITY_HEIGHT)

auto blocked(const XiMesh* mesh, float x0, float y0, float z0, float x1, float y1, float z1) -> bool
{
    return mesh->rayIntersect(Vector3{ x0, y0, z0 }, Vector3{ x1, y1, z1 }, IgnoreTransparentBarriers::No);
}

// The highest floor at (x, z) between `top` and `bottom` (top < bottom: heights count down), to a
// couple of centimeters, by halving: nothing from the yes-or-no ray but whether it hit.
auto floorAt(const XiMesh* mesh, float x, float z, float top, float bottom) -> Maybe<float>
{
    if (!blocked(mesh, x, top, z, x, bottom, z))
    {
        return std::nullopt;
    }

    float lo = top, hi = bottom;
    while (hi - lo > 0.02f)
    {
        const float mid = (lo + hi) * 0.5f;
        if (blocked(mesh, x, top, z, x, mid, z))
        {
            hi = mid;
        }
        else
        {
            lo = mid;
        }
    }

    if (lo - top < 0.05f)
    {
        return std::nullopt; // solid right at the top: inside something, not on it
    }

    return hi;
}

} // namespace

class JumpModule : public CPPModule
{
    void OnInit() override
    {
        lua.set_function("mogLeapTarget",
                         [](CLuaBaseEntity* PLuaPlayer, float ahead, float maxRise, float maxDrop) -> sol::variadic_results
                         {
                             sol::variadic_results out;
                             CBaseEntity*          PEntity = PLuaPlayer ? PLuaPlayer->GetBaseEntity() : nullptr;
                             if (!PEntity || !PEntity->loc.zone || !PEntity->loc.zone->xiMesh())
                             {
                                 return out;
                             }

                             const XiMesh*    mesh = PEntity->loc.zone->xiMesh();
                             const position_t from = PEntity->loc.p;
                             const position_t to   = nearPosition(from, ahead, 0.0f);

                             const auto floor = floorAt(mesh, to.x, to.z, from.y - maxRise - 0.3f, from.y + maxDrop);
                             if (!floor || from.y - *floor > maxRise)
                             {
                                 return out;
                             }

                             // the leap's top: a body above the higher floor, and clear all the way
                             const float apex = std::min(from.y, *floor) - BODY;
                             if (blocked(mesh, from.x, from.y - 0.5f, from.z, from.x, apex, from.z) ||  // up
                                 blocked(mesh, from.x, apex, from.z, to.x, apex, to.z) ||               // across
                                 blocked(mesh, to.x, apex, to.z, to.x, *floor - 0.1f, to.z))            // down
                             {
                                 return out;
                             }

                             out.push_back(sol::make_object(::lua, to.x));
                             out.push_back(sol::make_object(::lua, *floor));
                             out.push_back(sol::make_object(::lua, to.z));
                             return out;
                         });
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
