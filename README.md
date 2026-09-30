# MogHouse's LandSandBoat

The server image [MogHouse](https://moghouse.cc) (`ffxi.cc`) runs: [LandSandBoat](https://github.com/LandSandBoat/server),
newest, with MogHouse's modules, built here by GitHub and published as
`ghcr.io/tagban/moghouse-lsb`. The server pulls it; nothing is compiled there.

Only what is MogHouse's lives here: the modules and their list. LandSandBoat comes from its own
repository at build time, and the server's settings and passwords stay on the server.

## What is in the image

| | |
|---|---|
| LandSandBoat | its `base` branch as it is when the image is built (or a commit a run names) |
| `modules/init.txt` | the modules the server loads, in place of LandSandBoat's list |
| `modules/moghouse/commands/` | MogHouse's GM commands (`!home`, `!gmgear`, `!shop`, ...) |
| `discord_bridge/` | the Discord bridge's module, from [tagban/lsb-discord-bridge](https://github.com/tagban/lsb-discord-bridge) |
| LandSandBoat's own `modules/custom/` | the ones `init.txt` lists (the login announcement, ...) |

## How an image is made

`.github/workflows/build.yml`, on GitHub's machines:

1. LandSandBoat at `base` (or the commit asked for), from its repository.
2. `tools/assemble.sh`: our modules and `init.txt` into it, the bridge's module, and LandSandBoat's
   generated Lua enums (below).
3. LandSandBoat's own `docker/ubuntu.Dockerfile` builds it (about half an hour).
4. Tested (below): if a test fails, nothing is published, and the server keeps the image it has.
5. Published as `ghcr.io/tagban/moghouse-lsb:latest` and `:lsb-<LandSandBoat commit>-mog-<ours>`, labeled
   with the LandSandBoat commit (`cc.moghouse.lsb-commit`), which the server's source is matched to.

It runs nightly (doing nothing if neither LandSandBoat nor this repository changed), on every push to
`main`, and by hand: Actions, Build, Run workflow (where another LandSandBoat commit can be named, to
hold back or try one). The newest 15 images are kept; older ones are deleted after each build.

GitHub turns a public repository's nightly schedule off after 60 days without a push (it emails first);
a push, or Actions, Build, "Enable workflow", turns it back on.

## Adding to it

- **A command**: a file in `modules/moghouse/commands/`, in LandSandBoat's command-module form (see
  any file there: a `commandObj` with `cmdprops` and `onTrigger`, then
  `xi.module.registerCommand('<name>', commandObj)`). The folder is already listed. Add it, with its
  GM level, to `PERMISSIONS` in `tests/commands.lua`.
- **Another module** (Lua or C++): a file or folder under `modules/moghouse/`, and a line in
  `modules/init.txt`. LandSandBoat's own optional modules (`modules/custom/...` in its repository) are
  turned on by listing them there too.

Push to `main`; the image is built; on the server, `ffxi-update` pulls it, updates the database and
restarts (asking first, and warning the players).

## Tests

`tests/*.lua` are run in LandSandBoat's `xi_test` (a map server with simulated players, in the image)
against each new image, before it is published: every command is registered at its GM level, `!jinx`'s
defense makes a level 1 mob hurt a level 75 warrior (about 8 damage a minute becomes 400), its train
sets every live mob in a zone on the victim, and `!slap` knocks back with its animation. (LandSandBoat builds C++ modules into `xi_map` only, not `xi_test`: the knockback packet itself is seen in game.)

To run them yourself (Docker, on an x86-64 machine or VM):

```bash
docker run --rm -v navmeshes:/navmeshes -v ximeshes:/ximeshes ghcr.io/landsandboat/ximeshes:latest   # once
tools/test.sh                       # against ghcr.io/tagban/moghouse-lsb:latest
tools/test.sh <image>               # or another
```

The commands are mounted from the checkout, so a change to a Lua command can be tested before it is
pushed, without building an image. How to write a test: LandSandBoat's
[Testing](https://github.com/LandSandBoat/server/blob/base/docs/wiki/Testing.md).

## Why the generated enums are added here

LandSandBoat generates part of its Lua while building (`scripts/enum/*.codegen.lua`: `xi.job`,
`xi.element`, `xi.effect`, `xi.mod`...), and its Docker build can leave them out of the image (it
records "done" in a cache kept between builds, but the files in the fresh copy of the source). Without
them the map server fails every script that uses them. `assemble.sh` generates them into the source
before the build, which then copies them in with the rest.

## On the server

Its Docker Compose file uses the image (`image: ghcr.io/tagban/moghouse-lsb:latest`) in place of a
local build; its settings (`settings/`), secrets (`.env`) and the scripts that run it are in the
server's own (private) repository.
