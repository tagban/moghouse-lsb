# MogHouse's C++ modules

## knockback.cpp: `mogKnockback`

A Lua function for knocking a player back, as mob skills do, from any script or command. Based on
teotwaki's `injectKnockbackPacket`, made a module so LandSandBoat's own code is untouched: the module's
`OnInit` registers the function in Lua.

```lua
mogKnockback(actor, targetId, knockback, animation)
-- actor:     the entity the hit comes from (a player, a mob)
-- targetId:  the entity knocked back (its id: target:getID())
-- knockback: 1 to 7 (7 the farthest; LandSandBoat's Knockback enum)
-- animation: the hit's animation (899 is !slap's)
```

`!slap` uses it: `mogKnockback(player, t:getID(), 7, 899)` (`modules/moghouse/commands/slap.lua`).

The packet is a mob-skill finish (`ActionCategory::MobSkillFinish`) that hits the target with the
animation and knockback; everyone nearby sees it, the actor too (`CHAR_INRANGE_SELF`).

## jump.cpp: each /jump to Lua

The game's `/jump` (the client's packet 0x11D) only plays an animation, which LandSandBoat relays to
everyone nearby. The module's `OnIncomingPacket` hands each one to `xi.moghouse.onJump(player)` as well
(`modules/moghouse/jump.lua`: the player lifted a little, so a jump while walking lands them on a rock or
a step) and lets LandSandBoat go on with it.

It also holds `!fly`'s fliers to the zone's collision: while the local var `[mogFly]on` is 1, a position
report (0x015) whose move goes through a wall or down through the ground is not taken, and
`xi.moghouse.onFlyBlocked(player, x, y, z)` (`commands/fly.lua`) sets them back where they were. A
player whose own wallhack was on when they took off (`[mogFly]on` 2) goes through anything.

### Using them on another LandSandBoat server

1. Copy `knockback.cpp` (or `jump.cpp`, with `jump.lua`) into a module folder, e.g. `modules/custom/cpp/`.
2. List it in `modules/init.txt`: `custom/cpp/knockback.cpp` (or its folder).
3. Build the server again (C++ modules are compiled in).
4. Call `mogKnockback(...)` from Lua; `jump.cpp` needs `xi.moghouse.onJump` defined (`jump.lua`).

Written for LandSandBoat as of September 2026 (`action_t`, `GP_SERV_COMMAND_BATTLE2`).
