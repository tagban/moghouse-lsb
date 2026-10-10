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

## skyfx.cpp: `mogSkyFx`, a zone's look for MogHouse's client

`!skyfx` (`modules/moghouse/commands/skyfx.lua`) gives a zone a look that MogHouse's own client
(ffxi-native) draws: an aurora in the sky, the world as a wireframe, a color filter over the picture.
It rides at the end of the zone's weather packet (0x057), after the weather's own fields, tagged
`MOGX`; other clients read only the weather (the zone's own, unchanged) and see nothing new. It goes to
everyone in the zone when it is set and to each player as they come in (at their client's 0x00C).

```lua
mogSkyFx(zoneId, sky, skyR, skyG, skyB, skyStrength, world, filter, filterR, filterG, filterB, filterAmount)
-- sky:    0 none, 1 an aurora (its color, and strength 0-255)
-- world:  0 as it is, 1 the zone's own meshes in wireframe, 2 everything
-- filter: 0 none, 1 grey, 2 sepia, 3 a color, 4 inverted, 5 night vision (amount 0-255)
-- all 0: the zone as it is
local sky, sr, sg, sb, ss, world, filter, fr, fg, fb, fa = mogSkyFxGet(zoneId)
```

The packet's tail, from 0x0C: `MOGX`, version 1, sky, world, filter, the sky's r g b strength, the
filter's r g b amount (0x1C in all).

### Using them on another LandSandBoat server

1. Copy `knockback.cpp` (or `jump.cpp`, with `jump.lua`; or `skyfx.cpp`, with `commands/skyfx.lua`) into a module folder, e.g. `modules/custom/cpp/`.
2. List it in `modules/init.txt`: `custom/cpp/knockback.cpp` (or its folder).
3. Build the server again (C++ modules are compiled in).
4. Call `mogKnockback(...)` from Lua; `jump.cpp` needs `xi.moghouse.onJump` defined (`jump.lua`).

Written for LandSandBoat as of September 2026 (`action_t`, `GP_SERV_COMMAND_BATTLE2`).

## mount.cpp: `mogSetMount`, `mogGetMount`

The client draws a rider's mount from the mount index in their character update (0x00D's
`MountIndex`), which LandSandBoat sets only from the game's own Mount command. `!flymount` mounts a
player by the MOUNTED effect, so it sets the index first:

```lua
mogSetMount(player, mountId) -- xi.mount's, or MogHouse's own from 40 on (the client makes those)
local mountId = mogGetMount(player)
```

The effect's change of animation then sends it. The client finds a mount's model at file id
102704 + mountId; MogHouse's client makes its own from 40 on (the bee: 40, 41, 42 by the rider's size;
43 the airship), which other clients don't have. So everyone but the rider is told a retail mount in
their place (the Crackclaw), in their copy of the rider's character update (0x00D's `MountIndex`), until
the server can tell MogHouse's client from others.
